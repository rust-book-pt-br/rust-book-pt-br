## Traits avançadas

Abordamos traits pela primeira vez em [“Definindo comportamento compartilhado com
traits”][traits]<!-- ignore --> no Capítulo 10, mas não discutimos os detalhes
mais avançados. Agora que você sabe mais sobre Rust, podemos entrar no âmago
da questão.

<!-- Old headings. Do not remove or links may break. -->

<a id="specifying-placeholder-types-in-trait-definitions-with-associated-types"></a>
<a id="associated-types"></a>

### Definindo traits com tipos associados

_Tipos associados_ conectam um espaço reservado de tipo a uma trait, de modo que
as definições de métodos da trait possam usar esses tipos de espaço reservado
em suas assinaturas. O implementador de uma trait especificará o tipo concreto
a ser usado no lugar do espaço reservado para a implementação específica.
Dessa forma, podemos definir uma trait que usa alguns tipos sem precisar saber
exatamente quais são esses tipos até que a trait seja implementada.

Descrevemos a maioria dos recursos avançados deste capítulo como raramente
necessários. Os tipos associados ficam em algum lugar no meio: são usados com menos frequência
do que os recursos explicados no restante do livro, mas mais frequentemente do que muitos dos
outros recursos discutidos aqui.

Um exemplo de trait com tipo associado é a trait `Iterator`, fornecida pela
biblioteca padrão. O tipo associado chama-se `Item` e representa o tipo dos
valores sobre os quais o tipo que implementa a trait `Iterator` está iterando.
A definição da trait `Iterator` é mostrada na Listagem 20-13.

<Listing number="20-13" caption="A definição da trait `Iterator`, que possui um tipo associado `Item`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-13/src/lib.rs}}
```

</Listing>

O tipo `Item` é um espaço reservado, e a definição do método `next` mostra que
ele retornará valores do tipo `Option<Self::Item>`. Implementadores da trait
`Iterator` especificam o tipo concreto de `Item`, e o método `next` retorna um
`Option` contendo um valor desse tipo concreto.

Os tipos associados podem parecer semelhantes aos genéricos, na medida em que
estes últimos também nos permitem definir comportamento sem especificar, de
antemão, todos os tipos concretos envolvidos. Para examinar a diferença entre
os dois conceitos, veremos uma implementação da trait `Iterator` em um tipo
chamado `Counter`, que especifica o tipo `Item` como `u32`:

<Listing file-name="src/lib.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-22-iterator-on-counter/src/lib.rs:ch19}}
```

</Listing>

Essa sintaxe parece comparável à dos genéricos. Então, por que não definir
a trait `Iterator` com genéricos, como mostrado na Listagem 20-14?

<Listing number="20-14" caption="Uma definição hipotética da trait `Iterator` usando genéricos">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-14/src/lib.rs}}
```

</Listing>

A diferença é que, ao usar genéricos, como na Listagem 20-14, precisamos anotar
os tipos em cada implementação; como também poderíamos implementar
`Iterator<String> for Counter`, ou qualquer outra variação, poderíamos ter
várias implementações de `Iterator` para `Counter`. Em outras palavras, quando
uma trait tem um parâmetro genérico, ela pode ser implementada para um mesmo
tipo várias vezes, alterando os tipos concretos dos parâmetros genéricos a cada
implementação. Quando usássemos o método `next` em `Counter`, precisaríamos
fornecer anotações de tipo para indicar qual implementação de `Iterator`
queremos usar.

Com tipos associados, não precisamos anotar tipos, porque não podemos
implementar a mesma trait várias vezes para um tipo. Na definição da
Listagem 20-13, que usa tipos associados, só podemos escolher o tipo de `Item`
uma única vez, porque só pode existir um `impl Iterator for Counter`. Não
precisamos especificar, em todo lugar onde chamamos `next` em `Counter`, que
queremos um iterator de valores `u32`.

Os tipos associados também passam a fazer parte do contrato da trait:
implementadores da trait precisam fornecer um tipo para substituir o espaço
reservado do tipo associado.
Os tipos associados geralmente têm um nome que descreve como o tipo será usado,
e documentar o tipo associado na documentação da API é uma boa prática.

<!-- Old headings. Do not remove or links may break. -->

<a id="default-generic-type-parameters-and-operator-overloading"></a>

### Usando parâmetros genéricos padrão e sobrecarga de operadores

Quando usamos parâmetros de tipo genérico, podemos especificar um tipo concreto
padrão para o tipo genérico. Isso elimina a necessidade de implementadores da
trait especificarem um tipo concreto se o tipo padrão já servir. Você define um
tipo padrão ao declarar um tipo genérico com a sintaxe
`<PlaceholderType=ConcreteType>`.

Um ótimo exemplo de situação em que essa técnica é útil é a sobrecarga de operadores
(_operator overloading_), em que você personaliza o comportamento de um operador, como `+`,
em situações específicas.

Rust não permite que você crie seus próprios operadores nem que sobrecarregue
operadores arbitrariamente. Mas você pode sobrecarregar as operações e as
traits correspondentes listadas em `std::ops` implementando a trait associada
ao operador. Por exemplo, na Listagem 20-15, sobrecarregamos o operador `+`
para somar duas instâncias de `Point`. Fazemos isso implementando a trait
`Add` para a struct `Point`.

<Listing number="20-15" file-name="src/main.rs" caption="Implementando a trait `Add` para sobrecarregar o operador `+` para instâncias de `Point`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-15/src/main.rs}}
```

