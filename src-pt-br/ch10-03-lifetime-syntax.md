## Validando Referências com Tempos de Vida

Lifetimes são outro tipo de genérico que já usamos. Em vez de
do que garantir que um tipo tenha o comportamento que desejamos, as vidas garantem que
as referências são válidas enquanto precisarmos que sejam.

Um detalhe que não discutimos no [“Referências e
A seção Emprestando ”][references-and-borrowing]<!-- ignore --> no Capítulo 4 é
que toda referência em Rust tem uma vida útil, que é o escopo para o qual
essa referência é válida. Na maioria das vezes, as vidas são implícitas e inferidas,
assim como na maioria das vezes, os tipos são inferidos. Só somos obrigados a
anote tipos quando vários tipos forem possíveis. De maneira semelhante, devemos
anotar tempos de vida quando os tempos de vida das referências puderem ser relacionados em alguns
maneiras diferentes. Rust exige que anotemos os relacionamentos usando genéricos
parâmetros de vida útil para garantir que as referências reais usadas em tempo de execução serão
definitivamente será válido.

Anotar tempos de vida nem é um conceito na maioria das outras linguagens de programação
tenho, então isso vai parecer estranho. Embora não cubramos vidas em
na íntegra neste capítulo, discutiremos maneiras comuns que você pode encontrar
sintaxe vitalícia para que você possa se sentir confortável com o conceito.

<!-- Old headings. Do not remove or links may break. -->

<a id="preventing-dangling-references-with-lifetimes"></a>

### Referências pendentes

O principal objetivo das vidas é evitar referências pendentes, que, se
pudessem existir, faria com que um programa referenciasse dados diferentes dos
dados que se pretende referenciar. Considere o programa na Listagem 10-16, que
tem um escopo externo e um escopo interno.

<Listing number="10-16" caption="An attempt to use a reference whose value has gone out of scope">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-16/src/main.rs}}
```

</Listing>

> Nota: Os exemplos nas Listagens 10-16, 10-17 e 10-23 declaram variáveis
> sem dar-lhes um valor inicial, então o nome da variável existe no exterior
> escopo. À primeira vista, isso pode parecer estar em conflito com o fato de Rust ter
> sem valores nulos. No entanto, se tentarmos usar uma variável antes de atribuir-lhe um valor,
> obteremos um erro em tempo de compilação, o que mostra que de fato o Rust não permite
> valores nulos.

O escopo externo declara uma variável chamada `r` sem valor inicial, e o
o escopo interno declara uma variável chamada `x` com o valor inicial de `5`. Dentro
no escopo interno, tentamos definir o valor de `r` como uma referência a `x`.
Então, o escopo interno termina e tentamos imprimir o valor em `r`. Este código
não compilará, porque o valor ao qual `r` está se referindo saiu do escopo
antes de tentarmos usá-lo. Aqui está a mensagem de erro:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-16/output.txt}}
```

A mensagem de erro diz que a variável `x` “não dura o suficiente”. O
a razão é que `x` estará fora do escopo quando o escopo interno terminar na linha 7.
Mas `r` ainda é válido para o escopo externo; porque seu escopo é maior, dizemos
que “vive mais”. Se Rust permitisse que esse código funcionasse, `r` seria
referenciando a memória que foi desalocada quando `x` saiu do escopo e
qualquer coisa que tentássemos fazer com `r` não funcionaria corretamente. Então, como é que a ferrugem
determinar que este código é inválido? Ele usa um verificador de empréstimo.

### O verificador de empréstimos

O compilador Rust possui um _verificador de empréstimo_ que compara escopos para determinar
se todos os empréstimos são válidos. A Listagem 10-17 mostra o mesmo código da Listagem
10-16, mas com anotações mostrando os tempos de vida das variáveis.

<Listing number="10-17" caption="Annotations of the lifetimes of `r` and `x`, named `'a` and `'b`, respectively">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-17/src/main.rs}}
```

</Listing>

Aqui, anotamos o tempo de vida de `r` com `'a` e o tempo de vida de `x`
com `'b`. Como você pode ver, o bloco interno `'b` é muito menor que o bloco externo
`'a` bloco vitalício. Em tempo de compilação, Rust compara o tamanho dos dois
vidas e vê que `r` tem uma vida útil de `'a` mas que se refere à memória
com uma vida inteira de `'b`. O programa foi rejeitado porque `'b` é menor que
`'a`: O assunto da referência não dura tanto quanto a referência.

