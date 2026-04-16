<!-- Old headings. Do not remove or links may break. -->

<a id="closures-anonymous-functions-that-can-capture-their-environment"></a>
<a id="closures-anonymous-functions-that-capture-their-environment"></a>

## Closures

As closures de Rust são funções anônimas que você pode armazenar em uma
variável ou passar como argumentos para outras funções. Você pode criar uma
closure em um lugar e depois chamá-la em outro para avaliá-la em um contexto
diferente. Ao contrário das funções, closures podem capturar valores do escopo
em que são definidas. Vamos demonstrar como esses recursos de closures
permitem reutilizar código e personalizar comportamentos.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-an-abstraction-of-behavior-with-closures"></a>
<a id="refactoring-using-functions"></a>
<a id="refactoring-with-closures-to-store-code"></a>
<a id="capturing-the-environment-with-closures"></a>

### Capturando o Ambiente

Primeiro, vamos examinar como podemos usar closures para capturar valores do
ambiente em que são definidas para uso posterior. O cenário é o seguinte: de
tempos em tempos, nossa empresa de camisetas distribui uma camiseta exclusiva,
de edição limitada, para alguém da nossa lista de e-mails como promoção. As
pessoas na lista de e-mails podem opcionalmente adicionar sua cor favorita ao
perfil. Se a pessoa escolhida para ganhar a camiseta tiver uma cor favorita
definida, ela recebe uma camiseta dessa cor. Se não tiver especificado uma cor
favorita, ela recebe a cor da qual a empresa tem mais unidades no momento.

Há muitas formas de implementar isso. Neste exemplo, vamos usar um enum
chamado `ShirtColor`, com as variantes `Red` e `Blue` para simplificar o
número de cores disponíveis. Representamos o estoque da empresa com uma struct
`Inventory`, que tem um campo chamado `shirts` contendo um
`Vec<ShirtColor>` que representa as cores das camisetas atualmente em estoque.
O método `giveaway`, definido em `Inventory`, recebe a preferência opcional de
cor da pessoa sorteada e retorna a cor da camiseta que ela vai receber. Essa
configuração é mostrada na Listagem 13-1.

