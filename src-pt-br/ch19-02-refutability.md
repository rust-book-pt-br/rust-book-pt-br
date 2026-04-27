## Refutabilidade: Se um Padrão Pode Falhar ao Corresponder

Os padrões vêm em duas formas: refutáveis e irrefutáveis. Padrões que
correspondem a qualquer valor possível passado são _irrefutáveis_. Um exemplo
é `x` na instrução `let x = 5;`, porque `x` corresponde a qualquer coisa e,
portanto, não pode falhar. Já os padrões que podem falhar ao corresponder a
algum valor possível são _refutáveis_. Um exemplo é `Some(x)` na expressão
`if let Some(x) = a_value`, porque, se o valor na variável `a_value` for
`None` em vez de `Some`, o padrão `Some(x)` não corresponderá.

Parâmetros de função, instruções `let` e loops `for` só podem aceitar padrões
irrefutáveis, porque o programa não pode fazer nada significativo quando os
valores não correspondem. Já as expressões `if let` e `while let`, bem como a
instrução `let...else`, aceitam padrões refutáveis e irrefutáveis, mas o
compilador alerta contra padrões irrefutáveis porque, por definição, essas
construções servem para lidar com possíveis falhas: a utilidade de uma
condicional está em sua capacidade de se comportar de maneira diferente
dependendo do sucesso ou do fracasso.

Em geral, você não deveria se preocupar com a distinção entre padrões
refutáveis e irrefutáveis; no entanto, precisa estar familiarizado com o
conceito de refutabilidade para conseguir responder quando o vir em uma
mensagem de erro. Nesses casos, você precisará alterar o padrão ou a construção
com a qual está usando o padrão, dependendo do comportamento pretendido do
código.

Vejamos um exemplo do que acontece quando tentamos usar um padrão refutável onde
Rust exige um padrão irrefutável, e vice-versa. A Listagem 19-8 mostra uma
instrução `let`, mas, no padrão, especificamos `Some(x)`, um padrão refutável.
Como você pode imaginar, esse código não vai compilar.

<Listing number="19-8" caption="Tentando usar um padrão refutável com `let`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-08/src/main.rs:here}}
```

</Listing>

Se `some_option_value` fosse um valor `None`, ele deixaria de corresponder ao
padrão `Some(x)`, o que significa que o padrão é refutável. No entanto, a
instrução `let` só aceita um padrão irrefutável, porque não existe nada válido
que o código possa fazer com um valor `None`. Em tempo de compilação, Rust
reclamará que tentamos usar um padrão refutável onde um padrão irrefutável é
necessário:

```console
{{#include ../listings/ch19-patterns-and-matching/listing-19-08/output.txt}}
```

Porque não cobrimos (e não poderíamos cobrir!) todos os valores válidos com o
padrão `Some(x)`, Rust produz corretamente um erro do compilador.

Se tivermos um padrão refutável onde é necessário um padrão irrefutável,
podemos corrigir isso mudando o código que usa o padrão: em vez de usar `let`,
podemos usar `let...else`. Então, se o padrão não corresponder, o código entre
chaves tratará o valor. A Listagem 19-9 mostra como corrigir o código da
Listagem 19-8.

<Listing number="19-9" caption="Usando `let...else` e um bloco com padrões refutáveis no lugar de `let`">

```rust
{{#rustdoc_include ../listings/ch19-patterns-and-matching/listing-19-09/src/main.rs:here}}
```

</Listing>

Demos uma saída para o código! Esse código é perfeitamente válido, embora isso
signifique que não podemos usar um padrão irrefutável sem receber um aviso. Se
passarmos a `let...else` um padrão que sempre corresponderá, como `x`, conforme
mostrado na Listagem 19-10, o compilador emitirá um aviso.

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

Por essa razão, os braços de `match` devem usar padrões refutáveis, exceto o
último braço, que deve corresponder a quaisquer valores restantes com um padrão
irrefutável. Rust nos permite usar um padrão irrefutável em um `match` com
apenas um braço, mas essa sintaxe não é particularmente útil e pode ser
substituída por uma instrução `let` mais simples.

Agora que você sabe onde usar padrões e conhece a diferença entre padrões
refutáveis e irrefutáveis, vamos cobrir toda a sintaxe que podemos usar para
criar padrões.
