## Sintaxe de Padrões

Nesta seção, reunimos toda a sintaxe válida em padrões e discutimos
por que e quando você pode querer usar cada um.

### Correspondendo a Literais

Como você viu no Capítulo 6, é possível corresponder padrões diretamente a
literais. O código a seguir mostra alguns exemplos:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-01-literals/src/main.rs:here}}
```

Este código imprime `one` porque o valor em `x` é `1`. Essa sintaxe é útil
quando você quer que o código execute uma ação ao receber um determinado
valor concreto.

### Correspondendo a Variáveis Nomeadas

Variáveis nomeadas são padrões irrefutáveis que correspondem a qualquer valor,
e já as usamos muitas vezes neste livro. No entanto, há uma complicação quando
você usa variáveis nomeadas em expressões `match`, `if let` ou `while let`.
Como cada um desses tipos de expressão inicia um novo escopo, variáveis
declaradas como parte de um padrão dentro dessas expressões irão sombrear
aquelas com o mesmo nome fora delas, como acontece com todas as variáveis. Na
Listagem 19-11, declaramos uma variável chamada `x` com o valor `Some(5)` e uma
variável `y` com o valor `10`. Em seguida, criamos uma expressão `match` sobre
o valor `x`. Observe os padrões nos braços do `match` e o `println!` ao final,
e tente descobrir o que o código imprimirá antes de executá-lo ou continuar a
leitura.

<Listing number="19-11" file-name="src/main.rs" caption="Uma expressão `match` com um braço que introduz uma nova variável que sombreia uma variável `y` existente">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-11/src/main.rs:here}}
```

</Listing>

Vejamos o que acontece quando a expressão `match` é executada. O padrão
do primeiro braço não corresponde ao valor armazenado em `x`, então a
execução continua.

O padrão no segundo braço de `match` introduz uma nova variável chamada `y`,
que corresponderá a qualquer valor dentro de um `Some`. Como estamos em um novo
escopo dentro da expressão `match`, essa é uma nova variável `y`, e não o `y`
que declaramos no começo com o valor `10`. Esse novo binding `y` corresponderá
a qualquer valor dentro de um `Some`, que é exatamente o que temos em `x`.
Portanto, esse novo `y` se vincula ao valor interno de `Some` em `x`. Esse
valor é `5`, então a expressão desse braço é executada e imprime
`Matched, y = 5`.

Se `x` fosse `None` em vez de `Some(5)`, os padrões dos dois primeiros
braços não corresponderiam, então o valor cairia no padrão com
sublinhado. Como não introduzimos a variável `x` no padrão desse braço,
o `x` usado na expressão ainda seria o `x` externo, que não foi
sombreado. Nesse caso hipotético, o `match` imprimiria `Default case,
x = None`.

Quando a expressão `match` termina, seu escopo também termina, assim como o
escopo do `y` interno. O último `println!` produz `at the end: x = Some(5), y = 10`.

Para criar uma expressão `match` que compare os valores do `x` externo e de
`y`, em vez de introduzir uma nova variável que sombreie a variável `y`
existente, precisaríamos usar um match guard. Falaremos sobre match guards mais
adiante, na seção
[“Adicionando Condicionais com Match Guards”](#extra-conditionals-with-match-guards)<!-- ignore -->.

<!-- Old headings. Do not remove or links may break. -->
<a id="multiple-patterns"></a>

### Correspondendo a Múltiplos Padrões

Em expressões `match`, você pode corresponder a vários padrões usando a sintaxe
`|`, que é o operador de padrão _ou_. Por exemplo, no código a seguir,
comparamos o valor de `x` com os braços de `match`, sendo que o primeiro deles
tem uma opção _ou_; isto é, se o valor de `x` corresponder a qualquer um dos
valores naquele braço, o código desse braço será executado:


```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-02-multiple-patterns/src/main.rs:here}}
```

Este código imprime `one or two`.

### Correspondendo a Intervalos de Valores com `..=`

A sintaxe `..=` nos permite corresponder a um intervalo inclusivo de valores.
No código a seguir, quando um padrão corresponde a qualquer um dos valores
dentro do intervalo dado, aquele braço será executado:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-03-ranges/src/main.rs:here}}
```

Se `x` for `1`, `2`, `3`, `4` ou `5`, o primeiro braço corresponderá. Essa
sintaxe é mais conveniente para vários valores do que usar o operador `|` para
expressar a mesma ideia; se fôssemos usar `|`, teríamos de especificar
`1 | 2 | 3 | 4 | 5`. Especificar um intervalo é bem mais curto, especialmente
se quisermos corresponder, digamos, a qualquer número entre 1 e 1.000!

O compilador verifica, em tempo de compilação, se o intervalo não está vazio.
Como os únicos tipos para os quais Rust consegue determinar isso são `char` e
valores numéricos, intervalos só são permitidos com números ou `char`.

Eis um exemplo usando intervalos de valores `char`:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-04-ranges-of-char/src/main.rs:here}}
```