</Listing>

O método `add` soma os valores `x` de duas instâncias de `Point` e os valores
`y` dessas duas instâncias para criar um novo `Point`. A trait `Add` possui um
tipo associado chamado `Output`, que determina o tipo retornado pelo método
`add`.

O tipo genérico padrão neste código está na trait `Add`. Eis sua
definição:

```rust
trait Add<Rhs=Self> {
    type Output;

    fn add(self, rhs: Rhs) -> Self::Output;
}
```

Esse código deve parecer familiar em termos gerais: uma trait com um método e
um tipo associado. A parte nova é `Rhs=Self`: essa sintaxe é chamada de
_default type parameters_. O parâmetro de tipo genérico `Rhs`, abreviação de
“right-hand side”, define o tipo do parâmetro `rhs` no método `add`. Se não
especificarmos um tipo concreto para `Rhs` ao implementar a trait `Add`, o tipo
de `Rhs` terá como padrão `Self`, que será o tipo sobre o qual estamos
implementando `Add`.

Quando implementamos `Add` para `Point`, usamos o valor padrão de `Rhs` porque
queríamos somar duas instâncias de `Point`. Vejamos agora um exemplo de
implementação da trait `Add` em que queremos personalizar o tipo `Rhs`, em vez
de usar o padrão.

Temos duas structs, `Millimeters` e `Meters`, contendo valores em unidades
diferentes. Esse empacotamento fino de um tipo existente em outra struct é
conhecido como _newtype pattern_, que descrevemos em mais detalhes na seção
[“Implementando traits externas com o padrão newtype”][newtype]<!-- ignore -->.
Queremos somar valores em milímetros a valores em metros e fazer com que a
implementação de `Add` realize a conversão corretamente. Podemos implementar
`Add` para `Millimeters`, usando `Meters` como `Rhs`, como mostra a
Listagem 20-16.

<Listing number="20-16" file-name="src/lib.rs" caption="Implementando a trait `Add` em `Millimeters` para somar `Millimeters` e `Meters`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-16/src/lib.rs}}
```

</Listing>

Para somar `Millimeters` e `Meters`, especificamos `impl Add<Meters>` para definir o
valor do parâmetro de tipo `Rhs`, em vez de usar o padrão `Self`.

Você usará parâmetros de tipo padrão de duas maneiras principais:

1. Para estender um tipo sem quebrar código existente
2. Para permitir personalização em casos específicos dos quais a maioria dos usuários não precisará

A trait `Add` da biblioteca padrão é um exemplo do segundo propósito:
normalmente, você somará dois tipos iguais, mas a trait `Add` oferece a
capacidade de ir além disso. Usar um parâmetro de tipo padrão na definição de
`Add` significa que você não precisa especificar o parâmetro extra na maior
parte do tempo. Em outras palavras, evita-se um pouco de boilerplate de
implementação, o que torna a trait mais fácil de usar.

O primeiro propósito é parecido com o segundo, mas no sentido inverso: se você quiser adicionar um
parâmetro de tipo a uma trait existente, pode fornecer um valor padrão para permitir a
extensão da funcionalidade da trait sem quebrar o
código de implementação já existente.

<!-- Old headings. Do not remove or links may break. -->

<a id="fully-qualified-syntax-for-disambiguation-calling-methods-with-the-same-name"></a>
<a id="disambiguating-between-methods-with-the-same-name"></a>

### Desambiguando entre métodos com o mesmo nome

Nada em Rust impede que uma trait tenha um método com o mesmo nome que
o método de outra trait, nem impede que você implemente ambas as traits
em um mesmo tipo. Também é possível implementar diretamente no tipo um método com
o mesmo nome dos métodos dessas traits.

Ao chamar métodos com o mesmo nome, você precisará informar ao Rust qual deles
deseja usar. Considere o código da Listagem 20-17, em que definimos duas traits,
`Pilot` e `Wizard`, ambas com um método chamado `fly`. Em seguida, implementamos
as duas traits para um tipo `Human`, que já possui um método chamado `fly`
implementado diretamente. Cada método `fly` faz algo diferente.

<Listing number="20-17" file-name="src/main.rs" caption="Duas traits são definidas com um método `fly` e implementadas no tipo `Human`, e um método `fly` também é implementado diretamente em `Human`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-17/src/main.rs:here}}
```

