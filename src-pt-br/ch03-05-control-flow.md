## Fluxo de controle

A capacidade de executar algum código dependendo se uma condição é `true` e o
capacidade de executar algum código repetidamente enquanto uma condição é `true` são básicos
blocos de construção na maioria das linguagens de programação. As construções mais comuns que
permitem que você controle o fluxo de execução do código Rust são expressões `if` e
laços.

### `if` Expressões

Uma expressão `if` permite ramificar seu código dependendo das condições. Você
forneça uma condição e então declare: “Se esta condição for atendida, execute este bloco
de código. Se a condição não for atendida, não execute este bloco de código.”

Crie um novo projeto chamado _branches_ em seu diretório _projects_ para explorar
a expressão `if`. No arquivo _src/main.rs_, insira o seguinte:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-26-if-true/src/main.rs}}
```

Todas as expressões `if` começam com a palavra-chave `if`, seguida por uma condição. Em
neste caso, a condição verifica se a variável `number` tem ou não um
valor menor que 5. Colocamos o bloco de código para executar se a condição for
`true` imediatamente após a condição entre colchetes. Blocos de código
associados às condições em expressões `if` são às vezes chamados de _arms_,
assim como os braços nas expressões `match` que discutimos em [“Comparando
a suposição do número secreto”][comparing-the-guess-to-the-secret-number]<!--
ignore --> do Capítulo 2.

Opcionalmente, também podemos incluir uma expressão `else`, que escolhemos fazer
aqui, para dar ao programa um bloco alternativo de código para executar caso o
condição avaliada como `false`. Se você não fornecer uma expressão `else` e
a condição é `false`, o programa simplesmente pulará o bloco `if` e seguirá em frente
para o próximo pedaço de código.

Tente executar este código; você deverá ver a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-26-if-true/output.txt}}
```

Vamos tentar alterar o valor de `number` para um valor que torne a condição
`false` para ver o que acontece:

```rust,ignore
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-27-if-false/src/main.rs:here}}
```

Execute o programa novamente e observe o resultado:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-27-if-false/output.txt}}
```

Também é importante notar que a condição neste código _deve_ ser `bool`. Se
a condição não é `bool`, obteremos um erro. Por exemplo, tente executar o
seguinte código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-28-if-condition-must-be-bool/src/main.rs}}
```

A condição `if` é avaliada como um valor `3` desta vez, e Rust lança um
erro:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-28-if-condition-must-be-bool/output.txt}}
```

O erro indica que Rust esperava `bool`, mas obteve um número inteiro. Diferente
linguagens como Ruby e JavaScript, Rust não tentará automaticamente
converter tipos não booleanos em booleanos. Você deve ser explícito e sempre fornecer
`if` com um booleano como condição. Se quisermos que o bloco de código `if` seja executado
somente quando um número não é igual a `0`, por exemplo, podemos alterar o `if`
expressão para o seguinte:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-29-if-not-equal-0/src/main.rs}}
```

A execução deste código imprimirá `number was something other than zero`.

#### Lidando com múltiplas condições com `else if`

Você pode usar várias condições combinando `if` e `else` em um `else if`
expressão. Por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-30-else-if/src/main.rs}}
```

Este programa tem quatro caminhos possíveis que pode seguir. Depois de executá-lo, você deve
veja a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-30-else-if/output.txt}}
```

Quando este programa é executado, ele verifica cada expressão `if` e executa
o primeiro corpo para o qual a condição é avaliada como `true`. Observe que mesmo
embora 6 seja divisível por 2, não vemos a saída `number is divisible by 2`,
nem vemos o texto `number is not divisible by 4, 3, or 2` do `else`
bloquear. Isso porque Rust só executa o bloco para o primeiro `true`
condição e, uma vez encontrada, nem verifica o resto.

Usar muitas expressões `else if` pode sobrecarregar seu código, portanto, se você tiver mais
de um, talvez você queira refatorar seu código. O Capítulo 6 descreve um poderoso
Construção de ramificação Rust chamada `match` para esses casos.

