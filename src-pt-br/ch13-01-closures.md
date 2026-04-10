<!-- Old headings. Do not remove or links may break. -->

<a id="closures-anonymous-functions-that-can-capture-their-environment"></a>
<a id="closures-anonymous-functions-that-capture-their-environment"></a>

## Closures

closures do Rust são funções anônimas que você pode salvar em uma variável ou passar como
argumentos para outras funções. Você pode criar o closure em um só lugar e depois
chame o closure em outro lugar para avaliá-lo em um contexto diferente. Ao contrário
funções, closures pode capturar valores do escopo em que estão definidos.
Demonstraremos como esses recursos do closure permitem a reutilização e comportamento de código
personalização.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-an-abstraction-of-behavior-with-closures"></a>
<a id="refactoring-using-functions"></a>
<a id="refactoring-with-closures-to-store-code"></a>
<a id="capturing-the-environment-with-closures"></a>

### Capturando o Meio Ambiente

Examinaremos primeiro como podemos usar closures para capturar valores do
ambiente em que estão definidos para uso posterior. Aqui está o cenário: de vez em quando
frequentemente, nossa empresa de camisetas distribui uma camisa exclusiva de edição limitada para
alguém em nossa mailing list como uma promoção. As pessoas na lista de discussão podem
opcionalmente, adicione sua cor favorita ao perfil. Se a pessoa escolhida para
uma camisa grátis tem seu conjunto de cores favoritas, eles ficam com aquela camisa colorida. Se o
pessoa não especificou uma cor favorita, ela obtém a cor que a empresa
atualmente tem a maior parte.

Existem muitas maneiras de implementar isso. Para este exemplo, usaremos um
enum chamado `ShirtColor` que possui as variantes `Red` e `Blue` (limitando o
número de cores disponíveis para simplificar). Representamos a empresa
inventário com uma estrutura `Inventory` que possui um campo chamado `shirts` que
contém um `Vec<ShirtColor>` representando as cores da camisa atualmente em estoque.
O método `giveaway` definido em `Inventory` obtém a cor opcional da camisa
preferência do ganhador da camisa grátis, e retorna a cor da camisa
pessoa vai conseguir. Essa configuração é mostrada na Listagem 13-1.

