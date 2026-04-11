## Tipos de dados genéricos

Usamos genéricos para criar definições para itens como assinaturas de funções ou
structs, que podemos então usar com muitos tipos de dados concretos diferentes. Vamos
primeiro veja como definir funções, estruturas, enums e métodos usando
genéricos. Em seguida, discutiremos como os genéricos afetam o desempenho do código.

### Em Definições de Função

Ao definir uma função que usa genéricos, colocamos os genéricos no
assinatura da função onde normalmente especificaríamos os tipos de dados do
parâmetros e valor de retorno. Isso torna nosso código mais flexível e fornece
mais funcionalidade para quem chama nossa função, evitando a duplicação de código.

Continuando com nossa função `largest`, a Listagem 10-4 mostra duas funções que
ambos encontram o maior valor em uma fatia. Vamos então combiná-los em um único
função que usa genéricos.

<Listing number="10-4" file-name="src/main.rs" caption="Two functions that differ only in their names and in the types in their signatures">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-04/src/main.rs:here}}
```

</Listing>

A função `largest_i32` é aquela que extraímos na Listagem 10-3 que encontra
o maior `i32` em uma fatia. A função `largest_char` encontra o maior
`char` em uma fatia. Os corpos funcionais têm o mesmo código, então vamos eliminar
a duplicação introduzindo um parâmetro de tipo genérico em uma única função.

Para parametrizar os tipos em uma nova função única, precisamos nomear o tipo
parâmetro, assim como fazemos com os parâmetros de valor de uma função. Você pode usar
qualquer identificador como um nome de parâmetro de tipo. Mas usaremos `T` porque, por
convenção, os nomes dos parâmetros de tipo em Rust são curtos, geralmente apenas uma letra, e
A convenção de nomenclatura de tipo do Rust é UpperCamelCase. Abreviação de _type_, `T` é o
escolha padrão da maioria dos programadores Rust.

Quando usamos um parâmetro no corpo da função, temos que declarar o
nome do parâmetro na assinatura para que o compilador saiba qual é esse nome
significa. Da mesma forma, quando usamos um nome de parâmetro de tipo em uma assinatura de função,
temos que declarar o nome do parâmetro de tipo antes de usá-lo. Para definir o genérico
`largest`, colocamos as declarações de nome de tipo entre colchetes angulares,
`<>`, entre o nome da função e a lista de parâmetros, assim:

```rust,ignore
fn largest<T>(list: &[T]) -> &T {
```

Lemos esta definição como “A função `largest` é genérica sobre algum tipo
`T`.” Esta função possui um parâmetro chamado `list`, que é uma fatia de valores
do tipo `T`. A função `largest` retornará uma referência a um valor do
mesmo tipo `T`.

A Listagem 10-5 mostra a definição da função `largest` combinada usando o genérico
tipo de dados em sua assinatura. A listagem também mostra como podemos chamar a função
com uma fatia de valores `i32` ou valores `char`. Observe que este código não
compilar ainda.

<Listing number="10-5" file-name="src/main.rs" caption="The `largest` function using generic type parameters; this doesn’t compile yet">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-05/src/main.rs}}
```

</Listing>

Se compilarmos este código agora, obteremos este erro:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-05/output.txt}}
```

O texto de ajuda menciona `std::cmp::PartialOrd`, o que é uma característica, e estamos
falaremos sobre características na próxima seção. Por enquanto, saiba que esse erro
afirma que o corpo de `largest` não funcionará para todos os tipos possíveis que `T`
poderia ser. Como queremos comparar valores do tipo `T` no corpo, podemos
use apenas tipos cujos valores podem ser ordenados. Para permitir comparações, o padrão
biblioteca tem o traço `std::cmp::PartialOrd` que você pode implementar em tipos
(veja o Apêndice C para mais informações sobre esta característica). Para corrigir a Listagem 10-5, podemos seguir o
sugestão do texto de ajuda e restringir os tipos válidos para `T` apenas aqueles que
implementar `PartialOrd`. A listagem será então compilada, porque o padrão
biblioteca implementa `PartialOrd` em `i32` e `char`.

### Em definições de estrutura

Também podemos definir estruturas para usar um parâmetro de tipo genérico em um ou mais
campos usando a sintaxe `<>`. A Listagem 10-6 define uma estrutura `Point<T>` para armazenar
`x` e `y` valores de coordenadas de qualquer tipo.

<Listing number="10-6" file-name="src/main.rs" caption="A `Point<T>` struct that holds `x` and `y` values of type `T`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-06/src/main.rs}}
```

</Listing>

A sintaxe para usar genéricos em definições de struct é semelhante àquela usada em
definições de função. Primeiro, declaramos o nome do parâmetro de tipo dentro
colchetes angulares logo após o nome da estrutura. Então, usamos o tipo genérico
na definição da estrutura onde, de outra forma, especificaríamos tipos de dados concretos.

