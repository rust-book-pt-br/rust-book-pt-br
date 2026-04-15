## Trazendo caminhos para o escopo com a palavra-chave `use`

Ter de escrever os caminhos completos para chamar funções pode parecer
inconveniente e repetitivo. Na Listagem 7-7, independentemente de escolhermos o
caminho absoluto ou relativo para a função `add_to_waitlist`, toda vez que
queríamos chamar `add_to_waitlist` precisávamos especificar também
`front_of_house` e `hosting`. Felizmente, há uma forma de simplificar esse
processo: podemos criar um atalho para um caminho com a palavra-chave `use` uma
única vez e então usar o nome mais curto em qualquer outro lugar daquele
escopo.

Na Listagem 7-11, trazemos o módulo `crate::front_of_house::hosting` para o
escopo da função `eat_at_restaurant`, de modo que só precisamos especificar
`hosting::add_to_waitlist` para chamar a função `add_to_waitlist` dentro de
`eat_at_restaurant`.

<Listing number="7-11" file-name="src/lib.rs" caption="Trazendo um módulo para o escopo com `use`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-11/src/lib.rs}}
```

</Listing>

Adicionar `use` e um caminho dentro de um escopo é semelhante a criar um link
simbólico no sistema de arquivos. Ao adicionar
`use crate::front_of_house::hosting` na raiz da crate, `hosting` passa a ser um
nome válido naquele escopo, como se o módulo `hosting` tivesse sido definido na
raiz da crate. Caminhos trazidos para o escopo com `use` também respeitam as
regras de privacidade, como quaisquer outros caminhos.

Observe que `use` cria o atalho apenas para o escopo específico em que aparece.
A Listagem 7-12 move a função `eat_at_restaurant` para um novo módulo filho
chamado `customer`, que então se torna um escopo diferente daquele da
instrução `use`, e por isso o corpo da função não compilará.

<Listing number="7-12" file-name="src/lib.rs" caption="Uma instrução `use` se aplica apenas ao escopo em que ela foi declarada">

```rust,noplayground,test_harness,does_not_compile,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-12/src/lib.rs}}
```

</Listing>

O erro do compilador mostra que o atalho já não se aplica dentro do módulo
`customer`:

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-12/output.txt}}
```

Observe também que há um aviso de que `use` não está mais sendo usada em seu
escopo! Para corrigir esse problema, mova a `use` para dentro do módulo
`customer` também, ou então faça referência ao atalho presente no módulo pai
com `super::hosting` dentro do módulo filho `customer`.

### Criando caminhos `use` idiomáticos

Na Listagem 7-11, você talvez tenha se perguntado por que especificamos
`use crate::front_of_house::hosting` e então chamamos
`hosting::add_to_waitlist` em `eat_at_restaurant`, em vez de especificar o
caminho de `use` até a função `add_to_waitlist` para obter o mesmo resultado,
como na Listagem 7-13.

<Listing number="7-13" file-name="src/lib.rs" caption="Trazendo a função `add_to_waitlist` para o escopo com `use`, de uma maneira pouco idiomática">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-13/src/lib.rs}}
```

</Listing>

Embora a Listagem 7-11 e a Listagem 7-13 façam a mesma coisa, a Listagem 7-11
é a forma idiomática de trazer uma função para o escopo com `use`. Trazer o
módulo pai da função para o escopo com `use` significa que precisamos
especificar o módulo pai ao chamar a função. Especificar esse módulo pai ao
chamar a função deixa claro que ela não foi definida localmente, enquanto ainda
minimiza a repetição do caminho completo. O código da Listagem 7-13 torna menos
claro onde `add_to_waitlist` está definida.

Por outro lado, ao trazer structs, enums e outros itens para o escopo com
`use`, o idiomático é especificar o caminho completo. A Listagem 7-14 mostra a
forma idiomática de trazer a struct `HashMap` da biblioteca padrão para o
escopo de uma crate binária.

<Listing number="7-14" file-name="src/main.rs" caption="Trazendo `HashMap` para o escopo de forma idiomática">

```rust
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-14/src/main.rs}}
```

</Listing>

Não há um motivo técnico forte por trás desse idiomatismo: é simplesmente a
convenção que surgiu, e as pessoas se acostumaram a ler e escrever código Rust
dessa maneira.

A exceção a esse idiomatismo aparece quando trazemos para o escopo dois itens
com o mesmo nome por meio de instruções `use`, porque Rust não permite isso. A
Listagem 7-15 mostra como trazer para o escopo dois tipos `Result` que têm o
mesmo nome, mas módulos-pai diferentes, e como se referir a eles.

<Listing number="7-15" file-name="src/lib.rs" caption="Trazer dois tipos com o mesmo nome para o mesmo escopo exige usar seus módulos-pai">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-15/src/lib.rs:here}}
```