A Listagem 10-18 corrige o código para que ele não tenha uma referência pendente e
ele compila sem erros.

<Listing number="10-18" caption="A valid reference because the data has a longer lifetime than the reference">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-18/src/main.rs}}
```

</Listing>

Aqui, `x` tem o tempo de vida `'b`, que neste caso é maior que `'a`. Esse
significa que `r` pode referenciar `x` porque Rust sabe que a referência em `r` irá
sempre será válido enquanto `x` for válido.

Agora que você sabe onde estão os tempos de vida das referências e como o Rust analisa
vidas úteis para garantir que as referências serão sempre válidas, vamos explorar
tempos de vida em parâmetros de função e valores de retorno.

### Vidas genéricas em funções

Escreveremos uma função que retorna a maior das duas fatias de string. Esse
A função pegará duas fatias de string e retornará uma única fatia de string. Depois
implementamos a função `longest`, o código na Listagem 10-19 deve
imprima `The longest string is abcd`.

<Listing number="10-19" file-name="src/main.rs" caption="A `main` function that calls the `longest` function to find the longer of two string slices">

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-19/src/main.rs}}
```

</Listing>

Observe que queremos que a função receba fatias de string, que são referências,
em vez de strings, porque não queremos que a função `longest` assuma
propriedade de seus parâmetros. Consulte [“String Slices como
Parâmetros”][string-slices-as-parameters]<!-- ignore --> no Capítulo 4 para mais
discussão sobre por que os parâmetros que usamos na Listagem 10-19 são aqueles que
querer.

Se tentarmos implementar a função `longest` conforme mostrado na Listagem 10-20,
não compilará.

<Listing number="10-20" file-name="src/main.rs" caption="An implementation of the `longest` function that returns the longer of two string slices but does not yet compile">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-20/src/main.rs:here}}
```

</Listing>

Em vez disso, obtemos o seguinte erro que fala sobre tempos de vida:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-20/output.txt}}
```

O texto de ajuda revela que o tipo de retorno precisa de um parâmetro genérico de vida útil
nele porque Rust não consegue dizer se a referência retornada se refere a
`x` ou `y`. Na verdade, também não sabemos, porque o bloco `if` no corpo
desta função retorna uma referência para `x` e o bloco `else` retorna um
referência a `y`!

Quando definimos esta função, não sabemos os valores concretos que irão
ser passado para esta função, então não sabemos se o caso `if` ou o caso
`else` caso será executado. Também não sabemos a vida útil concreta do
referências que serão passadas, então não podemos olhar para os escopos como fizemos em
Listagens 10-17 e 10-18 para determinar se a referência que retornamos será
seja sempre válido. O verificador de empréstimo também não pode determinar isso, porque
não sabe como os tempos de vida de `x` e `y` se relacionam com o tempo de vida do
valor de retorno. Para corrigir esse erro, adicionaremos parâmetros genéricos de vida útil que
definir o relacionamento entre as referências para que o verificador de empréstimo possa
realizar sua análise.

### Sintaxe de anotação vitalícia

As anotações vitalícias não alteram a duração de qualquer uma das referências. Em vez de,
eles descrevem as relações dos tempos de vida de múltiplas referências para cada
outro sem afetar a vida útil. Assim como as funções podem aceitar qualquer tipo
quando a assinatura especifica um parâmetro de tipo genérico, as funções podem aceitar
referências com qualquer tempo de vida especificando um parâmetro de tempo de vida genérico.

As anotações vitalícias têm uma sintaxe um pouco incomum: os nomes das anotações vitalícias
os parâmetros devem começar com um apóstrofo (`'`) e geralmente estão todos em letras minúsculas
e muito curtos, como tipos genéricos. A maioria das pessoas usa o nome `'a` para o primeiro
anotação vitalícia. Colocamos anotações de parâmetro de vida útil após `&` de um
referência, usando um espaço para separar a anotação do tipo da referência.

Aqui estão alguns exemplos: uma referência a um `i32` sem um parâmetro de tempo de vida, um
referência a um `i32` que possui um parâmetro de vida útil chamado `'a` e um parâmetro mutável
referência a um `i32` que também tem o tempo de vida `'a`:

```rust,ignore
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

Uma anotação vitalícia por si só não tem muito significado, porque o
anotações têm como objetivo informar ao Rust como os parâmetros genéricos de vida de vários
referências se relacionam entre si. Vamos examinar como as anotações vitalícias
relacionam-se entre si no contexto da função `longest`.

<!-- Old headings. Do not remove or links may break. -->

<a id="lifetime-annotations-in-function-signatures"></a>

### Em assinaturas de função

Para usar anotações vitalícias em assinaturas de funções, precisamos declarar o
parâmetros genéricos de vida útil entre colchetes angulares entre o nome da função e
a lista de parâmetros, assim como fizemos com parâmetros de tipo genérico.

Queremos que a assinatura expresse a seguinte restrição: O valor retornado
a referência será válida desde que ambos os parâmetros sejam válidos. Isso é
a relação entre a vida útil dos parâmetros e o valor de retorno.
Nomearemos o tempo de vida como `'a` e depois o adicionaremos a cada referência, conforme mostrado em
Listagem 10-21.

<Listing number="10-21" file-name="src/main.rs" caption="The `longest` function definition specifying that all the references in the signature must have the same lifetime `'a`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-21/src/main.rs:here}}
```

</Listing>

Este código deve compilar e produzir o resultado que desejamos quando o usamos com o
`main` na Listagem 10-19.

A assinatura da função agora informa ao Rust que durante algum tempo de vida `'a`, a função
leva dois parâmetros, sendo que ambos são fatias de string que vivem pelo menos como
contanto que seja vitalício `'a`. A assinatura da função também informa ao Rust que a string
a fatia retornada da função durará pelo menos enquanto durar o tempo de vida `'a`.
Na prática, isso significa que o tempo de vida da referência retornada pelo
A função `longest` é igual ao menor dos tempos de vida dos valores
referido pelos argumentos da função. Esses relacionamentos são o que queremos
Rust para usar ao analisar este código.

Lembre-se, quando especificamos os parâmetros de tempo de vida nesta assinatura de função,
não estamos alterando o tempo de vida de nenhum valor passado ou retornado. Em vez de,
estamos especificando que o verificador de empréstimo deve rejeitar quaisquer valores que não
aderir a essas restrições. Observe que a função `longest` não precisa
sabemos exatamente quanto tempo `x` e `y` viverão, apenas que algum escopo pode ser
substituído por `'a` que irá satisfazer esta assinatura.

Ao anotar tempos de vida em funções, as anotações vão para a função
assinatura, não no corpo da função. As anotações vitalícias tornam-se parte
o contrato da função, bem como os tipos na assinatura. Tendo
assinaturas de função contêm o contrato vitalício significa a análise do Rust
compilador pode ser mais simples. Se houver um problema com a forma como uma função é
anotado ou a forma como é chamado, os erros do compilador podem apontar para a parte do
nosso código e as restrições com mais precisão. Se, em vez disso, o compilador Rust
fizemos mais inferências sobre o que pretendíamos com as relações das vidas
ser, o compilador só poderá apontar para um uso de nosso código em muitas etapas
longe da causa do problema.

Quando passamos referências concretas para `longest`, o tempo de vida concreto que é
substituído por `'a` é a parte do escopo de `x` que se sobrepõe ao
escopo de `y`. Em outras palavras, o tempo de vida genérico `'a` obterá o concreto
tempo de vida que é igual ao menor dos tempos de vida de `x` e `y`. Porque
anotamos a referência retornada com o mesmo parâmetro de vida útil `'a`,
a referência retornada também será válida para o comprimento do menor dos
vidas úteis de `x` e `y`.

Vejamos como as anotações vitalícias restringem a função `longest` por
passando referências que têm diferentes tempos de vida concretos. A Listagem 10-22 é
um exemplo direto.