<Listing number="13-1" file-name="src/main.rs" caption="Situação de sorteio de camisetas de uma empresa">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-01/src/main.rs}}
```

</Listing>

O `store` definido em `main` tem duas camisetas azuis e uma vermelha restantes
para distribuir nessa promoção de edição limitada. Chamamos o método
`giveaway` para uma pessoa que prefere camiseta vermelha e para outra sem
nenhuma preferência.

Mais uma vez, esse código poderia ser implementado de várias maneiras, e aqui,
para manter o foco em closures, ficamos com conceitos que você já aprendeu,
exceto pelo corpo do método `giveaway`, que usa uma closure. No método
`giveaway`, recebemos a preferência do usuário como um parâmetro do tipo
`Option<ShirtColor>` e chamamos o método `unwrap_or_else` em
`user_preference`. O [método `unwrap_or_else` em `Option<T>`][unwrap-or-else]
<!-- ignore --> é definido pela biblioteca padrão. Ele recebe um argumento:
uma closure sem parâmetros que retorna um valor `T` (o mesmo tipo armazenado
na variante `Some` de `Option<T>`, neste caso `ShirtColor`). Se o `Option<T>`
for a variante `Some`, `unwrap_or_else` retorna o valor dentro de `Some`. Se
for a variante `None`, `unwrap_or_else` chama a closure e retorna o valor
produzido por ela.

Especificamos a expressão de closure `|| self.most_stocked()` como argumento de
`unwrap_or_else`. Essa é uma closure que não recebe parâmetros (se tivesse,
eles apareceriam entre as duas barras verticais). O corpo da closure chama
`self.most_stocked()`. Estamos definindo a closure aqui, e a implementação de
`unwrap_or_else` vai avaliá-la depois, se o resultado for necessário.

A execução deste código imprime o seguinte:

```console
{{#include ../listings/ch13-functional-features/listing-13-01/output.txt}}
```

Um aspecto interessante aqui é que passamos uma closure que chama
`self.most_stocked()` na instância atual de `Inventory`. A biblioteca padrão
não precisou saber nada sobre os tipos `Inventory` ou `ShirtColor` que
definimos, nem sobre a lógica que queremos usar nesse cenário. A closure
captura uma referência imutável à instância `self` de `Inventory` e a passa,
junto com o código que especificamos, para o método `unwrap_or_else`.
Funções, por outro lado, não conseguem capturar o ambiente dessa maneira.

<!-- Old headings. Do not remove or links may break. -->

<a id="closure-type-inference-and-annotation"></a>

### Inferindo e Anotando Tipos de Closures

Há mais diferenças entre funções e closures. Em geral, closures não exigem que
você anote os tipos dos parâmetros nem o valor de retorno, como acontece com
as funções `fn`. Anotações de tipo são necessárias em funções porque os tipos
fazem parte de uma interface explícita exposta a quem usa seu código. Definir
essa interface rigidamente é importante para garantir que todos concordem
sobre quais tipos de valores uma função usa e retorna. Closures, por outro
lado, não são usadas em uma interface exposta dessa forma: elas ficam
armazenadas em variáveis e são usadas sem receber um nome e sem serem expostas
às pessoas usuárias da nossa biblioteca.

Closures normalmente são curtas e relevantes apenas dentro de um contexto
restrito, em vez de em qualquer cenário arbitrário. Dentro desses contextos
limitados, o compilador consegue inferir os tipos dos parâmetros e o tipo de
retorno, de maneira semelhante ao que faz com a maioria das variáveis
(existem casos raros em que o compilador também precisa de anotações de tipo
em closures).

Assim como acontece com variáveis, podemos adicionar anotações de tipo se
quisermos tornar o código mais explícito e claro, ao custo de deixá-lo mais
verboso do que o estritamente necessário. Anotar os tipos de uma closure
ficaria como na definição mostrada na Listagem 13-2. Neste exemplo, estamos
definindo uma closure e armazenando-a em uma variável, em vez de defini-la no
próprio lugar em que a passamos como argumento, como fizemos na Listagem
13-1.

<Listing number="13-2" file-name="src/main.rs" caption="Adicionando anotações opcionais de tipo para o parâmetro e o valor de retorno na closure">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-02/src/main.rs:here}}
```

</Listing>

Com as anotações de tipo adicionadas, a sintaxe de closures fica mais parecida
com a sintaxe de funções. Aqui, definimos uma função que soma 1 ao seu
parâmetro e uma closure com o mesmo comportamento, para fins de comparação.
Adicionamos alguns espaços para alinhar as partes relevantes. Isso ilustra como
a sintaxe de closures é parecida com a de funções, exceto pelo uso das barras
verticais e pela quantidade de sintaxe que é opcional:

```rust,ignore
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

A primeira linha mostra uma definição de função, e a segunda mostra uma
definição de closure com anotações completas. Na terceira linha, removemos as
anotações de tipo da definição da closure. Na quarta, removemos as chaves, que
são opcionais porque o corpo da closure tem apenas uma expressão. Todas essas
são definições válidas que produzirão o mesmo comportamento quando forem
chamadas. As linhas `add_one_v3` e `add_one_v4` exigem que as closures sejam
avaliadas para que possam compilar, porque os tipos serão inferidos com base
no uso. Isso é semelhante ao fato de `let v = Vec::new();` precisar de
anotações de tipo ou de valores de algum tipo inseridos em `Vec` para que Rust
consiga inferir o tipo.

Para definições de closures, o compilador vai inferir um tipo concreto para
cada parâmetro e para o valor de retorno. Por exemplo, a Listagem 13-3 mostra
a definição de uma closure curta que simplesmente retorna o valor que recebe
como parâmetro. Essa closure não é muito útil fora do contexto deste exemplo.
Observe que não adicionamos nenhuma anotação de tipo à definição. Como não há
anotações de tipo, podemos chamar a closure com qualquer tipo, e aqui fizemos
isso pela primeira vez com `String`. Se depois tentarmos chamar
`example_closure` com um inteiro, teremos um erro.

<Listing number="13-3" file-name="src/main.rs" caption="Tentando chamar uma closure cujos tipos inferidos são dois tipos diferentes">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-03/src/main.rs:here}}
```

</Listing>

O compilador nos dá este erro:

```console
{{#include ../listings/ch13-functional-features/listing-13-03/output.txt}}
```

Na primeira vez que chamamos `example_closure` com o valor `String`, o
compilador infere que o tipo de `x` e o tipo de retorno da closure são
`String`. Esses tipos então ficam fixados na closure em `example_closure`, e
recebemos um erro de tipo quando tentamos usar um tipo diferente com a mesma
closure.

### Capturando Referências ou Movendo Ownership

Closures podem capturar valores do ambiente de três maneiras, que correspondem
diretamente às três maneiras pelas quais uma função pode receber um parâmetro:
emprestando de forma imutável, emprestando de forma mutável e tomando
ownership. A closure decidirá qual dessas abordagens usar com base no que o
corpo da função faz com os valores capturados.

Na Listagem 13-4, definimos uma closure que captura uma referência imutável ao
vetor chamado `list`, porque ela só precisa de uma referência imutável para
imprimir o valor.

<Listing number="13-4" file-name="src/main.rs" caption="Definindo e chamando uma closure que captura uma referência imutável">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-04/src/main.rs}}
```

</Listing>

Este exemplo também ilustra que uma variável pode se ligar a uma definição de
closure, e depois podemos chamar a closure usando o nome da variável e
parênteses, como se o nome da variável fosse o nome de uma função.

Como podemos ter várias referências imutáveis a `list` ao mesmo tempo, `list`
continua acessível no código antes da definição da closure, depois da
definição mas antes da chamada, e depois que a closure é chamada. Esse código
compila, executa e imprime:

```console
{{#include ../listings/ch13-functional-features/listing-13-04/output.txt}}
```

A seguir, na Listagem 13-5, alteramos o corpo da closure para que ela adicione
um elemento ao vetor `list`. Agora a closure captura uma referência mutável.

<Listing number="13-5" file-name="src/main.rs" caption="Definindo e chamando uma closure que captura uma referência mutável">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-05/src/main.rs}}
```

</Listing>

Este código compila, executa e imprime:

```console
{{#include ../listings/ch13-functional-features/listing-13-05/output.txt}}
```

Observe que não há mais um `println!` entre a definição e a chamada da closure
`borrows_mutably`: quando `borrows_mutably` é definida, ela captura uma
referência mutável a `list`. Não usamos a closure de novo depois que ela é
chamada, então o empréstimo mutável termina ali. Entre a definição da closure
e sua chamada, não é permitido fazer um empréstimo imutável para imprimir,
porque nenhum outro empréstimo é permitido enquanto existe um empréstimo
mutável. Tente adicionar um `println!` ali para ver qual mensagem de erro você
obtém!

Se quiser forçar a closure a tomar ownership dos valores que ela usa do
ambiente, mesmo quando o corpo da closure não precisa estritamente de
ownership, você pode usar a palavra-chave `move` antes da lista de parâmetros.

Essa técnica é especialmente útil quando passamos uma closure para uma nova
thread, movendo os dados para que passem a pertencer à nova thread. Vamos
discutir threads e por que você pode querer usá-las em detalhes no Capítulo
16, quando falarmos sobre concorrência. Por enquanto, vamos apenas explorar
brevemente a criação de uma nova thread usando uma closure que precisa da
palavra-chave `move`. A Listagem 13-6 mostra a Listagem 13-4 modificada para
imprimir o vetor em uma nova thread em vez de na thread principal.

<Listing number="13-6" file-name="src/main.rs" caption="Usando `move` para forçar a closure da thread a tomar ownership de `list`">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-06/src/main.rs}}
```

</Listing>

Criamos uma nova thread e passamos para ela uma closure a ser executada. O
corpo da closure imprime a lista. Na Listagem 13-4, a closure capturava `list`
apenas por meio de uma referência imutável, porque esse era o menor nível de
acesso necessário para imprimi-la. Neste exemplo, embora o corpo da closure
ainda precise apenas de uma referência imutável, precisamos especificar que
`list` deve ser movido para dentro da closure, colocando a palavra-chave
`move` no início da definição. Se a thread principal executasse mais operações
antes de chamar `join` na nova thread, a nova thread poderia terminar antes do
resto da thread principal, ou a thread principal poderia terminar primeiro. Se
a thread principal mantivesse ownership de `list`, mas terminasse antes da nova
thread e descartasse `list`, a referência imutável na thread ficaria inválida.
Por isso, o compilador exige que `list` seja movido para a closure passada à
nova thread, para que a referência continue válida. Tente remover a palavra
`move` ou usar `list` na thread principal depois que a closure for definida
para ver quais erros do compilador você recebe!

<!-- Old headings. Do not remove or links may break. -->

<a id="storing-closures-using-generic-parameters-and-the-fn-traits"></a>
<a id="limitations-of-the-cacher-implementation"></a>
<a id="moving-captured-values-out-of-the-closure-and-the-fn-traits"></a>
<a id="moving-captured-values-out-of-closures-and-the-fn-traits"></a>

### Movendo Valores Capturados para Fora de Closures

Depois que uma closure capturou uma referência ou tomou ownership de um valor
do ambiente em que foi definida, o código em seu corpo determina o que acontece
com essas referências ou valores quando a closure for avaliada mais tarde.
Isso afeta o que, se é que algo é, movido _para dentro_ e _para fora_ da
closure.

O corpo de uma closure pode fazer qualquer uma das seguintes coisas: mover para
fora da closure um valor capturado, modificar o valor capturado, não mover nem
modificar o valor, ou nem sequer capturar algo do ambiente.

A forma como uma closure captura e trata valores do ambiente afeta quais traits
ela implementa, e traits são a maneira como funções e structs podem especificar
que tipos de closures conseguem usar. Closures implementam automaticamente uma,
duas ou as três traits `Fn`, de maneira acumulativa, dependendo de como o
corpo da closure lida com os valores:

* `FnOnce` se aplica a closures que podem ser chamadas uma vez. Todas as
  closures implementam pelo menos essa trait, porque todas podem ser chamadas.
  Uma closure que move valores capturados para fora do próprio corpo
  implementará apenas `FnOnce`, e nenhuma das outras traits `Fn`, porque só
  pode ser chamada uma vez.
* `FnMut` se aplica a closures que não movem valores capturados para fora do
  próprio corpo, mas podem modificar os valores capturados. Essas closures
  podem ser chamadas mais de uma vez.
* `Fn` se aplica a closures que não movem valores capturados para fora do
  próprio corpo nem modificam valores capturados, bem como a closures que não
  capturam nada do ambiente. Essas closures podem ser chamadas mais de uma vez
  sem modificar o ambiente, o que é importante em casos como chamar uma
  closure várias vezes de forma concorrente.

Vamos olhar a definição do método `unwrap_or_else` em `Option<T>`, que usamos
na Listagem 13-1:

```rust,ignore
impl<T> Option<T> {
    pub fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T
    {
        match self {
            Some(x) => x,
            None => f(),
        }
    }
}
```

Lembre-se de que `T` é o tipo genérico que representa o tipo do valor na
variante `Some` de um `Option`. Esse tipo `T` também é o tipo de retorno de
`unwrap_or_else`: um código que chama `unwrap_or_else` em um
`Option<String>`, por exemplo, receberá um `String`.

Agora, observe que a função `unwrap_or_else` tem um parâmetro de tipo genérico
adicional, `F`. O tipo `F` é o tipo do parâmetro chamado `f`, que é a closure
que fornecemos ao chamar `unwrap_or_else`.

O limite de trait especificado sobre o tipo genérico `F` é `FnOnce() -> T`, o
que significa que `F` precisa poder ser chamado uma vez, não receber
argumentos e retornar um `T`. Usar `FnOnce` no limite de trait expressa a
restrição de que `unwrap_or_else` não chamará `f` mais de uma vez. No corpo de
`unwrap_or_else`, vemos que, se o `Option` for `Some`, `f` não será chamado.
Se o `Option` for `None`, `f` será chamado uma vez. Como todas as closures
implementam `FnOnce`, `unwrap_or_else` aceita os três tipos de closures e é o
mais flexível possível.

> Nota: se o que queremos fazer não exigir capturar um valor do ambiente,
> podemos usar o nome de uma função no lugar de uma closure quando precisarmos
> de algo que implemente uma das traits `Fn`. Por exemplo, em um valor
> `Option<Vec<T>>`, poderíamos chamar `unwrap_or_else(Vec::new)` para obter um
> novo vetor vazio se o valor for `None`. O compilador implementa
> automaticamente a trait `Fn` apropriada para uma definição de função.

Agora, vamos observar o método `sort_by_key`, da biblioteca padrão, definido em
slices, para ver como ele difere de `unwrap_or_else` e por que usa `FnMut`, em
vez de `FnOnce`, como limite de trait. A closure recebe um argumento na forma
de uma referência ao item atual do slice que está sendo considerado e retorna
um valor do tipo `K`, que pode ser ordenado. Essa função é útil quando você
quer ordenar um slice por um atributo específico de cada item. Na Listagem
13-7, temos uma lista de instâncias de `Rectangle` e usamos `sort_by_key` para
ordená-las pelo atributo `width`, da menor para a maior.

<Listing number="13-7" file-name="src/main.rs" caption="Usando `sort_by_key` para ordenar retângulos pela largura">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-07/src/main.rs}}
```

