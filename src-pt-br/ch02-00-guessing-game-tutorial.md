# Jogo de Adivinhação

Vamos entrar de cabeça no Rust e colocar a mão na massa! Este capítulo vai lhe
apresentar alguns conceitos bem comuns no Rust, mostrando como usá-los em um
programa de verdade. Você vai aprender sobre `let`, `match`, métodos, funções
associadas, crates externas, e mais! Os capítulos seguintes vão explorar essas
ideias em mais detalhes. Neste capítulo, você vai praticar o básico.

Vamos implementar um clássico problema de programação para iniciantes: um jogo
de adivinhação. Eis como ele funciona: o programa vai gerar um número inteiro
aleatório entre 1 e 100. Então, ele vai pedir ao jogador que digite um palpite.
Após darmos nosso palpite, ele vai nos indicar se o palpite é muito baixo ou
muito alto. Uma vez que o palpite estiver correto, ele vai nos dar os parabéns e
sair.

## Preparando um Novo Projeto

Para iniciar um novo projeto, vá ao seu diretório de projetos que você criou no
Capítulo 1, e execute os comandos do Cargo a seguir:

```text
$ cargo new jogo_de_adivinhacao
$ cd jogo_de_adivinhacao
```

O primeiro comando, `cargo new`, recebe o nome do projeto (`jogo_de_adivinhacao`)
como primeiro argumento. O segundo comando muda a pasta atual para o diretório do projeto.

Confira o arquivo *Cargo.toml* gerado:

<span class="filename">Arquivo: Cargo.toml</span>

```toml
[package]
name = "jogo_de_adivinhacao"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
```

Assim como no Capítulo 1, `cargo new` gera um programa "Hello, world!" para nós.
Confira em *src/main.rs*:

<span class="filename">Arquivo: src/main.rs</span>

```rust
fn main() {
    println!("Hello, world!");
}
```

Agora vamos compilar esse programa "Hello, world!" e executá-lo de uma vez só
usando o comando `cargo run`:

```text
$ cargo run
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
    Finished dev [unoptimized + debuginfo] target(s) in 1.50 secs
     Running `target/debug/jogo_de_adivinhacao`
Hello, world!
```

O comando `run` é uma boa opção quando precisamos iterar rapidamente em um
projeto, que é o caso neste jogo: nós queremos testar rapidamente cada iteração
antes de movermos para a próxima.

Abra novamente o arquivo *src/main.rs*. Escreveremos todo nosso código nele.

## Processando um Palpite

A primeira parte do programa vai pedir uma entrada ao usuário, processar essa
entrada e conferir se ela está no formato esperado. Para começar, vamos permitir
que o jogador entre com um palpite. Coloque este código no arquivo
*src/main.rs*:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore
use std::io;