Rust consegue dizer que `'c'` está dentro do intervalo do primeiro padrão e
imprime `early ASCII letter`.

### Desestruturando para Separar Valores

Também podemos usar padrões para desestruturar structs, enums e tuplas, de modo
a usar partes diferentes desses valores. Vamos examinar cada caso.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-structs"></a>

#### Structs

A Listagem 19-12 mostra uma struct `Point` com dois campos, `x` e `y`, que
podemos separar usando um padrão em uma instrução `let`.

<Listing number="19-12" file-name="src/main.rs" caption="Desestruturando os campos de uma struct em variáveis separadas">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-12/src/main.rs}}
```

</Listing>

Esse código cria as variáveis `a` e `b`, que correspondem aos valores dos
campos `x` e `y` da struct `p`. Este exemplo mostra que os nomes das variáveis
no padrão não precisam corresponder aos nomes dos campos da struct. No entanto,
é comum usar os mesmos nomes dos campos para as variáveis, a fim de facilitar a
lembrança de quais variáveis vieram de quais campos. Por causa desse uso comum,
e porque escrever `let Point { x: x, y: y } = p;` contém bastante duplicação,
Rust tem uma forma abreviada para padrões que correspondem aos campos de uma
struct: você só precisa listar o nome do campo da struct, e as variáveis
criadas a partir do padrão terão os mesmos nomes. A Listagem 19-13 se comporta
da mesma forma que o código da Listagem 19-12, mas as variáveis criadas no
padrão `let` são `x` e `y` em vez de `a` e `b`.

<Listing number="19-13" file-name="src/main.rs" caption="Desestruturando campos de struct usando a forma abreviada de campos">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-13/src/main.rs}}
```

</Listing>

Esse código cria as variáveis `x` e `y`, que correspondem aos campos `x` e `y`
da variável `p`. O resultado é que `x` e `y` contêm os valores da struct `p`.

Também podemos desestruturar usando valores literais como parte do padrão da
struct em vez de criar variáveis para todos os campos. Fazer isso nos permite
testar alguns dos campos contra valores específicos ao criar variáveis para
desestruturar os outros campos.

Na Listagem 19-14, temos uma expressão `match` que separa valores `Point`
em três casos: pontos que ficam diretamente no eixo `x` (o que é verdade quando
`y = 0`), no eixo `y` (`x = 0`) ou em nenhum dos eixos.

<Listing number="19-14" file-name="src/main.rs" caption="Desestruturando e comparando valores literais em um único padrão">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-14/src/main.rs:here}}
```

</Listing>

O primeiro braço corresponde a qualquer ponto que esteja no eixo `x`,
especificando que o campo `y` corresponde ao literal `0`. O padrão ainda
cria uma variável `x`, que podemos usar no código desse braço.

Da mesma forma, o segundo braço corresponde a qualquer ponto no eixo `y`,
especificando que o campo `x` tem valor `0`, e cria uma variável `y` para o
valor do campo `y`. O terceiro braço não especifica nenhum literal, então
corresponde a qualquer outro `Point` e cria variáveis para os campos `x` e `y`.

Neste exemplo, o valor `p` corresponde ao segundo braço porque `x`
contém `0`, então esse código imprimirá `On the y axis at 7`.

Lembre-se de que uma expressão `match` para de verificar os braços depois de
encontrar o primeiro padrão correspondente; assim, embora `Point { x: 0, y: 0 }`
esteja no eixo `x` e também no eixo `y`, esse código imprimiria apenas
`On the x axis at 0`.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-enums"></a>

#### Enums

Desestruturamos enums neste livro (por exemplo, na Listagem 6-5 do Capítulo 6),
mas ainda não discutimos explicitamente que o padrão para desestruturar um enum
corresponde à maneira como os dados armazenados nele são definidos. Como
exemplo, na Listagem 19-15 usamos o enum `Message` da Listagem 6-2 e escrevemos
um `match` com padrões que desestruturam cada valor interno.

<Listing number="19-15" file-name="src/main.rs" caption="Desestruturando variantes de enum que guardam diferentes tipos de valores">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-15/src/main.rs}}
```

