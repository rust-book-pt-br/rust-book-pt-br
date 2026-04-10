## Macros

Usamos macros como `println!` ao longo deste livro, mas ainda não
explorou o que é uma macro e como ela funciona. O termo _macro_ refere-se a uma família
de recursos em Rust - macros declarativas com `macro_rules!` e três tipos de
macros processuais:

- Macros `#[derive]` personalizadas que especificam o código adicionado com o atributo `derive`
  usado em estruturas e enums
- Macros semelhantes a atributos que definem atributos personalizados utilizáveis em qualquer item
- Macros semelhantes a funções que se parecem com chamadas de função, mas operam nos tokens
  especificado como seu argumento

Falaremos de cada uma delas por vez, mas, primeiro, vamos ver por que sequer
need macros when we already have functions.

### A diferença entre macros e funções

Fundamentalmente, as macros são uma forma de escrever código que escreve outro código, que
é conhecido como _metaprogramação_. No Apêndice C, discutimos o `derive`
atributo, que gera uma implementação de vários traits para você. Nós temos
também usou as macros ` println!`e ` vec!`ao longo do livro. Todos estes
macros _expandem_ para produzir mais código do que o código que você escreveu manualmente.

A metaprogramação é útil para reduzir a quantidade de código que você precisa escrever e
manter, que também é uma das funções das funções. No entanto, as macros têm
alguns poderes adicionais que as funções não possuem.

Uma assinatura de função deve declarar o número e o tipo de parâmetros que
função tem. As macros, por outro lado, podem assumir um número variável de
parâmetros: podemos chamar `println!("hello")` com um argumento ou
`println!("hello {}", name)` com dois argumentos. Além disso, as macros são expandidas
antes que o compilador interprete o significado do código, então uma macro pode, por
Por exemplo, implemente um trait em um determinado tipo. Uma função não pode, porque fica
chamado em tempo de execução e um trait precisa ser implementado em tempo de compilação.

A desvantagem de implementar uma macro em vez de uma função é que a macro
definições são mais complexas do que definições de função porque você está escrevendo
Código Rust que grava o código Rust. Devido a esta indireção, as definições macro são
geralmente mais difícil de ler, entender e manter do que funcionar
definições.

Outra diferença importante entre macros e funções é que você deve
defina macros ou coloque-as no escopo _antes_ de chamá-las em um arquivo, como
ao contrário de funções que você pode definir em qualquer lugar e chamar em qualquer lugar.

<!-- Old headings. Do not remove or links may break. -->

<a id="declarative-macros-with-macro_rules-for-general-metaprogramming"></a>

### Macros declarativas para metaprogramação geral

A forma de macro mais amplamente usada em Rust é a _macro declarativa_. Estes
também são às vezes chamados de “macros por exemplo”, “macros `macro_rules!` ”,
ou simplesmente “macros”. Basicamente, as macros declarativas permitem que você escreva
algo semelhante a uma expressão Rust `match`. Conforme discutido no Capítulo 6,
Expressões ` match`são estruturas de controle que pegam uma expressão, comparam o
valor resultante da expressão para padrões e, em seguida, execute o código associado
com o padrão correspondente. As macros também comparam um valor com padrões que são
associado a um código específico: nesta situação, o valor é o literal
Código fonte Rust passado para a macro; os padrões são comparados com o
estrutura desse código-fonte; e o código associado a cada padrão, quando
correspondido, substitui o código passado para a macro. Tudo isso acontece durante
compilação.

Para definir uma macro, você usa a construção `macro_rules!`. Vamos explorar como
use ` macro_rules!`observando como a macro ` vec!`é definida. Capítulo 8
cobrimos como podemos usar a macro ` vec!`para criar um novo vetor com particular
valores. Por exemplo, a macro a seguir cria um novo vetor contendo três
inteiros:

```rust
let v: Vec<u32> = vec![1, 2, 3];
```

Também poderíamos usar a macro `vec!` para fazer um vetor de dois inteiros ou um vetor
de cinco strings slices. Não seríamos capazes de usar uma função para fazer o mesmo
porque não saberíamos o número ou tipo de valores antecipadamente.

Listing 20-35 shows a slightly simplified definition of the `vec!` macro.

