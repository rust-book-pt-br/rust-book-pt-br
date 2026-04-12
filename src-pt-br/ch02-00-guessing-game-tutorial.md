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

Ainda estamos trabalhando nesta linha de código. Estamos agora discutindo uma terceira linha de
texto, mas observe que ainda faz parte de uma única linha lógica de código. O próximo
parte é este método:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:expect}}
```

Poderíamos ter escrito este código como:

```rust,ignore
io::stdin().read_line(&mut guess).expect("Failed to read line");
```

No entanto, uma linha longa é difícil de ler, por isso é melhor dividi-la. Isso é
muitas vezes é aconselhável introduzir uma nova linha e outros espaços em branco para ajudar a separar longos
linhas quando você chama um método com a sintaxe `.method_name()`. Agora vamos
discuta o que esta linha faz.

Como mencionado anteriormente, `read_line` coloca tudo o que o usuário digita
na string que passamos para ele, mas ele também retorna um valor `Result`.
[`Result`][result]<!--
ignore --> é uma [_enumeração_][enums]<!-- ignore -->,
geralmente chamada de _enum_,
que é um tipo que pode estar em um dos vários estados possíveis. Chamamos cada um
possível indicar uma _variante_.

[Capítulo 6][enums]<!-- ignore --> abordará enums com mais detalhes. O objetivo
desses tipos `Result` é codificar informações de tratamento de erros.

As variantes de `Result` são `Ok` e `Err`. A variante `Ok` indica o
a operação foi bem-sucedida e contém o valor gerado com sucesso.
A variante `Err` significa que a operação falhou e contém informações
sobre como ou por que a operação falhou.

Valores do tipo `Result`, como valores de qualquer tipo, possuem métodos definidos em
eles. Uma instância de `Result` tem um [`expect` método][expect]<!-- ignore -->
que você pode ligar. Se esta instância de `Result` for um valor `Err`, `expect`
fará com que o programa trave e exiba a mensagem que você passou como
argumento para `expect`. Se o método `read_line` retornar um `Err`, seria
provavelmente será o resultado de um erro proveniente do sistema operacional subjacente.
Se esta instância de `Result` for um valor `Ok`, `expect` receberá o retorno
valor que `Ok` está mantendo e retornar apenas esse valor para você para que você possa
use-o. Nesse caso, esse valor é o número de bytes na entrada do usuário.

Se você não chamar `expect`, o programa será compilado, mas você receberá um aviso:

```console
{{#include ../listings/ch02-guessing-game-tutorial/no-listing-02-without-expect/output.txt}}
```

Rust avisa que você não usou o valor `Result` retornado de `read_line`,
indicando que o programa não tratou um possível erro.

A maneira correta de suprimir o aviso é escrever um código de tratamento de erros,
mas no nosso caso só queremos travar este programa quando ocorrer um problema, então
pode usar `expect`. Você aprenderá como se recuperar de erros no [Capítulo
9][recover]<!-- ignore -->.

### Imprimindo valores com `println!` espaços reservados

Além da chave de fechamento, há apenas mais uma linha para discutir em
o código até agora:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:print_guess}}
```

Esta linha imprime a string que agora contém a entrada do usuário. O conjunto `{}` de
colchetes são um espaço reservado: pense em `{}` como pequenas pinças de caranguejo que seguram
um valor em vigor. Ao imprimir o valor de uma variável, o nome da variável pode
entre entre colchetes. Ao imprimir o resultado da avaliação de um
expressão, coloque colchetes vazios na string de formato e siga o
string de formato com uma lista de expressões separadas por vírgula para imprimir em cada vazio
espaço reservado para colchetes na mesma ordem. Imprimindo uma variável e o resultado
de uma expressão em uma chamada para `println!` ficaria assim:

```rust
let x = 5;
let y = 10;

println!("x = {x} and y + 2 = {}", y + 2);
```

Este código imprimiria `x = 5 and y + 2 = 12`.

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

Neste ponto, a primeira parte do jogo está concluída: estamos recebendo informações do
teclado e depois imprimi-lo.

## Gerando um número secreto

A seguir, precisamos gerar um número secreto que o usuário tentará adivinhar. O
o número secreto deve ser sempre diferente para que o jogo seja divertido de jogar
mais de uma vez. Usaremos um número aleatório entre 1 e 100 para que o jogo
não é muito difícil. Rust ainda não inclui funcionalidade de números aleatórios em
sua biblioteca padrão. No entanto, a equipe Rust fornece um [`rand`
crate][randcrate] com essa funcionalidade.

<!-- Old headings. Do not remove or links may break. -->
<a id="using-a-crate-to-get-more-functionality"></a>

### Aumentando a funcionalidade com uma crate

Lembre-se de que uma crate é uma coleção de arquivos de código-fonte do Rust. O projeto
que estamos construindo é uma crate binária, que é um executável. A crate `rand`
é uma crate de biblioteca, que contém código que se destina a ser usado em outros
programas e não pode ser executado por conta própria.

A forma como o Cargo coordena crates externas é onde ele realmente brilha. Antes de nós
podemos escrever código que usa `rand`, precisamos modificar o arquivo _Cargo.toml_ para
inclua a crate `rand` como uma dependência. Abra esse arquivo agora e adicione o
linha seguinte até a parte inferior, abaixo do cabeçalho da seção `[dependencies]` que
o Cargo criou para você. Certifique-se de especificar `rand` exatamente como temos aqui, com
este número de versão ou os exemplos de código neste tutorial podem não funcionar:

<!-- When updating the version of `rand` used, also update the version of
`rand` used in these files so they all match:
* ch07-04-bringing-paths-into-scope-with-the-use-keyword.md
* ch14-03-cargo-workspaces.md
-->

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-02/Cargo.toml:8:}}
```

No arquivo _Cargo.toml_, tudo o que segue um cabeçalho faz parte dele
seção que continua até que outra seção comece. Em `[dependencies]`, você
diga ao Cargo de quais crates externas seu projeto depende e de quais versões
aquelas crates que você precisa. Neste caso, especificamos a crate `rand` com o
especificador de versão semântica `0.8.5`. O Cargo entende [Versionamento
Semântico][semver]<!-- ignore --> (às vezes chamado de _SemVer_), que é um
padrão para escrever números de versão. O especificador `0.8.5` é na verdade
abreviação de `^0.8.5`, o que significa qualquer versão que seja pelo menos 0.8.5, mas
abaixo de 0.9.0.

Cargo considera que essas versões possuem APIs públicas compatíveis com a versão
0.8.5, e esta especificação garante que você obterá a versão de patch mais recente
que ainda será compilado com o código neste capítulo. Qualquer versão 0.9.0 ou
maior não tem garantia de ter a mesma API que os exemplos a seguir
usar.

Agora, sem alterar nenhum código, vamos construir o projeto, conforme mostrado em
Listagem 2-2.

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-02/
rm Cargo.lock
cargo clean
cargo build -->

<Listing number="2-2" caption="Saída de `cargo build` após adicionar o crate `rand` como dependência">

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

Você poderá ver diferentes números de versão (mas todos serão compatíveis com o
código, graças ao SemVer!) e diferentes linhas (dependendo do funcionamento
sistema), e as linhas podem estar em uma ordem diferente.

Quando incluímos uma dependência externa, o Cargo busca as versões mais recentes do
tudo que a dependência precisa do _registry_, que é uma cópia dos dados
de [Crates.io][cratesio]. Crates.io é onde as pessoas do ecossistema Rust
postar seus projetos Rust de código aberto para outros usarem.

Após atualizar o registro, Cargo verifica a seção `[dependencies]` e
baixa todas as crates listadas que ainda não foram baixadas. Nesse caso,
embora tenhamos listado apenas `rand` como uma dependência, Cargo também pegou outras crates
que `rand` depende para funcionar. Depois de baixar as crates, Rust compila
eles e então compila o projeto com as dependências disponíveis.

Se você executar `cargo build` imediatamente novamente sem fazer nenhuma alteração, você
não obterá nenhuma saída além da linha `Finished`. Cargo sabe que já
baixou e compilou as dependências e você não mudou nada
sobre eles em seu arquivo _Cargo.toml_. Cargo também sabe que você não mudou
nada sobre o seu código, então ele também não o recompila. Sem nada para
fazer, ele simplesmente sai.

Se você abrir o arquivo _src/main.rs_, faça uma alteração trivial, salve-o e
build novamente, você verá apenas duas linhas de saída:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-02/
touch src/main.rs
cargo build -->

```console
$ cargo build
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.13s
```

Essas linhas mostram que o Cargo apenas atualiza a compilação com sua pequena alteração no
arquivo _src/main.rs_. Suas dependências não mudaram, então o Cargo sabe que pode
reutilizar o que já foi baixado e compilado para eles.

<!-- Old headings. Do not remove or links may break. -->
<a id="ensuring-reproducible-builds-with-the-cargo-lock-file"></a>

#### Garantindo construções reproduzíveis

Cargo possui um mecanismo que garante que você possa reconstruir o mesmo artefato a cada
vez que você ou qualquer outra pessoa cria seu código: o Cargo usará apenas as versões do
as dependências que você especificou até que você indique o contrário. Por exemplo, digamos
que na próxima semana a versão 0.8.6 da crate `rand` será lançada, e essa versão
contém uma correção de bug importante, mas também contém uma regressão que irá
quebrar seu código. Para lidar com isso, Rust cria o arquivo _Cargo.lock_ primeiro
vez que você executa `cargo build`, então agora temos isso no _jogo_de_adivinhação_
diretório.

Quando você constrói um projeto pela primeira vez, Cargo descobre todas as versões
das dependências que atendem aos critérios e depois as grava no
Arquivo _Cargo.lock_. Quando você construir seu projeto no futuro, Cargo verá
que o arquivo _Cargo.lock_ existe e usará as versões especificadas nele
em vez de fazer todo o trabalho de descobrir as versões novamente. Isso permite que você
ter uma construção reproduzível automaticamente. Em outras palavras, seu projeto
permaneça em 0.8.5 até que você atualize explicitamente, graças ao arquivo _Cargo.lock_.
Como o arquivo _Cargo.lock_ é importante para compilações reproduzíveis, muitas vezes é
verificado no controle de origem com o restante do código em seu projeto.

#### Atualizando uma crate para obter uma nova versão

Quando você deseja atualizar uma crate, Cargo fornece o comando `update`,
que irá ignorar o arquivo _Cargo.lock_ e descobrir todas as versões mais recentes
que atendem às suas especificações em _Cargo.toml_. Cargo então escreverá aqueles
versões para o arquivo _Cargo.lock_. Caso contrário, por padrão, Cargo irá apenas procurar
para versões superiores a 0.8.5 e inferiores a 0.9.0. Se a crate `rand` tiver
lançou as duas novas versões 0.8.6 e 0.999.0, você veria o seguinte se
você executou `cargo update`:

<!-- manual-regeneration
cd listings/ch02-guessing-game-tutorial/listing-02-02/
cargo update
assuming there is a new 0.8.x version of rand; otherwise use another update
as a guide to creating the hypothetical output shown here -->

Há muito mais a dizer sobre [Cargo][doccargo]<!-- ignore --> e [sua
ecossistema][doccratesio]<!-- ignore -->, que discutiremos no Capítulo 14, mas
por enquanto, isso é tudo que você precisa saber. Cargo facilita muito a reutilização
bibliotecas, então os Rustáceos são capazes de escrever projetos menores que são montados
de vários pacotes.

### Gerando um número aleatório

Vamos começar a usar `rand` para gerar um número para adivinhar. O próximo passo é
atualize _src/main.rs_, conforme mostrado na Listagem 2-3.

<Listing number="2-3" file-name="src/main.rs" caption="Adicionando código para gerar um número aleatório">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-03/src/main.rs:all}}
```

