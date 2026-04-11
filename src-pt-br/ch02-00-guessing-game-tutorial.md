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

## Configurando um novo projeto

Para configurar um novo projeto, vá para o diretório _projects_ que você criou em
Capítulo 1 e faça um novo projeto usando Cargo, assim:

```console
$ cargo new guessing_game
$ cd guessing_game
```

O primeiro comando, `cargo new`, leva o nome do projeto (`guessing_game`)
como primeiro argumento. O segundo comando muda para o novo projeto
diretório.

Veja o arquivo _Cargo.toml_ gerado:

<!-- manual-regeneration
listagens de cd/ch02-guessing-game-tutorial
rm -rf no-listing-01-cargo-new
carga nova no-listing-01-cargo-new --nome adivinhação_game
cd no-listing-01-cargo-new
execução de carga > output.txt 2>&1
cd ../../..
-->

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
{{#include ../listings/ch02-guessing-game-tutorial/no-listing-01-cargo-new/Cargo.toml}}
```

Como você viu no Capítulo 1, `cargo new` gera uma mensagem “Olá, mundo!” programa para
você. Confira o arquivo _src/main.rs_:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-01-cargo-new/src/main.rs}}
```

Agora vamos compilar este “Olá, mundo!” programa e execute-o na mesma etapa
usando o comando `cargo run`:

```console
{{#include ../listings/ch02-guessing-game-tutorial/no-listing-01-cargo-new/output.txt}}
```

O comando `run` é útil quando você precisa iterar rapidamente em um projeto,
como faremos neste jogo, testando rapidamente cada iteração antes de passar para
o próximo.

Abra novamente o arquivo _src/main.rs_. Você escreverá todo o código neste arquivo.

## Processando uma suposição

A primeira parte do programa do jogo de adivinhação solicitará a entrada do usuário, processará
essa entrada e verifique se a entrada está no formato esperado. Para começar, vamos
permitir que o jogador insira um palpite. Insira o código na Listagem 2-1 em
_src/main.rs_.

<Listing number="2-1" file-name="src/main.rs" caption="Code that gets a guess from the user and prints it">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:all}}
```

</Listing>

Este código contém muitas informações, então vamos analisá-lo linha por linha. Para
obter a entrada do usuário e depois imprimir o resultado como saída, precisamos trazer o
`io` biblioteca de entrada/saída no escopo. A biblioteca `io` vem do padrão
biblioteca, conhecida como `std`:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:io}}
```

Por padrão, Rust possui um conjunto de itens definidos na biblioteca padrão que ele
traz para o escopo de cada programa. Este conjunto é chamado de _prelúdio_, e
você pode ver tudo nele [na documentação padrão da biblioteca][prelude].

Se um tipo que você deseja usar não estiver no prelúdio, você deverá trazer esse tipo
no escopo explicitamente com uma instrução `use`. Usando a biblioteca `std::io`
fornece vários recursos úteis, incluindo a capacidade de aceitar
entrada do usuário.

Como você viu no Capítulo 1, a função `main` é o ponto de entrada no
programa:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:main}}
```

A sintaxe `fn` declara uma nova função; os parênteses, `()`, indicam lá
não há parâmetros; e a chave, `{`, inicia o corpo da função.

Como você também aprendeu no Capítulo 1, `println!` é uma macro que imprime uma string
a tela:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:print}}
```

Este código está imprimindo um prompt informando qual é o jogo e solicitando entrada
do usuário.

### Armazenando Valores com Variáveis

A seguir, criaremos uma _variável_ para armazenar a entrada do usuário, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:string}}
```

Agora o programa está ficando interessante! Há muita coisa acontecendo neste pequeno
linha. Usamos a instrução `let` para criar a variável. Aqui está outro exemplo:

```rust,ignore
let apples = 5;
```

Esta linha cria uma nova variável chamada `apples` e a vincula ao valor `5`.
No Rust, as variáveis ​​são imutáveis ​​por padrão, ou seja, uma vez que damos à variável
um valor, o valor não mudará. Discutiremos esse conceito em detalhes em
as [“Variáveis ​​e Mutabilidade”][variables-and-mutability]<!-- ignore -->
seção no Capítulo 3. Para tornar uma variável mutável, adicionamos `mut` antes do
nome da variável:

```rust,ignore
let apples = 5; // immutable
let mut bananas = 5; // mutable
```

> Nota: A sintaxe `//` inicia um comentário que continua até o final do
> linha. Rust ignora tudo nos comentários. Discutiremos os comentários com mais detalhes
> detalhes no [Capítulo 3][comments]<!-- ignore -->.

