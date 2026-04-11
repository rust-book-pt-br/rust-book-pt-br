## Um exemplo de programa usando estruturas

Para entender quando podemos querer usar structs, vamos escrever um programa que
calcula a área de um retângulo. Começaremos usando variáveis ​​únicas e
em seguida, refatore o programa até usarmos structs.

Vamos fazer um novo projeto binário com Cargo chamado _retângulos_ que levará
a largura e a altura de um retângulo especificado em pixels e calcule a área
do retângulo. A Listagem 5-8 mostra um programa curto com uma maneira de fazer
exatamente isso em _src/main.rs_ do nosso projeto.

<Listing number="5-8" file-name="src/main.rs" caption="Calculating the area of a rectangle specified by separate width and height variables">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-08/src/main.rs:all}}
```

</Listing>

Agora, execute este programa usando `cargo run`:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-08/output.txt}}
```

Este código consegue descobrir a área do retângulo chamando o método
`area` funciona com cada dimensão, mas podemos fazer mais para deixar esse código claro
e legível.

O problema com este código é evidente na assinatura de `area`:

```rust,ignore
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-08/src/main.rs:here}}
```

A função `area` deve calcular a área de um retângulo, mas o
função que escrevemos tem dois parâmetros e não está claro em nenhum lugar do nosso
programa que os parâmetros estão relacionados. Seria mais legível e mais
gerenciável para agrupar largura e altura. Já discutimos uma maneira
podemos fazer isso na seção [“The Tuple Type”][the-tuple-type]<!-- ignore -->
do Capítulo 3: usando tuplas.

### Refatorando com Tuplas

A Listagem 5.9 mostra outra versão do nosso programa que usa tuplas.

<Listing number="5-9" file-name="src/main.rs" caption="Specifying the width and height of the rectangle with a tuple">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-09/src/main.rs}}
```

</Listing>

De certa forma, este programa é melhor. As tuplas nos permitem adicionar um pouco de estrutura e
agora estamos passando apenas um argumento. Mas por outro lado, esta versão é menos
claro: as tuplas não nomeiam seus elementos, então temos que indexar nas partes de
a tupla, tornando nosso cálculo menos óbvio.

Misturar largura e altura não importaria para o cálculo da área, mas se
queremos desenhar o retângulo na tela, isso faria diferença! Teríamos que
tenha em mente que `width` é o índice da tupla `0` e `height` é a tupla
índice `1`. Isso seria ainda mais difícil para outra pessoa descobrir e manter
importaria se eles usassem nosso código. Porque não transmitimos o significado de
nossos dados em nosso código, agora é mais fácil introduzir erros.

<!-- Old headings. Do not remove or links may break. -->

<a id="refactoring-with-structs-adding-more-meaning"></a>

### Refatorando com Estruturas

Usamos estruturas para adicionar significado rotulando os dados. Podemos transformar a tupla
estamos usando em uma estrutura com um nome para o todo, bem como nomes para o
peças, conforme mostrado na Listagem 5-10.

<Listing number="5-10" file-name="src/main.rs" caption="Defining a `Rectangle` struct">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-10/src/main.rs}}
```

</Listing>

Aqui, definimos uma estrutura e a nomeamos `Rectangle`. Dentro do cacheado
colchetes, definimos os campos como `width` e `height`, ambos com
digite `u32`. Então, em `main`, criamos uma instância específica de `Rectangle`
que tem uma largura de `30` e uma altura de `50`.

Nossa função `area` agora está definida com um parâmetro, que nomeamos
`rectangle`, cujo tipo é um empréstimo imutável de uma estrutura `Rectangle`
exemplo. Conforme mencionado no Capítulo 4, queremos emprestar a struct em vez de
apropriar-se dele. Dessa forma, `main` mantém sua propriedade e pode continuar
usando `rect1`, que é a razão pela qual usamos `&` na assinatura da função e
onde chamamos a função.

A função `area` acessa os campos `width` e `height` do `Rectangle`
instância (observe que acessar campos de uma instância de struct emprestada não
mova os valores dos campos, e é por isso que você costuma ver empréstimos de estruturas). Nosso
assinatura de função para `area` agora diz exatamente o que queremos dizer: Calcular a área
de `Rectangle`, usando seus campos `width` e `height`. Isto transmite que o
largura e altura estão relacionadas entre si e dá nomes descritivos aos
os valores em vez de usar os valores de índice de tupla de `0` e `1`. Este é um
vencer pela clareza.

<!-- Old headings. Do not remove or links may break. -->

<a id="adding-useful-functionality-with-derived-traits"></a>

### Adicionando funcionalidade com características derivadas

Seria útil poder imprimir uma instância de `Rectangle` enquanto estamos
depurando nosso programa e vendo os valores de todos os seus campos. Listando 5 a 11 tentativas
usando o [`println!` macro][println]<!-- ignore --> como usamos em
capítulos anteriores. Isso não funcionará, no entanto.

<Listing number="5-11" file-name="src/main.rs" caption="Attempting to print a `Rectangle` instance">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-11/src/main.rs}}
```

</Listing>

Quando compilamos este código, obtemos um erro com esta mensagem principal:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-11/output.txt:3}}
```

