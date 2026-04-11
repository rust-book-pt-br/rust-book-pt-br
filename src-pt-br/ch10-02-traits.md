<!-- Old headings. Do not remove or links may break. -->

<a id="traits-defining-shared-behavior"></a>

## Definindo Comportamento Compartilhado com Características

Uma _trait_ define a funcionalidade que um determinado tipo possui e com a qual pode compartilhar
outros tipos. Podemos usar características para definir o comportamento compartilhado de forma abstrata. Nós
pode usar _limites de características_ para especificar que um tipo genérico pode ser qualquer tipo que tenha
determinado comportamento.

> Nota: As características são semelhantes a um recurso frequentemente chamado de _interfaces_ em outros
> línguas, embora com algumas diferenças.

### Definindo uma característica

O comportamento de um tipo consiste nos métodos que podemos chamar nesse tipo. Diferente
tipos compartilham o mesmo comportamento se pudermos chamar os mesmos métodos em todos esses
tipos. As definições de características são uma forma de agrupar assinaturas de métodos para
definir um conjunto de comportamentos necessários para atingir algum propósito.

Por exemplo, digamos que temos múltiplas estruturas que contêm vários tipos e
quantidades de texto: uma estrutura `NewsArticle` que contém uma notícia arquivada em um
determinado local e um `SocialPost` que pode ter, no máximo, 280 caracteres
junto com metadados que indicam se foi uma nova postagem, uma repostagem ou uma
responda a outra postagem.

Queremos criar uma caixa de biblioteca agregadora de mídia chamada `aggregator` que possa
exibir resumos de dados que podem ser armazenados em um `NewsArticle` ou
`SocialPost` instância. Para fazer isso, precisamos de um resumo de cada tipo, e vamos
solicite esse resumo chamando um método `summarize` em uma instância. Listagem
10-12 mostra a definição de um traço público `Summary` que expressa isso
comportamento.

<Listing number="10-12" file-name="src/lib.rs" caption="A `Summary` trait that consists of the behavior provided by a `summarize` method">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-12/src/lib.rs}}
```

</Listing>

Aqui, declaramos uma característica usando a palavra-chave `trait` e depois o nome da característica,
que é `Summary` neste caso. Também declaramos a característica como `pub` para que
caixas dependendo desta caixa também podem fazer uso dessa característica, como veremos em
alguns exemplos. Dentro das chaves, declaramos as assinaturas dos métodos
que descrevem os comportamentos dos tipos que implementam essa característica, que em
este caso é `fn summarize(&self) -> String`.

Após a assinatura do método, em vez de fornecer uma implementação dentro do curly
colchetes, usamos ponto e vírgula. Cada tipo que implementa esta característica deve fornecer
seu próprio comportamento personalizado para o corpo do método. O compilador irá impor
que qualquer tipo que tenha o traço `Summary` terá o método `summarize`
definido exatamente com esta assinatura.

Uma característica pode ter vários métodos em seu corpo: as assinaturas dos métodos são listadas
um por linha e cada linha termina com ponto e vírgula.

### Implementando uma característica em um tipo

Agora que definimos as assinaturas desejadas dos métodos do trait `Summary`,
podemos implementá-lo nos tipos do nosso agregador de mídia. Listando 10-13 programas
uma implementação do traço `Summary` na estrutura `NewsArticle` que usa
o título, o autor e o local para criar o valor de retorno de
`summarize`. Para a estrutura `SocialPost`, definimos `summarize` como o nome de usuário
seguido por todo o texto da postagem, assumindo que o conteúdo da postagem é
já limitado a 280 caracteres.

<Listing number="10-13" file-name="src/lib.rs" caption="Implementing the `Summary` trait on the `NewsArticle` and `SocialPost` types">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-13/src/lib.rs:here}}
```

</Listing>

A implementação de uma característica em um tipo é semelhante à implementação de métodos regulares. O
a diferença é que depois de `impl`, colocamos o nome do trait que queremos implementar,
em seguida, use a palavra-chave `for` e especifique o nome do tipo que queremos
implementar a característica para. Dentro do bloco `impl`, colocamos as assinaturas dos métodos
que a definição do traço definiu. Em vez de adicionar um ponto e vírgula após cada
assinatura, usamos colchetes e preenchemos o corpo do método com o específico
comportamento que queremos que os métodos da característica tenham para o tipo específico.

