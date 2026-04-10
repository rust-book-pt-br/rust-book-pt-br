## Sintaxe do padrão

Nesta seção, reunimos toda a sintaxe válida em padrões e discutimos
por que e quando você pode querer usar cada um.

### Matching Literals

Como você viu no Capítulo 6, você pode comparar padrões match diretamente com literais. O
o código a seguir fornece alguns exemplos:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-01-literals/src/main.rs:here}}
```

Este código imprime `one` porque o valor em `x` é `1`. Esta sintaxe é útil
quando você deseja que seu código execute uma ação se obtiver uma determinada ação concreta
valor.

### Matching Named Variables

Variáveis nomeadas são padrões irrefutáveis que match qualquer valor, e usamos
muitas vezes neste livro. No entanto, há uma complicação quando você usa
variáveis nomeadas em expressões `match`, ` if let`ou ` while let`. Porque cada
desses tipos de expressões inicia um novo escopo, variáveis declaradas como parte de
um padrão dentro dessas expressões irá sombrear aqueles com o mesmo nome fora
os construtos, como é o caso de todas as variáveis. Na Listagem 19-11, declaramos
uma variável chamada ` x`com o valor ` Some(5)`e uma variável ` y`com o valor
` 10 `. Em seguida, criamos uma expressão` match `no valor` x `. Olhe para o
padrões nos braços match e` println!`no final, e tente descobrir
o que o código irá imprimir antes de executá-lo ou ler mais.

<Listing number="19-11" file-name="src/main.rs" caption="Uma expressão `match` com um braço que introduz uma nova variável que sombreia uma variável `y` existente">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-11/src/main.rs:here}}
```

</Listing>

Vejamos o que acontece quando a expressão `match` é executada. O padrão
no primeiro braço match não match o valor definido de `x`, então o código
continua.

O padrão no segundo braço match introduz uma nova variável chamada `y` que
match qualquer valor dentro de um valor `Some`. Porque estamos em um novo escopo dentro
expressão ` match`, esta é uma nova variável ` y`, não o ` y`que declaramos em
começando com o valor ` 10`. Esta nova ligação ` y`irá match qualquer valor
dentro de um ` Some`, que é o que temos no ` x`. Portanto, este novo ` y`se liga a
o valor interno de ` Some`em ` x`. Esse valor é ` 5`, então a expressão para
esse braço executa e imprime ` Matched, y = 5`.

Se `x` fosse um valor `None` em vez de `Some(5)`, os padrões no primeiro
dois braços não teriam correspondido, então o valor teria correspondido ao
sublinhado. Não introduzimos a variável ` x`no padrão do
braço de sublinhado, então o ` x`na expressão ainda é o ` x`externo que não foi
sido sombreado. Neste caso hipotético, ` match`imprimiria ` Default case,
x = None`.

Quando a expressão `match` é concluída, seu escopo termina, assim como o escopo de
o `y` interno. O último `println!` produz `at the end: x = Some(5), y = 10`.

