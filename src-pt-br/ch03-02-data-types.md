## Tipos de dados

Cada valor em Rust é de um certo _tipo de dados_, que informa ao Rust que tipo de
os dados estão sendo especificados para que ele saiba como trabalhar com esses dados. Nós vamos olhar
em dois subconjuntos de tipos de dados: escalar e composto.

Tenha em mente que Rust é uma linguagem _estaticamente digitada_, o que significa que
deve conhecer os tipos de todas as variáveis ​​em tempo de compilação. O compilador geralmente pode
inferir que tipo queremos usar com base no valor e como o usamos. Nos casos
quando muitos tipos são possíveis, como quando convertemos um `String` em um numérico
digite usando `parse` no [“Comparando a suposição com o segredo
Número”][comparing-the-guess-to-the-secret-number]<!-- ignore --> seção em
Capítulo 2, devemos adicionar uma anotação de tipo, como esta:

```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

Se não adicionarmos a anotação de tipo `: u32` mostrada no código anterior, Rust
exibirá o seguinte erro, o que significa que o compilador precisa de mais
informações nossas para saber qual tipo queremos usar:

```console
{{#include ../listings/ch03-common-programming-concepts/output-only-01-no-type-annotations/output.txt}}
```

Você verá anotações de tipo diferentes para outros tipos de dados.

### Tipos escalares

Um tipo _scalar_ representa um único valor. Rust tem quatro tipos escalares principais:
inteiros, números de ponto flutuante, booleanos e caracteres. Você pode reconhecer
estes de outras linguagens de programação. Vamos ver como eles funcionam no Rust.

#### Tipos inteiros

Um _inteiro_ é um número sem componente fracionário. Usamos um número inteiro
digite no Capítulo 2, o tipo `u32`. Esta declaração de tipo indica que o
o valor ao qual está associado deve ser um número inteiro sem sinal (tipos inteiros com sinal
comece com `i` em vez de `u`) que ocupa 32 bits de espaço. A Tabela 3-1 mostra
os tipos inteiros integrados no Rust. Podemos usar qualquer uma dessas variantes para declarar
o tipo de um valor inteiro.

<span class="caption">Tabela 3-1: Tipos inteiros em Rust</span>

| Comprimento| Assinado| Não assinado|
| ------- | ------- | -------- |
| 8 bits| `i8`    | `u8`     |
| 16 bits| `i16`   | `u16`    |
| 32 bits| `i32`   | `u32`    |
| 64 bits| `i64`   | `u64`    |
| 128 bits| `i128`  | `u128`   |
| Dependente da arquitetura| `isize` | `usize`  |

Cada variante pode ser assinada ou não assinada e possui um tamanho explícito.
_Assinado_ e _não assinado_ referem-se a se é possível que o número seja
negativo - em outras palavras, se o número precisa ter um sinal com ele
(assinado) ou se só será positivo e pode, portanto, ser
representado sem sinal (sem sinal). É como escrever números no papel: quando
o sinal é importante, um número é mostrado com um sinal de mais ou de menos; no entanto,
quando é seguro presumir que o número é positivo, ele é mostrado sem sinal.
Os números assinados são armazenados usando [complemento de dois][twos-complement]<!-- ignore
-> representação.

Cada variante assinada pode armazenar números de −(2<sup>n − 1</sup>) a 2<sup>n −
1</sup> − 1 inclusive, onde _n_ é o número de bits que a variante usa. Então, um
`i8` pode armazenar números de −(2<sup>7</sup>) a 2<sup>7</sup> − 1, que é igual
−128 a 127. Variantes não assinadas podem armazenar números de 0 a 2<sup>n</sup> − 1,
então `u8` pode armazenar números de 0 a 2<sup>8</sup> − 1, que é igual a 0 a 255.

Além disso, os tipos `isize` e `usize` dependem da arquitetura do
computador em que seu programa está sendo executado: 64 bits se você estiver em uma arquitetura de 64 bits
e 32 bits se você estiver em uma arquitetura de 32 bits.

Você pode escrever literais inteiros em qualquer uma das formas mostradas na Tabela 3-2. Observação
que literais numéricos que podem ser vários tipos numéricos permitem um sufixo de tipo,
como `57u8`, para designar o tipo. Literais numéricos também podem usar `_` como
separador visual para facilitar a leitura do número, como `1_000`, que irá
tem o mesmo valor como se você tivesse especificado `1000`.

<span class="caption">Tabela 3-2: Literais inteiros em Rust</span>

| Literais numéricos| Exemplo|
| ---------------- | ------------- |
| Decimal| `98_222`      |
| Feitiço| `0xff`        |
| octal| `0o77`        |
| Binário| `0b1111_0000` |
| Byte (`u8` apenas)| `b'A'`        |

Então, como você sabe que tipo de número inteiro usar? Se você não tiver certeza, Rust's
os padrões geralmente são bons lugares para começar: os tipos inteiros são padronizados como `i32`.
A principal situação em que você usaria `isize` ou `usize` é ao indexar
algum tipo de coleção.

> ##### Estouro de número inteiro
>
> Digamos que você tenha uma variável do tipo `u8` que pode conter valores entre 0 e
> 255. Se você tentar alterar a variável para um valor fora desse intervalo, como
> 256, ocorrerá _overflow de número inteiro_, o que pode resultar em um de dois comportamentos.
> Quando você está compilando no modo de depuração, Rust inclui verificações de estouro de número inteiro
> que fazem com que seu programa _entre em pânico_ em tempo de execução se esse comportamento ocorrer. Ferrugem
> usa o termo _entrar em pânico_ quando um programa é encerrado com um erro; vamos discutir
> entra em pânico com mais profundidade em [“Erros Irrecuperáveis ​​com
> `panic!`”][unrecoverable-errors-with-panic]<!-- ignore --> seção no capítulo
> 9.
>
> Quando você está compilando no modo de lançamento com o sinalizador `--release`, Rust faz
> _não_ inclui verificações de estouro de número inteiro que causa pânico. Em vez disso, se
> ocorre overflow, Rust executa _envolvimento de complemento de dois_. Em suma, valores
> maior que o valor máximo que o tipo pode conter “envolver” ao mínimo
> dos valores que o tipo pode conter. No caso de `u8`, o valor 256 torna-se
> 0, o valor 257 torna-se 1 e assim por diante. O programa não entrará em pânico, mas o
> variável terá um valor que provavelmente não é o que você esperava
> ter. Confiar no comportamento de encapsulamento do estouro de número inteiro é considerado um erro.
>
> Para lidar explicitamente com a possibilidade de estouro, você pode usar estas famílias
> de métodos fornecidos pela biblioteca padrão para tipos numéricos primitivos:
>
> - Envolva todos os modos com os métodos `wrapping_*`, como `wrapping_add`.
> - Retorne o valor `None` se houver overflow com os métodos `checked_*`.
> - Retorna o valor e um booleano indicando se houve overflow com
>   os métodos `overflowing_*`.
> - Saturar nos valores mínimo ou máximo do valor com `saturating_*`
>   métodos.

#### Tipos de ponto flutuante

Rust também tem dois tipos primitivos para _números de ponto flutuante_, que são
números com casas decimais. Os tipos de ponto flutuante do Rust são `f32` e `f64`,
que têm tamanho de 32 bits e 64 bits, respectivamente. O tipo padrão é `f64`
porque em CPUs modernas, tem aproximadamente a mesma velocidade que `f32`, mas é capaz de
mais precisão. Todos os tipos de ponto flutuante são assinados.

Aqui está um exemplo que mostra números de ponto flutuante em ação:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-06-floating-point/src/main.rs}}
```

Os números de ponto flutuante são representados de acordo com o padrão IEEE-754.

#### Operações Numéricas

Rust suporta as operações matemáticas básicas que você esperaria para todos os números
tipos: adição, subtração, multiplicação, divisão e resto. Inteiro
a divisão trunca em direção a zero para o número inteiro mais próximo. O código a seguir mostra
como você usaria cada operação numérica em uma instrução `let`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-07-numeric-operations/src/main.rs}}
```

Cada expressão nessas declarações usa um operador matemático e avalia
a um único valor, que é então vinculado a uma variável. [Apêndice
B][appendix_b]<!-- ignore --> contém uma lista de todos os operadores que Rust
fornece.

#### O tipo booleano

Como na maioria das outras linguagens de programação, um tipo booleano em Rust tem duas possibilidades
valores: `true` e `false`. Booleanos têm um byte de tamanho. O tipo booleano em
A ferrugem é especificada usando `bool`. Por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-08-boolean/src/main.rs}}
```

