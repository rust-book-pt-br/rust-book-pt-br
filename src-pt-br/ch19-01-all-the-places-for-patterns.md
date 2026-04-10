## Todos os padrões de lugares podem ser usados

Os padrões aparecem em vários lugares no Rust, e você os tem usado muito
sem perceber! Esta seção discute todos os locais onde os padrões são
válido.

### `match` Arms

Conforme discutido no Capítulo 6, usamos padrões nos braços das expressões `match`.
Formalmente, as expressões ` match`são definidas como a palavra-chave ` match`, um valor para
match ligado e um ou mais braços match que consistem em um padrão e um
expressão a ser executada se o valor corresponder ao padrão desse braço, assim:

<!--
Formatado manualmente em vez de usar Markdown intencionalmente: Markdown não
  suporta código em itálico no corpo de um bloco como este!
-->

<pre><code>corresponder <em>VALUE</em> {
    <em>PATTERN</em> => <em>EXPRESSION</em>,
    <em>PATTERN</em> => <em>EXPRESSION</em>,
    <em>PATTERN</em> => <em>EXPRESSION</em>,
}</code></pre>

Por exemplo, aqui está a expressão `match` da Listagem 6-5 que corresponde a um
Valor `Option<i32>` na variável `x`:

```rust,ignore
match x {
    None => None,
    Some(i) => Some(i + 1),
}
```

Os padrões nesta expressão `match` são `None` e `Some(i)` para o
esquerda de cada seta.

Um requisito para expressões `match` é que elas sejam exaustivas em
no sentido de que todas as possibilidades para o valor na expressão `match` devem
ser contabilizado. Uma maneira de garantir que você cobriu todas as possibilidades é
tenha um padrão abrangente para o último braço: por exemplo, um nome de variável
combinar qualquer valor nunca pode falhar e, portanto, cobre todos os casos restantes.

O padrão específico `_` fará qualquer coisa com match, mas nunca se vincula a um
variável, por isso é frequentemente usado no último braço match. O padrão `_` pode ser
útil quando você deseja ignorar qualquer valor não especificado, por exemplo. Nós vamos
cobriremos o padrão `_` com mais detalhes em [“Ignorando valores em um
Padrão”][ignoring-values-in-a-pattern]<!-- ignore --> posteriormente neste capítulo.

### `let` Statements

Antes deste capítulo, havíamos discutido explicitamente apenas o uso de padrões com
`match ` e`if let `, mas na verdade também usamos padrões em outros lugares,
inclusive em instruções` let `. Por exemplo, considere isso simples
atribuição de variável com` let`:

```rust
let x = 5;
```

Cada vez que você usou uma instrução `let` como esta, você usou padrões,
embora você possa não ter percebido isso! Mais formalmente, uma instrução `let` parece
assim:

<!--
Formatado manualmente em vez de usar Markdown intencionalmente: Markdown não
  suporta código em itálico no corpo de um bloco como este!
-->

<pre>
<code>let <em>PATTERN</em> = <em>EXPRESSION</em>;</code>
</pre>

Em instruções como `let x = 5;` com um nome de variável no slot PATTERN, o
o nome da variável é apenas uma forma particularmente simples de padrão. Rust compara
a expressão em relação ao padrão e atribui quaisquer nomes que encontrar. Então, no
Exemplo `let x = 5;`, ` x`é um padrão que significa “vincular o que corresponde aqui a
a variável ` x`.” Como o nome ` x`é o padrão completo, esse padrão
efetivamente significa “vincular tudo à variável ` x`, qualquer que seja o valor”.

Para ver o aspecto de correspondência de padrões do `let` mais claramente, considere a Listagem
19-1, que usa um padrão com `let` para desestruturar uma tupla.


