## Validando Referências com Lifetimes

_Lifetimes_ são outro tipo de genérico que já vimos em uso. Em vez de
garantir que um tipo tenha o comportamento que queremos, lifetimes garantem
que referências continuem válidas pelo tempo que precisamos delas.

Um detalhe que não discutimos na seção [“Referências e
Empréstimos”][references-and-borrowing]<!-- ignore -->, no Capítulo 4, é que toda
referência em Rust tem um lifetime, que é o escopo durante o qual essa
referência é válida. Na maior parte do tempo, lifetimes são implícitos e
inferidos, assim como geralmente acontece com tipos. Só precisamos anotar tipos
quando mais de um tipo é possível. De forma parecida, precisamos anotar
lifetimes quando os lifetimes de referências podem se relacionar de algumas
maneiras diferentes. O Rust exige que anotemos essas relações usando parâmetros
genéricos de lifetime, para garantir que as referências concretas usadas em
tempo de execução sejam de fato válidas.

Anotar lifetimes não é sequer um conceito presente na maioria das outras
linguagens de programação, então isso provavelmente vai parecer pouco familiar.
Embora não cubramos lifetimes por completo neste capítulo, vamos discutir as
formas mais comuns em que essa sintaxe aparece para que você se acostume com a
ideia.

<!-- Old headings. Do not remove or links may break. -->

<a id="preventing-dangling-references-with-lifetimes"></a>

### Referências Pendentes

O principal objetivo dos lifetimes é evitar referências pendentes, que, se
fossem permitidas, fariam um programa referenciar dados diferentes daqueles
que ele pretendia referenciar. Considere o programa da Listagem 10-16, que tem
um escopo externo e um escopo interno.

<Listing number="10-16" caption="Tentativa de usar uma referência cujo valor já saiu de escopo">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-16/src/main.rs}}
```

</Listing>

> Nota: os exemplos das Listagens 10-16, 10-17 e 10-23 declaram variáveis
> sem lhes dar um valor inicial, de modo que o nome da variável existe no
> escopo externo. À primeira vista, isso pode parecer entrar em conflito com o
> fato de Rust não ter valores nulos. No entanto, se tentarmos usar uma
> variável antes de lhe atribuir um valor, receberemos um erro em tempo de
> compilação, o que mostra que Rust realmente não permite valores nulos.

O escopo externo declara uma variável chamada `r` sem valor inicial, e o
escopo interno declara uma variável chamada `x` com o valor inicial `5`. Dentro
do escopo interno, tentamos definir o valor de `r` como uma referência a `x`.
Depois, o escopo interno termina e tentamos imprimir o valor em `r`. Esse
código não compila, porque o valor ao qual `r` se refere saiu de escopo antes
de tentarmos usá-lo. Aqui está a mensagem de erro:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-16/output.txt}}
```

A mensagem de erro diz que a variável `x` “não vive tempo suficiente”. O motivo
é que `x` sai de escopo quando o escopo interno termina na linha 7. Mas `r`
ainda é válido no escopo externo; como seu escopo é maior, dizemos que ele
“vive mais”. Se Rust permitisse esse código, `r` ficaria apontando para uma
região de memória que já teria sido desalocada quando `x` saísse de escopo, e
qualquer tentativa de usar `r` produziria comportamento incorreto. Como o Rust
determina que esse código é inválido? Ele usa o _borrow checker_.

### O Borrow Checker

O compilador Rust possui um _borrow checker_ que compara escopos para
determinar se todos os empréstimos são válidos. A Listagem 10-17 mostra o
mesmo código da Listagem 10-16, mas com anotações exibindo os lifetimes das
variáveis.

<Listing number="10-17" caption="Anotações dos lifetimes de `r` e `x`, chamados `'a` e `'b`, respectivamente">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-17/src/main.rs}}
```

</Listing>

Aqui, anotamos o lifetime de `r` com `'a` e o de `x` com `'b`. Como você pode
ver, o bloco interno `'b` é muito menor que o bloco externo `'a`. Em tempo de
compilação, o Rust compara o tamanho desses dois lifetimes e percebe que `r`
tem lifetime `'a`, mas aponta para uma memória com lifetime `'b`. O programa é
rejeitado porque `'b` é menor que `'a`: o valor referenciado não vive tanto
quanto a referência.

A Listagem 10-18 corrige o código para que ele não tenha uma referência
pendente, e então ele compila sem erros.

<Listing number="10-18" caption="Uma referência válida porque os dados têm um lifetime maior que a referência">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-18/src/main.rs}}
```