Agora que a biblioteca implementou o traço `Summary` em `NewsArticle` e
`SocialPost`, os usuários da caixa podem chamar os métodos trait em instâncias de
`NewsArticle` e `SocialPost` da mesma forma que chamamos métodos regulares. A única
A diferença é que o usuário deve trazer a característica para o escopo, bem como o
tipos. Aqui está um exemplo de como uma caixa binária poderia usar nosso `aggregator`
caixa da biblioteca:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-01-calling-trait-method/src/main.rs}}
```

Este código imprime `1 nova postagem: horse_ebooks: claro, como você provavelmente já
sabe, gente.

Outras caixas que dependem da caixa `aggregator` também podem trazer o `Summary`
trait no escopo para implementar `Summary` em seus próprios tipos. Uma restrição a
A observação é que só podemos implementar uma característica em um tipo se a característica ou o
tipo, ou ambos, são locais para nossa caixa. Por exemplo, podemos implementar padrões
características da biblioteca como `Display` em um tipo personalizado como `SocialPost` como parte de nosso
`aggregator` funcionalidade crate porque o tipo `SocialPost` é local para nosso
`aggregator` caixa. Também podemos implementar `Summary` em `Vec<T>` em nosso
`aggregator` caixa porque a característica `Summary` é local para nosso `aggregator`
caixa.

Mas não podemos implementar características externas em tipos externos. Por exemplo, não podemos
implementar a característica `Display` em `Vec<T>` dentro de nossa caixa `aggregator`,
porque `Display` e `Vec<T>` são definidos na biblioteca padrão e
não são locais da nossa caixa `aggregator`. Esta restrição faz parte de uma propriedade
chamada _coerência_, e mais especificamente a _regra órfã_, assim chamada porque
o tipo pai não está presente. Esta regra garante que o código de outras pessoas
não pode quebrar seu código e vice-versa. Sem a regra, duas caixas poderiam
implementar a mesma característica para o mesmo tipo, e Rust não saberia qual
implementação a ser usada.

<!-- Old headings. Do not remove or links may break. -->

<a id="default-implementations"></a>

### Usando implementações padrão

Às vezes é útil ter um comportamento padrão para alguns ou todos os métodos
em uma característica em vez de exigir implementações para todos os métodos em todos os tipos.
Então, à medida que implementamos a característica em um tipo específico, podemos manter ou substituir
o comportamento padrão de cada método.

Na Listagem 10-14, especificamos uma string padrão para o método `summarize` do
`Summary` trait em vez de apenas definir a assinatura do método, como fizemos em
Listagem 10-12.

<Listing number="10-14" file-name="src/lib.rs" caption="Defining a `Summary` trait with a default implementation of the `summarize` method">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-14/src/lib.rs:here}}
```

</Listing>

Para usar uma implementação padrão para resumir instâncias de `NewsArticle`, nós
especifique um bloco `impl` vazio com `impl Summary for NewsArticle {}`.

Mesmo que não estejamos mais definindo o método `summarize` em `NewsArticle`
diretamente, fornecemos uma implementação padrão e especificamos que
`NewsArticle` implementa a característica `Summary`. Como resultado, ainda podemos chamar
o método `summarize` em uma instância de `NewsArticle`, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-02-calling-default-impl/src/main.rs:here}}
```

Este código imprime `New article available! (Read more...)`.

Criar uma implementação padrão não exige que mudemos nada
a implementação de `Summary` em `SocialPost` na Listagem 10-13. A razão é
que a sintaxe para substituir uma implementação padrão é a mesma que a
sintaxe para implementar um método trait que não possui um padrão
implementação.

Implementações padrão podem chamar outros métodos com a mesma característica, mesmo que esses
outros métodos não possuem uma implementação padrão. Dessa forma, uma característica pode
fornecem muitas funcionalidades úteis e exigem apenas que os implementadores especifiquem
uma pequena parte disso. Por exemplo, poderíamos definir a característica `Summary` como tendo um
`summarize_author` cuja implementação é necessária e, em seguida, defina um
`summarize` método que possui uma implementação padrão que chama o
`summarize_author` método:

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-03-default-impl-calls-other-methods/src/lib.rs:here}}
```

Para usar esta versão de `Summary`, só precisamos definir `summarize_author`
quando implementamos a característica em um tipo:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-03-default-impl-calls-other-methods/src/lib.rs:impl}}
```