<Listing number="10-22" file-name="src/main.rs" caption="Using the `longest` function with references to `String` values that have different concrete lifetimes">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-22/src/main.rs:here}}
```

</Listing>

Neste exemplo, `string1` é válido até o final do escopo externo, `string2`
é válido até o final do escopo interno e `result` faz referência a algo
isso é válido até o final do escopo interno. Execute este código e você verá
que o verificador de empréstimo aprova; ele irá compilar e imprimir `A string mais longa
é uma string longa é longa`.

A seguir, vamos tentar um exemplo que mostra que o tempo de vida da referência em
`result` deve ser o menor tempo de vida dos dois argumentos. Nós moveremos o
declaração da variável `result` fora do escopo interno, mas deixe o
atribuição do valor à variável `result` dentro do escopo com
`string2`. Então, moveremos o `println!` que usa `result` para fora do
escopo interno, após o término do escopo interno. O código na Listagem 10-23 irá
não compilar.

<Listing number="10-23" file-name="src/main.rs" caption="Attempting to use `result` after `string2` has gone out of scope">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-23/src/main.rs:here}}
```

</Listing>

Quando tentamos compilar este código, obtemos este erro:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-23/output.txt}}
```

O erro mostra que para `result` ser válido para a instrução `println!`,
`string2` precisaria ser válido até o final do escopo externo. A ferrugem sabe
isso porque anotamos os tempos de vida dos parâmetros da função e retornamos
valores usando o mesmo parâmetro de vida útil `'a`.

Como humanos, podemos olhar para este código e ver que `string1` é mais longo que
`string2` e, portanto, `result` conterá uma referência a `string1`.
Como `string1` ainda não saiu do escopo, uma referência a `string1` será
ainda será válido para a instrução `println!`. No entanto, o compilador não pode ver
que a referência é válida neste caso. Dissemos a Rust que a vida de
a referência retornada pela função `longest` é igual ao menor dos
a vida útil das referências transmitidas. Portanto, o verificador de empréstimo
não permite o código na Listagem 10.23 por possivelmente ter uma referência inválida.

Tente projetar mais experimentos que variem os valores e a vida útil do
referências passadas para a função `longest` e como a referência retornada
é usado. Faça hipóteses sobre se seus experimentos passarão ou não no
peça emprestado o verificador antes de compilar; então, verifique se você está certo!

<!-- Old headings. Do not remove or links may break. -->

<a id="thinking-in-terms-of-lifetimes"></a>

### Relacionamentos

A maneira como você precisa especificar os parâmetros de vida útil depende de qual é o seu
função está fazendo. Por exemplo, se alterássemos a implementação do
Função `longest` para sempre retornar o primeiro parâmetro em vez do mais longo
fatia de string, não precisaríamos especificar um tempo de vida no parâmetro `y`. O
o seguinte código será compilado:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-08-only-one-reference-with-lifetime/src/main.rs:here}}
```

</Listing>

Especificamos um parâmetro vitalício `'a` para o parâmetro `x` e o retorno
tipo, mas não para o parâmetro `y`, porque o tempo de vida de `y` não tem
qualquer relacionamento com o tempo de vida de `x` ou o valor de retorno.

Ao retornar uma referência de uma função, o parâmetro de tempo de vida para o
o tipo de retorno precisa corresponder ao parâmetro de vida útil de um dos parâmetros. Se
a referência retornada _não_ se refere a um dos parâmetros, ela deve se referir
para um valor criado dentro desta função. No entanto, isso seria uma pendência
referência porque o valor sairá do escopo no final da função.
Considere esta tentativa de implementação da função `longest` que não
compilar:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-09-unrelated-lifetime/src/main.rs:here}}
```

</Listing>

Aqui, embora tenhamos especificado um parâmetro vitalício `'a` para o retorno
tipo, esta implementação não será compilada porque o valor de retorno
a vida útil não está relacionada de forma alguma com a vida útil dos parâmetros. Aqui está o
mensagem de erro que recebemos:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-09-unrelated-lifetime/output.txt}}
```

O problema é que `result` sai do escopo e é limpo no final
da função `longest`. Também estamos tentando retornar uma referência para `result`
da função. Não há como especificar parâmetros de vida útil que
mudaria a referência pendente, e Rust não nos deixaria criar uma referência pendente
referência. Nesse caso, a melhor solução seria retornar um tipo de dados próprio
em vez de uma referência para que a função de chamada seja responsável por
limpando o valor.

Em última análise, a sintaxe do tempo de vida trata de conectar os tempos de vida de vários
parâmetros e valores de retorno de funções. Uma vez conectados, Rust tem
informações suficientes para permitir operações seguras de memória e proibir operações que
criaria ponteiros pendentes ou violaria a segurança da memória.

<!-- Old headings. Do not remove or links may break. -->

<a id="lifetime-annotations-in-struct-definitions"></a>

### Em definições de estrutura

Até agora, todas as estruturas que definimos possuem tipos de propriedade. Podemos definir estruturas
para conter referências, mas, nesse caso, precisaríamos adicionar uma vida inteira
anotação em cada referência na definição da estrutura. A Listagem 10-24 tem um
struct chamada `ImportantExcerpt` que contém uma fatia de string.

<Listing number="10-24" file-name="src/main.rs" caption="A struct that holds a reference, requiring a lifetime annotation">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-24/src/main.rs}}
```

