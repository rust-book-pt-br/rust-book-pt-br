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

Descrevemos a maioria dos recursos avançados neste capítulo como sendo raramente
necessário. Os tipos associados estão em algum lugar no meio: são usados mais raramente
do que os recursos explicados no resto do livro, mas mais comumente do que muitos dos
os outros recursos discutidos neste capítulo.

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

Os tipos associados podem parecer um conceito semelhante aos genéricos, na medida em que o
este último nos permite definir uma função sem especificar quais tipos ela pode
manusear. Para examinar a diferença entre os dois conceitos, veremos um
implementação do `Iterator` trait em um tipo chamado `Counter` que especifica
o tipo `Item` é `u32`:

<Listing file-name="src/lib.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-22-iterator-on-counter/src/lib.rs:ch19}}
```

</Listing>

Esta sintaxe parece comparável à dos genéricos. Então, por que não apenas definir o
`Iterator` trait com genéricos, conforme mostrado na Listagem 20-14?

<Listing number="20-14" caption="Uma definição hipotética da trait `Iterator` usando genéricos">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-14/src/lib.rs}}
```

</Listing>

A diferença é que ao usar genéricos, como na Listagem 20-14, devemos
anote os tipos em cada implementação; porque também podemos implementar
`Iterator<String> for Counter ` ou qualquer outro tipo, poderíamos ter vários
implementações de`Iterator ` para`Counter `. Em outras palavras, quando um trait tem um
parâmetro genérico, ele pode ser implementado para um tipo várias vezes, alterando
os tipos concretos dos parâmetros de tipo genérico de cada vez. Quando usamos o
Método` next `em` Counter `, teríamos que fornecer anotações de tipo para
indique qual implementação de` Iterator`queremos usar.

Com tipos associados, não precisamos anotar tipos, porque não podemos
implementar um trait em um tipo várias vezes. Na Listagem 20-13 com o
definição que utiliza tipos associados, podemos escolher qual o tipo de `Item`
será apenas uma vez porque só pode haver um ` impl Iterator for Counter`. Nós
não precisamos especificar que queremos um iterator de valores ` u32`em todos os lugares que
chame ` next`em ` Counter`.

Os tipos associados também passam a fazer parte do contrato do trait: Implementadores do
trait deve fornecer um tipo para substituir o espaço reservado de tipo associado.
Os tipos associados geralmente têm um nome que descreve como o tipo será usado,
e documentar o tipo associado na documentação da API é uma boa prática.

<!-- Old headings. Do not remove or links may break. -->

<a id="default-generic-type-parameters-and-operator-overloading"></a>

### Usando parâmetros genéricos padrão e sobrecarga de operador

Quando usamos parâmetros de tipo genérico, podemos especificar um tipo concreto padrão para
o tipo genérico. Isso elimina a necessidade dos implementadores do trait
especifique um tipo concreto se o tipo padrão funcionar. Você especifica um tipo padrão
ao declarar um tipo genérico com a sintaxe `<PlaceholderType=ConcreteType>`.

Um ótimo exemplo de situação em que esta técnica é útil é com _operator
sobrecarga_, em que você personaliza o comportamento de um operador (como `+`)
em situações particulares.

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

O método `add` adiciona os valores `x` de duas instâncias `Point` e o valor `y`
valores de duas instâncias ` Point`para criar um novo ` Point`. O ` Add`trait possui um
tipo associado denominado ` Output`que determina o tipo retornado do ` add`
método.

O tipo genérico padrão neste código está dentro de `Add` trait. Aqui está o seu
definição:

```rust
trait Add<Rhs=Self> {
    type Output;

    fn add(self, rhs: Rhs) -> Self::Output;
}
```

Este código deve parecer geralmente familiar: um trait com um método e um
tipo associado. A nova parte é `Rhs=Self`: Esta sintaxe é chamada _default
digite parâmetros_. O parâmetro de tipo genérico ` Rhs`(abreviação de “right-hand
side”) define o tipo do parâmetro ` rhs`no método ` add`. Se não
especificamos um tipo concreto para ` Rhs`quando implementamos o ` Add`trait, o tipo
de ` Rhs`será padronizado como ` Self`, que será o tipo que estamos implementando
` Add`ativado.

