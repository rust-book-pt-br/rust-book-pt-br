## Refutabilidade: se um padrão pode não corresponder

Os padrões vêm em duas formas: refutáveis ​​e irrefutáveis. Padrões que serão match
para qualquer valor possível passado são _irrefutáveis_. Um exemplo seria `x` no
declaração `let x = 5;` porque `x` corresponde a qualquer coisa e, portanto, não pode falhar
para match. Os padrões que podem falhar em match para algum valor possível são
_refutável_. Um exemplo seria `Some(x)` na expressão `if let Some(x) =
a_value` porque se o valor na variável `a_value` for `None` em vez de
`Some `, o padrão` Some(x)`não será match.

Parâmetros de função, instruções `let` e loops `for` só podem aceitar
padrões irrefutáveis porque o programa não pode fazer nada significativo quando
valores não match. As expressões `if let` e `while let` e o
A instrução `let...else` aceita padrões refutáveis e irrefutáveis, mas o
compilador alerta contra padrões irrefutáveis porque, por definição, eles são
destinado a lidar com possíveis falhas: A funcionalidade de uma condicional está em
sua capacidade de funcionar de maneira diferente dependendo do sucesso ou do fracasso.

Em geral, você não deveria se preocupar com a distinção entre refutável
e padrões irrefutáveis; no entanto, você precisa estar familiarizado com o conceito
de refutabilidade para que você possa responder quando vir uma mensagem de erro. Em
nesses casos, você precisará alterar o padrão ou a construção que está
usando o padrão com, dependendo do comportamento pretendido do código.

Vejamos um exemplo do que acontece quando tentamos usar um padrão refutável
onde Rust requer um padrão irrefutável e vice-versa. A listagem 19-8 mostra um
declaração `let`, mas para o padrão, especificamos ` Some(x)`, um refutável
padrão. Como você poderia esperar, este código não será compilado.

<Listing number="19-8" caption="Tentando usar um padrão refutável com `let`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-08/src/main.rs:here}}
```

</Listing>

Se `some_option_value` fosse um valor `None`, ele falharia em match o padrão
` Some(x) `, o que significa que o padrão é refutável. No entanto, a instrução` let `pode
só aceita um padrão irrefutável porque não há nada válido que o código possa
fazer com um valor` None`. Em tempo de compilação, Rust irá reclamar que tentamos
use um padrão refutável onde um padrão irrefutável for necessário:

```console
{{#include ../listings/ch19-patterns-and-matching/listing-19-08/output.txt}}
```

Porque não cobrimos (e não poderíamos cobrir!) todos os valores válidos com o
padrão `Some(x)`, Rust produz corretamente um erro do compilador.

If we have a refutable pattern where an irrefutable pattern is needed, we can
fix it by changing the code that uses the pattern: Instead of using `let`, we
pode usar ` let...else`. Then, if the pattern doesn’t match, the code in the curly
colchetes tratarão do valor. A Listagem 19-9 mostra como corrigir o código em
Listagem 19-8.

<Listing number="19-9" caption="Usando `let...else` e um bloco com padrões refutáveis no lugar de `let`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-09/src/main.rs:here}}
```

</Listing>

Demos uma saída ao código! Este código é perfeitamente válido, embora signifique que
não pode usar um padrão irrefutável sem receber um aviso. Se nós dermos
`let...else ` um padrão que sempre será match, como`x`, conforme mostrado na Listagem
19-10, o compilador dará um aviso.

<Listing number="19-10" caption="Tentando usar um padrão irrefutável com `let...else`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-10/src/main.rs:here}}
```

</Listing>

Rust reclama que não faz sentido usar `let...else` com um
padrão irrefutável:

```console
{{#include ../listings/ch19-patterns-and-matching/listing-19-10/output.txt}}
```

Por esta razão, os braços match devem usar padrões refutáveis, exceto o último
arm, que deve match quaisquer valores restantes com um padrão irrefutável. Rust
nos permite usar um padrão irrefutável em um `match` com apenas um braço, mas
esta sintaxe não é particularmente útil e pode ser substituída por uma mais simples
Instrução `let`.

Agora que você sabe onde usar padrões e a diferença entre refutáveis
e padrões irrefutáveis, vamos cobrir toda a sintaxe que podemos usar para criar
padrões.