</Listing>

Esta estrutura possui o único campo `part` que contém uma fatia de string, que é um
referência. Tal como acontece com os tipos de dados genéricos, declaramos o nome do genérico
parâmetro de vida útil entre colchetes angulares após o nome da estrutura para que
podemos usar o parâmetro tempo de vida no corpo da definição da estrutura. Esse
anotação significa que uma instância de `ImportantExcerpt` não pode sobreviver à referência
ele contém em seu campo `part`.

A função `main` aqui cria uma instância da estrutura `ImportantExcerpt`
que contém uma referência à primeira frase do `String` de propriedade do
variável `novel`. Os dados em `novel` existem antes de `ImportantExcerpt`
instância é criada. Além disso, `novel` não sai do escopo até depois
o `ImportantExcerpt` sai do escopo, então a referência no
`ImportantExcerpt` instância é válida.

### Elisão vitalícia

Você aprendeu que toda referência tem uma vida inteira e que você precisa especificar
parâmetros de vida útil para funções ou estruturas que usam referências. No entanto, nós
tinha uma função na Listagem 4-9, mostrada novamente na Listagem 10-25, que compilava
sem anotações vitalícias.

<Listing number="10-25" file-name="src/lib.rs" caption="A function we defined in Listing 4-9 that compiled without lifetime annotations, even though the parameter and return type are references">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-25/src/main.rs:here}}
```

</Listing>

A razão pela qual esta função é compilada sem anotações de tempo de vida é histórica:
Nas versões anteriores (pré-1.0) do Rust, este código não teria sido compilado, porque
cada referência precisava de um tempo de vida explícito. Naquela época, a função
a assinatura teria sido escrita assim:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &'a str {
```

Depois de escrever muitos códigos Rust, a equipe Rust descobriu que os programadores Rust
estavam inserindo as mesmas anotações de vida repetidamente, em particular
situações. Estas situações eram previsíveis e seguiam algumas regras determinísticas.
padrões. Os desenvolvedores programaram esses padrões no código do compilador para
que o verificador de empréstimo poderia inferir o tempo de vida nessas situações e
não precisaria de anotações explícitas.

Este pedaço da história do Rust é relevante porque é possível que mais
padrões determinísticos surgirão e serão adicionados ao compilador. No futuro,
ainda menos anotações vitalícias podem ser necessárias.

Os padrões programados na análise de referências do Rust são chamados de
_regras de elisão vitalícias_. Estas não são regras que os programadores devem seguir; eles são
um conjunto de casos particulares que o compilador irá considerar, e se o seu código
se encaixa nesses casos, você não precisa escrever os tempos de vida explicitamente.

As regras de elisão não fornecem inferência completa. Se ainda houver ambiguidade
sobre quais tempos de vida as referências têm depois que Rust aplica as regras, o
o compilador não adivinhará qual deveria ser o tempo de vida das referências restantes.
Em vez de adivinhar, o compilador apresentará um erro que você pode resolver
adicionando as anotações vitalícias.

Os tempos de vida nos parâmetros de função ou método são chamados de _tempos de vida de entrada_ e
os tempos de vida nos valores de retorno são chamados de _tempos de vida de saída_.

O compilador usa três regras para descobrir o tempo de vida das referências
quando não há anotações explícitas. A primeira regra se aplica à entrada
tempos de vida, e a segunda e terceira regras se aplicam aos tempos de vida de saída. Se o
compilador chega ao final das três regras e ainda há referências para
que não consegue calcular os tempos de vida, o compilador irá parar com um erro.
Essas regras se aplicam a definições `fn`, bem como a blocos `impl`.

