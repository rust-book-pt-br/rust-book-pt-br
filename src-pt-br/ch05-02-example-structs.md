## Um Exemplo de Programa Usando Structs

Para entender quando pode fazer sentido usar structs, vamos escrever um
programa que calcula a área de um retângulo. Começaremos usando variáveis
soltas e depois vamos refatorar o programa até chegarmos ao uso de structs.

Vamos criar um novo projeto binário com Cargo chamado _rectangles_, que
receberá a largura e a altura de um retângulo, especificadas em pixels, e
calculará sua área. A Listagem 5-8 mostra um pequeno programa com uma forma de
fazer exatamente isso em _src/main.rs_.

<Listing number="5-8" file-name="src/main.rs" caption="Calculando a área de um retângulo especificado por variáveis separadas de largura e altura">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-08/src/main.rs:all}}
```

</Listing>

Agora, execute esse programa com `cargo run`:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-08/output.txt}}
```

Esse código consegue descobrir a área do retângulo chamando a função `area`
com cada dimensão, mas ainda podemos fazer mais para que ele fique claro e
legível.

O problema com esse código fica evidente na assinatura de `area`:

```rust,ignore
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-08/src/main.rs:here}}
```

A função `area` deveria calcular a área de um único retângulo, mas a função
que escrevemos recebe dois parâmetros, e em nenhum ponto do programa fica
claro que eles estão relacionados. Seria mais legível e mais fácil de manter
agrupar largura e altura. Já discutimos uma forma de fazer isso na seção
[“O Tipo Tupla”][the-tuple-type]<!-- ignore --> do Capítulo 3: usando tuplas.

### Refatorando com Tuplas

A Listagem 5-9 mostra outra versão do programa usando tuplas.

<Listing number="5-9" file-name="src/main.rs" caption="Especificando a largura e a altura do retângulo com uma tupla">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-09/src/main.rs}}
```

</Listing>

Em certo sentido, esse programa é melhor. As tuplas nos permitem adicionar um
pouco de estrutura, e agora estamos passando apenas um argumento. Mas, por
outro lado, essa versão é menos clara: tuplas não dão nome aos seus elementos,
então precisamos acessar as partes por índice, o que torna o cálculo menos
óbvio.

Confundir largura e altura não faria diferença para o cálculo da área, mas,
se quisermos desenhar o retângulo na tela, isso passaria a importar! Teríamos
de lembrar que `width` corresponde ao índice `0` da tupla e `height` ao índice
`1`. Isso seria ainda mais difícil para outra pessoa descobrir e manter em
mente ao usar nosso código. Como não expressamos o significado desses dados no
próprio código, fica mais fácil introduzir erros.

<!-- Old headings. Do not remove or links may break. -->

<a id="refactoring-with-structs-adding-more-meaning"></a>

### Refatorando com Structs

Usamos structs para adicionar significado ao rotular os dados. Podemos
transformar a tupla que estamos usando em uma struct com um nome para o todo e
nomes para cada parte, como mostra a Listagem 5-10.

<Listing number="5-10" file-name="src/main.rs" caption="Definindo uma struct `Rectangle`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-10/src/main.rs}}
```

</Listing>

Aqui, definimos uma struct chamada `Rectangle`. Dentro das chaves, definimos os
campos `width` e `height`, ambos do tipo `u32`. Depois, em `main`, criamos uma
instância específica de `Rectangle` com largura `30` e altura `50`.

Nossa função `area` agora é definida com um único parâmetro, que chamamos de
`rectangle` e cujo tipo é um empréstimo imutável de uma instância da struct
`Rectangle`. Como mencionamos no Capítulo 4, queremos tomar emprestada a
struct, em vez de assumir seu ownership. Assim, `main` continua com o
ownership e pode seguir usando `rect1`; é por isso que usamos `&` tanto na
assinatura da função quanto no ponto em que a chamamos.

A função `area` acessa os campos `width` e `height` da instância `Rectangle`.
Observe que acessar campos de uma instância de struct emprestada não move os
valores dos campos, e é por isso que você verá com frequência structs sendo
emprestadas. Nossa assinatura de `area` agora expressa exatamente o que
queremos dizer: calcular a área de um `Rectangle` usando seus campos `width` e
`height`. Isso deixa claro que largura e altura estão relacionadas e dá nomes
descritivos aos valores, em vez de usar os índices `0` e `1` de uma tupla. É
um ganho real de clareza.

<!-- Old headings. Do not remove or links may break. -->

<a id="adding-useful-functionality-with-derived-traits"></a>

### Adicionando Funcionalidade com Traits Derivadas

Seria útil poder imprimir uma instância de `Rectangle` enquanto estivermos
depurando o programa, para enxergar os valores de todos os seus campos. A
Listagem 5-11 tenta fazer isso usando a macro [`println!`][println]<!-- ignore
-->, como já fizemos em capítulos anteriores. Mas isso não vai funcionar.

<Listing number="5-11" file-name="src/main.rs" caption="Tentando imprimir uma instância de `Rectangle`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-11/src/main.rs}}
```

</Listing>

Quando compilamos esse código, recebemos um erro com esta mensagem principal:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-11/output.txt:3}}
```

A macro `println!` pode fazer muitos tipos de formatação e, por padrão, as
chaves informam ao `println!` que ele deve usar a formatação conhecida como
`Display`, isto é, uma saída pensada para consumo direto por usuários finais.
Os tipos primitivos que vimos até agora implementam `Display` por padrão,
porque existe basicamente uma única forma razoável de mostrar um `1`, por
exemplo. Mas, com structs, a forma como `println!` deveria formatar a saída é
menos óbvia, porque há várias possibilidades: você quer vírgulas ou não?
Quer imprimir as chaves? Todos os campos devem aparecer? Por causa dessa
ambiguidade, o Rust não tenta adivinhar o que queremos, e structs não recebem
uma implementação padrão de `Display` para ser usada com `println!` e o
placeholder `{}`.

