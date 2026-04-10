## Funções e fechamentos avançados

Esta seção explora alguns recursos avançados relacionados às funções e closures,
incluindo ponteiros de função e retornando closures.

### Function Pointers

Já falamos sobre como passar closures para funções; você também pode passar regularmente
funções para funções! Esta técnica é útil quando você deseja passar um
função que você já definiu em vez de definir um novo closure. Funções
coagir para o tipo `fn` (com _f_ minúsculo), não deve ser confundido com o
`Fn ` closure trait. O tipo`fn` é chamado de _ponteiro de função_. Passando
funções com ponteiros de função permitirão que você use funções como argumentos
para outras funções.

A sintaxe para especificar que um parâmetro é um ponteiro de função é semelhante a
o de closures, conforme mostrado na Listagem 20-28, onde definimos uma função
`add_one ` que adiciona 1 ao seu parâmetro. A função`do_twice ` leva dois
parâmetros: um ponteiro de função para qualquer função que receba um parâmetro`i32 `
e retorna um valor` i32 `e um valor` i32 `. A função` do_twice `chama o
função` f `duas vezes, passando-lhe o valor` arg `e, em seguida, adiciona as duas chamadas de função
resultados juntos. A função` main `chama` do_twice `com os argumentos
` add_one `e` 5`.

<Listing number="20-28" file-name="src/main.rs" caption="Usando o tipo `fn` para aceitar um ponteiro de função como argumento">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-28/src/main.rs}}
```

</Listing>

Este código imprime `The answer is: 12`. Especificamos que o parâmetro ` f`em
` do_twice `é um` fn `que recebe um parâmetro do tipo` i32 `e retorna um
` i32 `. Podemos então chamar` f `no corpo de` do_twice `. Em` main `, podemos passar
o nome da função` add_one `como o primeiro argumento para` do_twice`.

Ao contrário de closures, `fn` é um tipo em vez de trait, portanto especificamos `fn` como o
tipo de parâmetro diretamente, em vez de declarar um parâmetro de tipo genérico com um
do `Fn` traits como um limite trait.

Os ponteiros de função implementam todos os três closure traits (`Fn `,` FnMut `e
` FnOnce`), o que significa que você sempre pode passar um ponteiro de função como argumento para um
função que espera um closure. É melhor escrever funções usando um genérico
tipo e um dos closure traits para que suas funções possam aceitar
funções ou closures.

Dito isto, um exemplo de onde você gostaria de aceitar apenas `fn` e não
closures ocorre durante a interface com código externo que não possui closures: C
funções podem aceitar funções como argumentos, mas C não possui closures.

Como exemplo de onde você pode usar um closure definido em linha ou um nome
função, vamos dar uma olhada no uso do método `map` fornecido pelo `Iterator`
trait na biblioteca padrão. Para usar o método ` map`para transformar um vetor de
números em um vetor de strings, poderíamos usar closure, como na Listagem 20-29.

<Listing number="20-29" caption="Usando uma closure com o método `map` para converter números em strings">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-29/src/main.rs:here}}
```

</Listing>

Ou poderíamos nomear uma função como argumento para `map` em vez de closure.
A listagem 20-30 mostra como seria isso.

<Listing number="20-30" caption="Usando a função `String::to_string` com o método `map` para converter números em strings">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-30/src/main.rs:here}}
```

</Listing>

Observe que devemos usar a sintaxe totalmente qualificada da qual falamos no
[“Traços avançados”][advanced-traits]seção <!-- ignore --> porque existem
múltiplas funções disponíveis denominadas `to_string`.

Aqui, estamos usando a função `to_string` definida em `ToString` trait,
que a biblioteca padrão implementou para qualquer tipo que implemente
`Display`.

Lembre-se da seção [“Enum Values”][enum-values]<!-- ignore --> no Capítulo
6 que o nome de cada variante enum que definimos também se torna um inicializador
função. Podemos usar essas funções inicializadoras como ponteiros de função que
implementar o closure traits, o que significa que podemos especificar o inicializador
funciona como argumentos para métodos que utilizam closures, conforme visto na Listagem 20-31.

<Listing number="20-31" caption="Usando um inicializador de enum com o método `map` para criar uma instância de `Status` a partir de números">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-31/src/main.rs:here}}
```