A principal maneira de usar valores booleanos é através de condicionais, como `if`
expressão. Abordaremos como as expressões `if` funcionam em Rust na seção [“Control
Fluxo”][control-flow]<!-- ignore --> seção.

#### O tipo de personagem

O tipo `char` de Rust é o tipo alfabético mais primitivo da linguagem. Aqui estão
alguns exemplos de declaração de valores `char`:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-09-char/src/main.rs}}
```

Observe que especificamos literais `char` com aspas simples, em vez de
literais de string, que usam aspas duplas. O tipo `char` de Rust é 4
bytes de tamanho e representa um valor escalar Unicode, o que significa que pode
representam muito mais do que apenas ASCII. Letras acentuadas; chineses, japoneses e
Caracteres coreanos; emoticons; e espaços de largura zero são todos valores `char` válidos em
Ferrugem. Os valores escalares Unicode variam de `U+0000` a `U+D7FF` e `U+E000` a
`U+10FFFF` inclusive. No entanto, um “caractere” não é realmente um conceito em Unicode,
então sua intuição humana sobre o que é um “personagem” pode não corresponder ao que é um
`char` está em ferrugem. Discutiremos este tópico em detalhes em [“Armazenando UTF-8
Texto codificado com strings”][strings]<!-- ignore --> no Capítulo 8.

### Tipos compostos

_Tipos compostos_ podem agrupar vários valores em um tipo. A ferrugem tem dois
tipos compostos primitivos: tuplas e matrizes.

#### O tipo de tupla

Uma _tupla_ é uma maneira geral de agrupar uma série de valores com um
variedade de tipos em um tipo composto. Tuplas têm comprimento fixo: Uma vez
declarado, eles não podem aumentar ou diminuir de tamanho.

Criamos uma tupla escrevendo uma lista de valores separados por vírgula dentro
parênteses. Cada posição na tupla possui um tipo, e os tipos da tupla
valores diferentes na tupla não precisam ser iguais. Adicionamos opcional
digite anotações neste exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-10-tuples/src/main.rs}}
```