</Listing>

Aqui, `x` tem lifetime `'b`, que neste caso é maior que `'a`. Isso significa
que `r` pode referenciar `x`, porque o Rust sabe que a referência em `r`
continuará válida enquanto `x` for válido.

Agora que você sabe onde estão os lifetimes das referências e como o Rust os
analisa para garantir que as referências sejam sempre válidas, vamos explorar
lifetimes genéricos em parâmetros de função e valores de retorno.

### Lifetimes Genéricos em Funções

Vamos escrever uma função que retorna o mais longo entre dois string slices.
Essa função receberá dois string slices e retornará um único string slice.
Depois de implementarmos a função `longest`, o código da Listagem 10-19 deverá
imprimir `The longest string is abcd`.

<Listing number="10-19" file-name="src/main.rs" caption="Uma função `main` que chama `longest` para encontrar o mais longo entre dois string slices">

```rust,ignore
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-19/src/main.rs}}
```

</Listing>

Observe que queremos que a função receba string slices, que são
referências, em vez de strings, porque não queremos que a função `longest`
assuma ownership de seus parâmetros. Consulte [“String Slices como
Parâmetros”][string-slices-as-parameters]<!-- ignore --> no Capítulo 4 para uma
discussão mais detalhada sobre por que os parâmetros da Listagem 10-19 são os
que queremos.

Se tentarmos implementar a função `longest` como mostrado na Listagem 10-20,
ela não compilará.

<Listing number="10-20" file-name="src/main.rs" caption="Uma implementação de `longest` que retorna o mais longo entre dois string slices, mas ainda não compila">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-20/src/main.rs:here}}
```

</Listing>

Em vez disso, obtemos o seguinte erro, que fala sobre lifetimes:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-20/output.txt}}
```

O texto de ajuda revela que o tipo de retorno precisa de um parâmetro genérico
de lifetime, porque o Rust não consegue dizer se a referência retornada se
refere a `x` ou a `y`. Na verdade, nós também não sabemos, porque o bloco `if`
no corpo dessa função retorna uma referência a `x`, e o bloco `else` retorna
uma referência a `y`!

Quando definimos essa função, não sabemos quais valores concretos serão
passados para ela, então não sabemos se o caso `if` ou o caso `else` será
executado. Também não sabemos quais são os lifetimes concretos das referências
recebidas, então não podemos olhar para os escopos como fizemos nas Listagens
10-17 e 10-18 para determinar se a referência que retornamos sempre será
válida. O borrow checker também não consegue determinar isso, porque não sabe
como os lifetimes de `x` e `y` se relacionam com o lifetime do valor de
retorno. Para corrigir esse erro, vamos adicionar parâmetros genéricos de
lifetime que definem a relação entre essas referências, permitindo que o
borrow checker faça sua análise.

### Sintaxe de Anotações de Lifetime

Anotações de lifetime não alteram por quanto tempo as referências vivem. Em vez
disso, elas descrevem as relações entre os lifetimes de múltiplas referências,
sem afetar esses lifetimes. Assim como funções podem aceitar qualquer tipo
quando a assinatura especifica um parâmetro de tipo genérico, funções podem
aceitar referências com qualquer lifetime ao especificar um parâmetro genérico
de lifetime.

Anotações de lifetime têm uma sintaxe um pouco incomum: os nomes desses
parâmetros devem começar com um apóstrofo (`'`) e geralmente são curtos e em
minúsculas, como os tipos genéricos. A maioria das pessoas usa o nome `'a`
para a primeira anotação de lifetime. Colocamos anotações de parâmetro de
lifetime logo após o `&` de uma referência, usando um espaço para separar a
anotação do tipo da referência.

Aqui estão alguns exemplos: uma referência a `i32` sem parâmetro de lifetime,
uma referência a `i32` com um parâmetro de lifetime chamado `'a`, e uma
referência mutável a `i32` que também tem o lifetime `'a`:

```rust,ignore
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

Uma anotação de lifetime, sozinha, não significa muita coisa, porque essas
anotações existem para informar ao Rust como os parâmetros genéricos de
lifetime de várias referências se relacionam entre si. Vamos examinar como as
anotações de lifetime se relacionam no contexto da função `longest`.

<!-- Old headings. Do not remove or links may break. -->

<a id="lifetime-annotations-in-function-signatures"></a>

### Em Assinaturas de Função

Para usar anotações de lifetime em assinaturas de função, precisamos declarar
os parâmetros genéricos de lifetime entre colchetes angulares, entre o nome da
função e a lista de parâmetros, assim como fizemos com parâmetros de tipo
genérico.

Queremos que a assinatura expresse a seguinte restrição: a referência
retornada será válida enquanto ambos os parâmetros forem válidos. Essa é a
relação entre os lifetimes dos parâmetros e o valor de retorno. Vamos chamar o
lifetime de `'a` e então adicioná-lo a cada referência, como mostrado na
Listagem 10-21.

<Listing number="10-21" file-name="src/main.rs" caption="Definição da função `longest`, especificando que todas as referências da assinatura devem ter o mesmo lifetime `'a`">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-21/src/main.rs:here}}
```

</Listing>

Esse código deve compilar e produzir o resultado desejado quando for usado com
a função `main` da Listagem 10-19.

A assinatura da função agora informa ao Rust que, para algum lifetime `'a`, a
função recebe dois parâmetros, ambos string slices que vivem pelo menos
enquanto `'a`. A assinatura também informa ao Rust que o string slice
retornado viverá pelo menos o mesmo tempo que `'a`. Na prática, isso significa
que o lifetime da referência retornada por `longest` é o menor dos lifetimes
dos valores referidos pelos argumentos da função. Essas relações são exatamente
o que queremos que o Rust use ao analisar esse código.

Lembre-se: quando especificamos parâmetros de lifetime nessa assinatura, não
estamos alterando o lifetime de nenhum valor passado ou retornado. Em vez
disso, estamos dizendo ao borrow checker que ele deve rejeitar quaisquer
valores que não atendam a essas restrições. Observe que a função `longest` não
precisa saber exatamente por quanto tempo `x` e `y` viverão; ela só precisa
saber que algum escopo pode ser substituído por `'a` e satisfazer essa
assinatura.

Ao anotar lifetimes em funções, as anotações aparecem na assinatura, não no
corpo da função. Anotações de lifetime passam a fazer parte do contrato da
função, assim como os tipos na assinatura. Tornar esse contrato explícito
simplifica a análise do compilador Rust. Se houver um problema na forma como
uma função é anotada ou chamada, os erros do compilador poderão apontar com
mais precisão para a parte do código e para a restrição envolvida. Se, em vez
disso, o compilador Rust tentasse inferir mais do que pretendíamos nas relações
entre lifetimes, talvez ele só conseguisse apontar para um uso do código muito
distante da causa real do problema.

Quando passamos referências concretas para `longest`, o lifetime concreto que
substitui `'a` é a parte do escopo de `x` que se sobrepõe ao escopo de `y`. Em
outras palavras, o lifetime genérico `'a` será instanciado com o menor dos
lifetimes de `x` e `y`. Como anotamos a referência retornada com o mesmo
parâmetro de lifetime `'a`, essa referência retornada também será válida apenas
pelo menor dos lifetimes de `x` e `y`.

Vamos ver como as anotações de lifetime restringem a função `longest`
quando passamos referências com lifetimes concretos diferentes. A Listagem 10-22
mostra um exemplo simples.

<Listing number="10-22" file-name="src/main.rs" caption="Usando `longest` com referências a valores `String` que têm lifetimes concretos diferentes">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-22/src/main.rs:here}}
```

</Listing>

Neste exemplo, `string1` é válido até o final do escopo externo, `string2` é
válido até o final do escopo interno, e `result` referencia algo que também é
válido até o fim desse escopo interno. Se você executar esse código, verá que
o borrow checker o aprova: ele compila e imprime `The longest string is long string is long`.

Agora vamos tentar um exemplo que mostra que o lifetime da referência em
`result` precisa ser o menor lifetime entre os dois argumentos. Vamos mover a
declaração da variável `result` para fora do escopo interno, mas deixar a
atribuição do valor de `result` dentro do escopo em que `string2` existe.
Depois, moveremos o `println!` que usa `result` para fora do escopo interno,
ou seja, depois que esse escopo já tiver terminado. O código da Listagem 10-23
não compila.

<Listing number="10-23" file-name="src/main.rs" caption="Tentando usar `result` depois que `string2` saiu de escopo">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-23/src/main.rs:here}}
```

