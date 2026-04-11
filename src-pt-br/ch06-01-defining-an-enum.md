## Definindo um Enum

Onde as estruturas fornecem uma maneira de agrupar campos e dados relacionados, como
um `Rectangle` com seu `width` e `height`, enums fornecem uma maneira de dizer um
valor é um de um conjunto possível de valores. Por exemplo, podemos querer dizer que
`Rectangle` faz parte de um conjunto de formas possíveis que também inclui `Circle` e
`Triangle`. Para fazer isso, Rust nos permite codificar essas possibilidades como um enum.

Vejamos uma situação que podemos querer expressar em código e ver por que enums
são úteis e mais apropriados que estruturas neste caso. Digamos que precisamos trabalhar
com endereços IP. Atualmente, dois padrões principais são usados ​​para endereços IP:
versão quatro e versão seis. Porque estas são as únicas possibilidades para um
Endereço IP que nosso programa encontrará, podemos _enumerar_ todos os possíveis
variantes, que é onde a enumeração recebe seu nome.

Qualquer endereço IP pode ser um endereço da versão quatro ou da versão seis, mas não
ambos ao mesmo tempo. Essa propriedade dos endereços IP torna os dados enum
estrutura apropriada porque um valor enum só pode ser uma de suas variantes.
Os endereços da versão quatro e da versão seis ainda são fundamentalmente IP
endereços, portanto eles devem ser tratados como do mesmo tipo quando o código estiver manipulando
situações que se aplicam a qualquer tipo de endereço IP.

Podemos expressar esse conceito em código definindo uma enumeração `IpAddrKind` e
listando os tipos possíveis que um endereço IP pode ter, `V4` e `V6`. Estes são os
variantes do enum:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:def}}
```

`IpAddrKind` agora é um tipo de dados personalizado que podemos usar em outras partes do nosso código.

### Valores de Enum

Podemos criar instâncias de cada uma das duas variantes de `IpAddrKind` assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:instance}}
```

Observe que as variantes do enum têm namespace sob seu identificador, e nós
use dois pontos duplos para separar os dois. Isto é útil porque agora ambos os valores
`IpAddrKind::V4` e `IpAddrKind::V6` são do mesmo tipo: `IpAddrKind`. Nós
pode então, por exemplo, definir uma função que aceita qualquer `IpAddrKind`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:fn}}
```

E podemos chamar esta função com qualquer variante:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-01-defining-enums/src/main.rs:fn_call}}
```

Usar enums tem ainda mais vantagens. Pensando mais no nosso tipo de endereço IP,
no momento não temos como armazenar os _dados_ do endereço IP real; nós
só sei que _tipo_ é. Dado que você acabou de aprender sobre estruturas em
Capítulo 5, você pode ficar tentado a resolver esse problema com estruturas como mostrado em
Listagem 6-1.

<Listing number="6-1" caption="Storing the data and `IpAddrKind` variant of an IP address using a `struct`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-01/src/main.rs:here}}
```

</Listing>

Aqui, definimos uma estrutura `IpAddr` que possui dois campos: um campo `kind` que
é do tipo `IpAddrKind` (o enum que definimos anteriormente) e um campo `address`
do tipo `String`. Temos duas instâncias dessa estrutura. O primeiro é `home`,
e tem o valor `IpAddrKind::V4` como `kind` com endereço associado
dados de `127.0.0.1`. A segunda instância é `loopback`. Tem o outro
variante de `IpAddrKind` como seu valor `kind`, `V6`, e tem endereço `::1`
associado a ele. Usamos uma estrutura para agrupar `kind` e `address`
valores juntos, então agora a variante está associada ao valor.

No entanto, representar o mesmo conceito usando apenas um enum é mais conciso:
Em vez de um enum dentro de uma struct, podemos colocar dados diretamente em cada enum
variante. Esta nova definição do `IpAddr` enum diz que tanto `V4` quanto `V6`
variantes terão valores `String` associados:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-02-enum-with-data/src/main.rs:here}}
```

