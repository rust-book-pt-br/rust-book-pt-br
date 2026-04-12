## Fluxo de Controle

A capacidade de executar algum código dependendo de uma condição ser `true` e a
capacidade de executar código repetidamente enquanto uma condição for `true`
são blocos fundamentais da maioria das linguagens de programação. As
construções mais comuns que permitem controlar o fluxo de execução de código em
Rust são expressões `if` e loops.

### Expressões `if`

Uma expressão `if` permite ramificar o código dependendo de condições. Você
fornece uma condição e então diz: “Se esta condição for satisfeita, execute
este bloco de código. Se ela não for satisfeita, não execute esse bloco.”

Crie um novo projeto chamado _branches_ dentro do seu diretório _projects_ para
explorar a expressão `if`. No arquivo _src/main.rs_, digite o seguinte:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-26-if-true/src/main.rs}}
```

Todas as expressões `if` começam com a palavra-chave `if`, seguida de uma
condição. Neste caso, a condição verifica se a variável `number` tem valor
menor que 5. Colocamos o bloco de código a ser executado caso a condição seja
`true` logo após a condição, entre chaves. Blocos de código associados às
condições em expressões `if` às vezes são chamados de _braços_, assim como os
braços de expressões `match` que discutimos na seção [“Comparando o Palpite com
o Número Secreto”][comparing-the-guess-to-the-secret-number]<!-- ignore --> do
Capítulo 2.

Opcionalmente, também podemos incluir uma expressão `else`, como escolhemos
fazer aqui, para fornecer ao programa um bloco alternativo de código a ser
executado caso a condição avalie para `false`. Se você não fornecer uma
expressão `else` e a condição for `false`, o programa simplesmente ignorará o
bloco `if` e seguirá adiante para o próximo trecho de código.

Tente executar esse código; você deverá ver a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-26-if-true/output.txt}}
```

Vamos agora alterar o valor de `number` para um valor que torne a condição
`false`, só para ver o que acontece:

```rust,ignore
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-27-if-false/src/main.rs:here}}
```

Execute o programa de novo e veja a saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-27-if-false/output.txt}}
```

Também vale notar que a condição nesse código _precisa_ ser um `bool`. Se a
condição não for um `bool`, teremos um erro. Por exemplo, tente executar o
seguinte código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-28-if-condition-must-be-bool/src/main.rs}}
```

Desta vez, a condição do `if` avalia para o valor `3`, e o Rust gera um erro:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-28-if-condition-must-be-bool/output.txt}}
```

O erro indica que o Rust esperava um `bool`, mas recebeu um inteiro.
Diferentemente de linguagens como Ruby e JavaScript, o Rust não tentará
converter automaticamente tipos não booleanos em booleanos. Você precisa ser
explícito e sempre fornecer ao `if` um booleano como condição. Se quisermos
que o bloco `if` execute somente quando um número for diferente de `0`, por
exemplo, podemos alterar a expressão `if` para a seguinte forma:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-29-if-not-equal-0/src/main.rs}}
```

Executar esse código imprimirá `number was something other than zero`.

#### Tratando Múltiplas Condições com `else if`

Você pode usar várias condições combinando `if` e `else` em uma expressão
`else if`. Por exemplo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-30-else-if/src/main.rs}}
```

Esse programa tem quatro caminhos possíveis. Depois de executá-lo, você deverá
ver a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-30-else-if/output.txt}}
```

Quando esse programa é executado, ele verifica cada expressão `if` em ordem e
executa o primeiro corpo cuja condição avalia para `true`. Observe que, mesmo
que 6 seja divisível por 2, não vemos a saída `number is divisible by 2`, nem
vemos o texto `number is not divisible by 4, 3, or 2` do bloco `else`. Isso
acontece porque o Rust executa apenas o bloco correspondente à primeira
condição `true` e, depois que encontra uma, nem sequer verifica as demais.