Para criar uma expressão `match` que compare os valores do `x` externo e
`y `, em vez de introduzir uma nova variável que obscureça o` y`existente
variável, precisaríamos usar uma condicional de proteção match. Nós vamos conversar
sobre os guardas match posteriormente em [“Adicionando condicionais com correspondência
Guardas”](#adding-conditionals-with-match-guards)Seção <!-- ignore -->.

<!-- Old headings. Do not remove or links may break. -->
<a id="multiple-patterns"></a>

### Combinando vários padrões

Nas expressões `match`, você pode match vários padrões usando a sintaxe ` |`,
que é o operador padrão _ou_. Por exemplo, no código a seguir, match
o valor de `x` em relação aos braços match, o primeiro dos quais tem uma opção _ou_,
ou seja, se o valor de `x` corresponder a qualquer um dos valores nesse braço, isso
arm’s code will run:


```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-02-multiple-patterns/src/main.rs:here}}
```

Este código imprime `one or two`.

### Correspondência de intervalos de valores com `..=`

A sintaxe `..=` nos permite match para um intervalo inclusivo de valores. No
código a seguir, quando um padrão corresponde a qualquer um dos valores dentro do determinado
alcance, esse braço executará:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-03-ranges/src/main.rs:here}}
```

Se `x` for `1`, ` 2`, ` 3`, ` 4`ou ` 5`, o primeiro braço será match. Esta sintaxe é
mais conveniente para vários valores match do que usar o operador `|` para
express the same idea; if we were to use `|`, we would have to specify `1 | 2 |
3 | 4 | 5`. Specifying a range is much shorter, especially if we want to match,
digamos, qualquer número entre 1 e 1.000!

O compilador verifica se o intervalo não está vazio em tempo de compilação e porque o
apenas os tipos para os quais Rust pode dizer se um intervalo está vazio ou não são `char` e
valores numéricos, os intervalos só são permitidos com valores numéricos ou `char`.

Here is an example using ranges of `char` values:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-04-ranges-of-char/src/main.rs:here}}
```

Rust pode dizer que `'c'` está dentro do intervalo do primeiro padrão e imprime `early
ASCII letter`.

### Destructuring to Break Apart Values

Também podemos usar padrões para desestruturar estruturas, enumerações e tuplas para usar
diferentes partes desses valores. Vamos examinar cada valor.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-structs"></a>

#### Structs

A Listagem 19-12 mostra uma estrutura `Point` com dois campos, `x` e `y`, que podemos
separe usando um padrão com uma instrução ` let`.

<Listing number="19-12" file-name="src/main.rs" caption="Desestruturando os campos de uma struct em variáveis separadas">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-12/src/main.rs}}
```

</Listing>

Este código cria as variáveis `a` e `b` que match os valores do `x`
e ` y`da estrutura ` p`. Este exemplo mostra que os nomes dos
variáveis ​​no padrão não precisam match os nomes dos campos da estrutura.
No entanto, é comum match os nomes das variáveis aos nomes dos campos para torná-lo
mais fácil lembrar quais variáveis vieram de quais campos. Por causa disso
uso comum e porque escrever ` let Point { x: x, y: y } = p;`contém um
muita duplicação, Rust tem uma abreviação para padrões que os campos de estrutura match:
Você só precisa listar o nome do campo struct e as variáveis criadas
do padrão terão os mesmos nomes. A Listagem 19-13 se comporta da mesma
maneira como o código na Listagem 19-12, mas as variáveis criadas no ` let`
padrão são ` x`e ` y`em vez de ` a`e ` b`.

<Listing number="19-13" file-name="src/main.rs" caption="Desestruturando campos de struct usando a forma abreviada de campos">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-13/src/main.rs}}
```

</Listing>

Este código cria as variáveis `x` e `y` que match os campos `x` e `y`
da variável ` p`. O resultado é que as variáveis ` x`e ` y`contêm o
valores da estrutura ` p`.

Também podemos desestruturar com valores literais como parte do padrão struct
em vez de criar variáveis para todos os campos. Fazer isso nos permite testar
alguns dos campos para valores específicos ao criar variáveis para
desestruturar os outros campos.

Na Listagem 19-14, temos uma expressão `match` que separa os valores `Point`
em três casos: pontos que ficam diretamente no eixo ` x`(o que é verdade quando
` y = 0 `), no eixo` y `(` x = 0`) ou em nenhum dos eixos.