Voltando ao programa do jogo de adivinhação, agora você sabe que `let mut guess` irá
introduza uma variável mutável chamada `guess`. O sinal de igual (`=`) diz a Rust que
quero vincular algo à variável agora. À direita do sinal de igual está
o valor ao qual `guess` está vinculado, que é o resultado da chamada
`String::new`, uma função que retorna uma nova instância de `String`.
[`String`][string]<!-- ignore --> é um tipo de string fornecido pelo padrão
biblioteca que é um pedaço de texto codificado em UTF-8 que pode ser ampliado.

A sintaxe `::` na linha `::new` indica que `new` é um associado
função do tipo `String`. Uma _função associada_ é uma função que é
implementado em um tipo, neste caso `String`. Esta função `new` cria um
string nova e vazia. Você encontrará uma função `new` em muitos tipos porque é uma
nome comum para uma função que cria algum tipo de novo valor.

Na íntegra, a linha `let mut guess = String::new();` criou um mutável
variável que está atualmente vinculada a uma instância nova e vazia de `String`. Uau!

### Recebendo entrada do usuário

Lembre-se de que incluímos a funcionalidade de entrada/saída do padrão
biblioteca com `use std::io;` na primeira linha do programa. Agora vamos ligar
a função `stdin` do módulo `io`, que nos permitirá lidar com o usuário
entrada:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-01/src/main.rs:read}}
```

Se não tivéssemos importado o módulo `io` com `use std::io;` no início de
o programa, ainda poderíamos usar a função escrevendo esta chamada de função como
`std::io::stdin`. A função `stdin` retorna uma instância de
[`std::io::Stdin`][iostdin]<!-- ignore -->, que é um tipo que representa um
identificador para a entrada padrão do seu terminal.

Em seguida, a linha `.read_line(&mut guess)` chama o método
[`read_line`][read_line]<!-- ignore --> no identificador de entrada padrão para
obter a entrada do usuário.
Também estamos passando `&mut guess` como argumento para `read_line` para dizer o que
string para armazenar a entrada do usuário. O trabalho completo de `read_line` é pegar
tudo o que o usuário digita na entrada padrão e anexa isso em uma string
(sem sobrescrever seu conteúdo), então passamos essa string como um
argumento. O argumento string precisa ser mutável para que o método possa mudar
o conteúdo da string.

O `&` indica que este argumento é uma _referência_, o que lhe dá uma maneira de
permita que várias partes do seu código acessem um dado sem a necessidade
copie esses dados na memória várias vezes. As referências são um recurso complexo,
e uma das principais vantagens do Rust é como ele é seguro e fácil de usar
referências. Você não precisa saber muitos desses detalhes para terminar isso
programa. Por enquanto, tudo que você precisa saber é que, assim como as variáveis, as referências são
imutável por padrão. Portanto, você precisa escrever `&mut guess` em vez de
`&guess` para torná-lo mutável. (O Capítulo 4 explicará as referências mais
completamente.)

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
[`Result`][result]<!-- ignore --> é uma [_enumeração_][enums]<!-- ignore -->,
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
listagens de cd/ch02-guessing-game-tutorial/listing-02-01/
carga limpa
corrida de carga
entrada 6 -->

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

### Aumentando a funcionalidade com uma caixa

Lembre-se de que uma caixa é uma coleção de arquivos de código-fonte do Rust. O projeto
que estamos construindo é uma caixa binária, que é um executável. A caixa `rand`
é uma caixa de biblioteca, que contém código que se destina a ser usado em outros
programas e não pode ser executado por conta própria.

A coordenação de caixas externas da Cargo é onde a Cargo realmente brilha. Antes de nós
podemos escrever código que usa `rand`, precisamos modificar o arquivo _Cargo.toml_ para
inclua a caixa `rand` como uma dependência. Abra esse arquivo agora e adicione o
linha seguinte até a parte inferior, abaixo do cabeçalho da seção `[dependencies]` que
Carga criada para você. Certifique-se de especificar `rand` exatamente como temos aqui, com
este número de versão ou os exemplos de código neste tutorial podem não funcionar:

<!-- When updating the version of `rand` used, also update the version of
`rand` usado nesses arquivos para que todos correspondam:
* ch07-04-trazendo-caminhos-para-o-escopo-com-o-uso-palavra-chave.md
* ch14-03-cargo-workspaces.md
-->

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-02/Cargo.toml:8:}}
```

