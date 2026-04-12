<!-- Old headings. Do not remove or links may break. -->

<a id="traits-defining-shared-behavior"></a>

## Definindo Comportamento Compartilhado com Características

Uma _trait_ define a funcionalidade que um tipo específico possui e pode
compartilhar com outros tipos. Podemos usar traits para descrever comportamento
compartilhado de forma abstrata. Também podemos usar _trait bounds_ para
especificar que um tipo genérico pode ser qualquer tipo que tenha determinado
comportamento.

> Nota: traits são parecidas com um recurso frequentemente chamado de
> _interfaces_ em outras linguagens, embora existam algumas diferenças.

### Definindo uma Trait

O comportamento de um tipo consiste nos métodos que podemos chamar nesse tipo.
Tipos diferentes compartilham o mesmo comportamento quando podemos chamar os
mesmos métodos em todos eles. Definições de trait são uma forma de agrupar
assinaturas de métodos para definir um conjunto de comportamentos necessários
para atingir algum objetivo.

Por exemplo, digamos que temos várias structs que armazenam tipos e quantidades
diferentes de texto: uma struct `NewsArticle`, que representa uma notícia
publicada em algum local, e um `SocialPost`, que pode ter no máximo 280
caracteres, além de metadados indicando se se trata de uma nova postagem, um
repost ou uma resposta a outra postagem.

Queremos criar um crate de biblioteca agregador de mídia chamado `aggregator`,
capaz de exibir resumos de dados que podem estar armazenados em uma instância
de `NewsArticle` ou `SocialPost`. Para isso, precisamos de um resumo de cada
tipo e vamos solicitá-lo chamando um método `summarize` na instância. A
Listagem 10-12 mostra a definição de uma trait pública `Summary` que expressa
esse comportamento.

<Listing number="10-12" file-name="src/lib.rs" caption="Uma trait `Summary` composta pelo comportamento fornecido por um método `summarize`">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-12/src/lib.rs}}
```

</Listing>

Aqui, declaramos uma trait usando a palavra-chave `trait` seguida do nome da
trait, que neste caso é `Summary`. Também a declaramos como `pub`, para que
crates que dependam deste crate possam usá-la, como veremos em alguns
exemplos. Dentro das chaves, declaramos as assinaturas dos métodos que
descrevem os comportamentos dos tipos que implementam essa trait; neste caso,
temos `fn summarize(&self) -> String`.

Depois da assinatura do método, em vez de fornecer uma implementação entre
chaves, usamos um ponto e vírgula. Cada tipo que implementar essa trait deverá
fornecer seu próprio comportamento para o corpo do método. O compilador garante
que qualquer tipo que implemente `Summary` terá o método `summarize` definido
exatamente com essa assinatura.

Uma trait pode ter vários métodos no corpo: as assinaturas são listadas uma por
linha, e cada linha termina com ponto e vírgula.

### Implementando uma Trait em um Tipo

Agora que definimos as assinaturas desejadas para os métodos da trait
`Summary`, podemos implementá-la nos tipos do nosso agregador de mídia. A
Listagem 10-13 mostra uma implementação de `Summary` para a struct
`NewsArticle`, usando título, autor e local para construir o valor retornado
por `summarize`. Para a struct `SocialPost`, definimos `summarize` como o nome
de usuário seguido do texto inteiro da postagem, assumindo que esse conteúdo já
está limitado a 280 caracteres.

<Listing number="10-13" file-name="src/lib.rs" caption="Implementando a trait `Summary` nos tipos `NewsArticle` e `SocialPost`">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-13/src/lib.rs:here}}
```

</Listing>

Implementar uma trait em um tipo é parecido com implementar métodos comuns. A
diferença é que, depois de `impl`, colocamos o nome da trait que queremos
implementar, usamos a palavra-chave `for` e então especificamos o nome do tipo
para o qual queremos implementar a trait. Dentro do bloco `impl`, colocamos as
assinaturas dos métodos definidos pela trait. Em vez de terminar cada
assinatura com ponto e vírgula, usamos chaves e preenchemos o corpo do método
com o comportamento específico que queremos para aquele tipo.

