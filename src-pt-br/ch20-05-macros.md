## Macros

Usamos macros como `println!` ao longo deste livro, mas ainda não
exploramos de fato o que é uma macro e como ela funciona. O termo _macro_
refere-se a uma família de recursos do Rust: macros declarativas com
`macro_rules!` e três tipos de macros procedurais:

- Macros `#[derive]` personalizadas que especificam o código adicionado com o atributo `derive`
  usado em estruturas e enums
- Macros semelhantes a atributos que definem atributos personalizados utilizáveis em qualquer item
- Macros semelhantes a funções, que se parecem com chamadas de função, mas
  operam sobre os tokens especificados como argumento

Falaremos de cada uma delas por vez, mas, primeiro, vamos ver por que sequer
precisamos de macros quando já temos funções.

### A diferença entre macros e funções

Fundamentalmente, macros são uma forma de escrever código que escreve outro
código, o que é conhecido como _metaprogramação_. No Apêndice C, discutimos o
atributo `derive`, que gera implementações de várias traits para você. Também
usamos as macros `println!` e `vec!` ao longo do livro. Todas elas se
_expandem_ para produzir mais código do que aquele que você escreveu
manualmente.

A metaprogramação é útil para reduzir a quantidade de código que você precisa
escrever e manter, algo que também é um dos papéis das funções. No entanto, as
macros têm alguns poderes adicionais que as funções não têm.

Uma assinatura de função precisa declarar o número e o tipo dos parâmetros que
a função recebe. Macros, por outro lado, podem aceitar uma quantidade variável
de parâmetros: podemos chamar `println!("hello")` com um argumento ou
`println!("hello {}", name)` com dois argumentos. Além disso, as macros são
expandidas antes de o compilador interpretar o significado do código; assim,
uma macro pode, por exemplo, implementar uma trait para um determinado tipo.
Uma função não pode fazer isso, porque é chamada em tempo de execução, enquanto
uma trait precisa ser implementada em tempo de compilação.

A desvantagem de implementar uma macro em vez de uma função é que definições de
macro são mais complexas do que definições de função, porque você está
escrevendo código Rust que gera código Rust. Por causa dessa indireção, em
geral as definições de macro são mais difíceis de ler, entender e manter do que
definições de função.

Outra diferença importante entre macros e funções é que você deve definir
macros, ou trazê-las para o escopo, _antes_ de chamá-las em um arquivo, ao
contrário das funções, que você pode definir em qualquer lugar e chamar em
qualquer lugar.

<!-- Old headings. Do not remove or links may break. -->

<a id="declarative-macros-with-macro_rules-for-general-metaprogramming"></a>

### Macros declarativas para metaprogramação geral

A forma de macro mais usada em Rust é a _macro declarativa_. Elas também são
às vezes chamadas de “macros por exemplo”, “macros `macro_rules!`” ou
simplesmente “macros”. Em essência, macros declarativas permitem escrever algo
parecido com uma expressão `match` do Rust. Como discutimos no Capítulo 6,
expressões `match` são estruturas de controle que recebem uma expressão,
comparam o valor resultante com padrões e então executam o código associado ao
padrão correspondente. Macros também comparam algo com padrões associados a um
código específico; nesse caso, o valor é o código-fonte Rust literal passado
para a macro, os padrões são comparados com a estrutura desse código-fonte, e o
código associado a cada padrão, quando há correspondência, substitui o código
passado para a macro. Tudo isso acontece durante a compilação.

Para definir uma macro, usa-se a construção `macro_rules!`. Vamos explorar como
usar `macro_rules!` observando como a macro `vec!` é definida. No Capítulo 8,
vimos como podemos usar a macro `vec!` para criar um novo vetor com valores
específicos. Por exemplo, a macro a seguir cria um novo vetor contendo três
inteiros:

```rust
let v: Vec<u32> = vec![1, 2, 3];
```

Também poderíamos usar a macro `vec!` para criar um vetor de dois inteiros ou
um vetor de cinco string slices. Não conseguiríamos usar uma função para fazer
o mesmo, porque não saberíamos antecipadamente o número nem o tipo dos valores.

A Listagem 20-35 mostra uma definição ligeiramente simplificada da macro
`vec!`.