Observe que, como usamos apenas um tipo genérico para definir `Point<T>`, isso
definição diz que a estrutura `Point<T>` é genérica sobre algum tipo `T`, e
os campos `x` e `y` são _ambos_ do mesmo tipo, seja qual for o tipo. Se
criamos uma instância de `Point<T>` que possui valores de diferentes tipos, como em
Listagem 10.7, nosso código não será compilado.

<Listing number="10-7" file-name="src/main.rs" caption="The fields `x` and `y` must be the same type because both have the same generic data type `T`.">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-07/src/main.rs}}
```

</Listing>

Neste exemplo, quando atribuímos o valor inteiro `5` a `x`, deixamos o
compilador sabe que o tipo genérico `T` será um número inteiro para esta instância de
`Point<T>`. Então, quando especificamos `4.0` para `y`, que definimos como tendo
do mesmo tipo que `x`, obteremos um erro de incompatibilidade de tipo como este:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-07/output.txt}}
```

Para definir uma estrutura `Point` onde `x` e `y` são genéricos, mas podem ter
tipos diferentes, podemos usar vários parâmetros de tipo genérico. Por exemplo, em
Listagem 10-8, alteramos a definição de `Point` para ser genérica em relação aos tipos `T`
e `U` onde `x` é do tipo `T` e `y` é do tipo `U`.

<Listing number="10-8" file-name="src/main.rs" caption="A `Point<T, U>` generic over two types so that `x` and `y` can be values of different types">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-08/src/main.rs}}
```

</Listing>

Agora todas as instâncias de `Point` mostradas são permitidas! Você pode usar tantos genéricos
digite parâmetros em uma definição como desejar, mas usando mais do que alguns faz
seu código é difícil de ler. Se você achar que precisa de muitos tipos genéricos
seu código, isso pode indicar que seu código precisa ser reestruturado em
peças.

### Em definições de Enum

Assim como fizemos com structs, podemos definir enums para conter tipos de dados genéricos em seus
variantes. Vamos dar uma outra olhada no enum `Option<T>` que o padrão
biblioteca fornece, que usamos no Capítulo 6:

```rust
enum Option<T> {
    Some(T),
    None,
}
```

Esta definição agora deve fazer mais sentido para você. Como você pode ver, o
`Option<T>` enum é genérico sobre o tipo `T` e tem duas variantes: `Some`, que
contém um valor do tipo `T` e uma variante `None` que não contém nenhum valor.
Usando o enum `Option<T>`, podemos expressar o conceito abstrato de um
valor opcional, e como `Option<T>` é genérico, podemos usar esta abstração
não importa qual seja o tipo do valor opcional.

Enums também podem usar vários tipos genéricos. A definição de `Result`
enum que usamos no Capítulo 9 é um exemplo:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

O `Result` enum é genérico em dois tipos, `T` e `E`, e tem duas variantes:
`Ok`, que contém um valor do tipo `T`, e `Err`, que contém um valor do tipo
`E`. Esta definição torna conveniente usar o enum `Result` em qualquer lugar que
tem uma operação que pode ser bem-sucedida (retornar um valor de algum tipo `T`) ou falhar
(retorne um erro de algum tipo `E`). Na verdade, foi isso que usamos para abrir um
arquivo na Listagem 9-3, onde `T` foi preenchido com o tipo `std::fs::File` quando
o arquivo foi aberto com sucesso e `E` foi preenchido com o tipo
`std::io::Error` quando houve problemas ao abrir o arquivo.

Quando você reconhece situações em seu código com múltiplas estruturas ou enumerações
definições que diferem apenas nos tipos de valores que contêm, você pode
evite a duplicação usando tipos genéricos.

### Em Definições de Método

Podemos implementar métodos em structs e enums (como fizemos no Capítulo 5) e usar
tipos genéricos em suas definições também. A Listagem 10-9 mostra o `Point<T>`
struct que definimos na Listagem 10.6 com um método chamado `x` implementado nela.

<Listing number="10-9" file-name="src/main.rs" caption="Implementing a method named `x` on the `Point<T>` struct that will return a reference to the `x` field of type `T`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-09/src/main.rs}}
```

</Listing>

Aqui, definimos um método chamado `x` em `Point<T>` que retorna uma referência
aos dados no campo `x`.

Observe que temos que declarar `T` logo após `impl` para que possamos usar `T` para
especifique que estamos implementando métodos do tipo `Point<T>`. Ao declarar
`T` como um tipo genérico após `impl`, Rust pode identificar que o tipo no
colchetes angulares em `Point` é um tipo genérico em vez de um tipo concreto. Nós
poderia ter escolhido um nome diferente para este parâmetro genérico do genérico
parâmetro declarado na definição da estrutura, mas usar o mesmo nome é
convencional. Se você escrever um método dentro de `impl` que declare um genérico
tipo, esse método será definido em qualquer instância do tipo, não importa o que
o tipo concreto acaba substituindo o tipo genérico.

