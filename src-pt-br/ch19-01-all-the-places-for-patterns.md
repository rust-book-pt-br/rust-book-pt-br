## Todos os lugares em que padrões podem ser usados

Padrões aparecem em vários lugares no Rust, e você os tem usado bastante sem
perceber! Esta seção discute todos os lugares em que padrões são válidos.

### Braços de `match`

Como discutimos no Capítulo 6, usamos padrões nos braços das expressões
`match`. Formalmente, expressões `match` são definidas pela palavra-chave
`match`, um valor sobre o qual haverá correspondência e um ou mais braços de
`match`, cada um consistindo em um padrão e em uma expressão a ser executada se
o valor corresponder ao padrão daquele braço, assim:

<!--
Formatado manualmente em vez de usar Markdown intencionalmente: Markdown não
  suporta código em itálico no corpo de um bloco como este!
-->

<pre><code>match <em>VALUE</em> {
    <em>PATTERN</em> => <em>EXPRESSION</em>,
    <em>PATTERN</em> => <em>EXPRESSION</em>,
    <em>PATTERN</em> => <em>EXPRESSION</em>,
}</code></pre>

Por exemplo, aqui está a expressão `match` da Listagem 6-5, que faz
correspondência com um valor `Option<i32>` na variável `x`:

```rust,ignore
match x {
    None => None,
    Some(i) => Some(i + 1),
}
```

Os padrões nessa expressão `match` são `None` e `Some(i)`, à esquerda de cada
seta.

Uma exigência das expressões `match` é que elas sejam exaustivas, no sentido de
que todas as possibilidades para o valor da expressão `match` precisam ser
contempladas. Uma forma de garantir isso é ter um padrão abrangente no último
braço: por exemplo, um nome de variável que corresponda a qualquer valor nunca
falha e, portanto, cobre todos os casos restantes.

O padrão específico `_` corresponde a qualquer coisa, mas nunca se vincula a
uma variável, por isso costuma ser usado no último braço de `match`. O padrão
`_` pode ser útil, por exemplo, quando você quer ignorar qualquer valor não
especificado. Vamos cobrir o padrão `_` com mais detalhes em
[“Ignorando valores em um padrão”][ignoring-values-in-a-pattern]<!-- ignore -->
mais adiante neste capítulo.

### Instruções `let`

Antes deste capítulo, havíamos discutido explicitamente o uso de padrões apenas
com `match` e `if let`, mas, na verdade, também usamos padrões em outros
lugares, inclusive em instruções `let`. Por exemplo, considere esta atribuição
simples de variável com `let`:

```rust
let x = 5;
```

Toda vez que você usou uma instrução `let` como essa, estava usando padrões,
ainda que talvez não tivesse percebido. De forma mais formal, uma instrução
`let` se parece com isto:

<!--
Formatado manualmente em vez de usar Markdown intencionalmente: Markdown não
  suporta código em itálico no corpo de um bloco como este!
-->

<pre>
<code>let <em>PATTERN</em> = <em>EXPRESSION</em>;</code>
</pre>

Em instruções como `let x = 5;`, com um nome de variável na posição de
PATTERN, o nome da variável é apenas uma forma particularmente simples de
padrão. Rust compara a expressão com o padrão e vincula quaisquer nomes que
encontrar. Assim, no exemplo `let x = 5;`, `x` é um padrão que significa
“vincular o que corresponder aqui à variável `x`”. Como o nome `x` é o padrão
inteiro, esse padrão efetivamente significa “vincular tudo à variável `x`,
qualquer que seja o valor”.

Para ver mais claramente o aspecto de correspondência de padrões em `let`,
considere a Listagem 19-1, que usa um padrão com `let` para desestruturar uma
tupla.


<Listing number="19-1" caption="Usando um padrão para desestruturar uma tupla e criar três variáveis de uma vez">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-01/src/main.rs:here}}
```

</Listing>

Aqui, fazemos a correspondência de uma tupla com um padrão. Rust compara o
valor `(1, 2, 3)` ao padrão `(x, y, z)` e verifica se o valor corresponde ao
padrão, isto é, percebe que o número de elementos é o mesmo em ambos. Então,
Rust vincula `1` a `x`, `2` a `y` e `3` a `z`. Você pode pensar nesse padrão de
tupla como o aninhamento de três padrões individuais de variável dentro dele.

Se o número de elementos no padrão não corresponder ao número de elementos da
tupla, a forma geral não corresponderá e obteremos um erro de compilador. Por
exemplo, a Listagem 19-2 mostra uma tentativa de desestruturar uma tupla com
três elementos em duas variáveis, o que não funcionará.

<Listing number="19-2" caption="Construindo incorretamente um padrão cujas variáveis não correspondem ao número de elementos da tupla">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-02/src/main.rs:here}}
```

</Listing>

A tentativa de compilar este código resulta neste tipo de erro:

```console
{{#include ../listings/ch19-patterns-and-matching/listing-19-02/output.txt}}
```

Para corrigir o erro, poderíamos ignorar um ou mais valores na tupla usando
`_` ou `..`, como você verá na seção
[“Ignorando valores em um padrão”][ignoring-values-in-a-pattern]<!-- ignore -->.
Se o problema for que temos variáveis demais no padrão, a solução é fazer os
tipos corresponderem removendo variáveis, de modo que o número de variáveis seja
igual ao número de elementos da tupla.

### Expressões condicionais `if let`

No Capítulo 6, discutimos como usar expressões `if let` principalmente como uma
forma mais curta de escrever o equivalente a um `match` que só corresponde a um
caso. Opcionalmente, `if let` pode ter um `else` correspondente, contendo código
para executar se o padrão em `if let` não corresponder.