<Listing number="19-14" file-name="src/main.rs" caption="Desestruturando e comparando valores literais em um único padrão">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-14/src/main.rs:here}}
```

</Listing>

O primeiro braço match qualquer ponto que esteja no eixo `x` especificando que
o campo `y` corresponde se seu valor corresponder ao literal `0`. O padrão ainda
cria uma variável ` x`que podemos usar no código deste braço.

Da mesma forma, o segundo braço corresponde a qualquer ponto no eixo `y` especificando que
o campo `x` corresponde se seu valor for `0` e cria uma variável `y` para o
valor do campo `y`. O terceiro braço não especifica nenhum literal, então
corresponde a qualquer outro ` Point`e cria variáveis para os campos ` x`e ` y`.

Neste exemplo, o valor `p` corresponde ao segundo braço em virtude de `x`
contendo um ` 0`, então este código imprimirá ` On the y axis at 7`.

Lembre-se de que uma expressão `match` para de verificar os braços depois de encontrar o
primeiro padrão correspondente, mesmo que `Point { x: 0, y: 0 }` esteja no eixo `x`
e o eixo ` y`, este código imprimiria apenas ` On the x axis at 0`.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-enums"></a>

#### Enums

Desestruturamos enums neste livro (por exemplo, Listagem 6-5 no Capítulo 6),
mas ainda não discutimos explicitamente que o padrão para desestruturar um enum
corresponde à forma como os dados armazenados na enumeração são definidos. Como um
Por exemplo, na Listagem 19-15, usamos o enum `Message` da Listagem 6-2 e escrevemos
um `match` com padrões que irão desestruturar cada valor interno.

<Listing number="19-15" file-name="src/main.rs" caption="Desestruturando variantes de enum que guardam diferentes tipos de valores">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-15/src/main.rs}}
```

</Listing>

Este código imprimirá `Change color to red 0, green 160, and blue 255`. Experimente
alterando o valor de ` msg`para ver o código dos outros braços executados.

Para variantes enum sem quaisquer dados, como `Message::Quit`, não podemos desestruturar
o valor ainda mais. Só podemos match no valor literal ` Message::Quit`,
e nenhuma variável está nesse padrão.

Para variantes de enum do tipo struct, como `Message::Move`, podemos usar um padrão
semelhante ao padrão que especificamos para estruturas match. Após o nome da variante, nós
coloque colchetes e depois liste os campos com variáveis para que possamos quebrar
separe as peças para usar no código deste braço. Aqui usamos a abreviatura
formulário como fizemos na Listagem 19-13.

Para variantes de enum semelhantes a tupla, como `Message::Write` que contém uma tupla com um
elemento e `Message::ChangeColor` que contém uma tupla com três elementos, o
padrão é semelhante ao padrão que especificamos para tuplas match. O número de
variáveis no padrão devem match o número de elementos na variante que estamos
correspondência.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-nested-structs-and-enums"></a>

#### Estruturas e Enums aninhados

Até agora, todos os nossos exemplos combinaram estruturas ou enums com um nível de profundidade,
mas a correspondência também pode funcionar em itens aninhados! Por exemplo, podemos refatorar o
código na Listagem 19-15 para suportar cores RGB e HSV no `ChangeColor`
mensagem, conforme mostrado na Listagem 19-16.

<Listing number="19-16" caption="Fazendo correspondência em enums aninhadas">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-16/src/main.rs}}
```

</Listing>

O padrão do primeiro braço na expressão `match` corresponde a um
Variante enum `Message::ChangeColor` que contém uma variante `Color::Rgb`; então,
o padrão se liga aos três valores ` i32`internos. O padrão do segundo
arm também corresponde a uma variante de enum ` Message::ChangeColor`, mas o enum interno
corresponde a ` Color::Hsv`. Podemos especificar essas condições complexas em um
Expressão ` match`, mesmo que duas enumerações estejam envolvidas.

<!-- Old headings. Do not remove or links may break. -->

<a id="destructuring-structs-and-tuples"></a>

#### Estruturas e Tuplas

Podemos misturar match e aninhar padrões de desestruturação de maneiras ainda mais complexas.
O exemplo a seguir mostra uma desestruturação complicada onde aninhamos estruturas e
tuplas dentro de uma tupla e desestrutura todos os valores primitivos:

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/no-listing-05-destructuring-structs-and-tuples/src/main.rs:here}}
```