<Listing number="20-35" file-name="src/lib.rs" caption="Uma versão simplificada da definição da macro `vec!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-35/src/lib.rs}}
```

</Listing>

> Nota: A definição real da macro `vec!` na biblioteca padrão
> inclui código para pré-alocar antecipadamente a quantidade correta de memória. Esse código
> é uma otimização que não incluímos aqui, para tornar o exemplo mais simples.

A anotação `#[macro_export]` indica que esta macro deve ser feita
disponível sempre que o crate no qual a macro está definida for colocado em
escopo. Sem esta anotação, a macro não pode ser incluída no escopo.

Iniciamos então a definição da macro com `macro_rules!` e o nome do
macro estamos definindo _sem_ o ponto de exclamação. O nome, neste caso
`vec`, é seguido por chaves que indicam o corpo da definição da macro.

A estrutura no corpo do `vec!` é semelhante à estrutura de um `match`
expressão. Aqui temos um braço com o padrão ` ($($x:expr),*)`,
seguido por ` =>`e o bloco de código associado a este padrão. Se o
correspondências de padrões, o bloco de código associado será emitido. Dado que isso
é o único padrão nesta macro, existe apenas um caminho válido para match; qualquer
outro padrão resultará em um erro. Macros mais complexas terão mais de
um braço.

A sintaxe padrão válida nas definições de macro é diferente da sintaxe padrão
abordado no Capítulo 19 porque os padrões de macro são comparados com o código Rust
estrutura em vez de valores. Vamos ver em que o padrão se insere
Listagem 20-29 média; para obter a sintaxe completa do padrão de macro, consulte o [Rust
Referência][ref].

Primeiro, usamos um conjunto de parênteses para abranger todo o padrão. Usamos um
cifrão (`$ `) para declarar uma variável no macro sistema que conterá
o código Rust correspondente ao padrão. O cifrão deixa claro que este é um
variável macro em oposição a uma variável Rust normal. Em seguida vem um conjunto de
parênteses que captura valores que match o padrão dentro dos parênteses
para uso no código de substituição. Dentro de` $() `está` $x:expr `, que corresponde a qualquer
expressão Rust e dá à expressão o nome` $x`.

A vírgula após `$()` indica que um caractere separador de vírgula literal
deve aparecer entre cada instância do código que corresponde ao código em `$()`.
O ` *`especifica que o padrão corresponde a zero ou mais do que precede
o ` *`.

Quando chamamos esta macro com `vec![1, 2, 3];`, o padrão ` $x`corresponde a três
vezes com as três expressões ` 1`, ` 2`e ` 3`.

Agora vamos dar uma olhada no padrão no corpo do código associado a este braço:
`temp_vec.push() ` dentro de`$()* ` é gerado para cada peça que corresponde a`$() `
no padrão zero ou mais vezes dependendo de quantas vezes o padrão
partidas. O` $x `é substituído por cada expressão correspondente. Quando chamamos isso
macro com` vec![1, 2, 3];`, o código gerado que substitui esta chamada de macro
será o seguinte:

```rust,ignore
{
    let mut temp_vec = Vec::new();
    temp_vec.push(1);
    temp_vec.push(2);
    temp_vec.push(3);
    temp_vec
}
```

Definimos uma macro que pode receber qualquer número de argumentos de qualquer tipo e pode
gerar código para criar um vetor contendo os elementos especificados.

Para saber mais sobre como escrever macros, consulte a documentação online ou
outros recursos, como [“O Pequeno Livro de Macros Rust”][tlborm] iniciado por
Daniel Keep e continuado por Lukas Wirth.

### Macros processuais para geração de código a partir de atributos

A segunda forma de macros é a macro processual, que atua mais como um
função (e é um tipo de procedimento). _Macros processuais_ aceitam algum código como
uma entrada, operar nesse código e produzir algum código como saída, em vez de
correspondência com padrões e substituição do código por outro código como declarativo
macros fazem. Os três tipos de macros procedurais são `derive` personalizados,
semelhantes a atributos e semelhantes a funções, e todos funcionam de maneira semelhante.