A macro `println!` pode fazer vários tipos de formatação e, por padrão, a curvada
colchetes dizem a `println!` para usar a formatação conhecida como `Display`: saída pretendida
para consumo direto do usuário final. Os tipos primitivos que vimos até agora
implemente `Display` por padrão porque só há uma maneira de mostrar
um `1` ou qualquer outro tipo primitivo para um usuário. Mas com estruturas, o caminho
`println!` deve formatar a saída é menos clara porque há mais
possibilidades de exibição: você quer vírgulas ou não? Você quer imprimir o
colchetes? Todos os campos devem ser mostrados? Devido a esta ambiguidade, Rust
não tenta adivinhar o que queremos e as estruturas não têm uma opção fornecida
implementação de `Display` para usar com `println!` e o espaço reservado `{}`.

Se continuarmos lendo os erros, encontraremos esta nota útil:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-11/output.txt:9:10}}
```

Vamos tentar! A chamada da macro `println!` agora se parecerá com `println!("rect1 is
{rect1:?}");`. Putting the specifier `:?` dentro das chaves indica
`println!` queremos usar um formato de saída chamado `Debug`. A característica `Debug`
nos permite imprimir nossa estrutura de uma forma que seja útil para desenvolvedores, para que
podemos ver seu valor enquanto depuramos nosso código.

Compile o código com esta alteração. Droga! Ainda recebemos um erro:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/output-only-01-debug/output.txt:3}}
```

Mas, novamente, o compilador nos dá uma nota útil:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/output-only-01-debug/output.txt:9:10}}
```

Rust _inclui_ funcionalidade para imprimir informações de depuração, mas nós
temos que optar explicitamente por disponibilizar essa funcionalidade para nossa estrutura.
Para fazer isso, adicionamos o atributo externo `#[derive(Debug)]` logo antes do
definição de struct, conforme mostrado na Listagem 5-12.

<Listing number="5-12" file-name="src/main.rs" caption="Adding the attribute to derive the `Debug` trait and printing the `Rectangle` instance using debug formatting">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-12/src/main.rs}}
```

</Listing>

Agora, quando executarmos o programa, não obteremos nenhum erro e veremos o
seguinte saída:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-12/output.txt}}
```

Legal! Não é a saída mais bonita, mas mostra os valores de todos os campos
para este caso, o que definitivamente ajudaria durante a depuração. Quando tivermos
estruturas maiores, é útil ter uma saída um pouco mais fácil de ler; em
nesses casos, podemos usar `{:#?}` em vez de `{:?}` na string `println!`. Em
neste exemplo, usar o estilo `{:#?}` produzirá o seguinte:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/output-only-02-pretty-debug/output.txt}}
```

Outra maneira de imprimir um valor usando o formato `Debug` é usar o [`dbg!`
macro][dbg]<!-- ignore -->, que se apropria de uma expressão (em oposição
para `println!`, que leva uma referência), imprime o arquivo e o número da linha de
onde essa chamada de macro `dbg!` ocorre em seu código junto com o valor resultante
dessa expressão e retorna a propriedade do valor.

> Nota: Chamar a macro `dbg!` imprime no fluxo do console de erros padrão
> (`stderr`), em oposição a `println!`, que imprime na saída padrão
> fluxo do console (`stdout`). Falaremos mais sobre `stderr` e `stdout` no
> [Seção “Redirecionando Erros para Erro Padrão” no Capítulo
> 12][err]<!-- ignore -->.

Aqui está um exemplo em que estamos interessados ​​no valor atribuído ao
Campo `width`, bem como o valor de toda a estrutura em `rect1`:

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-05-dbg-macro/src/main.rs}}
```

Podemos colocar `dbg!` em torno da expressão `30 * scale` e, porque `dbg!`
retorna a propriedade do valor da expressão, o campo `width` receberá o
mesmo valor como se não tivéssemos a chamada `dbg!` lá. Não queremos que `dbg!`
assuma a propriedade de `rect1`, então usaremos uma referência a `rect1` na próxima chamada.
Esta é a aparência do resultado deste exemplo:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/no-listing-05-dbg-macro/output.txt}}
```

Podemos ver que o primeiro bit de saída veio da linha 10 _src/main.rs_, onde estamos
depurando a expressão `30 * scale`, e seu valor resultante é `60` (o
A formatação `Debug` implementada para números inteiros é imprimir apenas seu valor). O
`dbg!` chamada na linha 14 de _src/main.rs_ gera o valor de `&rect1`, que é
a estrutura `Rectangle`. Esta saída usa a bonita formatação `Debug` do
`Rectangle` digite. A macro `dbg!` pode ser muito útil quando você está tentando
descubra o que seu código está fazendo!

Além da característica `Debug`, Rust forneceu uma série de características para nós
para usar com o atributo `derive` que pode adicionar um comportamento útil ao nosso costume
tipos. Essas características e seus comportamentos estão listados no [Apêndice C][app-c]<!--
ignorar -->. Abordaremos como implementar essas características com comportamento personalizado como
bem como como criar suas próprias características no Capítulo 10. Existem também muitos
atributos diferentes de `derive`; para obter mais informações, consulte [os “Atributos”
seção da Referência de Ferrugem][attributes].

Nossa função `area` é muito específica: ela calcula apenas a área de retângulos.
Seria útil vincular esse comportamento mais de perto à nossa estrutura `Rectangle`
porque não funcionará com nenhum outro tipo. Vejamos como podemos continuar a
refatore este código transformando a função `area` em um método `area`
definido em nosso tipo `Rectangle`.

[the-tuple-type]: ch03-02-data-types.html#the-tuple-type
[app-c]: appendix-03-derivable-traits.md
[println]: ../std/macro.println.html
[dbg]: ../std/macro.dbg.html
[err]: ch12-06-writing-to-stderr-instead-of-stdout.html
[attributes]: ../reference/attributes.html