#### Usando `if` em uma instrução `let`

Como `if` é uma expressão, podemos usá-la no lado direito de `let`
instrução para atribuir o resultado a uma variável, como na Listagem 3-2.

<Listing number="3-2" file-name="src/main.rs" caption="Assigning the result of an `if` expression to a variable">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-02/src/main.rs}}
```

</Listing>

A variável `number` será vinculada a um valor baseado no resultado do `if`
expressão. Execute este código para ver o que acontece:

```console
{{#include ../listings/ch03-common-programming-concepts/listing-03-02/output.txt}}
```

Lembre-se de que os blocos de código são avaliados até a última expressão neles e
os números por si só também são expressões. Neste caso, o valor do
toda a expressão `if` depende de qual bloco de código é executado. Isto significa o
valores que têm potencial para serem resultados de cada braço do `if` devem ser
o mesmo tipo; na Listagem 3-2, os resultados do braço `if` e do braço `else`
braço eram `i32` inteiros. Se os tipos forem incompatíveis, como a seguir
por exemplo, obteremos um erro:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-31-arms-must-return-same-type/src/main.rs}}
```

Quando tentarmos compilar este código, obteremos um erro. Os braços `if` e `else`
têm tipos de valor incompatíveis e Rust indica exatamente onde
encontre o problema no programa:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-31-arms-must-return-same-type/output.txt}}
```

A expressão no bloco `if` é avaliada como um número inteiro e a expressão em
o bloco `else` é avaliado como uma string. Isso não funcionará, porque as variáveis ​​devem
tem um único tipo, e Rust precisa saber definitivamente em tempo de compilação o que
digite a variável `number`. Conhecer o tipo de `number` permite ao compilador
verifique se o tipo é válido em todos os lugares que usamos `number`. A ferrugem não seria capaz
faça isso se o tipo de `number` só foi determinado em tempo de execução; o compilador
seria mais complexo e daria menos garantias sobre o código se tivesse
para acompanhar vários tipos hipotéticos para qualquer variável.

### Repetição com Loops

Muitas vezes é útil executar um bloco de código mais de uma vez. Para esta tarefa,
Rust fornece vários _loops_, que serão executados no código dentro do loop
corpo até o fim e então comece imediatamente de volta ao início. Para experimentar
com loops, vamos fazer um novo projeto chamado _loops_.

Rust tem três tipos de loops: `loop`, `while` e `for`. Vamos tentar cada um.

#### Repetindo código com `loop`

A palavra-chave `loop` diz ao Rust para executar um bloco de código repetidamente
para sempre ou até que você diga explicitamente para parar.

Por exemplo, altere o arquivo _src/main.rs_ em seu diretório _loops_ para ver
assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-32-loop/src/main.rs}}
```

Quando executarmos este programa, veremos `again!` impresso continuamente
até pararmos o programa manualmente. A maioria dos terminais suporta o atalho de teclado
<kbd>ctrl</kbd>-<kbd>C</kbd> para interromper um programa que está preso em um contínuo
laço. Experimente:

<!-- manual-regeneration
listagens de cd/ch03-common-programming-concepts/no-listing-32-loop
corrida de carga
CTRL-C
-->

```console
$ cargo run
   Compiling loops v0.1.0 (file:///projects/loops)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/loops`