A variável `tup` se liga à tupla inteira porque uma tupla é considerada um
único elemento composto. Para obter os valores individuais de uma tupla, podemos
use correspondência de padrões para desestruturar um valor de tupla, assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-11-destructuring-tuples/src/main.rs}}
```

Este programa primeiro cria uma tupla e a vincula à variável `tup`. Então
usa um padrão com `let` para pegar `tup` e transformá-lo em três
variáveis, `x`, `y` e `z`. Isso é chamado de _desestruturação_ porque quebra
a única tupla em três partes. Finalmente, o programa imprime o valor de
`y`, que é `6.4`.

Também podemos acessar um elemento de tupla diretamente usando um ponto (`.`) seguido por
o índice do valor que queremos acessar. Por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-12-tuple-indexing/src/main.rs}}
```

Este programa cria a tupla `x` e então acessa cada elemento da tupla
usando seus respectivos índices. Tal como acontece com a maioria das linguagens de programação, o primeiro
o índice em uma tupla é 0.

A tupla sem nenhum valor tem um nome especial, _unit_. Este valor e seu
tipo correspondente são escritos `()` e representam um valor vazio ou um
tipo de retorno vazio. As expressões retornam implicitamente o valor unitário se não o fizerem
retornar qualquer outro valor.

#### O tipo de matriz

Outra maneira de ter uma coleção de vários valores é com um _array_. Diferente
uma tupla, cada elemento de uma matriz deve ter o mesmo tipo. Ao contrário das matrizes em
em algumas outras linguagens, os arrays em Rust têm um comprimento fixo.

Escrevemos os valores em uma matriz como uma lista separada por vírgulas dentro de um quadrado
colchetes:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-13-arrays/src/main.rs}}
```

Arrays são úteis quando você deseja que seus dados sejam alocados na pilha, da mesma forma que
os outros tipos que vimos até agora, em vez do heap (discutiremos o
pilha e mais heap no [Capítulo 4][stack-and-heap]<!-- ignore -->) ou quando
você deseja garantir que sempre terá um número fixo de elementos. Uma matriz
não é tão flexível quanto o tipo vetorial. Um vetor é uma coleção semelhante
tipo fornecido pela biblioteca padrão que _tem_ permissão para aumentar ou diminuir
size porque seu conteúdo reside no heap. Se você não tiver certeza se deve usar um
array ou um vetor, é provável que você deva usar um vetor. [Capítulo
8][vectors]<!-- ignore --> discute vetores com mais detalhes.

No entanto, arrays são mais úteis quando você sabe que o número de elementos não será
precisa mudar. Por exemplo, se você estivesse usando os nomes do mês em um
programa, você provavelmente usaria um array em vez de um vetor porque você sabe
sempre conterá 12 elementos:

```rust
let months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];
```

Você escreve o tipo de um array usando colchetes com o tipo de cada elemento,
um ponto e vírgula e, em seguida, o número de elementos na matriz, assim:

```rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