</Listing>

Aqui, criamos instâncias `Status::Value` usando cada valor `u32` no intervalo
que `map` é chamado usando a função inicializadora de `Status::Value`.
Algumas pessoas preferem esse estilo e outras preferem usar closures. Eles
compile no mesmo código, então use o estilo que for mais claro para você.

### Retornando closures

Os fechamentos são representados por traits, o que significa que você não pode retornar closures
diretamente. Na maioria dos casos em que você deseja retornar um trait, você pode
use o tipo concreto que implementa trait como o valor de retorno do
função. No entanto, normalmente você não pode fazer isso com closures porque eles não
tenha um tipo concreto que seja retornável; você não tem permissão para usar a função
ponteiro `fn` como um tipo de retorno se o closure capturar algum valor de seu
escopo, por exemplo.

Em vez disso, você normalmente usará a sintaxe `impl Trait` que aprendemos em
Capítulo 10. Você pode retornar qualquer tipo de função usando `Fn`, ` FnOnce`e ` FnMut`.
Por exemplo, o código na Listagem 20-32 será compilado perfeitamente.

<Listing number="20-32" caption="Retornando uma closure de uma função usando a sintaxe `impl Trait`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-32/src/lib.rs}}
```

</Listing>

No entanto, como observamos no [“Inferir e Anotar Encerramento
Types”][closure-types]<!-- ignore --> no Capítulo 13, cada closure é
também seu próprio tipo distinto. Se você precisar trabalhar com múltiplas funções que
têm a mesma assinatura, mas implementações diferentes, você precisará usar um
objeto trait para eles. Considere o que acontece se você escrever um código como o mostrado
na Listagem 20-33.

<Listing file-name="src/main.rs" number="20-33" caption="Criando um `Vec<T>` de closures definidas por funções que retornam tipos `impl Fn`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-33/src/main.rs}}
```

</Listing>

Aqui temos duas funções, `returns_closure` e `returns_initialized_closure`,
ambos retornam ` impl Fn(i32) -> i32`. Observe que o closures que eles
return são diferentes, embora implementem o mesmo tipo. Se tentarmos
compilar isso, Rust nos avisa que não funcionará:

```text
{{#include ../listings/ch20-advanced-features/listing-20-33/output.txt}}
```

A mensagem de erro nos diz que sempre que retornarmos um `impl Trait`, Rust
cria um _tipo opaco_ exclusivo, um tipo onde não podemos ver os detalhes de
o que Rust constrói para nós, nem podemos adivinhar o tipo que Rust irá gerar para
escrevemos nós mesmos. Portanto, mesmo que essas funções retornem closures que implementam
o mesmo trait, ` Fn(i32) -> i32`, os tipos opacos que Rust gera para cada um são
distinto. (Isso é semelhante a como Rust produz diferentes tipos de concreto para
blocos async distintos mesmo quando possuem o mesmo tipo de saída, como vimos em
[“O tipo ` Pin`e a característica ` Unpin`”][future-types]<!-- ignore --> em
Capítulo 17.) Já vimos uma solução para este problema algumas vezes: podemos
use um objeto trait, como na Listagem 20-34.

<Listing number="20-34" caption="Criando um `Vec<T>` de closures definidas por funções que retornam `Box<dyn Fn>` para que tenham o mesmo tipo">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-34/src/main.rs:here}}
```

</Listing>

Este código irá compilar perfeitamente. Para obter mais informações sobre objetos trait, consulte o
seção [“Usando objetos de características para abstrair sobre compartilhamentos
Comportamento”][trait-objects]<!-- ignore --> no Capítulo 18.

Next, let’s look at macros!

[advanced-traits]: ch20-02-advanced-traits.html#advanced-traits
[enum-values]: ch06-01-defining-an-enum.html#enum-values
[closure-types]: ch13-01-closures.html#closure-type-inference-and-annotation
[future-types]: ch17-03-more-futures.html
[trait-objects]: ch18-02-trait-objects.html