<Listing number="20-35" file-name="src/lib.rs" caption="Uma versão simplificada da definição da macro `vec!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-35/src/lib.rs}}
```

</Listing>

> Nota: A definição real da macro `vec!` na biblioteca padrão
> inclui código para pré-alocar antecipadamente a quantidade correta de memória. Esse código
> é uma otimização que não incluímos aqui, para tornar o exemplo mais simples.

A anotação `#[macro_export]` indica que essa macro deve ser disponibilizada
sempre que o crate no qual ela está definida for colocado em escopo. Sem essa
anotação, a macro não pode ser trazida para o escopo.

Em seguida, iniciamos a definição da macro com `macro_rules!` e o nome da macro
que estamos definindo, _sem_ o ponto de exclamação. O nome, neste caso `vec`,
é seguido por chaves que indicam o corpo da definição da macro.

A estrutura do corpo de `vec!` é semelhante à estrutura de uma expressão
`match`. Aqui temos um braço com o padrão `($( $x:expr ),*)`, seguido por `=>`
e pelo bloco de código associado a esse padrão. Se o padrão corresponder, o
bloco de código associado será emitido. Como este é o único padrão dessa macro,
há apenas uma maneira válida de haver correspondência; qualquer outro padrão
resultará em erro. Macros mais complexas terão mais de um braço.

A sintaxe válida de padrões em definições de macro é diferente da sintaxe de
padrões abordada no Capítulo 19, porque padrões de macro são comparados com a
estrutura do código Rust, e não com valores. Vamos examinar o que significam as
partes do padrão na Listagem 20-35; para a sintaxe completa de padrões de
macro, consulte a [Referência do Rust][ref].

Primeiro, usamos um conjunto de parênteses para abranger todo o padrão. Usamos
um cifrão (`$`) para declarar uma variável no sistema de macros que conterá o
código Rust correspondente ao padrão. O cifrão deixa claro que se trata de uma
variável de macro, e não de uma variável Rust comum. Em seguida vem um conjunto
de parênteses que captura valores que correspondem ao padrão dentro desses
parênteses para uso no código de substituição. Dentro de `$()` está `$x:expr`,
que corresponde a qualquer expressão Rust e dá à expressão o nome `$x`.

A vírgula após `$()` indica que um caractere separador de vírgula literal deve
aparecer entre cada instância do código que corresponde ao código em `$()`. O
`*` especifica que o padrão corresponde a zero ou mais ocorrências do que vier
antes dele.

Quando chamamos essa macro com `vec![1, 2, 3];`, o padrão `$x` corresponde a
três ocorrências, com as expressões `1`, `2` e `3`.

Agora vamos observar o padrão no corpo do código associado a esse braço:
`temp_vec.push()` dentro de `$()*` é gerado para cada parte que corresponde a
`$()` no padrão, zero ou mais vezes, dependendo de quantas vezes o padrão
corresponde. O `$x` é substituído por cada expressão correspondente. Quando
chamamos essa macro com `vec![1, 2, 3];`, o código gerado que substitui essa
chamada será o seguinte:

```rust,ignore
{
    let mut temp_vec = Vec::new();
    temp_vec.push(1);
    temp_vec.push(2);
    temp_vec.push(3);
    temp_vec
}
```

Definimos uma macro que pode receber qualquer número de argumentos de qualquer
tipo e gerar código para criar um vetor contendo os elementos especificados.

Para saber mais sobre como escrever macros, consulte a documentação online ou
outros recursos, como [_The Little Book of Rust Macros_][tlborm], iniciado por
Daniel Keep e continuado por Lukas Wirth.

### Macros procedurais para gerar código a partir de atributos

A segunda forma de macro é a macro procedural, que se comporta mais como uma
função. _Macros procedurais_ aceitam algum código como entrada, operam sobre
esse código e produzem outro código como saída, em vez de comparar padrões e
substituir código por outro código, como fazem as macros declarativas. Os três
tipos de macros procedurais são as `derive` personalizadas, as semelhantes a
atributos e as semelhantes a funções, e todas funcionam de forma parecida.

Ao criar macros procedurais, as definições devem ficar em seu próprio crate,
com um tipo especial de crate. Isso acontece por razões técnicas complexas que
esperamos eliminar no futuro. Na Listagem 20-36, mostramos como definir uma
macro procedural, em que `some_attribute` é um marcador de posição para usar
uma variedade específica de macro.

