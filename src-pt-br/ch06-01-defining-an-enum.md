## Definindo um Enum

Enquanto structs oferecem uma forma de agrupar campos e dados relacionados,
como um `Rectangle` com `width` e `height`, enums oferecem uma forma de dizer
que um valor pode ser um dentre um conjunto possível de valores. Por exemplo,
talvez queiramos dizer que `Rectangle` é uma dentre várias formas possíveis,
junto com `Circle` e `Triangle`. Para isso, o Rust nos permite codificar essas
possibilidades como um enum.

Vamos analisar uma situação que talvez queiramos expressar em código e ver por
que enums são úteis e, nesse caso, mais apropriados do que structs. Digamos
que precisamos trabalhar com endereços IP. Atualmente, dois padrões principais
são usados para endereços IP: versão quatro e versão seis. Como essas são as
únicas possibilidades que nosso programa encontrará, podemos _enumerar_ todas
as variantes possíveis, e é daí que vem o nome enumeração.

Qualquer endereço IP pode ser um endereço de versão quatro ou de versão seis,
mas não ambos ao mesmo tempo. Essa propriedade dos endereços IP torna a
estrutura de dados enum apropriada, porque um valor enum só pode ser uma de
suas variantes. Tanto endereços de versão quatro quanto de versão seis ainda
são, no fundo, endereços IP, então devem ser tratados como o mesmo tipo quando
o código estiver lidando com situações que se aplicam a qualquer tipo de
endereço IP.

Podemos expressar esse conceito em código definindo um enum `IpAddrKind` e
listando os tipos possíveis que um endereço IP pode assumir, `V4` e `V6`.
Essas são as variantes do enum:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:def}}
```

`IpAddrKind` agora é um tipo de dado personalizado que podemos usar em outras
partes do nosso código.

### Valores de Enum

Podemos criar instâncias de cada uma das duas variantes de `IpAddrKind` assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:instance}}
```

Observe que as variantes do enum ficam em um namespace sob seu identificador, e
usamos dois pontos duplos para separar as duas partes. Isso é útil porque
agora tanto `IpAddrKind::V4` quanto `IpAddrKind::V6` têm o mesmo tipo:
`IpAddrKind`. Podemos então, por exemplo, definir uma função que aceite
qualquer `IpAddrKind`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:fn}}
```

E podemos chamar essa função com qualquer uma das variantes:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:fn_call}}
```

Usar enums tem ainda mais vantagens. Pensando um pouco mais no nosso tipo de
endereço IP, neste momento ainda não temos uma forma de armazenar os _dados_ do
endereço IP em si; só sabemos qual _tipo_ ele é. Como você acabou de aprender
sobre structs no Capítulo 5, talvez fique tentado a resolver esse problema com
structs, como mostra a Listagem 6-1.

<Listing number="6-1" caption="Armazenando os dados e a variante `IpAddrKind` de um endereço IP usando uma `struct`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-01/src/main.rs:here}}
```

</Listing>

Aqui, definimos uma struct `IpAddr` com dois campos: um campo `kind`, do tipo
`IpAddrKind` (o enum que definimos anteriormente), e um campo `address`, do
tipo `String`. Temos duas instâncias dessa struct. A primeira é `home`, e ela
tem o valor `IpAddrKind::V4` como `kind`, com os dados de endereço associados
`127.0.0.1`. A segunda instância é `loopback`. Ela tem a outra variante de
`IpAddrKind`, `V6`, e o endereço associado `::1`. Usamos uma struct para
agrupar os valores `kind` e `address`, e assim a variante fica associada ao
valor.

No entanto, representar esse mesmo conceito usando apenas um enum é mais
conciso. Em vez de colocar um enum dentro de uma struct, podemos colocar os
dados diretamente em cada variante do enum. Esta nova definição do enum
`IpAddr` diz que tanto a variante `V4` quanto a `V6` terão um valor `String`
associado:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-02-enum-with-data/src/main.rs:here}}
```

