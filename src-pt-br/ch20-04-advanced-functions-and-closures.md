## Funções e Closures Avançadas

Esta seção explora alguns recursos avançados relacionados a funções e closures,
incluindo ponteiros de função e o retorno de closures.

### Ponteiros de função

Já falamos sobre como passar closures para funções; você também pode passar
funções comuns para outras funções! Essa técnica é útil quando você quer passar
uma função que já definiu em vez de definir uma nova closure. Funções
são coercidas para o tipo `fn` (com _f_ minúsculo), que não deve ser confundido
com a trait de closure `Fn`. O tipo `fn` é chamado de _ponteiro de função_.
Passar funções por meio de ponteiros de função permite que você use funções
como argumentos de outras funções.

A sintaxe para especificar que um parâmetro é um ponteiro de função é semelhante à
das closures, como mostrado na Listagem 20-28, em que definimos uma função
`add_one` que adiciona 1 ao seu parâmetro. A função `do_twice` recebe dois
parâmetros: um ponteiro de função para qualquer função que receba um parâmetro `i32`
e retorne um valor `i32`, além de um valor `i32`. A função `do_twice` chama a
função `f` duas vezes, passando-lhe o valor `arg`, e então soma os resultados
dessas duas chamadas. A função `main` chama `do_twice` com os argumentos
`add_one` e `5`.

<Listing number="20-28" file-name="src/main.rs" caption="Usando o tipo `fn` para aceitar um ponteiro de função como argumento">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-28/src/main.rs}}
```

</Listing>

Esse código imprime `The answer is: 12`. Especificamos que o parâmetro `f` em
`do_twice` é um `fn` que recebe um parâmetro do tipo `i32` e retorna um
`i32`. Podemos então chamar `f` no corpo de `do_twice`. Em `main`, podemos passar
o nome da função `add_one` como o primeiro argumento para `do_twice`.

Ao contrário de closures, `fn` é um tipo, e não uma trait, portanto especificamos `fn` como
tipo do parâmetro diretamente, em vez de declarar um parâmetro genérico com
uma das traits `Fn` como bound.

Os ponteiros de função implementam as três closure traits (`Fn`, `FnMut` e
`FnOnce`), o que significa que você sempre pode passar um ponteiro de função como argumento para uma
função que espera uma closure. Em geral, é melhor escrever funções usando um tipo
genérico e uma das closure traits para que suas funções possam aceitar
tanto funções quanto closures.

Dito isso, um caso em que você pode querer aceitar apenas `fn`, e não
closures, é ao fazer interface com código externo que não possui closures: funções em C
podem aceitar funções como argumentos, mas C não tem closures.

Como exemplo de onde você pode usar tanto uma closure definida inline quanto uma
função nomeada, vamos observar o uso do método `map`, fornecido pela trait
`Iterator` na biblioteca padrão. Para usar `map` para transformar um vetor de
números em um vetor de strings, poderíamos usar uma closure, como na Listagem 20-29.

<Listing number="20-29" caption="Usando uma closure com o método `map` para converter números em strings">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-29/src/main.rs:here}}
```

</Listing>

Ou poderíamos passar uma função nomeada como argumento para `map`, em vez de uma closure.
A Listagem 20-30 mostra como isso ficaria.

<Listing number="20-30" caption="Usando a função `String::to_string` com o método `map` para converter números em strings">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-30/src/main.rs:here}}
```

</Listing>

Observe que precisamos usar a sintaxe totalmente qualificada de que falamos na
seção [“Traits avançadas”][advanced-traits]<!-- ignore --> porque existem
múltiplas funções disponíveis com o nome `to_string`.

Aqui, estamos usando a função `to_string` definida na trait `ToString`,
que a biblioteca padrão implementou para qualquer tipo que implemente
`Display`.

Lembre-se da seção [“Valores de enum”][enum-values]<!-- ignore -->, no Capítulo
6: o nome de cada variante de enum que definimos também se torna uma função
inicializadora. Podemos usar essas funções inicializadoras como ponteiros de função que
implementam as closure traits, o que significa que podemos passá-las
como argumentos para métodos que recebem closures, como visto na Listagem 20-31.

<Listing number="20-31" caption="Usando um inicializador de enum com o método `map` para criar uma instância de `Status` a partir de números">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-31/src/main.rs:here}}
```