Anexamos dados diretamente a cada variante do enum, portanto não há necessidade de um
estrutura extra. Aqui também é mais fácil ver outro detalhe de como funcionam as enums:
O nome de cada variante enum que definimos também se torna uma função que
constrói uma instância do enum. Ou seja, `IpAddr::V4()` é uma chamada de função
que recebe um argumento `String` e retorna uma instância do tipo `IpAddr`. Nós
obter automaticamente esta função construtora definida como resultado da definição do
enum.

Há outra vantagem em usar um enum em vez de uma struct: cada variante
pode ter diferentes tipos e quantidades de dados associados. Versão quatro IP
endereços sempre terão quatro componentes numéricos que terão valores
entre 0 e 255. Se quiséssemos armazenar endereços `V4` como quatro valores `u8`, mas
ainda expressar endereços `V6` como um valor `String`, não seríamos capazes de fazê-lo com
uma estrutura. Enums lidam com esse caso com facilidade:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-03-variants-with-different-data/src/main.rs:here}}
```

Mostramos várias maneiras diferentes de definir estruturas de dados para armazenar versões
endereços IP quatro e versão seis. No entanto, ao que parece, querer armazenar
Endereços IP e codificação de que tipo são são tão comuns que [o padrão
biblioteca tem uma definição que podemos usar!][IpAddr]<!-- ignore --> Vejamos como
a biblioteca padrão define `IpAddr`. Ele tem a enumeração e variantes exatas que
definimos e usamos, mas incorpora os dados de endereço dentro das variantes em
a forma de duas estruturas diferentes, que são definidas diferentemente para cada
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

Este código ilustra que você pode colocar qualquer tipo de dado dentro de uma variante enum:
strings, tipos numéricos ou estruturas, por exemplo. Você pode até incluir outro
enum! Além disso, os tipos de biblioteca padrão geralmente não são muito mais complicados do que
o que você pode inventar.

Observe que mesmo que a biblioteca padrão contenha uma definição para `IpAddr`,
ainda podemos criar e usar nossa própria definição sem conflito porque
não trouxemos a definição da biblioteca padrão para o nosso escopo. Nós vamos conversar
mais sobre como trazer tipos para o escopo no Capítulo 7.

Vejamos outro exemplo de enum na Listagem 6-2: Este tem uma ampla
variedade de tipos incorporados em suas variantes.

<Listing number="6-2" caption="A `Message` enum whose variants each store different amounts and types of values">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-02/src/main.rs:here}}
```

</Listing>

Este enum possui quatro variantes com tipos diferentes:

- `Quit`: não possui nenhum dado associado a ele
- `Move`: Possui campos nomeados, como uma estrutura faz
- `Write`: Inclui um único `String`
- `ChangeColor`: Inclui três valores `i32`

Definir um enum com variantes como as da Listagem 6-2 é semelhante a
definindo diferentes tipos de definições de estrutura, exceto que o enum não usa o
`struct` palavra-chave e todas as variantes são agrupadas sob `Message`
tipo. As estruturas a seguir podem conter os mesmos dados que o enum anterior
variantes são mantidas:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-04-structs-similar-to-message-enum/src/main.rs:here}}
```

Mas se usarmos diferentes estruturas, cada uma com seu próprio tipo,
não poderia definir tão facilmente uma função para receber qualquer um desses tipos de mensagens como
poderíamos com o enum `Message` definido na Listagem 6-2, que é um tipo único.

Há mais uma semelhança entre enums e structs: assim como podemos
definir métodos em estruturas usando `impl`, também podemos definir métodos em
enumerações. Aqui está um método chamado `call` que poderíamos definir em nosso `Message` enum:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-05-methods-on-enums/src/main.rs:here}}
```

