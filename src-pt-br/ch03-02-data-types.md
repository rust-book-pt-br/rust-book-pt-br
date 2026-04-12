## Tipos de Dados

Todo valor em Rust tem um certo _tipo de dado_, que informa ao Rust que tipo
de dado está sendo especificado, para que ele saiba como trabalhar com esse
dado. Vamos examinar dois subconjuntos de tipos de dados: escalares e
compostos.

Tenha em mente que Rust é uma linguagem de _tipagem estática_, o que significa
que ela precisa conhecer os tipos de todas as variáveis em tempo de compilação.
Na maior parte do tempo, o compilador consegue inferir qual tipo queremos usar
com base no valor e em como o utilizamos. Nos casos em que muitos tipos são
possíveis, como quando convertemos uma `String` para um tipo numérico usando
`parse` na seção [“Comparando o Palpite com o Número
Secreto”][comparing-the-guess-to-the-secret-number]<!-- ignore --> no Capítulo
2, precisamos adicionar uma anotação de tipo, assim:

```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

Se não adicionarmos a anotação de tipo `: u32` mostrada no código anterior, o
Rust exibirá o erro a seguir, o que significa que o compilador precisa de mais
informações para saber qual tipo queremos usar:

```console
{{#include ../listings/ch03-common-programming-concepts/output-only-01-no-type-annotations/output.txt}}
```

Você verá anotações de tipo diferentes para outros tipos de dados.

### Tipos Escalares

Um tipo _escalar_ representa um único valor. Rust tem quatro tipos escalares
primários: inteiros, números de ponto flutuante, booleanos e caracteres. Você
talvez reconheça esses tipos de outras linguagens de programação. Vamos ver
como eles funcionam em Rust.

#### Tipos Inteiros

Um _inteiro_ é um número sem componente fracionário. Já usamos um tipo inteiro
no Capítulo 2, o tipo `u32`. Essa declaração de tipo indica que o valor a ele
associado deve ser um inteiro sem sinal, pois os tipos inteiros com sinal
começam com `i` em vez de `u`, e que ocupa 32 bits de espaço. A Tabela 3-1
mostra os tipos inteiros embutidos no Rust. Podemos usar qualquer uma dessas
variantes para declarar o tipo de um valor inteiro.

<span class="caption">Tabela 3-1: Tipos Inteiros em Rust</span>

| Tamanho | Com sinal | Sem sinal |
| ------- | --------- | --------- |
| 8-bit   | `i8`      | `u8`      |
| 16-bit  | `i16`     | `u16`     |
| 32-bit  | `i32`     | `u32`     |
| 64-bit  | `i64`     | `u64`     |
| 128-bit | `i128`    | `u128`    |
| Dependente da arquitetura | `isize` | `usize` |

Cada variante pode ser com sinal ou sem sinal e tem um tamanho explícito.
_Com sinal_ e _sem sinal_ se referem a se o número pode ser negativo ou não.
Em outras palavras, se o número precisa carregar um sinal junto consigo, ele é
com sinal; caso contrário, ele é sempre positivo e pode ser representado sem
sinal. É como escrever números no papel: quando o sinal importa, o número é
escrito com um sinal de mais ou de menos; no entanto, quando é seguro assumir
que ele é positivo, ele aparece sem sinal. Números com sinal são armazenados
usando a representação em [complemento de dois][twos-complement]<!-- ignore
-->.

Cada variante com sinal pode armazenar números entre
−(2<sup>n − 1</sup>) e 2<sup>n − 1</sup> − 1, inclusive, em que _n_ é o
número de bits usado por aquela variante. Assim, um `i8` pode armazenar
números entre −(2<sup>7</sup>) e 2<sup>7</sup> − 1, isto é, de −128 a 127.
As variantes sem sinal podem armazenar números entre 0 e 2<sup>n</sup> − 1;
logo, um `u8` pode armazenar números entre 0 e 2<sup>8</sup> − 1, isto é, de
0 a 255.

Além disso, os tipos `isize` e `usize` dependem da arquitetura do computador
em que seu programa está sendo executado: 64 bits em arquiteturas de 64 bits e
32 bits em arquiteturas de 32 bits.

Você pode escrever literais inteiros em qualquer um dos formatos mostrados na
Tabela 3-2. Note que literais numéricos que podem assumir vários tipos aceitam
um sufixo de tipo, como `57u8`, para indicar o tipo. Literais numéricos também
podem usar `_` como separador visual para facilitar a leitura, como em
`1_000`, que tem o mesmo valor de `1000`.

<span class="caption">Tabela 3-2: Literais Inteiros em Rust</span>

| Literais numéricos | Exemplo       |
| ------------------ | ------------- |
| Decimal            | `98_222`      |
| Hexadecimal        | `0xff`        |
| Octal              | `0o77`        |
| Binário            | `0b1111_0000` |
| Byte (`u8` apenas) | `b'A'`        |

Então, como saber qual tipo inteiro usar? Se você estiver em dúvida, os
defaults do Rust geralmente são um bom ponto de partida: tipos inteiros usam
`i32` por padrão. A principal situação em que você usaria `isize` ou `usize`
é ao indexar algum tipo de coleção.

> ##### Overflow de Inteiro
>
> Digamos que você tenha uma variável do tipo `u8` que pode armazenar valores
> entre 0 e 255. Se você tentar mudar a variável para um valor fora desse
> intervalo, como 256, ocorrerá um _integer overflow_, o que pode resultar em
> um de dois comportamentos. Quando você está compilando em modo debug, o Rust
> inclui verificações de overflow de inteiros que fazem o programa _entrar em
> pânico_ em tempo de execução se isso acontecer. O Rust usa o termo
> _panicking_ quando um programa é encerrado com erro; discutiremos pânicos em
> mais profundidade na seção [“Erros Irrecuperáveis com
> `panic!`”][unrecoverable-errors-with-panic]<!-- ignore --> do Capítulo 9.
>
> Quando você está compilando em modo release com a flag `--release`, o Rust
> _não_ inclui verificações de overflow que causem pânico. Em vez disso, se
> ocorrer overflow, o Rust executa o _wrap_ em complemento de dois. Em resumo,
> valores maiores que o máximo que o tipo suporta “dão a volta” e retornam ao
> menor valor que o tipo pode armazenar. No caso de um `u8`, o valor 256 vira
> 0, o valor 257 vira 1 e assim por diante. O programa não entra em pânico,
> mas a variável passa a conter um valor que provavelmente não era o que você
> esperava. Confiar nesse comportamento de wrap em overflow de inteiros é
> considerado um erro.
>
> Para lidar explicitamente com a possibilidade de overflow, você pode usar as
> seguintes famílias de métodos fornecidas pela biblioteca padrão para tipos
> numéricos primitivos:
>
> - Fazer wrap em todos os modos com métodos `wrapping_*`, como
>   `wrapping_add`.
> - Retornar `None` se houver overflow com métodos `checked_*`.
> - Retornar o valor e um booleano indicando se houve overflow com métodos
>   `overflowing_*`.
> - Saturar no valor mínimo ou máximo com métodos `saturating_*`.

#### Tipos de Ponto Flutuante

Rust também tem dois tipos primitivos para _números de ponto flutuante_, que
são números com casas decimais. Os tipos de ponto flutuante do Rust são `f32`
e `f64`, com 32 e 64 bits de tamanho, respectivamente. O tipo padrão é `f64`
porque, em CPUs modernas, ele tem velocidade semelhante à de `f32`, mas é
capaz de representar mais precisão. Todos os tipos de ponto flutuante têm
sinal.

Este é um exemplo mostrando números de ponto flutuante em ação:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-06-floating-point/src/main.rs}}
```

Números de ponto flutuante são representados de acordo com o padrão IEEE-754.

#### Operações Numéricas

Rust oferece suporte às operações matemáticas básicas que você esperaria para
todos os tipos numéricos: adição, subtração, multiplicação, divisão e resto.
A divisão inteira é truncada em direção a zero até o inteiro mais próximo. O
código a seguir mostra como usar cada operação numérica em uma instrução `let`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-07-numeric-operations/src/main.rs}}
```

Cada expressão dessas instruções usa um operador matemático e avalia para um
único valor, que é então vinculado a uma variável. O [Apêndice
B][appendix_b]<!-- ignore --> contém uma lista de todos os operadores
fornecidos pelo Rust.

#### O Tipo Booleano

Como na maioria das outras linguagens de programação, um tipo booleano em Rust
tem dois valores possíveis: `true` e `false`. Booleanos têm tamanho de um
byte. O tipo booleano em Rust é especificado com `bool`. Por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-08-boolean/src/main.rs}}
```

