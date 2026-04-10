## Tipos Avançados

O sistema do tipo Rust possui alguns recursos que mencionamos até agora, mas não mencionamos
ainda discutido. Começaremos discutindo os novos tipos em geral enquanto examinamos o porquê
eles são úteis como tipos. Em seguida, passaremos para os aliases de digitação, um recurso
semelhante aos newtypes, mas com semântica ligeiramente diferente. Também discutiremos
o tipo `!` e tipos de tamanho dinâmico.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-the-newtype-pattern-for-type-safety-and-abstraction"></a>

### Digite segurança e abstração com o padrão Newtype

Esta seção pressupõe que você leu a seção anterior [“Implementando
Características com o padrão Newtype”][newtype]<!-- ignore -->. O padrão de novo tipo
também é útil para tarefas além daquelas que discutimos até agora, incluindo
impondo estaticamente que os valores nunca sejam confundidos e indicando as unidades de
um valor. Você viu um exemplo de uso de newtypes para indicar unidades na Listagem
20-16: Lembre-se de que as estruturas `Millimeters` e `Meters` envolvem valores `u32`
em um novo tipo. Se escrevermos uma função com um parâmetro do tipo ` Millimeters`,
não seria capaz de compilar um programa que acidentalmente tentasse chamar isso
função com um valor do tipo ` Meters`ou um ` u32`simples.

Também podemos usar o padrão newtype para abstrair algumas implementações
detalhes de um tipo: o novo tipo pode expor uma API pública diferente de
a API do tipo interno privado.

Newtypes também podem ocultar a implementação interna. Por exemplo, poderíamos fornecer um
Tipo `People` para agrupar um `HashMap<i32, String>` que armazena o ID de uma pessoa
associado ao seu nome. O código usando `People` interagiria apenas com o
API pública que fornecemos, como um método para adicionar uma string de nome ao `People`
coleção; esse código não precisaria saber que atribuímos um ID ` i32`aos nomes
internamente. O padrão newtype é uma maneira leve de obter encapsulamento
para ocultar detalhes de implementação, que discutimos no [“Encapsulamento que
Oculta a implementação
Details”][encapsulation-that-hides-implementation-details]<!-- ignore -->
seção no Capítulo 18.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-type-synonyms-with-type-aliases"></a>

### Sinônimos e aliases de tipo

Rust fornece a capacidade de declarar um _type alias_ para fornecer um tipo existente
outro nome. Para isso utilizamos a palavra-chave `type`. Por exemplo, podemos criar
o alias ` Kilometers`para ` i32`assim:

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-04-kilometers-alias/src/main.rs:here}}
```

Agora o apelido `Kilometers` é um _sinônimo_ para `i32`; ao contrário do ` Millimeters`
e ` Meters`que criamos na Listagem 20-16, ` Kilometers`não é separado,
novo tipo. Valores que possuem o tipo ` Kilometers`serão tratados da mesma forma que
valores do tipo ` i32`:

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-04-kilometers-alias/src/main.rs:there}}
```

Como `Kilometers` e `i32` são do mesmo tipo, podemos adicionar valores de ambos
tipos e podem passar valores `Kilometers` para funções que usam `i32`
parâmetros. No entanto, usando este método, não obtemos os benefícios da verificação de tipo
que obtemos do padrão newtype discutido anteriormente. Em outras palavras, se nós
misturar os valores ` Kilometers`e ` i32`em algum lugar, o compilador não nos dará
um erro.

O principal caso de uso para sinônimos de tipo é reduzir a repetição. Por exemplo, nós
pode ter um tipo longo como este:

```rust,ignore
Box<dyn Fn() + Send + 'static>
```

Escrever este tipo extenso em assinaturas de funções e como anotações de tipo
revisar o código pode ser cansativo e sujeito a erros. Imagine ter um projeto cheio de
código como esse na Listagem 20-25.

<Listing number="20-25" caption="Usando um tipo longo em muitos lugares">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-25/src/main.rs:here}}
```

</Listing>

Um alias de tipo torna esse código mais gerenciável, reduzindo a repetição. Em
Na Listagem 20-26, introduzimos um alias chamado `Thunk` para o tipo detalhado e
pode substituir todos os usos do tipo pelo alias mais curto `Thunk`.

<Listing number="20-26" caption="Introduzindo um alias de tipo, `Thunk`, para reduzir repetição">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-26/src/main.rs:here}}
```

</Listing>

Este código é muito mais fácil de ler e escrever! Escolhendo um nome significativo para um
type alias também pode ajudar a comunicar sua intenção (_thunk_ é uma palavra para código
para ser avaliado posteriormente, então é um nome apropriado para um closure que
fica armazenado).

