## Pacotes e caixas

As primeiras partes do sistema de módulos que abordaremos são pacotes e engradados.

Uma _crate_ é a menor quantidade de código que o compilador Rust considera em um
tempo. Mesmo se você executar `rustc` em vez de `cargo` e passar um único código-fonte
arquivo (como fizemos em [“Rust Program Basics”][basics]<!-- ignore
-> no Capítulo 1), o compilador considera esse arquivo como uma caixa. As caixas podem
contêm módulos, e os módulos podem ser definidos em outros arquivos que são obtidos
compilado com a caixa, como veremos nas próximas seções.

Uma caixa pode vir em uma de duas formas: uma caixa binária ou uma caixa de biblioteca.
_Caixas binárias_ são programas que você pode compilar em um executável que pode ser executado,
como um programa de linha de comando ou um servidor. Cada um deve ter uma função chamada
`main` que define o que acontece quando o executável é executado. Todas as caixas que temos
criados até agora foram caixas binárias.

_Caixas de biblioteca_ não têm uma função `main` e não compilam para um
executável. Em vez disso, eles definem funcionalidades destinadas a serem compartilhadas com
vários projetos. Por exemplo, a caixa `rand` que usamos no [Capítulo
2][rand]<!-- ignore --> fornece funcionalidade que gera números aleatórios.
Na maioria das vezes, quando os Rustáceos dizem “caixa”, eles querem dizer caixa de biblioteca, e eles
use “caixa” de forma intercambiável com o conceito geral de programação de uma “biblioteca”.

O _crate root_ é um arquivo fonte a partir do qual o compilador Rust inicia e faz
crie o módulo raiz da sua caixa (explicaremos os módulos em profundidade em [“Controle
Escopo e privacidade com módulos”][modules]<!-- ignore -->).

Um _pacote_ é um pacote de uma ou mais caixas que fornece um conjunto de
funcionalidade. Um pacote contém um arquivo _Cargo.toml_ que descreve como
construir essas caixas. Cargo é na verdade um pacote que contém a caixa binária
para a ferramenta de linha de comando que você está usando para construir seu código. A Carga
O pacote também contém uma caixa de biblioteca da qual a caixa binária depende. Outro
projetos podem depender da caixa da biblioteca Cargo para usar a mesma lógica que o Cargo
ferramenta de linha de comando usa.

Um pacote pode conter quantas caixas binárias você desejar, mas no máximo apenas uma.
caixote da biblioteca. Um pacote deve conter pelo menos uma caixa, seja ela uma
biblioteca ou caixa binária.

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

Depois de executarmos `cargo new my-project`, usamos `ls` para ver o que Cargo cria. Em
no diretório _my-project_, há um arquivo _Cargo.toml_, que nos fornece um pacote.
Há também um diretório _src_ que contém _main.rs_. Abra _Cargo.toml_ em
seu editor de texto e observe que não há menção a _src/main.rs_. Carga
segue uma convenção de que _src/main.rs_ é a raiz da caixa de uma caixa binária
com o mesmo nome do pacote. Da mesma forma, Cargo sabe que se o pacote
diretório contém _src/lib.rs_, o pacote contém uma caixa de biblioteca com o
mesmo nome do pacote e _src/lib.rs_ é a raiz da caixa. A carga passa
crie arquivos raiz para `rustc` para construir a biblioteca ou binário.

Aqui, temos um pacote que contém apenas _src/main.rs_, ou seja, apenas
contém uma caixa binária chamada `my-project`. Se um pacote contém _src/main.rs_
e _src/lib.rs_, possui duas caixas: uma binária e uma biblioteca, ambas com o mesmo
nome como o pacote. Um pacote pode ter múltiplas caixas binárias colocando arquivos
no diretório _src/bin_: Cada arquivo será uma caixa binária separada.

[basics]: ch01-02-hello-world.html#rust-program-basics
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generating-a-random-number