fn main() {
    println!("Adivinhe o número!");

    println!("Digite o seu palpite.");

    let mut palpite = String::new();

    io::stdin()
        .read_line(&mut palpite)
        .expect("Falha ao ler entrada");

    println!("Você disse: {palpite}");
}
```

<span class="caption">Listagem 2-1: Código para ler um palpite do usuário e
imprimí-lo na tela.</span>

Esse código tem muita informação, então vamos ver uma parte de cada vez. Para obter a
entrada do usuário e então imprimir o resultado como saída, precisaremos trazer
ao escopo a biblioteca `io` (de entrada/saída). A biblioteca `io` provém da
biblioteca padrão (chamada de `std`):

```rust,ignore
use std::io;
```

Por padrão, o Rust tem um conjunto de itens definidos na biblioteca padrão 
que são trazidos para o escopo de cada programa. Este conjunto é chamado 
de *prelúdio*, e você pode ver tudo que está incluído na 
[documentação da biblioteca padrão][prelude].

[prelude]: https://doc.rust-lang.org/std/prelude/index.html

Se um tipo que você quiser usar não
estiver no prelúdio, você terá que importá-lo explicitamente através do `use`.
A biblioteca `std::io` oferece várias ferramentas de entrada/saída, incluindo a
funcionalidade de ler dados de entrada do usuário.

Como visto no Capítulo 1, a função `main` é o ponto de entrada do programa:

```rust,ignore
fn main() {
```

A sintaxe `fn` declara uma nova função, o `()` indica que não há parâmetros, e
o `{` inicia o corpo da função.

Como você também já aprendeu no Capítulo 1, `println!` é uma macro que imprime
uma string na tela:

```rust,ignore
println!("Adivinhe o número!");

println!("Digite o seu palpite.");
```

Esse código exibe uma mensagem dizendo do que se trata o jogo e solicita
uma entrada do usuário.

### Armazenando Valores em Variáveis

Próximo passo, vamos criar uma variável para armazenar a entrada do usuário:

```rust,ignore
let mut palpite = String::new();
```

Agora o programa está ficando interessante! Tem muita coisa acontecendo nesta
pequena linha. Nós usamos a declaração `let` para criar a *variável*.
Segue outro exemplo:

```rust,ignore
let maçãs = 5;
```

Essa linha cria uma nova variável chamada `maçãs` e a vincula ao valor `5`. Em Rust, variáveis são imutáveis por padrão, ou seja, uma vez vinculado o valor à variável, 
ele não pode ser alterado. Nós vamos discutir este conceito em detalhes 
na seção ["Variáveis e Mutabilidade"][variables] do Capítulo 3. Para criar uma
variável mutável, nós adicionamos `mut` antes do nome da variável: 
[variables]: ./ch03-01-variables-and-mutability.html#variables-and-mutability

```rust
let maçãs = 5; // imutável
let mut bananas = 5; // mutável
```

> Nota: A sintaxe `//` inicia um comentário, que continua até o fim da linha.
> Rust ignora tudo o que estiver nos comentários.
> Nós vamos discutir comentários em mais detalhes no [Capítulo 3][chapter3]

[chapter3]: ./ch03-04-comments.html

Agora você sabe que `let mut palpite` vai introduzir uma variável mutável de
nome `palpite`. Do outro lado do símbolo `=` está o valor ao qual `palpite` está
vinculado, que é o resultado da chamada `String::new`, uma função que retorna
uma nova instância de `String`. [`String`][string]<!-- ignore --> é um tipo
fornecido pela biblioteca padrão que representa uma cadeia expansível de
caracteres codificados em UTF-8.

[string]: https://doc.rust-lang.org/std/string/struct.String.html

A sintaxe `::` na linha `::new` indica que `new` é uma função associada do
tipo `String`. Uma *função associada* é implementada sobre um tipo, neste caso
`String`, em vez de uma instância particular de `String`. Algumas linguagens
dão a isso o nome *método estático*.

Esta função `new()` cria uma nova `String` vazia. Você encontrará uma função
`new()` em muitos tipos, já que é um nome comum para uma função que produz um
novo valor de algum tipo.

Para resumir, a linha `let mut palpite = String::new();` criou uma variável
mutável que está atualmente vinculada a uma nova instância vazia de uma
`String`. Ufa!

### Recebendo dados do usuário

Lembre-se de que incluímos a funcionalidade de entrada/saída da biblioteca
padrão por meio do `use std::io;` na primeira linha do programa. Agora vamos
chamar uma função associada, `stdin`, em `io`:

```rust,ignore
    io::stdin()
        .read_line(&mut palpite)
        .expect("Falha ao ler entrada");
```

Se não tivéssemos a linha `use std::io` no início do programa, poderíamos ter
escrito esta chamada como `std::io::stdin`. A função `stdin` retorna uma
instância de [`std::io::Stdin`][iostdin]<!-- ignore -->, um tipo que representa
um manipulador (_handle_) da entrada padrão do seu terminal.

[iostdin]: https://doc.rust-lang.org/std/io/struct.Stdin.html

A próxima parte do código, `.read_line(&mut palpite)`, chama o método
[`read_line`][read_line]<!-- ignore --> do _handle_ da entrada padrão para obter
entrada do usuário. Também estamos passando um argumento para `read_line`:
`&mut palpite`.

[read_line]: https://doc.rust-lang.org/std/io/struct.Stdin.html#method.read_line

O trabalho da função `read_line` é receber o que o usuário digita na entrada
padrão e colocar isso numa string, por isso ela recebe essa string como
argumento. A string do argumento deve ser mutável para que o método consiga
alterar o seu conteúdo, adicionando a entrada do usuário.

O símbolo `&` indica que o argumento é uma *referência*, o que permite múltiplas
partes do seu código acessar um certo dado sem precisar criar várias cópias dele
na memória. Referências são uma característica complexa, e uma das maiores
vantagens do Rust é o quão fácil e seguro é usar referências. Você não precisa
conhecer muitos desses detalhes para finalizar esse programa. O Capítulo 4 vai
explicar sobre referências de forma mais aprofundada. Por enquanto, tudo que
você precisa saber é que, assim como as variáveis, referências são imutáveis por
padrão. Por isso, precisamos escrever `&mut palpite`, em vez de apenas
`&palpite`, para fazer com que o palpite seja mutável.

### Tratando Potenciais Falhas com o Tipo `Result`

Ainda não finalizamos completamente esta linha de código. Embora esta seja uma
única linha de texto, é apenas a primeira parte de uma linha lógica de código. A
segunda parte é a chamada para este método:

```rust,ignore
  .expect("Falha ao ler entrada");
```

Quando você chama um método com a sintaxe `.foo()`, geralmente é bom introduzir
uma nova linha e outro espaço para ajudar a dividir linhas muito compridas.
Poderíamos ter feito assim:

```rust,ignore
io::stdin().read_line(&mut palpite).expect("Falha ao ler entrada");
```

Porém, uma linha muito comprida fica difícil de ler. Então é melhor dividirmos a
linha em duas, uma para cada método chamado. Agora vamos falar sobre o que essa
linha faz.

Como mencionado anteriormente, `read_line` coloca o que o usuário escreve dentro
da string que passamos como argumento, mas também retorna um valor do tipo `Result`.
Os tipos [`Result`][result] são [*enumerações*][enums]<!-- ignore -->, comumente chamadas
de *enums*. Uma enumeração é um tipo que pode ter um conjunto fixo de valores,
os quais são chamados de *variantes* da enum.

O [Capítulo 6][enums] vai abordar enums em mais detalhes. O propósito desses tipos `Result` é codificar informações de manipulação de erros.

[result]: https://doc.rust-lang.org/std/result/enum.Result.html
[enums]: ch06-00-enums.html


As variantes de `Result` são `Ok` ou `Err`. `Ok` indica que a operação teve
sucesso, e dentro da variante `Ok` está o valor resultante. `Err` significa que
a operação falhou, e contém informações sobre como ou por que isso ocorreu.

Valores do tipo `Result`, assim como qualquer tipo, possuem métodos
definidos. Uma instância de `Result` tem um [método `expect`][expect]<!-- ignore -->
que você pode chamar. Se esta instância de `Result` é um `Err`, `expect` vai
terminar o programa com erro e mostrar a mensagem que você passou como argumento
ao `expect`. Se o método `read_line` retornar um `Err`, provavelmente será o
resultado de um erro vindo do sistema operacional que está por trás. Se esta
instância de `Result` é um `Ok`, `expect` vai obter o valor contido no `Ok`
e retorná-lo para que você possa usá-lo. Neste caso, o valor é o número de bytes
dos dados que o usuário inseriu através da entrada padrão.

[expect]: https://doc.rust-lang.org/std/result/enum.Result.html#method.expect

Se não chamarmos `expect`, nosso programa vai compilar, mas vamos ter um aviso:

```text
$ cargo build
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
warning: unused `Result` that must be used
  --> src/main.rs:10:5
   |
10 |     io::stdin().read_line(&mut palpite);
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: this `Result` may be an `Err` variant, which should be handled
   = note: `#[warn(unused_must_use)]` on by default

warning: `jogo_de_adivinhacao` (bin "jogo_de_adivinhacao") generated 1 warning
    Finished dev [unoptimized + debuginfo] target(s) in 0.59s
```

Rust avisa que não usamos o valor `Result`, retornado por `read_line`, indicando
que o programa deixou de tratar um possível erro. A maneira correta de suprimir
o aviso é realmente escrevendo um tratador de erro, mas como queremos que o
programa seja encerrado caso ocorra um problema, podemos usar `expect`. Você
aprenderá sobre recuperação de erros no [Capítulo 9][chap9].

[chap9]: ./ch09-00-error-handling.md

### Exibindo Valores com `println!` e placeholders

Tirando a chave que delimita a função `main`, há apenas uma linha mais a ser
discutida no código que fizemos até agora, que é a seguinte:

```rust,ignore
println!("Você disse: {palpite}");
```
Essa linha imprime a string na qual salvamos os dados inseridos pelo usuário. O `{}` é um placeholder que reserva o lugar de um valor. Para imprimir o valor de uma variável, podemos colocá-la diretamente dentro das chaves na string. Também podemos imprimir o resultado de uma ou mais expressões colocando chaves vazias na string de formatação e adicionando, depois dela, uma lista de expressões separadas por vírgulas, na mesma ordem. Por exemplo, podemos imprimir uma variável e o resultado de uma expressão em uma única chamada de `println!` desta forma:

```rust
let x = 5;
let y = 10;

println!("x = {x} and y + 2 = {}", y + 2);
```

Esse código imprime `x = 5 and y + 2 = 12`.

### Testando a Primeira Parte

Vamos testar a primeira parte do jogo de adivinhação. Você pode executá-lo usando
`cargo run`:

```text
$ cargo run
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
    Finished dev [unoptimized + debuginfo] target(s) in 6.44s
     Running `target/debug/jogo_de_adivinhacao`
Adivinhe o número!
Digite o seu palpite.
6
Você disse: 6
```

Nesse ponto, a primeira parte do jogo está feita: podemos coletar entrada do
teclado e mostrá-la na tela.

## Gerando um Número Secreto

A seguir, precisamos gerar um número secreto que o usuário vai tentar adivinhar.
O número secreto deve ser diferente a cada execução, para que o jogo tenha graça
em ser jogado mais de uma vez. Vamos usar um número aleatório entre 1 e 100,
para que o jogo não seja tão difícil. Rust ainda não inclui uma funcionalidade
de geração de números aleatórios em sua biblioteca padrão. Porém, a equipe Rust
fornece um [crate `rand`][randcrate].

[randcrate]: https://crates.io/crates/rand

### Usando um Crate para Ter Mais Funcionalidades

Lembre-se de que um *crate* é um pacote de código Rust. O projeto que estamos
construindo é um *crate binário*, que é um executável. Já o `rand` é um
*crate de biblioteca*, que contém código cujo objetivo é ser usado por outros
programas.

É no uso de crates externas que Cargo realmente brilha. Antes que possamos
escrever o código usando `rand`, precisamos modificar o arquivo *Cargo.toml*
para incluir o crate `rand` como uma dependência. Abra o arquivo e adicione
esta linha no final, abaixo do cabeçalho da seção `[dependencies]` que o Cargo
criou para você:

<span class="filename">Arquivo: Cargo.toml</span>

```toml
[dependencies]

rand = "0.8.5"
```

No arquivo *Cargo.toml*, tudo que vem depois de um cabeçalho é parte de uma
seção que segue até o início de outra. A seção `[dependencies]` é onde você diz
ao Cargo de quais crates externos o seu projeto depende, e quais versões desses
crates você exige. Neste caso, especificamos o crate `rand` com a versão
semântica `0.8.5`. Cargo compreende [Versionamento Semântico][semver]<!-- ignore -->
(às vezes chamado *SemVer*), um padrão para escrever números de versões. O
número `0.8.5` é, na verdade, uma forma curta de escrever `^0.8.5`, que
significa "qualquer versão que tenha uma API pública compatível com a versão 0.8.5".

[semver]: https://semver.org/lang/pt-BR/

Agora, sem mudar código algum, vamos compilar nosso projeto, conforme mostrado
na Listagem 2-2:

```text
$ cargo build
    Updating crates.io index
  Downloaded rand v0.8.5
  Downloaded libc v0.2.127
  Downloaded getrandom v0.2.7
  Downloaded cfg-if v1.0.0
  Downloaded ppv-lite86 v0.2.16
  Downloaded rand_chacha v0.3.1
  Downloaded rand_core v0.6.3
   Compiling libc v0.2.127
   Compiling getrandom v0.2.7
   Compiling cfg-if v1.0.0
   Compiling ppv-lite86 v0.2.16
   Compiling rand_core v0.6.3
   Compiling rand_chacha v0.3.1
   Compiling rand v0.8.5
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
    Finished dev [unoptimized + debuginfo] target(s) in 2.53s
```

<span class="caption">Listagem 2-2: Resultado da execução de `cargo build`
depois de adicionar o crate `rand` como dependência.</span>

Talvez para você apareçam versões diferentes, mas todas elas serão compatíveis com
o código, graças ao Versionamento Semântico, e as linhas talvez apareçam em
ordem diferente.

Agora que temos uma dependência externa, o Cargo busca as versões mais recentes de
tudo no *registro*, que é uma cópia dos dados do [Crates.io][cratesio].
Crates.io é onde as pessoas do ecossistema Rust postam seus projetos
_open source_ para que os outros possam usar.

[cratesio]: https://crates.io

Após atualizar o registro, o Cargo verifica a seção `[dependencies]` e baixa todas
as que você não tem ainda. Neste caso, embora tenhamos listado apenas `rand`
como dependência, o Cargo também baixa outras crates que `rand` depende para funcionar. Depois de baixá-las, o Cargo as compila e
então compila nosso projeto.

Se, logo em seguida, você executar `cargo build` novamente sem fazer mudanças,
não vai aparecer nenhuma mensagem de saída. O Cargo sabe que já baixou e
compilou as dependências, e você não alterou mais nada sobre elas no seu arquivo
*Cargo.toml*. Cargo também sabe que você não mudou mais nada no seu código, e
por isso não o recompila. Sem nada a fazer, ele simplesmente sai. Se você abrir
*src/main.rs*, fizer uma modificação trivial, salvar e compilar de novo, vai
aparecer uma mensagem de apenas duas linhas:

```text
$ cargo build
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
    Finished dev [unoptimized + debuginfo] target(s) in 2.53 secs
```

Essas linhas mostram que o Cargo só atualiza o _build_ com a sua pequena mudança
no arquivo *src/main.rs*. Suas dependências não mudaram, então o Cargo sabe que
pode reutilizar o que já tiver sido baixado e compilado para elas. Ele apenas
recompila a sua parte do código.

#### Garantindo _Builds_ reproduzíveis com o arquivo *Cargo.lock*

O Cargo tem um mecanismo que assegura que você pode reconstruir o mesmo artefato
toda vez que você ou outra pessoa compilar o seu código. O Cargo vai usar apenas
as versões das dependências que você especificou, até que você indique o
contrário. Por exemplo, o que acontece se, na semana que vem, sair a versão
`v0.8.6` contendo uma correção de bug, mas também uma regressão que não
funciona com o seu código?

A resposta para isso está no arquivo *Cargo.lock*, que foi criado na primeira
vez que você executou `cargo build`, e agora está no seu diretório
*jogo_de_adivinhacao*. Quando você compila o seu projeto pela primeira vez, o
Cargo descobre as versões de todas as dependências que preenchem os critérios
e então as escreve no arquivo *Cargo.lock*. Quando você compilar o seu projeto
futuramente, o Cargo verá que o arquivo *Cargo.lock* existe e usará as versões
especificadas no mesmo, em vez de refazer todo o trabalho de descobrir as versões
novamente. Isto lhe permite ter um _build_ reproduzível automaticamente. Em
outras palavras, seu projeto vai continuar com a versão `0.8.5` até que você
faça uma atualização explícita, graças ao arquivo *Cargo.lock*.

#### Atualizando um Crate para Obter uma Nova Versão

Quando você *quiser* atualizar um crate, o Cargo tem outro comando, `update`,
que faz o seguinte:

1. Ignora o arquivo *Cargo.lock* e descobre todas as versões mais recentes que
   atendem às suas especificações no *Cargo.toml*.
1. Se funcionar, o Cargo escreve essas versões no arquivo *Cargo.lock*.

Mas, por padrão, o Cargo vai procurar as versões maiores que `0.8.0` e menores
que `0.9.0`. Se o crate `rand` já tiver lançado duas novas versões, `0.8.6` e
`0.9.0`, você verá a seguinte mensagem ao executar `cargo update`:

```text
$ cargo update
    Updating registry `https://github.com/rust-lang/crates.io-index`
    Updating rand v0.8.5 -> v0.8.6
```

Nesse ponto, você vai notar também uma mudança no seu arquivo *Cargo.lock*
dizendo que a versão do crate `rand` que você está usando agora é a `0.8.6`. 

Se você quisesse usar a versão `0.9.0`, ou qualquer versão da série `0.9.x` do
`rand`, você teria que atualizar o seu *Cargo.toml* dessa forma:

```toml
[dependencies]

rand = "0.9.0"
```

Na próxima vez que você executar `cargo build`, o Cargo vai atualizar o registro
de crates disponíveis e reavaliar os seus requisitos sobre o `rand` de acordo
com a nova versão que você especificou.

Há muito mais a ser dito sobre [Cargo][doccargo]<!-- ignore --> e o [seu
ecossistema][doccratesio]<!-- ignore --> que vai ser discutido no Capítulo 14,
mas por ora isto é tudo que você precisa saber. Cargo facilita muito reutilizar
bibliotecas, de forma que os _rustáceos_ consigam escrever projetos menores que
são montados a partir de diversos pacotes.

[doccargo]: http://doc.crates.io
[doccratesio]: http://doc.crates.io/crates-io.html

### Gerando um Número Aleatório

Agora vamos *usar*, de fato, o `rand`. O próximo passo é atualizar o
*src/main.rs* conforme mostrado na Listagem 2-3:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore

use std::io;
use rand::Rng;

fn main() {
    println!("Adivinhe o número!");

    let numero_secreto = rand::thread_rng().gen_range(1..=100);

    println!("O número secreto é: {numero_secreto}");

    println!("Digite o seu palpite.");

    let mut palpite = String::new();

    io::stdin()
        .read_line(&mut palpite)
        .expect("Falha ao ler entrada");

    println!("Você disse: {palpite}");
}
```

<span class="caption">Listagem 2-3: Mudanças necessárias do código para gerar um
número aleatório.</span>

Primeiramente adicionamos a linha `use rand::Rng`. `Rng` é um trait
que define métodos a serem implementados pelos geradores de números aleatórios,
e esse trait deve estar dentro do escopo para que possamos usar esses métodos. O
Capítulo 10 vai abordar traits em mais detalhes.

Há outras duas linhas que adicionamos no meio. A função `rand::thread_rng` nos
dá o gerador de números aleatórios que vamos usar, um que é local à _thread_
corrente e que é inicializado pelo sistema operacional. Depois, vamos chamar o
método `gen_range` no gerador de números aleatórios. Esse método está definido
pelo trait `Rng` que trouxemos ao escopo por meio do `use rand::Rng`. Esse
método recebe uma expressão de intervalo como argumento e gera um número aleatório nesse intervalo. O tipo de argumento que estamos usando aqui tem a forma `start..=end`, que inclui os limites inferior e superior. Logo,
precisamos especificar `1..=100` para obter um número de 1 a 100.

> Nota: Saber quais traits devem ser usadas e quais funções e métodos de um crate
>devem ser chamados não é nada trivial. As instruções de como usar um crate
>estão na documentação de cada um. Outra coisa boa do Cargo é que você pode rodar
>o comando `cargo doc --open`, que vai construir localmente a documentação
>fornecida por todas as suas dependências e abri-la no seu navegador. Se você
>estiver interessado em outras funcionalidades do crate `rand`, por exemplo,
>execute `cargo doc --open` e clique em `rand`, no menu ao lado esquerdo.

A segunda linha que adicionamos imprime o número secreto. Isto é útil enquanto
estamos desenvolvendo o programa para podermos testá-lo, mas vamos retirá-la da
versão final. Um jogo não é muito interessante se ele mostra a resposta logo no
início!

Tente rodar o programa algumas vezes:

```text
$ cargo run
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
    Finished dev [unoptimized + debuginfo] target(s) in 2.53 secs
     Running `target/debug/jogo_de_adivinhacao`
Adivinhe o número!
O número secreto é: 7
Digite o seu palpite.
4
Você disse: 4
$ cargo run
     Running `target/debug/jogo_de_adivinhacao`
Adivinhe o número!
O número secreto é: 83
Digite o seu palpite.
5
Você disse: 5
```

Você já deve obter números aleatórios diferentes, e eles devem ser todos entre 1
e 100. Bom trabalho!

## Comparando o Palpite com o Número Secreto

Agora que temos a entrada do usuário e o número secreto, vamos compará-los.
Esta etapa é mostrada na Listagem 2-4. Observe que este código ainda não compila, como vamos explicar a seguir!

<span class="filename">Arquivo: src/main.rs</span>

<pre>
<img src="./img/ferris/does_not_compile.svg" alt= “” width="10%" height="10%" align="right">
</pre>

```rust,ignore

use std::io;
use std::cmp::Ordering;
use rand::Rng;

#fn main() {
#    println!("Adivinhe o número!");
#
#    let numero_secreto = rand::thread_rng().gen_range(1..=100);
#
#    println!("O número secreto é: {numero_secreto}");
#
#    println!("Digite o seu palpite.");
#
#    let mut palpite = String::new();
#
#    io::stdin().read_line(&mut palpite)
#        .expect("Falha ao ler entrada");
#
    // --snip--

    println!("Você disse: {palpite}");

    match palpite.cmp(&numero_secreto) {
        Ordering::Less => println!("Muito baixo!"),
        Ordering::Greater => println!("Muito alto!"),
        Ordering::Equal => println!("Você acertou!"),
    }
}
```

<span class="caption">Listagem 2-4: Tratando os possíveis resultados da
comparação de dois números.</span>

A primeira novidade aqui é outro `use`, que traz ao escopo um tipo da biblioteca
padrão chamado `std::cmp::Ordering`. `Ordering` é outra enum, igual a `Result`,
mas as suas variantes são `Less`, `Greater` e `Equal` (elas significam menor,
maior e igual, respectivamente). Estes são os três possíveis resultados quando
você compara dois valores.

Depois, adicionamos cinco novas linhas no final que usam o tipo `Ordering`:

```rust,ignore

match palpite.cmp(&numero_secreto) {
    Ordering::Less => println!("Muito baixo!"),
    Ordering::Greater => println!("Muito alto!"),
    Ordering::Equal => println!("Você acertou!"),
}
```

O método `cmp` compara dois valores, e pode ser chamado a partir de qualquer
coisa que possa ser comparada. Ele recebe uma referência de qualquer coisa que
você queira comparar. Neste caso, está comparando o `palpite` com o
`numero_secreto`. `cmp` retorna uma variante do tipo `Ordering`, que trouxemos
ao escopo com `use`. Nós usamos uma expressão [`match`][match]<!-- ignore -->
para decidir o que fazer em seguida, com base em qual variante de `Ordering` foi
retornada pelo método `cmp`, que foi chamado com os valores `palpite` e
`numero_secreto`.

[match]: ch06-02-match.html

Uma expressão `match` é composta de *braços*. Um braço consiste em um *padrão*
mais o código que deve ser executado se o valor colocado no início do `match` se
encaixar no padrão deste braço. O Rust pega o valor passado ao `match` e o
compara com o padrão de cada braço na sequência. A expressão `match` e os
padrões são ferramentas poderosas do Rust que lhe permitem expressar uma
variedade de situações que seu código pode encontrar, e ajuda a assegurar que
você tenha tratado todas elas. Essas ferramentas serão abordadas em detalhes nos
capítulos 6 e 18, respectivamente.

Vamos acompanhar um exemplo do que aconteceria na expressão `match` usada aqui.
Digamos que o usuário tenha colocado 50 como palpite, e o número secreto
aleatório desta vez é 38. Quando o código compara 50 com 38, o método `cmp` vai
retornar `Ordering::Greater`, porque 50 é maior que 38. `Ordering::Greater` é o
valor passado ao `match`. Ele olha para o padrão `Ordering::Less` do primeiro
braço, mas o valor `Ordering::Greater` não casa com `Ordering::Less`, então ele
ignora o código desse braço e avança para o próximo. Já o padrão do próximo
braço, `Ordering::Greater`, *casa* com `Ordering::Greater`! O código associado a
este braço vai ser executado e mostrar `Muito alto!` na tela. A expressão
`match` termina porque já não tem mais necessidade de verificar o último braço
nesse caso particular.

Porém, o código da Listagem 2-4 ainda não compila. Vamos tentar:

```text
$ cargo build
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
error[E0308]: mismatched types
  --> src/main.rs:23:21
   |
23 |     match palpite.cmp(&numero_secreto) {
   |                       ^^^^^^^^^^^^^^^ expected struct `std::string::String`, found integral variable
   |
   = note: expected type `&std::string::String`
   = note:    found type `&{integer}`

error: aborting due to previous error
Could not compile `jogo_de_adivinhacao`.
```

O que este erro está dizendo é que temos *tipos incompatíveis*. Rust tem um
sistema de tipos forte e estático. Porém, Rust também tem inferência de tipos.
Quando escrevemos `let palpite = String::new()`, Rust foi capaz de inferir que
`palpite` deveria ser uma `String`, então ele não nos faz escrever o tipo. O
`numero_secreto`, por outro lado, é de um tipo numérico. Existem alguns tipos
numéricos capazes de guardar um valor entre 1 e 100: `i32`, que é um número de
32 bits; `u32`, um número de 32 bits sem sinal; `i64`, um número de 64 bits; e
mais alguns outros. O tipo numérico padrão do Rust é `i32`, que é o tipo do
`numero_secreto`, a não ser que adicionemos, em algum lugar, uma informação de
tipo que faça o Rust inferir outro tipo numérico. A razão do erro é que o Rust
não pode comparar uma string e um tipo numérico.

Em última análise, queremos converter a `String` que lemos como entrada em um
tipo numérico de verdade, de forma que possamos compará-lo numericamente com o
palpite. Podemos fazer isso com a adição de mais uma linha no corpo da função `main`:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore

#use std::io;
#use std::cmp::Ordering;
#use rand::Rng;
#
#fn main() {
#    println!("Adivinhe o número!");
#
#    let numero_secreto = rand::thread_rng().gen_range(1..=100);
#
#    println!("O número secreto é: {numero_secreto}");
#
#    println!("Digite o seu palpite.");
    // --snip--

    let mut palpite = String::new();

    io::stdin()
        .read_line(&mut palpite)
        .expect("Falha ao ler entrada");

    let palpite: u32 = palpite.trim().parse().expect("Por favor, digite um número!");

    println!("Você disse: {palpite}");

    match palpite.cmp(&numero_secreto) {
        Ordering::Less => println!("Muito baixo!"),
        Ordering::Greater => println!("Muito alto!"),
        Ordering::Equal => println!("Você acertou!"),
    }
#}
```

A linha é:

```rust,ignore
let palpite: u32 = palpite.trim().parse().expect("Por favor, digite um número!");
```

Nós criamos uma variável chamada `palpite`. Mas espera, o programa já não tinha
uma variável chamada `palpite`? Sim, mas o Rust nos permite *sombrear* o
`palpite` anterior com um novo. Isto é geralmente usado em situações em que você
quer converter um valor de um tipo em outro. O sombreamento nos permite
reutilizar o nome `palpite`, em vez de nos forçar a criar dois nomes únicos como
`palpite_str` e `palpite`, por exemplo. (O [`Capítulo 3`][chap3-shadow] vai cobrir sombreamento em
mais detalhes).

[chap3-shadow]: ./ch03-01-variables-and-mutability.html#shadowing

Nós vinculamos `palpite` à expressão `palpite.trim().parse()`. O `palpite`, na
expressão, refere-se ao `palpite` original contendo a `String` de entrada do
usuário. O método `trim`, em uma instância de `String`, vai eliminar quaisquer
espaços em branco no início e no fim. `u32` pode conter apenas caracteres
numéricos, mas o usuário precisa pressionar <span class="keystroke">Enter</span>
para satisfazer o `read_line`. Quando o usuário pressiona
<span class="keystroke">Enter</span>, um caractere de nova linha é inserido na
string. Por exemplo, se o usuário digitar <span class="keystroke">5</span> e
depois <span class="keystroke">Enter</span>, `palpite` ficaria assim: `5\n`. O
`\n` representa uma linha nova, a tecla <span class="keystroke">Enter</span>.
O método `trim` elimina o `\n`, deixando apenas `5`.

O [método `parse` em strings][parse]<!-- ignore --> converte uma string para
algum tipo de número. Dado que ele pode interpretar uma variedade de tipos
numéricos, precisamos dizer ao Rust qual o tipo exato de número nós queremos, e
para isso usamos `let palpite: u32`. Os dois pontos (`:`) depois de `palpite`
informam ao Rust que estamos anotando seu tipo. O Rust tem alguns tipos
numéricos embutidos, o `u32` visto aqui é um inteiro de 32 bits sem sinal. É uma
boa escolha padrão para um número positivo pequeno. Você vai aprender sobre
outros tipos numéricos no [`Capítulo 3`][chap3-integer].

Além disso, a anotação `u32` neste programa de exemplo e a comparação com `numero_secreto` significa que o Rust vai inferir que `numero_secreto`
também deve ser um `u32`. Então agora a
comparação vai ser feita entre valores do mesmo tipo!



[chap3-integer]: ./ch03-02-data-types.html#integer-types
[parse]: https://doc.rust-lang.org/std/primitive.str.html#method.parse

A chamada para `parse` poderia facilmente causar um erro. Por exemplo, se a
string contiver `A👍%`, não haveria como converter isto em um número. Como ele
pode falhar, o método `parse` retorna um `Result`, assim como o método
`read_line`, conforme discutido anteriormente na seção ["Tratando Potenciais
Falhas com o Tipo `Result`"][sec-result]. Vamos tratar este `Result` da mesma forma usando o
método `expect` de novo. Se o `parse` retornar uma variante `Err` da enum
`Result`, por não conseguir criar um número a partir da string, a chamada ao
`expect` vai causar um _crash_ no jogo e exibir a mensagem que passamos a ele.
Se o `parse` conseguir converter uma string em um número, ele vai retornar a
variante `Ok` da enum `Result` e `expect` vai retornar o número que queremos
extrair do valor `Ok`.

[sec-result]: #tratando-potenciais-falhas-com-o-tipo-result

Agora vamos executar o programa!

```text
$ cargo run
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
    Finished dev [unoptimized + debuginfo] target(s) in 0.43 secs
     Running `target/jogo_de_adivinhacao`
Adivinhe o número!
O número secreto é: 58
Digite o seu palpite.
  76
Você disse: 76
Muito alto!
```

Boa! Até mesmo colocando alguns espaços antes de digitar o palpite, o programa
ainda descobriu que o palpite do usuário é 76. Execute o programa mais algumas
vezes para verificar os diferentes comportamentos com diferentes tipos de
entrada: Adivinhe o número corretamente, digite um número muito alto, e digite um
número muito baixo.

Agora já temos a maior parte do jogo funcionando, mas o usuário só consegue dar
um palpite uma vez. Vamos mudar isso adicionando laços!

## Permitindo Múltiplos Palpites Usando _Looping_

A palavra-chave `loop` nos dá um laço (_loop_) infinito. Use-a para dar aos
usuários mais chances de adivinhar o número:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore
#
#use std::io;
#use std::cmp::Ordering;
#use rand::Rng;
#
#fn main() {
#    println!("Adivinhe o número!");
#
#    let numero_secreto = rand::thread_rng().gen_range(1, 101);
#
    // --snip--

    println!("O número secreto é: {numero_secreto}");

    loop {
        println!("Digite o seu palpite.");

#        let mut palpite = String::new();
#
#        io::stdin().read_line(&mut palpite)
#            .expect("Falha ao ler entrada");
#
#        let palpite: u32 = palpite.trim().parse()
#            .expect("Por favor, digite um número!");
#
#        println!("Você disse: {palpite}");
#
        // --snip--

        match palpite.cmp(&numero_secreto) {
            Ordering::Less => println!("Muito baixo!"),
            Ordering::Greater => println!("Muito alto!"),
            Ordering::Equal => println!("Você acertou!"),
        }
    }
}
```

Como você pode ver, movemos tudo para dentro do laço a partir da mensagem
pedindo o palpite do usuário. Certifique-se de indentar essas linhas mais quatro
espaços cada uma, e execute o programa novamente. Repare que há um novo
problema, porque o programa está fazendo exatamente o que dissemos para ele
fazer: pedir sempre outro palpite! Parece que o usuário não consegue sair!

O usuário pode sempre interromper o programa usando as teclas
<span class="keystroke">ctrl-c</span>. Mas há uma outra forma de escapar deste
monstro insaciável que mencionamos na discussão do método `parse`, na seção
["Comparando o Palpite com o Número Secreto"][sec-comp]: se o usuário fornece uma resposta
não-numérica, o programa vai sofrer um _crash_. O usuário pode levar vantagem
disso para conseguir sair, como mostrado abaixo:

[sec-comp]: #comparando-o-palpite-com-o-número-secreto

```text
$ cargo run
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
     Running `target/jogo_de_adivinhacao`
Adivinhe o número!
O número secreto é: 59
Digite o seu palpite.
45
Você disse: 45
Muito baixo!
Digite o seu palpite.
60
Você disse: 60
Muito alto!
Digite o seu palpite.
59
Você disse: 59
Você acertou!
Digite o seu palpite.
sair
thread 'main' panicked at 'Por favor, digite um número!: ParseIntError { kind: InvalidDigit }', src/libcore/result.rs:785
note: Run with `RUST_BACKTRACE=1` for a backtrace.
error: Process didn't exit successfully: `target/debug/jogo_de_adivinhacao` (exit code: 101)
```

Digitar `sair`, na verdade, sai do jogo, mas isso também acontece com qualquer
outra entrada não numérica. Porém, isto não é o ideal. Queremos que o jogo
termine automaticamente quando o número é adivinhado corretamente.

### Saindo Após um Palpite Correto

Vamos programar o jogo para sair quando o usuário vencer, colocando um `break`:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore
#
#use std::io;
#use std::cmp::Ordering;
#use rand::Rng;
#
#fn main() {
#    println!("Adivinhe o número!");
#
#    let numero_secreto = rand::thread_rng().gen_range(1..=100);
#
#    println!("O número secreto é: {numero_secreto}");
#
#    loop {
#        println!("Digite o seu palpite.");
#
#        let mut palpite = String::new();
#
#        io::stdin().read_line(&mut palpite)
#            .expect("Falha ao ler entrada");
#
#        let palpite: u32 = palpite.trim().parse()
#            .expect("Por favor, digite um número!");
#
#        println!("Você disse: {palpite}");
#
        // --snip--

        match palpite.cmp(&numero_secreto) {
            Ordering::Less => println!("Muito baixo"),
            Ordering::Greater => println!("Muito alto!"),
            Ordering::Equal => {
                println!("Você acertou!");
                break;
            }
        }
    }
}
```

Adicionando a linha `break` após o `Você acertou!`, o programa vai sair do laço
quando o usuário adivinhar corretamente o número secreto. Sair do laço também
significa sair do programa, pois o laço é a última parte da `main`.

### Tratando Entradas Inválidas

Para refinar ainda mais o comportamento do jogo, em vez de causar um _crash_ no
programa quando o usuário insere uma entrada não numérica, vamos fazer o jogo
ignorá-la para que o usuário possa continuar tentando. Podemos fazer isso
alterando a linha em que o `palpite` é convertido de `String` para `u32`:


```rust,ignore
#
#use std::io;
#use std::cmp::Ordering;
#use rand::Rng;
#
#fn main() {
#    println!("Adivinhe o número!");
#
#    let numero_secreto = rand::thread_rng().gen_range(1..=100);
#
#    println!("O número secreto é: {numero_secreto}");
#
#    loop {
#        println!("Digite o seu palpite.");
#
#        let mut palpite = String::new();
#
#        io::stdin().read_line(&mut palpite)
#            .expect("Falha ao ler entrada");
#
        // --snip--

        let palpite: u32 = match palpite.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };


        println!("Você disse: {palpite}");

        // --snip--