</Listing>

Aqui, criamos instâncias `Status::Value` usando cada valor `u32` do intervalo
sobre o qual `map` é chamado, por meio da função inicializadora `Status::Value`.
Algumas pessoas preferem esse estilo, e outras preferem usar closures. Os dois
compilam para o mesmo código, então use o estilo que for mais claro para você.

### Retornando closures

Closures são representadas por traits, o que significa que você não pode retorná-las
diretamente. Na maioria dos casos em que você quer retornar uma trait, pode
usar o tipo concreto que a implementa como valor de retorno da
função. No entanto, isso normalmente não funciona com closures porque elas não
têm um tipo concreto retornável; por exemplo, você não pode usar o ponteiro de
função `fn` como tipo de retorno se a closure capturar algum valor do próprio
escopo.

Em vez disso, normalmente você usará a sintaxe `impl Trait`, que aprendemos no
Capítulo 10. Você pode retornar qualquer tipo de função usando `Fn`, `FnOnce` e `FnMut`.
Por exemplo, o código da Listagem 20-32 compila sem problemas.

<Listing number="20-32" caption="Retornando uma closure de uma função usando a sintaxe `impl Trait`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-32/src/lib.rs}}
```

</Listing>

No entanto, como observamos na seção [“Inferência e anotação de tipos de
closure”][closure-types]<!-- ignore -->, no Capítulo 13, cada closure
também é um tipo distinto. Se você precisar trabalhar com várias funções que
têm a mesma assinatura, mas implementações diferentes, precisará usar um
trait object para elas. Considere o que acontece se você escrever um código como o da
Listagem 20-33.

<Listing file-name="src/main.rs" number="20-33" caption="Criando um `Vec<T>` de closures definidas por funções que retornam tipos `impl Fn`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-33/src/main.rs}}
```

</Listing>

Aqui temos duas funções, `returns_closure` e `returns_initialized_closure`,
que ambas retornam `impl Fn(i32) -> i32`. Observe que as closures que elas
retornam são diferentes, embora implementem a mesma trait. Se tentarmos
compilar isso, Rust nos informará que não funcionará:

```text
{{#include ../listings/ch20-advanced-features/listing-20-33/output.txt}}
```

A mensagem de erro nos diz que, sempre que retornamos um `impl Trait`, Rust
cria um _tipo opaco_ distinto: um tipo cujos detalhes não podemos ver
nem nomear diretamente. Portanto, mesmo que essas funções retornem closures que implementam
a mesma trait, `Fn(i32) -> i32`, os tipos opacos que Rust gera para cada uma são
distintos. (Isso é semelhante à forma como Rust produz tipos concretos diferentes para
blocos async distintos, mesmo quando eles têm o mesmo tipo de saída, como vimos em
[“O tipo `Pin` e a trait `Unpin`”][future-types]<!-- ignore --> no
Capítulo 17.) Já vimos uma solução para esse problema algumas vezes: podemos
usar um trait object, como na Listagem 20-34.

<Listing number="20-34" caption="Criando um `Vec<T>` de closures definidas por funções que retornam `Box<dyn Fn>` para que tenham o mesmo tipo">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-34/src/main.rs:here}}
```

</Listing>

Esse código compila sem problemas. Para obter mais informações sobre trait objects, consulte a
seção [“Usando objetos de trait para abstrair comportamento
compartilhado”][trait-objects]<!-- ignore --> no Capítulo 18.

A seguir, vamos ver macros!

[advanced-traits]: ch20-02-advanced-traits.html#advanced-traits
[enum-values]: ch06-01-defining-an-enum.html#enum-values
[closure-types]: ch13-01-closures.html#closure-type-inference-and-annotation
[future-types]: ch17-03-more-futures.html
[trait-objects]: ch18-02-trait-objects.html
