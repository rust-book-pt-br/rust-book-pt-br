## Definindo e instanciando estruturas

As estruturas são semelhantes às tuplas, discutidas em [“The Tuple
Type”][tuples]<!-- ignore -->, pois ambas contêm vários valores relacionados. Assim como as tuplas, o
partes de uma estrutura podem ser de tipos diferentes. Ao contrário das tuplas, em uma estrutura
você nomeará cada dado para que fique claro o que os valores significam. Adicionando estes
nomes significa que as estruturas são mais flexíveis que as tuplas: você não precisa confiar
na ordem dos dados para especificar ou acessar os valores de uma instância.

Para definir uma estrutura, inserimos a palavra-chave `struct` e nomeamos toda a estrutura. UM
o nome da estrutura deve descrever o significado dos dados que estão sendo
agrupados. Então, entre chaves, definimos os nomes e tipos de
os pedaços de dados, que chamamos de _campos_. Por exemplo, a Listagem 5-1 mostra um
struct que armazena informações sobre uma conta de usuário.

<Listing number="5-1" file-name="src/main.rs" caption="A `User` struct definition">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-01/src/main.rs:here}}
```

</Listing>

Para usar uma estrutura depois de defini-la, criamos uma _instância_ dessa estrutura
especificando valores concretos para cada um dos campos. Criamos uma instância por
informando o nome da estrutura e, em seguida, adicione chaves contendo _`key:
valor`_ pares, onde as chaves são os nomes dos campos e os valores são os
dados que queremos armazenar nesses campos. Não precisamos especificar os campos em
na mesma ordem em que os declaramos na estrutura. Em outras palavras, o
A definição de struct é como um modelo geral para o tipo e as instâncias são preenchidas
nesse modelo com dados específicos para criar valores do tipo. Para
Por exemplo, podemos declarar um usuário específico conforme mostrado na Listagem 5-2.

<Listing number="5-2" file-name="src/main.rs" caption="Creating an instance of the `User` struct">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-02/src/main.rs:here}}
```

</Listing>

Para obter um valor específico de uma estrutura, usamos a notação de ponto. Por exemplo, para
acessar o endereço de e-mail deste usuário, usamos `user1.email`. Se a instância for
mutável, podemos alterar um valor usando a notação de ponto e atribuindo a um
campo específico. A Listagem 5-3 mostra como alterar o valor no `email`
campo de uma instância mutável `User`.

<Listing number="5-3" file-name="src/main.rs" caption="Changing the value in the `email` field of a `User` instance">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-03/src/main.rs:here}}
```

</Listing>

Observe que toda a instância deve ser mutável; A ferrugem não nos permite marcar
apenas alguns campos são mutáveis. Como acontece com qualquer expressão, podemos construir uma nova
instância da struct como a última expressão no corpo da função a ser
retornar implicitamente essa nova instância.

A Listagem 5-4 mostra uma função `build_user` que retorna uma instância `User` com
o e-mail e nome de usuário fornecidos. O campo `active` recebe o valor `true`, e o campo
`sign_in_count` obtém um valor de `1`.

<Listing number="5-4" file-name="src/main.rs" caption="A `build_user` function that takes an email and username and returns a `User` instance">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-04/src/main.rs:here}}
```

</Listing>

Faz sentido nomear os parâmetros da função com o mesmo nome da estrutura
campos, mas tendo que repetir os nomes dos campos `email` e `username` e
variáveis ​​é um pouco tedioso. Se a estrutura tivesse mais campos, repetindo cada nome
ficaria ainda mais irritante. Felizmente, existe uma abreviatura conveniente!

<!-- Old headings. Do not remove or links may break. -->

<a id="using-the-field-init-shorthand-when-variables-and-fields-have-the-same-name"></a>

### Usando a abreviação de inicialização de campo

Como os nomes dos parâmetros e os nomes dos campos struct são exatamente os mesmos em
Listagem 5-4, podemos usar a sintaxe _field init shorthand_ para reescrever
`build_user` para que ele se comporte exatamente da mesma forma, mas não tenha o
repetição de `username` e `email`, conforme mostrado na Listagem 5-5.

