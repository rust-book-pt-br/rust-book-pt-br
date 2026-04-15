# Programando um Jogo de Adivinhação

Vamos entrar no Rust trabalhando juntos em um projeto prático! Este capítulo
apresenta alguns conceitos comuns da linguagem ao mostrar como usá-los em um
programa real. Você aprenderá sobre `let`, `match`, métodos, funções
associadas, crates externos e muito mais. Nos capítulos seguintes,
exploraremos essas ideias em mais detalhes. Aqui, o objetivo é praticar os
fundamentos.

Implementaremos um problema clássico para iniciantes: um jogo de adivinhação.
O funcionamento é simples: o programa gera um número inteiro aleatório entre 1
e 100 e pede que a pessoa jogadora digite um palpite. Depois que o palpite é
informado, o programa diz se ele é baixo demais ou alto demais. Se o palpite
estiver correto, o jogo imprime uma mensagem de parabéns e encerra.

## Configurando um Novo Projeto

Para configurar um novo projeto, vá até o diretório _projects_ que você criou
no Capítulo 1 e crie um novo projeto com o Cargo:

```console
$ cargo new guessing_game
$ cd guessing_game
```

O primeiro comando, `cargo new`, recebe o nome do projeto
(`guessing_game`) como primeiro argumento. O segundo comando entra no diretório
do projeto recém-criado.

Veja o arquivo _Cargo.toml_ gerado:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial
rm -rf no-listing-01-cargo-new
cargo new no-listing-01-cargo-new --name guessing_game
cd no-listing-01-cargo-new
cargo run > output.txt 2>&1
cd ../../..
-->

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
{{#include ../listings/ch02-guessing-game-tutorial/no-listing-01-cargo-new/Cargo.toml}}
```

Como você viu no Capítulo 1, `cargo new` gera para você um programa “Hello,
world!”. Veja o arquivo _src/main.rs_:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-01-cargo-new/src/main.rs}}
```

Agora vamos compilar esse programa “Hello, world!” e executá-lo em uma única
etapa usando o comando `cargo run`:

```console
{{#include ../listings/ch02-guessing-game-tutorial/no-listing-01-cargo-new/output.txt}}
```

O comando `run` é útil quando você precisa iterar rapidamente em um projeto,
como faremos neste jogo, testando cada alteração antes de seguir adiante.

Abra novamente o arquivo _src/main.rs_. Você escreverá todo o código neste arquivo.

## Processando um Palpite

A primeira parte do programa do jogo de adivinhação vai pedir uma entrada ao
usuário, processá-la e verificar se ela está no formato esperado. Para começar,
vamos permitir que a pessoa jogadora digite um palpite. Insira o código da
Listagem 2-1 em _src/main.rs_.

<Listing number="2-1" file-name="src/main.rs" caption="Código que lê um palpite do usuário e o imprime">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:all}}
```

</Listing>

Esse código contém muita coisa, então vamos analisá-lo linha por linha. Para
receber a entrada do usuário e depois imprimir o resultado, precisamos trazer
para o escopo a biblioteca de entrada e saída `io`. A biblioteca `io` faz
parte da biblioteca padrão, conhecida como `std`:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:io}}
```

Por padrão, Rust traz para o escopo de todo programa um conjunto de itens
definidos na biblioteca padrão. Esse conjunto é chamado de _prelude_, e você
pode ver tudo o que ele inclui [na documentação da biblioteca padrão][prelude].

Se um tipo que você quer usar não estiver no prelude, será necessário trazê-lo
explicitamente para o escopo com uma instrução `use`. A biblioteca `std::io`
fornece vários recursos úteis, incluindo a capacidade de ler entrada do
usuário.

Como você viu no Capítulo 1, a função `main` é o ponto de entrada no
programa:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:main}}
```

A sintaxe `fn` declara uma nova função; os parênteses `()` indicam que não há
parâmetros; e a chave `{` inicia o corpo da função.

Como você também aprendeu no Capítulo 1, `println!` é uma macro que imprime uma
string na tela:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:print}}
```

Esse código imprime uma mensagem informando sobre o jogo e pedindo a entrada do
usuário.

### Armazenando Valores com Variáveis

A seguir, criaremos uma _variável_ para armazenar a entrada do usuário, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:string}}
```

Agora o programa começa a ficar interessante! Há bastante coisa acontecendo
nessa linha curta. Usamos a instrução `let` para criar a variável. Aqui vai
outro exemplo:

```rust,ignore
let apples = 5;
```

Esta linha cria uma nova variável chamada `apples` e a vincula ao valor `5`.
Em Rust, variáveis são imutáveis por padrão; isto é, depois que damos um valor
a uma variável, esse valor não muda. Discutiremos esse conceito em detalhes na
seção [“Variáveis e Mutabilidade”][variables-and-mutability]<!-- ignore --> do
Capítulo 3. Para tornar uma variável mutável, adicionamos `mut` antes do nome
da variável:

```rust,ignore
let apples = 5; // immutable
let mut bananas = 5; // mutable
```

> Nota: a sintaxe `//` inicia um comentário que vai até o fim da linha. Rust
> ignora tudo o que estiver em comentários. Falaremos mais sobre comentários no
> [Capítulo 3][comments]<!-- ignore -->.