</Listing>

Este código imprime:

```console
{{#include ../listings/ch13-functional-features/listing-13-07/output.txt}}
```

A razão pela qual `sort_by_key` é definido para receber uma closure `FnMut` é
que ele a chama várias vezes: uma vez para cada item do slice. A closure
`|r| r.width` não captura, não modifica nem move nada para fora do seu
ambiente, então ela satisfaz os requisitos do limite de trait.

Em contraste, a Listagem 13-8 mostra um exemplo de closure que implementa
apenas a trait `FnOnce`, porque move um valor para fora do ambiente. O
compilador não vai permitir que usemos essa closure com `sort_by_key`.

<Listing number="13-8" file-name="src/main.rs" caption="Tentando usar uma closure `FnOnce` com `sort_by_key`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-08/src/main.rs}}
```

</Listing>

Essa é uma forma artificial e complicada, que não funciona, de tentar contar o
número de vezes que `sort_by_key` chama a closure ao ordenar `list`. Esse
código tenta fazer a contagem inserindo `value`, uma `String` do ambiente da
closure, no vetor `sort_operations`. A closure captura `value` e então move
`value` para fora da closure ao transferir ownership de `value` para o vetor
`sort_operations`. Essa closure só pode ser chamada uma vez; tentar chamá-la
uma segunda vez não funcionaria, porque `value` não estaria mais no ambiente
para ser inserido em `sort_operations` novamente! Portanto, essa closure
implementa apenas `FnOnce`. Quando tentamos compilar esse código, recebemos o
erro de que `value` não pode ser movido para fora da closure porque a closure
precisa implementar `FnMut`:

```console
{{#include ../listings/ch13-functional-features/listing-13-08/output.txt}}
```

O erro aponta para a linha do corpo da closure que move `value` para fora do
ambiente. Para corrigir isso, precisamos mudar o corpo da closure para que ela
não mova valores para fora do ambiente. Manter um contador no ambiente e
incrementar seu valor no corpo da closure é uma forma mais direta de contar o
número de vezes que a closure é chamada. A closure da Listagem 13-9 funciona
com `sort_by_key` porque ela captura apenas uma referência mutável ao contador
`num_sort_operations` e, por isso, pode ser chamada mais de uma vez.

<Listing number="13-9" file-name="src/main.rs" caption="Usar uma closure `FnMut` com `sort_by_key` é permitido">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-09/src/main.rs}}
```

</Listing>

As traits `Fn` são importantes ao definir ou usar funções e tipos que fazem uso
de closures. Na próxima seção, vamos discutir iteradores. Muitos métodos de
iteradores recebem closures como argumento, então vale a pena manter esses
detalhes em mente enquanto avançamos!

[unwrap-or-else]: ../std/option/enum.Option.html#method.unwrap_or_else
