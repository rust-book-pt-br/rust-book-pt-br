## Fluxo de Controle Conciso com `if let` e `let...else`

A sintaxe `if let` permite combinar `if` e `let` em uma forma menos verbosa de
tratar valores que correspondem a um padrão, ignorando os demais. Considere o
programa da Listagem 6-6, que faz `match` sobre um valor `Option<u8>` na
variável `config_max`, mas só quer executar código se o valor for a variante
`Some`.

<Listing number="6-6" caption="Um `match` que só se importa em executar código quando o valor é `Some`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-06/src/main.rs:here}}
```

</Listing>

Se o valor for `Some`, imprimimos o valor dentro da variante `Some`, vinculando
esse valor à variável `max` no padrão. Não queremos fazer nada com o valor
`None`. Para satisfazer a expressão `match`, precisamos adicionar `_ => ()`
depois de tratar apenas uma variante, o que é um código repetitivo incômodo de
incluir.

Em vez disso, poderíamos escrever isso de forma mais curta usando `if let`. O
código a seguir se comporta da mesma maneira que o `match` da Listagem 6-6:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-12-if-let/src/main.rs:here}}
```

A sintaxe `if let` recebe um padrão e uma expressão separados por um sinal de
igual. Ela funciona da mesma forma que `match`, em que a expressão é fornecida
ao `match` e o padrão aparece em seu primeiro braço. Neste caso, o padrão é
`Some(max)`, e `max` se vincula ao valor dentro de `Some`. Podemos então usar
`max` no corpo do bloco `if let` da mesma forma que o usamos no braço
correspondente do `match`. O código dentro do bloco `if let` só é executado se
o valor corresponder ao padrão.

Usar `if let` significa menos digitação, menos indentação e menos código
repetitivo. No entanto, você perde a verificação exaustiva que `match` impõe e
que garante que nenhum caso foi esquecido. Escolher entre `match` e `if let`
depende do que você está fazendo na situação concreta e se ganhar concisão é
uma troca aceitável pela perda da verificação exaustiva.

Em outras palavras, você pode pensar em `if let` como açúcar sintático para um
`match` que executa código quando o valor corresponde a um padrão e depois
ignora todos os outros valores.

Podemos incluir um `else` com `if let`. O bloco de código que acompanha o
`else` é o mesmo bloco que acompanharia o caso `_` na expressão `match`
equivalente ao `if let` com `else`. Lembre-se da definição do enum `Coin` na
Listagem 6-4, em que a variante `Quarter` também armazenava um valor
`UsState`. Se quiséssemos contar todas as moedas que não são quarters e, ao
mesmo tempo, anunciar o estado dos quarters, poderíamos fazer isso com uma
expressão `match`, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-13-count-and-announce-match/src/main.rs:here}}
```

Ou poderíamos usar uma expressão `if let` com `else`, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-14-count-and-announce-if-let-else/src/main.rs:here}}
```

## Permanecendo no “Caminho Feliz” com `let...else`

Um padrão comum é realizar algum cálculo quando um valor está presente e
retornar um valor padrão caso contrário. Continuando com nosso exemplo das
moedas com um valor `UsState`, se quiséssemos dizer algo engraçado dependendo
de quão antigo era o estado no quarter, poderíamos introduzir um método em
`UsState` para verificar a idade de um estado, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-07/src/main.rs:state}}
```

Então poderíamos usar `if let` para fazer `match` sobre o tipo da moeda,
introduzindo uma variável `state` dentro do corpo da condição, como na
Listagem 6-7.

<Listing number="6-7" caption="Verificando se um estado já existia em 1900 usando condicionais aninhadas dentro de um `if let`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-07/src/main.rs:describe}}
```

</Listing>

Isso resolve o problema, mas empurra o trabalho para dentro do corpo da
instrução `if let`; se o trabalho a ser feito for mais complicado, pode ficar
difícil acompanhar exatamente como os ramos de nível superior se relacionam.
Também poderíamos aproveitar o fato de que expressões produzem um valor para ou
produzir `state` a partir do `if let` ou retornar mais cedo, como na Listagem
6-8. Você também poderia fazer algo parecido com `match`.

<Listing number="6-8" caption="Usando `if let` para produzir um valor ou retornar antecipadamente">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-08/src/main.rs:describe}}
```

</Listing>

Mesmo assim, essa abordagem também é um pouco chata de acompanhar. Um dos
ramos do `if let` produz um valor, enquanto o outro retorna da função por
completo.

Para tornar esse padrão comum mais agradável de expressar, o Rust tem
`let...else`. A sintaxe `let...else` recebe um padrão do lado esquerdo e uma
expressão do lado direito, muito parecida com `if let`, mas não tem um ramo
`if`, apenas um ramo `else`. Se o padrão corresponder, ela vinculará o valor
do padrão no escopo externo. Se o padrão _não_ corresponder, o fluxo do
programa seguirá para o braço `else`, que deve retornar da função.

Na Listagem 6-9, você pode ver como a Listagem 6-8 fica ao usar `let...else`
no lugar de `if let`.

<Listing number="6-9" caption="Usando `let...else` para deixar mais claro o fluxo da função">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-09/src/main.rs:describe}}
```

</Listing>

Observe que, dessa forma, o código permanece no “caminho feliz” no corpo
principal da função, sem ter um fluxo de controle significativamente diferente
entre dois ramos, como acontecia com `if let`.

Se você se deparar com uma situação em que a lógica do seu programa fique
verbosa demais para ser expressa com `match`, lembre-se de que `if let` e
`let...else` também fazem parte da sua caixa de ferramentas em Rust.

## Resumo

Agora cobrimos como usar enums para criar tipos personalizados que podem ser um
dentre um conjunto de valores enumerados. Mostramos como o tipo `Option<T>` da
biblioteca padrão ajuda você a usar o sistema de tipos para prevenir erros.
Quando valores de enum têm dados dentro deles, você pode usar `match` ou
`if let` para extrair e usar esses valores, dependendo de quantos casos precisa
tratar.

Seus programas em Rust agora podem expressar conceitos do seu domínio usando
structs e enums. Criar tipos personalizados para usar na sua API garante
segurança de tipos: o compilador assegurará que suas funções recebam apenas
valores do tipo que cada função espera.

Para fornecer aos usuários uma API bem organizada, simples de usar e que exponha
somente o que eles realmente precisam, vamos agora nos voltar para os módulos
do Rust.