Voltando ao programa do jogo de adivinhação, agora você sabe que `let mut
guess` vai introduzir uma variável mutável chamada `guess`. O sinal de igual
(`=`) diz ao Rust que queremos associar algo à variável naquele momento. À
direita do sinal de igual está o valor ao qual `guess` será associado, que é o
resultado da chamada `String::new`, uma função que retorna uma nova instância
de `String`. [`String`][string]<!-- ignore --> é um tipo de string fornecido
pela biblioteca padrão; trata-se de um pedaço de texto codificado em UTF-8 que
pode crescer.

A sintaxe `::` em `String::new` indica que `new` é uma função associada ao
tipo `String`. Uma _função associada_ é uma função implementada em um tipo,
neste caso `String`. A função `new` cria uma string nova e vazia. Você verá
uma função `new` em vários tipos porque esse é um nome comum para uma função
que cria algum valor novo.

Portanto, a linha `let mut guess = String::new();` cria uma variável mutável
que está associada, naquele momento, a uma instância nova e vazia de `String`.

### Recebendo entrada do usuário

Lembre-se de que incluímos a funcionalidade de entrada e saída da biblioteca
padrão com `use std::io;` na primeira linha do programa. Agora vamos chamar a
função `stdin` do módulo `io`, que nos permitirá lidar com a entrada do
usuário:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:read}}
```

Se não tivéssemos importado o módulo `io` com `use std::io;` no início do
programa, ainda poderíamos usar a função escrevendo a chamada como
`std::io::stdin`. A função `stdin` retorna uma instância de
[`std::io::Stdin`][iostdin]<!-- ignore -->, um tipo que representa um
manipulador para a entrada padrão do seu terminal.

Em seguida, a linha `.read_line(&mut guess)` chama o método
[`read_line`][read_line]<!-- ignore --> nesse manipulador de entrada padrão
para obter a entrada do usuário. Também passamos `&mut guess` como argumento
para `read_line`, indicando em qual string a entrada deverá ser armazenada. O
comportamento de `read_line` é pegar tudo o que o usuário digita na entrada
padrão e anexar esse conteúdo à string passada como argumento, sem sobrescrever
o que ela já contém. Por isso, o argumento precisa ser mutável: o método vai
alterar o conteúdo da string.

O `&` indica que esse argumento é uma _referência_, o que dá a você uma forma
de permitir que várias partes do código acessem um mesmo dado sem precisar
copiá-lo na memória muitas vezes. Referências são um recurso complexo, e uma
das grandes vantagens do Rust é que ele torna o uso delas seguro e prático.
Você não precisa entender todos esses detalhes agora para terminar este
programa. Por enquanto, basta saber que, assim como variáveis, referências são
imutáveis por padrão. Por isso, você precisa escrever `&mut guess` em vez de
`&guess` para torná-la mutável. O Capítulo 4 explicará referências com mais
detalhes.

<!-- Old headings. Do not remove or links may break. -->

<a id="handling-potential-failure-with-the-result-type"></a>

### Lidando com falhas potenciais com `Result`

Ainda estamos trabalhando nessa linha de código. Agora estamos discutindo uma
terceira linha de texto, mas observe que ela ainda faz parte de uma única
linha lógica de código. A próxima parte é este método:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:expect}}
```

Poderíamos ter escrito este código como:

```rust,ignore
io::stdin().read_line(&mut guess).expect("Failed to read line");
```

No entanto, uma linha longa é difícil de ler, por isso é melhor dividi-la.
Muitas vezes, vale a pena introduzir uma quebra de linha e outros espaços em
branco para separar linhas longas quando você chama um método com a sintaxe
`.method_name()`. Agora vamos discutir o que essa linha faz.

Como mencionamos antes, `read_line` coloca tudo o que a pessoa usuária digita
na string que passamos a ele, mas também retorna um valor `Result`.
[`Result`][result]<!-- ignore --> é uma [_enumeração_][enums]<!-- ignore -->,
geralmente chamada de _enum_, que é um tipo que pode estar em um dentre vários
estados possíveis. Chamamos cada estado possível de _variante_.

[Capítulo 6][enums]<!-- ignore --> abordará enums em mais detalhes. O propósito
de tipos `Result` é codificar informações sobre tratamento de erros.

As variantes de `Result` são `Ok` e `Err`. A variante `Ok` indica que a
operação foi bem-sucedida e contém o valor gerado com sucesso. A variante
`Err` significa que a operação falhou e contém informações sobre como ou por
que ela falhou.