A Listagem 19-3 mostra que também é possível misturar expressões `if let`,
`else if` e `else if let`. Isso nos dá mais flexibilidade do que uma expressão
`match`, na qual só podemos expressar um único valor para comparar com os
padrões. Além disso, Rust não exige que as condições em uma série de braços
`if let`, `else if` e `else if let` estejam relacionadas entre si.

O código na Listagem 19-3 determina em qual cor seu plano de fundo será baseado.
uma série de verificações para diversas condições. Para este exemplo, criamos
variáveis com valores codificados que um programa real pode receber do usuário
entrada.

<Listing number="19-3" file-name="src/main.rs" caption="Misturando `if let`, `else if`, `else if let` e `else`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-03/src/main.rs}}
```

</Listing>

Se o usuário especificar uma cor favorita, essa cor será usada como plano de fundo.
Se nenhuma cor favorita for especificada e hoje for terça-feira, a cor de fundo será
verde. Caso contrário, se o usuário especificar sua idade como uma string e pudermos analisar
como um número com sucesso, a cor é roxa ou laranja dependendo
o valor do número. Se nenhuma destas condições se aplicar, o plano de fundo
a cor é azul.

Essa estrutura condicional nos permite dar suporte a requisitos complexos. Com
os valores codificados que temos aqui, este exemplo imprimirá
`Using purple as the background color`.

Você pode ver que `if let` também pode introduzir novas variáveis que sombreiam
as existentes, do mesmo modo que os braços de `match`: a linha
`if let Ok(age) = age` introduz uma nova variável `age` que contém o valor
dentro da variante `Ok`, sombreando a variável `age` já existente. Isso
significa que precisamos colocar a condição `if age > 30` dentro desse bloco:
não podemos combinar essas duas condições em `if let Ok(age) = age && age > 30`.
A nova `age` que queremos comparar com 30 não é válida até que o novo escopo
comece com as chaves.

A desvantagem de usar expressões `if let` é que o compilador não verifica
para exaustividade, enquanto com expressões `match` isso acontece. Se omitimos o
último bloco `else` e, portanto, perdeu o tratamento de alguns casos, o compilador
não nos alerta sobre o possível bug lógico.

### Loops condicionais `while let`

Semelhante em construção a `if let`, o loop condicional `while let` permite que
um loop `while` seja executado enquanto um padrão continuar correspondendo. Na
Listagem 19-4, mostramos um loop `while let` que espera mensagens enviadas entre
threads, mas, nesse caso, verificando um `Result` em vez de um `Option`.

<Listing number="19-4" caption="Usando um loop `while let` para imprimir valores enquanto `rx.recv()` retornar `Ok`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-04/src/main.rs:here}}
```

</Listing>

Este exemplo imprime `1`, `2` e depois `3`. O método `recv` tira a primeira
mensagem do lado receptor do canal e retorna um `Ok(value)`. Quando vimos
`recv` pela primeira vez no Capítulo 16, desembrulhamos o erro diretamente ou
interagimos com ele como um iterator usando um loop `for`. Como mostra a
Listagem 19-4, porém, também podemos usar `while let`, porque o método `recv`
retorna `Ok` cada vez que uma mensagem chega, enquanto o remetente existir, e
então produz um `Err` assim que o lado remetente se desconecta.

### Loops `for`

Em um loop `for`, o valor que segue diretamente a palavra-chave `for` é um
padrão. Por exemplo, em `for x in y`, `x` é o padrão. A Listagem 19-5
demonstra como usar um padrão em um loop `for` para desestruturar uma tupla
como parte do próprio loop.


<Listing number="19-5" caption="Usando um padrão em um loop `for` para desestruturar uma tupla">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-05/src/main.rs:here}}
```

</Listing>

O código na Listagem 19-5 imprimirá o seguinte:


```console
{{#include ../listings/ch19-patterns-and-matching/listing-19-05/output.txt}}
```

Adaptamos um iterator usando o método `enumerate` para que ele produza um valor
e o índice desse valor, colocados em uma tupla. O primeiro valor produzido é a
tupla `(0, 'a')`. Quando esse valor corresponde ao padrão `(index, value)`,
`index` será `0` e `value` será `'a'`, imprimindo a primeira linha da saída.


### Parâmetros de função

Os parâmetros de função também podem ser padrões. O código na Listagem 19-6, que
declara uma função chamada `foo` que recebe um parâmetro chamado `x` do tipo
`i32` já deve parecer familiar.

<Listing number="19-6" caption="Uma assinatura de função usando padrões nos parâmetros">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-06/src/main.rs:here}}
```

</Listing>

A parte `x` é um padrão! Assim como fizemos com `let`, poderíamos fazer a
correspondência de uma tupla nos argumentos de uma função com um padrão. A
Listagem 19-7 divide os valores de uma tupla à medida que a passamos para uma
função.

<Listing number="19-7" file-name="src/main.rs" caption="Uma função com parâmetros que desestruturam uma tupla">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-07/src/main.rs}}
```

</Listing>

Esse código imprime `Current location: (3, 5)`. Os valores `&(3, 5)`
correspondem ao padrão `&(x, y)`, então `x` é o valor `3` e `y` é o valor `5`.

Também podemos usar padrões nas listas de parâmetros closure da mesma forma que em
listas de parâmetros de função porque closures são semelhantes a funções, como
discutido no Capítulo 13.

Neste ponto, você viu várias maneiras de usar padrões, mas os padrões não
funcionam da mesma forma em todos os lugares onde podemos usá-los. Em alguns lugares, os padrões devem
ser irrefutável; em outras circunstâncias, podem ser refutáveis. Nós discutiremos
esses dois conceitos a seguir.

[ignoring-values-in-a-pattern]: ch19-03-pattern-syntax.html#ignoring-values-in-a-pattern
