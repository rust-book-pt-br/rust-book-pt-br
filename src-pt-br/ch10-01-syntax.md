## Tipos de Dados Genéricos

Usamos genéricos para criar definições de itens como assinaturas de função ou
structs, que depois podemos usar com muitos tipos concretos de dados. Vamos
primeiro ver como definir funções, structs, enums e métodos usando genéricos.
Depois, discutiremos como os genéricos afetam o desempenho do código.

### Em Definições de Função

Ao definir uma função que usa genéricos, colocamos os genéricos na assinatura
da função, onde normalmente especificaríamos os tipos de dados dos parâmetros e
do valor de retorno. Fazer isso torna nosso código mais flexível e oferece
mais funcionalidade para quem chama a função, evitando duplicação de código.

Continuando com nossa função `largest`, a Listagem 10-4 mostra duas funções que
ambas encontram o maior valor em uma fatia. Em seguida, vamos combiná-las em
uma única função usando genéricos.

<Listing number="10-4" file-name="src/main.rs" caption="Duas funções que diferem apenas nos nomes e nos tipos presentes em suas assinaturas">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-04/src/main.rs:here}}
```

</Listing>

A função `largest_i32` é aquela que extraímos na Listagem 10-3, que encontra o
maior `i32` em uma fatia. A função `largest_char` encontra o maior `char` em
uma fatia. Os corpos das duas funções têm o mesmo código, então vamos eliminar
a duplicação introduzindo um parâmetro de tipo genérico em uma única função.

Para parametrizar os tipos nessa nova função única, precisamos dar um nome ao
parâmetro de tipo, assim como fazemos com parâmetros de valor de uma função.
Você pode usar qualquer identificador como nome do parâmetro de tipo. Mas
vamos usar `T` porque, por convenção, nomes de parâmetros de tipo em Rust são
curtos, geralmente com apenas uma letra, e a convenção de nomenclatura de tipos
em Rust é UpperCamelCase. Como abreviação de _type_, `T` é a escolha padrão da
maioria dos programadores Rust.

Quando usamos um parâmetro no corpo da função, precisamos declarar seu nome na
assinatura para que o compilador saiba o que ele significa. Da mesma forma,
quando usamos um nome de parâmetro de tipo em uma assinatura de função,
precisamos declarar esse nome antes de usá-lo. Para definir a função genérica
`largest`, colocamos as declarações de nome de tipo dentro de colchetes
angulares, `<>`, entre o nome da função e a lista de parâmetros, assim:

```rust,ignore
fn largest<T>(list: &[T]) -> &T {
```

Lemos essa definição como: “A função `largest` é genérica sobre algum tipo
`T`.” Essa função tem um parâmetro chamado `list`, que é uma fatia de valores
do tipo `T`. A função `largest` retornará uma referência a um valor do mesmo
tipo `T`.

A Listagem 10-5 mostra a definição combinada da função `largest` usando o tipo
de dado genérico em sua assinatura. A listagem também mostra como podemos
chamar a função tanto com uma fatia de valores `i32` quanto com valores
`char`. Observe que esse código ainda não compila.

<Listing number="10-5" file-name="src/main.rs" caption="A função `largest` usando parâmetros de tipo genérico; isso ainda não compila">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-05/src/main.rs}}
```

</Listing>

Se compilarmos esse código agora, obteremos este erro:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-05/output.txt}}
```

O texto de ajuda menciona `std::cmp::PartialOrd`, que é uma trait, e vamos
falar sobre traits na próxima seção. Por enquanto, basta saber que esse erro
afirma que o corpo de `largest` não funciona para todos os tipos possíveis que
`T` poderia representar. Como queremos comparar valores do tipo `T` dentro do
corpo, só podemos usar tipos cujos valores possam ser ordenados. Para
habilitar comparações, a biblioteca padrão fornece a trait
`std::cmp::PartialOrd`, que você pode implementar em tipos. Veja o Apêndice C
para mais informações sobre essa trait. Para corrigir a Listagem 10-5, podemos
seguir a sugestão do texto de ajuda e restringir os tipos válidos para `T`
apenas àqueles que implementam `PartialOrd`. A listagem então compilará,
porque a biblioteca padrão implementa `PartialOrd` tanto em `i32` quanto em
`char`.

### Em Definições de Struct

Também podemos definir structs para usar um parâmetro de tipo genérico em um ou
mais campos usando a sintaxe `<>`. A Listagem 10-6 define uma struct
`Point<T>` para armazenar valores de coordenadas `x` e `y` de qualquer tipo.

<Listing number="10-6" file-name="src/main.rs" caption="Uma struct `Point<T>` que armazena valores `x` e `y` do tipo `T`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-06/src/main.rs}}
```

</Listing>