</Listing>

Quando tentamos compilar este código, obtemos este erro:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-23/output.txt}}
```

O erro mostra que para `result` ser válido para a instrução `println!`,
`string2` precisaria ser válido até o final do escopo externo. Rust sabe
isso porque anotamos os lifetimes dos parâmetros da função e retornamos
valores usando o mesmo parâmetro de lifetime `'a`.

Como humanos, podemos olhar para esse código e perceber que `string1` é mais
longa que `string2` e, portanto, `result` conterá uma referência a `string1`.
Como `string1` ainda não saiu de escopo, uma referência a `string1`
continuaria válida para a instrução `println!`. No entanto, o compilador não
consegue concluir isso nesse caso. Nós dissemos ao Rust que o lifetime da
referência retornada pela função `longest` é igual ao menor lifetime das
referências passadas. Por isso, o borrow checker não permite o código da
Listagem 10-23, porque ele _poderia_ conter uma referência inválida.

Tente imaginar outros experimentos, variando os valores, os lifetimes das
referências passadas para `longest` e a forma como a referência retornada é
usada. Faça hipóteses sobre se seus experimentos passarão ou não pelo
borrow checker antes de compilar; depois, veja se você acertou!

<!-- Old headings. Do not remove or links may break. -->

<a id="thinking-in-terms-of-lifetimes"></a>

### Pensando em Relações Entre Lifetimes

A forma como você precisa especificar parâmetros de lifetime depende do que sua
função faz. Por exemplo, se alterássemos a implementação de `longest` para
sempre retornar o primeiro parâmetro, em vez do string slice mais longo, não
precisaríamos especificar um lifetime no parâmetro `y`. O código a seguir
compila:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-08-only-one-reference-with-lifetime/src/main.rs:here}}
```

</Listing>

Especificamos um parâmetro de lifetime `'a` para o parâmetro `x` e para o tipo
de retorno, mas não para o parâmetro `y`, porque o lifetime de `y` não tem
nenhuma relação com o lifetime de `x` nem com o valor de retorno.

Ao retornar uma referência de uma função, o parâmetro de lifetime para o
tipo de retorno precisa corresponder ao parâmetro de lifetime de um dos
parâmetros. Se a referência retornada _não_ se refere a um dos parâmetros, ela
deve se referir a um valor criado dentro desta função. No entanto, isso seria
uma referência pendente, porque o valor sairá de escopo no final da função.
Considere esta tentativa de implementação da função `longest`, que não
compila:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-09-unrelated-lifetime/src/main.rs:here}}
```

</Listing>

Aqui, embora tenhamos especificado um parâmetro de lifetime `'a` para o tipo
de retorno, esta implementação não compilará porque o lifetime do valor
de retorno não tem nenhuma relação com o lifetime dos parâmetros. Aqui está a
mensagem de erro que recebemos:

```console
{{#include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-09-unrelated-lifetime/output.txt}}
```

O problema é que `result` sai de escopo e é limpo no final da função
`longest`. Também estamos tentando retornar uma referência a `result` a partir
da função. Não há como especificar parâmetros de lifetime que transformem essa
referência pendente em uma referência válida, e Rust não nos deixará criar uma
referência pendente. Nesse caso, a melhor solução seria retornar um tipo de
dado com ownership, em vez de uma referência, para que a função chamadora seja
responsável por limpar o valor.

Em última análise, a sintaxe de lifetime serve para conectar os lifetimes de
vários parâmetros e valores de retorno de funções. Uma vez que eles estão
conectados, Rust tem informações suficientes para permitir operações seguras em
memória e proibir operações que criariam ponteiros pendentes ou violariam a
segurança de memória.

<!-- Old headings. Do not remove or links may break. -->

<a id="lifetime-annotations-in-struct-definitions"></a>