Depois de definirmos `summarize_author`, podemos chamar `summarize` em instâncias do
`SocialPost` struct, e a implementação padrão de `summarize` chamará o
definição de `summarize_author` que fornecemos. Porque implementamos
`summarize_author`, o traço `Summary` nos deu o comportamento do
`summarize` sem exigir que escrevamos mais nenhum código. Aqui está o que
isso se parece com:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-03-default-impl-calls-other-methods/src/main.rs:here}}
```

Este código imprime `1 new post: (Read more from @horse_ebooks...)`.

Observe que não é possível chamar a implementação padrão de um
substituindo a implementação desse mesmo método.

<!-- Old headings. Do not remove or links may break. -->

<a id="traits-as-parameters"></a>

### Usando características como parâmetros

Agora que você sabe como definir e implementar características, podemos explorar como usar
traits para definir funções que aceitam muitos tipos diferentes. Usaremos o
`Summary` trait que implementamos nos tipos `NewsArticle` e `SocialPost` em
Listagem 10-13 para definir uma função `notify` que chama o método `summarize`
em seu parâmetro `item`, que é de algum tipo que implementa o `Summary`
característica. Para fazer isso, usamos a sintaxe `impl Trait`, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-04-traits-as-parameters/src/lib.rs:here}}
```

Em vez de um tipo concreto para o parâmetro `item`, especificamos o `impl`
palavra-chave e o nome da característica. Este parâmetro aceita qualquer tipo que implemente o
característica especificada. No corpo de `notify`, podemos chamar qualquer método em `item`
que vêm do traço `Summary`, como `summarize`. Podemos ligar para `notify`
e passe em qualquer instância de `NewsArticle` ou `SocialPost`. Código que chama o
função com qualquer outro tipo, como `String` ou `i32`, não será compilada,
porque esses tipos não implementam `Summary`.

<!-- Old headings. Do not remove or links may break. -->

<a id="fixing-the-largest-function-with-trait-bounds"></a>

#### Sintaxe vinculada à característica

A sintaxe `impl Trait` funciona para casos simples, mas na verdade é uma sintaxe
açúcar para uma forma mais longa conhecida como _traitbound_; é assim:

```rust,ignore
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

Esta forma mais longa é equivalente ao exemplo da seção anterior, mas é
mais detalhado. Colocamos limites de características com a declaração do tipo genérico
parâmetro após dois pontos e dentro de colchetes angulares.

A sintaxe `impl Trait` é conveniente e proporciona um código mais conciso de maneira simples.
casos, enquanto a sintaxe mais completa ligada a características pode expressar mais complexidade em outros
casos. Por exemplo, podemos ter dois parâmetros que implementam `Summary`. Fazendo
então com a sintaxe `impl Trait` fica assim:

```rust,ignore
pub fn notify(item1: &impl Summary, item2: &impl Summary) {
```

Usar `impl Trait` é apropriado se quisermos que esta função permita `item1` e
`item2` para ter tipos diferentes (desde que ambos os tipos implementem `Summary`). Se
queremos forçar que ambos os parâmetros tenham o mesmo tipo, porém, devemos usar um
traço vinculado, assim:

```rust,ignore
pub fn notify<T: Summary>(item1: &T, item2: &T) {
```

O tipo genérico `T` especificado como o tipo de `item1` e `item2`
parâmetros restringe a função de tal forma que o tipo concreto do valor
passado como argumento para `item1` e `item2` deve ser o mesmo.

<!-- Old headings. Do not remove or links may break. -->

<a id="specifying-multiple-trait-bounds-with-the--syntax"></a>

#### Vários limites de características com a sintaxe `+`

Também podemos especificar mais de um limite de característica. Digamos que queremos que `notify` use
formatação de exibição, bem como `summarize` em `item`: especificamos no `notify`
definição de que `item` deve implementar `Display` e `Summary`. Nós podemos fazer
então, usando a sintaxe `+`:

```rust,ignore
pub fn notify(item: &(impl Summary + Display)) {
```

A sintaxe `+` também é válida com limites de características em tipos genéricos:

```rust,ignore
pub fn notify<T: Summary + Display>(item: &T) {
```

Com os dois limites de características especificados, o corpo de `notify` pode chamar `summarize`
e use `{}` para formatar `item`.

#### Limites de características mais claros com cláusulas `where`

Usar muitos limites de características tem suas desvantagens. Cada genérico tem sua própria característica
limites, portanto, funções com vários parâmetros de tipo genérico podem conter muitos
informações vinculadas a características entre o nome da função e sua lista de parâmetros,
tornando a assinatura da função difícil de ler. Por esta razão, Rust tem alternativas
sintaxe para especificar limites de características dentro de uma cláusula `where` após a função
assinatura. Então, em vez de escrever isto:

```rust,ignore
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
```

podemos usar uma cláusula `where`, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-07-where-clause/src/lib.rs:here}}
```

A assinatura desta função é menos confusa: o nome da função, lista de parâmetros,
e o tipo de retorno estão próximos, semelhante a uma função sem muitas características
limites.

### Retornando tipos que implementam características

Também podemos usar a sintaxe `impl Trait` na posição de retorno para retornar um
valor de algum tipo que implementa uma característica, conforme mostrado aqui:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-05-returning-impl-trait/src/lib.rs:here}}
```

Ao usar `impl Summary` para o tipo de retorno, especificamos que o
A função `returns_summarizable` retorna algum tipo que implementa `Summary`
trait sem nomear o tipo concreto. Neste caso, `returns_summarizable`
retorna `SocialPost`, mas o código que chama esta função não precisa saber
que.

A capacidade de especificar um tipo de retorno apenas pela característica que ele implementa é
especialmente útil no contexto de encerramentos e iteradores, que abordamos em
Capítulo 13. Closures e iteradores criam tipos que somente o compilador conhece ou
tipos que são muito longos para especificar. A sintaxe `impl Trait` permite que você concisamente
especifique que uma função retorna algum tipo que implementa a característica `Iterator`
sem precisar escrever um tipo muito longo.

No entanto, você só pode usar `impl Trait` se estiver retornando um único tipo. Para
por exemplo, este código que retorna `NewsArticle` ou `SocialPost` com
o tipo de retorno especificado como `impl Summary` não funcionaria:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-06-impl-trait-returns-one-type/src/lib.rs:here}}
```

Não é permitido retornar `NewsArticle` ou `SocialPost` devido a
restrições sobre como a sintaxe `impl Trait` é implementada no compilador.
Abordaremos como escrever uma função com esse comportamento na seção [“Usando Trait
Objetos para abstrair sobre comportamento compartilhado”][trait-objects]<!-- ignore -->
seção do Capítulo 18.

### Usando limites de características para implementar métodos condicionalmente

Usando uma característica vinculada a um bloco `impl` que usa parâmetros de tipo genérico,
podemos implementar métodos condicionalmente para tipos que implementam o especificado
características. Por exemplo, o tipo `Pair<T>` na Listagem 10-15 sempre implementa o
`new` para retornar uma nova instância de `Pair<T>` (lembre-se do [“Método
Sintaxe”][methods]<!-- ignore --> seção do Capítulo 5 que `Self` é um tipo
alias para o tipo do bloco `impl`, que neste caso é `Pair<T>`). Mas
no próximo bloco `impl`, `Pair<T>` apenas implementa o método `cmp_display` se
seu tipo interno `T` implementa a característica `PartialOrd` que permite comparação
_e_ a característica `Display` que permite a impressão.

<Listing number="10-15" file-name="src/lib.rs" caption="Conditionally implementing methods on a generic type depending on trait bounds">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-15/src/lib.rs}}
```

</Listing>

Também podemos implementar condicionalmente uma característica para qualquer tipo que implemente
outra característica. Implementações de uma característica em qualquer tipo que satisfaça a característica
limites são chamados de _implementações gerais_ e são usados ​​extensivamente no
Biblioteca padrão Rust. Por exemplo, a biblioteca padrão implementa o
`ToString` trait em qualquer tipo que implemente o `Display` trait. O `impl`
bloco na biblioteca padrão é semelhante a este código:

```rust,ignore
impl<T: Display> ToString for T {
    // --snip--
}
```

Como a biblioteca padrão tem essa implementação geral, podemos chamar o método
`to_string` método definido pela característica `ToString` em qualquer tipo que implemente
o traço `Display`. Por exemplo, podemos transformar números inteiros em seus correspondentes
`String` valores como este porque números inteiros implementam `Display`:

```rust
let s = 3.to_string();
```

Implementações gerais aparecem na documentação da característica no
Seção “Implementadores”.

Características e limites de características nos permitem escrever código que usa parâmetros de tipo genérico para
reduzir a duplicação, mas também especificar ao compilador que queremos o genérico
tipo para ter um comportamento específico. O compilador pode então usar o trait vinculado
informações para verificar se todos os tipos concretos usados ​​em nosso código fornecem o
comportamento correto. Em linguagens de tipo dinâmico, obteríamos um erro em
tempo de execução se chamarmos um método em um tipo que não definiu o método. Mas ferrugem
move esses erros para o tempo de compilação para que sejamos forçados a corrigi-los
antes mesmo que nosso código possa ser executado. Além disso, não precisamos escrever código
que verifica o comportamento em tempo de execução, porque já verificamos na compilação
tempo. Fazer isso melhora o desempenho sem ter que abrir mão da flexibilidade
de genéricos.

[trait-objects]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior
[methods]: ch05-03-method-syntax.html#method-syntax