Valores do tipo `Result`, como valores de qualquer outro tipo, têm métodos
definidos neles. Uma instância de `Result` tem um [método
`expect`][expect]<!-- ignore --> que você pode chamar. Se essa instância de
`Result` for um valor `Err`, `expect` fará o programa encerrar e exibirá a
mensagem que você passou como argumento para `expect`. Se o método `read_line`
retornar um `Err`, isso provavelmente será resultado de um erro vindo do
sistema operacional subjacente. Se essa instância de `Result` for um valor
`Ok`, `expect` pegará o valor que `Ok` está contendo e o retornará para você
usar. Nesse caso, esse valor é o número de bytes da entrada da pessoa usuária.

Se você não chamar `expect`, o programa será compilado, mas você receberá um aviso:

```console
{{#include ../listings/ch02-guessing-game-tutorial/no-listing-02-without-expect/output.txt}}
```

Rust avisa que você não usou o valor `Result` retornado de `read_line`,
indicando que o programa não tratou um possível erro.

A forma correta de suprimir o aviso é escrever código de tratamento de erros,
mas, no nosso caso, queremos apenas encerrar o programa quando ocorrer um
problema, então podemos usar `expect`. Você aprenderá como se recuperar de
erros no [Capítulo 9][recover]<!-- ignore -->.

### Imprimindo valores com placeholders de `println!`

Além da chave de fechamento, há apenas mais uma linha para discutir no código
até aqui:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:print_guess}}
```

Essa linha imprime a string que agora contém a entrada da pessoa usuária. O
conjunto `{}` de chaves funciona como um placeholder: pense em `{}` como
pequenas garras de caranguejo segurando um valor no lugar. Ao imprimir o valor
de uma variável, o nome da variável pode ir entre as chaves. Ao imprimir o
resultado da avaliação de uma expressão, coloque chaves vazias na string de
formatação e, em seguida, acrescente à string de formatação uma lista de
expressões separadas por vírgula, a serem impressas em cada placeholder vazio,
na mesma ordem. Imprimir uma variável e o resultado de uma expressão em uma
única chamada a `println!` ficaria assim:

```rust
let x = 5;
let y = 10;

println!("x = {x} and y + 2 = {}", y + 2);
```

Esse código imprimiria `x = 5 and y + 2 = 12`.

### Testando a primeira parte

Vamos testar a primeira parte do jogo de adivinhação. Execute-o usando `cargo run`:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-01/
cargo clean
cargo run
input 6 -->

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 6.44s
     Running `target/debug/guessing_game`
Guess the number!
Please input your guess.
6
You guessed: 6
```

Neste ponto, a primeira parte do jogo está concluída: estamos recebendo entrada
do teclado e depois imprimindo essa entrada.

## Gerando um número secreto

A seguir, precisamos gerar um número secreto que a pessoa usuária tentará
adivinhar. O número secreto deve ser diferente a cada vez para que o jogo seja
divertido de jogar mais de uma vez. Vamos usar um número aleatório entre 1 e
100 para que o jogo não fique muito difícil. Rust ainda não inclui
funcionalidade de números aleatórios em sua biblioteca padrão. No entanto, a
equipe do Rust fornece uma crate chamada [`rand`][randcrate] com essa
funcionalidade.

<!-- Old headings. Do not remove or links may break. -->
<a id="using-a-crate-to-get-more-functionality"></a>

### Aumentando a funcionalidade com uma crate

Lembre-se de que uma crate é uma coleção de arquivos de código-fonte Rust. O
projeto que estamos construindo é uma crate binária, isto é, um executável. A
crate `rand` é uma crate de biblioteca, que contém código destinado a ser
usado em outros programas e não pode ser executado sozinha.

A forma como o Cargo coordena crates externas é onde ele realmente brilha.
Antes de escrevermos código que use `rand`, precisamos modificar o arquivo
_Cargo.toml_ para incluir a crate `rand` como dependência. Abra esse arquivo
agora e adicione a linha a seguir no final, abaixo do cabeçalho da seção
`[dependencies]` que o Cargo criou para você. Certifique-se de especificar
`rand` exatamente como está aqui, com esse número de versão, ou os exemplos de
código deste tutorial podem não funcionar:

