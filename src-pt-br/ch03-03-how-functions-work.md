## Funções

As funções são predominantes no código Rust. Você já viu um dos mais
funções importantes na linguagem: a função `main`, que é a entrada
ponto de muitos programas. Você também viu a palavra-chave `fn`, que permite
declarar novas funções.

O código Rust usa _snake case_ como estilo convencional para função e variável
nomes, em que todas as letras são minúsculas e sublinham palavras separadas.
Aqui está um programa que contém um exemplo de definição de função:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-16-functions/src/main.rs}}
```

Definimos uma função em Rust digitando `fn` seguido por um nome de função e um
conjunto de parênteses. As chaves informam ao compilador onde a função
corpo começa e termina.

Podemos chamar qualquer função que definimos digitando seu nome seguido por um conjunto
de parênteses. Como `another_function` está definido no programa, pode ser
chamado de dentro da função `main`. Observe que definimos `another_function`
_depois_ da função `main` no código-fonte; poderíamos ter definido isso antes
também. Rust não se importa onde você define suas funções, apenas se elas estão
definido em algum lugar em um escopo que pode ser visto pelo chamador.

Vamos iniciar um novo projeto binário chamado _functions_ para explorar funções
avançar. Coloque o exemplo `another_function` em _src/main.rs_ e execute-o. Você
deverá ver a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-16-functions/output.txt}}
```

As linhas são executadas na ordem em que aparecem na função `main`.
Primeiro o “Olá, mundo!” a mensagem é impressa e então `another_function` é chamado
e sua mensagem é impressa.

### Parâmetros

Podemos definir funções para terem _parâmetros_, que são variáveis ​​especiais que
fazem parte da assinatura de uma função. Quando uma função tem parâmetros, você pode
forneça valores concretos para esses parâmetros. Tecnicamente, o concreto
valores são chamados de _argumentos_, mas em conversas casuais, as pessoas tendem a usar
as palavras _parâmetro_ e _argumento_ alternadamente para as variáveis
na definição de uma função ou nos valores concretos passados ​​quando você chama um
função.

Nesta versão de `another_function` adicionamos um parâmetro:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-17-functions-with-parameters/src/main.rs}}
```

Tente executar este programa; você deve obter a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-17-functions-with-parameters/output.txt}}
```

A declaração de `another_function` possui um parâmetro denominado `x`. O tipo de
`x` é especificado como `i32`. Quando passamos `5` para `another_function`, o
A macro `println!` coloca `5` onde estava o par de chaves contendo `x`
na string de formato.

Nas assinaturas de funções, você _deve_ declarar o tipo de cada parâmetro. Isso é
uma decisão deliberada no design do Rust: Exigindo anotações de tipo em função
definições significa que o compilador quase nunca precisa que você as use em outro lugar
o código para descobrir que tipo você quer dizer. O compilador também é capaz de fornecer
mensagens de erro mais úteis se souber quais tipos a função espera.

Ao definir vários parâmetros, separe as declarações dos parâmetros com
vírgulas, assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-18-functions-with-multiple-parameters/src/main.rs}}
```

Este exemplo cria uma função chamada `print_labeled_measurement` com dois
parâmetros. O primeiro parâmetro é denominado `value` e é `i32`. O segundo é
chamado `unit_label` e é do tipo `char`. A função então imprime texto contendo
tanto o `value` quanto o `unit_label`.

Vamos tentar executar este código. Substitua o programa atualmente em suas _funções_
arquivo _src/main.rs_ do projeto com o exemplo anterior e execute-o usando `cargo
correr`:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-18-functions-with-multiple-parameters/output.txt}}
```

Porque chamamos a função com `5` como valor para `value` e `'h'` como
o valor para `unit_label`, a saída do programa contém esses valores.

### Declarações e Expressões

Os corpos funcionais são compostos por uma série de instruções que terminam opcionalmente em um
expressão. Até agora, as funções que cobrimos não incluíram um final
expressão, mas você viu uma expressão como parte de uma declaração. Porque
Rust é uma linguagem baseada em expressões, esta é uma distinção importante para
entender. Outras línguas não têm as mesmas distinções, então vamos dar uma olhada
o que são declarações e expressões e como suas diferenças afetam os corpos
de funções.

- _Declarações_ são instruções que realizam alguma ação e não retornam
um valor.
- _Expressões_ são avaliadas como um valor resultante.

Vejamos alguns exemplos.