Este código nos permite dividir tipos complexos em suas partes componentes para que possamos
use os valores nos quais estamos interessados separadamente.

A desestruturação com padrões é uma maneira conveniente de usar pedaços de valores, como
como o valor de cada campo em uma estrutura, separadamente um do outro.

### Ignorando valores em um padrão

Você viu que às vezes é útil ignorar valores em um padrão, como
no último braço de um `match`, para obter um resumo que na verdade não funciona
qualquer coisa, menos leva em conta todos os valores possíveis restantes. Existem alguns
maneiras de ignorar valores inteiros ou partes de valores em um padrão: usando o ` _`
padrão (que você viu), usando o padrão ` _`dentro de outro padrão,
usando um nome que começa com um sublinhado ou usando `..` para ignorar o restante
partes de um valor. Vamos explorar como e por que usar cada um desses padrões.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-an-entire-value-with-_"></a>

#### Um valor inteiro com `_`

Usamos o sublinhado como um padrão curinga que match qualquer valor, exceto
não se vincula ao valor. Isto é especialmente útil como o último braço em um `match`
expressão, mas também podemos usá-la em qualquer padrão, incluindo função
parâmetros, conforme mostrado na Listagem 19-17.

<Listing number="19-17" file-name="src/main.rs" caption="Usando `_` em uma assinatura de função">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-17/src/main.rs}}
```

</Listing>

Este código irá ignorar completamente o valor `3` passado como primeiro argumento,
e imprimirá `This code only uses the y parameter: 4`.

Na maioria dos casos, quando você não precisa mais de um parâmetro de função específico, você
mudaria a assinatura para que não incluísse o parâmetro não utilizado.
Ignorar um parâmetro de função pode ser especialmente útil nos casos em que, por
Por exemplo, você está implementando um trait quando precisa de um determinado tipo de assinatura, mas
o corpo da função na sua implementação não precisa de um dos parâmetros.
Você evita então receber um aviso do compilador sobre parâmetros de função não utilizados, como
você faria se usasse um nome.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-parts-of-a-value-with-a-nested-_"></a>

#### Partes de um valor com um `_` aninhado

Também podemos usar `_` dentro de outro padrão para ignorar apenas parte de um valor, por
Por exemplo, quando queremos testar apenas parte de um valor, mas não temos utilidade para o
outras partes do código correspondente que queremos executar. A Listagem 19-18 mostra o código
responsável por gerenciar o valor de uma configuração. Os requisitos de negócios são que
o usuário não deve ter permissão para substituir uma personalização existente de um
configuração, mas pode desarmar a configuração e atribuir-lhe um valor se ela estiver atualmente desativada.

<Listing number="19-18" caption="Usando sublinhado dentro de padrões que correspondem a variantes `Some` quando não precisamos usar o valor dentro de `Some`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-18/src/main.rs:here}}
```

</Listing>

Este código irá imprimir `Can't overwrite an existing customized value` e então
`setting is Some(5) `. No primeiro braço match, não precisamos ligar ou usar match
os valores dentro de qualquer variante` Some `, mas precisamos testar o caso
quando` setting_value `e` new_setting_value `são a variante` Some `. Nisso
caso, imprimimos o motivo para não alterar` setting_value`, e isso não acontece
mudou.

Em todos os outros casos (se `setting_value` ou `new_setting_value` for `None`)
expresso pelo padrão ` _`no segundo braço, queremos permitir
` new_setting_value `para se tornar` setting_value`.

Também podemos usar sublinhados em vários lugares dentro de um padrão para ignorar
valores particulares. A Listagem 19-19 mostra um exemplo de como ignorar o segundo e
quartos valores em uma tupla de cinco itens.

