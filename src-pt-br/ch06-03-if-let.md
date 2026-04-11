## Fluxo de controle conciso com `if let` e `let...else`

A sintaxe `if let` permite combinar `if` e `let` de uma forma menos detalhada para
manipular valores que correspondam a um padrão enquanto ignora o resto. Considere o
programa na Listagem 6-6 que corresponde a um valor `Option<u8>` no
`config_max` variável, mas só deseja executar código se o valor for `Some`
variante.

<Listing number="6-6" caption="A `match` that only cares about executing code when the value is `Some`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-06/src/main.rs:here}}
```

</Listing>

Se o valor for `Some`, imprimimos o valor na variante `Some` ligando
o valor para a variável `max` no padrão. Não queremos fazer nada
com o valor `None`. Para satisfazer a expressão `match`, temos que adicionar `_ =>
()` depois de processar apenas uma variante, o que é um código padrão irritante para
adicionar.

Em vez disso, poderíamos escrever isso de uma forma mais curta usando `if let`. A seguir
o código se comporta da mesma forma que `match` na Listagem 6-6:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-12-if-let/src/main.rs:here}}
```

A sintaxe `if let` leva um padrão e uma expressão separados por um igual
sinal. Funciona da mesma forma que `match`, onde a expressão é dada ao
`match` e o padrão é seu primeiro braço. Neste caso, o padrão é
`Some(max)`, e `max` se liga ao valor dentro de `Some`. Podemos então
use `max` no corpo do bloco `if let` da mesma forma que usamos `max` em
o braço `match` correspondente. O código no bloco `if let` só é executado se o
o valor corresponde ao padrão.

Usar `if let` significa menos digitação, menos recuo e menos código clichê.
No entanto, você perde a verificação exaustiva que `match` impõe que garante que
você não está se esquecendo de lidar com nenhum caso. Escolhendo entre `match` e `if
let` depende do que você está fazendo em sua situação específica e se
ganhar concisão é uma compensação apropriada para perder uma verificação exaustiva.

Em outras palavras, você pode pensar em `if let` como açúcar de sintaxe para um `match` que
executa o código quando o valor corresponde a um padrão e depois ignora todos os outros valores.

Podemos incluir `else` com `if let`. O bloco de código que acompanha o
`else` é o mesmo bloco de código que acompanharia o caso `_` no
`match` expressão que é equivalente a `if let` e `else`. Lembre-se do
`Coin` definição de enum na Listagem 6-4, onde a variante `Quarter` também possuía um
`UsState` valor. Se quiséssemos contar todas as moedas que não são de um quarto, vemos ao mesmo tempo
anunciando o estado dos trimestres, poderíamos fazer isso com um `match`
expressão, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-13-count-and-announce-match/src/main.rs:here}}
```

Ou poderíamos usar uma expressão `if let` e `else`, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-14-count-and-announce-if-let-else/src/main.rs:here}}
```

## Permanecendo no “Caminho Feliz” com `let...else`

O padrão comum é realizar algum cálculo quando um valor está presente e
retornar um valor padrão caso contrário. Continuando com nosso exemplo de moedas com
Valor `UsState`, se quiséssemos dizer algo engraçado dependendo da idade do
estado no trimestre foi, poderíamos introduzir um método em `UsState` para verificar o
idade de um estado, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-07/src/main.rs:state}}
```

Então, podemos usar `if let` para combinar o tipo de moeda, introduzindo um `state`
variável dentro do corpo da condição, como na Listagem 6-7.

<Listing number="6-7" caption="Checking whether a state existed in 1900 by using conditionals nested inside an `if let`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-07/src/main.rs:describe}}
```

</Listing>

Isso dá conta do recado, mas empurrou o trabalho para dentro do corpo do “se
let`, e se o trabalho a ser feito for mais complicado, pode ser
difícil acompanhar exatamente como as filiais de nível superior se relacionam. Poderíamos também levar
vantagem do fato de que as expressões produzem um valor para produzir o
`state` do `if let` ou retornar mais cedo, como na Listagem 6-8. (Você poderia fazer
algo semelhante com `match` também.)

<Listing number="6-8" caption="Using `if let` to produce a value or return early">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-08/src/main.rs:describe}}
```

</Listing>

No entanto, isso é um pouco chato de seguir à sua maneira! Um ramo do `if
let` produz um valor, e o outro retorna inteiramente da função.

Para tornar esse padrão comum mais fácil de expressar, Rust tem `let...else`. O
A sintaxe `let...else` usa um padrão no lado esquerdo e uma expressão no lado
certo, muito parecido com `if let`, mas não tem um branch `if`, apenas um
`else` filial. Se o padrão corresponder, ele vinculará o valor do padrão
no âmbito externo. Se o padrão _não_ corresponder, o programa fluirá para
o braço `else`, que deve retornar da função.

Na Listagem 6-9, você pode ver a aparência da Listagem 6-8 ao usar `let...else` em
lugar de `if let`.

<Listing number="6-9" caption="Using `let...else` to clarify the flow through the function">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-09/src/main.rs:describe}}
```

</Listing>

Observe que ele permanece no “caminho da felicidade” no corpo principal da função
maneira, sem ter fluxo de controle significativamente diferente para dois ramos, o
como o `if let` fez.

Se você tiver uma situação em que seu programa possui uma lógica muito detalhada para
expressar usando `match`, lembre-se de que `if let` e `let...else` estão em seu
Caixa de ferramentas de ferrugem também.

## Resumo

Agora abordamos como usar enums para criar tipos personalizados que podem ser um de
conjunto de valores enumerados. Mostramos como o `Option<T>` da biblioteca padrão
type ajuda você a usar o sistema de tipos para evitar erros. Quando os valores enum têm
dados dentro deles, você pode usar `match` ou `if let` para extrair e usar esses
valores, dependendo de quantos casos você precisa tratar.

Seus programas Rust agora podem expressar conceitos em seu domínio usando estruturas e
enumerações. A criação de tipos personalizados para usar em sua API garante a segurança do tipo: O
compilador garantirá que suas funções obtenham apenas valores do tipo cada
função espera.

Para fornecer uma API bem organizada aos seus usuários e que seja simples
usar e expõe exatamente o que seus usuários precisarão, vamos agora
Módulos de Rust.