Usar muitas expressões `else if` pode poluir o código, então, se você tiver
mais de uma, talvez valha a pena refatorar. O Capítulo 6 descreve uma poderosa
construção de ramificação do Rust chamada `match` para esses casos.

#### Usando `if` em uma Instrução `let`

Como `if` é uma expressão, podemos usá-lo no lado direito de uma instrução
`let` para atribuir o resultado a uma variável, como na Listagem 3-2.

<Listing number="3-2" file-name="src/main.rs" caption="Atribuindo o resultado de uma expressão `if` a uma variável">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-02/src/main.rs}}
```

</Listing>

A variável `number` ficará vinculada a um valor dependendo do resultado da
expressão `if`. Execute esse código para ver o que acontece:

```console
{{#include ../listings/ch03-common-programming-concepts/listing-03-02/output.txt}}
```

Lembre-se de que blocos de código avaliam para a última expressão neles, e
números sozinhos também são expressões. Neste caso, o valor da expressão `if`
inteira depende de qual bloco de código é executado. Isso significa que os
valores que podem surgir como resultado de cada braço do `if` precisam ter o
mesmo tipo; na Listagem 3-2, os resultados dos braços `if` e `else` eram
inteiros `i32`. Se os tipos não forem compatíveis, como no exemplo a seguir,
teremos um erro:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-31-arms-must-return-same-type/src/main.rs}}
```

Quando tentamos compilar esse código, recebemos um erro. Os braços `if` e
`else` têm tipos de valor incompatíveis, e o Rust aponta exatamente onde está
o problema no programa:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-31-arms-must-return-same-type/output.txt}}
```

A expressão no bloco `if` avalia para um inteiro, e a expressão no bloco
`else` avalia para uma string. Isso não funciona porque variáveis precisam ter
um único tipo, e o Rust precisa saber de forma definitiva, em tempo de
compilação, qual é o tipo da variável `number`. Conhecer o tipo de `number`
permite que o compilador verifique se esse tipo é válido em todos os lugares
em que usamos `number`. O Rust não conseguiria fazer isso se o tipo de
`number` fosse determinado apenas em tempo de execução; o compilador seria mais
complexo e daria menos garantias sobre o código se precisasse acompanhar
múltiplos tipos hipotéticos para qualquer variável.

### Repetição com Loops

Com frequência é útil executar um bloco de código mais de uma vez. Para isso, o
Rust fornece vários _loops_, que executam o código dentro do corpo do loop até
o fim e então voltam imediatamente ao começo. Para experimentar com loops,
vamos criar um novo projeto chamado _loops_.

Rust tem três tipos de loop: `loop`, `while` e `for`. Vamos experimentar cada
um deles.

#### Repetindo Código com `loop`

A palavra-chave `loop` diz ao Rust para executar um bloco de código repetidas
vezes, para sempre, ou até que você diga explicitamente que ele deve parar.

Como exemplo, altere o arquivo _src/main.rs_ no seu diretório _loops_ para que
fique assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-32-loop/src/main.rs}}
```

Quando executarmos esse programa, veremos `again!` sendo impresso
continuamente, repetidas vezes, até interrompermos o programa manualmente. A
maioria dos terminais oferece o atalho de teclado <kbd>ctrl</kbd>-<kbd>C</kbd>
para interromper um programa preso em um loop contínuo. Experimente:

<!-- manual-regeneration
cd listings/ch03-common-programming-concepts/no-listing-32-loop
cargo run
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

O símbolo `^C` representa o ponto em que você pressionou
<kbd>ctrl</kbd>-<kbd>C</kbd>.

Você pode ou não ver a palavra `again!` impressa depois de `^C`, dependendo de
onde o código estava dentro do loop quando recebeu o sinal de interrupção.

Felizmente, o Rust também fornece uma forma de sair de um loop usando código.
Você pode colocar a palavra-chave `break` dentro do loop para dizer ao programa
quando deve parar de executá-lo. Lembre-se de que fizemos isso no jogo de
adivinhação, na seção [“Saindo Depois de um Palpite
Correto”][quitting-after-a-correct-guess]<!-- ignore --> do Capítulo 2, para
encerrar o programa quando o usuário acertava o número.