</Listing>

Esse código imprimirá `Change color to red 0, green 160, and blue 255`. Experimente
alterar o valor de `msg` para ver o código dos outros braços ser executado.

Para variantes de enum sem dados, como `Message::Quit`, não podemos
desestruturar ainda mais o valor. Só podemos corresponder ao valor literal
`Message::Quit`, e não há variáveis nesse padrão.

Para variantes de enum do tipo struct, como `Message::Move`, podemos usar um
padrão semelhante ao que usamos para structs. Após o nome da variante,
colocamos chaves e listamos os campos com variáveis para separar as partes e
usá-las no código desse braço. Aqui usamos a forma abreviada, como fizemos na
Listagem 19-13.

Para variantes de enum semelhantes a tuplas, como `Message::Write`, que contém
uma tupla com um elemento, e `Message::ChangeColor`, que contém uma tupla com
três elementos, o padrão é semelhante ao que usamos para tuplas. O número de
variáveis no padrão deve corresponder ao número de elementos da variante com a
qual estamos fazendo a correspondência.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-nested-structs-and-enums"></a>

#### Structs e Enums Aninhados

Até agora, todos os nossos exemplos fizeram correspondência com structs ou
enums de um único nível, mas a correspondência também funciona com itens
aninhados. Por exemplo, podemos refatorar o código da Listagem 19-15 para dar
suporte a cores RGB e HSV na mensagem `ChangeColor`, como mostrado na Listagem
19-16.

<Listing number="19-16" caption="Fazendo correspondência em enums aninhados">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-16/src/main.rs}}
```

</Listing>

O padrão do primeiro braço na expressão `match` corresponde a uma
variante `Message::ChangeColor` que contém uma variante `Color::Rgb`; então,
o padrão associa os três valores internos do tipo `i32`. O padrão do segundo
braço também corresponde a uma variante `Message::ChangeColor`, mas o enum
interno corresponde a `Color::Hsv`. Podemos especificar essas condições
complexas em uma única expressão `match`, mesmo quando dois enums estão
envolvidos.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-structs-and-tuples"></a>

#### Structs e Tuplas

Podemos misturar e aninhar padrões de desestruturação de maneiras ainda mais
complexas. O exemplo a seguir mostra uma desestruturação mais elaborada em que
aninhamos structs e tuplas dentro de uma tupla e extraímos todos os valores
primitivos:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-05-destructuring-structs-and-tuples/src/main.rs:here}}
```

Esse código nos permite dividir tipos complexos em suas partes componentes para
que possamos usar separadamente os valores que nos interessam.

A desestruturação com padrões é uma maneira conveniente de usar partes de valores,
como o valor de cada campo de uma struct, separadamente umas das outras.

### Ignorando Valores em um Padrão

Você viu que, às vezes, é útil ignorar valores em um padrão, como
no último braço de um `match`, para obter um caso genérico que não faz
nada de fato, mas cobre todos os valores possíveis restantes. Existem algumas
formas de ignorar valores inteiros ou partes de valores em um padrão: usando o
padrão `_` (que você já viu), usando `_` dentro de outro padrão, usando um nome
que começa com sublinhado ou usando `..` para ignorar as partes restantes de um
valor. Vamos explorar como e por que usar cada um desses padrões.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-an-entire-value-with-_"></a>

#### Um Valor Inteiro com `_`

Usamos o sublinhado como um padrão curinga que corresponde a qualquer valor,
mas não o vincula a uma variável. Isso é especialmente útil como último braço de uma
expressão `match`, mas também podemos usá-lo em qualquer padrão, inclusive em
parâmetros de função, como mostra a Listagem 19-17.