<Listing number="13-1" file-name="src/main.rs" caption="Situação de sorteio de camisetas de uma empresa">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-01/src/main.rs}}
```

</Listing>

O `store` definido em `main` tem duas camisas azuis e uma camisa vermelha restantes
para distribuir nesta promoção de edição limitada. Chamamos o método `giveaway`
para um usuário com preferência pela camisa vermelha e um usuário sem nenhuma preferência.

Novamente, este código poderia ser implementado de várias maneiras, e aqui, para focar
closures, nos apegamos aos conceitos que você já aprendeu, exceto o corpo do
o método `giveaway` que usa um closure. No método `giveaway`, obtemos o
preferência do usuário como um parâmetro do tipo ` Option<ShirtColor>`e chame o
Método ` unwrap_or_else`em ` user_preference`. O [método ` unwrap_or_else`em
` Option<T> `][unwrap-or-else]<!-- ignore --> é definido pela biblioteca padrão.
Leva um argumento: um closure sem nenhum argumento que retorna um valor` T `
(o mesmo tipo armazenado na variante` Some `do` Option<T> `, neste caso
` ShirtColor `). Se` Option<T> `for a variante` Some `,` unwrap_or_else `
retorna o valor de dentro do` Some `. Se o` Option<T> `for o` None `
variante,` unwrap_or_else`chama closure e retorna o valor retornado por
o closure.

Especificamos a expressão closure `|| self.most_stocked()` como argumento para
`unwrap_or_else`. Este é um closure que não aceita parâmetros (se o
closure tinha parâmetros, eles apareceriam entre os dois tubos verticais). O
corpo do closure chama `self.most_stocked()`. Estamos definindo o closure
aqui, e a implementação do `unwrap_or_else` avaliará o closure
mais tarde, se o resultado for necessário.

A execução deste código imprime o seguinte:

```console
{{#include ../listings/ch13-functional-features/listing-13-01/output.txt}}
```

Um aspecto interessante aqui é que passamos um closure que chama
`self.most_stocked() ` na instância`Inventory ` atual. A biblioteca padrão
não precisávamos saber nada sobre os tipos`Inventory ` ou`ShirtColor ` que
definido, ou a lógica que queremos usar neste cenário. O closure captura um
referência imutável à instância`self` ` Inventory`e passa-a com o
código que especificamos para o método ` unwrap_or_else`. As funções, por outro lado,
não são capazes de capturar seu ambiente dessa maneira.

<!-- Old headings. Do not remove or links may break. -->

<a id="closure-type-inference-and-annotation"></a>

### Inferindo e anotando tipos de fechamento

Existem mais diferenças entre funções e closures. Os fechamentos não
geralmente exigem que você anote os tipos dos parâmetros ou o valor de retorno
como fazem as funções `fn`. Anotações de tipo são necessárias em funções porque o
tipos fazem parte de uma interface explícita exposta aos seus usuários. Definindo isso
interface rigidamente é importante para garantir que todos concordem sobre quais tipos
de valores que uma função usa e retorna. Os fechamentos, por outro lado, não são usados
em uma interface exposta como esta: eles são armazenados em variáveis e são
usados sem nomeá-los e expô-los aos usuários de nossa biblioteca.

Os encerramentos são normalmente curtos e relevantes apenas dentro de um contexto restrito, em vez de
do que em qualquer cenário arbitrário. Dentro desses contextos limitados, o compilador pode
inferir os tipos dos parâmetros e o tipo de retorno, semelhante a como é capaz
para inferir os tipos da maioria das variáveis (há raros casos em que o compilador
também precisa de anotações do tipo closure).

Tal como acontece com as variáveis, podemos adicionar anotações de tipo se quisermos aumentar
explicitação e clareza ao custo de ser mais prolixo do que é estritamente
necessário. Anotar os tipos para um closure seria parecido com a definição
mostrado na Listagem 13-2. Neste exemplo, estamos definindo um closure e armazenando-o
em uma variável, em vez de definir closure no local, passamos-o como um
argumento, como fizemos na Listagem 13-1.

<Listing number="13-2" file-name="src/main.rs" caption="Adicionando anotações opcionais de tipo para o parâmetro e o valor de retorno na closure">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-02/src/main.rs:here}}
```

</Listing>

Com anotações de tipo adicionadas, a sintaxe de closures parece mais semelhante à
sintaxe de funções. Aqui, definimos uma função que adiciona 1 ao seu parâmetro e
um closure que tem o mesmo comportamento, para comparação. Adicionamos alguns espaços
para alinhar as partes relevantes. Isso ilustra como a sintaxe closure é semelhante
para funcionar a sintaxe, exceto pelo uso de barras verticais e pela quantidade de sintaxe que é
opcional:

```rust,ignore
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

A primeira linha mostra uma definição de função e a segunda linha mostra uma definição completa
definição closure anotada. Na terceira linha, removemos as anotações de tipo
da definição closure. Na quarta linha, removemos os colchetes, que
são opcionais porque o corpo closure possui apenas uma expressão. Estes são todos
definições válidas que produzirão o mesmo comportamento quando forem chamadas. O
As linhas `add_one_v3` e `add_one_v4` exigem que o closures seja avaliado para ser
capaz de compilar porque os tipos serão inferidos de seu uso. Isto é
semelhante ao `let v = Vec::new();`, necessitando de anotações de tipo ou valores de
algum tipo a ser inserido no ` Vec`para que Rust possa inferir o tipo.

Para definições closure, o compilador inferirá um tipo concreto para cada um dos
seus parâmetros e seu valor de retorno. Por exemplo, a Listagem 13-3 mostra
a definição de um closure curto que apenas retorna o valor que recebe como
parâmetro. Este closure não é muito útil, exceto para os propósitos deste
exemplo. Observe que não adicionamos nenhuma anotação de tipo à definição.
Como não há anotações de tipo, podemos chamar closure com qualquer tipo,
o que fizemos aqui com `String` pela primeira vez. Se então tentarmos ligar
`example_closure` com um número inteiro, obteremos um erro.

<Listing number="13-3" file-name="src/main.rs" caption="Tentando chamar uma closure cujos tipos inferidos são dois tipos diferentes">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-03/src/main.rs:here}}
```

</Listing>

O compilador nos dá este erro:

```console
{{#include ../listings/ch13-functional-features/listing-13-03/output.txt}}
```

Na primeira vez que chamamos `example_closure` com o valor `String`, o compilador
infere que o tipo de ` x`e o tipo de retorno de closure são ` String`. Aqueles
tipos são então bloqueados no closure em ` example_closure`, e obtemos um tipo
erro quando tentarmos usar um tipo diferente com o mesmo closure.

### Capturando referências ou transferindo ownership

Os encerramentos podem capturar valores do seu ambiente de três maneiras, que
mapeie diretamente as três maneiras pelas quais uma função pode receber um parâmetro: borrowing
imutável, borrowing mutável e tomando ownership. O closure decidirá
qual deles usar com base no que o corpo da função faz com o
valores capturados.

Na Listagem 13-4, definimos um closure que captura uma referência imutável para
o vetor denominado `list` porque ele só precisa de uma referência imutável para imprimir
o valor.

<Listing number="13-4" file-name="src/main.rs" caption="Definindo e chamando uma closure que captura uma referência imutável">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-04/src/main.rs}}
```

</Listing>

Este exemplo também ilustra que uma variável pode ser vinculada a uma definição closure,
e mais tarde podemos chamar closure usando o nome da variável e parênteses como
se o nome da variável fosse um nome de função.

Como podemos ter várias referências imutáveis a `list` ao mesmo tempo,
`list` ainda está acessível a partir do código antes da definição closure, depois
a definição closure, mas antes de closure ser chamado e depois de closure
é chamado. Este código compila, executa e imprime:

```console
{{#include ../listings/ch13-functional-features/listing-13-04/output.txt}}
```

A seguir, na Listagem 13-5, alteramos o corpo closure para que ele adicione um elemento ao
o vetor `list`. O closure agora captura uma referência mutável.

<Listing number="13-5" file-name="src/main.rs" caption="Definindo e chamando uma closure que captura uma referência mutável">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-05/src/main.rs}}
```

</Listing>

Este código compila, executa e imprime:

```console
{{#include ../listings/ch13-functional-features/listing-13-05/output.txt}}
```

Observe que não há mais `println!` entre a definição e a chamada de
o `borrows_mutably` closure: Quando `borrows_mutably` é definido, ele captura um
referência mutável para `list`. Não usamos o closure novamente depois do closure
é chamado, então o borrowing mutável termina. Entre a definição closure e o
chamada closure, um borrowing imutável para impressão não é permitido, porque nenhum outro
borrowing são permitidos quando há um borrowing mutável. Tente adicionar um ` println!`
lá para ver qual mensagem de erro você recebe!

Se você quiser forçar o closure a pegar ownership dos valores que ele usa no
ambiente, mesmo que o corpo do closure não precise estritamente
ownership, você pode usar a palavra-chave `move` antes da lista de parâmetros.

Esta técnica é mais útil ao passar um closure para um novo thread para mover
os dados para que sejam ownership do novo thread. Discutiremos threads e por quê
você gostaria de usá-los em detalhes no Capítulo 16, quando falamos sobre
simultaneidade, mas por enquanto, vamos explorar brevemente a geração de um novo thread usando um
closure que precisa da palavra-chave `move`. A Listagem 13-6 mostra a Listagem 13-4 modificada
para imprimir o vetor em um novo thread em vez de no thread principal.

<Listing number="13-6" file-name="src/main.rs" caption="Usando `move` para forçar a closure da thread a tomar ownership de `list`">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-06/src/main.rs}}
```

</Listing>

Geramos um novo thread, dando ao thread um closure para ser executado como argumento. O
O corpo closure imprime a lista. Na Listagem 13-4, o closure capturou apenas
`list ` usando uma referência imutável porque é a menor quantidade de acesso
para`list ` necessário para imprimi-lo. Neste exemplo, mesmo que o corpo closure
ainda precisa apenas de uma referência imutável, precisamos especificar que`list ` deve
ser movido para o closure colocando a palavra-chave`move ` no início do
Definição closure. Se o thread principal executou mais operações antes de chamar
`join ` no novo thread, o novo thread pode terminar antes do resto do
o thread principal termina, ou o thread principal pode terminar primeiro. Se o thread principal
manteve ownership de`list ` mas terminou antes do novo thread e descarta
`list `, a referência imutável no thread seria inválida. Portanto, o
o compilador requer que` list `seja movido para o closure fornecido ao novo thread
para que a referência seja válida. Tente remover a palavra-chave` move `ou usar
` list`no thread principal após o closure ser definido para ver qual compilador
erros que você recebe!

<!-- Old headings. Do not remove or links may break. -->

<a id="storing-closures-using-generic-parameters-and-the-fn-traits"></a>
<a id="limitations-of-the-cacher-implementation"></a>
<a id="moving-captured-values-out-of-the-closure-and-the-fn-traits"></a>
<a id="moving-captured-values-out-of-closures-and-the-fn-traits"></a>

### Moving Captured Values Out of Closures

Depois que um closure capturou uma referência ou capturou ownership de um valor de
o ambiente onde o closure é definido (afetando assim o que, se houver,
é movido _para_ o closure), o código no corpo do closure define o que
acontece com as referências ou valores quando o closure é avaliado posteriormente (portanto
afetando o que, se houver, é movido _para fora_ do closure).

Um corpo closure pode fazer o seguinte: Mover um valor capturado para fora do
closure, altere o valor capturado, não mova nem altere o valor ou
para começar, não capture nada do ambiente.

A maneira como um closure captura e trata valores do ambiente afeta
qual traits o closure implementa, e traits são como funções e estruturas
podem especificar quais tipos de closures eles podem usar. Os fechamentos serão automaticamente
implementar um, dois ou todos os três `Fn` traits, de forma aditiva,
dependendo de como o corpo do closure lida com os valores:

* `FnOnce` se aplica a closures que pode ser chamado uma vez. Todos os implementos closures
  pelo menos este trait porque todos os closures podem ser chamados. Um closure que se move
  valores capturados fora de seu corpo implementarão apenas `FnOnce` e nenhum dos
  outro `Fn` traits porque só pode ser chamado uma vez.
* `FnMut` se aplica a closures que não move valores capturados para fora de seu corpo
  mas pode alterar os valores capturados. Esses closures podem ser chamados de mais de
  uma vez.
* `Fn` aplica-se a closures que não move valores capturados para fora de seu corpo
  e não altera os valores capturados, bem como closures que não captura nada
  do seu ambiente. Estes closures podem ser chamados mais de uma vez sem
  alterando seu ambiente, o que é importante em casos como chamar um closure várias vezes simultaneamente.

Vejamos a definição do método `unwrap_or_else` em `Option<T>` que
usamos na Listagem 13-1:

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

Lembre-se de que `T` é o tipo genérico que representa o tipo do valor no
Variante `Some` de um `Option`. Esse tipo ` T`também é o tipo de retorno do
Função ` unwrap_or_else`: Código que chama ` unwrap_or_else`em um
` Option<String> `, por exemplo, receberá um` String`.

A seguir, observe que a função `unwrap_or_else` possui o tipo genérico adicional
parâmetro `F`. O tipo ` F`é o tipo do parâmetro denominado ` f`, que é
o closure que fornecemos ao chamar ` unwrap_or_else`.

O limite trait especificado no tipo genérico `F` é `FnOnce() -> T`, que
significa que ` F`deve poder ser chamado uma vez, não receber argumentos e retornar um ` T`.
Usar ` FnOnce`no limite trait expressa a restrição que
` unwrap_or_else `não chamará` f `mais de uma vez. No corpo de
` unwrap_or_else `, podemos ver que se` Option `for` Some `,` f `não será
chamado. Se` Option `for` None `,` f `será chamado uma vez. Porque tudo
closures implementa` FnOnce `,` unwrap_or_else`aceita todos os três tipos de
closures e é tão flexível quanto possível.

> Nota: Se o que queremos fazer não requer a captura de um valor do
> ambiente, podemos usar o nome de uma função em vez de closure onde
> preciso de algo que implemente um dos `Fn` traits. Por exemplo, em um
> Valor `Option<Vec<T>>`, poderíamos chamar ` unwrap_or_else(Vec::new)`para obter um
> novo vetor vazio se o valor for ` None`. O compilador automaticamente
> implementa qualquer ` Fn`traits aplicável para uma função
> definição.

Agora vamos dar uma olhada no método da biblioteca padrão `sort_by_key`, definido em slices,
para ver como isso difere de ` unwrap_or_else`e por que ` sort_by_key`usa
` FnMut `em vez de` FnOnce `para o limite trait. O closure recebe um argumento
na forma de uma referência ao item atual no slice sendo considerado,
e retorna um valor do tipo` K `que pode ser solicitado. Esta função é útil
quando você deseja classificar um slice por um atributo específico de cada item. Em
Listagem 13-7, temos uma lista de instâncias` Rectangle `e usamos` sort_by_key `
para ordená-los por seu atributo` width`de menor para maior.

<Listing number="13-7" file-name="src/main.rs" caption="Usando `sort_by_key` para ordenar retângulos pela largura">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-07/src/main.rs}}
```