No arquivo _Cargo.toml_, tudo o que segue um cabeçalho faz parte dele
seção que continua até que outra seção comece. Em `[dependencies]`, você
diga ao Cargo de quais caixas externas seu projeto depende e de quais versões
aquelas caixas que você precisa. Neste caso, especificamos a caixa `rand` com o
especificador de versão semântica `0.8.5`. Carga entende [Semântica
Versionamento][semver]<!-- ignore --> (às vezes chamado de _SemVer_), que é um
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
listagens de cd/ch02-guessing-game-tutorial/listing-02-02/
rm Cargo.lock
carga limpa
construção de carga -->

<Listing number="2-2" caption="The output from running `cargo build` after adding the `rand` crate as a dependency">

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
baixa todas as caixas listadas que ainda não foram baixadas. Nesse caso,
embora tenhamos listado apenas `rand` como uma dependência, Cargo também pegou outras caixas
que `rand` depende para funcionar. Depois de baixar as caixas, Rust compila
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
listagens de cd/ch02-guessing-game-tutorial/listing-02-02/
toque em src/main.rs
construção de carga -->

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
que na próxima semana a versão 0.8.6 da caixa `rand` será lançada, e essa versão
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

#### Atualizando uma caixa para obter uma nova versão

Quando você deseja atualizar uma caixa, Cargo fornece o comando `update`,
que irá ignorar o arquivo _Cargo.lock_ e descobrir todas as versões mais recentes
que atendem às suas especificações em _Cargo.toml_. Cargo então escreverá aqueles
versões para o arquivo _Cargo.lock_. Caso contrário, por padrão, Cargo irá apenas procurar
para versões superiores a 0.8.5 e inferiores a 0.9.0. Se a caixa `rand` tiver
lançou as duas novas versões 0.8.6 e 0.999.0, você veria o seguinte se
você executou `cargo update`:

<!-- manual-regeneration
listagens de cd/ch02-guessing-game-tutorial/listing-02-02/
atualização de carga
assumindo que existe uma nova versão 0.8.x do Rand; caso contrário, use outra atualização
como um guia para criar a saída hipotética mostrada aqui ->

```console
$ cargo update
    Updating crates.io index
     Locking 1 package to latest Rust 1.85.0 compatible version
    Updating rand v0.8.5 -> v0.8.6 (available: v0.999.0)
```

Cargo ignora a versão 0.999.0. Neste ponto, você também notaria um
altere seu arquivo _Cargo.lock_ observando que a versão da caixa `rand`
você está usando agora é 0.8.6. Para usar `rand` versão 0.999.0 ou qualquer versão no
Série 0.999._x_, você teria que atualizar o arquivo _Cargo.toml_ para ficar assim
em vez disso (na verdade, não faça essa alteração porque os exemplos a seguir assumem
você está usando `rand` 0,8):

```toml
[dependencies]
rand = "0.999.0"
```