A principal forma de usar valores booleanos é com condicionais, como uma
expressão `if`. Veremos como expressões `if` funcionam em Rust na seção [“Fluxo
de Controle”][control-flow]<!-- ignore -->.

#### O Tipo Caractere

O tipo `char` do Rust é o tipo alfabético mais primitivo da linguagem. Aqui
estão alguns exemplos de declaração de valores `char`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-09-char/src/main.rs}}
```

Observe que especificamos literais `char` com aspas simples, ao contrário de
literais de string, que usam aspas duplas. O tipo `char` do Rust ocupa 4 bytes
e representa um valor escalar Unicode, o que significa que ele pode
representar muito mais do que apenas ASCII. Letras acentuadas, caracteres
chineses, japoneses e coreanos, emojis e espaços de largura zero são todos
valores `char` válidos em Rust. Valores escalares Unicode variam de `U+0000`
até `U+D7FF` e de `U+E000` até `U+10FFFF`, inclusive. No entanto, “caractere”
não é exatamente um conceito do Unicode, então sua intuição humana sobre o que
é um “caractere” pode não corresponder ao que um `char` representa em Rust.
Discutiremos esse tópico em detalhes em [“Armazenando Texto Codificado em
UTF-8 com Strings”][strings]<!-- ignore --> no Capítulo 8.

### Tipos Compostos

Tipos _compostos_ podem agrupar vários valores em um único tipo. Rust tem dois
tipos compostos primitivos: tuplas e arrays.

#### O Tipo Tupla

Uma _tupla_ é uma forma geral de agrupar vários valores de tipos diferentes em
um único tipo composto. Tuplas têm comprimento fixo: uma vez declaradas, não
podem crescer nem encolher.

Criamos uma tupla escrevendo uma lista de valores separados por vírgula entre
parênteses. Cada posição da tupla tem um tipo, e os tipos dos diferentes
valores da tupla não precisam ser iguais. Adicionamos anotações de tipo
opcionais neste exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-10-tuples/src/main.rs}}
```