Ao criar macros procedurais, as definições devem residir em seu próprio crate
com um tipo especial crate. Isto ocorre por razões técnicas complexas que esperamos
para eliminar no future. Na Listagem 20-36, mostramos como definir um
macro processual, onde `some_attribute` é um espaço reservado para usar um específico
variedade macro.

<Listing number="20-36" file-name="src/lib.rs" caption="Um exemplo de definição de uma macro procedural">

```rust,ignore
use proc_macro::TokenStream;

#[some_attribute]
pub fn some_name(input: TokenStream) -> TokenStream {
}
```

</Listing>

A função que define uma macro processual recebe `TokenStream` como entrada
e produz um `TokenStream` como saída. O tipo `TokenStream` é definido por
o `proc_macro` crate que está incluído no Rust e representa uma sequência de
fichas. Este é o núcleo da macro: o código fonte que a macro é
operando constitui a entrada `TokenStream` e o código que a macro produz
é a saída `TokenStream`. A função também possui um atributo anexado a ela
que especifica que tipo de macro processual estamos criando. Nós podemos ter
vários tipos de macros procedurais no mesmo crate.

Vejamos os diferentes tipos de macros procedurais. Começaremos com um
macro `derive` personalizada e, em seguida, explique as pequenas diferenças que tornam o
outras formas diferentes.

<!-- Old headings. Do not remove or links may break. -->

<a id="how-to-write-a-custom-derive-macro"></a>

### Custom `derive` Macros

Vamos criar um crate chamado `hello_macro` que define um trait chamado
`HelloMacro ` com uma função associada chamada`hello_macro `. Em vez de
fazendo com que nossos usuários implementem o` HelloMacro `trait para cada um de seus tipos,
forneceremos uma macro processual para que os usuários possam anotar seu tipo com
` #[derive(HelloMacro)] `para obter uma implementação padrão do` hello_macro `
função. A implementação padrão imprimirá` Hello, Macro! My name is
TypeName! `onde` TypeName`é o nome do tipo no qual este trait possui
foi definido. Em outras palavras, escreveremos um crate que habilita outro
programador para escrever código como a Listagem 20-37 usando nosso crate.

<Listing number="20-37" file-name="src/main.rs" caption="O código que um usuário do nosso crate poderá escrever ao usar nossa macro procedural">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-37/src/main.rs}}
```

</Listing>

Este código imprimirá `Hello, Macro! My name is Pancakes!` quando terminarmos. O
O primeiro passo é fazer uma nova biblioteca crate, assim:

```console
$ cargo new hello_macro --lib
```

A seguir, na Listagem 20-38, definiremos `HelloMacro` trait e seus associados
função.

<Listing file-name="src/lib.rs" number="20-38" caption="Uma trait simples que usaremos com a macro `derive`">

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-38/hello_macro/src/lib.rs}}
```

</Listing>

Temos um trait e sua função. Neste ponto, nosso usuário crate poderia implementar
o trait para obter a funcionalidade desejada, como na Listagem 20-39.