Anexamos os dados diretamente a cada variante do enum, então não há
necessidade de uma struct extra. Aqui também fica mais fácil enxergar outro
detalhe de como enums funcionam: o nome de cada variante do enum que definimos
também se torna uma função que constrói uma instância desse enum. Ou seja,
`IpAddr::V4()` é uma chamada de função que recebe um argumento `String` e
retorna uma instância do tipo `IpAddr`. Recebemos essa função construtora
automaticamente como resultado da definição do enum.

Há outra vantagem em usar um enum em vez de uma struct: cada variante pode ter
tipos e quantidades de dados associados diferentes. Endereços IP de versão
quatro sempre terão quatro componentes numéricos com valores entre 0 e 255.
Se quiséssemos armazenar endereços `V4` como quatro valores `u8`, mas ainda
representar endereços `V6` como um único valor `String`, não conseguiríamos
fazer isso com uma struct. Enums lidam com esse caso com facilidade:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-03-variants-with-different-data/src/main.rs:here}}
```

Mostramos várias formas de definir estruturas de dados para armazenar endereços
IP de versão quatro e de versão seis. No entanto, armazenar endereços IP e
codificar de que tipo eles são é algo tão comum que [a biblioteca padrão já
tem uma definição que podemos usar!][IpAddr]<!-- ignore --> Vamos ver como a
biblioteca padrão define `IpAddr`. Ela tem exatamente o enum e as variantes que
definimos e usamos, mas incorpora os dados do endereço dentro das variantes na
forma de duas structs diferentes, definidas de maneiras distintas para cada
variante:

```rust
struct Ipv4Addr {
    // --snip--
}

struct Ipv6Addr {
    // --snip--
}

enum IpAddr {
    V4(Ipv4Addr),
    V6(Ipv6Addr),
}
```

Esse código ilustra que você pode colocar qualquer tipo de dado dentro de uma
variante de enum: strings, tipos numéricos ou structs, por exemplo. Você pode
até incluir outro enum! Além disso, os tipos da biblioteca padrão muitas vezes
não são muito mais complicados do que aquilo que você mesmo criaria.

Observe que, embora a biblioteca padrão contenha uma definição para `IpAddr`,
ainda podemos criar e usar nossa própria definição sem conflito, porque não
trouxemos a definição da biblioteca padrão para o nosso escopo. Vamos falar
mais sobre como trazer tipos para o escopo no Capítulo 7.

Vejamos outro exemplo de enum na Listagem 6-2. Este aqui tem uma variedade bem
ampla de tipos embutidos em suas variantes.

<Listing number="6-2" caption="Um enum `Message` cujas variantes armazenam quantidades e tipos diferentes de valores">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-02/src/main.rs:here}}
```

</Listing>

Esse enum tem quatro variantes com tipos diferentes:

- `Quit`: não tem nenhum dado associado
- `Move`: tem campos nomeados, como uma struct
- `Write`: inclui uma única `String`
- `ChangeColor`: inclui três valores `i32`

Definir um enum com variantes como as da Listagem 6-2 é semelhante a definir
tipos diferentes de structs, exceto que o enum não usa a palavra-chave
`struct` e que todas as variantes ficam agrupadas sob o tipo `Message`. As
structs a seguir poderiam armazenar os mesmos dados que as variantes do enum
anterior armazenam:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-04-structs-similar-to-message-enum/src/main.rs:here}}
```

Mas, se usássemos structs diferentes, cada uma com seu próprio tipo, não
conseguiríamos definir com a mesma facilidade uma função que aceitasse qualquer
um desses tipos de mensagem, como conseguimos com o enum `Message` definido na
Listagem 6-2, que é um único tipo.

Há mais uma semelhança entre enums e structs: assim como podemos definir
métodos em structs usando `impl`, também podemos definir métodos em enums. Aqui
está um método chamado `call` que poderíamos definir no nosso enum `Message`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-05-methods-on-enums/src/main.rs:here}}
```