</Listing>

Como você pode ver, usar os módulos-pai distingue os dois tipos `Result`. Se,
em vez disso, tivéssemos especificado `use std::fmt::Result` e
`use std::io::Result`, teríamos dois tipos `Result` no mesmo escopo, e Rust não
saberia a qual deles estamos nos referindo ao usar `Result`.

### Fornecendo novos nomes com a palavra-chave `as`

Existe outra solução para o problema de trazer para o mesmo escopo dois tipos
com o mesmo nome usando `use`: depois do caminho, podemos especificar `as` e um
novo nome local, ou _alias_, para o tipo. A Listagem 7-16 mostra outra maneira
de escrever o código da Listagem 7-15, renomeando um dos dois tipos `Result`
com `as`.

<Listing number="7-16" file-name="src/lib.rs" caption="Renomeando um tipo quando ele é trazido para o escopo com a palavra-chave `as`">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-16/src/lib.rs:here}}
```

</Listing>

Na segunda instrução `use`, escolhemos o novo nome `IoResult` para o tipo
`std::io::Result`, que não entrará em conflito com o `Result` de `std::fmt` que
também trouxemos para o escopo. Tanto a Listagem 7-15 quanto a Listagem 7-16
são consideradas idiomáticas, então a escolha fica a seu critério!

### Reexportando nomes com `pub use`

Quando trazemos um nome para o escopo com a palavra-chave `use`, esse nome fica
privado ao escopo para o qual o importamos. Para permitir que código fora desse
escopo se refira a esse nome como se ele tivesse sido definido ali, podemos
combinar `pub` e `use`. Essa técnica é chamada de _reexportação_, porque
estamos trazendo um item para o escopo, mas também tornando esse item
disponível para que outras pessoas o tragam para seus próprios escopos.

A Listagem 7-17 mostra o código da Listagem 7-11 com `use` no módulo raiz
alterado para `pub use`.

<Listing number="7-17" file-name="src/lib.rs" caption="Disponibilizando um nome para qualquer código usar a partir de um novo escopo com `pub use`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-17/src/lib.rs}}
```

</Listing>

Antes dessa mudança, código externo teria de chamar a função
`add_to_waitlist` usando o caminho
`restaurant::front_of_house::hosting::add_to_waitlist()`, o que também exigiria
que o módulo `front_of_house` fosse marcado como `pub`. Agora que esse `pub use`
reexportou o módulo `hosting` a partir do módulo raiz, código externo pode usar
o caminho `restaurant::hosting::add_to_waitlist()`.

A reexportação é útil quando a estrutura interna do seu código difere da forma
como pessoas chamando o seu código pensam no domínio do problema. Por exemplo,
nesta metáfora do restaurante, as pessoas que trabalham no restaurante pensam
em termos como “front of house” e “back of house”. Mas clientes visitando um
restaurante provavelmente não pensariam nas partes do restaurante dessa forma.
Com `pub use`, podemos escrever nosso código com uma estrutura e expor outra
estrutura. Isso faz com que a biblioteca fique bem organizada tanto para quem
trabalha nela quanto para quem a utiliza. Veremos outro exemplo de `pub use` e
como isso afeta a documentação da crate em [“Exportando uma API pública
conveniente”][ch14-pub-use]<!-- ignore -->, no Capítulo 14.

### Usando pacotes externos

No Capítulo 2, programamos um projeto de jogo de adivinhação que usava um
pacote externo chamado `rand` para obter números aleatórios. Para usar `rand`
no nosso projeto, adicionamos esta linha a _Cargo.toml_:

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