<Listing number="20-39" file-name="src/main.rs" caption="Como ficaria se os usuários escrevessem uma implementação manual da trait `HelloMacro`">

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-39/pancakes/src/main.rs}}
```

</Listing>

No entanto, eles precisariam escrever o bloco de implementação para cada tipo que eles
queria usar com `hello_macro`; queremos poupá-los de ter que fazer isso
trabalho.

Além disso, ainda não podemos fornecer a função `hello_macro` com padrão
implementação que imprimirá o nome do tipo em que trait está implementado
ativado: Rust não possui recursos de reflexão, portanto não pode procurar o tipo
nome em tempo de execução. Precisamos de uma macro para gerar código em tempo de compilação.

O próximo passo é definir a macro processual. No momento em que este livro foi escrito,
macros procedimentais precisam estar em seu próprio crate. Eventualmente, esta restrição
poderá ser levantado. A convenção para estruturar crates e macro crates é como
segue: Para um crate denominado `foo`, uma macro processual ` derive`personalizada crate é
chamado ` foo_derive`. Vamos iniciar um novo crate chamado ` hello_macro_derive`dentro
nosso projeto ` hello_macro`:

```console
$ cargo new hello_macro_derive --lib
```

Nossos dois crates estão intimamente relacionados, então criamos a macro processual crate
dentro do diretório do nosso `hello_macro` crate. Se mudarmos o trait
definição em `hello_macro`, teremos que alterar a implementação do
macro processual em ` hello_macro_derive`também. Os dois crates precisarão
serão publicados separadamente, e os programadores que usam estes crates precisarão adicionar
ambos como dependências e coloque-os no escopo. Poderíamos, em vez disso, ter o
` hello_macro `crate usa` hello_macro_derive `como dependência e reexporta o
código de macro processual. No entanto, a forma como estruturámos o projecto torna-o
possível para os programadores usarem` hello_macro `mesmo que não queiram o
Funcionalidade` derive`.

Precisamos declarar `hello_macro_derive` crate como uma macro processual crate.
Também precisaremos de funcionalidades do `syn` e `quote` crates, como você verá
daqui a pouco, então precisamos adicioná-los como dependências. Adicione o seguinte ao
Arquivo _Cargo.toml_ para `hello_macro_derive`:

<Listing file-name="hello_macro_derive/Cargo.toml">

```toml
{{#include ../listings/ch20-advanced-features/listing-20-40/hello_macro/hello_macro_derive/Cargo.toml:6:12}}
```

</Listing>

Para começar a definir a macro processual, coloque o código da Listagem 20-40 em
seu arquivo _src/lib.rs_ para `hello_macro_derive` crate. Observe que este código
não será compilado até adicionarmos uma definição para a função `impl_hello_macro`.

<Listing number="20-40" file-name="hello_macro_derive/src/lib.rs" caption="Código que a maioria dos crates de macros procedurais exigirá para processar código Rust">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-40/hello_macro/hello_macro_derive/src/lib.rs}}
```

</Listing>

Observe que dividimos o código na função `hello_macro_derive`, que
é responsável por analisar o ` TokenStream`e o ` impl_hello_macro`
função, que é responsável por transformar a árvore sintática: Isso faz com que
escrever uma macro processual é mais conveniente. O código na função externa
(` hello_macro_derive `neste caso) será o mesmo para quase todos
macro processual crate que você vê ou cria. O código que você especifica no corpo do
a função interna (` impl_hello_macro`neste caso) será diferente
dependendo da finalidade da sua macro processual.

Apresentamos três novos crates: `proc_macro`, [` syn `][syn]<!-- ignore -->,
e [` quote `][quote]<!-- ignore -->. O` proc_macro `crate vem com Rust,
então não precisamos adicionar isso às dependências em _Cargo.toml_. O
` proc_macro`crate é a API do compilador que nos permite ler e manipular
Código Rust do nosso código.

O `syn` crate analisa o código Rust de uma string em uma estrutura de dados que
pode realizar operações. O `quote` crate devolve as estruturas de dados `syn`
no código Rust. Esses crates tornam muito mais simples analisar qualquer tipo de Rust
código que podemos querer manipular: Escrever um analisador completo para o código Rust não é simples
tarefa.

A função `hello_macro_derive` será chamada quando um usuário de nossa biblioteca
especifica `#[derive(HelloMacro)]` em um tipo. Isto é possível porque temos
anotou a função `hello_macro_derive` aqui com `proc_macro_derive` e
especificou o nome `HelloMacro`, que corresponde ao nosso nome trait; este é o
convenção que a maioria das macros procedurais segue.

A função `hello_macro_derive` primeiro converte o `input` de um
`TokenStream ` para uma estrutura de dados que podemos então interpretar e executar
operações em. É aqui que o`syn ` entra em ação. A função`parse ` em
`syn ` pega um`TokenStream ` e retorna uma estrutura`DeriveInput ` representando o
código Rust analisado. A Listagem 20-41 mostra as partes relevantes do`DeriveInput `
struct que obtemos ao analisar a string` struct Pancakes;`.

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

Os campos desta estrutura mostram que o código Rust que analisamos é uma estrutura de unidade
com o `ident` (_identifier_, significando o nome) de `Pancakes`. Existem mais
campos nesta estrutura para descrever todos os tipos de código Rust; verifique o [` syn `
documentação para` DeriveInput`][syn-docs] para obter mais informações.

Em breve definiremos a função `impl_hello_macro`, onde construiremos
o novo código Rust que queremos incluir. Mas antes de fazermos isso, observe que a saída
pois nossa macro ` derive`também é um ` TokenStream`. O ` TokenStream`retornado é
adicionado ao código que nossos usuários crate escrevem, então quando eles compilarem seu crate,
eles obterão a funcionalidade extra que fornecemos no modificado
` TokenStream`.

Você deve ter notado que estamos chamando `unwrap` para fazer com que o
Função `hello_macro_derive` para panic se a chamada para a função `syn::parse`
falha aqui. É necessário que nossa macro processual panic em caso de erros porque
As funções ` proc_macro_derive`devem retornar ` TokenStream`em vez de ` Result`para
esteja em conformidade com a API de macro processual. Simplificamos este exemplo usando
` unwrap `; no código de produção, você deve fornecer mensagens de erro mais específicas
sobre o que deu errado ao usar` panic! `ou` expect`.

Agora que temos o código para transformar o código Rust anotado de um `TokenStream`
em uma instância ` DeriveInput`, vamos gerar o código que implementa o
` HelloMacro`trait no tipo anotado, conforme mostrado na Listagem 20-42.

<Listing number="20-42" file-name="hello_macro_derive/src/lib.rs" caption="Implementando a trait `HelloMacro` usando o código Rust analisado">

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-42/hello_macro/hello_macro_derive/src/lib.rs:here}}
```

</Listing>

Obtemos uma instância de estrutura `Ident` contendo o nome (identificador) do
tipo anotado usando `ast.ident`. A estrutura na Listagem 20-41 mostra que quando
executamos a função ` impl_hello_macro`no código da Listagem 20-37, o
` ident `que obtemos terá o campo` ident `com um valor de` "Pancakes" `. Assim,
a variável` name `na Listagem 20-42 conterá uma instância de estrutura` Ident `
que, quando impresso, será a string` "Pancakes"`, o nome da struct em
Listagem 20-37.

A macro `quote!` nos permite definir o código Rust que queremos retornar. O
o compilador espera algo diferente do resultado direto do `quote!`
execução da macro, então precisamos convertê-la para ` TokenStream`. Fazemos isso por
chamando o método ` into`, que consome esta representação intermediária e
retorna um valor do tipo ` TokenStream`necessário.

A macro `quote!` também fornece algumas mecânicas de modelagem muito interessantes: podemos
insira `#name` e `quote!` irá substituí-lo pelo valor na variável
`name `. Você pode até fazer algumas repetições semelhantes à forma como as macros normais funcionam.
Confira [a documentação do` quote`crate] [quote-docs] para uma introdução completa.

