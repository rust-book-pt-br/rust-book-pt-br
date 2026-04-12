## Definindo e Instanciando Structs

Structs são parecidas com tuplas, discutidas na seção [“O Tipo
Tupla”][tuples]<!-- ignore -->, porque ambas armazenam vários valores
relacionados. Assim como nas tuplas, os elementos de uma struct podem ter tipos
diferentes. A diferença é que, em uma struct, cada pedaço de dado recebe um
nome, o que torna mais claro o significado dos valores. Por causa desses
nomes, structs são mais flexíveis do que tuplas: você não precisa depender da
ordem dos dados para especificar ou acessar os valores de uma instância.

Para definir uma struct, usamos a palavra-chave `struct` e damos um nome à
estrutura inteira. O nome da struct deve descrever o significado dos dados que
estão sendo agrupados. Em seguida, entre chaves, definimos os nomes e os tipos
dos dados que ela contém, chamados de _campos_. Por exemplo, a Listagem 5-1
mostra uma struct que armazena informações sobre uma conta de usuário.

<Listing number="5-1" file-name="src/main.rs" caption="Definição da struct `User`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-01/src/main.rs:here}}
```

</Listing>

Para usar uma struct depois de defini-la, criamos uma _instância_ dela
especificando valores concretos para cada campo. Criamos uma instância
escrevendo o nome da struct e, em seguida, chaves contendo pares _`chave:
valor`_, em que as chaves são os nomes dos campos e os valores são os dados
que queremos armazenar neles. Não é necessário especificar os campos na mesma
ordem em que eles foram declarados na struct. Em outras palavras, a definição
da struct funciona como um modelo geral para o tipo, e as instâncias preenchem
esse modelo com dados específicos para criar valores daquele tipo. Por
exemplo, podemos declarar um usuário específico como mostra a Listagem 5-2.

<Listing number="5-2" file-name="src/main.rs" caption="Criando uma instância da struct `User`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-02/src/main.rs:here}}
```

</Listing>

Para obter um valor específico de uma struct, usamos notação de ponto. Por
exemplo, para acessar o endereço de e-mail desse usuário, usamos
`user1.email`. Se a instância for mutável, podemos alterar um valor usando a
notação de ponto e atribuindo um novo valor a um campo específico. A Listagem
5-3 mostra como alterar o valor do campo `email` de uma instância mutável de
`User`.

<Listing number="5-3" file-name="src/main.rs" caption="Alterando o valor do campo `email` de uma instância de `User`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-03/src/main.rs:here}}
```

</Listing>

Observe que a instância inteira precisa ser mutável; o Rust não permite marcar
apenas alguns campos como mutáveis. Como acontece com qualquer expressão,
também podemos construir uma nova instância da struct como a última expressão
no corpo de uma função para retorná-la implicitamente.

A Listagem 5-4 mostra uma função `build_user` que retorna uma instância de
`User` com o e-mail e o nome de usuário fornecidos. O campo `active` recebe o
valor `true`, e `sign_in_count` recebe o valor `1`.

<Listing number="5-4" file-name="src/main.rs" caption="Uma função `build_user` que recebe e-mail e nome de usuário e retorna uma instância de `User`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-04/src/main.rs:here}}
```

</Listing>

Faz sentido dar aos parâmetros da função os mesmos nomes dos campos da struct,
mas ter de repetir os nomes `email` e `username` tanto nos campos quanto nas
variáveis pode ficar um pouco cansativo. Se a struct tivesse mais campos,
repetir cada nome ficaria ainda mais incômodo. Felizmente, há uma abreviação
conveniente!

<!-- Old headings. Do not remove or links may break. -->

<a id="using-the-field-init-shorthand-when-variables-and-fields-have-the-same-name"></a>

### Usando a Abreviação de Inicialização de Campos

Como os nomes dos parâmetros e os nomes dos campos da struct são exatamente os
mesmos na Listagem 5-4, podemos usar a sintaxe _field init shorthand_ para
reescrever `build_user` de forma que ela se comporte exatamente igual, mas sem
repetir `username` e `email`, como mostra a Listagem 5-5.