A variável `tup` se vincula à tupla inteira porque uma tupla é considerada um
único elemento composto. Para obter os valores individuais de uma tupla,
podemos usar correspondência de padrões para desestruturar o valor da tupla,
assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-11-destructuring-tuples/src/main.rs}}
```

Esse programa primeiro cria uma tupla e a vincula à variável `tup`. Depois, ele
usa um padrão com `let` para pegar `tup` e transformá-la em três variáveis
separadas, `x`, `y` e `z`. Isso é chamado de _desestruturação_, porque quebra
a tupla única em três partes. Por fim, o programa imprime o valor de `y`, que
é `6.4`.

Também podemos acessar um elemento da tupla diretamente usando um ponto (`.`)
seguido pelo índice do valor que queremos acessar. Por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-12-tuple-indexing/src/main.rs}}
```

Esse programa cria a tupla `x` e depois acessa cada elemento da tupla usando
seus respectivos índices. Como na maioria das linguagens de programação, o
primeiro índice de uma tupla é 0.

A tupla sem nenhum valor recebe um nome especial: _unit_. Esse valor e seu
tipo correspondente são ambos escritos como `()` e representam um valor vazio
ou um tipo de retorno vazio. Expressões retornam implicitamente o valor unit se
não retornarem nenhum outro valor.

#### O Tipo Array

Outra forma de ter uma coleção de vários valores é com um _array_. Diferente de
uma tupla, todo elemento de um array precisa ter o mesmo tipo. E, diferente dos
arrays em algumas outras linguagens, arrays em Rust têm comprimento fixo.

Escrevemos os valores de um array como uma lista separada por vírgulas entre
colchetes:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-13-arrays/src/main.rs}}
```

Arrays são úteis quando você quer que os dados sejam alocados na pilha, como os
outros tipos que vimos até aqui, em vez de no heap, assunto que discutiremos
mais no [Capítulo 4][stack-and-heap]<!-- ignore -->, ou quando quer garantir
que sempre terá um número fixo de elementos. No entanto, arrays não são tão
flexíveis quanto o tipo vetor. Um vetor é um tipo de coleção semelhante,
fornecido pela biblioteca padrão, que _pode_ crescer ou encolher porque seu
conteúdo vive no heap. Se você estiver em dúvida entre usar um array ou um
vetor, é bem provável que deva usar um vetor. O [Capítulo 8][vectors]<!--
ignore --> discute vetores com mais detalhes.

Ainda assim, arrays são mais úteis quando você sabe que o número de elementos
não precisará mudar. Por exemplo, se você estivesse usando os nomes dos meses
em um programa, provavelmente usaria um array em vez de um vetor, porque sabe
que sempre haverá 12 elementos:

```rust
let months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];
```

Você escreve o tipo de um array usando colchetes com o tipo de cada elemento,
um ponto e vírgula e, em seguida, o número de elementos do array, assim:

```rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