Queremos que nossa macro processual gere uma implementação do nosso `HelloMacro`
trait para o tipo anotado pelo usuário, que podemos obter usando ` #name`. O
A implementação de trait possui uma função ` hello_macro`, cujo corpo contém o
funcionalidade que queremos fornecer: imprimir ` Hello, Macro! My name is`e depois
o nome do tipo anotado.

A macro `stringify!` usada aqui está incorporada ao Rust. É preciso um Rust
expressão, como `1 + 2`, e em tempo de compilação transforma a expressão em um
literal de cadeia de caracteres, como ` "1 + 2"`. Isso é diferente de ` format!`ou
` println! `, que são macros que avaliam a expressão e depois transformam o
resultar em um` String `. Existe a possibilidade de que a entrada` #name `possa ser
uma expressão para imprimir literalmente, então usamos` stringify! `. Usando` stringify! `
também salva uma alocação convertendo` #name`em uma string literal na compilação
tempo.

Neste ponto, `cargo build` deve ser concluído com sucesso em ambos `hello_macro`
e ` hello_macro_derive`. Vamos conectar esses crates ao código da Listagem
20-37 para ver a macro processual em ação! Crie um novo projeto binário em
seu diretório _projetos_ usando ` cargo new pancakes`. Precisamos adicionar
` hello_macro `e` hello_macro_derive `como dependências no` pancakes `
_Cargo.toml_ do crate. Se você estiver publicando suas versões do` hello_macro `e
` hello_macro_derive `para [crates.io](https://crates.io/)<!-- ignore -->, eles
seriam dependências regulares; caso contrário, você pode especificá-los como` path`
dependências da seguinte forma:

```toml
{{#include ../listings/ch20-advanced-features/no-listing-21-pancakes/pancakes/Cargo.toml:6:8}}
```

Coloque o código da Listagem 20-37 em _src/main.rs_ e execute `cargo run`:
deve imprimir ` Hello, Macro! My name is Pancakes!`. A implementação do
` HelloMacro `trait da macro processual foi incluído sem o
` pancakes `crate necessitando implementá-lo; o` #[derive(HelloMacro)]`adicionou o
Implementação trait.

A seguir, vamos explorar como os outros tipos de macros procedurais diferem das macros personalizadas.
Macros `derive`.

### Attribute-Like Macros

Macros semelhantes a atributos são semelhantes às macros `derive` personalizadas, mas em vez de
gerando código para o atributo `derive`, eles permitem criar novos
atributos. Eles também são mais flexíveis: ` derive`funciona apenas para estruturas e
enumerações; atributos também podem ser aplicados a outros itens, como funções.
Aqui está um exemplo de uso de uma macro semelhante a um atributo. Digamos que você tenha um atributo
chamado ` route`que anota funções ao usar uma estrutura de aplicativo da web:

```rust,ignore
#[route(GET, "/")]
fn index() {
```

Este atributo `#[route]` seria definido pelo framework como um procedimento
macro. A assinatura da função de definição de macro ficaria assim:

```rust,ignore
#[proc_macro_attribute]
pub fn route(attr: TokenStream, item: TokenStream) -> TokenStream {
```

Aqui temos dois parâmetros do tipo `TokenStream`. A primeira é para
conteúdo do atributo: a parte ` GET, "/"`. O segundo é o corpo do
item ao qual o atributo está anexado: neste caso, ` fn index() {}`e o resto
do corpo da função.

Fora isso, macros semelhantes a atributos funcionam da mesma maneira que `derive` personalizado
macros: Você cria um crate com o tipo `proc-macro` crate e implementa um
função que gera o código que você deseja!

### Function-Like Macros

Macros semelhantes a funções definem macros que se parecem com chamadas de função. Da mesma forma que
Macros `macro_rules!`, são mais flexíveis que funções; por exemplo, eles
pode receber um número desconhecido de argumentos. No entanto, as macros ` macro_rules!`podem
só pode ser definido usando a sintaxe semelhante a match que discutimos no [“Declarativo
Macros para metaprogramação geral”][decl]<!-- ignore --> seção anterior.
Macros semelhantes a funções recebem um parâmetro ` TokenStream`e sua definição
manipula esse ` TokenStream`usando o código Rust como os outros dois tipos de
macros processuais fazem. Um exemplo de macro semelhante a uma função é uma macro ` sql!`
que pode ser chamado assim:

```rust,ignore
let sql = sql!(SELECT * FROM posts WHERE id=1);
```

Esta macro analisaria a instrução SQL dentro dela e verificaria se está
sintaticamente correto, o que é um processamento muito mais complexo do que um
A macro `macro_rules!` pode fazer. A macro `sql!` seria definida assim:

```rust,ignore
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
```

Esta definição é semelhante à assinatura da macro `derive` personalizada: Recebemos
os tokens que estão entre parênteses e retornam o código que queríamos
gerar.

## Resumo

Uau! Agora você tem alguns recursos do Rust em sua caixa de ferramentas que provavelmente não usará
frequentemente, mas você saberá que eles estão disponíveis em circunstâncias muito específicas.
Introduzimos vários tópicos complexos para que, quando você os encontrar em
sugestões de mensagens de erro ou no código de outras pessoas, você poderá
reconhecer esses conceitos e sintaxe. Use este capítulo como referência para orientar
você para soluções.

A seguir, colocaremos em prática tudo o que discutimos ao longo do livro
e faça mais um projeto!

[ref]: ../reference/macros-by-example.html
[tlborm]: https://veykril.github.io/tlborm/
[syn]: https://crates.io/crates/syn
[quote]: https://crates.io/crates/quote
[syn-docs]: https://docs.rs/syn/2.0/syn/struct.DeriveInput.html
[quote-docs]: https://docs.rs/quote
[decl]: #declarative-macros-with-macro_rules-for-general-metaprogramming
