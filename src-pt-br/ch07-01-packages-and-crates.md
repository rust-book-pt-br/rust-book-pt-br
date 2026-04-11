## Pacotes e Crates

As primeiras partes do sistema de módulos que abordaremos são os pacotes e os crates.

Uma _crate_ é a menor quantidade de código que o compilador Rust considera em um
tempo. Mesmo se você executar `rustc` em vez de `cargo` e passar um único código-fonte
arquivo (como fizemos em [“Noções básicas do programa Rust”][basics]<!-- ignore
--> no Capítulo 1), o compilador considera esse arquivo como um crate. Crates podem
contêm módulos, e os módulos podem ser definidos em outros arquivos que são obtidos
compilado com o crate, como veremos nas próximas seções.

Um crate pode vir em uma de duas formas: um crate binário ou uma biblioteca crate.
_Crates binários_ são programas que você pode compilar em um executável que pode ser executado,
como um programa de linha de comando ou um servidor. Cada um deve ter uma função chamada
`main` que define o que acontece quando o executável é executado. Todos os crates que temos
criados até agora foram binários crates.

_Crates de biblioteca_ não têm uma função `main` e não compilam para um
executável. Em vez disso, eles definem funcionalidades destinadas a serem compartilhadas com
vários projetos. Por exemplo, o `rand` crate que usamos no [Capítulo
2][rand]<!-- ignore --> fornece funcionalidade que gera números aleatórios.
Na maioria das vezes, quando os Rustáceos dizem “crate”, eles se referem à biblioteca crate, e
use “crate” de forma intercambiável com o conceito geral de programação de uma “biblioteca”.

O _crate root_ é um arquivo fonte a partir do qual o compilador Rust inicia e faz
instale o módulo raiz do seu crate (explicaremos os módulos em detalhes em [“Controle
Escopo e privacidade com módulos”][modules]<!-- ignore -->).

Um _pacote_ é um pacote de um ou mais crates que fornece um conjunto de
funcionalidade. Um pacote contém um arquivo _Cargo.toml_ que descreve como
construa aqueles crates. Cargo é na verdade um pacote que contém o binário crate
para a ferramenta de linha de comando que você está usando para construir seu código. O Cargo
O pacote também contém uma biblioteca crate da qual o binário crate depende. Outro
projetos podem depender da biblioteca Cargo crate para usar a mesma lógica do Cargo
ferramenta de linha de comando usa.

Um pacote pode conter quantos binários crates você desejar, mas no máximo apenas um
biblioteca crate. Um pacote deve conter pelo menos um crate, seja ele um
biblioteca ou binário crate.

Vejamos o que acontece quando criamos um pacote. Primeiro, entramos no
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

Depois de executarmos `cargo new my-project`, usamos ` ls`para ver o que Cargo cria. Em
no diretório _my-project_, há um arquivo _Cargo.toml_, que nos fornece um pacote.
Há também um diretório _src_ que contém _main.rs_. Abra _Cargo.toml_ em
seu editor de texto e observe que não há menção a _src/main.rs_. Cargo
segue uma convenção de que _src/main.rs_ é a raiz crate de um crate binário
com o mesmo nome do pacote. Da mesma forma, Cargo sabe que se o pacote
diretório contém _src/lib.rs_, o pacote contém uma biblioteca crate com o
mesmo nome do pacote e _src/lib.rs_ é sua raiz crate. Cargo passa o
Arquivos raiz crate para ` rustc`para construir a biblioteca ou binário.

Aqui, temos um pacote que contém apenas _src/main.rs_, ou seja, apenas
contém um crate binário denominado `my-project`. Se um pacote contém _src/main.rs_
e _src/lib.rs_, possui dois crates: um binário e uma biblioteca, ambos com o mesmo
nome como o pacote. Um pacote pode ter vários binários crates colocando arquivos
no diretório _src/bin_: Cada arquivo será um crate binário separado.

[basics]: ch01-02-hello-world.html#rust-program-basics
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generating-a-random-number