</Listing>

Primeiro, adicionamos a linha `use rand::Rng;`. A característica `Rng` define métodos que
geradores de números aleatórios são implementados, e essa característica deve estar no escopo para que possamos
use esses métodos. O Capítulo 10 abordará as características em detalhes.

A seguir, estamos adicionando duas linhas no meio. Na primeira linha chamamos
`rand::thread_rng` função que nos dá o número aleatório específico
gerador que usaremos: um que seja local para o thread atual do
execução e é propagado pelo sistema operacional. Então, chamamos `gen_range`
método no gerador de números aleatórios. Este método é definido pelo `Rng`
característica que trouxemos para o escopo com a instrução `use rand::Rng;`. O
O método `gen_range` pega uma expressão de intervalo como argumento e gera um
número aleatório no intervalo. O tipo de expressão de intervalo que estamos usando aqui leva
a forma `start..=end` e é inclusiva nos limites inferior e superior, então
precisa especificar `1..=100` para solicitar um número entre 1 e 100.

> Observação: você não saberá apenas quais características usar e quais métodos e funções
> chamar de uma crate, então cada crate possui documentação com instruções para
> usando-o. Outro recurso interessante do Cargo é que executar o `cargo doc
> O comando --open` criará a documentação fornecida por todas as suas dependências
> localmente e abra-o no seu navegador. Se você estiver interessado em outros
> funcionalidade na crate `rand`, por exemplo, execute `cargo doc --open` e
> clique em `rand` na barra lateral à esquerda.