<Listing number="20-36" file-name="src/lib.rs" caption="Um exemplo de definição de uma macro procedural">

```rust,ignore
use proc_macro::TokenStream;

#[some_attribute]
pub fn some_name(input: TokenStream) -> TokenStream {
}
```

</Listing>

A função que define uma macro procedural recebe um `TokenStream` como entrada e
produz um `TokenStream` como saída. O tipo `TokenStream` é definido pelo crate
`proc_macro`, que vem com o Rust, e representa uma sequência de tokens. Esse é
o núcleo da macro: o código-fonte sobre o qual a macro opera compõe o
`TokenStream` de entrada, e o código que a macro produz é o `TokenStream` de
saída. A função também tem um atributo anexado a ela que especifica qual tipo
de macro procedural estamos criando. Podemos ter vários tipos de macros
procedurais no mesmo crate.

Vamos ver os diferentes tipos de macros procedurais. Começaremos com uma macro
`derive` personalizada e, em seguida, explicaremos as pequenas diferenças que
tornam as outras formas distintas.

<!-- Old headings. Do not remove or links may break. -->

<a id="how-to-write-a-custom-derive-macro"></a>

<a id="custom-derive-macros"></a>

### Macros `derive` personalizadas

Vamos criar um crate chamado `hello_macro` que define uma trait chamada
`HelloMacro` com uma função associada chamada `hello_macro`. Em vez de fazer
com que nossos usuários implementem a trait `HelloMacro` para cada um de seus
tipos, forneceremos uma macro procedural para que possam anotar seu tipo com
`#[derive(HelloMacro)]` e obter uma implementação padrão da função
`hello_macro`. A implementação padrão imprimirá `Hello, Macro! My name is
TypeName!`, em que `TypeName` é o nome do tipo para o qual a trait foi
definida. Em outras palavras, escreveremos um crate que permite a outro
programador escrever um código como o da Listagem 20-37 usando nosso crate.

<Listing number="20-37" file-name="src/main.rs" caption="O código que um usuário do nosso crate poderá escrever ao usar nossa macro procedural">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-37/src/main.rs}}
```

</Listing>

Esse código imprimirá `Hello, Macro! My name is Pancakes!` quando terminarmos.
O primeiro passo é criar um novo crate de biblioteca, assim:

```console
$ cargo new hello_macro --lib
```

A seguir, na Listagem 20-38, definiremos a trait `HelloMacro` e sua função
associada.

<Listing file-name="src/lib.rs" number="20-38" caption="Uma trait simples que usaremos com a macro `derive`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-38/hello_macro/src/lib.rs}}
```

</Listing>

Temos uma trait e sua função. Neste ponto, quem usa nosso crate poderia
implementar a trait para obter a funcionalidade desejada, como na
Listagem 20-39.