O corpo do método usaria `self` para obter o valor sobre o qual o método foi
chamado. Neste exemplo, criamos uma variável `m` com o valor
`Message::Write(String::from("hello"))`, e isso é o que `self` será dentro do
corpo do método `call` quando `m.call()` for executado.

Vamos olhar agora para outro enum da biblioteca padrão que é extremamente comum
e útil: `Option`.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-option-enum-and-its-advantages-over-null-values"></a>

### O Enum `Option`

Esta seção explora um estudo de caso de `Option`, que é outro enum definido
pela biblioteca padrão. O tipo `Option` codifica o cenário muito comum em que
um valor pode ser alguma coisa ou pode não ser nada.

Por exemplo, se você pedir o primeiro item de uma lista não vazia, receberá um
valor. Se pedir o primeiro item de uma lista vazia, não receberá nada.
Expressar esse conceito em termos do sistema de tipos significa que o
compilador pode verificar se você tratou todos os casos que deveria tratar.
Esse recurso pode evitar bugs extremamente comuns em outras linguagens de
programação.

O design de uma linguagem de programação costuma ser pensado em termos dos
recursos que ela inclui, mas os recursos que ela exclui também são importantes.
O Rust não tem o recurso de nulo que muitas outras linguagens têm. _Null_ é um
valor que significa que não há valor ali. Em linguagens com null, variáveis
sempre podem estar em um de dois estados: null ou não null.

Na sua apresentação de 2009, “Null References: The Billion Dollar Mistake”,
Tony Hoare, o inventor do null, disse o seguinte:

> Eu chamo isso de meu erro de um bilhão de dólares. Na época, eu estava
> projetando o primeiro sistema de tipos abrangente para referências em uma
> linguagem orientada a objetos. Meu objetivo era garantir que todo uso de
> referências fosse absolutamente seguro, com a verificação realizada
> automaticamente pelo compilador. Mas eu não consegui resistir à tentação de
> incluir uma referência nula, simplesmente porque era muito fácil
> implementá-la. Isso levou a inúmeros erros, vulnerabilidades e falhas de
> sistema, que
> provavelmente causaram um bilhão de dólares em dor e prejuízo ao longo dos
> últimos quarenta anos.

O problema com valores null é que, se você tentar usar um valor null como se
fosse um valor não null, vai receber algum tipo de erro. Como essa propriedade
de ser null ou não null é disseminada, é extremamente fácil cometer esse tipo
de erro.

No entanto, o conceito que null tenta expressar ainda é útil: null é um valor
que, por algum motivo, está ausente ou inválido no momento.

O problema não está realmente no conceito, e sim na implementação específica.
Por isso, o Rust não tem nulls, mas tem um enum que pode codificar a ideia de
um valor estar presente ou ausente. Esse enum é `Option<T>`, e ele é [definido
pela biblioteca padrão][option]<!-- ignore --> assim:

```rust
enum Option<T> {
    None,
    Some(T),
}
```

O enum `Option<T>` é tão útil que ele inclusive faz parte do prelude; você não
precisa trazê-lo explicitamente para o escopo. Suas variantes também fazem
parte do prelude: você pode usar `Some` e `None` diretamente, sem o prefixo
`Option::`. O enum `Option<T>` continua sendo apenas um enum normal, e
`Some(T)` e `None` continuam sendo variantes do tipo `Option<T>`.