A segunda nova linha imprime o número secreto. Isso é útil enquanto estamos
desenvolvendo o programa para poder testá-lo, mas vamos excluí-lo do
versão final. Não é um grande jogo se o programa imprimir a resposta o mais rápido possível
assim que começa!

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

Você deve obter números aleatórios diferentes e todos devem ser números entre
1 e 100. Ótimo trabalho!

## Comparando o Palpite com o Número Secreto

Agora que temos a entrada do usuário e um número aleatório, podemos compará-los. Esse passo
é mostrado na Listagem 2-4. Observe que este código ainda não será compilado, pois iremos
explicar.

<Listing number="2-4" file-name="src/main.rs" caption="Tratando os possíveis valores de retorno da comparação entre dois números">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-04/src/main.rs:here}}
```

</Listing>

Primeiro, adicionamos outra instrução `use`, trazendo um tipo chamado
`std::cmp::Ordering` no escopo da biblioteca padrão. O tipo `Ordering`
é outro enum e possui as variantes `Less`, `Greater` e `Equal`. Estes são
os três resultados possíveis quando você compara dois valores.

Em seguida, adicionamos cinco novas linhas na parte inferior que usam o tipo `Ordering`. O
O método `cmp` compara dois valores e pode ser chamado em qualquer coisa que possa ser
comparado. É necessária uma referência a tudo o que você deseja comparar: aqui, é
comparando `guess` com `secret_number`. Em seguida, ele retorna uma variante do
`Ordering` enum que trouxemos para o escopo com a instrução `use`. Usamos um
[`match`][match]<!-- ignore --> expressão para decidir o que fazer a seguir com base em
qual variante de `Ordering` foi retornada da chamada para `cmp` com os valores
em `guess` e `secret_number`.

Uma expressão `match` é composta de _braços_. Um braço consiste em um _padrão_ para
corresponder e o código que deve ser executado se o valor fornecido a `match`
se encaixa no padrão desse braço. Rust pega o valor dado a `match` e olha
através do padrão de cada braço, por sua vez. Padrões e a construção `match` são
recursos poderosos do Rust: eles permitem expressar uma variedade de situações em que seu código
pode encontrar, e eles garantem que você lide com todos eles. Esses recursos serão
abordados em detalhes no Capítulo 6 e no Capítulo 19, respectivamente.

Vejamos um exemplo com a expressão `match` que usamos aqui. Diga isso
o usuário adivinhou 50 e o número secreto gerado aleatoriamente desta vez é
38.

Quando o código compara 50 a 38, o método `cmp` retornará
`Ordering::Greater` porque 50 é maior que 38. A expressão `match` fica
o valor `Ordering::Greater` e começa a verificar o padrão de cada braço. Parece
no padrão do primeiro braço, `Ordering::Less`, e vê que o valor
`Ordering::Greater` não corresponde a `Ordering::Less`, portanto ignora o código em
esse braço e passa para o próximo braço. O próximo padrão do braço é
`Ordering::Greater`, que _corresponde_ a `Ordering::Greater`! O código
associado a esse braço será executado e imprimirá `Too big!` na tela. A
expressão `match` termina após a primeira correspondência bem-sucedida, então
ela não olha para o último braço nesse cenário.

Entretanto, o código na Listagem 2.4 ainda não será compilado. Vamos tentar:

<!--
The error numbers in this output should be that of the code **WITHOUT** the
anchor or snip comments
-->

```console
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-04/output.txt}}
```

A essência do erro é que existem _tipos incompatíveis_. Rust tem um sistema de
tipos estático e forte, mas também possui inferência de tipos. Quando
escrevemos `let mut guess = String::new()`, Rust conseguiu inferir que `guess`
deveria ser uma `String`, sem exigir que escrevêssemos isso explicitamente. Já
`secret_number` é um tipo numérico. Vários tipos numéricos do Rust podem
conter valores entre 1 e 100: `i32`, um número de 32 bits; `u32`, um inteiro
sem sinal de 32 bits; `i64`, um número de 64 bits; e assim por diante. A menos
que você especifique outra coisa, o padrão do Rust é `i32`, então esse é o
tipo de `secret_number`, a não ser que alguma informação em outro ponto faça o
compilador inferir outro tipo numérico. O erro acontece porque Rust não pode
comparar uma string com um número.

No fim das contas, queremos converter a `String` lida da entrada em um tipo
numérico para podermos compará-la numericamente com o número secreto. Fazemos
isso adicionando a seguinte linha ao corpo de `main`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-03-convert-string-to-number/src/main.rs:here}}
```