Agora que a biblioteca implementa a trait `Summary` em `NewsArticle` e
`SocialPost`, usuários do crate podem chamar os métodos da trait em instâncias
desses tipos da mesma forma que chamamos métodos comuns. A única diferença é
que o usuário precisa trazer para o escopo tanto a trait quanto os tipos. Aqui
está um exemplo de como um crate binário poderia usar nosso crate de biblioteca
`aggregator`:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-01-calling-trait-method/src/main.rs}}
```

Esse código imprime `1 new post: horse_ebooks: of course, as you probably
already know, people`.

Outros crates que dependem de `aggregator` também podem trazer a trait
`Summary` para o escopo e implementá-la em seus próprios tipos. Há, porém, uma
restrição importante: só podemos implementar uma trait em um tipo se a trait,
o tipo, ou ambos, forem locais ao nosso crate. Por exemplo, podemos
implementar traits da biblioteca padrão, como `Display`, em um tipo
personalizado como `SocialPost` dentro do nosso crate `aggregator`, porque o
tipo `SocialPost` é local. Também podemos implementar `Summary` em `Vec<T>` em
nosso crate `aggregator`, porque a trait `Summary` é local ao crate.

Mas não podemos implementar traits externas em tipos externos. Por exemplo, não
podemos implementar `Display` para `Vec<T>` dentro do crate `aggregator`,
porque tanto `Display` quanto `Vec<T>` são definidos na biblioteca padrão e,
portanto, não são locais ao nosso crate. Essa restrição faz parte de uma
propriedade chamada _coerência_ e, mais especificamente, da chamada _regra
órfã_ (_orphan rule_). Essa regra garante que o código de outras pessoas não
quebrará o seu, e vice-versa. Sem ela, dois crates poderiam implementar a
mesma trait para o mesmo tipo, e o Rust não saberia qual implementação usar.

<!-- Old headings. Do not remove or links may break. -->

<a id="default-implementations"></a>

### Usando Implementações Padrão

Às vezes é útil ter um comportamento padrão para alguns ou todos os métodos de
uma trait, em vez de exigir implementações para todos os métodos em todos os
tipos. Assim, ao implementar a trait em um tipo específico, podemos manter ou
substituir o comportamento padrão de cada método.

Na Listagem 10-14, especificamos uma string padrão para o método `summarize` da
trait `Summary`, em vez de definir apenas sua assinatura, como fizemos na
Listagem 10-12.

<Listing number="10-14" file-name="src/lib.rs" caption="Definindo uma trait `Summary` com implementação padrão do método `summarize`">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-14/src/lib.rs:here}}
```

</Listing>

Para usar uma implementação padrão para resumir instâncias de `NewsArticle`,
basta especificar um bloco `impl` vazio com `impl Summary for NewsArticle {}`.

Mesmo sem definir `summarize` diretamente em `NewsArticle`, fornecemos uma
implementação padrão e especificamos que `NewsArticle` implementa a trait
`Summary`. Como resultado, ainda podemos chamar `summarize` em uma instância
de `NewsArticle`, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-02-calling-default-impl/src/main.rs:here}}
```

Esse código imprime `New article available! (Read more...)`.

Criar uma implementação padrão não exige que mudemos nada na implementação de
`Summary` em `SocialPost` na Listagem 10-13. Isso porque a sintaxe para
substituir uma implementação padrão é a mesma usada para implementar um método
de trait que não tem implementação padrão.

Implementações padrão podem chamar outros métodos da mesma trait, mesmo que
esses outros métodos não tenham implementação padrão. Dessa forma, uma trait
pode oferecer bastante funcionalidade útil e exigir que os implementadores
especifiquem apenas uma pequena parte dela. Por exemplo, poderíamos definir a
trait `Summary` com um método `summarize_author`, cuja implementação seria
obrigatória, e depois definir um método `summarize` com implementação padrão
que chama `summarize_author`:

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-03-default-impl-calls-other-methods/src/lib.rs:here}}
```

Para usar essa versão de `Summary`, precisamos apenas definir
`summarize_author` ao implementar a trait em um tipo:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-03-default-impl-calls-other-methods/src/lib.rs:impl}}
```

Depois de definir `summarize_author`, podemos chamar `summarize` em instâncias
da struct `SocialPost`, e a implementação padrão de `summarize` chamará a
definição de `summarize_author` que fornecemos. Como implementamos
`summarize_author`, a trait `Summary` nos fornece o comportamento de
`summarize` sem exigir nenhum código extra. O resultado fica assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-03-default-impl-calls-other-methods/src/main.rs:here}}
```

Esse código imprime `1 new post: (Read more from @horse_ebooks...)`.

Observe que não é possível chamar a implementação padrão a partir de uma
implementação que substitui esse mesmo método.

<!-- Old headings. Do not remove or links may break. -->