Se continuarmos lendo as mensagens de erro, encontraremos esta observação útil:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-11/output.txt:9:10}}
```

Vamos tentar! A chamada da macro `println!` agora ficará assim:
`println!("rect1 is {rect1:?}");`. Colocar o especificador `:?` dentro das
chaves informa ao `println!` que queremos usar um formato de saída chamado
`Debug`. A trait `Debug` nos permite imprimir a struct de uma maneira útil
para desenvolvedores, para que possamos inspecionar seu valor enquanto
depuramos o código.

Compile o código com essa mudança. Droga! Ainda recebemos um erro:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/output-only-01-debug/output.txt:3}}
```

Mas, de novo, o compilador nos dá uma observação útil:

```text
{{#include ../listings/ch05-using-structs-to-structure-related-data/output-only-01-debug/output.txt:9:10}}
```

O Rust _de fato_ oferece funcionalidade para imprimir informações de depuração,
mas precisamos habilitá-la explicitamente para nossa struct. Para isso,
adicionamos o atributo externo `#[derive(Debug)]` logo antes da definição da
struct, como mostra a Listagem 5-12.

<Listing number="5-12" file-name="src/main.rs" caption="Adicionando o atributo para derivar a trait `Debug` e imprimindo a instância de `Rectangle` com formatação de depuração">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-12/src/main.rs}}
```

</Listing>

Agora, quando executarmos o programa, não veremos mais erros e obteremos a
seguinte saída:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/listing-05-12/output.txt}}
```

Ótimo! Não é a saída mais bonita do mundo, mas ela mostra os valores de todos
os campos dessa instância, o que certamente ajuda durante a depuração. Quando
temos structs maiores, é útil contar com uma saída um pouco mais fácil de ler;
nesses casos, podemos usar `{:#?}` em vez de `{:?}` na string de `println!`.
Neste exemplo, usar o estilo `{:#?}` produz a seguinte saída:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/output-only-02-pretty-debug/output.txt}}
```

Outra forma de imprimir um valor usando o formato `Debug` é com a macro
[`dbg!`][dbg]<!-- ignore -->, que assume o ownership de uma expressão
(diferentemente de `println!`, que recebe uma referência), imprime o arquivo e
o número da linha em que a chamada à macro `dbg!` ocorre, junto com o valor
resultante da expressão, e então devolve o ownership desse valor.

> Observação: a macro `dbg!` imprime na saída de erro padrão (`stderr`), ao
> contrário de `println!`, que imprime na saída padrão (`stdout`). Vamos falar
> mais sobre `stderr` e `stdout` na seção [“Redirecionando Erros para a Saída
> de Erro Padrão”][err]<!-- ignore --> do Capítulo 12.

Aqui está um exemplo em que nos interessa tanto o valor atribuído ao campo
`width` quanto o valor da struct inteira em `rect1`:

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-05-dbg-macro/src/main.rs}}
```

Podemos colocar `dbg!` em volta da expressão `30 * scale` e, como `dbg!`
devolve o ownership do valor da expressão, o campo `width` receberá exatamente
o mesmo valor que receberia se a chamada a `dbg!` não estivesse ali. Não
queremos que `dbg!` assuma o ownership de `rect1`, então usamos uma referência
a `rect1` na chamada seguinte. A saída desse exemplo é assim:

```console
{{#include ../listings/ch05-using-structs-to-structure-related-data/no-listing-05-dbg-macro/output.txt}}
```

Podemos ver que a primeira parte da saída veio da linha 10 de _src/main.rs_,
onde estamos depurando a expressão `30 * scale`, e que o valor resultante é
`60` (a formatação `Debug` para inteiros imprime apenas o valor). A chamada a
`dbg!` na linha 14 de _src/main.rs_ imprime o valor de `&rect1`, que é a
struct `Rectangle`. Essa saída usa a versão mais legível da formatação
`Debug` para o tipo `Rectangle`. A macro `dbg!` pode ser realmente útil quando
você está tentando entender o que seu código está fazendo.

Além da trait `Debug`, o Rust fornece várias outras traits que podemos usar com
o atributo `derive` para adicionar comportamentos úteis aos nossos tipos
personalizados. Essas traits e seus comportamentos estão listados no
[Apêndice C][app-c]<!-- ignore -->. No Capítulo 10, veremos como implementar
essas traits com comportamento personalizado e também como criar suas próprias
traits. Há ainda muitos outros atributos além de `derive`; para mais
informações, veja a seção [“Attributes” da Referência do
Rust][attributes].

Nossa função `area` é muito específica: ela calcula apenas a área de
retângulos. Seria útil vincular esse comportamento mais de perto à nossa
struct `Rectangle`, já que ele não faz sentido para outros tipos. Vamos ver
como continuar refatorando esse código, transformando a função `area` em um
método `area` definido no tipo `Rectangle`.

[the-tuple-type]: ch03-02-data-types.html#the-tuple-type
[app-c]: appendix-03-derivable-traits.md
[println]: ../std/macro.println.html
[dbg]: ../std/macro.dbg.html
[err]: ch12-06-writing-to-stderr-instead-of-stdout.html
[attributes]: https://doc.rust-lang.org/reference/attributes.html