<!-- When updating the version of `rand` used, also update the version of
`rand` used in these files so they all match:
* ch07-04-bringing-paths-into-scope-with-the-use-keyword.md
* ch14-03-cargo-workspaces.md
-->

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-02/Cargo.toml:8:}}
```

No arquivo _Cargo.toml_, tudo o que vem depois de um cabeçalho faz parte
daquela seção, até que outra seção comece. Em `[dependencies]`, você informa ao
Cargo de quais crates externas o projeto depende e de quais versões dessas
crates você precisa. Neste caso, especificamos a crate `rand` com o
especificador de versão semântica `0.8.5`. O Cargo entende [Versionamento
Semântico][semver]<!-- ignore -->, às vezes chamado de _SemVer_, que é um
padrão para escrever números de versão. O especificador `0.8.5` é, na verdade,
uma abreviação de `^0.8.5`, o que significa qualquer versão que seja pelo menos
0.8.5, mas abaixo de 0.9.0.

O Cargo considera que essas versões têm APIs públicas compatíveis com a versão
0.8.5, e essa especificação garante que você obterá a versão de patch mais
recente que ainda compilará com o código deste capítulo. Não há garantia de que
qualquer versão 0.9.0 ou superior tenha a mesma API usada nos exemplos a
seguir.

Agora, sem alterar nenhum código, vamos compilar o projeto, como mostra a
Listagem 2-2.

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-02/
rm Cargo.lock
cargo clean
cargo build -->

<Listing number="2-2" caption="Saída de `cargo build` após adicionar a crate `rand` como dependência">

```console
$ cargo build
  Updating crates.io index
   Locking 15 packages to latest Rust 1.85.0 compatible versions
    Adding rand v0.8.5 (available: v0.9.0)
 Compiling proc-macro2 v1.0.93
 Compiling unicode-ident v1.0.17
 Compiling libc v0.2.170
 Compiling cfg-if v1.0.0
 Compiling byteorder v1.5.0
 Compiling getrandom v0.2.15
 Compiling rand_core v0.6.4
 Compiling quote v1.0.38
 Compiling syn v2.0.98
 Compiling zerocopy-derive v0.7.35
 Compiling zerocopy v0.7.35
 Compiling ppv-lite86 v0.2.20
 Compiling rand_chacha v0.3.1
 Compiling rand v0.8.5
 Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
  Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.48s
```

</Listing>

Você pode ver números de versão diferentes, embora todos sejam compatíveis com
o código graças ao SemVer, e linhas diferentes, dependendo do sistema
operacional. As linhas também podem aparecer em outra ordem.

Quando incluímos uma dependência externa, o Cargo busca no _registry_ as
versões mais recentes de tudo de que a dependência precisa. O registry é uma
cópia dos dados de [Crates.io][cratesio]. O Crates.io é onde as pessoas do
ecossistema Rust publicam seus projetos Rust de código aberto para que outras
pessoas possam usá-los.

Depois de atualizar o registry, o Cargo verifica a seção `[dependencies]` e
baixa todas as crates listadas que ainda não foram baixadas. Nesse caso,
embora tenhamos listado apenas `rand` como dependência, o Cargo também obteve
outras crates das quais `rand` depende para funcionar. Depois de baixar as
crates, Rust as compila e, em seguida, compila o projeto com as dependências
disponíveis.

Se você executar `cargo build` imediatamente de novo, sem fazer nenhuma
alteração, não verá nenhuma saída além da linha `Finished`. O Cargo sabe que
já baixou e compilou as dependências e que você não mudou nada nelas no arquivo
_Cargo.toml_. Ele também sabe que você não mudou nada no seu código, então não
o recompila. Sem nada a fazer, ele simplesmente encerra.

Se você abrir o arquivo _src/main.rs_, fizer uma alteração trivial, salvá-lo e
compilar novamente, verá apenas duas linhas de saída:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-02/
touch src/main.rs
cargo build -->

```console
$ cargo build
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.13s
```

Essas linhas mostram que o Cargo atualiza apenas o build com a pequena mudança
feita no arquivo _src/main.rs_. Como as dependências não mudaram, o Cargo sabe
que pode reutilizar o que já foi baixado e compilado para elas.

<!-- Old headings. Do not remove or links may break. -->
<a id="ensuring-reproducible-builds-with-the-cargo-lock-file"></a>

#### Garantindo builds reproduzíveis

O Cargo tem um mecanismo que garante que você possa recriar o mesmo artefato
toda vez que você ou qualquer outra pessoa compilar o código: ele usará apenas
as versões das dependências que você especificou até que você diga o contrário.
Por exemplo, imagine que, na próxima semana, a versão 0.8.6 da crate `rand`
seja lançada, contendo uma correção de bug importante, mas também uma regressão
que quebrará seu código. Para lidar com isso, Rust cria o arquivo
_Cargo.lock_ na primeira vez que você executa `cargo build`, então agora temos
esse arquivo no diretório _guessing_game_.

Quando você compila um projeto pela primeira vez, o Cargo descobre todas as
versões das dependências que atendem aos critérios e depois as grava no
arquivo _Cargo.lock_. Quando você compilar o projeto no futuro, o Cargo verá
que o arquivo _Cargo.lock_ existe e usará as versões especificadas ali, em vez
de repetir todo o trabalho de descobrir as versões novamente. Isso permite que
você tenha um build reproduzível automaticamente. Em outras palavras, o seu
projeto permanecerá na versão 0.8.5 até que você atualize explicitamente,
graças ao arquivo _Cargo.lock_. Como esse arquivo é importante para builds
reproduzíveis, muitas vezes ele é versionado junto com o restante do código no
projeto.

#### Atualizando uma crate para obter uma nova versão

Quando você _quiser_ atualizar uma crate, o Cargo fornece o comando `update`,
que ignorará o arquivo _Cargo.lock_ e descobrirá todas as versões mais recentes
que atendem às especificações do seu _Cargo.toml_. O Cargo então escreverá
essas versões no arquivo _Cargo.lock_. Fora isso, por padrão, o Cargo procurará
apenas versões maiores que 0.8.5 e menores que 0.9.0. Se a crate `rand`
tivesse lançado as duas novas versões 0.8.6 e 0.999.0, você veria o seguinte
ao executar `cargo update`:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-02/
cargo update
assuming there is a new 0.8.x version of rand; otherwise use another update
as a guide to creating the hypothetical output shown here -->

Há muito mais a dizer sobre [Cargo][doccargo]<!-- ignore --> e [seu
ecossistema][doccratesio]<!-- ignore -->, que discutiremos no Capítulo 14, mas,
por enquanto, isso é tudo o que você precisa saber. O Cargo facilita muito a
reutilização de bibliotecas, então os rustaceanos conseguem escrever projetos
menores, montados a partir de vários pacotes.

### Gerando um número aleatório

Vamos começar a usar `rand` para gerar um número a ser adivinhado. O próximo
passo é atualizar _src/main.rs_, como mostra a Listagem 2-3.

<Listing number="2-3" file-name="src/main.rs" caption="Adicionando código para gerar um número aleatório">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-03/src/main.rs:all}}
```

