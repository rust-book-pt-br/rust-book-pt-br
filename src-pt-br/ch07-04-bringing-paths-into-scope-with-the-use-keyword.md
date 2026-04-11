## Trazendo Caminhos para o Escopo com a Palavra-chave `use`

Ter de escrever os caminhos completos para chamar funções pode parecer
incômodo e repetitivo. Na Listagem 7-7, independentemente de termos escolhido
o caminho absoluto ou relativo para a função `add_to_waitlist`, toda vez que
quiséssemos chamá-la precisaríamos especificar também `front_of_house` e
`hosting`. Felizmente, há uma forma de simplificar esse processo: podemos criar
um atalho para um caminho com a palavra-chave `use` uma única vez e, depois,
usar o nome mais curto em qualquer outro lugar do escopo.

Na Listagem 7-11, trazemos o módulo `crate::front_of_house::hosting` para o
escopo da função `eat_at_restaurant`, de modo que só precisemos especificar
`hosting::add_to_waitlist` para chamar a função `add_to_waitlist` dentro de
`eat_at_restaurant`.

<Listing number="7-11" file-name="src/lib.rs" caption="Trazendo um módulo para o escopo com `use`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-11/src/lib.rs}}
```

</Listing>

Adicionar `use` e um caminho em um escopo é semelhante a criar um link
simbólico no sistema de arquivos. Ao adicionar
`use crate::front_of_house::hosting` na raiz do crate, `hosting` passa a ser um
nome válido naquele escopo, como se o módulo `hosting` tivesse sido definido na
raiz do crate. Caminhos trazidos para o escopo com `use` também obedecem às
regras de privacidade, como quaisquer outros caminhos.

Observe que `use` só cria o atalho para o escopo específico em que aparece. A
Listagem 7-12 move a função `eat_at_restaurant` para um novo módulo filho
chamado `customer`, que então passa a estar em um escopo diferente daquele da
instrução `use`; por isso, o corpo da função não compilará.

<Listing number="7-12" file-name="src/lib.rs" caption="Uma instrução `use` só vale no escopo em que está">

```rust,noplayground,test_harness,does_not_compile,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-12/src/lib.rs}}
```

</Listing>

O erro do compilador mostra que o atalho não se aplica mais dentro do módulo
`customer`:

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-12/output.txt}}
```

Observe que também há um aviso dizendo que `use` não está mais sendo usado no
escopo em que foi declarado! Para corrigir esse problema, mova o `use` para
dentro do módulo `customer` também, ou faça referência ao atalho do módulo pai
com `super::hosting` dentro do módulo filho `customer`.

### Criando Caminhos `use` Idiomáticos

Na Listagem 7-11, você talvez tenha se perguntado por que especificamos
`use crate::front_of_house::hosting` e depois chamamos
`hosting::add_to_waitlist` em `eat_at_restaurant`, em vez de especificar o
caminho `use` até a própria função `add_to_waitlist` para obter o mesmo
resultado, como na Listagem 7-13.

<Listing number="7-13" file-name="src/lib.rs" caption="Trazendo a função `add_to_waitlist` para o escopo com `use`, o que não é idiomático">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-13/src/lib.rs}}
```

</Listing>

Embora tanto a Listagem 7-11 quanto a Listagem 7-13 realizem a mesma tarefa, a
Listagem 7-11 é a forma idiomática de trazer uma função para o escopo com
`use`. Trazer o módulo pai da função para o escopo com `use` significa que
temos de especificar o módulo pai ao chamar a função. Especificar o módulo pai
ao chamar a função deixa claro que ela não está definida localmente, ao mesmo
tempo em que minimiza a repetição do caminho completo. O código da Listagem
7-13 não deixa claro onde `add_to_waitlist` está definida.

Por outro lado, ao trazer structs, enums e outros itens com `use`, é idiomático
especificar o caminho completo. A Listagem 7-14 mostra a forma idiomática de
trazer a struct `HashMap`, da biblioteca padrão, para o escopo de um crate
binário.

<Listing number="7-14" file-name="src/main.rs" caption="Trazendo `HashMap` para o escopo de forma idiomática">

```rust
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-14/src/main.rs}}
```

</Listing>

Não existe um motivo técnico muito forte por trás desse idiomatismo: ele é
simplesmente a convenção que emergiu, e as pessoas se acostumaram a ler e
escrever código Rust dessa forma.

A exceção a esse idiomatismo ocorre quando trazemos para o escopo, com
instruções `use`, dois itens com o mesmo nome, porque Rust não permite isso. A
Listagem 7-15 mostra como trazer para o escopo dois tipos `Result` com o mesmo
nome, mas pertencentes a módulos pais diferentes, e como se referir a eles.

<Listing number="7-15" file-name="src/lib.rs" caption="Trazer dois tipos com o mesmo nome para o mesmo escopo exige usar seus módulos pais">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-15/src/lib.rs:here}}
```

