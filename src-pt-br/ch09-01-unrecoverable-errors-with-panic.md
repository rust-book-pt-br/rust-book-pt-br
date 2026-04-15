## Erros Irrecuperáveis com `panic!`

Às vezes, coisas ruins acontecem no seu código, e não há nada que você possa
fazer a respeito. Nesses casos, Rust oferece a macro `panic!`. Na prática,
existem duas formas de causar um panic: executando uma ação que faça o código
entrar em panic, como acessar um array além do fim, ou chamando explicitamente
a macro `panic!`. Em ambos os casos, provocamos um panic no programa. Por
padrão, esses panics exibem uma mensagem de falha, fazem _unwind_, limpam a
stack e encerram o programa. Por meio de uma variável de ambiente, você também
pode fazer Rust exibir a call stack quando ocorre um panic, para facilitar a
localização da origem do problema.

> ### Fazendo Unwind da Stack ou Abortando em Resposta a um Panic
>
> Por padrão, quando ocorre um panic, o programa começa a fazer _unwind_, o que
> significa que Rust percorre a stack de volta e limpa os dados de cada função
> encontrada. No entanto, percorrer a stack e limpar tudo dá trabalho. Por
> isso, Rust permite que você escolha a alternativa de _abortar_ imediatamente,
> o que encerra o programa sem fazer limpeza.
>
> A memória que o programa estava usando precisará então ser liberada pelo
> sistema operacional. Se, no seu projeto, você precisar tornar o binário
> resultante o menor possível, pode trocar de unwind para abort ao ocorrer um
> panic adicionando `panic = 'abort'` às seções `[profile]` apropriadas do
> arquivo _Cargo.toml_. Por exemplo, se você quiser abortar ao ocorrer um panic
> no modo release, adicione isto:
>
> ```toml
> [profile.release]
> panic = 'abort'
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

A chamada a `panic!` causa a mensagem de erro contida nas duas últimas linhas.
A primeira linha mostra nossa mensagem de panic e o local do código-fonte em
que ele ocorreu: _src/main.rs:2:5_ indica a segunda linha e o quinto caractere
do nosso arquivo _src/main.rs_.

Neste caso, a linha indicada faz parte do nosso código e, se formos até ela,
veremos a chamada à macro `panic!`. Em outros casos, a chamada a `panic!` pode
estar no código que o nosso código chamou, e o nome do arquivo e o número da
linha informados pela mensagem de erro serão do código de outra pessoa onde a
macro `panic!` foi chamada, e não da linha do nosso código que acabou levando
até essa chamada.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-a-panic-backtrace"></a>

Podemos usar o backtrace das funções de onde veio a chamada `panic!` para
descobrir qual parte do nosso código está causando o problema. Para entender
como usar um backtrace de `panic!`, vamos analisar outro exemplo e ver como é
quando uma chamada `panic!` vem de uma biblioteca por causa de um bug no nosso
código, em vez de vir diretamente de uma chamada nossa à macro. A Listagem 9-1
tem um código que tenta acessar um índice de um vetor além do intervalo de
índices válidos.

<Listing number="9-1" file-name="src/main.rs" caption="Tentando acessar um elemento além do fim de um vetor, o que causará uma chamada a `panic!`">

```rust,should_panic,panics
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-01/src/main.rs}}
```

</Listing>

Aqui, estamos tentando acessar o centésimo elemento do nosso vetor, que está no
índice 99, porque a indexação começa em zero, mas o vetor tem apenas três
elementos. Nessa situação, Rust entra em panic. Usar `[]` deveria retornar um
elemento, mas, se você passar um índice inválido, não existe nenhum elemento
que Rust pudesse retornar aqui de forma correta.

Em C, tentar ler além do fim de uma estrutura de dados é um comportamento
indefinido. Você pode acabar obtendo qualquer coisa que esteja naquela posição
de memória correspondente ao elemento na estrutura, mesmo que a memória não
pertença a ela. Isso é chamado de _buffer overread_ e pode levar a
vulnerabilidades de segurança se uma pessoa atacante conseguir manipular o
índice de maneira a ler dados que não deveria ter permissão para acessar e que
estejam armazenados depois da estrutura de dados.

Para proteger seu programa contra esse tipo de vulnerabilidade, se você tentar
ler um elemento em um índice inexistente, Rust vai interromper a execução e se
recusar a continuar. Vamos tentar para ver:

```console
{{#include ../listings/ch09-error-handling/listing-09-01/output.txt}}
```

Esse erro aponta para a linha 4 do nosso _main.rs_, onde tentamos acessar o
índice 99 do vetor `v`.

A linha `note:` nos diz que podemos definir a variável de ambiente
`RUST_BACKTRACE` para obter um backtrace exato do que aconteceu para causar o
erro. Um _backtrace_ é uma lista de todas as funções chamadas até chegar a esse
ponto. Backtraces em Rust funcionam como em outras linguagens: a chave para
lê-los é começar do topo e continuar até encontrar arquivos que você escreveu.
Esse é o ponto onde o problema se originou. As linhas acima desse ponto são
códigos que seu código chamou; as linhas abaixo são códigos que chamaram o seu
código. Essas linhas antes e depois podem incluir código interno do Rust,
código da biblioteca padrão ou crates que você está usando. Vamos tentar obter
um backtrace definindo a variável de ambiente `RUST_BACKTRACE` para qualquer
valor diferente de `0`. A Listagem 9-2 mostra uma saída parecida com a que você
verá.

<!-- manual-regeneration
cd listings/ch09-error-handling/listing-09-01
RUST_BACKTRACE=1 cargo run
copy the backtrace output below
check the backtrace number mentioned in the text below the listing
-->

<Listing number="9-2" caption="O backtrace gerado por uma chamada a `panic!`, exibido quando a variável de ambiente `RUST_BACKTRACE` está definida">

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

É bastante saída! A saída exata pode ser diferente dependendo do seu sistema
operacional e da versão do Rust. Para obter backtraces com essas informações,
os símbolos de depuração precisam estar habilitados. Eles ficam habilitados por
padrão ao usar `cargo build` ou `cargo run` sem a flag `--release`, como
estamos fazendo aqui.

Na saída da Listagem 9-2, a linha 6 do backtrace aponta para a linha do nosso
projeto que está causando o problema: a linha 4 de _src/main.rs_. Se não
quisermos que o programa entre em panic, devemos começar a investigação no
local indicado pela primeira linha que menciona um arquivo escrito por nós. Na
Listagem 9-1, em que escrevemos deliberadamente um código que causaria panic, a
forma de corrigir o problema é não solicitar um elemento além do intervalo de
índices do vetor. Quando seu código entrar em panic no futuro, você vai
precisar descobrir que ação ele está realizando, com quais valores, para causar
o panic, e o que ele deveria fazer em vez disso.

Voltaremos a `panic!` e a quando devemos ou não usá-lo para lidar com
condições de erro na seção [“Para `panic!` ou não para
`panic!`”][to-panic-or-not-to-panic]<!-- ignore --> mais adiante neste
capítulo. A seguir, veremos como se recuperar de um erro usando `Result`.

[to-panic-or-not-to-panic]: ch09-03-to-panic-or-not-to-panic.html