Na verdade, já usamos declarações e expressões. Criando uma variável e
atribuir um valor a ele com a palavra-chave `let` é uma afirmação. Na Listagem 3-1,
`let y = 6;` é uma declaração.

<Listing number="3-1" file-name="src/main.rs" caption="Uma declaração de função `main` contendo uma instrução">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-01/src/main.rs}}
```

</Listing>

As definições de funções também são declarações; todo o exemplo anterior é um
declaração em si. (Como veremos em breve, chamar uma função não é uma tarefa
declaração, no entanto.)

As instruções não retornam valores. Portanto, você não pode atribuir uma instrução `let`
para outra variável, como o código a seguir tenta fazer; você receberá um erro:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-19-statements-vs-expressions/src/main.rs}}
```

Ao executar este programa, o erro que você obterá será semelhante a este:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-19-statements-vs-expressions/output.txt}}
```

A instrução `let y = 6` não retorna um valor, então não há nada para
`x` para vincular. Isso é diferente do que acontece em outras línguas, como
C e Ruby, onde a atribuição retorna o valor da atribuição. Naqueles
idiomas, você pode escrever `x = y = 6` e fazer com que `x` e `y` tenham o valor
`6`; esse não é o caso em Rust.

As expressões são avaliadas como um valor e constituem a maior parte do restante do código que
você escreverá em Rust. Considere uma operação matemática, como `5 + 6`, que é um
expressão que avalia o valor `11`. As expressões podem fazer parte
declarações: Na Listagem 3-1, o `6` na declaração `let y = 6;` é um
expressão que avalia o valor `6`. Chamar uma função é um
expressão. Chamar uma macro é uma expressão. Um novo bloco de escopo criado com
colchetes é uma expressão, por exemplo:

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
como parte da instrução `let`. Observe a linha `x + 1` sem ponto e vírgula em
o final, que é diferente da maioria das falas que você viu até agora. Expressões fazem
não inclui ponto e vírgula final. Se você adicionar um ponto e vírgula ao final de um
expressão, você a transforma em uma instrução e ela não retornará um valor.
Tenha isso em mente ao explorar os valores e expressões de retorno da função a seguir.

### Funções com valores de retorno

As funções podem retornar valores ao código que as chama. Nós não nomeamos retorno
valores, mas devemos declarar seu tipo após uma seta (`->`). Em Ferrugem, o
o valor de retorno da função é sinônimo do valor do final
expressão no bloco do corpo de uma função. Você pode retornar mais cedo de um
função usando a palavra-chave `return` e especificando um valor, mas a maioria
funções retornam a última expressão implicitamente. Aqui está um exemplo de
função que retorna um valor:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-21-function-return-values/src/main.rs}}
```

Não há chamadas de função, macros ou mesmo instruções `let` no `five`
função - apenas o número `5` sozinho. Essa é uma função perfeitamente válida em
Ferrugem. Observe que o tipo de retorno da função também é especificado, como `-> i32`. Tentar
executando este código; a saída deve ficar assim:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-21-function-return-values/output.txt}}
```

O `5` em `five` é o valor de retorno da função, e é por isso que o tipo de retorno
é `i32`. Vamos examinar isso com mais detalhes. Existem duas partes importantes:
Primeiro, a linha `let x = five();` mostra que estamos usando o valor de retorno de um
função para inicializar uma variável. Como a função `five` retorna `5`,
essa linha é igual à seguinte:

```rust
let x = 5;
```

Segundo, a função `five` não possui parâmetros e define o tipo do
valor de retorno, mas o corpo da função é um solitário `5` sem ponto e vírgula
porque é uma expressão cujo valor queremos retornar.

Vejamos outro exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-22-function-parameter-and-return/src/main.rs}}
```

A execução deste código imprimirá `The value of x is: 6`. Mas o que acontece se nós
coloque um ponto e vírgula no final da linha que contém `x + 1`, alterando-o de
uma expressão para uma declaração?

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-23-statements-dont-return-values/src/main.rs}}
```

Compilar este código produzirá um erro, como segue:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-23-statements-dont-return-values/output.txt}}
```

A principal mensagem de erro, `mismatched types`, revela o problema central deste
código. A definição da função `plus_one` diz que ela retornará um
`i32`, mas as declarações não são avaliadas como um valor, que é expresso por `()`,
o tipo de unidade. Portanto, nada é retornado, o que contradiz a função
definição e resulta em um erro. Nesta saída, Rust fornece uma mensagem para
possivelmente ajude a corrigir esse problema: sugere a remoção do ponto e vírgula, que
corrigiria o erro.