Quando implementamos `Add` para `Point`, usamos o padrão para ` Rhs`porque
queria adicionar duas instâncias ` Point`. Vejamos um exemplo de implementação
o ` Add`trait onde queremos personalizar o tipo ` Rhs`em vez de usar o
padrão.

Temos duas estruturas, `Millimeters` e `Meters`, contendo valores em diferentes
unidades. Esse empacotamento fino de um tipo existente em outra estrutura é conhecido como
_newtype pattern_, que descrevemos com mais detalhes em [“Implementando
traits externas com o padrão newtype”][newtype] seção <!-- ignore -->. Nós
deseja adicionar valores em milímetros a valores em metros e ter o
implementação de ` Add`faça a conversão corretamente. Podemos implementar ` Add`para
` Millimeters `com` Meters `como` Rhs`, conforme mostrado na Listagem 20-16.

<Listing number="20-16" file-name="src/lib.rs" caption="Implementando a trait `Add` em `Millimeters` para somar `Millimeters` e `Meters`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-16/src/lib.rs}}
```

</Listing>

Para adicionar `Millimeters` e `Meters`, especificamos ` impl Add<Meters>`para definir o
valor do parâmetro de tipo ` Rhs`em vez de usar o padrão ` Self`.

Você usará parâmetros de tipo padrão de duas maneiras principais:

1. Para estender um tipo sem quebrar código existente
2. Para permitir personalização em casos específicos de que a maioria dos usuários não precisará

O `Add` trait da biblioteca padrão é um exemplo do segundo propósito:
Normalmente, você adicionará dois tipos semelhantes, mas o `Add` trait oferece a capacidade de
personalizar além disso. Usando um parâmetro de tipo padrão no `Add` trait
definição significa que você não precisa especificar o parâmetro extra na maioria dos
tempo. Em outras palavras, não é necessário um pouco de clichê de implementação, tornando
é mais fácil usar o trait.

O primeiro propósito é semelhante ao segundo, mas ao contrário: se você quiser adicionar um
parâmetro de tipo para um trait existente, você pode fornecer um padrão para permitir
extensão da funcionalidade do trait sem quebrar o existente
código de implementação.

<!-- Old headings. Do not remove or links may break. -->

<a id="fully-qualified-syntax-for-disambiguation-calling-methods-with-the-same-name"></a>
<a id="disambiguating-between-methods-with-the-same-name"></a>

### Desambiguando entre métodos com o mesmo nome

Nada em Rust impede que um trait tenha um método com o mesmo nome que
outro método trait, nem Rust impede que você implemente ambos os métodos traits
em um tipo. Também é possível implementar um método diretamente no tipo com
o mesmo nome dos métodos de traits.

Ao chamar métodos com o mesmo nome, você precisará informar ao Rust qual deles você
deseja usar. Considere o código na Listagem 20-17 onde definimos dois traits,
`Pilot ` e`Wizard `, ambos possuem um método chamado` fly `. Implementamos então
ambos traits em um tipo` Human `que já possui um método chamado` fly `implementado
nisso. Cada método` fly`faz algo diferente.

<Listing number="20-17" file-name="src/main.rs" caption="Duas traits são definidas com um método `fly` e implementadas no tipo `Human`, e um método `fly` também é implementado diretamente em `Human`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-17/src/main.rs:here}}
```

</Listing>

Quando chamamos `fly` em uma instância de `Human`, o compilador usa como padrão chamar
o método que é implementado diretamente no tipo, conforme mostrado na Listagem 20-18.