</Listing>

Primeiro, adicionamos a linha `use rand::Rng;`. A trait `Rng` define métodos
que geradores de números aleatórios implementam, e essa trait precisa estar em
escopo para que possamos usar esses métodos. O Capítulo 10 abordará traits em
detalhes.

A seguir, estamos adicionando duas linhas no meio. Na primeira, chamamos a
função `rand::thread_rng`, que nos fornece o gerador de números aleatórios
específico que vamos usar: um que é local à thread de execução atual e é
inicializado pelo sistema operacional. Depois, chamamos o método `gen_range`
nesse gerador de números aleatórios. Esse método é definido pela trait `Rng`
que trouxemos para o escopo com a instrução `use rand::Rng;`. O método
`gen_range` recebe uma expressão de intervalo como argumento e gera um número
aleatório dentro desse intervalo. O tipo de expressão de intervalo que estamos
usando aqui tem a forma `start..=end` e inclui os limites inferior e superior;
por isso, precisamos especificar `1..=100` para pedir um número entre 1 e 100.

> Nota: você não vai simplesmente saber quais traits usar e quais métodos e
> funções chamar de uma crate, então cada crate tem documentação com
> instruções sobre como usá-la. Outro recurso interessante do Cargo é que
> executar o comando `cargo doc --open` compila localmente a documentação
> fornecida por todas as suas dependências e a abre no navegador. Se você tiver
> interesse em outras funcionalidades da crate `rand`, por exemplo, execute
> `cargo doc --open` e clique em `rand` na barra lateral à esquerda.

A segunda nova linha imprime o número secreto. Isso é útil enquanto estamos
desenvolvendo o programa para podermos testá-lo, mas vamos removê-la da versão
final. Não existe muita graça em um jogo que imprime a resposta assim que
começa!

Tente executar o programa algumas vezes:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-03/
cargo run
4
cargo run
5
-->

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/guessing_game`
Guess the number!
The secret number is: 7
Please input your guess.
4
You guessed: 4

$ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/guessing_game`
Guess the number!
The secret number is: 83
Please input your guess.
5
You guessed: 5
```

Você deve obter números aleatórios diferentes, e todos eles devem estar entre 1
e 100. Ótimo trabalho!

## Comparando o Palpite com o Número Secreto

Agora que temos a entrada da pessoa usuária e um número aleatório, podemos
compará-los. Esse passo é mostrado na Listagem 2-4. Observe que esse código
ainda não compilará, como explicaremos.

<Listing number="2-4" file-name="src/main.rs" caption="Tratando os possíveis valores retornados pela comparação de dois números">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-04/src/main.rs:here}}
```

</Listing>

Primeiro, adicionamos outra instrução `use`, trazendo para o escopo um tipo da
biblioteca padrão chamado `std::cmp::Ordering`. O tipo `Ordering` é outro enum
e tem as variantes `Less`, `Greater` e `Equal`. Esses são os três resultados
possíveis ao comparar dois valores.