A linha é:

```rust,ignore
let guess: u32 = guess.trim().parse().expect("Please type a number!");
```

Criamos uma variável chamada `guess`. Mas espere: o programa já não tem uma
variável com esse nome? Tem, mas felizmente Rust nos permite sombrear o valor
anterior de `guess` com um novo. _Shadowing_ nos permite reutilizar o nome da
variável em vez de nos obrigar a criar duas variáveis diferentes, como
`guess_str` e `guess`, por exemplo. Veremos isso com mais detalhes no
[Capítulo 3][shadowing]<!-- ignore -->, mas por enquanto basta saber que esse
recurso é muito usado quando queremos converter um valor de um tipo para outro.

Associamos essa nova variável à expressão `guess.trim().parse()`. O `guess` na
expressão se refere à variável `guess` original, que continha a entrada como
uma string. O método `trim` em uma instância de `String` remove qualquer espaço
em branco no início e no fim, o que precisamos fazer antes de converter a
string para `u32`, que só pode conter dados numéricos. O usuário precisa
pressionar
<kbd>enter</kbd> para satisfazer `read_line` e inserir seu palpite, o que adiciona um
caractere de nova linha para a string. Por exemplo, se o usuário digitar <kbd>5</kbd> e
pressiona <kbd>enter</kbd>, `guess` fica assim: `5\n`. O `\n` representa
“nova linha.” (No Windows, pressionar <kbd>enter</kbd> resulta em um retorno de carro
e uma nova linha, `\r\n`.) O método `trim` elimina `\n` ou `\r\n`, resultando
em apenas `5`.