<Listing number="20-39" file-name="src/main.rs" caption="Como ficaria se os usuários escrevessem uma implementação manual da trait `HelloMacro`">

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-39/pancakes/src/main.rs}}
```

</Listing>

No entanto, seria necessário escrever o bloco de implementação para cada tipo
que se quisesse usar com `hello_macro`; queremos poupar os usuários desse
trabalho.

Além disso, ainda não podemos fornecer uma implementação padrão para a função
`hello_macro` que imprima o nome do tipo ao qual a trait está associada: Rust
não tem recursos de reflexão, então não consegue descobrir o nome do tipo em
tempo de execução. Precisamos de uma macro para gerar código em tempo de
compilação.

O próximo passo é definir a macro procedural. No momento em que este livro foi
escrito, macros procedurais precisam estar em seu próprio crate. No futuro,
essa restrição talvez seja removida. A convenção para estruturar crates e
macro crates é a seguinte: para um crate chamado `foo`, o crate da macro
procedural `derive` personalizada se chama `foo_derive`. Vamos iniciar um novo
crate chamado `hello_macro_derive` dentro do nosso projeto `hello_macro`:

```console
$ cargo new hello_macro_derive --lib
```

Nossos dois crates estão intimamente relacionados, então criamos o crate da
macro procedural dentro do diretório do crate `hello_macro`. Se mudarmos a
definição da trait em `hello_macro`, também teremos de alterar a implementação
da macro procedural em `hello_macro_derive`. Os dois crates precisarão ser
publicados separadamente, e programadores que usarem esses crates precisarão
adicionar ambos como dependências e colocá-los no escopo. Poderíamos, em vez
disso, fazer com que o crate `hello_macro` usasse `hello_macro_derive` como
dependência e reexportasse o código da macro procedural. No entanto, a forma
como estruturamos o projeto torna possível usar `hello_macro` mesmo sem querer
a funcionalidade de `derive`.

Precisamos declarar o crate `hello_macro_derive` como um crate de macro
procedural. Também vamos precisar de funcionalidades dos crates `syn` e
`quote`, como você verá em instantes, então devemos adicioná-los como
dependências. Acrescente o seguinte ao arquivo _Cargo.toml_ de
`hello_macro_derive`:

<Listing file-name="hello_macro_derive/Cargo.toml">

```toml
{{#include ../listings/ch20-advanced-features/listing-20-40/hello_macro/hello_macro_derive/Cargo.toml:6:12}}
```

</Listing>

Para começar a definir a macro procedural, coloque o código da Listagem 20-40
em seu arquivo _src/lib.rs_ do crate `hello_macro_derive`. Observe que esse
código não compilará até adicionarmos uma definição para a função
`impl_hello_macro`.

<Listing number="20-40" file-name="hello_macro_derive/src/lib.rs" caption="Código que a maioria dos crates de macros procedurais exigirá para processar código Rust">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-40/hello_macro/hello_macro_derive/src/lib.rs}}
```

</Listing>

Observe que dividimos o código entre a função `hello_macro_derive`, que é
responsável por analisar o `TokenStream`, e a função `impl_hello_macro`, que é
responsável por transformar a árvore sintática. Isso torna mais conveniente
escrever uma macro procedural. O código da função externa
(`hello_macro_derive`, neste caso) será o mesmo para quase todo crate de macro
procedural que você vir ou criar. Já o código no corpo da função interna
(`impl_hello_macro`, neste caso) será diferente, dependendo da finalidade da
sua macro procedural.

Apresentamos três crates novos: `proc_macro`, [`syn`][syn]<!-- ignore --> e
[`quote`][quote]<!-- ignore -->. O crate `proc_macro` vem com o Rust, portanto
não precisamos adicioná-lo às dependências em _Cargo.toml_. O crate
`proc_macro` é a API do compilador que nos permite ler e manipular código Rust
a partir do nosso próprio código.

O crate `syn` analisa código Rust a partir de uma string e o transforma em uma
estrutura de dados sobre a qual podemos operar. O crate `quote` converte as
estruturas de dados do `syn` de volta em código Rust. Esses crates tornam muito
mais simples analisar qualquer tipo de código Rust que queiramos manipular:
escrever um parser completo para Rust não é uma tarefa simples.

A função `hello_macro_derive` será chamada quando alguém que usa nossa
biblioteca especificar `#[derive(HelloMacro)]` em um tipo. Isso é possível
porque anotamos a função `hello_macro_derive` com `proc_macro_derive` e
especificamos o nome `HelloMacro`, que corresponde ao nome da nossa trait; essa
é a convenção seguida pela maioria das macros procedurais.

A função `hello_macro_derive` primeiro converte o `input` de um `TokenStream`
para uma estrutura de dados que podemos então interpretar e manipular. É aí que
entra o `syn`. A função `parse` de `syn` recebe um `TokenStream` e retorna uma
struct `DeriveInput` representando o código Rust analisado. A Listagem 20-41
mostra as partes relevantes da struct `DeriveInput` que obtemos ao analisar a
string `struct Pancakes;`.

<Listing number="20-41" caption="A instância de `DeriveInput` que obtemos ao analisar o código que possui o atributo da macro na Listagem 20-37">

```rust,ignore
DeriveInput {
    // --snip--

    ident: Ident {
        ident: "Pancakes",
        span: #0 bytes(95..103)
    },
    data: Struct(
        DataStruct {
            struct_token: Struct,
            fields: Unit,
            semi_token: Some(
                Semi
            )
        }
    )
}
```

</Listing>

Os campos dessa struct mostram que o código Rust analisado é uma unit struct com
o `ident` (_identifier_, ou seja, o nome) `Pancakes`. Há outros campos nessa
struct para descrever diversos tipos de código Rust; consulte a
[documentação de `syn` para `DeriveInput`][syn-docs] para mais informações.

Em breve definiremos a função `impl_hello_macro`, onde construiremos o novo
código Rust que queremos incluir. Mas, antes disso, observe que a saída da
nossa macro `derive` também é um `TokenStream`. O `TokenStream` retornado é
adicionado ao código que os usuários do crate escrevem; assim, quando eles
compilarem seu crate, obterão a funcionalidade extra que fornecemos por meio do
`TokenStream` modificado.

Você deve ter notado que estamos chamando `unwrap` para fazer a função
`hello_macro_derive` entrar em `panic` se a chamada a `syn::parse` falhar. É
necessário que nossa macro procedural entre em `panic` em caso de erro porque
funções `proc_macro_derive` precisam retornar `TokenStream`, e não `Result`,
para obedecer à API de macros procedurais. Simplificamos este exemplo usando
`unwrap`; em código de produção, você deve fornecer mensagens de erro mais
específicas sobre o que deu errado usando `panic!` ou `expect`.

Agora que temos o código para transformar o código Rust anotado, de um
`TokenStream` em uma instância de `DeriveInput`, vamos gerar o código que
implementa a trait `HelloMacro` no tipo anotado, como mostrado na
Listagem 20-42.

<Listing number="20-42" file-name="hello_macro_derive/src/lib.rs" caption="Implementando a trait `HelloMacro` usando o código Rust analisado">

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-42/hello_macro/hello_macro_derive/src/lib.rs:here}}
```

</Listing>

Obtemos uma instância da struct `Ident` contendo o nome (identificador) do tipo
anotado usando `ast.ident`. A struct mostrada na Listagem 20-41 indica que,
quando executamos a função `impl_hello_macro` sobre o código da Listagem 20-37,
o `ident` obtido terá o campo `ident` com o valor `"Pancakes"`. Assim, a
variável `name` na Listagem 20-42 conterá uma instância de `Ident` que, quando
impressa, será a string `"Pancakes"`, o nome da struct da Listagem 20-37.

A macro `quote!` nos permite definir o código Rust que queremos retornar. O
compilador espera algo diferente do resultado direto da execução de `quote!`,
então precisamos convertê-lo em um `TokenStream`. Fazemos isso chamando o
método `into`, que consome essa representação intermediária e retorna um valor
do tipo `TokenStream` necessário.

A macro `quote!` também fornece um mecanismo de template muito interessante:
podemos inserir `#name`, e `quote!` o substituirá pelo valor da variável
`name`. Você pode até fazer repetições semelhantes à forma como macros comuns
funcionam. Consulte [a documentação do crate `quote`][quote-docs] para uma
introdução completa.

