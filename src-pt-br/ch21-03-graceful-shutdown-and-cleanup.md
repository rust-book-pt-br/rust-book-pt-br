## Encerramento Elegante e Limpeza

O código na Listagem 21-20 está respondendo a requisições de forma assíncrona por meio do
uso de um thread pool, como pretendíamos. Recebemos alguns avisos sobre os campos
`workers`, `id` e `thread`, que não estamos usando de forma direta, lembrando-nos de que
não estamos limpando nada. Quando usamos o método menos elegante
<kbd>ctrl</kbd>-<kbd>C</kbd> para interromper a thread principal, todas as outras threads
também são interrompidas imediatamente, mesmo que estejam no meio de atender uma
requisição.

A seguir, implementaremos a trait `Drop` para chamar `join` em cada uma das
threads do pool, para que elas possam finalizar as requisições em que estão
trabalhando antes de encerrar. Em seguida, implementaremos uma maneira de
informar às threads que elas devem parar de aceitar novas requisições e se
desligar. Para ver esse código em ação, vamos modificar nosso servidor para
aceitar apenas duas requisições antes de desligar normalmente seu thread pool.

Uma coisa a observar à medida que avançamos: nada disso afeta as partes do
código que lidam com a execução das closures, então tudo aqui seria o mesmo se
estivéssemos usando um thread pool para um runtime async.

### Implementando a trait `Drop` em `ThreadPool`

Vamos começar implementando `Drop` em nosso thread pool. Quando ele for
descartado, todas as nossas threads deverão ser reunidas com `join` para
garantir que concluam seu trabalho. A Listagem 21-22 mostra uma primeira
tentativa de implementar `Drop`; esse código ainda não funcionará muito bem.