A primeira regra é que o compilador atribua um parâmetro de tempo de vida a cada
parâmetro que é uma referência. Em outras palavras, uma função com um parâmetro
obtém um parâmetro de vida útil: `fn foo<'a>(x: &'a i32)`; uma função com dois
parâmetros obtém dois parâmetros de vida útil separados: `fn foo<'a, 'b>(x: &'a i32,
y: &'b i32)`; e assim por diante.

A segunda regra é que, se houver exatamente um parâmetro de tempo de vida de entrada, esse
tempo de vida é atribuído a todos os parâmetros de tempo de vida de saída: `fn foo<'a>(x: &'a i32)
-> &'a i32`.

A terceira regra é que, se houver vários parâmetros de tempo de vida de entrada, mas
um deles é `&self` ou `&mut self` porque este é um método, a vida útil de
`self` é atribuído a todos os parâmetros de vida útil de saída. Esta terceira regra faz
métodos muito mais agradáveis ​​de ler e escrever porque são necessários menos símbolos.

Vamos fingir que somos o compilador. Aplicaremos essas regras para descobrir o
tempos de vida das referências na assinatura da função `first_word` em
Listagem 10-25. A assinatura começa sem nenhum tempo de vida associado ao
referências:

```rust,ignore
fn first_word(s: &str) -> &str {
```

Então, o compilador aplica a primeira regra, que especifica que cada parâmetro
obtém sua própria vida útil. Vamos chamá-lo de `'a` como sempre, então agora a assinatura é
esse:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &str {
```

A segunda regra se aplica porque há exatamente um tempo de vida de entrada. O segundo
regra especifica que o tempo de vida de um parâmetro de entrada é atribuído a
o tempo de vida da saída, então a assinatura agora é esta:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &'a str {
```

Agora todas as referências nesta assinatura de função têm vida útil, e o
compilador pode continuar sua análise sem precisar que o programador faça anotações
os tempos de vida nesta assinatura de função.

Vejamos outro exemplo, desta vez usando a função `longest` que tinha
nenhum parâmetro de tempo de vida quando começamos a trabalhar com ele na Listagem 10-20:

```rust,ignore
fn longest(x: &str, y: &str) -> &str {
```

Vamos aplicar a primeira regra: cada parâmetro tem seu próprio tempo de vida. Desta vez nós
temos dois parâmetros em vez de um, então temos dois tempos de vida:

```rust,ignore
fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str {
```

Você pode ver que a segunda regra não se aplica, porque há mais de um
vida útil da entrada. A terceira regra também não se aplica, porque `longest` é um
função em vez de um método, portanto nenhum dos parâmetros é `self`. Depois
trabalhando com todas as três regras, ainda não descobrimos qual será o retorno
a vida útil do tipo é. É por isso que recebemos um erro ao tentar compilar o código em
Listagem 10-20: O compilador trabalhou através das regras de elisão vitalícia, mas ainda assim
não consegui descobrir todos os tempos de vida das referências na assinatura.

Como a terceira regra só se aplica a assinaturas de métodos, veremos
vidas nesse contexto, veja a seguir por que a terceira regra significa que não precisamos
anote tempos de vida em assinaturas de métodos com muita frequência.

<!-- Old headings. Do not remove or links may break. -->

<a id="lifetime-annotations-in-method-definitions"></a>

### Em Definições de Método

Quando implementamos métodos em uma estrutura com tempos de vida, usamos a mesma sintaxe que
o dos parâmetros de tipo genérico, conforme mostrado na Listagem 10-11. Onde declaramos
e usar os parâmetros de vida útil depende se eles estão relacionados ao
campos struct ou os parâmetros do método e valores de retorno.

Nomes vitalícios para campos struct sempre precisam ser declarados após `impl`
palavra-chave e usada após o nome da estrutura porque esses tempos de vida fazem parte
do tipo da estrutura.

Nas assinaturas de métodos dentro do bloco `impl`, as referências podem estar vinculadas ao
vida útil das referências nos campos da estrutura, ou elas podem ser independentes. Em
Além disso, as regras de elisão vitalícia geralmente fazem com que as anotações vitalícias
não são necessários em assinaturas de métodos. Vejamos alguns exemplos usando o
struct chamada `ImportantExcerpt` que definimos na Listagem 10-24.

Primeiro, usaremos um método chamado `level` cujo único parâmetro é uma referência a
`self` e cujo valor de retorno é `i32`, que não é referência a nada:

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-10-lifetimes-on-methods/src/main.rs:1st}}
```

A declaração do parâmetro vitalício após `impl` e seu uso após o nome do tipo
são obrigatórios, mas por causa da primeira regra de elisão, não somos obrigados a
anote o tempo de vida da referência a `self`.

Aqui está um exemplo onde a terceira regra de elisão vitalícia se aplica:

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-10-lifetimes-on-methods/src/main.rs:3rd}}
```