Queremos que nossa macro procedural gere uma implementação da trait
`HelloMacro` para o tipo anotado pelo usuário, que podemos obter com `#name`.
A implementação da trait tem a função `hello_macro`, cujo corpo contém a
funcionalidade que queremos oferecer: imprimir `Hello, Macro! My name is` e, em
seguida, o nome do tipo anotado.

A macro `stringify!` usada aqui já vem embutida no Rust. Ela recebe uma
expressão Rust, como `1 + 2`, e em tempo de compilação transforma essa
expressão em um literal de string, como `"1 + 2"`. Isso é diferente de
`format!` ou `println!`, que são macros que avaliam a expressão e depois
transformam o resultado em uma `String`. Existe a possibilidade de a entrada
`#name` ser uma expressão a ser impressa literalmente, então usamos
`stringify!`. Além disso, `stringify!` evita uma alocação ao converter `#name`
em um literal de string em tempo de compilação.

Neste ponto, `cargo build` deve ser concluído com sucesso tanto em
`hello_macro` quanto em `hello_macro_derive`. Vamos conectar esses crates ao
código da Listagem 20-37 para ver a macro procedural em ação! Crie um novo
projeto binário no seu diretório _projects_ usando `cargo new pancakes`.
Precisamos adicionar `hello_macro` e `hello_macro_derive` como dependências no
_Cargo.toml_ do crate `pancakes`. Se você estiver publicando suas versões de
`hello_macro` e `hello_macro_derive` em
[crates.io](https://crates.io/)<!-- ignore -->, elas seriam dependências
regulares; caso contrário, você pode especificá-las como dependências `path`,
da seguinte forma:

```toml
{{#include ../listings/ch20-advanced-features/no-listing-21-pancakes/pancakes/Cargo.toml:6:8}}
```

Coloque o código da Listagem 20-37 em _src/main.rs_ e execute `cargo run`: isso
deve imprimir `Hello, Macro! My name is Pancakes!`. A implementação da trait
`HelloMacro`, fornecida pela macro procedural, foi incluída sem que o crate
`pancakes` precisasse implementá-la; `#[derive(HelloMacro)]` adicionou a
implementação da trait.

A seguir, vamos explorar como os outros tipos de macros procedurais diferem das
macros `derive` personalizadas.

<a id="attribute-like-macros"></a>

### Macros semelhantes a atributos

Macros semelhantes a atributos são parecidas com macros `derive`
personalizadas, mas, em vez de gerar código para o atributo `derive`, permitem
criar novos atributos. Elas também são mais flexíveis: `derive` funciona apenas
para structs e enums; atributos também podem ser aplicados a outros itens, como
funções. Eis um exemplo de uso de uma macro semelhante a atributo. Digamos que
você tenha um atributo chamado `route` que anota funções ao usar um framework
web:

```rust,ignore
#[route(GET, "/")]
fn index() {
```

Esse atributo `#[route]` seria definido pelo framework como uma macro
procedural. A assinatura da função de definição da macro seria assim:

```rust,ignore
#[proc_macro_attribute]
pub fn route(attr: TokenStream, item: TokenStream) -> TokenStream {
```

Aqui temos dois parâmetros do tipo `TokenStream`. O primeiro é para o conteúdo
do atributo: a parte `GET, "/"`. O segundo é o corpo do item ao qual o
atributo está anexado: neste caso, `fn index() {}` e o restante do corpo da
função.

Fora isso, macros semelhantes a atributos funcionam da mesma maneira que macros
`derive` personalizadas: você cria um crate com o tipo `proc-macro` e
implementa uma função que gera o código desejado.

<a id="function-like-macros"></a>

### Macros semelhantes a funções

Macros semelhantes a funções definem macros que se parecem com chamadas de
função. Assim como macros `macro_rules!`, elas são mais flexíveis do que
funções; por exemplo, podem receber uma quantidade desconhecida de argumentos.
No entanto, macros `macro_rules!` só podem ser definidas usando a sintaxe
semelhante a `match` que discutimos anteriormente na seção
[“Macros declarativas para metaprogramação geral”][decl]<!-- ignore -->.
Macros semelhantes a funções recebem um parâmetro `TokenStream`, e sua
definição manipula esse `TokenStream` usando código Rust, assim como fazem os
outros dois tipos de macros procedurais. Um exemplo de macro semelhante a uma
função é uma macro `sql!`, que poderia ser chamada assim:

```rust,ignore
let sql = sql!(SELECT * FROM posts WHERE id=1);
```

Essa macro analisaria a instrução SQL dentro dela e verificaria se ela está
sintaticamente correta, o que é um processamento muito mais complexo do que uma
macro `macro_rules!` pode realizar. A macro `sql!` seria definida assim:

```rust,ignore
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
```

Essa definição é semelhante à assinatura da macro `derive` personalizada:
recebemos os tokens que estão entre parênteses e retornamos o código que
queremos gerar.

## Resumo

Ufa! Agora você tem alguns recursos do Rust na sua caixa de ferramentas que
provavelmente não usará com frequência, mas saberá que estão disponíveis em
circunstâncias muito específicas. Introduzimos vários tópicos complexos para
que, quando você os encontrar em sugestões de mensagens de erro ou no código de
outras pessoas, consiga reconhecer esses conceitos e essa sintaxe. Use este
capítulo como referência para se orientar em direção a soluções.

A seguir, colocaremos em prática tudo o que discutimos ao longo do livro e
faremos mais um projeto!

[ref]: https://doc.rust-lang.org/reference/macros-by-example.html
[tlborm]: https://veykril.github.io/tlborm/
[syn]: https://crates.io/crates/syn
[quote]: https://crates.io/crates/quote
[syn-docs]: https://docs.rs/syn/2.0/syn/struct.DeriveInput.html
[quote-docs]: https://docs.rs/quote
[decl]: #declarative-macros-with-macro_rules-for-general-metaprogramming