<Listing number="19-19" caption="Ignorando várias partes de uma tupla">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-19/src/main.rs:here}}
```

</Listing>

Este código imprimirá `Some numbers: 2, 8, 32`, e os valores ` 4`e ` 16`serão
ser ignorado.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-an-unused-variable-by-starting-its-name-with-_"></a>

#### Uma variável não utilizada iniciando seu nome com `_`

Se você criar uma variável, mas não a usar em lugar nenhum, Rust normalmente emitirá um
aviso porque uma variável não utilizada pode ser um bug. No entanto, às vezes é
útil para poder criar uma variável que você ainda não usará, como quando você está
prototipagem ou apenas iniciando um projeto. Nesta situação, você pode dizer ao Rust
não avisar sobre a variável não utilizada iniciando o nome da variável
com um sublinhado. Na Listagem 19-20, criamos duas variáveis não utilizadas, mas quando
compilarmos este código, só devemos receber um aviso sobre um deles.

<Listing number="19-20" file-name="src/main.rs" caption="Começando o nome de uma variável com sublinhado para evitar avisos de variável não utilizada">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-20/src/main.rs}}
```

</Listing>

Aqui, recebemos um aviso sobre não usar a variável `y`, mas não recebemos um
aviso sobre não usar ` _x`.

Observe que há uma diferença sutil entre usar apenas `_` e usar um nome
que começa com um sublinhado. A sintaxe `_x` ainda vincula o valor ao
variável, enquanto `_` não se vincula de forma alguma. Para mostrar um caso em que isso
distinção é importante, a Listagem 19-21 nos fornecerá um erro.

<Listing number="19-21" caption="Uma variável não usada que começa com sublinhado ainda associa o valor, o que pode tomar ownership dele">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-21/src/main.rs:here}}
```

</Listing>

Receberemos um erro porque o valor `s` ainda será movido para `_s`,
o que nos impede de usar ` s`novamente. No entanto, usando o sublinhado sozinho
nunca se vincula ao valor. A Listagem 19-22 será compilada sem erros
porque ` s`não é movido para ` _`.

<Listing number="19-22" caption="Usar um sublinhado não associa o valor">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-22/src/main.rs:here}}
```

</Listing>

Esse código funciona perfeitamente porque nunca vinculamos `s` a nada; ele não é movido.

<a id="ignoring-remaining-parts-of-a-value-with-"></a>

#### Partes restantes de um valor com `..`

Com valores que possuem muitas partes, podemos usar a sintaxe `..` para usar valores específicos.
partes e ignore o resto, evitando a necessidade de listar sublinhados para cada
valor ignorado. O padrão `..` ignora qualquer parte de um valor que não tenhamos
explicitamente correspondido no resto do padrão. Na Listagem 19-23, temos um
Estrutura `Point` que contém uma coordenada no espaço tridimensional. No
Expressão `match`, queremos operar apenas na coordenada ` x`e ignorar
os valores nos campos ` y`e ` z`.

<Listing number="19-23" caption="Ignorando todos os campos de um `Point`, exceto `x`, usando `..`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-23/src/main.rs:here}}
```

</Listing>

Listamos o valor `x` e depois incluímos apenas o padrão `..`. Isso é mais rápido
do que ter que listar ` y: _`e ` z: _`, especialmente quando estamos trabalhando com
estruturas que possuem muitos campos em situações onde apenas um ou dois campos são
relevante.

A sintaxe `..` será expandida para quantos valores forem necessários. Listagem 19-24
mostra como usar `..` com uma tupla.

<Listing number="19-24" file-name="src/main.rs" caption="Fazendo correspondência apenas com o primeiro e o último valores de uma tupla e ignorando todos os demais">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-24/src/main.rs}}
```

</Listing>

Neste código, o primeiro e o último valores são correspondidos com `first` e `last`.
O `..` irá match e ignorará tudo no meio.