<Listing number="19-17" file-name="src/main.rs" caption="Usando `_` em uma assinatura de função">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-17/src/main.rs}}
```

</Listing>

Este código ignorará completamente o valor `3` passado como primeiro argumento
e imprimirá `This code only uses the y parameter: 4`.

Na maioria dos casos, quando você não precisa mais de um parâmetro específico de uma função,
você mudaria a assinatura para não incluí-lo. Ignorar um parâmetro pode ser
especialmente útil quando, por exemplo, você está implementando uma trait e precisa
seguir uma determinada assinatura, mas o corpo da sua implementação não usa um dos
parâmetros. Assim, você evita o aviso do compilador sobre parâmetro não utilizado,
que apareceria se usasse um nome normal.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-parts-of-a-value-with-a-nested-_"></a>

#### Partes de um Valor com um `_` Aninhado

Também podemos usar `_` dentro de outro padrão para ignorar apenas parte de um
valor, por exemplo, quando queremos testar só uma parte dele, mas não precisamos
das outras partes no código correspondente que será executado. A Listagem 19-18
mostra um código responsável por gerenciar o valor de uma configuração. A regra
de negócio é que o usuário não deve poder sobrescrever uma personalização já
existente de uma configuração, mas pode definir um valor se ela estiver
atualmente sem valor.

<Listing number="19-18" caption="Usando sublinhado dentro de padrões que correspondem a variantes `Some` quando não precisamos usar o valor dentro de `Some`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-18/src/main.rs:here}}
```

</Listing>

Esse código imprimirá `Can't overwrite an existing customized value` e depois
`setting is Some(5)`. No primeiro braço do `match`, não precisamos vincular nem usar
os valores dentro das variantes `Some`, mas precisamos testar o caso
em que `setting_value` e `new_setting_value` sejam ambos `Some`. Nesse
caso, imprimimos o motivo para não alterar `setting_value`, e ele permanece
inalterado.

Em todos os outros casos, expressos pelo padrão `_` no segundo braço
(ou seja, se `setting_value` ou `new_setting_value` for `None`),
queremos permitir que `new_setting_value` se torne `setting_value`.

Também podemos usar sublinhados em vários pontos de um padrão para ignorar
valores específicos. A Listagem 19-19 mostra como ignorar o segundo e o
quarto valores de uma tupla com cinco itens.

<Listing number="19-19" caption="Ignorando várias partes de uma tupla">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-19/src/main.rs:here}}
```

</Listing>

Esse código imprimirá `Some numbers: 2, 8, 32`, e os valores `4` e `16` serão
ignorados.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-an-unused-variable-by-starting-its-name-with-_"></a>

#### Uma Variável Não Utilizada Iniciando com `_`

Se você criar uma variável, mas não a usar em lugar nenhum, Rust normalmente
emitirá um aviso, porque uma variável não utilizada pode indicar um bug. No
entanto, às vezes é útil criar uma variável que você ainda não vai usar, como
quando está prototipando ou apenas começando um projeto. Nessa situação, você
pode dizer ao Rust para não avisar sobre a variável não utilizada iniciando seu
nome com um sublinhado. Na Listagem 19-20, criamos duas variáveis não
utilizadas, mas, quando compilarmos esse código, devemos receber aviso apenas
sobre uma delas.

<Listing number="19-20" file-name="src/main.rs" caption="Começando o nome de uma variável com sublinhado para evitar avisos de variável não utilizada">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-20/src/main.rs}}
```

</Listing>

Aqui, recebemos um aviso sobre não usar a variável `y`, mas não recebemos um
aviso sobre não usar `_x`.

Observe que há uma diferença sutil entre usar apenas `_` e usar um nome
que começa com sublinhado. A sintaxe `_x` ainda vincula o valor à
variável, enquanto `_` não vincula nada. Para mostrar um caso em que essa
distinção é importante, a Listagem 19-21 produzirá um erro.

<Listing number="19-21" caption="Uma variável não usada que começa com sublinhado ainda associa o valor, o que pode tomar ownership dele">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-21/src/main.rs:here}}
```

</Listing>

Receberemos um erro porque o valor `s` ainda será movido para `_s`,
o que nos impede de usar `s` novamente. Já o sublinhado sozinho
nunca se vincula ao valor. A Listagem 19-22 compilará sem erros
porque `s` não é movido para `_`.

<Listing number="19-22" caption="Usar um sublinhado não associa o valor">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-22/src/main.rs:here}}
```

</Listing>

Esse código funciona perfeitamente porque nunca vinculamos `s` a nada; ele não é movido.

<a id="ignoring-remaining-parts-of-a-value-with-"></a>

#### Partes Restantes de um Valor com `..`

Em valores com muitas partes, podemos usar a sintaxe `..` para selecionar
partes específicas e ignorar o restante, sem precisar listar sublinhados para cada
valor ignorado. O padrão `..` ignora qualquer parte de um valor que não tenhamos
correspondido explicitamente no restante do padrão. Na Listagem 19-23, temos uma
struct `Point` que contém uma coordenada no espaço tridimensional. Na
expressão `match`, queremos operar apenas sobre a coordenada `x` e ignorar
os valores dos campos `y` e `z`.