<Listing number="20-18" file-name="src/main.rs" caption="Chamando `fly` em uma instância de `Human`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-18/src/main.rs:here}}
```

</Listing>

A execução deste código imprimirá `*waving arms furiously*`, mostrando que Rust
chamado de método ` fly`implementado diretamente no ` Human`.

Para chamar os métodos `fly` do `Pilot` trait ou do `Wizard` trait,
precisamos usar uma sintaxe mais explícita para especificar a qual método `fly` nos referimos.
A Listagem 20-19 demonstra essa sintaxe.

<Listing number="20-19" file-name="src/main.rs" caption="Especificando qual método `fly` de trait queremos chamar">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-19/src/main.rs:here}}
```

</Listing>

Especificar o nome trait antes do nome do método esclarecer para Rust qual
implementação de `fly` que queremos chamar. Poderíamos também escrever
`Human::fly(&person) `, que é equivalente ao` person.fly()`que usamos
na Listagem 20-19, mas isso é um pouco mais longo para escrever se não precisarmos
desambiguar.

A execução deste código imprime o seguinte:

```console
{{#include ../listings/ch20-advanced-features/listing-20-19/output.txt}}
```

Como o método `fly` usa um parâmetro `self`, se tivéssemos dois _tipos_ que
ambos implementam uma _trait_, Rust poderia descobrir qual implementação de um
trait para usar com base no tipo de ` self`.

No entanto, funções associadas que não são métodos não possuem um `self`
parâmetro. Quando existem vários tipos ou traits que definem não-método
funções com o mesmo nome de função, Rust nem sempre sabe qual tipo você
significa, a menos que você use sintaxe totalmente qualificada. Por exemplo, na Listagem 20-20, nós
crie um trait para um abrigo de animais que deseja nomear todos os cães bebês como Spot. Nós
faça um ` Animal`trait com uma função não-método associada ` baby_name`. O
` Animal `trait é implementado para a estrutura` Dog `, na qual também fornecemos um
função não-método associada` baby_name`diretamente.