Aqui, `i32` é o tipo de cada elemento. Após o ponto e vírgula, o número `5`
indica que a matriz contém cinco elementos.

Você também pode inicializar um array para conter o mesmo valor para cada elemento,
especificando o valor inicial, seguido por um ponto e vírgula e, em seguida, o comprimento de
a matriz entre colchetes, conforme mostrado aqui:

```rust
let a = [3; 5];
```

A matriz chamada `a` conterá elementos `5` que serão todos definidos com o valor
`3` inicialmente. Isto é o mesmo que escrever `let a = [3, 3, 3, 3, 3];` mas em um
forma mais concisa.

<!-- Old headings. Do not remove or links may break. -->
<a id="accessing-array-elements"></a>

#### Acesso ao elemento da matriz

Um array é um único pedaço de memória de tamanho fixo e conhecido que pode ser
alocado na pilha. Você pode acessar elementos de um array usando indexação,
assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-14-array-indexing/src/main.rs}}
```

Neste exemplo, a variável chamada `first` receberá o valor `1` porque isso
é o valor no índice `[0]` na matriz. A variável chamada `second` receberá
o valor `2` do índice `[1]` na matriz.

#### Acesso inválido ao elemento da matriz

Vamos ver o que acontece se você tentar acessar um elemento de um array que já passou
o final da matriz. Digamos que você execute este código, semelhante ao jogo de adivinhação em
Capítulo 2, para obter um índice de array do usuário:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,panics
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-15-invalid-array-access/src/main.rs}}
```

Este código é compilado com sucesso. Se você executar este código usando `cargo run` e
digite `0`, `1`, `2`, `3` ou `4`, o programa imprimirá o correspondente
valor nesse índice na matriz. Se, em vez disso, você inserir um número após o final de
a matriz, como `10`, você verá uma saída como esta:

<!-- manual-regeneration
listagens de cd/ch03-common-programming-concepts/no-listing-15-invalid-array-access
corrida de carga
10
-->

```console
thread 'main' panicked at src/main.rs:19:19:
index out of bounds: the len is 5 but the index is 10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

O programa resultou em um erro de tempo de execução no momento de usar um arquivo inválido
valor na operação de indexação. O programa foi encerrado com uma mensagem de erro e
não executou a instrução `println!` final. Quando você tenta acessar um
elemento usando indexação, Rust verificará se o índice que você especificou é menor
do que o comprimento da matriz. Se o índice for maior ou igual ao comprimento,
A ferrugem entrará em pânico. Esta verificação deve acontecer em tempo de execução, especialmente neste caso,
porque o compilador não pode saber qual valor um usuário inserirá quando
execute o código mais tarde.

Este é um exemplo dos princípios de segurança de memória do Rust em ação. Em muitos
linguagens de baixo nível, esse tipo de verificação não é feita, e quando você fornece um
índice incorreto, memória inválida pode ser acessada. A ferrugem protege você contra isso
tipo de erro ao sair imediatamente em vez de permitir o acesso à memória e
continuando. O Capítulo 9 discute mais sobre o tratamento de erros do Rust e como você pode
escreva código legível e seguro que não entre em pânico nem permita acesso inválido à memória.

[comparing-the-guess-to-the-secret-number]: ch02-00-guessing-game-tutorial.html#comparing-the-guess-to-the-secret-number
[twos-complement]: https://en.wikipedia.org/wiki/Two%27s_complement
[control-flow]: ch03-05-control-flow.html#control-flow
[strings]: ch08-02-strings.html#storing-utf-8-encoded-text-with-strings
[stack-and-heap]: ch04-01-what-is-ownership.html#the-stack-and-the-heap
[vectors]: ch08-01-vectors.html
[unrecoverable-errors-with-panic]: ch09-01-unrecoverable-errors-with-panic.html
[appendix_b]: appendix-02-operators.md