<Listing number="19-23" caption="Ignorando todos os campos de um `Point`, exceto `x`, usando `..`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-23/src/main.rs:here}}
```

</Listing>

Listamos o valor `x` e depois incluímos apenas o padrão `..`. Isso é mais simples
do que listar `y: _` e `z: _`, especialmente quando estamos trabalhando com
structs que têm muitos campos em situações em que apenas um ou dois deles são
relevantes.

A sintaxe `..` será expandida para quantos valores forem necessários. A
Listagem 19-24 mostra como usar `..` com uma tupla.

<Listing number="19-24" file-name="src/main.rs" caption="Fazendo correspondência apenas com o primeiro e o último valores de uma tupla e ignorando todos os demais">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-24/src/main.rs}}
```

</Listing>

Nesse código, o primeiro e o último valores são correspondidos com `first` e `last`.
O `..` corresponderá e ignorará tudo o que estiver no meio.

No entanto, o uso de `..` precisa ser inequívoco. Se não ficar claro quais valores
devem ser correspondidos e quais devem ser ignorados, Rust emitirá um erro.
A Listagem 19-25 mostra um exemplo de uso ambíguo de `..` e, por isso, não
compila.

<Listing number="19-25" file-name="src/main.rs" caption="Uma tentativa de usar `..` de forma ambígua">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-25/src/main.rs}}
```

</Listing>

Quando compilamos este exemplo, obtemos este erro:

```console
{{#include ../listings/ch19-patterns-and-matching/listing-19-25/output.txt}}
```

É impossível para Rust determinar quantos valores na tupla devem ser ignorados
antes de associar um valor a `second` e quantos valores adicionais devem ser
ignorados depois disso. Esse código pode significar que queremos ignorar `2`, vincular
`second` a `4` e depois ignorar `8`, `16` e `32`; ou que queremos ignorar
`2` e `4`, vincular `second` a `8` e depois ignorar `16` e `32`; e assim por diante.
O nome da variável `second` não tem nenhum significado especial para Rust, então recebemos um
erro do compilador porque usar `..` em dois lugares dessa forma é ambíguo.

<!-- Old headings. Do not remove or links may break. -->

<a id="extra-conditionals-with-match-guards"></a>

### Adicionando Condicionais com Match Guards

Um _match guard_ é uma condição `if` adicional, especificada após o padrão em
um braço de `match`, que também precisa ser satisfeita para que esse braço seja
escolhido. Match guards são úteis para expressar ideias mais complexas do que
um padrão sozinho permite. Observe, porém, que eles estão disponíveis apenas em
expressões `match`, não em expressões `if let` ou `while let`.

A condição pode usar variáveis criadas no padrão. A Listagem 19-26 mostra um
`match` em que o primeiro braço tem o padrão `Some(x)` e também uma
condição `if x % 2 == 0` (que será `true` se o número for par).

<Listing number="19-26" caption="Adicionando um match guard a um padrão">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-26/src/main.rs:here}}
```

</Listing>

Esse exemplo imprimirá `The number 4 is even`. Quando `num` é comparado com o
padrão do primeiro braço, ele corresponde porque `Some(4)` corresponde a
`Some(x)`. Então, o match guard verifica se o resto da divisão de `x` por 2 é
igual a 0 e, como é esse o caso, o primeiro braço é selecionado.

Se `num` fosse `Some(5)`, o match guard do primeiro braço seria
`false`, porque o resto de 5 dividido por 2 é 1, e não
0. Rust passaria então para o segundo braço, que corresponderia, porque
ele não tem match guard e, portanto, corresponde a qualquer variante `Some`.

Não há como expressar a condição `if x % 2 == 0` dentro de um padrão, então
o match guard nos permite representar essa lógica. A desvantagem dessa
expressividade adicional é que o compilador não tenta verificar
a exaustividade quando há match guards envolvidos.

Ao discutir a Listagem 19-11, mencionamos que poderíamos usar match guards para
resolver nosso problema de sombreamento de padrões. Lembre-se de que criamos
uma nova variável dentro do padrão na expressão `match`, em vez de usar a
variável externa. Essa nova variável significava que não poderíamos testar o
valor da variável de fora. A Listagem 19-27 mostra como usar um match guard para
corrigir esse problema.

<Listing number="19-27" file-name="src/main.rs" caption="Usando um match guard para testar igualdade com uma variável externa">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-27/src/main.rs}}
```

</Listing>

Esse código agora imprimirá `Default case, x = Some(5)`. O padrão no segundo
braço do `match` não introduz uma nova variável `y` que sombrearia o `y` externo,
o que significa que podemos usar o `y` externo no match guard. Em vez de
especificar o padrão como `Some(y)`, o que teria sombreado o `y` externo,
especificamos `Some(n)`. Isso cria uma nova variável `n` que não sombreia nada,
porque não existe nenhuma variável `n` fora do `match`.

O match guard `if n == y` não é um padrão e, portanto, não introduz novas
variáveis. Esse `y` _é_ o `y` externo, em vez de um novo `y` sombreando-o, e
podemos procurar um valor igual ao `y` externo comparando
`n` com `y`.

Você também pode usar o operador _or_ `|` em um braço com match guard para
especificar múltiplos padrões; a condição do match guard será aplicada a todos
eles.
A Listagem 19-28 mostra a precedência ao combinar um padrão com `|`
e um match guard. A parte importante deste exemplo é que o match guard
`if y` se aplica a `4`, `5` _e_ `6`, embora possa parecer, à primeira vista, que
ele se aplica apenas a `6`.

<Listing number="19-28" caption="Combinando vários padrões com um match guard">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-28/src/main.rs:here}}
```

