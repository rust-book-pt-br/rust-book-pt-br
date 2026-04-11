## Trazendo caminhos para o escopo com a palavra-chave `use`

Ter que escrever os caminhos para chamar funções pode parecer inconveniente e
repetitivo. Na Listagem 7-7, se escolhemos o caminho absoluto ou relativo para
a função `add_to_waitlist`, toda vez que queríamos chamar `add_to_waitlist`
tivemos que especificar `front_of_house` e `hosting` também. Felizmente, há um
maneira de simplificar esse processo: podemos criar um atalho para um caminho com o `use`
palavra-chave uma vez e, em seguida, use o nome mais curto em qualquer outro lugar do escopo.

Na Listagem 7-11, trazemos o módulo `crate::front_of_house::hosting` para o
escopo da função `eat_at_restaurant` para que só tenhamos que especificar
`hosting::add_to_waitlist` para chamar a função `add_to_waitlist` em
`eat_at_restaurant`.

<Listing number="7-11" file-name="src/lib.rs" caption="Bringing a module into scope with `use`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-11/src/lib.rs}}
```

</Listing>

Adicionar `use` e um caminho em um escopo é semelhante a criar um link simbólico em
o sistema de arquivos. Adicionando `use crate::front_of_house::hosting` na caixa
root, `hosting` agora é um nome válido nesse escopo, assim como se `hosting`
módulo foi definido na raiz da caixa. Caminhos trazidos para o escopo com `use`
verifique também a privacidade, como qualquer outro caminho.

Observe que `use` cria apenas o atalho para o escopo específico no qual o
`use` ocorre. A Listagem 7-12 move a função `eat_at_restaurant` para uma nova
módulo filho chamado `customer`, que é então um escopo diferente do `use`
instrução, então o corpo da função não será compilado.

<Listing number="7-12" file-name="src/lib.rs" caption="A `use` statement only applies in the scope it’s in.">

```rust,noplayground,test_harness,does_not_compile,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-12/src/lib.rs}}
```

</Listing>

O erro do compilador mostra que o atalho não se aplica mais ao
`customer` módulo:

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-12/output.txt}}
```

Observe que também há um aviso de que `use` não é mais usado em seu escopo! Para
para corrigir esse problema, mova `use` dentro do módulo `customer` também ou faça referência
o atalho no módulo pai com `super::hosting` dentro do filho
`customer` módulo.

### Criando caminhos idiomáticos `use`

Na Listagem 7.11, você deve estar se perguntando por que especificamos `use
crate::front_of_house::hosting` and then called `hosting::add_to_waitlist` em
`eat_at_restaurant`, em vez de especificar o caminho `use` até
a função `add_to_waitlist` para obter o mesmo resultado, como na Listagem 7-13.

<Listing number="7-13" file-name="src/lib.rs" caption="Bringing the `add_to_waitlist` function into scope with `use`, which is unidiomatic">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-13/src/lib.rs}}
```

</Listing>

Embora a Listagem 7-11 e a Listagem 7-13 realizem a mesma tarefa, a Listagem
7-11 é a maneira idiomática de colocar uma função no escopo com `use`. Trazendo
o módulo pai da função no escopo com `use` significa que temos que especificar o
módulo pai ao chamar a função. Especificando o módulo pai quando
chamar a função deixa claro que a função não está definida localmente
enquanto ainda minimiza a repetição do caminho completo. O código na Listagem 7-13 é
não está claro onde `add_to_waitlist` está definido.

Por outro lado, ao trazer structs, enums e outros itens com `use`,
é idiomático especificar o caminho completo. A Listagem 7-14 mostra a maneira idiomática
para trazer a estrutura `HashMap` da biblioteca padrão para o escopo de um binário
caixa.

<Listing number="7-14" file-name="src/main.rs" caption="Bringing `HashMap` into scope in an idiomatic way">

```rust
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-14/src/main.rs}}
```

</Listing>

Não há nenhuma razão forte por trás dessa expressão: é apenas a convenção que
surgiu, e as pessoas se acostumaram a ler e escrever código Rust dessa maneira.

A exceção a esta expressão é se trouxermos dois itens com o mesmo nome
no escopo com instruções `use`, porque Rust não permite isso. Listagem 7-15
mostra como trazer para o escopo dois tipos `Result` que têm o mesmo nome, mas
diferentes módulos pai e como se referir a eles.

<Listing number="7-15" file-name="src/lib.rs" caption="Bringing two types with the same name into the same scope requires using their parent modules.">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-15/src/lib.rs:here}}
```

