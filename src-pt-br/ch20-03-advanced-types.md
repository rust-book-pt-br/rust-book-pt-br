## Tipos Avançados

O sistema de tipos do Rust possui alguns recursos que mencionamos até agora, mas
ainda não discutimos de fato. Começaremos falando de newtypes em geral, à
medida que examinamos por que eles são úteis como tipos. Em seguida, passaremos
para aliases de tipo, um recurso semelhante aos newtypes, mas com semântica um
pouco diferente. Também discutiremos o tipo `!` e os tipos de tamanho dinâmico.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-the-newtype-pattern-for-type-safety-and-abstraction"></a>

### Segurança de Tipos e Abstração com o Padrão Newtype

Esta seção pressupõe que você tenha lido a seção anterior,
[“Implementando Traits Externas com o Padrão Newtype”][newtype]<!-- ignore -->.
O padrão newtype também é útil para tarefas além daquelas que discutimos até
aqui, incluindo impor estaticamente que valores nunca sejam confundidos e
indicar as unidades de um valor. Você viu um exemplo de uso de newtypes para
indicar unidades na Listagem 20-16: lembre-se de que as structs `Millimeters` e
`Meters` encapsulam valores `u32` em um newtype. Se escrevêssemos uma função com
um parâmetro do tipo `Millimeters`, não conseguiríamos compilar um programa que
tentasse, por engano, chamá-la com um valor do tipo `Meters` ou com um simples
`u32`.

Também podemos usar o padrão newtype para abstrair alguns detalhes de
implementação de um tipo: o novo tipo pode expor uma API pública diferente da
API do tipo interno privado.

Newtypes também podem ocultar a implementação interna. Por exemplo, poderíamos
fornecer um tipo `People` para encapsular um `HashMap<i32, String>` que
armazena o ID de uma pessoa associado ao seu nome. O código que usasse
`People` interagiria apenas com a API pública que fornecemos, como um método
para adicionar uma string de nome à coleção `People`; esse código não
precisaria saber que, internamente, atribuímos um ID `i32` aos nomes. O padrão
newtype é uma forma leve de obter encapsulamento para esconder detalhes de
implementação, algo que discutimos na seção
[“Encapsulamento que oculta detalhes de implementação”][encapsulation-that-hides-implementation-details]<!-- ignore -->
no Capítulo 18.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-type-synonyms-with-type-aliases"></a>

### Sinônimos e Aliases de Tipo

Rust oferece a capacidade de declarar um _type alias_ para dar outro nome a um
tipo existente. Para isso, usamos a palavra-chave `type`. Por exemplo, podemos
criar o alias `Kilometers` para `i32` assim:

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-04-kilometers-alias/src/main.rs:here}}
```

Agora, o alias `Kilometers` é um _sinônimo_ para `i32`; ao contrário de
`Millimeters` e `Meters`, que criamos na Listagem 20-16, `Kilometers` não é um
newtype separado. Valores que têm o tipo `Kilometers` serão tratados da mesma
forma que valores do tipo `i32`:

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-04-kilometers-alias/src/main.rs:there}}
```

Como `Kilometers` e `i32` são o mesmo tipo, podemos somar valores dos dois
tipos e também passar valores `Kilometers` para funções que recebem parâmetros `i32`.
No entanto, usando esse método, não obtemos os benefícios de verificação de tipo
que o padrão newtype oferece. Em outras palavras, se misturarmos valores
`Kilometers` e `i32` em algum ponto, o compilador não nos dará
nenhum erro.

O principal caso de uso de sinônimos de tipo é reduzir repetição. Por exemplo,
podemos ter um tipo longo como este:

```rust,ignore
Box<dyn Fn() + Send + 'static>
```

Escrever esse tipo extenso em assinaturas de funções e em anotações de tipo por
todo o código pode ser cansativo e sujeito a erros. Imagine um projeto cheio de
código como o da Listagem 20-25.

<Listing number="20-25" caption="Usando um tipo longo em muitos lugares">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-25/src/main.rs:here}}
```

</Listing>

Um alias de tipo torna esse código mais administrável ao reduzir a repetição.
Na Listagem 20-26, introduzimos um alias chamado `Thunk` para esse tipo
verboso e substituímos todas as ocorrências pelo alias mais curto `Thunk`.

<Listing number="20-26" caption="Introduzindo um alias de tipo, `Thunk`, para reduzir repetição">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-26/src/main.rs:here}}
```

</Listing>

Esse código é bem mais fácil de ler e escrever. Escolher um nome significativo
para um type alias também pode ajudar a comunicar sua intenção. _Thunk_ é uma
palavra usada para código que será avaliado mais tarde, portanto é um nome
apropriado para uma closure armazenada.