### Em Definições de Struct

Até agora, todas as structs que definimos armazenavam tipos com ownership.
Podemos definir structs que contenham referências, mas, nesse caso, precisamos
adicionar uma anotação de lifetime a cada referência na definição da struct. A
Listagem 10-24 tem uma struct chamada `ImportantExcerpt` que contém um string
slice.

<Listing number="10-24" file-name="src/main.rs" caption="Uma struct que armazena uma referência, exigindo uma anotação de lifetime">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-24/src/main.rs}}
```

</Listing>

Essa struct tem um único campo, `part`, que contém um string slice, isto é,
uma referência. Assim como acontece com tipos de dados genéricos, declaramos o
nome do parâmetro genérico de lifetime entre colchetes angulares depois do nome
da struct, para que possamos usar esse parâmetro de lifetime no corpo da
definição da struct. Essa anotação significa que uma instância de
`ImportantExcerpt` não pode viver mais do que a referência que ela armazena no
campo `part`.

A função `main` aqui cria uma instância da struct `ImportantExcerpt` que contém
uma referência à primeira frase da `String` pertencente à variável `novel`. Os
dados em `novel` existem antes de a instância de `ImportantExcerpt` ser criada.
Além disso, `novel` não sai de escopo antes de `ImportantExcerpt` sair de
escopo, então a referência na instância de `ImportantExcerpt` é válida.

### Elisão de Lifetime

Você aprendeu que toda referência tem um lifetime e que você precisa
especificar parâmetros de lifetime para funções ou structs que usam
referências. No entanto, tínhamos uma função na Listagem 4-9, mostrada
novamente na Listagem 10-25, que compilava sem anotações de lifetime.

<Listing number="10-25" file-name="src/lib.rs" caption="Uma função definida na Listagem 4-9 que compilou sem anotações de lifetime, mesmo com parâmetros e retorno sendo referências">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-25/src/main.rs:here}}
```

</Listing>