A sintaxe `<T>` é um recurso do Rust sobre o qual ainda não falamos. Trata-se
de um parâmetro de tipo genérico, e veremos genéricos em mais detalhes no
Capítulo 10. Por enquanto, tudo o que você precisa saber é que `<T>` significa
que a variante `Some` do enum `Option` pode conter um valor de qualquer tipo e
que cada tipo concreto usado no lugar de `T` transforma o tipo geral
`Option<T>` em um tipo diferente. Aqui estão alguns exemplos de uso de valores
`Option` para armazenar tipos numéricos e caracteres:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-06-option-examples/src/main.rs:here}}
```

O tipo de `some_number` é `Option<i32>`. O tipo de `some_char` é
`Option<char>`, que é um tipo diferente. O Rust consegue inferir esses tipos
porque especificamos um valor dentro da variante `Some`. Para `absent_number`,
o Rust exige que anotemos o tipo `Option` como um todo: o compilador não
consegue inferir qual tipo a variante `Some` correspondente conteria olhando
apenas para um valor `None`. Aqui, estamos dizendo ao Rust que queremos que
`absent_number` seja do tipo `Option<i32>`.

Quando temos um valor `Some`, sabemos que um valor está presente e que ele está
armazenado dentro de `Some`. Quando temos um valor `None`, em certo sentido
isso significa a mesma coisa que null: não temos um valor válido. Então por que
ter `Option<T>` é melhor do que ter null?

Em resumo, porque `Option<T>` e `T`, em que `T` pode ser qualquer tipo, são
tipos diferentes, o compilador não nos deixa usar um valor `Option<T>` como se
ele certamente fosse um valor válido. Por exemplo, este código não compila,
porque tenta somar um `i8` a um `Option<i8>`:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-07-cant-use-option-directly/src/main.rs:here}}
```

Se executarmos esse código, receberemos uma mensagem de erro como esta:

```console
{{#include ../listings/ch06-enums-and-pattern-matching/no-listing-07-cant-use-option-directly/output.txt}}
```

Pesado! Na prática, essa mensagem de erro quer dizer que o Rust não sabe como
somar um `i8` e um `Option<i8>`, porque eles são tipos diferentes. Quando
temos um valor de um tipo como `i8` em Rust, o compilador garante que sempre
teremos um valor válido. Podemos prosseguir com confiança, sem precisar
verificar se o valor é null antes de usá-lo. Só quando temos um `Option<i8>`,
ou qualquer outro `Option` com que estejamos trabalhando, é que precisamos nos
preocupar com a possibilidade de não haver valor, e o compilador garantirá que
trataremos esse caso antes de usar o valor.

Em outras palavras, você precisa converter um `Option<T>` em um `T` antes de
poder realizar operações de `T` com ele. Em geral, isso ajuda a capturar um
dos problemas mais comuns envolvendo null: supor que algo não é null quando, na
verdade, é.

Eliminar o risco de assumir incorretamente que um valor não é null ajuda você a
ter mais confiança no seu código. Para ter um valor que possa ser null, você
precisa optar explicitamente por isso, fazendo com que o tipo desse valor seja
`Option<T>`. Depois, ao usar esse valor, você é obrigado a tratar
explicitamente o caso em que ele é null. Em todo lugar em que um valor tenha um
tipo que não seja `Option<T>`, você _pode_ assumir com segurança que ele não é
null. Essa foi uma decisão deliberada de design do Rust para limitar a
disseminação de null e aumentar a segurança do código Rust.

Então, como você obtém o valor `T` de dentro de uma variante `Some` quando tem
um valor do tipo `Option<T>` e quer usar esse valor? O enum `Option<T>` tem um
grande número de métodos úteis em diversas situações; você pode consultá-los
na [documentação][docs]<!-- ignore -->. Familiarizar-se com os métodos de
`Option<T>` será extremamente útil na sua jornada com Rust.

Em geral, para usar um valor `Option<T>`, você precisa ter código que trate
cada variante. Você vai querer um trecho de código que só execute quando tiver
um `Some(T)`, e esse código poderá usar o `T` interno. Também vai querer outro
trecho que só execute quando tiver um valor `None`, e esse código não terá um
valor `T` disponível. A expressão `match` é uma construção de controle de
fluxo que faz exatamente isso quando usada com enums: ela executa códigos
diferentes dependendo de qual variante do enum está presente, e esse código
pode usar os dados contidos no valor correspondente.

[IpAddr]: ../std/net/enum.IpAddr.html
[option]: ../std/option/enum.Option.html
[docs]: ../std/option/enum.Option.html