<Listing number="20-20" file-name="src/main.rs" caption="Uma trait com uma função associada e um tipo com uma função associada de mesmo nome que também implementa a trait">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-20/src/main.rs}}
```

</Listing>

Implementamos o código para nomear todos os filhotes Spot no `baby_name` associado
função definida em `Dog`. O tipo ` Dog`também implementa o trait
`Animal`, que descreve traços que todos os animais possuem. Cachorros bebês são
chamados filhotes, e isso se expressa na implementação do` Animal `
trait em` Dog `na função` baby_name `associada ao` Animal`trait.

Em `main`, chamamos a função ` Dog::baby_name`, que chama o
função definida diretamente em ` Dog`. Este código imprime o seguinte:

```console
{{#include ../listings/ch20-advanced-features/listing-20-20/output.txt}}
```

Esta saída não é o que queríamos. Queremos chamar a função `baby_name` que
faz parte do `Animal` trait que implementamos no `Dog` para que o código
imprime `A baby dog is called a puppy`. A técnica de especificação do trait
name que usamos na Listagem 20-19 não ajuda aqui; se mudarmos ` main`para
o código na Listagem 20-21, obteremos um erro de compilação.

<Listing number="20-21" file-name="src/main.rs" caption="Tentando chamar a função `baby_name` da trait `Animal`, mas o Rust não sabe qual implementação usar">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-21/src/main.rs:here}}
```

</Listing>

Como `Animal::baby_name` não possui um parâmetro `self` e pode haver
outros tipos que implementam o `Animal` trait, Rust não conseguem descobrir qual
implementação de `Animal::baby_name` que desejamos. Obteremos este erro do compilador:

```console
{{#include ../listings/ch20-advanced-features/listing-20-21/output.txt}}
```

Para desambiguar e dizer ao Rust que queremos usar a implementação de
`Animal ` para`Dog ` em oposição à implementação de`Animal` para alguns outros
tipo, precisamos usar sintaxe totalmente qualificada. A Listagem 20-22 demonstra como
use sintaxe totalmente qualificada.

<Listing number="20-22" file-name="src/main.rs" caption="Usando sintaxe totalmente qualificada para especificar que queremos chamar a função `baby_name` da trait `Animal` como implementada em `Dog`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-22/src/main.rs:here}}
```

</Listing>

Estamos fornecendo ao Rust uma anotação de tipo entre colchetes angulares, que
indica que queremos chamar o método `baby_name` do `Animal` trait como
implementado em `Dog` dizendo que queremos tratar o tipo `Dog` como um
`Animal` para esta chamada de função. Este código agora imprimirá o que queremos:

```console
{{#include ../listings/ch20-advanced-features/listing-20-22/output.txt}}
```

Em geral, a sintaxe totalmente qualificada é definida da seguinte forma:

```rust,ignore
<Type as Trait>::function(receiver_if_method, next_arg, ...);
```

Para funções associadas que não são métodos, não haveria `receiver`:
Haveria apenas a lista de outros argumentos. Você poderia usar totalmente qualificado
sintaxe em todos os lugares onde você chama funções ou métodos. No entanto, você está autorizado
omitir qualquer parte desta sintaxe que Rust possa descobrir a partir de outras informações
no programa. Você só precisa usar esta sintaxe mais detalhada nos casos em que
existem várias implementações que usam o mesmo nome e Rust precisa de ajuda
para identificar qual implementação você deseja chamar.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-supertraits-to-require-one-traits-functionality-within-another-trait"></a>

### Usando supertraits

Às vezes você pode escrever uma definição trait que depende de outro trait: Para
um tipo para implementar o primeiro trait, você deseja exigir que esse tipo também
implementar o segundo trait. Você faria isso para que sua definição trait pudesse
faça uso dos itens associados do segundo trait. O trait seu trait
a definição em que se baseia é chamada de _supertrait_ da sua trait.

Por exemplo, digamos que queremos fazer um `OutlinePrint` trait com um
Método `outline_print` que imprimirá um determinado valor formatado para que seja
enquadrado em asteriscos. Ou seja, dada uma estrutura `Point` que implementa o
biblioteca padrão trait `Display` para resultar em `(x, y)`, quando chamamos
` outline_print `em uma instância` Point `que possui` 1 `para` x `e` 3 `para` y`, ele
deve imprimir o seguinte:

```text
**********
*        *
* (1, 3) *
*        *
**********
```

Na implementação do método `outline_print`, queremos usar o
Funcionalidade do ` Display`trait. Portanto, precisamos especificar que o
` OutlinePrint `trait funcionará apenas para tipos que também implementam` Display `e
fornece a funcionalidade que o` OutlinePrint `precisa. Podemos fazer isso no
Definição de trait especificando` OutlinePrint: Display `. Esta técnica é
semelhante a adicionar um trait vinculado ao trait. A listagem 20-23 mostra um
implementação do` OutlinePrint`trait.

<Listing number="20-23" file-name="src/main.rs" caption="Implementando a trait `OutlinePrint`, que exige a funcionalidade de `Display`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-23/src/main.rs:here}}
```

</Listing>

Como especificamos que `OutlinePrint` requer `Display` trait,
pode usar a função `to_string` que é implementada automaticamente para qualquer tipo
que implementa `Display`. Se tentássemos usar ` to_string`sem adicionar um
dois pontos e especificando ` Display`trait após o nome trait, obteríamos um
erro dizendo que nenhum método chamado ` to_string`foi encontrado para o tipo ` &Self`em
o escopo atual.

Vamos ver o que acontece quando tentamos implementar `OutlinePrint` em um tipo que
não implementa `Display`, como a estrutura ` Point`:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-02-impl-outlineprint-for-point/src/main.rs:here}}
```

</Listing>

Recebemos um erro dizendo que `Display` é exigida, mas não foi implementada:

```console
{{#include ../listings/ch20-advanced-features/no-listing-02-impl-outlineprint-for-point/output.txt}}
```

Para corrigir isso, implementamos `Display` em `Point` e satisfazemos a restrição que
`OutlinePrint` requer, assim:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-03-impl-display-for-point/src/main.rs:here}}
```

</Listing>

Então, implementar o `OutlinePrint` trait no `Point` irá compilar
com sucesso, e podemos chamar `outline_print` em uma instância `Point` para exibir
dentro de um contorno de asteriscos.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-the-newtype-pattern-to-implement-external-traits-on-external-types"></a>
<a id="using-the-newtype-pattern-to-implement-external-traits"></a>

### Implementando traits externas com o padrão newtype

Na seção [“Implementando uma trait em um tipo”][implementing-a-trait-on-a-type]<!--
ignore --> no Capítulo 10, mencionamos a regra órfã que afirma
só podemos implementar um trait em um tipo se o trait ou o
tipo, ou ambos, são locais para nosso crate. É possível contornar isso
restrição usando o padrão newtype, que envolve a criação de um novo tipo em um
estrutura de tupla. (Nós cobrimos estruturas de tuplas no [“Criando Diferentes Tipos com
Tuple Structs”][tuple-structs]<!-- ignore --> seção no Capítulo 5.) A tupla
struct terá um campo e será um wrapper fino em torno do tipo para o qual
deseja implementar um trait. Então, o tipo de wrapper é local para nosso crate, e nós
pode implementar o trait no wrapper. _Newtype_ é um termo que se origina
da linguagem de programação Haskell. Não há penalidade de desempenho em tempo de execução
para usar esse padrão, e o tipo de wrapper é eliminado em tempo de compilação.

Por exemplo, digamos que queremos implementar `Display` em `Vec<T>`, que o
regra órfã nos impede de fazer diretamente porque o ` Display`trait e o
O tipo ` Vec<T>`é definido fora do nosso crate. Podemos fazer uma estrutura ` Wrapper`
que contém uma instância de ` Vec<T>`; então, podemos implementar ` Display`em
` Wrapper `e use o valor` Vec<T>`, conforme mostrado na Listagem 20-24.

<Listing number="20-24" file-name="src/main.rs" caption="Criando um tipo `Wrapper` em torno de `Vec<String>` para implementar `Display`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-24/src/main.rs}}
```

</Listing>

A implementação de `Display` usa `self.0` para acessar o `Vec<T>` interno
porque `Wrapper` é uma estrutura de tupla e `Vec<T>` é o item no índice 0 no
tupla. Então, podemos usar a funcionalidade do `Display` trait no `Wrapper`.

A desvantagem de usar esta técnica é que `Wrapper` é um novo tipo, então
não tem os métodos do valor que está mantendo. Teríamos que implementar
todos os métodos de `Vec<T>` diretamente em `Wrapper` de modo que os métodos
delegar para `self.0`, o que nos permitiria tratar ` Wrapper`exatamente como um
` Vec<T> `. Se quiséssemos que o novo tipo tivesse todos os métodos que o tipo interno possui,
implementar o` Deref `trait no` Wrapper `para retornar o tipo interno seria
ser uma solução (discutimos a implementação do` Deref`trait no [“Tratando
Smart Pointers Like Regular References”][smart-pointer-deref]<!-- ignore -->
seção no Capítulo 15). Se não quiséssemos que o tipo `Wrapper` tivesse todos os
métodos do tipo interno - por exemplo, para restringir o tipo `Wrapper`
comportamento - teríamos que implementar manualmente apenas os métodos que desejamos.

Este padrão newtype também é útil mesmo quando traits não está envolvido. Vamos
mude o foco e veja algumas maneiras avançadas de interagir com o sistema de tipos do Rust.

[newtype]: ch20-02-advanced-traits.html#implementing-external-traits-with-the-newtype-pattern
[implementing-a-trait-on-a-type]: ch10-02-traits.html#implementing-a-trait-on-a-type
[traits]: ch10-02-traits.html
[smart-pointer-deref]: ch15-02-deref.html#treating-smart-pointers-like-regular-references
[tuple-structs]: ch05-01-defining-structs.html#creating-different-types-with-tuple-structs