<Listing number="5-5" file-name="src/main.rs" caption="Uma função `build_user` que usa a abreviação de inicialização de campos porque os parâmetros `username` e `email` têm o mesmo nome dos campos da struct">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-05/src/main.rs:here}}
```

</Listing>

Aqui, estamos criando uma nova instância da struct `User`, que tem um campo
chamado `email`. Queremos atribuir ao campo `email` o valor contido no
parâmetro `email` da função `build_user`. Como o campo `email` e o parâmetro
`email` têm o mesmo nome, só precisamos escrever `email` em vez de
`email: email`.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-instances-from-other-instances-with-struct-update-syntax"></a>

### Criando Instâncias com a Sintaxe de Atualização de Struct

Muitas vezes é útil criar uma nova instância de uma struct que aproveite a
maior parte dos valores de outra instância do mesmo tipo, alterando apenas
alguns campos. Podemos fazer isso usando a sintaxe de atualização de struct.

Primeiro, na Listagem 5-6, mostramos como criar uma nova instância de `User`
em `user2` do jeito tradicional, sem a sintaxe de atualização. Definimos um
novo valor para `email`, mas reutilizamos os mesmos valores de `user1`,
instância criada na Listagem 5-2.

<Listing number="5-6" file-name="src/main.rs" caption="Criando uma nova instância de `User` usando todos os valores de `user1`, exceto um">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-06/src/main.rs:here}}
```

</Listing>

Usando a sintaxe de atualização de struct, podemos obter o mesmo efeito com
menos código, como mostra a Listagem 5-7. A sintaxe `..` indica que os campos
restantes, não definidos explicitamente, devem receber os mesmos valores que
os campos da instância fornecida.

<Listing number="5-7" file-name="src/main.rs" caption="Usando a sintaxe de atualização de struct para definir um novo valor de `email` em uma instância de `User`, reaproveitando o restante dos valores de `user1`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-07/src/main.rs:here}}
```

</Listing>

O código da Listagem 5-7 também cria uma instância em `user2` com um valor
diferente para `email`, mas com os mesmos valores de `username`, `active` e
`sign_in_count` vindos de `user1`. O trecho `..user1` precisa vir por último
para indicar que quaisquer campos restantes devem receber seus valores dos
campos correspondentes em `user1`, mas podemos escolher explicitamente quantos
campos quisermos, em qualquer ordem, independentemente da ordem em que eles
foram declarados na struct.

Observe que a sintaxe de atualização de struct usa `=` como uma atribuição;
isso acontece porque ela move os dados, como vimos na seção [“Variáveis e
Dados Interagindo com Move”][move]<!-- ignore -->. Neste exemplo, não podemos
mais usar `user1` depois de criar `user2`, porque a `String` armazenada no
campo `username` de `user1` foi movida para `user2`. Se tivéssemos dado a
`user2` novos valores `String` tanto para `email` quanto para `username`, e
portanto usássemos de `user1` apenas os valores `active` e `sign_in_count`,
então `user1` ainda seria válido depois da criação de `user2`. Tanto `active`
quanto `sign_in_count` são tipos que implementam a trait `Copy`, então o
comportamento discutido na seção [“Dados Somente de Pilha:
Copy”][copy]<!-- ignore --> se aplica aqui. Também ainda podemos usar
`user1.email` nesse exemplo, porque o valor desse campo não foi movido para
fora de `user1`.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-tuple-structs-without-named-fields-to-create-different-types"></a>

### Criando Tipos Diferentes com Tuple Structs

Rust também oferece suporte a structs que se parecem com tuplas, chamadas
_tuple structs_. Tuple structs têm o significado adicional fornecido pelo nome
da struct, mas não têm nomes associados a seus campos; em vez disso, elas
armazenam apenas os tipos dos campos. Tuple structs são úteis quando você quer
dar um nome à tupla inteira e fazer com que ela seja um tipo diferente de
outras tuplas, mas nomear cada campo, como em uma struct comum, seria verboso
ou redundante.

Para definir uma tuple struct, começamos com a palavra-chave `struct`, seguida
do nome da struct e então os tipos da tupla. Por exemplo, aqui definimos e
usamos duas tuple structs chamadas `Color` e `Point`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-01-tuple-structs/src/main.rs}}
```

</Listing>

Observe que os valores `black` e `origin` têm tipos diferentes porque são
instâncias de tuple structs diferentes. Cada struct que você define é um tipo
próprio, mesmo que os campos internos tenham os mesmos tipos. Por exemplo, uma
função que recebe um parâmetro do tipo `Color` não pode receber um `Point`,
embora ambos sejam compostos de três valores `i32`. Fora isso, instâncias de
tuple struct se comportam de forma semelhante às tuplas: você pode
desestruturá-las em suas partes individuais e usar `.` seguido do índice para
acessar um valor específico. Diferentemente das tuplas, porém, tuple structs
exigem que você use o nome do tipo ao desestruturá-las. Por exemplo,
escreveríamos `let Point(x, y, z) = origin;` para desestruturar os valores de
`origin` em variáveis chamadas `x`, `y` e `z`.

<!-- Old headings. Do not remove or links may break. -->