<Listing number="5-5" file-name="src/main.rs" caption="A `build_user` function that uses field init shorthand because the `username` and `email` parameters have the same name as struct fields">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-05/src/main.rs:here}}
```

</Listing>

Aqui, estamos criando uma nova instância da estrutura `User`, que possui um campo
chamado `email`. Queremos definir o valor do campo `email` para o valor no
`email` parâmetro da função `build_user`. Porque o campo `email` e
o parâmetro `email` tem o mesmo nome, só precisamos escrever `email` em vez
do que `email: email`.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-instances-from-other-instances-with-struct-update-syntax"></a>

### Criando instâncias com sintaxe de atualização de estrutura

Muitas vezes é útil criar uma nova instância de uma estrutura que inclua a maior parte
os valores de outra instância do mesmo tipo, mas altera alguns deles.
Você pode fazer isso usando a sintaxe de atualização de struct.

Primeiro, na Listagem 5-6 mostramos como criar uma nova instância `User` em `user2` em
da maneira normal, sem a sintaxe de atualização. Definimos um novo valor para `email` mas
caso contrário, use os mesmos valores de `user1` que criamos na Listagem 5-2.

<Listing number="5-6" file-name="src/main.rs" caption="Creating a new `User` instance using all but one of the values from `user1`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-06/src/main.rs:here}}
```

</Listing>

Usando a sintaxe de atualização de struct, podemos obter o mesmo efeito com menos código, como
mostrado na Listagem 5-7. A sintaxe `..` especifica que os campos restantes não
definido explicitamente deve ter o mesmo valor que os campos na instância fornecida.

<Listing number="5-7" file-name="src/main.rs" caption="Using struct update syntax to set a new `email` value for a `User` instance but to use the rest of the values from `user1`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-07/src/main.rs:here}}
```

</Listing>

O código na Listagem 5-7 também cria uma instância em `user2` que possui um
valor diferente para `email`, mas tem os mesmos valores para `username`,
`active` e `sign_in_count` campos de `user1`. O `..user1` deve vir por último
para especificar que quaisquer campos restantes devem obter seus valores do
campos correspondentes em `user1`, mas podemos optar por especificar valores para como
quantos campos quisermos em qualquer ordem, independentemente da ordem dos campos em
a definição da estrutura.

Observe que a sintaxe de atualização da estrutura usa `=` como uma atribuição; isso é porque
ele move os dados, assim como vimos na seção [“Variáveis ​​​​e Dados Interagindo com
Mover”][move]<!-- ignore --> seção. Neste exemplo, não podemos mais usar
`user1` depois de criar `user2` porque `String` no campo `username` de
`user1` foi movido para `user2`. Se tivéssemos fornecido `user2` novos valores `String` para
ambos `email` e `username` e, portanto, usaram apenas `active` e `sign_in_count`
valores de `user1`, então `user1` ainda seria válido após a criação de `user2`.
Ambos `active` e `sign_in_count` são tipos que implementam a característica `Copy`, então
o comportamento que discutimos em [“Dados somente para pilha: copiar”][copy]<!-- ignore -->
seção seria aplicável. Também podemos usar `user1.email` neste exemplo,
porque seu valor não foi movido de `user1`.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-tuple-structs-without-named-fields-to-create-different-types"></a>

### Criando tipos diferentes com estruturas de tupla

Rust também oferece suporte a estruturas semelhantes a tuplas, chamadas _tuple structs_.
Estruturas de tupla têm o significado adicional que o nome da estrutura fornece, mas não tem
nomes associados aos seus campos; em vez disso, eles apenas têm os tipos de
campos. Estruturas de tupla são úteis quando você deseja dar um nome à tupla inteira
e tornar a tupla um tipo diferente de outras tuplas, e ao nomear cada uma
campo como em uma estrutura regular seria detalhado ou redundante.

Para definir uma estrutura de tupla, comece com a palavra-chave `struct` e o nome da estrutura
seguido pelos tipos na tupla. Por exemplo, aqui definimos e usamos dois
estruturas de tupla denominadas `Color` e `Point`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-01-tuple-structs/src/main.rs}}
```

</Listing>

Observe que os valores `black` e `origin` são de tipos diferentes porque são
instâncias de diferentes estruturas de tupla. Cada estrutura que você define é seu próprio tipo,
mesmo que os campos dentro da estrutura possam ter os mesmos tipos. Para
Por exemplo, uma função que recebe um parâmetro do tipo `Color` não pode receber um
`Point` como argumento, embora ambos os tipos sejam compostos de três `i32`
valores. Caso contrário, as instâncias de struct de tupla são semelhantes às tuplas no sentido de que você pode
desestruturá-los em suas partes individuais, e você pode usar um `.` seguido
pelo índice para acessar um valor individual. Ao contrário das tuplas, estruturas de tupla
exigem que você nomeie o tipo da estrutura ao desestruturá-la. Para
por exemplo, escreveríamos `let Point(x, y, z) = origin;` para desestruturar o
valores em `origin` apontam para variáveis ​​chamadas `x`, `y` e `z`.

<!-- Old headings. Do not remove or links may break. -->

<a id="unit-like-structs-without-any-fields"></a>

### Definindo estruturas semelhantes a unidades

