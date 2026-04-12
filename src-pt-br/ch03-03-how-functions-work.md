## Funções

Funções são onipresentes em código Rust. Você já viu uma das funções mais
importantes da linguagem: a função `main`, que é o ponto de entrada de muitos
programas. Você também já viu a palavra-chave `fn`, que permite declarar novas
funções.

Código Rust usa _snake case_ como estilo convencional para nomes de funções e
variáveis, em que todas as letras ficam em minúsculas e as palavras são
separadas por sublinhados. Aqui está um programa que contém um exemplo de
definição de função:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-16-functions/src/main.rs}}
```

Definimos uma função em Rust digitando `fn`, seguido pelo nome da função e por
um conjunto de parênteses. As chaves informam ao compilador onde o corpo da
função começa e termina.

Podemos chamar qualquer função que tenhamos definido digitando seu nome seguido
por um conjunto de parênteses. Como `another_function` está definida no
programa, ela pode ser chamada de dentro da função `main`. Observe que
definimos `another_function` _depois_ da função `main` no código-fonte; também
poderíamos tê-la definido antes. Rust não se importa com o lugar em que você
define suas funções, apenas com o fato de elas estarem definidas em algum
escopo visível para quem as chama.

Vamos iniciar um novo projeto binário chamado _functions_ para explorar melhor
as funções. Coloque o exemplo `another_function` em _src/main.rs_ e execute-o.
Você deverá ver a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-16-functions/output.txt}}
```

As linhas são executadas na ordem em que aparecem na função `main`. Primeiro, a
mensagem “Hello, world!” é impressa; depois, `another_function` é chamada e sua
mensagem é impressa.

### Parâmetros

Podemos definir funções com _parâmetros_, que são variáveis especiais que
fazem parte da assinatura de uma função. Quando uma função tem parâmetros, você
pode fornecer valores concretos para eles. Tecnicamente, esses valores
concretos são chamados de _argumentos_, mas, em conversas casuais, as pessoas
tendem a usar as palavras _parâmetro_ e _argumento_ de forma intercambiável,
tanto para as variáveis na definição da função quanto para os valores concretos
passados quando você chama a função.

Nesta versão de `another_function`, adicionamos um parâmetro:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-17-functions-with-parameters/src/main.rs}}
```

Tente executar este programa; você deve obter a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-17-functions-with-parameters/output.txt}}
```

A declaração de `another_function` tem um parâmetro chamado `x`. O tipo de `x`
é especificado como `i32`. Quando passamos `5` para `another_function`, a
macro `println!` coloca `5` no lugar do par de chaves que continha `x` na
string de formatação.

Nas assinaturas de funções, você _deve_ declarar o tipo de cada parâmetro. Essa
é uma decisão deliberada no design de Rust: exigir anotações de tipo em
definições de função significa que o compilador quase nunca precisa que você as
use em outras partes do código para descobrir a que tipo você está se
referindo. O compilador também consegue fornecer mensagens de erro mais úteis
se souber quais tipos a função espera.

Ao definir vários parâmetros, separe suas declarações com vírgulas, assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-18-functions-with-multiple-parameters/src/main.rs}}
```

Este exemplo cria uma função chamada `print_labeled_measurement` com dois
parâmetros. O primeiro se chama `value` e é um `i32`. O segundo se chama
`unit_label` e tem tipo `char`. A função então imprime um texto contendo tanto
`value` quanto `unit_label`.

Vamos experimentar esse código. Substitua o programa atual do arquivo
_src/main.rs_ do projeto _functions_ pelo exemplo anterior e execute-o com
`cargo run`:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-18-functions-with-multiple-parameters/output.txt}}
```

Como chamamos a função com `5` como valor de `value` e `'h'` como valor de
`unit_label`, a saída do programa contém esses valores.

### Instruções e expressões

Corpos de funções são compostos por uma série de instruções, opcionalmente
terminando com uma expressão. Até agora, as funções que vimos não incluíam uma
expressão final, mas você já viu uma expressão como parte de uma instrução.
Como Rust é uma linguagem baseada em expressões, essa é uma distinção
importante de entender. Outras linguagens não fazem exatamente a mesma
distinção, então vamos examinar o que são instruções e expressões e como suas
diferenças afetam os corpos das funções.

- _Instruções_ são comandos que executam alguma ação e não retornam um valor.
- _Expressões_ são avaliadas para produzir um valor resultante.

Vejamos alguns exemplos.

Na verdade, já usamos instruções e expressões. Criar uma variável e atribuir um
valor a ela com a palavra-chave `let` é uma instrução. Na Listagem 3-1,
`let y = 6;` é uma instrução.