</Listing>

Como você pode ver, usar os módulos pais distingue os dois tipos `Result`. Se,
em vez disso, especificássemos `use std::fmt::Result` e `use std::io::Result`,
teríamos dois tipos `Result` no mesmo escopo, e Rust não saberia a qual deles
estamos nos referindo ao usar `Result`.

### Fornecendo Novos Nomes com a Palavra-chave `as`

Existe outra solução para o problema de trazer para o mesmo escopo, com `use`,
dois tipos com o mesmo nome: depois do caminho, podemos especificar `as` e um
novo nome local, ou _alias_, para o tipo. A Listagem 7-16 mostra outra forma
de escrever o código da Listagem 7-15, renomeando um dos dois tipos `Result`
com `as`.

<Listing number="7-16" file-name="src/lib.rs" caption="Renomeando um tipo ao trazê-lo para o escopo com a palavra-chave `as`">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-16/src/lib.rs:here}}
```

</Listing>

Na segunda instrução `use`, escolhemos o novo nome `IoResult` para o tipo
`std::io::Result`, que não entrará em conflito com `Result`, vindo de
`std::fmt`, que também trouxemos para o escopo. Tanto a Listagem 7-15 quanto a
Listagem 7-16 são consideradas idiomáticas, então a escolha é sua!

### Reexportando Nomes com `pub use`

Quando trazemos um nome para o escopo com a palavra-chave `use`, esse nome fica
privado ao escopo para o qual o importamos. Para permitir que código fora
desse escopo se refira a esse nome como se ele tivesse sido definido ali,
podemos combinar `pub` e `use`. Essa técnica é chamada de _reexportação_,
porque estamos trazendo um item para o escopo, mas também disponibilizando
esse item para que outras pessoas o tragam para seus próprios escopos.

A Listagem 7-17 mostra o código da Listagem 7-11 com o `use` no módulo raiz
alterado para `pub use`.

<Listing number="7-17" file-name="src/lib.rs" caption="Disponibilizando um nome para qualquer código a partir de um novo escopo com `pub use`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-17/src/lib.rs}}
```

</Listing>

Antes dessa mudança, código externo teria de chamar a função
`add_to_waitlist` usando o caminho
`restaurant::front_of_house::hosting::add_to_waitlist()`, o que também
exigiria que o módulo `front_of_house` fosse marcado como `pub`. Agora que esse
`pub use` reexportou o módulo `hosting` a partir do módulo raiz, código externo
pode usar o caminho `restaurant::hosting::add_to_waitlist()`.

Reexportação é útil quando a estrutura interna do seu código é diferente de
como quem chama esse código pensa sobre o domínio. Por exemplo, nesta metáfora
do restaurante, as pessoas que administram o restaurante pensam em “frente da
casa” e “fundos da casa”. Mas clientes que visitam um restaurante
provavelmente não pensam nas partes do restaurante nesses termos. Com `pub
use`, podemos escrever nosso código com uma estrutura e expor uma estrutura
diferente. Isso torna nossa biblioteca bem organizada tanto para quem trabalha
na sua implementação quanto para quem a utiliza. Veremos outro exemplo de
`pub use` e como isso afeta a documentação do seu crate em [“Exportando uma API
Pública Conveniente”][ch14-pub-use]<!-- ignore -->, no Capítulo 14.

### Usando Pacotes Externos

No Capítulo 2, programamos um projeto de jogo de adivinhação que usava um
pacote externo chamado `rand` para obter números aleatórios. Para usar `rand`
em nosso projeto, adicionamos esta linha a _Cargo.toml_:

<!-- When updating the version of `rand` used, also update the version of
`rand` used in these files so they all match:
* ch02-00-guessing-game-tutorial.md
* ch14-03-cargo-workspaces.md
-->

<Listing file-name="Cargo.toml">

```toml
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-02/Cargo.toml:9:}}
```

</Listing>