</Listing>

Quando chamamos `fly` em uma instância de `Human`, o compilador, por padrão, chama
o método implementado diretamente no tipo, como mostrado na Listagem 20-18.

<Listing number="20-18" file-name="src/main.rs" caption="Chamando `fly` em uma instância de `Human`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-18/src/main.rs:here}}
```

</Listing>

A execução desse código imprimirá `*waving arms furiously*`, mostrando que Rust
chamou o método `fly` implementado diretamente em `Human`.

Para chamar os métodos `fly` da trait `Pilot` ou da trait `Wizard`,
precisamos usar uma sintaxe mais explícita para especificar a qual método `fly` nos referimos.
A Listagem 20-19 demonstra essa sintaxe.

<Listing number="20-19" file-name="src/main.rs" caption="Especificando qual método `fly` de trait queremos chamar">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-19/src/main.rs:here}}
```

</Listing>

Especificar o nome da trait antes do nome do método deixa claro para Rust qual
implementação de `fly` queremos chamar. Também poderíamos escrever
`Human::fly(&person)`, o que é equivalente a `person.fly()`, usado
na Listagem 20-19, mas isso é um pouco mais longo quando não precisamos
desambiguar.

A execução deste código imprime o seguinte:

```console
{{#include ../listings/ch20-advanced-features/listing-20-19/output.txt}}
```

Como o método `fly` usa um parâmetro `self`, se tivéssemos dois _tipos_ que
implementassem a mesma _trait_, Rust poderia descobrir qual implementação
usar com base no tipo de `self`.

No entanto, funções associadas que não são métodos não possuem parâmetro `self`.
Quando existem vários tipos ou traits que definem funções não associadas a métodos
com o mesmo nome, Rust nem sempre sabe a qual tipo você está se referindo,
a menos que use sintaxe totalmente qualificada. Por exemplo, na Listagem 20-20, criamos
uma trait para um abrigo de animais que quer chamar todos os cães filhotes de Spot. Fazemos
uma trait `Animal` com uma função associada não-método chamada `baby_name`. A
trait `Animal` é implementada para a struct `Dog`, na qual também fornecemos
diretamente uma função associada não-método `baby_name`.