Na próxima vez que você executar `cargo build`, o Cargo atualizará o registro de caixas
disponível e reavalie seus `rand` requisitos de acordo com a nova versão
você especificou.
-->

Há muito mais a dizer sobre [Cargo][doccargo]<!-- ignore --> e [sua
ecossistema][doccratesio]<!-- ignore -->, que discutiremos no Capítulo 14, mas
por enquanto, isso é tudo que você precisa saber. Cargo facilita muito a reutilização
bibliotecas, então os Rustáceos são capazes de escrever projetos menores que são montados
de vários pacotes.

### Gerando um número aleatório

Vamos começar a usar `rand` para gerar um número para adivinhar. O próximo passo é
atualize _src/main.rs_, conforme mostrado na Listagem 2-3.

<Listing number="2-3" file-name="src/main.rs" caption="Adding code to generate a random number">

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
> chamar de uma caixa, então cada caixa possui documentação com instruções para
> usando-o. Outro recurso interessante do Cargo é que executar o `cargo doc
> O comando --open` criará a documentação fornecida por todas as suas dependências
> localmente e abra-o no seu navegador. Se você estiver interessado em outros
> funcionalidade na caixa `rand`, por exemplo, execute `cargo doc --open` e
> clique em `rand` na barra lateral à esquerda.

A segunda nova linha imprime o número secreto. Isso é útil enquanto estamos
desenvolvendo o programa para poder testá-lo, mas vamos excluí-lo do
versão final. Não é um grande jogo se o programa imprimir a resposta o mais rápido possível
assim que começa!

Tente executar o programa algumas vezes:

<!-- manual-regeneration
listagens de cd/ch02-guessing-game-tutorial/listing-02-03/
corrida de carga
4
corrida de carga
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

## Comparando a suposição com o número secreto

Agora que temos a entrada do usuário e um número aleatório, podemos compará-los. Esse passo
é mostrado na Listagem 2-4. Observe que este código ainda não será compilado, pois iremos
explicar.

<Listing number="2-4" file-name="src/main.rs" caption="Handling the possible return values of comparing two numbers">

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
`Ordering::Greater`, que _corresponde_ a `Ordering::Greater`! O associado
o código nesse braço será executado e impresso `Too big!` na tela. O `match`
expressão termina após a primeira correspondência bem-sucedida, portanto não olhará para a última
braço neste cenário.

Entretanto, o código na Listagem 2.4 ainda não será compilado. Vamos tentar:

<!--
Os números de erro nesta saída devem ser os do código **SEM** o
âncora ou recorte comentários
-->

```console
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-04/output.txt}}
```

A essência do erro afirma que existem _tipos incompatíveis_. A ferrugem tem um
sistema de tipo estático e forte. No entanto, também possui inferência de tipo. Quando escrevemos
`let mut guess = String::new()`, Rust foi capaz de inferir que `guess` deveria ser
a `String` e não nos fez escrever o tipo. O `secret_number`, por outro
mão, é um tipo de número. Alguns dos tipos de números do Rust podem ter um valor entre 1
e 100: `i32`, um número de 32 bits; `u32`, um número não assinado de 32 bits; `i64`, um
Número de 64 bits; bem como outros. A menos que especificado de outra forma, o padrão do Rust é
um `i32`, que é o tipo de `secret_number`, a menos que você adicione informações de tipo
em outro lugar isso faria com que Rust inferisse um tipo numérico diferente. A razão
pois o erro é que Rust não pode comparar uma string e um tipo de número.