A razão pela qual essa função compila sem anotações de lifetime é histórica:
nas versões antigas (pré-1.0) de Rust, esse código não teria compilado, porque
cada referência precisava de um lifetime explícito. Naquela época, a assinatura
da função teria sido escrita assim:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &'a str {
```

Depois de escrever muito código Rust, a equipe do Rust percebeu que
programadores escreviam as mesmas anotações de lifetime repetidas vezes em
situações específicas. Essas situações eram previsíveis e seguiam alguns
padrões determinísticos. Os desenvolvedores programaram esses padrões no
compilador para que o borrow checker pudesse inferir os lifetimes nessas
situações sem exigir anotações explícitas.

Esse pedaço da história de Rust é relevante porque é possível que mais padrões
determinísticos surjam e sejam adicionados ao compilador. No futuro, talvez
ainda menos anotações de lifetime sejam necessárias.

Os padrões programados na análise de referências de Rust são chamados de
_regras de elisão de lifetime_. Essas não são regras que programadores precisam
seguir; elas são um conjunto de casos específicos que o compilador considera.
Se o seu código se encaixa nesses casos, você não precisa escrever os lifetimes
explicitamente.

As regras de elisão não fornecem inferência completa. Se ainda houver
ambiguidade sobre quais lifetimes as referências têm depois que Rust aplica as
regras, o compilador não adivinhará qual deve ser o lifetime das referências
restantes. Em vez de adivinhar, o compilador apresentará um erro que você pode
resolver adicionando anotações de lifetime.

Os lifetimes em parâmetros de função ou método são chamados de _lifetimes de
entrada_, e os lifetimes em valores de retorno são chamados de _lifetimes de
saída_.

O compilador usa três regras para descobrir os lifetimes das referências
quando não há anotações explícitas. A primeira regra se aplica aos lifetimes de
entrada, e a segunda e a terceira se aplicam aos lifetimes de saída. Se o
compilador chegar ao fim das três regras e ainda houver referências cujos
lifetimes ele não consegue descobrir, ele parará com um erro. Essas regras se
aplicam tanto a definições `fn` quanto a blocos `impl`.

A primeira regra é que o compilador atribui um parâmetro de lifetime a cada
parâmetro que é uma referência. Em outras palavras, uma função com um parâmetro
obtém um parâmetro de lifetime: `fn foo<'a>(x: &'a i32)`; uma função com dois
parâmetros obtém dois parâmetros de lifetime separados: `fn foo<'a, 'b>(x: &'a i32,
y: &'b i32)`; e assim por diante.

A segunda regra é que, se houver exatamente um parâmetro de lifetime de
entrada, esse lifetime é atribuído a todos os parâmetros de lifetime de saída:
`fn foo<'a>(x: &'a i32) -> &'a i32`.

A terceira regra é que, se houver vários parâmetros de lifetime de entrada, mas
um deles for `&self` ou `&mut self` porque se trata de um método, o lifetime de
`self` será atribuído a todos os parâmetros de lifetime de saída. Essa terceira
regra torna métodos muito mais agradáveis de ler e escrever, porque exige
menos símbolos.

Vamos fingir que somos o compilador. Aplicaremos essas regras para descobrir o
lifetime das referências na assinatura da função `first_word` da Listagem
10-25. A assinatura começa sem nenhum lifetime associado às referências:

```rust,ignore
fn first_word(s: &str) -> &str {
```

Então, o compilador aplica a primeira regra, que especifica que cada parâmetro
recebe seu próprio lifetime. Vamos chamá-lo de `'a`, como de costume, então
agora a assinatura é esta:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &str {
```

A segunda regra se aplica porque há exatamente um lifetime de entrada. A
segunda regra especifica que o lifetime do único parâmetro de entrada é
atribuído ao lifetime de saída, então a assinatura agora é esta:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &'a str {
```

Agora todas as referências nessa assinatura de função têm lifetimes, e o
compilador pode continuar sua análise sem precisar que o programador anote os
lifetimes nessa assinatura.

Vejamos outro exemplo, desta vez usando a função `longest` que tinha
nenhum parâmetro de lifetime quando começamos a trabalhar com ela na Listagem
10-20:

```rust,ignore
fn longest(x: &str, y: &str) -> &str {
```

Vamos aplicar a primeira regra: cada parâmetro recebe seu próprio lifetime.
Desta vez, temos dois parâmetros em vez de um, então temos dois lifetimes:

```rust,ignore
fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str {
```

Você pode ver que a segunda regra não se aplica, porque há mais de um
lifetime de entrada. A terceira regra também não se aplica, porque `longest` é
uma função, não um método, portanto nenhum dos parâmetros é `self`. Depois de
percorrer as três regras, ainda não descobrimos qual é o lifetime do tipo de
retorno. É por isso que recebemos um erro ao tentar compilar o código da
Listagem 10-20: o compilador percorreu as regras de elisão de lifetime, mas
ainda assim não conseguiu descobrir todos os lifetimes das referências na
assinatura.

Como a terceira regra realmente só se aplica a assinaturas de métodos, veremos
lifetimes nesse contexto a seguir para entender por que essa regra faz com que
não precisemos anotar lifetimes em assinaturas de métodos com tanta frequência.

<!-- Old headings. Do not remove or links may break. -->

<a id="lifetime-annotations-in-method-definitions"></a>

### Em Definições de Método

Quando implementamos métodos em uma struct com lifetimes, usamos a mesma
sintaxe dos parâmetros de tipo genérico, como mostrado na Listagem 10-11. Onde
declaramos e usamos os parâmetros de lifetime depende de eles estarem
relacionados aos campos da struct ou aos parâmetros e valores de retorno do
método.

Nomes de lifetimes para campos de struct sempre precisam ser declarados depois
da palavra-chave `impl` e usados depois do nome da struct, porque esses
lifetimes fazem parte do tipo da struct.

Nas assinaturas de métodos dentro do bloco `impl`, as referências podem estar
ligadas ao lifetime das referências nos campos da struct, ou podem ser
independentes. Além disso, as regras de elisão de lifetime frequentemente fazem
com que anotações de lifetime não sejam necessárias em assinaturas de métodos.
Vejamos alguns exemplos usando a struct chamada `ImportantExcerpt` que
definimos na Listagem 10-24.

Primeiro, usaremos um método chamado `level`, cujo único parâmetro é uma
referência a `self` e cujo valor de retorno é um `i32`, que não é referência a
nada:

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-10-lifetimes-on-methods/src/main.rs:1st}}
```

A declaração do parâmetro de lifetime após `impl` e seu uso após o nome do tipo
são obrigatórios, mas, por causa da primeira regra de elisão, não somos
obrigados a anotar o lifetime da referência a `self`.

Aqui está um exemplo onde a terceira regra de elisão de lifetime se aplica:

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-10-lifetimes-on-methods/src/main.rs:3rd}}
```