Aliases de tipo também são comumente usados com `Result<T, E>` para reduzir
repetição. Considere o módulo `std::io` da biblioteca padrão. Operações de E/S
geralmente retornam um `Result<T, E>` para lidar com situações em que algo
falha. Essa biblioteca tem uma struct `std::io::Error` que representa todos os
erros de E/S possíveis. Muitas das funções de `std::io` retornam
`Result<T, E>`, em que `E` é `std::io::Error`, como acontece nestas funções da
trait `Write`:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-05-write-trait/src/lib.rs}}
```

`Result<..., Error>` se repete bastante. Por isso, `std::io` possui esta
declaração de alias de tipo:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-06-result-alias/src/lib.rs:here}}
```

Como essa declaração está no módulo `std::io`, podemos usar o alias
totalmente qualificado `std::io::Result<T>`; isto é, um `Result<T, E>` com `E`
preenchido como `std::io::Error`. As assinaturas das funções da trait `Write`
acabam ficando assim:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-06-result-alias/src/lib.rs:there}}
```

O alias de tipo ajuda de duas maneiras: torna o código mais fácil de escrever _e_
nos dá uma interface consistente em todo o `std::io`. Como é apenas um alias, ele é
só outra forma de escrever `Result<T, E>`, o que significa que podemos usar
com ele qualquer método que funcione com `Result<T, E>`, além de sintaxes especiais,
como o operador `?`.

### O Tipo Never, Que Nunca Retorna

Rust tem um tipo especial chamado `!`, conhecido, no jargão da teoria dos
tipos, como _tipo vazio_, porque não possui valores. Preferimos chamá-lo de
_tipo never_ porque ele aparece no lugar do tipo de retorno quando uma função
nunca retornará. Aqui está um exemplo:

```rust,noplayground
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-07-never-type/src/lib.rs:here}}
```

Esse código é lido como “a função `bar` retorna never”. Funções que nunca
retornam são chamadas de _funções divergentes_. Não podemos criar valores do
tipo `!`, então `bar` jamais poderá retornar.

Mas para que serve um tipo para o qual você nunca pode criar valores? Lembre-se
do código da Listagem 2-5, parte do jogo de adivinhação de números;
reproduzimos um trecho dele aqui na Listagem 20-27.

<Listing number="20-27" caption="Um `match` com um braço que termina em `continue`">

```rust,ignore
{{#rustdoc_include ../listings/ch02-guessing-game-tutorial/listing-02-05/src/main.rs:ch19}}
```

</Listing>

Na época, pulamos alguns detalhes desse código. Na seção [“A estrutura
de controle de fluxo `match`”][the-match-control-flow-construct]<!-- ignore -->
do Capítulo 6, discutimos que todos os braços de `match` devem retornar o mesmo
tipo. Assim, por exemplo, o código a seguir não funciona:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-08-match-arms-different-types/src/main.rs:here}}
```

O tipo de `guess` nesse código teria de ser um inteiro _e_ uma string,
e Rust exige que `guess` tenha apenas um tipo. Então, o que `continue`
retorna? Como pudemos retornar um `u32` de um braço e ter outro braço
que termina com `continue` na Listagem 20-27?

Como você já deve ter imaginado, `continue` tem o valor `!`. Ou seja, quando Rust
calcula o tipo de `guess`, ele analisa ambos os braços do `match`: o primeiro
com um valor `u32` e o segundo com um valor `!`. Como `!` nunca pode ter um
valor, Rust decide que o tipo de `guess` é `u32`.

A forma formal de descrever esse comportamento é que expressões do tipo `!` podem
ser coercidas para qualquer outro tipo. Podemos encerrar esse braço do `match`
com `continue` porque `continue` não retorna um valor; em vez disso, ele
transfere o controle de volta para o início do loop, portanto, no caso `Err`,
nunca atribuímos um valor a `guess`.

O tipo never também é útil com a macro `panic!`. Lembre-se da função `unwrap`,
que chamamos em valores `Option<T>` para produzir um valor ou gerar um panic, com
esta definição:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-09-unwrap-definition/src/lib.rs:here}}
```

Nesse código, acontece o mesmo que no `match` da Listagem 20-27: Rust
vê que `val` tem tipo `T` e `panic!` tem tipo `!`, então o resultado
da expressão `match` como um todo é `T`. Esse código funciona porque `panic!`
não produz um valor; ele encerra o programa. No caso `None`, não estaremos
retornando um valor de `unwrap`, portanto esse código é válido.

Uma expressão final que possui o tipo `!` é um loop:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-10-loop-returns-never/src/main.rs:here}}
```

Aqui, o loop nunca termina, então `!` é o valor da expressão. No entanto, isso
não seria verdade se incluíssemos um `break`, porque o loop terminaria
ao chegar ao `break`.

### Tipos de Tamanho Dinâmico e a Trait `Sized`

Rust precisa saber alguns detalhes sobre seus tipos, como quanto espaço deve ser
alocado para um valor de um tipo específico. Isso deixa um canto do sistema de
tipos um pouco confuso no início: o conceito de _tipos de tamanho dinâmico_.
Às vezes chamados de _DSTs_ ou _unsized types_, esses tipos nos permitem escrever
código usando valores cujo tamanho só podemos saber em tempo de execução.