Aliases de tipo também são comumente usados com o tipo `Result<T, E>` para reduzir
repetição. Considere o módulo `std::io` na biblioteca padrão. E/S
as operações geralmente retornam um `Result<T, E>` para lidar com situações quando as operações
não funcionar. Esta biblioteca possui uma estrutura `std::io::Error` que representa todos
possíveis erros de E/S. Muitas das funções em `std::io` retornarão
`Result<T, E> ` onde`E ` é`std::io::Error `, como estas funções em
o` Write`trait:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-05-write-trait/src/lib.rs}}
```

O `Result<..., Error>` se repete muito. Como tal, `std::io` possui este tipo
declaração de alias:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-06-result-alias/src/lib.rs:here}}
```

Como esta declaração está no módulo `std::io`, podemos usar o método completo
alias qualificado ` std::io::Result<T>`; isto é, um ` Result<T, E>`com o ` E`
preenchido como ` std::io::Error`. As assinaturas da função ` Write`trait terminam
parecendo assim:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-06-result-alias/src/lib.rs:there}}
```

O alias de tipo ajuda de duas maneiras: torna o código mais fácil de escrever _e_ fornece
nos proporciona uma interface consistente em todo o `std::io`. Porque é um apelido, é
apenas outro ` Result<T, E>`, o que significa que podemos usar qualquer método que funcione
` Result<T, E> `com ele, bem como sintaxe especial como o operador`?`.

### O tipo nunca que nunca retorna

Rust tem um tipo especial chamado `!` que é conhecido no jargão da teoria dos tipos como
_tipo vazio_ porque não possui valores. Preferimos chamá-lo de _nunca tipo_
porque está no lugar do tipo de retorno quando uma função nunca será
retornar. Aqui está um exemplo:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-07-never-type/src/lib.rs:here}}
```

Este código é lido como “a função `bar` retorna nunca”. Funções que retornam
nunca são chamadas de _funções divergentes_. Não podemos criar valores do tipo `!`,
então ` bar`nunca poderá retornar.

Mas para que serve um tipo para o qual você nunca pode criar valores? Lembre-se do código de
Listagem 2.5, parte do jogo de adivinhação de números; reproduzimos um pouco disso
aqui na Listagem 20-27.

<Listing number="20-27" caption="Um `match` com um braço que termina em `continue`">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-05/src/main.rs:ch19}}
```

</Listing>

Na época, pulamos alguns detalhes neste código. Em [“O `match`
Control Flow Construct”][the-match-control-flow-construct]<!-- ignore -->
seção no Capítulo 6, discutimos que os braços `match` devem todos retornar o mesmo
tipo. Então, por exemplo, o código a seguir não funciona:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-08-match-arms-different-types/src/main.rs:here}}
```

O tipo de `guess` neste código teria que ser um número inteiro _e_ uma string,
e Rust requer que `guess` tenha apenas um tipo. Então, o que `continue`
retornar? Como pudemos devolver um ` u32`de um braço e ter outro braço
que termina com ` continue`na Listagem 20-27?

Como você deve ter adivinhado, `continue` tem um valor `!`. Ou seja, quando Rust
calcula o tipo de ` guess`, ele analisa ambos os braços match, o primeiro com um
valor de ` u32`e o último com valor `!`. Porque `!` nunca pode ter um
valor, Rust decide que o tipo de `guess` é `u32`.

A maneira formal de descrever esse comportamento é que expressões do tipo `!` podem
ser coagido a qualquer outro tipo. Podemos encerrar este braço `match` com
`continue ` porque`continue ` não retorna um valor; em vez disso, ele move o controle
de volta ao topo do loop, portanto, no caso`Err `, nunca atribuímos um valor a
` guess`.

O tipo never também é útil com a macro `panic!`. Lembre-se do ` unwrap`
função que chamamos em valores ` Option<T>`para produzir um valor ou panic com
esta definição:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-09-unwrap-definition/src/lib.rs:here}}
```

Neste código acontece o mesmo que no `match` da Listagem 20-27: Rust
vê que `val` tem o tipo `T` e `panic!` tem o tipo `!`, então o resultado
da expressão ` match`geral é ` T`. Este código funciona porque ` panic!`
não produz um valor; isso encerra o programa. No caso ` None`, não seremos
retornando um valor de ` unwrap`, portanto este código é válido.

Uma expressão final que possui o tipo `!` é um loop:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-10-loop-returns-never/src/main.rs:here}}
```

Aqui, o loop nunca termina, então `!` é o valor da expressão. No entanto, isso
não seria verdade se incluíssemos um `break`, porque o loop terminaria
quando chegou ao ` break`.

### Tipos de tamanho dinâmico e a característica `Sized`

Rust precisa saber alguns detalhes sobre seus tipos, como quanto espaço deve ser
alocar para um valor de um tipo específico. Isso deixa um canto do seu tipo
sistema um pouco confuso no início: o conceito de _tipos de tamanho dinâmico_.
Às vezes chamados de _DSTs_ ou _unsized types_, esses tipos nos permitem escrever
código usando valores cujo tamanho só podemos saber em tempo de execução.