</Listing>

Como você pode ver, o uso dos módulos pai distingue os dois tipos `Result`.
Se, em vez disso, especificássemos `use std::fmt::Result` e `use std::io::Result`, teríamos
temos dois tipos `Result` no mesmo escopo, e Rust não saberia qual deles
quis dizer quando usamos `Result`.

### Fornecendo novos nomes com a palavra-chave `as`

Existe outra solução para o problema de trazer dois tipos com o mesmo nome
no mesmo escopo com `use`: Após o caminho, podemos especificar `as` e um novo
nome local, ou _alias_, para o tipo. A Listagem 7.16 mostra outra maneira de escrever
o código na Listagem 7.15 renomeando um dos dois tipos `Result` usando `as`.

<Listing number="7-16" file-name="src/lib.rs" caption="Renaming a type when it’s brought into scope with the `as` keyword">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-16/src/lib.rs:here}}
```

</Listing>

Na segunda instrução `use`, escolhemos o novo nome `IoResult` para o
`std::io::Result` tipo, que não entrará em conflito com o `Result` de `std::fmt`
que também trouxemos para o escopo. Listagem 7-15 e Listagem 7-16 são
considerado idiomático, então a escolha é sua!

### Reexportando nomes com `pub use`

Quando colocamos um nome no escopo com a palavra-chave `use`, o nome é privado para
o escopo para o qual o importamos. Para habilitar código fora desse escopo para referência
a esse nome como se tivesse sido definido nesse escopo, podemos combinar `pub` e
`use`. Essa técnica é chamada de _reexportação_ porque estamos trazendo um item
no escopo, mas também disponibilizando esse item para que outros possam trazer para seus
escopo.

A Listagem 7-17 mostra o código da Listagem 7-11 com `use` no módulo raiz
alterado para `pub use`.

<Listing number="7-17" file-name="src/lib.rs" caption="Making a name available for any code to use from a new scope with `pub use`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-17/src/lib.rs}}
```

</Listing>

Antes dessa mudança, o código externo teria que chamar o `add_to_waitlist`
função usando o caminho
`restaurant::front_of_house::hosting::add_to_waitlist()`, o que também teria
exigia que o módulo `front_of_house` fosse marcado como `pub`. Agora que este `pub
use` has re-exported the `hosting` módulo do módulo raiz, código externo
pode usar o caminho `restaurant::hosting::add_to_waitlist()`.

A reexportação é útil quando a estrutura interna do seu código é diferente
de como os programadores que chamam seu código pensariam sobre o domínio. Para
Por exemplo, nesta metáfora do restaurante, as pessoas que dirigem o restaurante pensam
sobre “frente da casa” e “fundos da casa”. Mas os clientes que visitam um restaurante
provavelmente não pensará nas partes do restaurante nesses termos. Com `pub
use`, podemos escrever nosso código com uma estrutura, mas expor uma estrutura diferente.
Isso torna nossa biblioteca bem organizada para programadores que trabalham na biblioteca
e programadores ligando para a biblioteca. Veremos outro exemplo de `pub use`
e como isso afeta a documentação da sua caixa em [“Exportando um Público Conveniente
API”][ch14-pub-use]<!-- ignore --> no Capítulo 14.

### Usando pacotes externos

No Capítulo 2, programamos um projeto de jogo de adivinhação que utilizou um
pacote chamado `rand` para obter números aleatórios. Para usar `rand` em nosso projeto, nós
adicionei esta linha a _Cargo.toml_:

<!-- When updating the version of `rand` used, also update the version of
`rand` usado nesses arquivos para que todos correspondam:
* ch02-00-tutorial de jogo de adivinhação.md
* ch14-03-cargo-workspaces.md
-->

<Listing file-name="Cargo.toml">

```toml
{{#include ../listings/ch02-guessing-game-tutorial/listing-02-02/Cargo.toml:9:}}
```

</Listing>