<a id="traits-as-parameters"></a>

### Usando Traits como Parâmetros

Agora que você já sabe como definir e implementar traits, podemos explorar como
usá-las para definir funções que aceitam muitos tipos diferentes. Usaremos a
trait `Summary`, implementada para `NewsArticle` e `SocialPost` na Listagem
10-13, para definir uma função `notify` que chama o método `summarize` em seu
parâmetro `item`, que é de algum tipo que implementa `Summary`. Para fazer
isso, usamos a sintaxe `impl Trait`, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-04-traits-as-parameters/src/lib.rs:here}}
```

Em vez de um tipo concreto para o parâmetro `item`, especificamos a palavra-
chave `impl` e o nome da trait. Esse parâmetro aceita qualquer tipo que
implemente a trait especificada. No corpo de `notify`, podemos chamar em
`item` qualquer método proveniente da trait `Summary`, como `summarize`.
Podemos chamar `notify` passando qualquer instância de `NewsArticle` ou
`SocialPost`. Já um código que tente chamar a função com qualquer outro tipo,
como `String` ou `i32`, não compilará, porque esses tipos não implementam
`Summary`.

<!-- Old headings. Do not remove or links may break. -->

<a id="fixing-the-largest-function-with-trait-bounds"></a>

#### Sintaxe de Trait Bounds

A sintaxe `impl Trait` funciona bem em casos simples, mas na verdade é um
_syntax sugar_ para uma forma mais longa, conhecida como _trait bound_:

```rust,ignore
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

Essa forma mais longa é equivalente ao exemplo da seção anterior, apenas mais
verbosa. Colocamos o trait bound na declaração do parâmetro de tipo genérico,
depois de dois-pontos e dentro dos colchetes angulares.

A sintaxe `impl Trait` é conveniente e gera código mais conciso em casos
simples, enquanto a forma completa com trait bounds pode expressar situações
mais complexas. Por exemplo, podemos ter dois parâmetros que implementam
`Summary`. Com a sintaxe `impl Trait`, isso fica assim:

```rust,ignore
pub fn notify(item1: &impl Summary, item2: &impl Summary) {
```

Usar `impl Trait` é apropriado se quisermos permitir que `item1` e `item2`
tenham tipos diferentes, contanto que ambos implementem `Summary`. Se quisermos
forçar que ambos os parâmetros tenham o mesmo tipo, porém, devemos usar um
trait bound, assim:

```rust,ignore
pub fn notify<T: Summary>(item1: &T, item2: &T) {
```

O tipo genérico `T`, usado tanto em `item1` quanto em `item2`, restringe a
função de modo que o tipo concreto passado como argumento para ambos os
parâmetros precisa ser o mesmo.

<!-- Old headings. Do not remove or links may break. -->

<a id="specifying-multiple-trait-bounds-with-the--syntax"></a>

#### Múltiplos Trait Bounds com a Sintaxe `+`

Também podemos especificar mais de um trait bound. Digamos que queremos que
`notify` use formatação de exibição, além de `summarize` em `item`: nesse caso,
especificamos na definição de `notify` que `item` deve implementar `Display` e
`Summary`. Podemos fazer isso usando a sintaxe `+`:

```rust,ignore
pub fn notify(item: &(impl Summary + Display)) {
```

A sintaxe `+` também funciona com trait bounds em tipos genéricos:

```rust,ignore
pub fn notify<T: Summary + Display>(item: &T) {
```

Com os dois trait bounds especificados, o corpo de `notify` pode chamar
`summarize` e usar `{}` para formatar `item`.

#### Trait Bounds Mais Claros com Cláusulas `where`

Usar muitos trait bounds tem suas desvantagens. Cada tipo genérico recebe seus
próprios limites, então funções com vários parâmetros genéricos podem acabar
com muita informação espremida entre o nome da função e a lista de parâmetros,
o que torna a assinatura difícil de ler. Por isso, o Rust oferece uma sintaxe
alternativa para especificar trait bounds dentro de uma cláusula `where`, após
a assinatura da função. Assim, em vez de escrever isto:

```rust,ignore
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
```

podemos usar uma cláusula `where`, assim:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-07-where-clause/src/lib.rs:here}}
```

A assinatura dessa função fica menos confusa: o nome da função, a lista de
parâmetros e o tipo de retorno ficam próximos uns dos outros, como em uma
função sem muitos trait bounds.

### Retornando Tipos que Implementam Traits

Também podemos usar a sintaxe `impl Trait` na posição de retorno para devolver
um valor de algum tipo que implemente uma trait, como mostrado aqui:

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-05-returning-impl-trait/src/lib.rs:here}}
```

