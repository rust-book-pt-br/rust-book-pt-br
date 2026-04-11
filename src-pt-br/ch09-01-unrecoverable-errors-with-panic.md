## Erros irrecuperáveis ​​com `panic!`

Às vezes, coisas ruins acontecem no seu código e não há nada que você possa fazer a respeito.
isto. Nestes casos, Rust possui a macro `panic!`. Existem duas maneiras de causar um
pânico na prática: executando uma ação que causa pânico em nosso código (como
acessando um array após o final) ou chamando explicitamente a macro `panic!`.
Em ambos os casos, causamos pânico em nosso programa. Por padrão, esses pânicos irão
imprima uma mensagem de falha, relaxe, limpe a pilha e saia. Através de um
variável de ambiente, você também pode fazer com que Rust exiba a pilha de chamadas quando um
o pânico ocorre para tornar mais fácil rastrear a origem do pânico.

> ### Desenrolar a pilha ou abortar em resposta a um pânico
>
> Por padrão, quando ocorre um pânico, o programa começa a _desenrolar_, o que significa
> Rust volta para a pilha e limpa os dados de cada função que ele
> encontros. No entanto, voltar e limpar dá muito trabalho. Ferrugem
> portanto, permite que você escolha a alternativa de _abortar_ imediatamente,
> que encerra o programa sem limpar.
>
> A memória que o programa estava usando precisará ser limpa pelo
> sistema operacional. Se no seu projeto você precisar tornar o binário resultante como
> menor possível, você pode passar do relaxamento para o aborto em caso de pânico,
> adicionando `panic = 'abort'` às seções `[profile]` apropriadas em seu
> Arquivo _Cargo.toml_. Por exemplo, se você quiser abortar em caso de pânico no modo de liberação,
> adicione isto:
>
> ```toml
> [perfil.lançamento]
> pânico = 'abortar'
> ```

Vamos tentar chamar `panic!` em um programa simples:

<Listing file-name="src/main.rs">

```rust,should_panic,panics
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-01-panic/src/main.rs}}
```

</Listing>

Ao executar o programa, você verá algo assim:

```console
{{#include ../listings/ch09-error-handling/no-listing-01-panic/output.txt}}
```

A chamada para `panic!` causa a mensagem de erro contida nas duas últimas linhas.
A primeira linha mostra nossa mensagem de pânico e o local em nosso código-fonte onde
o pânico ocorreu: _src/main.rs:2:5_ indica que é a segunda linha,
quinto caractere do nosso arquivo _src/main.rs_.

Neste caso, a linha indicada faz parte do nosso código, e se formos até lá
linha, vemos a chamada de macro `panic!`. Em outros casos, a chamada `panic!` pode
estar no código que nosso código chama, e o nome do arquivo e o número da linha relatados por
a mensagem de erro será o código de outra pessoa onde a macro `panic!` está
chamado, não a linha do nosso código que eventualmente levou à chamada `panic!`.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-a-panic-backtrace"></a>

Podemos usar o backtrace das funções de onde veio a chamada `panic!` para descobrir
a parte do nosso código que está causando o problema. Para entender como usar
um backtrace `panic!`, vamos dar uma olhada em outro exemplo e ver como é quando
uma chamada `panic!` vem de uma biblioteca por causa de um bug em nosso código, em vez de
do nosso código chamando a macro diretamente. A Listagem 9-1 tem algum código que
tenta acessar um índice em um vetor além do intervalo de índices válidos.

<Listing number="9-1" file-name="src/main.rs" caption="Attempting to access an element beyond the end of a vector, which will cause a call to `panic!`">

```rust,should_panic,panics
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-01/src/main.rs}}
```

</Listing>

Aqui, estamos tentando acessar o 100º elemento do nosso vetor (que está em
índice 99 porque a indexação começa em zero), mas o vetor tem apenas três
elementos. Nesta situação, Rust entrará em pânico. Usar `[]` deve retornar
um elemento, mas se você passar um índice inválido, não há nenhum elemento que Rust
poderia retornar aqui isso seria correto.

Em C, tentar ler além do final de uma estrutura de dados é indefinido
comportamento. Você pode obter o que quer que esteja no local da memória que
correspondem a esse elemento na estrutura de dados, mesmo que a memória
não pertence a essa estrutura. Isso é chamado de _buffer overread_ e pode
levar a vulnerabilidades de segurança se um invasor for capaz de manipular o índice
de forma a ler dados que não deveriam ser permitidos e que são armazenados após
a estrutura de dados.