Em última análise, queremos converter o `String` que o programa lê como entrada em um
tipo de número para que possamos compará-lo numericamente com o número secreto. Nós fazemos
então, adicionando esta linha ao corpo da função `main`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-03-convert-string-to-number/src/main.rs:here}}
```

A linha é:

```rust,ignore
let guess: u32 = guess.trim().parse().expect("Please type a number!");
```

Criamos uma variável chamada `guess`. Mas espere, o programa já não tem
uma variável chamada `guess`? Sim, mas de forma útil Rust nos permite obscurecer o
valor anterior de `guess` por um novo. _Shadowing_ nos permite reutilizar o `guess`
nome da variável em vez de nos forçar a criar duas variáveis ​​únicas, como
`guess_str` e `guess`, por exemplo. Abordaremos isso com mais detalhes em
[Capítulo 3][shadowing]<!-- ignore -->, mas por enquanto, saiba que esse recurso é
frequentemente usado quando você deseja converter um valor de um tipo para outro.

Vinculamos esta nova variável à expressão `guess.trim().parse()`. O `guess`
na expressão refere-se à variável `guess` original que continha o
entrada como uma string. O método `trim` em uma instância `String` eliminará qualquer
espaço em branco no início e no final, o que devemos fazer antes de podermos converter o
string para um `u32`, que só pode conter dados numéricos. O usuário deve pressionar
<kbd>enter</kbd> para satisfazer `read_line` e inserir seu palpite, o que adiciona um
caractere de nova linha para a string. Por exemplo, se o usuário digitar <kbd>5</kbd> e
pressiona <kbd>enter</kbd>, `guess` fica assim: `5\n`. O `\n` representa
“nova linha.” (No Windows, pressionar <kbd>enter</kbd> resulta em um retorno de carro
e uma nova linha, `\r\n`.) O método `trim` elimina `\n` ou `\r\n`, resultando
em apenas `5`.

O método [`parse` em strings][parse]<!-- ignore --> converte uma string em
outro tipo. Aqui, nós o usamos para converter de uma string em um número. Precisamos
diga ao Rust o tipo exato de número que queremos usando `let guess: u32`. O cólon
(`:`) depois que `guess` disser a Rust que anotaremos o tipo da variável. A ferrugem tem um
poucos tipos de números integrados; o `u32` visto aqui é um número inteiro não assinado de 32 bits.
É uma boa escolha padrão para um pequeno número positivo. Você aprenderá sobre
outros tipos de números no [Capítulo 3][integers]<!-- ignore -->.

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
listagens de cd/ch02-guessing-game-tutorial/no-listing-03-convert-string-to-number/
toque em src/main.rs
corrida de carga
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

Legal! Mesmo que espaços tenham sido adicionados antes da estimativa, o programa ainda calculou
descobrir que o usuário acertou 76. Execute o programa algumas vezes para verificar o
comportamento diferente com diferentes tipos de entrada: Adivinhe o número corretamente,
adivinhe um número muito alto e adivinhe um número muito baixo.

Temos a maior parte do jogo funcionando agora, mas o usuário só pode dar um palpite.
Vamos mudar isso adicionando um loop!

## Permitindo múltiplas suposições com looping

A palavra-chave `loop` cria um loop infinito. Adicionaremos um loop para oferecer aos usuários
mais chances de adivinhar o número:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-04-looping/src/main.rs:here}}
```

Como você pode ver, movemos tudo, desde o prompt de entrada de estimativa em diante, para
um laço. Certifique-se de recuar as linhas dentro do loop em mais quatro espaços cada
e execute o programa novamente. O programa agora pedirá outro palpite para sempre,
o que na verdade introduz um novo problema. Não parece que o usuário pode sair!