Ao usar `impl Summary` como tipo de retorno, estamos especificando que a função
`returns_summarizable` retorna algum tipo que implementa a trait `Summary`,
sem nomear qual é esse tipo concreto. Neste caso, `returns_summarizable`
retorna `SocialPost`, mas o código que chama a função não precisa saber disso.

A capacidade de especificar um tipo de retorno apenas pela trait que ele
implementa é especialmente útil no contexto de closures e iteradores, que
veremos no Capítulo 13. Closures e iteradores produzem tipos que só o
compilador conhece ou que seriam longos demais para escrever. A sintaxe
`impl Trait` permite declarar de forma concisa que uma função retorna algum
tipo que implementa a trait `Iterator`, sem precisar escrever um tipo enorme.

No entanto, só podemos usar `impl Trait` quando a função retorna um único tipo.
Por exemplo, este código, que retorna `NewsArticle` ou `SocialPost` com o tipo
de retorno especificado como `impl Summary`, não funcionaria:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-06-impl-trait-returns-one-type/src/lib.rs:here}}
```

Não é permitido retornar `NewsArticle` ou `SocialPost` por causa das
restrições de como `impl Trait` é implementado no compilador. Veremos como
escrever uma função com esse comportamento na seção [“Usando Trait Objects
para Abstrair Comportamento Compartilhado”][trait-objects]<!-- ignore --> do
Capítulo 18.

### Usando Trait Bounds para Implementar Métodos Condicionalmente

Ao usar trait bounds em um bloco `impl` com parâmetros de tipo genérico,
podemos implementar métodos condicionalmente para tipos que satisfaçam os
limites especificados. Por exemplo, o tipo `Pair<T>` da Listagem 10-15 sempre
implementa o método `new`, que retorna uma nova instância de `Pair<T>`.
Lembre-se, da seção [“Sintaxe de Método”][methods]<!-- ignore --> do Capítulo
5, que `Self` é um alias para o tipo do bloco `impl`, que aqui é `Pair<T>`.
Mas, no bloco `impl` seguinte, `Pair<T>` só implementa o método
`cmp_display` se seu tipo interno `T` implementar `PartialOrd`, que permite
comparação, _e_ `Display`, que permite impressão.

<Listing number="10-15" file-name="src/lib.rs" caption="Implementando métodos condicionalmente em um tipo genérico, dependendo de trait bounds">

```rust,noplayground
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-15/src/lib.rs}}
```

</Listing>

Também podemos implementar condicionalmente uma trait para qualquer tipo que
implemente outra trait. Implementações de uma trait para qualquer tipo que
satisfaça determinados trait bounds são chamadas de _implementações gerais_ e
são muito usadas na biblioteca padrão do Rust. Por exemplo, a biblioteca
padrão implementa a trait `ToString` para qualquer tipo que implemente
`Display`. O bloco `impl` correspondente na biblioteca padrão se parece com
algo assim:

```rust,ignore
impl<T: Display> ToString for T {
    // --snip--
}
```

Como a biblioteca padrão tem essa implementação geral, podemos chamar o método
`to_string`, definido pela trait `ToString`, em qualquer tipo que implemente
`Display`. Por exemplo, podemos transformar inteiros em seus valores `String`
correspondentes porque inteiros implementam `Display`:

```rust
let s = 3.to_string();
```

Implementações gerais aparecem na documentação da trait na seção
“Implementors”.

Traits e trait bounds nos permitem escrever código com parâmetros de tipo
genérico para reduzir duplicação e, ao mesmo tempo, especificar ao compilador
que queremos que o tipo genérico tenha determinado comportamento. O compilador
pode então usar essas informações para verificar se todos os tipos concretos
usados no código fornecem o comportamento correto. Em linguagens de tipagem
dinâmica, receberíamos um erro em tempo de execução se chamássemos um método em
um tipo que não o define. Em Rust, esses erros são antecipados para o tempo de
compilação, de modo que somos obrigados a corrigi-los antes mesmo de executar o
código. Além disso, não precisamos escrever checagens de comportamento em
tempo de execução, porque tudo já foi validado na compilação. Isso melhora o
desempenho sem abrir mão da flexibilidade oferecida pelos genéricos.

[trait-objects]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior
[methods]: ch05-03-method-syntax.html#method-syntax