Existem dois tempos de vida de entrada, então Rust aplica a primeira regra de elisão de tempo de vida
e dá a `&self` e `announcement` suas próprias vidas. Então, porque
um dos parâmetros é `&self`, o tipo de retorno obtém o tempo de vida de `&self`,
e todas as vidas foram contabilizadas.

### A vida estática

Uma vida especial que precisamos discutir é `'static`, o que denota que o
a referência afetada _pode_ permanecer ativa durante toda a duração do programa. Todos
literais de string têm o tempo de vida `'static`, que podemos anotar da seguinte forma:

```rust
let s: &'static str = "I have a static lifetime.";
```

O texto desta string é armazenado diretamente no binário do programa, que é
sempre disponível. Portanto, o tempo de vida de todos os literais de string é `'static`.

Você pode ver sugestões em mensagens de erro para usar o tempo de vida `'static`. Mas
antes de especificar `'static` como o tempo de vida de uma referência, pense em
se a referência que você tem realmente vive ou não toda a vida de
seu programa e se você deseja. Na maioria das vezes, uma mensagem de erro
sugerindo os resultados da vida útil `'static` da tentativa de criar um pendente
referência ou uma incompatibilidade das vidas disponíveis. Nesses casos, a solução
é corrigir esses problemas, não especificar o tempo de vida `'static`.

<!-- Old headings. Do not remove or links may break. -->

<a id="generic-type-parameters-trait-bounds-and-lifetimes-together"></a>

## Parâmetros de tipo genérico, limites de características e tempos de vida

Vejamos brevemente a sintaxe de especificação de parâmetros de tipo genérico, trait
limites e tempos de vida, tudo em uma função!

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-11-generics-traits-and-lifetimes/src/main.rs:here}}
```

Esta é a função `longest` da Listagem 10.21 que retorna o maior
duas fatias de barbante. Mas agora ele tem um parâmetro extra chamado `ann` do genérico
digite `T`, que pode ser preenchido por qualquer tipo que implemente `Display`
característica conforme especificado pela cláusula `where`. Este parâmetro extra será impresso
usando `{}`, e é por isso que o limite de característica `Display` é necessário. Porque
tempos de vida são um tipo genérico, as declarações do parâmetro de tempo de vida
`'a` e o parâmetro de tipo genérico `T` vão na mesma lista dentro do ângulo
colchetes após o nome da função.

## Resumo

Abordamos muito neste capítulo! Agora que você sabe sobre o tipo genérico
parâmetros, características e limites de características e parâmetros genéricos de vida útil, você está
pronto para escrever código sem repetição que funcione em muitas situações diferentes.
Os parâmetros de tipo genérico permitem aplicar o código a diferentes tipos. Características e
limites de características garantem que, mesmo que os tipos sejam genéricos, eles terão o
comportamento que o código precisa. Você aprendeu como usar anotações vitalícias para garantir
que este código flexível não terá referências pendentes. E tudo isso
a análise acontece em tempo de compilação, o que não afeta o desempenho em tempo de execução!

Acredite ou não, há muito mais para aprender sobre os tópicos que discutimos em
neste capítulo: O Capítulo 18 discute objetos de características, que são outra maneira de usar
características. Existem também cenários mais complexos que envolvem anotações vitalícias
que você só precisará em cenários muito avançados; para aqueles, você deve ler
a [Referência de ferrugem][reference]. Mas a seguir, você aprenderá como escrever testes em
Rust para que você possa ter certeza de que seu código está funcionando como deveria.

[references-and-borrowing]: ch04-02-references-and-borrowing.html#references-and-borrowing
[string-slices-as-parameters]: ch04-03-slices.html#string-slices-as-parameters
[reference]: ../reference/trait-bounds.html