Adicionar `rand` como dependência em _Cargo.toml_ instrui o Cargo a baixar o
pacote `rand`, bem como quaisquer dependências dele, de
[crates.io](https://crates.io/), e disponibilizar `rand` ao nosso projeto.

Depois, para trazer as definições de `rand` para o escopo do nosso pacote,
adicionamos uma linha `use` que começa com o nome do crate, `rand`, e listamos
os itens que queríamos trazer para o escopo. Lembre-se de que, em [“Gerando um
Número Aleatório”][rand]<!-- ignore -->, no Capítulo 2, trouxemos a trait
`Rng` para o escopo e chamamos a função `rand::thread_rng`:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-03/src/main.rs:ch07-04}}
```

Membros da comunidade Rust disponibilizaram muitos pacotes em
[crates.io](https://crates.io/), e trazer qualquer um deles para o seu pacote
envolve essas mesmas etapas: listá-lo no arquivo _Cargo.toml_ do pacote e usar
`use` para trazer itens do crate para o escopo.

Observe que a biblioteca padrão, `std`, também é um crate externo ao nosso
pacote. Como a biblioteca padrão acompanha a linguagem Rust, não precisamos
alterar _Cargo.toml_ para incluir `std`. Mas precisamos nos referir a ela com
`use` para trazer itens dali para o escopo do nosso pacote. Por exemplo, com
`HashMap`, usaríamos esta linha:

```rust
use std::collections::HashMap;
```

Esse é um caminho absoluto que começa com `std`, o nome do crate da biblioteca
padrão.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-nested-paths-to-clean-up-large-use-lists"></a>

### Usando Caminhos Aninhados para Limpar Listas de `use`

Se estivermos usando vários itens definidos no mesmo crate ou no mesmo módulo,
listar cada item em sua própria linha pode ocupar muito espaço vertical nos
arquivos. Por exemplo, estas duas instruções `use` que tínhamos no jogo de
adivinhação, na Listagem 2-4, trazem itens de `std` para o escopo:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-01-use-std-unnested/src/main.rs:here}}
```

</Listing>

Em vez disso, podemos usar caminhos aninhados para trazer esses mesmos itens
para o escopo em uma única linha. Fazemos isso especificando a parte comum do
caminho, seguida por dois-pontos duplos e, então, chaves em torno de uma lista
das partes dos caminhos que diferem, como mostra a Listagem 7-18.

<Listing number="7-18" file-name="src/main.rs" caption="Especificando um caminho aninhado para trazer para o escopo vários itens com o mesmo prefixo">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-18/src/main.rs:here}}
```

</Listing>

Em programas maiores, trazer muitos itens para o escopo a partir do mesmo crate
ou módulo usando caminhos aninhados pode reduzir bastante o número de
instruções `use` separadas necessárias.

Podemos usar um caminho aninhado em qualquer nível de um caminho, o que é útil
ao combinar duas instruções `use` que compartilham um subcaminho. Por exemplo,
a Listagem 7-19 mostra duas instruções `use`: uma que traz `std::io` para o
escopo e outra que traz `std::io::Write`.

<Listing number="7-19" file-name="src/lib.rs" caption="Duas instruções `use` em que uma é subcaminho da outra">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-19/src/lib.rs}}
```

</Listing>

A parte comum desses dois caminhos é `std::io`, e esse é o primeiro caminho
completo. Para fundir esses dois caminhos em uma única instrução `use`,
podemos usar `self` no caminho aninhado, como mostra a Listagem 7-20.

<Listing number="7-20" file-name="src/lib.rs" caption="Combinando os caminhos da Listagem 7-19 em uma única instrução `use`">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-20/src/lib.rs}}
```

</Listing>

Essa linha traz `std::io` e `std::io::Write` para o escopo.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-glob-operator"></a>

### Importando Itens com o Operador Glob

Se quisermos trazer para o escopo _todos_ os itens públicos definidos em um
caminho, podemos especificar esse caminho seguido do operador glob `*`:

```rust
use std::collections::*;
```

Essa instrução `use` traz para o escopo atual todos os itens públicos definidos
em `std::collections`. Tenha cuidado ao usar o operador glob! Ele pode tornar
mais difícil identificar quais nomes estão em escopo e onde um nome usado no
programa foi definido. Além disso, se a dependência alterar suas definições,
aquilo que você importou também muda, o que pode levar a erros de compilação ao
atualizar a dependência se ela passar a incluir uma definição com o mesmo nome
de uma definição sua no mesmo escopo, por exemplo.

O operador glob costuma ser usado em testes para trazer para o módulo `tests`
tudo o que está sendo testado; falaremos disso em [“Como Escrever
Testes”][writing-tests]<!-- ignore -->, no Capítulo 11. O operador glob também
é usado às vezes como parte do padrão de prelude: consulte [a documentação da
biblioteca padrão](../std/prelude/index.html#other-preludes)<!-- ignore --> para
mais informações sobre esse padrão.

[ch14-pub-use]: ch14-02-publishing-to-crates-io.html#exporting-a-convenient-public-api
[rand]: ch02-00-guessing-game-tutorial.html#generating-a-random-number
[writing-tests]: ch11-01-writing-tests.html#how-to-write-tests