<Listing number="20-20" file-name="src/main.rs" caption="Uma trait com uma função associada e um tipo com uma função associada de mesmo nome que também implementa a trait">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-20/src/main.rs}}
```

</Listing>

Implementamos em `Dog` o código para nomear todos os filhotes como Spot, na função
associada `baby_name`. O tipo `Dog` também implementa a trait
`Animal`, que descreve características compartilhadas por todos os animais. Filhotes
de cachorro são chamados de `puppy`, e isso é expresso na implementação da trait
`Animal` para `Dog`, na função associada `baby_name` dessa trait.

Em `main`, chamamos a função `Dog::baby_name`, que invoca a
função definida diretamente em `Dog`. Esse código imprime o seguinte:

```console
{{#include ../listings/ch20-advanced-features/listing-20-20/output.txt}}
```

Essa saída não é o que queríamos. Queremos chamar a função `baby_name` que
faz parte da trait `Animal` implementada em `Dog`, para que o código
imprima `A baby dog is called a puppy`. A técnica de especificar o nome da trait,
que usamos na Listagem 20-19, não ajuda aqui; se mudarmos `main` para
o código da Listagem 20-21, obteremos um erro de compilação.

<Listing number="20-21" file-name="src/main.rs" caption="Tentando chamar a função `baby_name` da trait `Animal`, mas o Rust não sabe qual implementação usar">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-21/src/main.rs:here}}
```

</Listing>

Como `Animal::baby_name` não possui um parâmetro `self` e pode haver
outros tipos que implementem a trait `Animal`, Rust não consegue descobrir qual
implementação de `Animal::baby_name` queremos. Obteremos este erro do compilador:

```console
{{#include ../listings/ch20-advanced-features/listing-20-21/output.txt}}
```

Para desambiguar e dizer ao Rust que queremos usar a implementação de
`Animal` para `Dog`, e não a implementação de `Animal` para algum outro
tipo, precisamos usar sintaxe totalmente qualificada. A Listagem 20-22 mostra como
usar essa sintaxe.

<Listing number="20-22" file-name="src/main.rs" caption="Usando sintaxe totalmente qualificada para especificar que queremos chamar a função `baby_name` da trait `Animal` como implementada em `Dog`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-22/src/main.rs:here}}
```

</Listing>

Estamos fornecendo ao Rust uma anotação de tipo entre colchetes angulares, que
indica que queremos chamar o método `baby_name` da trait `Animal` como
implementado em `Dog`, ou seja, queremos tratar o tipo `Dog` como um
`Animal` nessa chamada de função. Esse código agora imprimirá o que queremos:

```console
{{#include ../listings/ch20-advanced-features/listing-20-22/output.txt}}
```

Em geral, a sintaxe totalmente qualificada é definida da seguinte forma:

```rust,ignore
<Type as Trait>::function(receiver_if_method, next_arg, ...);
```

Para funções associadas que não são métodos, não haveria `receiver`:
haveria apenas a lista dos outros argumentos. Você poderia usar sintaxe totalmente qualificada
em todos os lugares em que chama funções ou métodos. No entanto, pode
omitir qualquer parte dessa sintaxe que Rust consiga deduzir a partir de outras informações
do programa. Você só precisa usar essa forma mais detalhada quando
existem várias implementações com o mesmo nome e Rust precisa de ajuda
para identificar qual delas você quer chamar.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-supertraits-to-require-one-traits-functionality-within-another-trait"></a>

### Usando supertraits

Às vezes você pode escrever uma definição de trait que depende de outra trait. Para
um tipo implementar a primeira trait, você quer exigir que esse tipo também
implemente a segunda. Você faz isso para que a definição da sua trait possa
usar os itens associados da segunda. A trait da qual a sua definição
depende é chamada de _supertrait_ da sua trait.

Por exemplo, digamos que queremos criar uma trait `OutlinePrint` com um
método `outline_print` que imprima um determinado valor formatado de modo a ficar
emoldurado por asteriscos. Ou seja, dada uma struct `Point` que implementa a
trait `Display` da biblioteca padrão e produz `(x, y)`, quando chamamos
`outline_print` em uma instância de `Point` que tenha `1` em `x` e `3` em `y`, ela
deve imprimir o seguinte:

```text
**********
*        *
* (1, 3) *
*        *
**********
```

Na implementação do método `outline_print`, queremos usar a
funcionalidade da trait `Display`. Portanto, precisamos especificar que a
trait `OutlinePrint` funcionará apenas para tipos que também implementem `Display` e
forneçam a funcionalidade de que `OutlinePrint` precisa. Podemos fazer isso na
definição da trait, especificando `OutlinePrint: Display`. Essa técnica é
semelhante a adicionar uma trait bound. A Listagem 20-23 mostra uma
implementação da trait `OutlinePrint`.

<Listing number="20-23" file-name="src/main.rs" caption="Implementando a trait `OutlinePrint`, que exige a funcionalidade de `Display`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-23/src/main.rs:here}}
```

</Listing>

Como especificamos que `OutlinePrint` exige a trait `Display`,
podemos usar a função `to_string`, implementada automaticamente para qualquer tipo
que implemente `Display`. Se tentássemos usar `to_string` sem adicionar os
dois-pontos e especificar a trait `Display` após o nome da trait, obteríamos um
erro dizendo que nenhum método chamado `to_string` foi encontrado para o tipo `&Self`
no escopo atual.

Vamos ver o que acontece quando tentamos implementar `OutlinePrint` em um tipo que
não implementa `Display`, como a struct `Point`:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-02-impl-outlineprint-for-point/src/main.rs:here}}
```

</Listing>

Recebemos um erro dizendo que a trait `Display` é exigida, mas não foi implementada:

```console
{{#include ../listings/ch20-advanced-features/no-listing-02-impl-outlineprint-for-point/output.txt}}
```

Para corrigir isso, implementamos `Display` para `Point` e satisfazemos a restrição exigida por
`OutlinePrint`, assim:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-03-impl-display-for-point/src/main.rs:here}}
```

</Listing>

Então, implementar a trait `OutlinePrint` para `Point` compilará
com sucesso, e poderemos chamar `outline_print` em uma instância de `Point` para exibi-la
dentro de um contorno de asteriscos.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-the-newtype-pattern-to-implement-external-traits-on-external-types"></a>
<a id="using-the-newtype-pattern-to-implement-external-traits"></a>

### Implementando traits externas com o padrão newtype

Na seção [“Implementando uma trait em um tipo”][implementing-a-trait-on-a-type]<!--
ignore --> do Capítulo 10, mencionamos a regra órfã, que afirma que
só podemos implementar uma trait para um tipo se a trait, o
tipo, ou ambos, forem locais ao nosso crate. É possível contornar essa
restrição usando o padrão newtype, que envolve criar um novo tipo em uma
tuple struct. (Cobrimos tuple structs na seção [“Criando diferentes tipos com
tuple structs”][tuple-structs]<!-- ignore -->, no Capítulo 5.) A tuple
struct terá um campo e será um wrapper fino em torno do tipo para o qual
queremos implementar uma trait. Assim, o tipo wrapper é local ao nosso crate, e nós
podemos implementar a trait nele. _Newtype_ é um termo que vem
da linguagem de programação Haskell. Não há penalidade de desempenho em tempo de execução
ao usar esse padrão, e o tipo wrapper é eliminado em tempo de compilação.

Por exemplo, digamos que queremos implementar `Display` para `Vec<T>`, algo que a
regra órfã nos impede de fazer diretamente porque tanto a trait `Display` quanto o
tipo `Vec<T>` são definidos fora do nosso crate. Podemos criar uma struct `Wrapper`
que contenha uma instância de `Vec<T>`; então, podemos implementar `Display` para
`Wrapper` e usar o valor `Vec<T>`, como mostrado na Listagem 20-24.

<Listing number="20-24" file-name="src/main.rs" caption="Criando um tipo `Wrapper` em torno de `Vec<String>` para implementar `Display`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-24/src/main.rs}}
```

</Listing>

A implementação de `Display` usa `self.0` para acessar o `Vec<T>` interno
porque `Wrapper` é uma tuple struct e `Vec<T>` é o item no índice 0 da
tupla. Assim, podemos usar a funcionalidade da trait `Display` em `Wrapper`.

A desvantagem de usar essa técnica é que `Wrapper` é um novo tipo e, portanto,
não tem os métodos do valor que está encapsulando. Teríamos de implementar
todos os métodos de `Vec<T>` diretamente em `Wrapper` de modo que eles
delegassem para `self.0`, o que nos permitiria tratar `Wrapper` exatamente como um
`Vec<T>`. Se quiséssemos que o novo tipo tivesse todos os métodos do tipo interno,
implementar a trait `Deref` para `Wrapper`, retornando o tipo interno, seria
uma solução (discutimos a implementação de `Deref` na seção [“Tratando
smart pointers como referências normais”][smart-pointer-deref]<!-- ignore -->
do Capítulo 15). Se não quiséssemos que `Wrapper` tivesse todos os
métodos do tipo interno, por exemplo, para restringir seu
comportamento, teríamos de implementar manualmente apenas os métodos desejados.

Esse padrão newtype também é útil mesmo quando traits não estão envolvidas. Vamos
mudar o foco e ver algumas maneiras avançadas de interagir com o sistema de tipos do Rust.

[newtype]: ch20-02-advanced-traits.html#implementing-external-traits-with-the-newtype-pattern
[implementing-a-trait-on-a-type]: ch10-02-traits.html#implementing-a-trait-on-a-type
[traits]: ch10-02-traits.html
[smart-pointer-deref]: ch15-02-deref.html#treating-smart-pointers-like-regular-references
[tuple-structs]: ch05-01-defining-structs.html#creating-different-types-with-tuple-structs