#
#        match palpite.cmp(&numero_secreto) {
#            Ordering::Less => println!("Muito baixo"),
#            Ordering::Greater => println!("Muito alto!"),
#            Ordering::Equal => {
#                println!("Você acertou!");
#                break;
#            }
#        }
#    }
#}
```

Trocando uma chamada a `expect` por uma expressão `match` é a forma como você
geralmente deixa de causar um _crash_ em um erro e passa a tratá-lo, de fato.
Lembre-se que o método `parse` retorna um valor do tipo `Result`, uma enum que
contém a variante `Ok` ou `Err`. Estamos usando um `match` aqui, assim como
fizemos com o `Ordering` resultante do método `cmp`.

Se o `parse` consegue converter a string em um número, ele vai retornar um `Ok`
contendo o número resultante. Esse valor `Ok` vai casar com o padrão do primeiro
braço, e o `match` vai apenas retornar o valor `num` produzido pelo `parse` e
colocado dentro do `Ok`. Esse número vai acabar ficando exatamente onde
queremos, na variável `palpite` que estamos criando. 

Se o `parse` *não* conseguir converter a string em um número, ele vai retornar
um `Err` que contém mais informações sobre o erro. O valor `Err` não casa com o
padrão `Ok(num)` do primeiro braço do `match`, mas casa com o padrão `Err(_)` do
segundo braço. O `_` é um valor "pega tudo". Neste exemplo, estamos dizendo que
queremos casar todos os valores `Err`, não importa qual informação há dentro
deles. Então o programa vai executar o código do segundo braço, `continue`, que
significa ir para a próxima iteração do `loop` e pedir outro palpite.
Efetivamente, o programa ignora todos os erros que o `parse` vier a encontrar!

Agora, tudo no programa deve funcionar como esperado. Vamos tentar executá-lo
usando o comando `cargo run`:

```text
$ cargo run
   Compiling jogo_de_adivinhacao v0.1.0 (file:///projects/jogo_de_adivinhacao)
     Running `target/jogo_de_adivinhacao`
Adivinhe o número!
O número secreto é: 61
Digite o seu palpite.
10
Você disse: 10
Muito baixo!
Digite o seu palpite.
99
Você disse: 99
Muito alto!
Digite o seu palpite.
foo
Digite o seu palpite.
61
Você disse: 61
Você acertou!
```

Demais! Com apenas um último ajuste, vamos finalizar o jogo de adivinhação:
lembre-se que o programa ainda está mostrando o número secreto. Isto foi bom
para testar, mas estraga o jogo. Vamos apagar o `println!` que revela o número
secreto. A Listagem 2-5 mostra o código final:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore
use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Adivinhe o número!");

    let numero_secreto = rand::thread_rng().gen_range(1..=101);

    loop {
        println!("Digite o seu palpite.");

        let mut palpite = String::new();

        io::stdin().read_line(&mut palpite)
            .expect("Falha ao ler entrada");

        let palpite: u32 = match palpite.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("Você disse: {palpite}");

        match palpite.cmp(&numero_secreto) {
            Ordering::Less => println!("Muito baixo!"),
            Ordering::Greater => println!("Muito alto!"),
            Ordering::Equal => {
                println!("Você acertou!");
                break;
            }
        }
    }
}
```

<span class="caption">Listagem 2-5: Código completo do jogo de adivinhação.
</span>

## Resumo

Neste ponto, você construiu com sucesso o jogo de adivinhação! Parabéns!

Este projeto foi uma forma prática de apresentar vários conceitos novos de Rust:
`let`, `match`, métodos, funções associadas, uso de crates externas, e outros.
Nos próximos capítulos, você vai aprender sobre esses conceitos em mais
detalhes. O Capítulo 3 aborda conceitos que a maioria das linguagens de
programação tem, como variáveis, tipos de dados e funções, e mostra como usá-los
em Rust. O Capítulo 4 explora posse (_ownership_), que é a característica do
Rust mais diferente das outras linguagens. O Capítulo 5 discute structs e a
sintaxe de métodos, e o Capítulo 6 se dedica a explicar enums.