Também podemos especificar restrições em tipos genéricos ao definir métodos no
tipo. Poderíamos, por exemplo, implementar métodos apenas em instâncias `Point<f32>`
em vez de `Point<T>` instâncias com qualquer tipo genérico. Na Listagem 10-10, nós
use o tipo concreto `f32`, o que significa que não declaramos nenhum tipo depois de `impl`.

<Listing number="10-10" file-name="src/main.rs" caption="An `impl` block that only applies to a struct with a particular concrete type for the generic type parameter `T`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-10/src/main.rs:here}}
```

</Listing>

Este código significa que o tipo `Point<f32>` terá um `distance_from_origin`
método; outras instâncias de `Point<T>` onde `T` não é do tipo `f32` não serão
tenha esse método definido. O método mede a que distância nosso ponto está do ponto
aponta nas coordenadas (0,0, 0,0) e usa operações matemáticas que são
disponível apenas para tipos de ponto flutuante.

Os parâmetros de tipo genérico em uma definição de estrutura nem sempre são iguais aos
você usa nas assinaturas de método da mesma estrutura. A Listagem 10-11 usa o genérico
digita `X1` e `Y1` para a estrutura `Point` e `X2` e `Y2` para `mixup`
assinatura do método para tornar o exemplo mais claro. O método cria um novo `Point`
instância com o valor `x` de `self` `Point` (do tipo `X1`) e `y`
valor do `Point` passado (do tipo `Y2`).

<Listing number="10-11" file-name="src/main.rs" caption="A method that uses generic types that are different from its struct’s definition">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-11/src/main.rs}}
```

</Listing>

Em `main`, definimos um `Point` que tem um `i32` para `x` (com valor `5`)
e um `f64` para `y` (com valor `10.4`). A variável `p2` é uma estrutura `Point`
que tem uma fatia de string para `x` (com valor `"Hello"`) e um `char` para `y`
(com valor `c`). Chamar `mixup` em `p1` com o argumento `p2` nos dá `p3`,
que terá um `i32` para `x` porque `x` veio de `p1`. A variável `p3`
terá um `char` para `y` porque `y` veio de `p2`. A macro `println!`
chamada imprimirá `p3.x = 5, p3.y = c`.

O objetivo deste exemplo é demonstrar uma situação em que alguns genéricos
parâmetros são declarados com `impl` e alguns são declarados com o método
definição. Aqui, os parâmetros genéricos `X1` e `Y1` são declarados após
`impl` porque eles acompanham a definição da estrutura. Os parâmetros genéricos `X2`
e `Y2` são declarados após `fn mixup` porque são relevantes apenas para o
método.

### Desempenho de código usando genéricos

Você deve estar se perguntando se há um custo de tempo de execução ao usar o tipo genérico
parâmetros. A boa notícia é que usar tipos genéricos não tornará seu programa
execute mais lentamente do que seria com tipos concretos.

Rust consegue isso realizando a monomorfização do código usando
genéricos em tempo de compilação. _Monomorfização_ é o processo de tornar genérico
código em código específico preenchendo os tipos concretos que são usados ​​quando
compilado. Neste processo, o compilador faz o oposto das etapas que usamos
para criar a função genérica na Listagem 10-5: O compilador analisa todos os
locais onde o código genérico é chamado e gera código para os tipos concretos
o código genérico é chamado com.

Vejamos como isso funciona usando o genérico da biblioteca padrão
`Option<T>` enumeração:

```rust
let integer = Some(5);
let float = Some(5.0);
```

Quando Rust compila esse código, ele executa a monomorfização. Durante isso
processo, o compilador lê os valores que foram usados ​​em `Option<T>`
instâncias e identifica dois tipos de `Option<T>`: um é `i32` e o outro
é `f64`. Como tal, expande a definição genérica de `Option<T>` em duas
definições especializadas para `i32` e `f64`, substituindo assim o genérico
definição com as específicas.

A versão monomorfizada do código é semelhante à seguinte (o
compilador usa nomes diferentes dos que estamos usando aqui para ilustração):

<Listing file-name="src/main.rs">

```rust
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

</Listing>

O genérico `Option<T>` é substituído pelas definições específicas criadas por
o compilador. Como Rust compila código genérico em código que especifica o
type em cada instância, não pagamos nenhum custo de tempo de execução pelo uso de genéricos. Quando o código
é executado, ele funciona exatamente como seria se tivéssemos duplicado cada definição por
mão. O processo de monomorfização torna os genéricos de Rust extremamente eficientes
em tempo de execução.