</Listing>

Este código imprime:

```console
{{#include ../listings/ch13-functional-features/listing-13-07/output.txt}}
```

A razão pela qual `sort_by_key` é definido para receber um `FnMut` closure é que ele chama
o closure várias vezes: uma vez para cada item no slice. O closure`|r|
r.width` doesn’t capture, mutate, or move anything out from its environment, so
ele atende aos requisitos vinculados ao trait.

Em contraste, a Listagem 13-8 mostra um exemplo de closure que implementa apenas
o `FnOnce` trait, porque move um valor para fora do ambiente. O
o compilador não nos permitirá usar este closure com `sort_by_key`.

<Listing number="13-8" file-name="src/main.rs" caption="Tentando usar uma closure `FnOnce` com `sort_by_key`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-08/src/main.rs}}
```

</Listing>

Esta é uma maneira artificial e complicada (que não funciona) de tentar contar o
número de vezes que `sort_by_key` chama closure ao classificar `list`. Este código
tenta fazer esta contagem pressionando ` value`- um ` String`do closure
ambiente - no vetor ` sort_operations`. O closure captura ` value`e
em seguida, move ` value`para fora do closure transferindo ownership de ` value`para
o vetor ` sort_operations`. Este closure pode ser chamado uma vez; tentando ligar
uma segunda vez não funcionaria, porque ` value`não estaria mais no
ambiente a ser inserido no ` sort_operations`novamente! Portanto, este closure
implementa apenas ` FnOnce`. Quando tentamos compilar este código, obtemos este erro
que ` value`não pode ser movido para fora do closure porque o closure deve
implementar ` FnMut`:

```console
{{#include ../listings/ch13-functional-features/listing-13-08/output.txt}}
```

O erro aponta para a linha no corpo closure que move `value` para fora do
ambiente. Para corrigir isso, precisamos alterar o corpo do closure para que não
retirar valores do ambiente. Manter um balcão no ambiente e
incrementar seu valor no corpo closure é uma maneira mais direta de
conte o número de vezes que o closure é chamado. O closure na Listagem 13-9
funciona com `sort_by_key` porque está capturando apenas uma referência mutável para o
Contador `num_sort_operations` e, portanto, pode ser chamado mais de uma vez.

<Listing number="13-9" file-name="src/main.rs" caption="Usar uma closure `FnMut` com `sort_by_key` é permitido">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-09/src/main.rs}}
```

</Listing>

Os `Fn` traits são importantes ao definir ou usar funções ou tipos que
faça uso do closures. Na próxima seção, discutiremos iterators. Muitos
Os métodos iterator aceitam argumentos closure, portanto, lembre-se desses detalhes do closure
enquanto continuamos!

[unwrap-or-else]: ../std/option/enum.Option.html#method.unwrap_or_else