Adicionar `rand` como uma dependência em _Cargo.toml_ diz ao Cargo para baixar o
`rand` pacote e quaisquer dependências de [crates.io](https://crates.io/) e
disponibilizar `rand` para nosso projeto.

Então, para trazer as definições de `rand` para o escopo do nosso pacote, adicionamos um
`use` linha começando com o nome da caixa, `rand`, e listou os itens que
queria trazer para o escopo. Lembre-se disso em [“Gerando um Random
Número”][rand]<!-- ignore --> no Capítulo 2, trouxemos o traço `Rng` para
escopo e chamou a função `rand::thread_rng`:

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-03/src/main.rs:ch07-04}}
```

Membros da comunidade Rust disponibilizaram muitos pacotes em
[crates.io](https://crates.io/) e colocar qualquer um deles em seu pacote
envolve as mesmas etapas: listá-los no arquivo _Cargo.toml_ do seu pacote e
usando `use` para trazer itens de suas caixas para o escopo.

Observe que a biblioteca padrão `std` também é uma caixa externa ao nosso
pacote. Como a biblioteca padrão vem com a linguagem Rust, nós
não é necessário alterar _Cargo.toml_ para incluir `std`. Mas precisamos nos referir a
use `use` para trazer itens de lá para o escopo do nosso pacote. Por exemplo,
com `HashMap` usaríamos esta linha:

```rust
use std::collections::HashMap;
```

Este é um caminho absoluto começando com `std`, o nome da biblioteca padrão
caixa.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-nested-paths-to-clean-up-large-use-lists"></a>

### Usando caminhos aninhados para limpar listas `use`

Se estivermos usando vários itens definidos na mesma caixa ou no mesmo módulo, listar
cada item em sua própria linha pode ocupar muito espaço vertical em nossos arquivos. Para
por exemplo, essas duas declarações `use` que tivemos no jogo de adivinhação da Listagem 2-4
traga itens de `std` para o escopo:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-01-use-std-unnested/src/main.rs:here}}
```

</Listing>

Em vez disso, podemos usar caminhos aninhados para trazer os mesmos itens para o escopo em um
linha. Fazemos isso especificando a parte comum do caminho, seguida por dois
dois pontos e, em seguida, colchetes em torno de uma lista das partes dos caminhos que
diferem, conforme mostrado na Listagem 7-18.

<Listing number="7-18" file-name="src/main.rs" caption="Specifying a nested path to bring multiple items with the same prefix into scope">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-18/src/main.rs:here}}
```

</Listing>

Em programas maiores, trazer para o escopo muitos itens da mesma caixa ou
módulo usando caminhos aninhados pode reduzir o número de instruções `use` separadas
preciso muito!

Podemos usar um caminho aninhado em qualquer nível de um caminho, o que é útil ao combinar
duas instruções `use` que compartilham um subcaminho. Por exemplo, a Listagem 7-19 mostra dois
Declarações `use`: uma que traz `std::io` para o escopo e outra que traz
`std::io::Write` no escopo.

<Listing number="7-19" file-name="src/lib.rs" caption="Two `use` statements where one is a subpath of the other">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-19/src/lib.rs}}
```

</Listing>

A parte comum desses dois caminhos é `std::io`, e esse é o primeiro caminho completo
caminho. Para mesclar esses dois caminhos em uma instrução `use`, podemos usar `self` em
o caminho aninhado, conforme mostrado na Listagem 7-20.

<Listing number="7-20" file-name="src/lib.rs" caption="Combining the paths in Listing 7-19 into one `use` statement">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-20/src/lib.rs}}
```

</Listing>

Esta linha traz `std::io` e `std::io::Write` ao escopo.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-glob-operator"></a>

### Importando Itens com o Operador Glob

Se quisermos trazer _todos_ os itens públicos definidos em um caminho para o escopo, podemos
especifique esse caminho seguido pelo operador glob `*`:

```rust
use std::collections::*;
```

Esta instrução `use` traz todos os itens públicos definidos em `std::collections` para
o escopo atual. Tenha cuidado ao usar o operador glob! Glob pode fazer isso
mais difícil saber quais nomes estão no escopo e onde um nome é usado em seu programa
foi definido. Além disso, se a dependência alterar suas definições, o que
você também importou alterações, o que pode levar a erros do compilador quando você
atualize a dependência se a dependência adicionar uma definição com o mesmo nome
como uma definição sua no mesmo escopo, por exemplo.

O operador glob é frequentemente usado em testes para colocar tudo em teste em
o módulo `tests`; falaremos sobre isso em [“Como escrever
Testes”][writing-tests]<!-- ignore --> no Capítulo 11. O operador glob também é
às vezes usado como parte do padrão prelúdio: Consulte [a biblioteca padrão
documentação](../std/prelude/index.html#other-preludes)<!-- ignore --> para mais
informações sobre esse padrão.

[ch14-pub-use]: ch14-02-publishing-to-crates-io.html#exporting-a-convenient-public-api
[rand]: ch02-00-guessing-game-tutorial.html#generating-a-random-number
[writing-tests]: ch11-01-writing-tests.html#how-to-write-tests