again!
again!
again!
again!
^Cagain!
```

O símbolo `^C` representa onde você pressionou <kbd>ctrl</kbd>-<kbd>C</kbd>.

Você pode ou não ver a palavra `again!` impressa após `^C`, dependendo
onde o código estava no loop quando recebeu o sinal de interrupção.

Felizmente, Rust também oferece uma maneira de sair de um loop usando código. Você
pode colocar a palavra-chave `break` dentro do loop para informar ao programa quando parar
executando o loop. Lembre-se que fizemos isso no jogo de adivinhação no
[“Desistir após um palpite correto”][quitting-after-a-correct-guess]<!-- ignorar
-> seção do Capítulo 2 para sair do programa quando o usuário ganhou o jogo
adivinhando o número correto.

Também usamos `continue` no jogo de adivinhação, que em um loop informa ao programa
para pular qualquer código restante nesta iteração do loop e ir para o
próxima iteração.

#### Retornando Valores de Loops

Um dos usos de `loop` é tentar novamente uma operação que você sabe que pode falhar, como
como verificar se um thread concluiu seu trabalho. Você também pode precisar passar
o resultado dessa operação fora do loop para o resto do seu código. Pendência
isso, você pode adicionar o valor que deseja retornar após a expressão `break` que você
use para parar o loop; esse valor será retornado fora do loop para que você
pode usá-lo, como mostrado aqui:

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-33-return-value-from-loop/src/main.rs}}
```

Antes do loop, declaramos uma variável chamada `counter` e a inicializamos para
`0`. Então, declaramos uma variável chamada `result` para armazenar o valor retornado de
o laço. Em cada iteração do loop, adicionamos `1` à variável `counter`,
e verifique se `counter` é igual a `10`. Quando for, usamos o
`break` palavra-chave com o valor `counter * 2`. Após o loop, usamos um
ponto e vírgula para finalizar a instrução que atribui o valor a `result`. Finalmente, nós
imprima o valor em `result`, que neste caso é `20`.

Você também pode `return` dentro de um loop. Enquanto `break` apenas sai do atual
loop, `return` sempre sai da função atual.

<!-- Old headings. Do not remove or links may break. -->
<a id="loop-labels-to-disambiguate-between-multiple-loops"></a>

#### Desambiguando com rótulos de loop

Se você tiver loops dentro de loops, `break` e `continue` aplicam-se ao mais interno
loop nesse ponto. Opcionalmente, você pode especificar um _loop label_ em um loop que
você pode usar com `break` ou `continue` para especificar que essas palavras-chave
aplique ao loop rotulado em vez do loop mais interno. Os rótulos de loop devem começar
com uma única citação. Aqui está um exemplo com dois loops aninhados:

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-32-5-loop-labels/src/main.rs}}
```

O loop externo tem o rótulo `'counting_up` e contará de 0 a 2.
O loop interno sem rótulo faz a contagem regressiva de 10 a 9. O primeiro `break` que
não especifica um rótulo sairá apenas do loop interno. A `pausa
A instrução 'counting_up;` sairá do loop externo. Este código imprime:

```console
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-32-5-loop-labels/output.txt}}
```

<!-- Old headings. Do not remove or links may break. -->
<a id="conditional-loops-with-while"></a>

#### Simplificando Loops Condicionais com while

Freqüentemente, um programa precisará avaliar uma condição dentro de um loop. Enquanto o
condição for `true`, o loop será executado. Quando a condição deixa de ser `true`, o
o programa chama `break`, interrompendo o loop. É possível implementar comportamento
assim usando uma combinação de `loop`, `if`, `else` e `break`; você poderia
tente isso agora em um programa, se desejar. No entanto, esse padrão é tão comum
que Rust tem uma construção de linguagem integrada para ele, chamada `while` loop. Em
Listagem 3-3, usamos `while` para repetir o programa três vezes, contando regressivamente cada
tempo e, após o loop, imprimir uma mensagem e sair.

<Listing number="3-3" file-name="src/main.rs" caption="Using a `while` loop to run code while a condition evaluates to `true`">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-03/src/main.rs}}
```

</Listing>

Esta construção elimina muitos aninhamentos que seriam necessários se você usasse
`loop`, `if`, `else` e `break`, e é mais claro. Enquanto uma condição
avalia `true`, o código é executado; caso contrário, ele sai do loop.

#### Percorrendo uma coleção com `for`

Você pode optar por usar a construção `while` para percorrer os elementos de um
coleção, como uma matriz. Por exemplo, o loop na Listagem 3-4 imprime cada
elemento na matriz `a`.

<Listing number="3-4" file-name="src/main.rs" caption="Looping through each element of a collection using a `while` loop">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-04/src/main.rs}}
```