No entanto, o uso de `..` deve ser inequívoco. Se não estiver claro quais valores são
destinado à correspondência e que deve ser ignorado, Rust nos dará um erro.
A Listagem 19-25 mostra um exemplo de uso de `..` de forma ambígua, portanto não
compilar.

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
antes de combinar um valor com `second` e quantos valores adicionais devem ser
ignorar depois disso. Este código pode significar que queremos ignorar `2`, vincular
` second `para` 4 `e, em seguida, ignore` 8 `,` 16 `e` 32 `; ou que queremos ignorar
` 2 `e` 4 `, ligue` second `a` 8 `e, em seguida, ignore` 16 `e` 32 `; e assim por diante.
O nome da variável` second `não significa nada de especial para Rust, então obtemos um
erro do compilador porque usar`..` em dois lugares como este é ambíguo.

<!-- Old headings. Do not remove or links may break. -->

<a id="extra-conditionals-with-match-guards"></a>

### Adicionando Condicionais com Match Guards

Um _match guard_ é uma condição `if` adicional, especificada após o padrão em
um braço `match`, que também deve match para que esse braço seja escolhido. Os guardas da partida são
útil para expressar ideias mais complexas do que um padrão sozinho permite. Nota,
no entanto, eles estão disponíveis apenas em expressões ` match`, não em ` if let`ou
Expressões ` while let`.

A condição pode usar variáveis ​​criadas no padrão. A listagem 19-26 mostra um
`match ` onde o primeiro braço possui o padrão`Some(x) ` e também possui um match
guarda de`if x % 2 == 0 ` (que será`true` se o número for par).

<Listing number="19-26" caption="Adicionando uma guarda de match a um padrão">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-26/src/main.rs:here}}
```

</Listing>

Este exemplo imprimirá `The number 4 is even`. Quando ` num`é comparado com o
padrão no primeiro braço, ele corresponde porque ` Some(4)`corresponde a ` Some(x)`. Então,
o guarda match verifica se o restante da divisão de ` x`por 2 é igual a
0 e, por ser assim, o primeiro braço é selecionado.

Se `num` fosse `Some(5)`, a guarda match no primeiro braço seria
foram ` false`porque o resto de 5 dividido por 2 é 1, o que não é
igual a 0. Rust iria então para o segundo braço, que seria match porque o
o segundo braço não possui uma proteção match e, portanto, corresponde a qualquer variante ` Some`.

Não há como expressar a condição `if x % 2 == 0` dentro de um padrão, então
a guarda match nos dá a capacidade de expressar essa lógica. A desvantagem de
essa expressividade adicional é que o compilador não tenta verificar
exaustividade quando expressões de guarda match estão envolvidas.

Ao discutir a Listagem 19-11, mencionamos que poderíamos usar proteções match para
resolver nosso problema de sombreamento de padrões. Lembre-se que criamos uma nova variável
dentro do padrão na expressão `match` em vez de usar a variável
fora do `match`. Essa nova variável significava que não poderíamos testar o valor
da variável externa. A Listagem 19-27 mostra como podemos usar uma proteção match para corrigir
esse problema.

<Listing number="19-27" file-name="src/main.rs" caption="Usando uma guarda de `match` para testar igualdade com uma variável externa">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-27/src/main.rs}}
```

</Listing>

Este código agora imprimirá `Default case, x = Some(5)`. O padrão no segundo
O braço match não introduz uma nova variável ` y`que obscureceria o ` y`externo,
o que significa que podemos usar o ` y`externo na proteção match. Em vez de especificar o
padrão como ` Some(y)`, que teria sombreado o ` y`externo, especificamos
` Some(n) `. Isso cria uma nova variável` n `que não oculta nada porque
não há variável` n `fora de` match`.

A proteção match `if n == y` não é um padrão e portanto não introduz novos
variáveis. Este `y` _é_ o `y` externo em vez de um novo `y` o sombreando, e
podemos procurar um valor que tenha o mesmo valor do `y` externo comparando
`n ` para`y`.