Também usamos `continue` no jogo de adivinhação. Dentro de um loop, essa
palavra-chave diz ao programa para pular qualquer código restante da iteração
atual e ir direto para a próxima.

#### Retornando Valores a Partir de Loops

Um dos usos de `loop` é repetir uma operação que você sabe que pode falhar,
como verificar se uma thread concluiu seu trabalho. Você também pode precisar
passar o resultado dessa operação para fora do loop e usá-lo no restante do
código. Para fazer isso, você pode adicionar o valor que deseja retornar após a
expressão `break` usada para interromper o loop; esse valor será retornado para
fora do loop, para que você possa utilizá-lo, como mostrado aqui:

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-33-return-value-from-loop/src/main.rs}}
```

Antes do loop, declaramos uma variável chamada `counter` e a inicializamos com
`0`. Em seguida, declaramos uma variável chamada `result` para armazenar o
valor retornado pelo loop. Em cada iteração do loop, somamos `1` à variável
`counter` e então verificamos se `counter` é igual a `10`. Quando isso
acontece, usamos a palavra-chave `break` com o valor `counter * 2`. Depois do
loop, usamos um ponto e vírgula para encerrar a instrução que atribui o valor
a `result`. Por fim, imprimimos o valor contido em `result`, que neste caso é
`20`.

Você também pode usar `return` de dentro de um loop. Enquanto `break` sai apenas
do loop atual, `return` sempre sai da função atual.

<!-- Old headings. Do not remove or links may break. -->
<a id="loop-labels-to-disambiguate-between-multiple-loops"></a>

#### Desambiguando com Rótulos de Loop

Se você tiver loops dentro de loops, `break` e `continue` se aplicam ao loop
mais interno naquele ponto. Opcionalmente, você pode especificar um _rótulo de
loop_ em um loop e então usar esse rótulo com `break` ou `continue` para
indicar que essas palavras-chave devem se aplicar ao loop rotulado, em vez do
mais interno. Rótulos de loop devem começar com uma aspas simples. Aqui está um
exemplo com dois loops aninhados:

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-32-5-loop-labels/src/main.rs}}
```

O loop externo tem o rótulo `'counting_up`, e ele contará de 0 a 2. O loop
interno, sem rótulo, conta regressivamente de 10 a 9. O primeiro `break` que
não especifica rótulo sairá apenas do loop interno. Já a instrução `break
'counting_up;` sairá do loop externo. Esse código imprime:

```console
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-32-5-loop-labels/output.txt}}
```

<!-- Old headings. Do not remove or links may break. -->
<a id="conditional-loops-with-while"></a>

#### Simplificando Loops Condicionais com `while`

Um programa frequentemente precisa avaliar uma condição dentro de um loop.
Enquanto a condição for `true`, o loop continua. Quando a condição deixa de ser
`true`, o programa chama `break`, interrompendo o loop. É possível implementar
esse comportamento usando uma combinação de `loop`, `if`, `else` e `break`; se
quiser, você pode tentar isso agora em um programa. No entanto, esse padrão é
tão comum que o Rust oferece uma construção específica para ele, chamada loop
`while`. Na Listagem 3-3, usamos `while` para fazer o programa repetir três
vezes, contando regressivamente, e então, depois do loop, imprimir uma mensagem
e sair.

<Listing number="3-3" file-name="src/main.rs" caption="Usando um loop `while` para executar código enquanto uma condição avalia para `true`">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-03/src/main.rs}}
```

</Listing>

Essa construção elimina muito do aninhamento que seria necessário se você
usasse `loop`, `if`, `else` e `break`, além de ficar mais clara. Enquanto a
condição avaliar para `true`, o código é executado; caso contrário, o loop é
encerrado.

#### Percorrendo uma Coleção com `for`

Você pode escolher usar a construção `while` para iterar sobre os elementos de
uma coleção, como um array. Por exemplo, o loop da Listagem 3-4 imprime cada
elemento do array `a`.

<Listing number="3-4" file-name="src/main.rs" caption="Percorrendo cada elemento de uma coleção usando um loop `while`">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-04/src/main.rs}}
```