</Listing>

Aqui, o código faz a contagem crescente dos elementos do array. Começa no índice
`0` e, em seguida, faz um loop até atingir o índice final na matriz (ou seja,
quando `index < 5` não for mais `true`). A execução deste código imprimirá todos
elemento na matriz:

```console
{{#include ../listings/ch03-common-programming-concepts/listing-03-04/output.txt}}
```

Todos os cinco valores da matriz aparecem no terminal, conforme esperado. Mesmo que `index`
atingirá um valor de `5` em algum ponto, o loop para de ser executado antes de tentar
para buscar um sexto valor da matriz.

No entanto, esta abordagem é propensa a erros; poderíamos causar pânico no programa se
o valor do índice ou condição de teste está incorreto. Por exemplo, se você alterou o
definição do array `a` para ter quatro elementos, mas esqueci de atualizar o
condição para `while index < 4`, o código entraria em pânico. Também é lento, porque
o compilador adiciona código de tempo de execução para realizar a verificação condicional se o
index está dentro dos limites da matriz em cada iteração do loop.

Como uma alternativa mais concisa, você pode usar um loop `for` e executar algum código
para cada item de uma coleção. Um loop `for` se parece com o código da Listagem 3-5.

<Listing number="3-5" file-name="src/main.rs" caption="Looping through each element of a collection using a `for` loop">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-05/src/main.rs}}
```

</Listing>

Quando executarmos esse código, veremos a mesma saída da Listagem 3-4. Mais
mais importante, agora aumentamos a segurança do código e eliminamos o
chance de bugs que podem resultar de ir além do final do array ou não
indo longe o suficiente e faltando alguns itens. Código de máquina gerado a partir de `for`
loops também podem ser mais eficientes porque o índice não precisa ser
comparado ao comprimento da matriz em cada iteração.

Usando o loop `for`, você não precisaria se lembrar de alterar nenhum outro código se
você alterou o número de valores na matriz, como faria com o método
usado na Listagem 3-4.

A segurança e a concisão dos loops `for` fazem deles o loop mais comumente usado
construir em Rust. Mesmo em situações em que você deseja executar algum código
certo número de vezes, como no exemplo de contagem regressiva que usou um loop `while`
na Listagem 3-3, a maioria dos Rustáceos usaria um loop `for`. A maneira de fazer isso
seria usar um `Range`, fornecido pela biblioteca padrão, que gera
todos os números em sequência começando de um número e terminando antes de outro
número.

Esta é a aparência da contagem regressiva usando um loop `for` e outro método
ainda não falamos sobre `rev`, para reverter o intervalo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-34-for-range/src/main.rs}}
```

Esse código é um pouco melhor, não é?

## Resumo

Você conseguiu! Este foi um capítulo considerável: você aprendeu sobre variáveis, escalar
e tipos de dados compostos, funções, comentários, expressões `if` e loops! Para
praticar com os conceitos discutidos neste capítulo, tente construir programas para
faça o seguinte:

- Converta temperaturas entre Fahrenheit e Celsius.
- Gere o *n*ésimo número de Fibonacci.
- Imprima a letra da canção de Natal “Os Doze Dias de Natal”,
aproveitando a repetição da música.

Quando você estiver pronto para seguir em frente, falaremos sobre um conceito em Rust que _não_
comumente existem em outras linguagens de programação: propriedade.

[comparing-the-guess-to-the-secret-number]: ch02-00-guessing-game-tutorial.html#comparing-the-guess-to-the-secret-number
[quitting-after-a-correct-guess]: ch02-00-guessing-game-tutorial.html#quitting-after-a-correct-guess