Você também pode definir estruturas que não possuem campos! Estes são chamados
_estruturas semelhantes a unidades_ porque elas se comportam de forma semelhante a `()`, o tipo de unidade que
mencionamos na seção [“O tipo de tupla”][tuples]<!-- ignore -->. Semelhante a uma unidade
structs podem ser úteis quando você precisa implementar uma característica em algum tipo, mas não
tenha quaisquer dados que você deseja armazenar no próprio tipo. Discutiremos características
no Capítulo 10. Aqui está um exemplo de declaração e instanciação de uma estrutura de unidade
chamado `AlwaysEqual`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-04-unit-like-structs/src/main.rs}}
```

</Listing>

Para definir `AlwaysEqual`, usamos a palavra-chave `struct`, o nome que queremos e
depois um ponto e vírgula. Não há necessidade de chaves ou parênteses! Então, podemos obter
uma instância de `AlwaysEqual` na variável `subject` de maneira semelhante: usando
o nome que definimos, sem chaves ou parênteses. Imagine isso
mais tarde implementaremos o comportamento para este tipo de modo que cada instância de
`AlwaysEqual` é sempre igual a todas as instâncias de qualquer outro tipo, talvez para
ter um resultado conhecido para fins de teste. Não precisaríamos de nenhum dado para
implemente esse comportamento! Você verá no Capítulo 10 como definir características e
implemente-os em qualquer tipo, incluindo estruturas semelhantes a unidades.

> ### Propriedade de dados estruturais
>
> Na definição da estrutura `User` na Listagem 5-1, usamos o propriedade `String`
> tipo em vez do tipo de fatia de string `&str`. Esta é uma escolha deliberada
> porque queremos que cada instância desta estrutura possua todos os seus dados e para
> esses dados serão válidos enquanto toda a estrutura for válida.
>
> Também é possível que estruturas armazenem referências a dados pertencentes a algo
> outra coisa, mas para fazer isso é necessário o uso de _lifetimes_, um recurso do Rust que iremos
> discutiremos no Capítulo 10. Tempos de vida garantem que os dados referenciados por uma estrutura
> é válido enquanto a estrutura for. Digamos que você tente armazenar uma referência
> em uma estrutura sem especificar tempos de vida, como o seguinte em
> *src/main.rs*; isso não vai funcionar:
>
> <Listing file-name="src/main.rs">
>
> <!-- CAN'T EXTRACT SEE https://github.com/rust-lang/mdBook/issues/1127 -->
>
> ```ferrugem,ignora,não_compila
> estruturar usuário {
>     ativo: bool,
>     nome de usuário: &str,
>     e-mail: &str,
>     sign_in_count: u64,
> }
>
> fn principal() {
>     deixe usuário1 = Usuário {
>         ativo: verdadeiro,
>         nome de usuário: "algumnomedeusuario123",
>         e-mail: "alguém@exemplo.com",
>         sign_in_count: 1,
>     };
> }
> ```
>
> </Listing>
>
> O compilador reclamará que precisa de especificadores de tempo de vida:
>
> ```console
> $ corrida de carga
>    Compilando estruturas v0.1.0 (file:///projects/structs)
> erro[E0106]: especificador de tempo de vida ausente
>  --> src/main.rs:3:15
>   |
> 3 |     nome de usuário: &str,
>   |               ^ parâmetro de vida útil nomeado esperado
>   |
> ajuda: considere introduzir um parâmetro de vida útil nomeado
>   |
> 1 ~ estrutura Usuário<'a> {
> 2 |     ativo: bool,
> 3 ~ nome de usuário: &'a str,
>   |
>
> erro[E0106]: especificador de tempo de vida ausente
>  --> src/main.rs:4:12
>   |
> 4 |     e-mail: &str,
>   |            ^ parâmetro de vida útil nomeado esperado
>   |
> ajuda: considere introduzir um parâmetro de vida útil nomeado
>   |
> 1 ~ estrutura Usuário<'a> {
> 2 |     ativo: bool,
> 3 |     nome de usuário: &str,
> 4 ~ email: &'a str,
>   |
>
> Para obter mais informações sobre esse erro, tente `rustc --explain E0106`.
> erro: não foi possível compilar `structs` (bin "structs") devido a 2 erros anteriores
> ```
>
> No Capítulo 10, discutiremos como corrigir esses erros para que você possa armazenar
> referências em estruturas, mas por enquanto, corrigiremos erros como esses usando propriedades
> tipos como `String` em vez de referências como `&str`.

<!-- manual-regeneration
para o erro acima
depois de executar update-rustc.sh:
pbcopy <listings/ch05-using-structs-to-structure-related-data/no-listing-02-reference-in-struct/output.txt
cole acima
adicione `> ` antes de cada linha -->

[tuples]: ch03-02-data-types.html#the-tuple-type
[move]: ch04-01-what-is-ownership.html#variables-and-data-interacting-with-move
[copy]: ch04-01-what-is-ownership.html#stack-only-data-copy