Vamos nos aprofundar nos detalhes de um tipo de tamanho dinâmico chamado `str`, que
temos usado ao longo do livro. Isso mesmo: não `&str`, mas `str` por
si só, é um DST. Em muitos casos, como ao armazenar um texto inserido pelo
usuário, não podemos saber o tamanho da string até o tempo de execução. Isso
significa que não podemos criar uma variável do tipo `str`, nem aceitar um
argumento do tipo `str`. Considere o código a seguir, que não funciona:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-11-cant-create-str/src/main.rs:here}}
```

Rust precisa saber quanta memória deve ser alocada para qualquer valor de um
determinado tipo, e todos os valores de um mesmo tipo devem usar a mesma
quantidade de memória. Se Rust nos permitisse escrever esse código, esses dois
valores `str` precisariam ocupar a mesma quantidade de espaço. Mas eles têm
comprimentos diferentes: `s1` precisa de 12 bytes de armazenamento, e `s2`, de
15. Por isso, não é possível criar uma variável armazenando um tipo de tamanho
dinâmico.

Então, o que fazemos? Nesse caso, você já sabe a resposta: fazemos com que o tipo
de `s1` e `s2` seja string slice (`&str`), em vez de `str`. Lembre-se da
seção [“String Slices”][string-slices]<!-- ignore -->, no Capítulo 4: a
estrutura de dados slice armazena apenas a posição inicial e o comprimento do
slice. Portanto, embora `&T` seja um único valor que armazena o endereço de
memória de onde `T` está localizado, uma string slice tem _dois_ valores: o
endereço do `str` e seu comprimento. Assim, podemos saber o tamanho de uma
string slice em tempo de compilação: ele é o dobro do tamanho de um `usize`. Ou
seja, sempre sabemos o tamanho de uma string slice, não importa quão longa seja
a string à qual ela se refere. Em geral, é assim que tipos de tamanho dinâmico
são usados em Rust: eles carregam um pouco extra de metadados que armazena o
tamanho da informação dinâmica. A regra de ouro para tipos de tamanho dinâmico
é que devemos sempre colocar valores desses tipos atrás de algum tipo de
ponteiro.

Podemos combinar `str` com vários tipos de ponteiro, por exemplo, `Box<str>` ou
`Rc<str>`. Na verdade, você já viu isso antes, mas com outro tipo de tamanho
dinâmico: traits. Toda trait é um tipo de tamanho dinâmico ao qual podemos nos
referir usando o nome da trait. Na seção [“Usando Objetos de Trait para Abstrair
Comportamento Compartilhado”][using-trait-objects-to-abstract-over-shared-behavior]<!--
ignore --> do Capítulo 18, mencionamos que, para usar traits como trait
objects, devemos colocá-las atrás de um ponteiro, como `&dyn Trait` ou `Box<dyn
Trait>` (`Rc<dyn Trait>` também funcionaria).

Para trabalhar com DSTs, Rust fornece a trait `Sized` para determinar se o
tamanho de um tipo é conhecido em tempo de compilação. Essa trait é
implementada automaticamente para tudo cujo tamanho é conhecido em tempo de
compilação. Além disso, Rust adiciona implicitamente um limite `Sized` a cada
função genérica. Ou seja, uma definição de função genérica como esta:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-12-generic-fn-definition/src/lib.rs}}
```

na verdade é tratada como se tivéssemos escrito isto:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-13-generic-implicit-sized-bound/src/lib.rs}}
```

Por padrão, funções genéricas funcionarão apenas com tipos que tenham tamanho conhecido em
tempo de compilação. No entanto, você pode usar a seguinte sintaxe especial para relaxar essa
restrição:

```rust,ignore
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-14-generic-maybe-sized/src/lib.rs}}
```

Um trait bound `?Sized` significa “`T` pode ou não ser `Sized`”, e essa
notação substitui o comportamento padrão segundo o qual tipos genéricos precisam
ter tamanho conhecido em tempo de compilação. A sintaxe `?Trait` com esse
significado só está disponível para `Sized`, e não para outras traits.

Observe também que mudamos o tipo do parâmetro `t` de `T` para `&T`.
Como o tipo pode não ser `Sized`, precisamos usá-lo atrás de algum tipo de
ponteiro. Neste caso, escolhemos uma referência.

A seguir falaremos sobre funções e closures!

[encapsulation-that-hides-implementation-details]: ch18-01-what-is-oo.html#encapsulation-that-hides-implementation-details
[string-slices]: ch04-03-slices.html#string-slices
[the-match-control-flow-construct]: ch06-02-match.html#the-match-control-flow-construct
[using-trait-objects-to-abstract-over-shared-behavior]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior
[newtype]: ch20-02-advanced-traits.html#implementing-external-traits-with-the-newtype-pattern