<Listing number="21-22" file-name="src/lib.rs" caption="Esperando cada thread com `join` quando o thread pool sai de escopo">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch21-web-server/listing-21-22/src/lib.rs:here}}
```

</Listing>

Primeiro, percorremos cada um dos `workers` do thread pool. Usamos `&mut` para
isso porque `self` é uma referência mutável e também precisamos poder alterar
cada `worker`. Para cada `worker`, imprimimos uma mensagem dizendo que essa
instância de `Worker` está sendo encerrada e então chamamos `join` na thread
dessa instância. Se a chamada a `join` falhar, usamos `unwrap` para fazer o
Rust entrar em `panic` e encerrar de forma abrupta.

Aqui está o erro que obtemos quando compilamos este código:

```console
{{#include ../listings/ch21-web-server/listing-21-22/output.txt}}
```

O erro nos diz que não podemos chamar `join` porque só temos um empréstimo
mutável de cada `worker`, e `join` toma ownership de seu argumento. Para
resolver esse problema, precisamos mover a thread para fora da instância
`Worker` que possui o campo `thread`, para que `join` possa consumi-la. Uma
maneira de fazer isso seria adotar a mesma abordagem que usamos na
Listagem 18-15. Se `Worker` armazenasse um `Option<thread::JoinHandle<()>>`,
poderíamos chamar o método `take` em `Option` para mover o valor para fora da
variante `Some` e deixar uma variante `None` em seu lugar. Em outras palavras,
um `Worker` em execução teria `Some` em `thread`, e, quando quiséssemos limpar
um `Worker`, substituiríamos `Some` por `None`, para que o `Worker` deixasse de
ter uma thread para executar.

No entanto, o _único_ momento em que isso aconteceria seria ao descartar o
`Worker`. Em troca, teríamos que lidar com um `Option<thread::JoinHandle<()>>`
em todo lugar em que acessássemos `worker.thread`. Rust idiomático usa bastante
`Option`, mas, quando você se vê embrulhando algo que sabe que sempre estará
presente em um `Option` apenas como solução de contorno, é uma boa ideia
procurar abordagens alternativas para manter o código mais limpo e menos sujeito
a erros.

Neste caso, existe uma alternativa melhor: o método `Vec::drain`. Ele aceita um
parâmetro de intervalo para especificar quais itens remover do vetor e retorna
um iterator desses itens. Passar a sintaxe de intervalo `..` removerá *todos*
os valores do vetor.

Portanto, precisamos atualizar a implementação de `Drop` para `ThreadPool`
assim:

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

### Sinalizando para as Threads Pararem de Escutar Trabalhos

Com todas as alterações que fizemos, nosso código compila sem nenhum aviso.
No entanto, a má notícia é que esse código ainda não funciona da maneira que
desejamos. A chave está na lógica da closure executada pelas threads das
instâncias `Worker`: no momento, chamamos `join`, mas isso não desligará essas
threads, porque elas estão em `loop`, sempre procurando trabalho. Se tentarmos
descartar nosso `ThreadPool` com a implementação atual de `drop`, a thread
principal ficará bloqueada para sempre, esperando a primeira thread terminar.

Para corrigir esse problema, precisaremos de uma alteração na implementação de
`drop` para `ThreadPool` e, em seguida, de uma mudança no loop de `Worker`.

Primeiro, mudaremos a implementação de `drop` para `ThreadPool` para descartar
explicitamente o `sender` antes de esperar a conclusão das threads. A
Listagem 21-23 mostra as alterações em `ThreadPool` para descartar
explicitamente `sender`. Ao contrário do caso da thread, aqui _precisamos_ usar
um `Option` para poder mover `sender` para fora de `ThreadPool` com
`Option::take`.

<Listing number="21-23" file-name="src/lib.rs" caption="Fazendo `drop` explícito de `sender` antes de esperar as threads `Worker` com `join`">

```rust,noplayground,not_desired_behavior
{{#rustdoc_include ../listings/ch21-web-server/listing-21-23/src/lib.rs:here}}
```

</Listing>

Descartar `sender` fecha o canal, o que indica que nenhuma outra mensagem será
enviada. Quando isso acontece, todas as chamadas a `recv` feitas pelas
instâncias `Worker` em seu loop infinito retornam erro. Na Listagem 21-24,
alteramos o loop de `Worker` para sair normalmente nesse caso, o que significa
que as threads terminarão quando a implementação de `drop` para `ThreadPool`
chamar `join` nelas.

<Listing number="21-24" file-name="src/lib.rs" caption="Saindo explicitamente do loop quando `recv` retorna um erro">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-24/src/lib.rs:here}}
```

</Listing>

Para ver este código em ação, vamos modificar `main` para aceitar apenas duas requisições
antes de desligar o servidor normalmente, conforme mostrado na Listagem 21-25.

<Listing number="21-25" file-name="src/main.rs" caption="Encerrando o servidor após atender duas requisições ao sair do loop">

```rust,ignore
{{#rustdoc_include ../listings/ch21-web-server/listing-21-25/src/main.rs:here}}
```

</Listing>

Você não gostaria que um web server do mundo real desligasse depois de atender
apenas duas requisições. Este código apenas demonstra que o desligamento e a
limpeza normais estão funcionando.

O método `take` é definido na trait `Iterator` e limita a iteração, no máximo,
aos dois primeiros itens. O `ThreadPool` sairá de escopo ao final de `main`, e
a implementação de `drop` será executada.

Inicie o servidor com `cargo run` e faça três requisições. A terceira deverá
falhar e, em seu terminal, você deverá ver uma saída semelhante a esta:

<!-- manual-regeneration
cd listings/ch21-web-server/listing-21-25
cargo run
curl http://127.0.0.1:7878
curl http://127.0.0.1:7878
curl http://127.0.0.1:7878
third request will error because server will have shut down
copy output below
Can't automate because the output depends on making requests
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

Você pode ver uma ordem diferente de IDs e mensagens `Worker` impressas. Pelas
mensagens, conseguimos perceber como esse código funciona: as instâncias
`Worker` 0 e 3 receberam as duas primeiras requisições. O servidor parou de
aceitar conexões após a segunda, e a implementação de `Drop` para `ThreadPool`
começa a ser executada antes mesmo de `Worker 3` iniciar seu trabalho. Soltar o
`sender` desconecta todas as instâncias `Worker` e solicita que elas sejam
encerradas. Cada instância `Worker` imprime uma mensagem quando se desconecta,
e então o thread pool chama `join` para esperar que a thread de cada `Worker`
termine.

Observe um aspecto interessante desta execução específica: o `ThreadPool`
descartou o `sender`, e, antes que qualquer `Worker` recebesse um erro,
tentamos fazer `join` em `Worker 0`. `Worker 0` ainda não havia recebido um
erro de `recv`, então a thread principal ficou bloqueada, esperando `Worker 0`
terminar. Enquanto isso, `Worker 3` recebeu um trabalho e todas as threads
receberam um erro. Quando `Worker 0` terminou, a thread principal esperou que o
restante das instâncias `Worker` terminasse. Nesse ponto, todas já tinham saído
de seus loops e parado.

Parabéns! Agora concluímos nosso projeto: temos um web server básico que usa
um thread pool para responder de forma assíncrona. Somos capazes de realizar um
encerramento elegante do servidor, limpando todas as threads do pool.

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
- Encontre um crate de thread pool em [crates.io](https://crates.io/) e
  implemente um web server semelhante usando esse crate. Em seguida, compare
  sua API e robustez com o thread pool que implementamos.

## Resumo

Bom trabalho! Você chegou ao final do livro! Queremos agradecer por ter
acompanhado este tour pelo Rust conosco. Agora você está pronto para criar seus
próprios projetos em Rust e ajudar em projetos de outras pessoas. Tenha em
mente que existe uma comunidade acolhedora de outros Rustaceans que adoraria
ajudar com qualquer desafio que você encontrar em sua jornada com Rust.