<a id="unit-like-structs-without-any-fields"></a>

### Definindo Structs Unit-Like

Você também pode definir structs que não têm nenhum campo. Elas são chamadas de
_unit-like structs_ porque se comportam de maneira semelhante a `()`, o tipo
unit que mencionamos na seção [“O Tipo Tupla”][tuples]<!-- ignore -->.
Unit-like structs podem ser úteis quando você precisa implementar uma trait em
algum tipo, mas não quer armazenar nenhum dado nesse tipo em si. Vamos discutir
traits no Capítulo 10. Aqui está um exemplo de declaração e instanciação de uma
unit-like struct chamada `AlwaysEqual`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-04-unit-like-structs/src/main.rs}}
```

</Listing>

Para definir `AlwaysEqual`, usamos a palavra-chave `struct`, o nome desejado e
então um ponto e vírgula. Não precisamos de chaves nem de parênteses! Depois,
podemos obter uma instância de `AlwaysEqual` na variável `subject` de forma
semelhante: usando apenas o nome definido, sem chaves nem parênteses. Imagine
que, mais tarde, implementaremos comportamento para esse tipo de forma que toda
instância de `AlwaysEqual` seja sempre igual a qualquer instância de qualquer
outro tipo, talvez para ter um resultado conhecido em testes. Não precisaríamos
de nenhum dado para implementar esse comportamento. Você verá no Capítulo 10
como definir traits e implementá-las em qualquer tipo, incluindo unit-like
structs.

> ### Ownership dos Dados em Structs
>
> Na definição da struct `User` da Listagem 5-1, usamos o tipo com ownership
> `String` em vez do tipo fatia de string `&str`. Essa é uma escolha
> deliberada, porque queremos que cada instância dessa struct seja dona de
> todos os seus dados e que esses dados permaneçam válidos enquanto a struct
> inteira for válida.
>
> Também é possível que structs armazenem referências a dados pertencentes a
> outra coisa, mas fazer isso exige o uso de _lifetimes_, um recurso do Rust
> que vamos discutir no Capítulo 10. Lifetimes garantem que os dados
> referenciados por uma struct sejam válidos pelo tempo que a struct precisar
> deles. Digamos que você tente armazenar uma referência em uma struct sem
> especificar lifetimes, como no exemplo a seguir em *src/main.rs*; isso não
> funcionará:
>
> <Listing file-name="src/main.rs">
>
> <!-- CAN'T EXTRACT SEE https://github.com/rust-lang/mdBook/issues/1127 -->
>
> ```rust,ignore,does_not_compile
> struct User {
>     active: bool,
>     username: &str,
>     email: &str,
>     sign_in_count: u64,
> }
>
> fn main() {
>     let user1 = User {
>         active: true,
>         username: "someusername123",
>         email: "someone@example.com",
>         sign_in_count: 1,
>     };
> }
> ```
>
> </Listing>
>
> O compilador reclamará que ele precisa de especificadores de lifetime:
>
> ```console
> $ cargo run
>    Compiling structs v0.1.0 (file:///projects/structs)
> error[E0106]: missing lifetime specifier
>  --> src/main.rs:3:15
>   |
> 3 |     username: &str,
>   |               ^ expected named lifetime parameter
>   |
> help: consider introducing a named lifetime parameter
>   |
> 1 ~ struct User<'a> {
> 2 |     active: bool,
> 3 ~     username: &'a str,
>   |
>
> error[E0106]: missing lifetime specifier
>  --> src/main.rs:4:12
>   |
> 4 |     email: &str,
>   |            ^ expected named lifetime parameter
>   |
> help: consider introducing a named lifetime parameter
>   |
> 1 ~ struct User<'a> {
> 2 |     active: bool,
> 3 |     username: &str,
> 4 ~     email: &'a str,
>   |
>
> For more information about this error, try `rustc --explain E0106`.
> error: could not compile `structs` (bin "structs") due to 2 previous errors
> ```
>
> No Capítulo 10, veremos como corrigir erros como esses para que você possa
> armazenar referências em structs. Por enquanto, vamos resolver esse tipo de
> situação usando tipos com ownership, como `String`, em vez de referências
> como `&str`.

<!-- manual-regeneration
for the error above
after running update-rustc.sh:
pbcopy < listings/ch05-using-structs-to-structure-related-data/no-listing-02-reference-in-struct/output.txt
paste above
add `> ` before every line -->

[tuples]: ch03-02-data-types.html#the-tuple-type
[move]: ch04-01-what-is-ownership.html#variables-and-data-interacting-with-move
[copy]: ch04-01-what-is-ownership.html#stack-only-data-copy