</Listing>

Aqui, o código percorre os elementos do array em ordem crescente. Ele começa no
índice `0` e continua até alcançar o índice final do array, isto é, até que
`index < 5` deixe de ser `true`. Executar esse código imprimirá todos os
elementos do array:

```console
{{#include ../listings/ch03-common-programming-concepts/listing-03-04/output.txt}}
```

Os cinco valores do array aparecem no terminal, como esperado. Mesmo que
`index` chegue ao valor `5` em algum momento, o loop para antes de tentar
buscar um sexto valor do array.

No entanto, essa abordagem é propensa a erros. Poderíamos fazer o programa
entrar em pânico se o valor do índice ou a condição do teste estivesse errada.
Por exemplo, se você alterasse a definição do array `a` para ter quatro
elementos, mas esquecesse de atualizar a condição para `while index < 4`, o
código entraria em pânico. Ela também é mais lenta, porque o compilador insere
código de tempo de execução para verificar a cada iteração se o índice está
dentro dos limites do array.

Como alternativa mais concisa, você pode usar um loop `for` e executar algum
código para cada item de uma coleção. Um loop `for` tem a aparência do código
na Listagem 3-5.

<Listing number="3-5" file-name="src/main.rs" caption="Percorrendo cada elemento de uma coleção usando um loop `for`">

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-05/src/main.rs}}
```

</Listing>

Quando executarmos esse código, veremos a mesma saída da Listagem 3-4. Mais
importante: aumentamos a segurança do código e eliminamos a chance de bugs
resultantes de passar do fim do array ou de não percorrê-lo por completo e
deixar elementos para trás. O código de máquina gerado para loops `for`
também pode ser mais eficiente, porque o índice não precisa ser comparado ao
comprimento do array em cada iteração.

Usando o loop `for`, você não precisaria lembrar de alterar outro trecho de
código se mudasse a quantidade de valores no array, como acontecia com o método
usado na Listagem 3-4.

A segurança e a concisão dos loops `for` fazem deles a construção de loop mais
usada em Rust. Mesmo em situações em que você quer executar algum código um
número específico de vezes, como no exemplo da contagem regressiva feito com um
loop `while` na Listagem 3-3, a maioria dos rustaceanos usaria um loop `for`.
O jeito de fazer isso seria usando um `Range`, fornecido pela biblioteca
padrão, que gera todos os números em sequência a partir de um número inicial e
até antes de outro número.

Veja como a contagem regressiva ficaria usando um loop `for` e outro método
que ainda não discutimos, `rev`, para inverter o intervalo:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-34-for-range/src/main.rs}}
```

Esse código fica um pouco melhor, não fica?

## Resumo

Você conseguiu! Este foi um capítulo grande: você aprendeu sobre variáveis,
tipos de dados escalares e compostos, funções, comentários, expressões `if` e
loops. Para praticar os conceitos discutidos neste capítulo, tente construir
programas que façam o seguinte:

- Converter temperaturas entre Fahrenheit e Celsius.
- Gerar o enésimo número de Fibonacci.
- Imprimir a letra da canção natalina “The Twelve Days of Christmas”,
  aproveitando a repetição da música.

Quando estiver pronto para seguir em frente, vamos falar sobre um conceito do
Rust que _não_ existe comumente em outras linguagens de programação:
ownership.

[comparing-the-guess-to-the-secret-number]: ch02-00-guessing-game-tutorial.html#comparing-the-guess-to-the-secret-number
[quitting-after-a-correct-guess]: ch02-00-guessing-game-tutorial.html#quitting-after-a-correct-guess
