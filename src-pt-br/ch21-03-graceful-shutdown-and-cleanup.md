## Desligamento e limpeza elegantes

O código na Listagem 21-20 está respondendo a solicitações de forma assíncrona por meio do
uso de um pool thread, como pretendíamos. Recebemos alguns avisos sobre o `workers`,
Campos ` id`e ` thread`que não estamos usando de forma direta que nos lembre
não estamos limpando nada. Quando usamos o menos elegante
Método <kbd>ctrl</kbd>-<kbd>C</kbd> para interromper o thread principal, todos os outros threads
também são interrompidos imediatamente, mesmo que estejam no meio de um serviço
pedido.

A seguir, implementaremos o `Drop` trait para chamar `join` em cada um dos
threads no pool para que eles possam finalizar as solicitações nas quais estão trabalhando
antes de fechar. Em seguida, implementaremos uma maneira de informar ao threads que eles deveriam
pare de aceitar novas solicitações e desligue. Para ver este código em ação, vamos
modifique nosso servidor para aceitar apenas duas solicitações antes de desligar normalmente
seu conjunto thread.

Uma coisa a ser observada à medida que avançamos: nada disso afeta as partes do código que
lidar com a execução do closures, então tudo aqui seria o mesmo se estivéssemos
usando um pool thread para um tempo de execução async.

### Implementando a característica `Drop` em `ThreadPool`

Vamos começar implementando `Drop` em nosso pool thread. Quando a piscina estiver
descartados, todos os nossos threads devem se juntar para garantir que concluam seu trabalho.
A Listagem 21-22 mostra uma primeira tentativa de implementação de `Drop`; este código não vai
bastante trabalho ainda.