O corpo do método usaria `self` para obter o valor que chamamos de
método ativado. Neste exemplo, criamos uma variável `m` que tem o valor
`Message::Write(String::from("hello"))`, e é isso que `self` estará no
corpo do método `call` quando `m.call()` é executado.

Vejamos outro enum na biblioteca padrão que é muito comum e
útil: `Option`.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-option-enum-and-its-advantages-over-null-values"></a>

### O `Option` Enum

Esta seção explora um estudo de caso de `Option`, que é outro enum definido
pela biblioteca padrão. O tipo `Option` codifica o cenário muito comum em
qual um valor pode ser algo ou pode ser nada.

Por exemplo, se você solicitar o primeiro item de uma lista não vazia, você obterá
um valor. Se você solicitar o primeiro item de uma lista vazia, não receberá nada.
Expressar este conceito em termos de sistema de tipos significa que o compilador pode
verifique se você tratou de todos os casos que deveria tratar; esse
funcionalidade pode evitar bugs que são extremamente comuns em outras programações
línguas.

O design da linguagem de programação é frequentemente pensado em termos de quais recursos você
incluir, mas os recursos que você exclui também são importantes. A ferrugem não tem
recurso nulo que muitos outros idiomas possuem. _Null_ é um valor que significa que existe
não há valor aí. Em linguagens com nulo, as variáveis ​​sempre podem estar em um dos
dois estados: nulo ou não nulo.

Em sua apresentação de 2009 “Referências nulas: o erro de um bilhão de dólares”, Tony
Hoare, o inventor do nulo, disse o seguinte:

> Eu chamo isso de meu erro de um bilhão de dólares. Naquela época, eu estava projetando o primeiro
> sistema de tipos abrangente para referências em uma linguagem orientada a objetos. Meu
> O objetivo era garantir que todo uso de referências fosse absolutamente seguro, com
> verificação realizada automaticamente pelo compilador. Mas não pude resistir ao
> tentação de colocar uma referência nula, simplesmente porque era tão fácil
> implementar. Isso levou a inúmeros erros, vulnerabilidades e falhas no sistema.
> acidentes, que provavelmente causaram um bilhão de dólares de dor e danos em
> últimos quarenta anos.

O problema com valores nulos é que se você tentar usar um valor nulo como
valor não nulo, você receberá algum tipo de erro. Porque este nulo ou não nulo
propriedade é generalizada, é extremamente fácil cometer esse tipo de erro.

No entanto, o conceito que null está tentando expressar ainda é útil: A
null é um valor atualmente inválido ou ausente por algum motivo.

O problema não está realmente no conceito, mas no particular
implementação. Como tal, Rust não possui nulos, mas possui um enum
que pode codificar o conceito de um valor estar presente ou ausente. Este enum é
`Option<T>`, e é [definido pela biblioteca padrão][option]<!-- ignore -->
do seguinte modo:

```rust
enum Option<T> {
    None,
    Some(T),
}
```

O enum `Option<T>` é tão útil que até é incluído no prelúdio; você
não precisa trazê-lo explicitamente para o escopo. Suas variantes também estão incluídas em
o prelúdio: você pode usar `Some` e `None` diretamente sem o `Option::`
prefixo. O `Option<T>` enum ainda é apenas um enum normal, e `Some(T)` e
`None` ainda são variantes do tipo `Option<T>`.