Em seguida, adicionamos cinco novas linhas na parte inferior que usam o tipo
`Ordering`. O método `cmp` compara dois valores e pode ser chamado em qualquer
coisa que possa ser comparada. Ele recebe uma referência ao que você quer
comparar com o valor atual; aqui, ele está comparando `guess` com
`secret_number`. Depois, retorna uma variante do enum `Ordering` que trouxemos
para o escopo com a instrução `use`. Usamos uma expressão
[`match`][match]<!-- ignore --> para decidir o que fazer a seguir com base em
qual variante de `Ordering` foi retornada pela chamada a `cmp` com os valores
em `guess` e `secret_number`.

Uma expressão `match` é composta por _braços_. Um braço consiste em um
_padrão_ a ser comparado e no código que deve ser executado se o valor dado a
`match` se encaixar no padrão daquele braço. Rust pega o valor fornecido a
`match` e verifica, em sequência, o padrão de cada braço. Padrões e a
construção `match` são recursos poderosos do Rust: eles permitem expressar uma
grande variedade de situações que seu código pode encontrar e garantem que
você trate todas elas. Esses recursos serão abordados em detalhes no Capítulo
6 e no Capítulo 19, respectivamente.

Vamos percorrer um exemplo com a expressão `match` que usamos aqui. Digamos que
a pessoa usuária tenha chutado 50 e que o número secreto gerado aleatoriamente
desta vez seja 38.

Quando o código compara 50 com 38, o método `cmp` retorna
`Ordering::Greater`, porque 50 é maior que 38. A expressão `match` recebe o
valor `Ordering::Greater` e começa a verificar o padrão de cada braço. Ela olha
para o padrão do primeiro braço, `Ordering::Less`, e vê que o valor
`Ordering::Greater` não corresponde a `Ordering::Less`, então ignora o código
desse braço e segue para o próximo. O padrão do braço seguinte é
`Ordering::Greater`, que _corresponde_ a `Ordering::Greater`! O código
associado a esse braço será executado e imprimirá `Too big!` na tela. A
expressão `match` termina após a primeira correspondência bem-sucedida, então
ela não verifica o último braço nesse cenário.

No entanto, o código da Listagem 2-4 ainda não compila. Vamos tentar:

<!--
The error numbers in this output should be that of the code **WITHOUT** the
anchor or snip comments
-->

```console
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-04/output.txt}}
```

A essência do erro é que existem _tipos incompatíveis_. Rust tem um sistema de
tipos forte e estático, mas também possui inferência de tipos. Quando
escrevemos `let mut guess = String::new()`, Rust conseguiu inferir que `guess`
deveria ser uma `String`, sem exigir que escrevêssemos isso explicitamente. Já
`secret_number` é um tipo numérico. Alguns dos tipos numéricos de Rust podem
conter um valor entre 1 e 100: `i32`, um número de 32 bits; `u32`, um inteiro
sem sinal de 32 bits; `i64`, um número de 64 bits; entre outros. A menos que
você especifique algo diferente, Rust usa `i32` por padrão, então esse é o
tipo de `secret_number`, a menos que alguma informação em outro ponto faça o
compilador inferir outro tipo numérico. O erro acontece porque Rust não pode
comparar uma string com um tipo numérico.