</Listing>

A condição diz que o braço só corresponde se o valor de `x` for
igual a `4`, `5` ou `6` _e_ se `y` for `true`. Quando esse código é executado, o
padrão do primeiro braço corresponde porque `x` é `4`, mas o match guard `if y`
é `false`, então o primeiro braço não é escolhido. O código passa para o segundo
braço, que corresponde, e o programa imprime `no`. A razão é que
a condição `if` se aplica a todo o padrão `4 | 5 | 6`, e não apenas ao último
valor `6`. Em outras palavras, a precedência de um match guard em relação a um
padrão se comporta assim:

```text
(4 | 5 | 6) if y => ...
```

em vez de assim:

```text
4 | 5 | (6 if y) => ...
```

Depois de executar o código, o comportamento da precedência fica evidente: se o
match guard fosse aplicado apenas ao valor final da lista de valores
especificados com o operador `|`, o braço teria correspondido e o programa
teria impresso `yes`.

<!-- Old headings. Do not remove or links may break. -->

<a id="-bindings"></a>

### Usando Bindings `@`

O operador _at_ `@` nos permite criar uma variável que contém um valor ao mesmo
tempo em que testamos esse valor em um padrão. Na Listagem 19-29, queremos
verificar se o campo `id` de `Message::Hello` está dentro do intervalo
`3..=7`. Também queremos vincular esse valor à variável `id` para que possamos
usá-lo no código associado ao braço.

<Listing number="19-29" caption="Usando `@` para associar um valor em um padrão ao mesmo tempo em que o testa">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-29/src/main.rs:here}}
```

</Listing>

Esse exemplo imprimirá `Found an id in range: 5`. Ao especificar `id @` antes do
intervalo `3..=7`, capturamos qualquer valor que corresponda ao intervalo em uma
variável chamada `id`, ao mesmo tempo em que testamos se o valor corresponde ao
padrão de intervalo.

No segundo braço, em que temos apenas um intervalo especificado no padrão, o
código associado ao braço não possui uma variável contendo o valor real do campo
`id`. O valor desse campo poderia ser 10, 11 ou 12, mas o código associado a
esse padrão não sabe qual deles é. Esse código não pode usar o valor do campo
`id`, porque não o salvamos em uma variável.

No último braço, em que especificamos uma variável sem intervalo, temos
o valor disponível para uso no código do braço em uma variável chamada `id`. Isso
acontece porque usamos a sintaxe abreviada do campo da struct. Mas não
aplicamos nenhum teste ao valor do campo `id` nesse braço, como fizemos nos
dois primeiros: qualquer valor corresponderia a esse padrão.

Usar `@` nos permite testar um valor e salvá-lo em uma variável dentro de um padrão.

## Resumo

Os padrões de Rust são muito úteis para distinguir entre diferentes tipos de
dados. Quando usados em expressões `match`, Rust garante que os padrões cubram
todos os valores possíveis, ou o programa não compila. Padrões em instruções `let`
e em parâmetros de função tornam essas construções mais úteis, permitindo
desestruturar valores em partes menores e atribuir essas partes a
variáveis. Podemos criar padrões simples ou complexos para atender às nossas necessidades.

A seguir, no penúltimo capítulo do livro, veremos alguns aspectos avançados de
vários recursos de Rust.