Para proteger seu programa contra esse tipo de vulnerabilidade, se você tentar ler um
elemento em um índice que não existe, Rust irá parar a execução e se recusará a
continuar. Vamos tentar e ver:

```console
{{#include ../listings/ch09-error-handling/listing-09-01/output.txt}}
```

Este erro aponta para a linha 4 do nosso _main.rs_ onde tentamos acessar o índice
99 do vetor em `v`.

A linha `note:` nos diz que podemos definir o ambiente `RUST_BACKTRACE`
variável para obter um rastreamento exato do que aconteceu para causar o erro. UM
_backtrace_ é uma lista de todas as funções que foram chamadas para chegar a este
apontar. Backtraces em Rust funcionam como em outras linguagens: a chave para
ler o backtrace é começar do topo e ler até ver os arquivos que você
escreveu. Esse é o local onde o problema se originou. As linhas acima desse ponto
são códigos que seu código chamou; as linhas abaixo são o código que chamou seu
código. Essas linhas antes e depois podem incluir o código Rust principal, padrão
código da biblioteca ou caixas que você está usando. Vamos tentar obter um backtrace
definindo a variável de ambiente `RUST_BACKTRACE` para qualquer valor, exceto `0`.
A Listagem 9-2 mostra um resultado semelhante ao que você verá.

<!-- manual-regeneration
listagens de cd/ch09-error-handling/listing-09-01
RUST_BACKTRACE=1 corrida de carga
copie a saída do backtrace abaixo
verifique o número de backtrace mencionado no texto abaixo da listagem
-->

<Listing number="9-2" caption="The backtrace generated by a call to `panic!` displayed when the environment variable `RUST_BACKTRACE` is set">

```console
$ RUST_BACKTRACE=1 cargo run
thread 'main' panicked at src/main.rs:4:6:
index out of bounds: the len is 3 but the index is 99
stack backtrace:
   0: rust_begin_unwind
             at /rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/std/src/panicking.rs:692:5
   1: core::panicking::panic_fmt
             at /rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/panicking.rs:75:14
   2: core::panicking::panic_bounds_check
             at /rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/panicking.rs:273:5
   3: <usize as core::slice::index::SliceIndex<[T]>>::index
             at file:///home/.rustup/toolchains/1.85/lib/rustlib/src/rust/library/core/src/slice/index.rs:274:10
   4: core::slice::index::<impl core::ops::index::Index<I> for [T]>::index
             at file:///home/.rustup/toolchains/1.85/lib/rustlib/src/rust/library/core/src/slice/index.rs:16:9
   5: <alloc::vec::Vec<T,A> as core::ops::index::Index<I>>::index
             at file:///home/.rustup/toolchains/1.85/lib/rustlib/src/rust/library/alloc/src/vec/mod.rs:3361:9
   6: panic::main
             at ./src/main.rs:4:6
   7: core::ops::function::FnOnce::call_once
             at file:///home/.rustup/toolchains/1.85/lib/rustlib/src/rust/library/core/src/ops/function.rs:250:5
note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.
```

</Listing>

Isso é muita produção! A saída exata que você vê pode ser diferente dependendo
em seu sistema operacional e versão Rust. Para obter backtraces com este
informações, os símbolos de depuração devem estar habilitados. Os símbolos de depuração são habilitados por
padrão ao usar `cargo build` ou `cargo run` sem o sinalizador `--release`,
como temos aqui.

Na saída da Listagem 9-2, a linha 6 do backtrace aponta para a linha em nosso
projeto que está causando o problema: linha 4 de _src/main.rs_. Se não quisermos
nosso programa entre em pânico, devemos começar nossa investigação no local apontado
na primeira linha mencionando um arquivo que escrevemos. Na Listagem 9-1, onde
escreveu deliberadamente um código que causaria pânico, a maneira de consertar o pânico é não
solicitar um elemento além do intervalo dos índices vetoriais. Quando seu código
pânico no futuro, você precisará descobrir qual ação o código está executando
com quais valores causarão pânico e o que o código deve fazer.

Voltaremos a `panic!` e quando devemos ou não usar `panic!` para
lidar com condições de erro no [“Para `panic!` ou Não para
`panic!`”][to-panic-or-not-to-panic]<!-- ignore --> seção mais adiante neste
capítulo. A seguir, veremos como se recuperar de um erro usando `Result`.

[to-panic-or-not-to-panic]: ch09-03-to-panic-or-not-to-panic.html#to-panic-or-not-to-panic