Existem dois lifetimes de entrada, então Rust aplica a primeira regra de
elisão de lifetime e dá a `&self` e `announcement` seus próprios lifetimes.
Então, como um dos parâmetros é `&self`, o tipo de retorno recebe o lifetime de
`&self`, e todos os lifetimes foram contabilizados.

### O Lifetime `static`

Um lifetime especial que precisamos discutir é `'static`, que indica que a
referência afetada _pode_ permanecer ativa durante toda a duração do programa.
Todos os literais de string têm o lifetime `'static`, que podemos anotar da
seguinte forma:

```rust
let s: &'static str = "I have a static lifetime.";
```

O texto desta string é armazenado diretamente no binário do programa, que é
sempre disponível. Portanto, o lifetime de todos os literais de string é
`'static`.

Você pode ver sugestões em mensagens de erro para usar o lifetime `'static`. Mas
antes de especificar `'static` como o lifetime de uma referência, pense em
se a referência que você tem realmente vive por toda a duração do seu programa
e se é isso que você deseja. Na maioria das vezes, uma mensagem de erro que
sugere o lifetime `'static` é resultado de uma tentativa de criar uma
referência pendente ou de uma incompatibilidade entre os lifetimes disponíveis.
Nesses casos, a solução é corrigir esses problemas, não especificar o lifetime
`'static`.

<!-- Old headings. Do not remove or links may break. -->

<a id="generic-type-parameters-trait-bounds-and-lifetimes-together"></a>

## Parâmetros de tipo genérico, trait bounds e lifetimes

Vejamos brevemente a sintaxe para especificar parâmetros de tipo genérico,
trait bounds e lifetimes, tudo em uma única função!

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/no-listing-11-generics-traits-and-lifetimes/src/main.rs:here}}
```

Esta é a função `longest` da Listagem 10-21, que retorna o mais longo entre
dois string slices. Mas agora ela tem um parâmetro extra chamado `ann`, do tipo
genérico `T`, que pode ser preenchido por qualquer tipo que implemente a trait
`Display`, conforme especificado pela cláusula `where`. Esse parâmetro extra
será impresso usando `{}`, e é por isso que o trait bound `Display` é
necessário. Como lifetimes são um tipo de genérico, as declarações do
parâmetro de lifetime `'a` e do parâmetro de tipo genérico `T` ficam na mesma
lista dentro dos colchetes angulares após o nome da função.

## Resumo

Abordamos muita coisa neste capítulo! Agora que você sabe sobre parâmetros de
tipo genérico, traits e trait bounds, e parâmetros genéricos de lifetime, você
está pronto para escrever código sem repetição que funcione em muitas situações
diferentes. Parâmetros de tipo genérico permitem aplicar o código a diferentes
tipos. Traits e trait bounds garantem que, mesmo que os tipos sejam genéricos,
eles terão o comportamento de que o código precisa. Você aprendeu como usar
anotações de lifetime para garantir que esse código flexível não tenha
referências pendentes. E toda essa análise acontece em tempo de compilação, o
que não afeta o desempenho em tempo de execução!

Acredite ou não, há muito mais para aprender sobre os tópicos que discutimos
neste capítulo: o Capítulo 18 discute objetos de trait, que são outra forma de
usar traits. Também existem cenários mais complexos envolvendo anotações de
lifetime, que você só precisará em situações muito avançadas; para esses casos,
você deve ler a [Referência do Rust][reference]. Mas, a seguir, você aprenderá
como escrever testes em Rust para poder ter certeza de que seu código está
funcionando como deveria.

[references-and-borrowing]: ch04-02-references-and-borrowing.html#references-and-borrowing
[string-slices-as-parameters]: ch04-03-slices.html#string-slices-as-parameters
[reference]: https://doc.rust-lang.org/reference/trait-bounds.html