A sintaxe `<T>` é um recurso do Rust sobre o qual ainda não falamos. É um
parâmetro de tipo genérico e abordaremos os genéricos com mais detalhes no Capítulo 10.
Por enquanto, tudo que você precisa saber é que `<T>` significa que a variante `Some` de
o `Option` enum pode conter um dado de qualquer tipo e que cada
tipo concreto que é usado no lugar de `T` cria o tipo geral `Option<T>`
um tipo diferente. Aqui estão alguns exemplos de uso de valores `Option` para armazenar
tipos de números e tipos de caracteres:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-06-option-examples/src/main.rs:here}}
```

O tipo de `some_number` é `Option<i32>`. O tipo de `some_char` é
`Option<char>`, que é um tipo diferente. A ferrugem pode inferir esses tipos porque
especificamos um valor dentro da variante `Some`. Para `absent_number`, Ferrugem
exige que anotemos o tipo geral `Option`: O compilador não pode inferir o
digite que a variante `Some` correspondente será mantida olhando apenas para um
`None` valor. Aqui, dizemos a Rust que queremos dizer que `absent_number` seja do tipo
`Option<i32>`.

Quando temos um valor `Some`, sabemos que um valor está presente e o valor é
realizada dentro do `Some`. Quando temos um valor `None`, em certo sentido, significa o
a mesma coisa que null: não temos um valor válido. Então, por que ter `Option<T>`
é melhor do que ter nulo?

Resumindo, porque `Option<T>` e `T` (onde `T` pode ser qualquer tipo) são diferentes
tipos, o compilador não nos permitirá usar um valor `Option<T>` como se fosse
definitivamente um valor válido. Por exemplo, este código não será compilado, porque é
tentando adicionar um `i8` a um `Option<i8>`:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-07-cant-use-option-directly/src/main.rs:here}}
```

Se executarmos este código, receberemos uma mensagem de erro como esta:

```console
{{#include ../listings/ch06-enums-and-pattern-matching/no-listing-07-cant-use-option-directly/output.txt}}
```

Intenso! Na verdade, esta mensagem de erro significa que Rust não entende como
para adicionar `i8` e `Option<i8>`, porque são tipos diferentes. Quando nós
tiver um valor de um tipo como `i8` em Rust, o compilador garantirá que
sempre tem um valor válido. Podemos prosseguir com confiança, sem ter que verificar
para null antes de usar esse valor. Somente quando temos um `Option<i8>` (ou
seja qual for o tipo de valor com o qual estamos trabalhando), precisamos nos preocupar com a possibilidade
não tendo um valor, e o compilador garantirá que lidaremos com esse caso antes
usando o valor.

Em outras palavras, você precisa converter um `Option<T>` em `T` antes de poder
execute `T` operações com ele. Geralmente, isso ajuda a capturar um dos
problemas comuns com nulo: assumir que algo não é nulo quando realmente é.

Eliminar o risco de assumir incorretamente um valor não nulo ajuda você a ser mais
confiante em seu código. Para ter um valor que possa ser nulo, você
deve aceitar explicitamente, tornando o tipo desse valor `Option<T>`. Então, quando
você usar esse valor, será necessário lidar explicitamente com o caso quando o
o valor é nulo. Em todos os lugares onde um valor tem um tipo que não é `Option<T>`,
você _pode_ assumir com segurança que o valor não é nulo. Este foi um projeto deliberado
decisão do Rust para limitar a difusão do null e aumentar a segurança do Rust
código.

Então, como você obtém o valor `T` de uma variante `Some` quando você tem um valor
do tipo `Option<T>` para que você possa usar esse valor? O `Option<T>` enum tem um
grande número de métodos que são úteis em diversas situações; você pode
confira em [sua documentação][docs]<!-- ignore -->. Tornando-se familiar
com os métodos em `Option<T>` será extremamente útil em sua jornada com
Ferrugem.

Em geral, para usar um valor `Option<T>`, você deseja ter um código que
irá lidar com cada variante. Você quer algum código que será executado somente quando você tiver um
`Some(T)`, e este código pode usar o `T` interno. Você quer um pouco
outro código para ser executado somente se você tiver um valor `None` e esse código não tiver um
`T` valor disponível. A expressão `match` é uma construção de fluxo de controle que
faz exatamente isso quando usado com enums: ele executará códigos diferentes dependendo de
qual variante do enum ele possui, e esse código pode usar os dados dentro do
valor correspondente.

[IpAddr]: ../std/net/enum.IpAddr.html
[option]: ../std/option/enum.Option.html
[docs]: ../std/option/enum.Option.html