No fim das contas, queremos converter a `String` lida da entrada em um tipo
numérico, para podermos compará-la numericamente com o número secreto. Fazemos
isso adicionando a linha a seguir ao corpo de `main`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-03-convert-string-to-number/src/main.rs:here}}
```

A linha é:

```rust,ignore
let guess: u32 = guess.trim().parse().expect("Please type a number!");
```

Criamos uma variável chamada `guess`. Mas espere: o programa já não tem uma
variável com esse nome? Tem, mas, felizmente, Rust nos permite sombrear o
valor anterior de `guess` com um novo. _Shadowing_ nos permite reutilizar o
nome da variável em vez de nos obrigar a criar duas variáveis diferentes, como
`guess_str` e `guess`, por exemplo. Veremos isso com mais detalhes no
[Capítulo 3][shadowing]<!-- ignore -->, mas, por enquanto, basta saber que
esse recurso é muito usado quando queremos converter um valor de um tipo para
outro.

Associamos essa nova variável à expressão `guess.trim().parse()`. O `guess` na
expressão se refere à variável `guess` original, que continha a entrada como
string. O método `trim` em uma instância de `String` remove qualquer espaço em
branco no início e no fim, o que precisamos fazer antes de converter a string
para `u32`, que só pode conter dados numéricos. A pessoa usuária precisa
pressionar
<kbd>enter</kbd> para satisfazer `read_line` e inserir seu palpite, o que
adiciona um caractere de nova linha à string. Por exemplo, se a pessoa usuária
digitar <kbd>5</kbd> e pressionar <kbd>enter</kbd>, `guess` ficará assim:
`5\n`. O `\n` representa “nova linha”. No Windows, pressionar
<kbd>enter</kbd> resulta em retorno de carro e nova linha, `\r\n`. O método
`trim` elimina `\n` ou `\r\n`, deixando apenas `5`.

O [método `parse` em strings][parse]<!-- ignore --> converte uma string em
outro tipo. Aqui, nós o usamos para converter uma string em número. Precisamos
dizer ao Rust exatamente qual tipo numérico queremos usando
`let guess: u32`. Os dois-pontos (`:`) depois de `guess` dizem ao Rust que
vamos anotar o tipo da variável. Rust tem alguns tipos numéricos embutidos; o
`u32` visto aqui é um inteiro sem sinal de 32 bits. Ele é uma boa escolha
padrão para um número pequeno e positivo. Você aprenderá sobre outros tipos
numéricos no [Capítulo 3][integers]<!-- ignore -->.

Além disso, a anotação `u32` neste programa de exemplo, junto com a comparação
com `secret_number`, significa que Rust inferirá que `secret_number` também
deve ser um `u32`. Assim, agora a comparação será entre dois valores do mesmo
tipo!

O método `parse` só funcionará em caracteres que podem ser convertidos
logicamente em número e, portanto, pode falhar facilmente. Se, por exemplo, a
string contivesse `A👍%`, não haveria como convertê-la em número. Como isso
pode falhar, o método `parse` retorna um valor do tipo `Result`, assim como o
método `read_line` faz, como discutimos anteriormente em [“Lidando com falhas
potenciais com `Result`”](#lidando-com-falhas-potenciais-com-result)<!-- ignore -->.
Vamos tratar esse `Result` da mesma forma, usando novamente o método `expect`.
Se `parse` retornar uma variante `Err` de `Result` porque não conseguiu criar
um número a partir da string, a chamada a `expect` encerrará o jogo e imprimirá
a mensagem que fornecemos. Se `parse` conseguir converter a string para número,
ele retornará a variante `Ok` de `Result`, e `expect` retornará o número que
queremos a partir do valor `Ok`.

Vamos executar o programa agora:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/no-listing-03-convert-string-to-number/
touch src/main.rs
cargo run
  76
-->

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.26s
     Running `target/debug/guessing_game`
Guess the number!
The secret number is: 58
Please input your guess.
  76
You guessed: 76
Too big!
```

Muito bom! Mesmo com espaços antes do palpite, o programa ainda conseguiu
entender que a pessoa usuária digitou 76. Execute o programa algumas vezes para
observar o comportamento com diferentes tipos de entrada: acerte o número,
escolha um número alto demais e depois um baixo demais.

Temos a maior parte do jogo funcionando agora, mas a pessoa usuária só pode dar
um palpite. Vamos mudar isso adicionando um loop!

## Permitindo Múltiplos Palpites com Looping

A palavra-chave `loop` cria um loop infinito. Vamos adicionar um loop para dar
mais chances de acertar o número:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-04-looping/src/main.rs:here}}
```

Como você pode ver, movemos tudo a partir do prompt que pede o palpite para
dentro de um loop. Certifique-se de recuar em mais quatro espaços as linhas
dentro do loop e execute o programa novamente. Agora o programa pedirá outro
palpite indefinidamente, o que introduz um novo problema: não parece haver uma
forma de sair!

A pessoa usuária sempre pode interromper o programa usando o atalho de teclado
<kbd>ctrl</kbd>-<kbd>C</kbd>. Mas há outra forma de escapar desse monstro
insaciável, como mencionamos na discussão sobre `parse` em [“Comparando o
Palpite com o Número Secreto”](#comparando-o-palpite-com-o-número-secreto)<!-- ignore -->:
se a pessoa usuária inserir uma resposta que não seja número, o programa vai
encerrar. Podemos nos aproveitar disso para permitir que ela saia, como mostra
o exemplo a seguir:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/no-listing-04-looping/
touch src/main.rs
cargo run
(too small guess)
(too big guess)
(correct guess)
quit
-->

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.23s
     Running `target/debug/guessing_game`
Guess the number!
The secret number is: 59
Please input your guess.
45
You guessed: 45
Too small!
Please input your guess.
60
You guessed: 60
Too big!
Please input your guess.
59
You guessed: 59
You win!
Please input your guess.
quit

thread 'main' panicked at src/main.rs:28:47:
Please type a number!: ParseIntError { kind: InvalidDigit }
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Digitar `quit` encerra o jogo, mas, como você pode notar, qualquer outra
entrada não numérica também o encerra. Isso está longe do ideal; queremos que o
jogo também termine quando o número correto for adivinhado.

### Desistir após um palpite correto

Vamos programar o jogo para encerrar quando a pessoa usuária vencer,
adicionando uma instrução `break`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-05-quitting/src/main.rs:here}}
```