Vamos nos aprofundar nos detalhes de um tipo de tamanho dinâmico chamado `str`, que
usamos ao longo do livro. Isso mesmo, não ` &str`, mas ` str`em
próprio, é um horário de verão. Em muitos casos, como ao armazenar texto inserido por um usuário,
não podemos saber quanto tempo a string tem até o tempo de execução. Isso significa que não podemos criar
uma variável do tipo ` str`, nem podemos aceitar um argumento do tipo ` str`. Considere
o seguinte código, que não funciona:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-11-cant-create-str/src/main.rs:here}}
```

Rust precisa saber quanta memória deve ser alocada para qualquer valor de um determinado
tipo, e todos os valores de um tipo devem usar a mesma quantidade de memória. Se Rust
nos permitiu escrever este código, esses dois valores `str` precisariam ocupar o
mesma quantidade de espaço. Mas eles têm comprimentos diferentes: `s1` precisa de 12 bytes de
armazenamento e `s2` precisam de 15. É por isso que não é possível criar uma variável
segurando um tipo de tamanho dinâmico.

Então, o que fazemos? Nesse caso você já sabe a resposta: Fazemos o tipo
da sequência `s1` e `s2` slice (`&str `) em vez de` str `. Lembre-se do
[“String Slices”][string-slices]<!-- ignore --> seção no Capítulo 4 que o
A estrutura de dados slice armazena apenas a posição inicial e o comprimento do
slice. Portanto, embora` &T `seja um valor único que armazena o endereço de memória de
onde o` T `está localizado, uma string slice tem _dois_ valores: o endereço do
` str `e seu comprimento. Como tal, podemos saber o tamanho do valor de uma string slice em
tempo de compilação: tem o dobro do comprimento de um` usize`. Ou seja, sempre sabemos o
tamanho de uma string slice, não importa o tamanho da string a que ela se refere. Em
Em geral, esta é a forma como os tipos de tamanho dinâmico são usados em Rust:
Eles têm um pouco extra de metadados que armazena o tamanho do dinâmico
informação. A regra de ouro dos tipos de tamanho dinâmico é que devemos sempre
coloque valores de tipos de tamanho dinâmico atrás de algum tipo de ponteiro.

Podemos combinar `str` com todos os tipos de ponteiros: por exemplo, `Box<str>` ou
`Rc<str> `. Na verdade, você já viu isso antes, mas com uma dinâmica diferente
tipo de tamanho: traits. Cada trait é um tipo de tamanho dinâmico ao qual podemos nos referir por
usando o nome do trait. Na seção [“Usando objetos de características para abstrair
Comportamento compartilhado”][using-trait-objects-to-abstract-over-shared-behavior]<!--
ignore --> no Capítulo 18, mencionamos que para usar traits como trait
objetos, devemos colocá-los atrás de um ponteiro, como` &dyn Trait `ou` Box<dyn
Trait> `(` Rc<dyn Trait>`também funcionaria).

Para trabalhar com DSTs, Rust fornece o `Sized` trait para determinar se ou não
o tamanho de um tipo é conhecido em tempo de compilação. Este trait é implementado automaticamente
para tudo cujo tamanho é conhecido em tempo de compilação. Além disso, Rust
adiciona implicitamente um limite em `Sized` a cada função genérica. Ou seja, um
definição de função genérica como esta:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-12-generic-fn-definition/src/lib.rs}}
```

is actually treated as though we had written this:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-13-generic-implicit-sized-bound/src/lib.rs}}
```

Por padrão, as funções genéricas funcionarão apenas em tipos que possuem um tamanho conhecido em
tempo de compilação. No entanto, você pode usar a seguinte sintaxe especial para relaxar isso
restrição:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-14-generic-maybe-sized/src/lib.rs}}
```

Um trait vinculado a `?Sized` significa “ `T` pode ou não ser `Sized` ”, e isso
a notação substitui o padrão de que os tipos genéricos devem ter um tamanho conhecido em
tempo de compilação. A sintaxe `?Trait` com este significado só está disponível para
`Sized`, não qualquer outro traits.

Observe também que mudamos o tipo do parâmetro `t` de `T` para `&T`.
Como o tipo pode não ser ` Sized`, precisamos usá-lo atrás de algum tipo de
ponteiro. Neste caso, escolhemos uma referência.

A seguir falaremos sobre funções e closures!

[encapsulation-that-hides-implementation-details]: ch18-01-what-is-oo.html#encapsulation-that-hides-implementation-details
[string-slices]: ch04-03-slices.html#string-slices
[the-match-control-flow-construct]: ch06-02-match.html#the-match-control-flow-construct
[using-trait-objects-to-abstract-over-shared-behavior]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior
[newtype]: ch20-02-advanced-traits.html#implementing-external-traits-with-the-newtype-pattern