<Listing number="19-1" caption="Usando um padrão para desestruturar uma tupla e criar três variáveis de uma vez">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-01/src/main.rs:here}}
```

</Listing>

Aqui, match uma tupla contra um padrão. Rust compara o valor `(1, 2, 3)`
ao padrão ` (x, y, z)`e verifica se o valor corresponde ao padrão - ou seja,
ele vê que o número de elementos é o mesmo em ambos - então Rust liga ` 1`a
` x `,` 2 `para` y `e` 3 `para` z`. Você pode pensar neste padrão de tupla como um aninhamento
três padrões variáveis individuais dentro dele.

Se o número de elementos no padrão não match o número de elementos
na tupla, o tipo geral não será match e obteremos um erro do compilador. Para
Por exemplo, a Listagem 19-2 mostra uma tentativa de desestruturar uma tupla com três
elementos em duas variáveis, o que não funcionará.

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
`_ ` ou`..`, como você verá em [“Ignorando valores em um
Padrão”][ignoring-values-in-a-pattern]seção <!-- ignore -->. Se o problema
é que temos muitas variáveis no padrão, a solução é fazer com que o
digita match removendo variáveis para que o número de variáveis seja igual ao
número de elementos na tupla.

### Conditional `if let` Expressions

No Capítulo 6, discutimos como usar expressões `if let` principalmente como expressões mais curtas
maneira de escrever o equivalente a um `match` que corresponde apenas a um caso.
Opcionalmente, `if let` pode ter um `else` correspondente contendo código para executar se
o padrão no `if let` não corresponde ao match.

A Listagem 19-3 mostra que também é possível misturar expressões match `if let`, ` else
if`e ` else if let`. Fazer isso nos dá mais flexibilidade do que um
Expressão ` match`na qual podemos expressar apenas um valor para comparar com o
padrões. Além disso, Rust não exige que as condições em uma série de braços ` if
let`, ` else if`e ` else if let`estejam relacionadas entre si.

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

Essa estrutura condicional nos permite oferecer suporte a requisitos complexos. Com o
valores codificados que temos aqui, este exemplo imprimirá `Using purple as the
background color`.

Você pode ver que `if let` também pode introduzir novas variáveis que sombreiam as existentes
variáveis da mesma forma que os braços `match` podem: A linha `if let Ok(age) = age`
introduz uma nova variável ` age`que contém o valor dentro da variante ` Ok`,
sombreando a variável ` age`existente. Isso significa que precisamos colocar a condição ` if age >
30`dentro desse bloco: Não podemos combinar essas duas condições em ` if
let Ok(age) = age && age > 30`. O novo ` age`que queremos comparar com 30 não é
válido até que o novo escopo comece com as chaves.

A desvantagem de usar expressões `if let` é que o compilador não verifica
para exaustividade, enquanto com expressões `match` isso acontece. Se omitimos o
último bloco `else` e, portanto, perdeu o tratamento de alguns casos, o compilador
não nos alerta sobre o possível bug lógico.

### `while let` Conditional Loops

Semelhante em construção ao `if let`, o loop condicional ` while let`permite um
O loop ` while`será executado enquanto um padrão continuar até match. Na listagem
19-4, mostramos um loop ` while let`que espera mensagens enviadas entre threads,
mas neste caso verificando um ` Result`em vez de um ` Option`.

<Listing number="19-4" caption="Usando um loop `while let` para imprimir valores enquanto `rx.recv()` retornar `Ok`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-04/src/main.rs:here}}
```

</Listing>

Este exemplo imprime `1`, ` 2`e depois ` 3`. O método ` recv`leva o primeiro
mensagem sai do lado receptor do canal e retorna um ` Ok(value)`. Quando
vimos ` recv`pela primeira vez no Capítulo 16, desembrulhamos o erro diretamente ou
interagimos com ele como um iterator usando um loop ` for`. Como mostra a Listagem 19-4,
porém, também podemos usar ` while let`, porque o método ` recv`retorna um ` Ok`
cada vez que uma mensagem chega, desde que o remetente exista, e então produz um
` Err`assim que o lado do remetente se desconectar.

### Ciclos `for`

Em um loop `for`, o valor que segue diretamente a palavra-chave ` for`é um
padrão. Por exemplo, em ` for x in y`, ` x`é o padrão. Listagem 19-5
demonstra como usar um padrão em um loop ` for`para desestruturar ou quebrar
à parte, uma tupla como parte do loop ` for`.


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
e o índice desse valor, colocado em uma tupla. O primeiro valor produzido é
a tupla `(0, 'a')`. Quando este valor corresponder ao padrão ` (index,
value)`, o índice será ` 0`e o valor será ` 'a'`, imprimindo a primeira linha do
a saída.


### Function Parameters

Os parâmetros de função também podem ser padrões. O código na Listagem 19-6, que
declara uma função chamada `foo` que recebe um parâmetro chamado `x` do tipo
`i32` já deve parecer familiar.

<Listing number="19-6" caption="Uma assinatura de função usando padrões nos parâmetros">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-06/src/main.rs:here}}
```

</Listing>

A parte `x` é um padrão! Como fizemos com `let`, poderíamos match uma tupla em um
argumentos da função para o padrão. A Listagem 19-7 divide os valores em uma tupla
conforme o passamos para uma função.

<Listing number="19-7" file-name="src/main.rs" caption="Uma função com parâmetros que desestruturam uma tupla">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-07/src/main.rs}}
```

</Listing>

Este código imprime `Current location: (3, 5)`. Os valores ` &(3, 5)`match o
padrão ` &(x, y)`, então ` x`é o valor ` 3`e ` y`é o valor ` 5`.

Também podemos usar padrões nas listas de parâmetros closure da mesma forma que em
listas de parâmetros de função porque closures são semelhantes a funções, como
discutido no Capítulo 13.

Neste ponto, você viu várias maneiras de usar padrões, mas os padrões não
funcionam da mesma forma em todos os lugares onde podemos usá-los. Em alguns lugares, os padrões devem
ser irrefutável; em outras circunstâncias, podem ser refutáveis. Nós discutiremos
esses dois conceitos a seguir.

[ignoring-values-in-a-pattern]: ch19-03-pattern-syntax.html#ignoring-values-in-a-pattern