Adicionar a linha `break` após `You win!` faz o programa sair do loop quando a
pessoa usuária acerta o número secreto. Sair do loop também significa sair do
programa, porque o loop é a última parte de `main`.

### Tratamento de entrada inválida

Para refinar ainda mais o comportamento do jogo, em vez de travar o programa quando
o usuário insere um não-número, vamos fazer o jogo ignorar um não-número para que
o usuário pode continuar adivinhando. Podemos fazer isso alterando a linha onde
`guess` é convertido de `String` para `u32`, conforme mostrado na Listagem 2-5.

<Listing number="2-5" file-name="src/main.rs" caption="Ignorando um palpite que não é número e pedindo outro em vez de encerrar o programa">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-05/src/main.rs:here}}
```

</Listing>

Mudamos de uma chamada a `expect` para uma expressão `match`, deixando de
encerrar o programa em caso de erro para passar a tratá-lo. Lembre-se de que
`parse` retorna um `Result`, e `Result` é um enum com as variantes `Ok` e
`Err`. Estamos usando uma expressão `match` aqui, assim como fizemos com o
resultado `Ordering` retornado pelo método `cmp`.

Se `parse` conseguir transformar a string em um número, ele retornará um valor
`Ok` contendo o número resultante. Esse valor corresponderá ao padrão do
primeiro braço, e a expressão `match` retornará apenas o valor `num` produzido
por `parse` dentro do `Ok`. Esse número irá parar exatamente onde queremos: na
nova variável `guess` que estamos criando.

Se `parse` _não_ conseguir transformar a string em um número, ele retornará um
valor `Err` com mais informações sobre o erro. Esse valor não corresponde ao
padrão `Ok(num)` do primeiro braço, mas corresponde ao padrão `Err(_)` do
segundo. O sublinhado `_` é um curinga; neste exemplo, estamos dizendo que
queremos corresponder a todos os valores `Err`, independentemente das
informações que carregam. Então o programa executa o código do segundo braço,
`continue`, que o faz ir para a próxima iteração do `loop` e pedir outro
palpite. Na prática, o programa ignora qualquer erro que `parse` encontrar!

Agora tudo no programa deve funcionar conforme o esperado. Vamos tentar:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-05/
cargo run
(too small guess)
(too big guess)
foo
(correct guess)
-->

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.13s
     Running `target/debug/guessing_game`
Guess the number!
The secret number is: 61
Please input your guess.
10
You guessed: 10
Too small!
Please input your guess.
99
You guessed: 99
Too big!
Please input your guess.
foo
Please input your guess.
61
You guessed: 61
You win!
```

Incrível! Com um último ajuste pequeno, terminaremos o jogo de adivinhação.
Lembre-se de que o programa ainda está imprimindo o número secreto. Isso foi
útil para testar, mas estraga o jogo. Vamos remover o `println!` que imprime o
número secreto. A Listagem 2-6 mostra o código final.

<Listing number="2-6" file-name="src/main.rs" caption="Código completo do jogo de adivinhação">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-06/src/main.rs}}
```

</Listing>

Neste ponto, você construiu com sucesso o jogo de adivinhação. Parabéns!

## Resumo

Este projeto foi uma forma prática de apresentar muitos novos conceitos do Rust:
`let`, `match`, funções, uso de crates externas e muito mais. Nos próximos
capítulos, você aprenderá sobre esses conceitos com mais detalhes. Capítulo 3
cobre conceitos que a maioria das linguagens de programação possui, como variáveis, dados
tipos e funções, e mostra como usá-los no Rust. O Capítulo 4 explora
ownership, um recurso que torna o Rust diferente de outras linguagens. Capítulo 5
discute estruturas e sintaxe de método, e o Capítulo 6 explica como funcionam as enumerações.

[prelude]: ../std/prelude/index.html
[variables-and-mutability]: ch03-01-variables-and-mutability.html#variables-and-mutability
[comments]: ch03-04-comments.html
[string]: ../std/string/struct.String.html
[iostdin]: ../std/io/struct.Stdin.html
[read_line]: ../std/io/struct.Stdin.html#method.read_line
[result]: ../std/result/enum.Result.html
[enums]: ch06-00-enums.html
[expect]: ../std/result/enum.Result.html#method.expect
[recover]: ch09-02-recoverable-errors-with-result.html
[randcrate]: https://crates.io/crates/rand
[semver]: http://semver.org
[cratesio]: https://crates.io/
[doccargo]: https://doc.rust-lang.org/cargo/
[doccratesio]: https://doc.rust-lang.org/cargo/reference/publishing.html
[match]: ch06-02-match.html
[shadowing]: ch03-01-variables-and-mutability.html#shadowing
[parse]: ../std/primitive.str.html#method.parse
[integers]: ch03-02-data-types.html#integer-types