A sintaxe para usar genéricos em definições de struct é parecida com a usada em
definições de função. Primeiro, declaramos o nome do parâmetro de tipo entre
colchetes angulares logo após o nome da struct. Depois, usamos o tipo genérico
na definição da struct onde, de outra forma, especificaríamos tipos concretos.

Observe que, como usamos apenas um tipo genérico para definir `Point<T>`, essa
definição diz que a struct `Point<T>` é genérica sobre algum tipo `T`, e que
os campos `x` e `y` são _ambos_ desse mesmo tipo, seja ele qual for. Se
criarmos uma instância de `Point<T>` com valores de tipos diferentes, como na
Listagem 10-7, nosso código não compilará.

<Listing number="10-7" file-name="src/main.rs" caption="Os campos `x` e `y` precisam ter o mesmo tipo porque ambos usam o mesmo tipo de dado genérico `T`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-07/src/main.rs}}
```

</Listing>

Neste exemplo, quando atribuímos o valor inteiro `5` a `x`, deixamos o
compilador saber que o tipo genérico `T` será um inteiro para essa instância
de `Point<T>`. Depois, quando especificamos `4.0` para `y`, que definimos como
tendo o mesmo tipo de `x`, receberemos um erro de incompatibilidade de tipos
assim:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-07/output.txt}}
```

Para definir uma struct `Point` em que `x` e `y` sejam genéricos, mas possam
ter tipos diferentes, podemos usar múltiplos parâmetros de tipo genérico. Por
exemplo, na Listagem 10-8, alteramos a definição de `Point` para ser genérica
sobre os tipos `T` e `U`, em que `x` é do tipo `T` e `y` é do tipo `U`.

<Listing number="10-8" file-name="src/main.rs" caption="Um `Point<T, U>` genérico sobre dois tipos, para que `x` e `y` possam ter valores de tipos diferentes">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-08/src/main.rs}}
```

</Listing>

Agora todas as instâncias de `Point` mostradas são permitidas! Você pode usar
quantos parâmetros de tipo genérico quiser em uma definição, mas usar mais do
que alguns torna o código difícil de ler. Se você perceber que precisa de
muitos tipos genéricos no seu código, isso pode indicar que ele precisa ser
reestruturado em partes menores.

### Em Definições de Enum

Assim como fizemos com structs, podemos definir enums para armazenar tipos de
dado genéricos em suas variantes. Vamos dar outra olhada no enum `Option<T>`
fornecido pela biblioteca padrão, que usamos no Capítulo 6:

```rust
enum Option<T> {
    Some(T),
    None,
}
```

Essa definição agora deve fazer mais sentido para você. Como pode ver, o enum
`Option<T>` é genérico sobre o tipo `T` e tem duas variantes: `Some`, que
contém um valor do tipo `T`, e `None`, que não contém valor algum. Usando o
enum `Option<T>`, podemos expressar o conceito abstrato de um valor opcional,
e, como `Option<T>` é genérico, podemos usar essa abstração independentemente
do tipo do valor opcional.

Enums também podem usar vários tipos genéricos. A definição do enum `Result`,
que usamos no Capítulo 9, é um exemplo:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

O enum `Result` é genérico sobre dois tipos, `T` e `E`, e tem duas variantes:
`Ok`, que contém um valor do tipo `T`, e `Err`, que contém um valor do tipo
`E`. Essa definição torna conveniente usar o enum `Result` em qualquer lugar em
que temos uma operação que pode ter sucesso, retornando um valor de algum tipo
`T`, ou falhar, retornando um erro de algum tipo `E`. Na verdade, foi isso que
usamos para abrir um arquivo na Listagem 9-3, em que `T` foi preenchido com o
tipo `std::fs::File` quando o arquivo foi aberto com sucesso, e `E` foi
preenchido com o tipo `std::io::Error` quando houve problemas ao abrir o
arquivo.

Quando você reconhece situações no código com múltiplas definições de structs
ou enums que diferem apenas nos tipos de valores que armazenam, pode evitar
duplicação usando tipos genéricos.

### Em Definições de Método

Podemos implementar métodos em structs e enums, como fizemos no Capítulo 5, e
usar tipos genéricos em suas definições também. A Listagem 10-9 mostra a
struct `Point<T>` que definimos na Listagem 10-6 com um método chamado `x`
implementado nela.

<Listing number="10-9" file-name="src/main.rs" caption="Implementando um método chamado `x` na struct `Point<T>` que retorna uma referência ao campo `x` do tipo `T`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-09/src/main.rs}}
```

</Listing>

Aqui, definimos um método chamado `x` em `Point<T>` que retorna uma referência
aos dados no campo `x`.

Observe que precisamos declarar `T` logo após `impl` para que possamos usar
`T` e especificar que estamos implementando métodos no tipo `Point<T>`. Ao
declarar `T` como tipo genérico depois de `impl`, o Rust consegue identificar
que o tipo entre colchetes angulares em `Point` é um tipo genérico e não um
tipo concreto. Poderíamos ter escolhido um nome diferente para esse parâmetro
genérico em relação ao declarado na definição da struct, mas usar o mesmo nome
é convencional. Se você escrever um método dentro de um `impl` que declare um
tipo genérico, esse método será definido em qualquer instância do tipo, não
importa qual tipo concreto acabe substituindo o tipo genérico.