<Listing number="3-1" file-name="src/main.rs" caption="Uma declaração da função `main` contendo uma instrução">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-01/src/main.rs}}
```

</Listing>

Definições de funções também são instruções; o exemplo inteiro anterior é, por
si só, uma instrução. Como veremos em breve, chamar uma função não é uma
instrução.

Instruções não retornam valores. Portanto, você não pode atribuir uma
instrução `let` a outra variável, como o código a seguir tenta fazer; você
receberá um erro:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-19-statements-vs-expressions/src/main.rs}}
```

Ao executar esse programa, o erro obtido será parecido com este:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-19-statements-vs-expressions/output.txt}}
```

A instrução `let y = 6` não retorna valor algum, então não existe nada ao qual
`x` possa se vincular. Isso é diferente do que acontece em outras linguagens,
como C e Ruby, em que a atribuição retorna o valor atribuído. Nessas
linguagens, você pode escrever `x = y = 6` e fazer com que tanto `x` quanto
`y` tenham o valor `6`; em Rust, não é assim.

Expressões produzem um valor e constituem a maior parte do restante do código
que você escreverá em Rust. Considere uma operação matemática como `5 + 6`,
que é uma expressão avaliada para o valor `11`. Expressões podem fazer parte de
instruções: na Listagem 3-1, o `6` na instrução `let y = 6;` é uma expressão
avaliada para o valor `6`. Chamar uma função é uma expressão. Chamar uma macro
é uma expressão. Um novo bloco de escopo criado com chaves também é uma
expressão, por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-20-blocks-are-expressions/src/main.rs}}
```

Esta expressão:

```rust,ignore
{
    let x = 3;
    x + 1
}
```

é um bloco que, neste caso, é avaliado como `4`. Esse valor é vinculado a `y`
como parte da instrução `let`. Observe a linha `x + 1` sem ponto e vírgula no
final, o que é diferente da maior parte das linhas que você viu até agora.
Expressões não incluem ponto e vírgula ao final. Se você adicionar um ponto e
vírgula ao fim de uma expressão, estará transformando-a em uma instrução, e
ela então deixará de retornar um valor. Tenha isso em mente ao explorar os
valores de retorno de funções e as expressões a seguir.

### Funções com valores de retorno

Funções podem retornar valores para o código que as chama. Não damos nomes aos
valores de retorno, mas precisamos declarar seu tipo após uma seta (`->`). Em
Rust, o valor de retorno da função é sinônimo do valor da expressão final no
bloco do corpo da função. Você pode retornar mais cedo de uma função usando a
palavra-chave `return` e especificando um valor, mas a maioria das funções
retorna a última expressão implicitamente. Aqui está um exemplo de função que
retorna um valor:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-21-function-return-values/src/main.rs}}
```

Não há chamadas de função, macros nem mesmo instruções `let` na função `five`,
apenas o número `5` sozinho. Isso é uma função perfeitamente válida em Rust.
Observe também que o tipo de retorno da função foi especificado como `-> i32`.
Tente executar esse código; a saída deve ser parecida com esta:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-21-function-return-values/output.txt}}
```

O `5` em `five` é o valor de retorno da função, e por isso o tipo de retorno é
`i32`. Vamos examinar isso com mais detalhes. Há dois pontos importantes.
Primeiro, a linha `let x = five();` mostra que estamos usando o valor de
retorno de uma função para inicializar uma variável. Como a função `five`
retorna `5`, essa linha é a mesma coisa que:

```rust
let x = 5;
```

Segundo, a função `five` não tem parâmetros e define o tipo de retorno, mas o
corpo da função é apenas um `5`, sem ponto e vírgula, porque essa é uma
expressão cujo valor queremos retornar.

Vamos ver outro exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-22-function-parameter-and-return/src/main.rs}}
```

Executar esse código imprimirá `The value of x is: 6`. Mas o que acontece se
colocarmos um ponto e vírgula ao final da linha que contém `x + 1`,
transformando-a de expressão em instrução?

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-23-statements-dont-return-values/src/main.rs}}
```

Compilar esse código produzirá um erro, como este:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-23-statements-dont-return-values/output.txt}}
```

A principal mensagem de erro, `mismatched types`, revela o problema central
desse código. A definição da função `plus_one` diz que ela retornará um `i32`,
mas instruções não produzem um valor; isso é expresso por `()`, o tipo unit.
Portanto, nada é retornado, o que contradiz a definição da função e resulta em
erro. Nessa saída, Rust fornece até uma mensagem que pode ajudar a corrigir o
problema: ela sugere remover o ponto e vírgula, o que resolveria o erro.