O método [`parse` em strings][parse]<!-- ignore --> converte uma string em
outro tipo. Aqui, nós o usamos para converter uma string em um número.
Precisamos dizer ao Rust exatamente qual tipo numérico queremos usando
`let guess: u32`. Os dois-pontos (`:`) após `guess` dizem ao Rust que vamos
anotar o tipo da variável. Rust possui vários tipos numéricos internos; o
`u32` visto aqui é um inteiro sem sinal de 32 bits. É uma boa escolha padrão
para um número positivo pequeno. Você aprenderá sobre outros tipos numéricos
no [Capítulo 3][integers]<!-- ignore -->.

Além disso, a anotação `u32` neste programa de exemplo e a comparação
com `secret_number` significa que Rust irá inferir que `secret_number` deve ser um
`u32` também. Então, agora a comparação será entre dois valores do mesmo
tipo!

O método `parse` só funcionará em caracteres que podem ser convertidos logicamente
em números e, portanto, pode facilmente causar erros. Se, por exemplo, a sequência
continha `A👍%`, não haveria como converter isso em um número. Porque isso
pode falhar, o método `parse` retorna um tipo `Result`, assim como o método `read_line`
método faz (discutido anteriormente em [“Tratando falha potencial com
`Result`”](#tratamento-de-falha-potencial-com-resultado)<!-- ignore -->). Trataremos
isso `Result` da mesma maneira usando o método `expect` novamente. Se `parse`
retorna uma variante `Err` `Result` porque não foi possível criar um número a partir do
string, a chamada `expect` irá travar o jogo e imprimir a mensagem que lhe demos.
Se `parse` conseguir converter a string em um número com sucesso, ele retornará o
`Ok` variante de `Result` e `expect` retornará o número que queremos
o valor `Ok`.

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

Legal! Mesmo com espaços antes do palpite, o programa ainda conseguiu entender
que o usuário digitou 76. Execute o programa algumas vezes para observar o
comportamento com diferentes tipos de entrada: adivinhe corretamente, escolha
um número alto demais e depois um baixo demais.

Temos a maior parte do jogo funcionando agora, mas o usuário só pode dar um palpite.
Vamos mudar isso adicionando um loop!

## Permitindo Múltiplos Palpites com Looping

A palavra-chave `loop` cria um loop infinito. Vamos adicionar um loop para dar
à pessoa jogadora mais chances de acertar o número:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-04-looping/src/main.rs:here}}
```

Como você pode ver, movemos tudo a partir do prompt de entrada do palpite para
dentro de um loop. Certifique-se de recuar em mais quatro espaços as linhas
dentro do loop e execute o programa novamente. Agora o programa pedirá outro
palpite indefinidamente, o que introduz um novo problema: não parece haver uma
forma de o usuário sair!

O usuário sempre pode interromper o programa usando o atalho do teclado
<kbd>ctrl</kbd>-<kbd>C</kbd>. Mas há outra maneira de escapar desse monstro insaciável, como mencionamos na discussão sobre `parse` em [“Comparando o palpite com o
Número secreto”](#comparando-o-palpite-com-o-número-secreto)<!-- ignore -->: Se
o usuário inserir uma resposta que não seja um número, o programa irá travar. Podemos levar
vantagem disso para permitir que o usuário saia, conforme mostrado aqui:

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

Digitar `quit` encerra o jogo, mas, como você vai notar, qualquer outra entrada
não numérica também o faz encerrar. Isso está longe do ideal; queremos que o
jogo termine quando o número correto for adivinhado.

### Desistir após um palpite correto

Vamos programar o jogo para encerrar quando o usuário vencer, adicionando uma instrução `break`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-05-quitting/src/main.rs:here}}
```

Adicionar a linha `break` após `You win!` faz o programa sair do loop quando o
usuário acerta o número secreto. Sair do loop também significa sair do
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