Adicionar `rand` como dependência em _Cargo.toml_ informa ao Cargo para baixar
o pacote `rand` e quaisquer dependências dele a partir de
[crates.io](https://crates.io/), além de disponibilizar `rand` ao nosso
projeto.

Depois, para trazer definições de `rand` para o escopo do nosso pacote,
adicionamos uma linha `use` começando com o nome da crate, `rand`, e listamos
os itens que queríamos trazer para o escopo. Lembre-se de que, em
[“Gerando um número aleatório”][rand]<!-- ignore --> no Capítulo 2, trouxemos a
trait `Rng` para o escopo e chamamos a função `rand::thread_rng`:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-03/src/main.rs:ch07-04}}
```

Membros da comunidade Rust disponibilizaram muitos pacotes em
[crates.io](https://crates.io/), e trazer qualquer um deles para o seu pacote
envolve esses mesmos passos: listá-lo no arquivo _Cargo.toml_ do pacote e usar
`use` para trazer itens de suas crates para o escopo.

Observe que a biblioteca padrão `std` também é uma crate externa ao nosso
pacote. Como a biblioteca padrão acompanha a linguagem Rust, não precisamos
alterar _Cargo.toml_ para incluir `std`. Mas precisamos nos referir a ela com
`use` para trazer itens de lá para o escopo do nosso pacote. Por exemplo, com
`HashMap` usaríamos esta linha:

```rust
use std::collections::HashMap;
```

Este é um caminho absoluto começando com `std`, o nome da crate da biblioteca
padrão.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-nested-paths-to-clean-up-large-use-lists"></a>

### Usando caminhos aninhados para limpar listas de `use`

Se estivermos usando vários itens definidos na mesma crate ou no mesmo módulo,
listar cada item em sua própria linha pode ocupar bastante espaço vertical em
nossos arquivos. Por exemplo, estas duas instruções `use` que tínhamos no jogo
de adivinhação da Listagem 2-4 trazem itens de `std` para o escopo:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-01-use-std-unnested/src/main.rs:here}}
```

</Listing>

Em vez disso, podemos usar caminhos aninhados para trazer os mesmos itens para
o escopo em uma única linha. Fazemos isso especificando a parte comum do
caminho, seguida por dois pontos duplos, e depois chaves em torno de uma lista
das partes do caminho que diferem, como mostra a Listagem 7-18.

<Listing number="7-18" file-name="src/main.rs" caption="Especificando um caminho aninhado para trazer para o escopo vários itens com o mesmo prefixo">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-18/src/main.rs:here}}
```

</Listing>

Em programas maiores, trazer muitos itens da mesma crate ou do mesmo módulo
para o escopo usando caminhos aninhados pode reduzir bastante a quantidade de
instruções `use` separadas necessárias!

Podemos usar um caminho aninhado em qualquer nível de um caminho, o que é útil
ao combinar duas instruções `use` que compartilham um subcaminho. Por exemplo,
a Listagem 7-19 mostra duas instruções `use`: uma que traz `std::io` para o
escopo e outra que traz `std::io::Write` para o escopo.

<Listing number="7-19" file-name="src/lib.rs" caption="Duas instruções `use` em que uma é um subcaminho da outra">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-19/src/lib.rs}}
```

</Listing>

A parte comum desses dois caminhos é `std::io`, e esse é o primeiro caminho
inteiro. Para mesclar esses dois caminhos em uma só instrução `use`, podemos
usar `self` no caminho aninhado, como mostra a Listagem 7-20.

<Listing number="7-20" file-name="src/lib.rs" caption="Combinando os caminhos da Listagem 7-19 em uma única instrução `use`">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-20/src/lib.rs}}
```

</Listing>

Essa linha traz `std::io` e `std::io::Write` para o escopo.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-glob-operator"></a>

### Importando itens com o operador glob

Se quisermos trazer para o escopo _todos_ os itens públicos definidos em um
caminho, podemos especificar esse caminho seguido pelo operador glob `*`:

```rust
use std::collections::*;
```

Essa instrução `use` traz todos os itens públicos definidos em
`std::collections` para o escopo atual. Tenha cuidado ao usar o operador glob!
Ele pode dificultar descobrir quais nomes estão no escopo e onde um nome usado
no programa foi definido. Além disso, se a dependência mudar suas definições,
aquilo que foi importado também muda, o que pode levar a erros de compilação ao
atualizar a dependência, por exemplo se ela adicionar uma definição com o mesmo
nome de uma definição sua no mesmo escopo.

O operador glob é frequentemente usado em testes para trazer tudo que está
sendo testado para dentro do módulo `tests`; falaremos disso em [“Como escrever
testes”][writing-tests]<!-- ignore --> no Capítulo 11. O operador glob também é
às vezes usado como parte do padrão prelude; veja [a documentação da biblioteca
padrão](../std/prelude/index.html#other-preludes)<!-- ignore --> para mais
informações sobre esse padrão.

[ch14-pub-use]: ch14-02-publishing-to-crates-io.html#exporting-a-convenient-public-api
[rand]: ch02-00-guessing-game-tutorial.html#generating-a-random-number
[writing-tests]: ch11-01-writing-tests.html#how-to-write-tests