O usuário sempre pode interromper o programa usando o atalho do teclado
<kbd>ctrl</kbd>-<kbd>C</kbd>. Mas há outra maneira de escapar desta insaciável
monstro, conforme mencionado na discussão `parse` em [“Comparando a suposição com o
Número secreto”](#comparando-o-palpite-com-o-número-secreto)<!-- ignore -->: Se
o usuário inserir uma resposta que não seja um número, o programa irá travar. Podemos levar
vantagem disso para permitir que o usuário saia, conforme mostrado aqui:

<!-- manual-regeneration
listagens de cd/ch02-guessing-game-tutorial/no-listing-04-looping/
toque em src/main.rs
corrida de carga
(suposição muito pequena)
(palpite muito grande)
(palpite correto)
desistir
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

Digitar `quit` sairá do jogo, mas como você notará, entrar em qualquer
outra entrada não numérica. Isto não é o ideal, para dizer o mínimo; queremos o jogo
para também parar quando o número correto for adivinhado.

### Desistir após um palpite correto

Vamos programar o jogo para encerrar quando o usuário vencer, adicionando uma instrução `break`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/no-listing-05-quitting/src/main.rs:here}}
```

Adicionar a linha `break` após `You win!` faz o programa sair do loop quando
o usuário adivinha o número secreto corretamente. Sair do loop também significa
saindo do programa, porque o loop é a última parte de `main`.

### Tratamento de entrada inválida

Para refinar ainda mais o comportamento do jogo, em vez de travar o programa quando
o usuário insere um não-número, vamos fazer o jogo ignorar um não-número para que
o usuário pode continuar adivinhando. Podemos fazer isso alterando a linha onde
`guess` é convertido de `String` para `u32`, conforme mostrado na Listagem 2-5.

<Listing number="2-5" file-name="src/main.rs" caption="Ignoring a non-number guess and asking for another guess instead of crashing the program">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-05/src/main.rs:here}}
```

</Listing>

Mudamos de uma chamada `expect` para uma expressão `match` para deixar de travar
em um erro para lidar com o erro. Lembre-se de que `parse` retorna `Result`
type e `Result` é um enum que possui as variantes `Ok` e `Err`. Estamos usando
uma expressão `match` aqui, como fizemos com o resultado `Ordering` de `cmp`
método.

Se `parse` for capaz de transformar a string em um número com sucesso, ele irá
retorne um valor `Ok` que contém o número resultante. Esse valor `Ok` será
corresponda ao padrão do primeiro braço, e a expressão `match` retornará apenas o
`num` valor que `parse` produziu e colocou dentro do valor `Ok`. Esse número
terminará exatamente onde queremos na nova variável `guess` que estamos criando.

Se `parse` _não_ for capaz de transformar a string em um número, ele retornará um
`Err` valor que contém mais informações sobre o erro. O valor `Err`
não corresponde ao padrão `Ok(num)` no primeiro braço `match`, mas corresponde
combine com o padrão `Err(_)` no segundo braço. O sublinhado, `_`, é um
valor abrangente; neste exemplo, estamos dizendo que queremos corresponder todos `Err`
valores, não importa quais informações eles tenham dentro deles. Então, o programa irá
execute o código do segundo braço, `continue`, que diz ao programa para ir para o
próxima iteração do `loop` e peça outro palpite. Então, efetivamente, o
o programa ignora todos os erros que `parse` possa encontrar!

Agora tudo no programa deve funcionar conforme o esperado. Vamos tentar:

<!-- manual-regeneration
listagens de cd/ch02-guessing-game-tutorial/listing-02-05/
corrida de carga
(suposição muito pequena)
(palpite muito grande)
foo
(palpite correto)
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

Incrível! Com um pequeno ajuste final, terminaremos o jogo de adivinhação. Lembrar
que o programa ainda está imprimindo o número secreto. Isso funcionou bem para
testando, mas estraga o jogo. Vamos deletar o `println!` que gera o
número secreto. A Listagem 2-6 mostra o código final.

<Listing number="2-6" file-name="src/main.rs" caption="Complete guessing game code">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-06/src/main.rs}}
```

</Listing>

Neste ponto, você construiu com sucesso o jogo de adivinhação. Parabéns!

## Resumo

Este projeto foi uma forma prática de apresentar muitos novos conceitos do Rust:
`let`, `match`, funções, uso de caixas externas e muito mais. No próximo
poucos capítulos, você aprenderá sobre esses conceitos com mais detalhes. Capítulo 3
cobre conceitos que a maioria das linguagens de programação possui, como variáveis, dados
tipos e funções, e mostra como usá-los no Rust. O Capítulo 4 explora
propriedade, um recurso que torna o Rust diferente de outras linguagens. Capítulo 5
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