<Listing number="21-22" file-name="src/lib.rs" caption="Esperando cada thread com `join` quando o thread pool sai de escopo">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch21-web-server/listing-21-22/src/lib.rs:here}}
```

</Listing>

Primeiro, percorremos cada um dos pools thread `workers`. Usamos ` &mut`para isso
porque ` self`é uma referência mutável e também precisamos ser capazes de sofrer mutação
` worker `. Para cada` worker `, imprimimos uma mensagem dizendo que este
A instância` Worker `está sendo encerrada e então chamamos` join `nesse` Worker `
thread da instância. Se a chamada para` join `falhar, usamos` unwrap`para fazer Rust
panic e entre em um desligamento desagradável.

Aqui está o erro que obtemos quando compilamos este código:

```console
{{#include ../listings/ch21-web-server/listing-21-22/output.txt}}
```

O erro nos diz que não podemos chamar `join` porque só temos um borrowing mutável
de cada `worker` e `join` leva ownership de seu argumento. Para resolver isso
problema, precisamos mover o thread para fora da instância `Worker` que possui
`thread ` para que`join ` possa consumir o thread. Uma maneira de fazer isso é pegar
a mesma abordagem que adotamos na Listagem 18-15. Se`Worker ` mantivesse um
`Option<thread::JoinHandle<()>> `, poderíamos chamar o método` take `no
` Option `para mover o valor para fora da variante` Some `e deixar uma variante` None `
em seu lugar. Em outras palavras, um` Worker `em execução teria um` Some `
variante em` thread `, e quando quiséssemos limpar um` Worker `, substituiríamos
` Some `com` None `para que o` Worker`não tenha um thread para rodar.

No entanto, o _único_ momento em que isso aconteceria seria ao descartar o
`Worker `. Em troca, teríamos que lidar com um
` Option<thread::JoinHandle<()>> `em qualquer lugar onde acessamos` worker.thread `.
Idiomatic Rust usa bastante` Option `, mas quando você se encontra embrulhando
algo que você sabe que sempre estará presente em um` Option`como uma solução alternativa como
isso, é uma boa ideia procurar abordagens alternativas para tornar seu código
mais limpo e menos sujeito a erros.

Neste caso, existe uma alternativa melhor: o método `Vec::drain`. Aceita
um parâmetro de intervalo para especificar quais itens remover do vetor e retornar
um iterator desses itens. Passar a sintaxe do intervalo `..` removerá *todos*
valor do vetor.

Portanto, precisamos atualizar a implementação `ThreadPool` ` drop`assim:

<Listing file-name="src/lib.rs">

```rust
{{#rustdoc_include ../listings/ch21-web-server/no-listing-04-update-drop-definition/src/lib.rs:here}}
```

</Listing>

Isso resolve o erro do compilador e não requer nenhuma outra alteração em nosso
código. Observe que, como drop pode ser chamado em caso de pânico, o unwrap
também poderia panic e causar um panic duplo, que trava imediatamente o
programa e encerra qualquer limpeza em andamento. Isso é bom para um programa de exemplo,
mas não é recomendado para código de produção.

### Sinalização para os threads pararem de escutar trabalhos

Com todas as alterações que fizemos, nosso código é compilado sem nenhum aviso.
No entanto, a má notícia é que esse código não funciona da maneira que desejamos
ainda. A chave é a lógica no closures executada pelo threads do `Worker`
instâncias: No momento, chamamos ` join`, mas isso não desligará o threads,
porque eles ` loop`estão sempre procurando emprego. Se tentarmos abandonar nossos
` ThreadPool `com nossa implementação atual do` drop`, o thread principal será
bloquear para sempre, aguardando a conclusão do primeiro thread.

Para corrigir este problema, precisaremos de uma alteração no `ThreadPool` ` drop`
implementação e, em seguida, uma mudança no loop ` Worker`.

Primeiro, mudaremos a implementação `ThreadPool` ` drop`para eliminar explicitamente
o ` sender`antes de aguardar a conclusão do threads. A Listagem 21-23 mostra o
alterações em ` ThreadPool`para eliminar explicitamente ` sender`. Ao contrário do thread,
aqui _precisamos_ usar um ` Option`para poder mover ` sender`para fora
` ThreadPool `com` Option::take`.

<Listing number="21-23" file-name="src/lib.rs" caption="Fazendo `drop` explícito de `sender` antes de esperar as threads `Worker` com `join`">

```rust,noplayground,not_desired_behavior
{{#rustdoc_include ../listings/ch21-web-server/listing-21-23/src/lib.rs:here}}
```

</Listing>

A eliminação de `sender` fecha o canal, o que indica que nenhuma outra mensagem será
enviado. Quando isso acontece, todas as chamadas para `recv` que as instâncias `Worker` fazem
no loop infinito retornará um erro. Na Listagem 21-24, alteramos o
Loop `Worker` para sair normalmente do loop nesse caso, o que significa que o threads
terminará quando a implementação `ThreadPool` ` drop`chamar ` join`neles.

<Listing number="21-24" file-name="src/lib.rs" caption="Saindo explicitamente do loop quando `recv` retorna um erro">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-24/src/lib.rs:here}}
```

</Listing>

Para ver este código em ação, vamos modificar `main` para aceitar apenas duas solicitações
antes de desligar o servidor normalmente, conforme mostrado na Listagem 21-25.

<Listing number="21-25" file-name="src/main.rs" caption="Encerrando o servidor após atender duas requisições ao sair do loop">

```rust,ignore
{{#rustdoc_include ../listings/ch21-web-server/listing-21-25/src/main.rs:here}}
```

</Listing>

Você não gostaria que um web server do mundo real desligasse depois de servir apenas dois
solicitações. Este código apenas demonstra que o desligamento e a limpeza normais são
em condições de funcionamento.

O método `take` é definido em `Iterator` trait e limita a iteração
no máximo aos dois primeiros itens. O `ThreadPool` sairá do escopo no
final de `main`, e a implementação de ` drop`será executada.

Inicie o servidor com `cargo run` e faça três solicitações. O terceiro pedido
deve ocorrer um erro e, em seu terminal, você deverá ver uma saída semelhante a esta:

<!-- manual-regeneration
listagens de cd/ch21-web-server/listing-21-25
Execução cargo
enrolar http://127.0.0.1:7878
enrolar http://127.0.0.1:7878
enrolar http://127.0.0.1:7878
a terceira solicitação apresentará erro porque o servidor será desligado
copie a saída abaixo
Não é possível automatizar porque a saída depende de solicitações
-->

```console
$ cargo run
   Compiling hello v0.1.0 (file:///projects/hello)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.41s
     Running `target/debug/hello`
Worker 0 got a job; executing.
Shutting down.
Shutting down worker 0
Worker 3 got a job; executing.
Worker 1 disconnected; shutting down.
Worker 2 disconnected; shutting down.
Worker 3 disconnected; shutting down.
Worker 0 disconnected; shutting down.
Shutting down worker 1
Shutting down worker 2
Shutting down worker 3
```

Você poderá ver uma ordem diferente de IDs e mensagens `Worker` impressas. Nós podemos
veja como esse código funciona a partir das mensagens: As instâncias 0 e 3 do `Worker` obtiveram o
dois primeiros pedidos. O servidor parou de aceitar conexões após o segundo
conexão, e a implementação `Drop` em `ThreadPool` começa a ser executada
antes mesmo de `Worker 3` iniciar seu trabalho. Soltar o `sender` desconecta todos os
instâncias `Worker` e solicita que elas sejam encerradas. As instâncias `Worker` cada
imprima uma mensagem quando eles se desconectarem e, em seguida, o pool thread chama `join` para
espere que cada `Worker` thread termine.

Observe um aspecto interessante desta execução específica: O `ThreadPool`
derrubou o ` sender`, e antes que qualquer ` Worker`recebesse um erro, tentamos
junte-se ao ` Worker 0`. ` Worker 0`ainda não recebeu um erro do ` recv`, então o principal
thread bloqueado, aguardando a conclusão do ` Worker 0`. Enquanto isso, ` Worker 3`
recebeu um trabalho e todos os threads receberam um erro. Quando ` Worker 0`terminar,
o thread principal esperou que o restante das instâncias ` Worker`terminassem. Naquela
ponto, todos eles saíram de seus loops e pararam.

Parabéns! Agora concluímos nosso projeto; temos um web server básico que usa
um pool thread para responder de forma assíncrona. Somos capazes de realizar um gracioso
desligamento do servidor, que limpa todo o threads do pool.

Aqui está o código completo para referência:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch21-web-server/no-listing-07-final-code/src/main.rs}}
```

</Listing>

<Listing file-name="src/lib.rs">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/no-listing-07-final-code/src/lib.rs}}
```

</Listing>

Poderíamos fazer mais aqui! Se você quiser continuar aprimorando este projeto,
aqui estão algumas ideias:

- Adicione mais documentação ao `ThreadPool` e seus métodos públicos.
- Adicione testes de funcionalidade da biblioteca.
- Altere as chamadas para `unwrap` para um tratamento de erros mais robusto.
- Use `ThreadPool` para realizar alguma tarefa diferente de atender solicitações da web.
- Encontre um pool thread crate em [crates.io](https://crates.io/) e implemente um
  web server semelhante usando o crate. Em seguida, compare sua API e
  robustez ao pool thread que implementamos.

## Resumo

Bom trabalho! Você chegou ao final do livro! Queremos agradecer-lhe por
juntando-se a nós neste tour pelo Rust. Agora você está pronto para implementar seu próprio Rust
projetos e ajudar com projetos de outras pessoas. Tenha em mente que existe um
comunidade acolhedora de outros Rustáceos que adorariam ajudá-lo com qualquer
desafios que você encontra em sua jornada Rust.