Também podemos especificar restrições sobre tipos genéricos ao definir métodos
no tipo. Poderíamos, por exemplo, implementar métodos apenas em instâncias
`Point<f32>`, em vez de em instâncias `Point<T>` com qualquer tipo genérico. Na
Listagem 10-10, usamos o tipo concreto `f32`, o que significa que não
declaramos nenhum tipo depois de `impl`.

<Listing number="10-10" file-name="src/main.rs" caption="Um bloco `impl` que se aplica apenas a uma struct com um tipo concreto específico para o parâmetro de tipo genérico `T`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-10/src/main.rs:here}}
```

</Listing>

Esse código significa que o tipo `Point<f32>` terá um método
`distance_from_origin`; outras instâncias de `Point<T>` em que `T` não seja do
tipo `f32` não terão esse método definido. O método mede a distância do ponto
até a origem, nas coordenadas `(0.0, 0.0)`, e usa operações matemáticas
disponíveis apenas para tipos de ponto flutuante.

Os parâmetros de tipo genérico em uma definição de struct nem sempre são os
mesmos que você usa nas assinaturas de métodos dessa mesma struct. A Listagem
10-11 usa os tipos genéricos `X1` e `Y1` para a struct `Point` e `X2` e `Y2`
para a assinatura do método `mixup`, para deixar o exemplo mais claro. O
método cria uma nova instância de `Point` com o valor `x` do `Point` de `self`,
do tipo `X1`, e o valor `y` do `Point` passado como argumento, do tipo `Y2`.

<Listing number="10-11" file-name="src/main.rs" caption="Um método que usa tipos genéricos diferentes dos definidos na própria struct">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-11/src/main.rs}}
```

</Listing>

Em `main`, definimos um `Point` que tem um `i32` para `x`, com valor `5`, e um
`f64` para `y`, com valor `10.4`. A variável `p2` é uma struct `Point` que tem
uma fatia de string para `x`, com valor `"Hello"`, e um `char` para `y`, com
valor `c`. Chamar `mixup` em `p1` com o argumento `p2` nos dá `p3`, que terá
um `i32` para `x` porque `x` veio de `p1`. A variável `p3` terá um `char` para
`y` porque `y` veio de `p2`. A chamada da macro `println!` imprimirá
`p3.x = 5, p3.y = c`.

O objetivo desse exemplo é demonstrar uma situação em que alguns parâmetros
genéricos são declarados em `impl` e outros são declarados na definição do
método. Aqui, os parâmetros genéricos `X1` e `Y1` são declarados após `impl`
porque pertencem à definição da struct. Já os parâmetros genéricos `X2` e
`Y2` são declarados após `fn mixup` porque só são relevantes para esse método.

### Desempenho de Código Usando Genéricos

Você talvez esteja se perguntando se existe algum custo em tempo de execução ao
usar parâmetros de tipo genérico. A boa notícia é que usar tipos genéricos não
fará seu programa rodar mais lentamente do que faria com tipos concretos.

O Rust consegue isso realizando monomorfização do código que usa genéricos em
tempo de compilação. _Monomorfização_ é o processo de transformar código
genérico em código específico, preenchendo os tipos concretos que são usados na
compilação. Nesse processo, o compilador faz o oposto das etapas que usamos
para criar a função genérica da Listagem 10-5: ele observa todos os lugares em
que o código genérico é chamado e gera código para os tipos concretos com os
quais ele foi usado.

Vamos ver como isso funciona usando o enum genérico `Option<T>` da biblioteca
padrão:

```rust
let integer = Some(5);
let float = Some(5.0);
```

Quando o Rust compila esse código, ele realiza monomorfização. Durante esse
processo, o compilador lê os valores usados nas instâncias de `Option<T>` e
identifica duas formas de `Option<T>`: uma é `i32`, e a outra é `f64`. Assim,
ele expande a definição genérica de `Option<T>` em duas definições
especializadas para `i32` e `f64`, substituindo a definição genérica pelas
específicas.

A versão monomorfizada do código é parecida com a seguinte, embora o
compilador use nomes diferentes dos que estamos usando aqui apenas para
ilustração:

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

O genérico `Option<T>` é substituído pelas definições específicas criadas pelo
compilador. Como o Rust compila código genérico em código que especifica o tipo
em cada instância, não pagamos custo de tempo de execução por usar genéricos.
Quando o código roda, ele se comporta exatamente como se tivéssemos duplicado
cada definição manualmente. O processo de monomorfização torna os genéricos do
Rust extremamente eficientes em tempo de execução.