Você também pode usar o operador _or_ `|` em uma guarda de `match` para
especificar múltiplos padrões; a condição da guarda será aplicada a todos os
padrões. A Listagem 19-28 mostra a precedência ao combinar um padrão que usa
`|` com uma guarda de `match`. A parte importante deste exemplo é que a guarda
de `match` `if y` se aplica a `4`, `5` _e_ `6`, mesmo que possa parecer que
`if y` se aplica apenas
applies to `6`.

<Listing number="19-28" caption="Combinando vários padrões com uma guarda de match">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-28/src/main.rs:here}}
```

</Listing>

A condição match afirma que o braço só corresponde se o valor de `x` for
igual a `4`, ` 5`ou ` 6`_e_ se ` y`for ` true`. Quando esse código é executado, o
o padrão do primeiro braço corresponde porque `x` é `4`, mas o match guarda ` if y`
é `false`, então o primeiro braço não é escolhido. O código passa para o segundo
arm, que faz match, e este programa imprime `no`. A razão é que
A condição `if` se aplica a todo o padrão `4 | 5 | 6`, não apenas ao último
value `6`. In other words, the precedence of a match guard in relation to a
padrão se comporta assim:

```text
(4 | 5 | 6) if y => ...
```

em vez disso:

```text
4 | 5 | (6 if y) => ...
```

Depois de executar o código, o comportamento de precedência fica evidente: Se o guarda match
foram aplicados apenas ao valor final na lista de valores especificados usando o
Operador `|`, o braço teria correspondido e o programa teria impresso
`yes`.

<!-- Old headings. Do not remove or links may break. -->

<a id="-bindings"></a>

### Usando ligações `@`

O operador _at_ `@` nos permite criar uma variável que contém um valor ao mesmo
vez que estamos testando esse valor para um padrão match. Na Listagem 19-29, queremos
teste se um campo `Message::Hello` ` id`está dentro do intervalo ` 3..=7`. Nós também
queremos vincular o valor à variável ` id`para que possamos usá-lo no código
associado ao braço.

<Listing number="19-29" caption="Usando `@` para associar um valor em um padrão ao mesmo tempo em que o testa">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-29/src/main.rs:here}}
```

</Listing>

Este exemplo imprimirá `Found an id in range: 5`. Especificando ` id @`antes
intervalo ` 3..=7`, estamos capturando qualquer valor que corresponda ao intervalo em um
variável chamada ` id`enquanto testa se o valor corresponde ao padrão de intervalo.

No segundo braço, onde temos apenas um intervalo especificado no padrão, o código
associado ao braço não possui uma variável que contenha o valor real
do campo `id`. O valor do campo ` id`poderia ter sido 10, 11 ou 12, mas
o código que acompanha esse padrão não sabe qual é. O código padrão
não é possível usar o valor do campo ` id`porque não salvamos o
Valor ` id`em uma variável.

No último braço, onde especificamos uma variável sem intervalo, temos
o valor disponível para uso no código do braço em uma variável chamada `id`. O
o motivo é que usamos a sintaxe abreviada do campo struct. Mas não temos
aplicou qualquer teste ao valor no campo ` id`neste braço, como fizemos com o
primeiros dois braços: Qualquer valor seria match esse padrão.

Usar `@` nos permite testar um valor e salvá-lo em uma variável dentro de um padrão.

## Resumo

Os padrões do Rust são muito úteis para distinguir entre diferentes tipos de
dados. Quando usado em expressões `match`, Rust garante que seus padrões cubram
todos os valores possíveis, ou seu programa não será compilado. Padrões em ` let`
instruções e parâmetros de função tornam essas construções mais úteis, permitindo
a desestruturação de valores em partes menores e a atribuição dessas partes a
variáveis. Podemos criar padrões simples ou complexos para atender às nossas necessidades.

A seguir, no penúltimo capítulo do livro, veremos alguns
aspectos de uma variedade de recursos do Rust.