Aqui, `i32` é o tipo de cada elemento. Depois do ponto e vírgula, o número `5`
indica que o array contém cinco elementos.

Você também pode inicializar um array para que todos os elementos tenham o
mesmo valor especificando o valor inicial, seguido de um ponto e vírgula, e
então o comprimento do array entre colchetes, como aqui:

```rust
let a = [3; 5];
```

O array chamado `a` conterá `5` elementos, todos inicialmente definidos com o
valor `3`. Isso é o mesmo que escrever `let a = [3, 3, 3, 3, 3];`, mas de uma
forma mais concisa.

<!-- Old headings. Do not remove or links may break. -->
<a id="accessing-array-elements"></a>

#### Acesso a Elementos de Array

Um array é um único bloco de memória de tamanho conhecido e fixo, que pode ser
alocado na pilha. Você pode acessar elementos de um array usando indexação,
assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-14-array-indexing/src/main.rs}}
```

Neste exemplo, a variável chamada `first` receberá o valor `1` porque esse é o
valor no índice `[0]` do array. A variável chamada `second` receberá o valor
`2` do índice `[1]` do array.

#### Acesso Inválido a Elemento de Array

Vamos ver o que acontece se você tentar acessar um elemento de um array que
está além do seu final. Digamos que você execute este código, semelhante ao
jogo de adivinhação do Capítulo 2, para obter do usuário um índice de array:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,panics
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-15-invalid-array-access/src/main.rs}}
```

Esse código compila com sucesso. Se você o executar com `cargo run` e digitar
`0`, `1`, `2`, `3` ou `4`, o programa imprimirá o valor correspondente naquele
índice do array. Mas, se em vez disso você digitar um número além do final do
array, como `10`, verá uma saída assim:

<!-- manual-regeneration
cd listings/ch03-common-programming-concepts/no-listing-15-invalid-array-access
cargo run
10
-->

```console
thread 'main' panicked at src/main.rs:19:19:
index out of bounds: the len is 5 but the index is 10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

O programa produziu um erro em tempo de execução no ponto em que tentou usar
um valor inválido na operação de indexação. O programa foi encerrado com uma
mensagem de erro e não executou a instrução final `println!`. Quando você tenta
acessar um elemento usando indexação, o Rust verifica se o índice especificado
é menor que o comprimento do array. Se o índice for maior ou igual ao
comprimento, o Rust entra em pânico. Essa verificação precisa acontecer em
tempo de execução, especialmente neste caso, porque o compilador não tem como
saber qual valor um usuário digitará quando executar o código depois.

Esse é um exemplo dos princípios de segurança de memória do Rust em ação. Em
muitas linguagens de baixo nível, esse tipo de verificação não é feito e,
quando você fornece um índice incorreto, memória inválida pode ser acessada. O
Rust protege você contra esse tipo de erro saindo imediatamente, em vez de
permitir o acesso à memória e continuar. O Capítulo 9 discute mais sobre o
tratamento de erros em Rust e sobre como escrever código legível e seguro, que
nem entre em pânico nem permita acessos inválidos à memória.

[comparing-the-guess-to-the-secret-number]: ch02-00-guessing-game-tutorial.html#comparing-the-guess-to-the-secret-number
[twos-complement]: https://en.wikipedia.org/wiki/Two%27s_complement
[control-flow]: ch03-05-control-flow.html#control-flow
[strings]: ch08-02-strings.html#storing-utf-8-encoded-text-with-strings
[stack-and-heap]: ch04-01-what-is-ownership.html#the-stack-and-the-heap
[vectors]: ch08-01-vectors.html
[unrecoverable-errors-with-panic]: ch09-01-unrecoverable-errors-with-panic.html
[appendix_b]: appendix-02-operators.md
