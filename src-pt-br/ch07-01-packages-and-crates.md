## Pacotes e Crates

As primeiras partes do sistema de módulos que vamos abordar são pacotes e
crates.

Um _crate_ é a menor unidade de código que o compilador Rust considera em um
processo de compilação. Mesmo que você execute `rustc` diretamente em vez de
usar `cargo`, passando um único arquivo-fonte, como fizemos em [“Noções
Básicas de um Programa Rust”][basics]<!-- ignore --> no Capítulo 1, o
compilador trata esse arquivo como um crate. Crates podem conter módulos, e os
módulos podem ser definidos em outros arquivos que são compilados junto com o
crate, como veremos nas próximas seções.

Um crate pode ser de um de dois tipos: crate binário ou crate de biblioteca.
_Crates binários_ são programas que podem ser compilados para um executável, por
exemplo um programa de linha de comando ou um servidor. Cada crate binário
precisa ter uma função chamada `main`, que define o que acontece quando o
executável é executado. Todos os crates que criamos até agora eram crates
binários.

_Crates de biblioteca_ não têm função `main` e não são compilados em um
executável. Em vez disso, eles definem funcionalidades destinadas a ser
compartilhadas com outros projetos. Por exemplo, o crate `rand`, que usamos no
[Capítulo 2][rand]<!-- ignore -->, fornece funcionalidades para gerar números
aleatórios. Na maior parte do tempo, quando rustaceanos dizem “crate”, eles
estão falando de um crate de biblioteca e usam “crate” quase como sinônimo da
ideia geral de “biblioteca”.

O _crate root_ é o arquivo-fonte a partir do qual o compilador Rust começa a
análise e monta a árvore de módulos do crate. Vamos explorar módulos com mais
profundidade em [“Definindo Módulos para Controlar Escopo e
Privacidade”][modules]<!-- ignore -->.

Um _pacote_ é um conjunto de um ou mais crates que oferece um grupo de
funcionalidades. Um pacote contém um arquivo _Cargo.toml_ que descreve como
compilar esses crates. O próprio Cargo é, na verdade, um pacote que contém o
crate binário da ferramenta de linha de comando que você usa para construir seu
código. O pacote do Cargo também contém um crate de biblioteca do qual esse
crate binário depende. Outros projetos podem depender desse crate de biblioteca
do Cargo para reutilizar a mesma lógica que a ferramenta de linha de comando
usa.

Um pacote pode conter quantos crates binários você quiser, mas no máximo um
crate de biblioteca. E todo pacote precisa conter pelo menos um crate, seja
ele binário, seja de biblioteca.

Vamos ver o que acontece quando criamos um pacote. Primeiro, executamos o
comando `cargo new my-project`:

```console
$ cargo new my-project
     Created binary (application) `my-project` package
$ ls my-project
Cargo.toml
src
$ ls my-project/src
main.rs
```

Depois de executar `cargo new my-project`, usamos `ls` para ver o que o Cargo
criou. No diretório _my-project_, há um arquivo _Cargo.toml_, que define o
pacote. Também há um diretório _src_ contendo _main.rs_. Se você abrir
_Cargo.toml_ no editor, verá que ele não menciona explicitamente
_src/main.rs_. O Cargo segue uma convenção: _src/main.rs_ é o _crate root_ de
um crate binário com o mesmo nome do pacote. Da mesma forma, se o pacote
contiver _src/lib.rs_, o Cargo entende que ele também possui um crate de
biblioteca com o mesmo nome do pacote, e que _src/lib.rs_ é o _crate root_
desse crate. O Cargo passa esses arquivos raiz para o `rustc`, que então
compila a biblioteca ou o binário.

Aqui, temos um pacote que contém apenas _src/main.rs_, o que significa que ele
contém apenas um crate binário chamado `my-project`. Se um pacote contiver
tanto _src/main.rs_ quanto _src/lib.rs_, ele terá dois crates: um binário e um
de biblioteca, ambos com o mesmo nome do pacote. Um pacote também pode ter
vários crates binários colocando arquivos no diretório _src/bin_: cada arquivo
nesse diretório será um crate binário separado.

[basics]: ch01-02-hello-world.html#rust-program-basics
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generating-a-random-number
