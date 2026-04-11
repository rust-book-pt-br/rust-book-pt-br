## Métodos

Os métodos são semelhantes às funções: nós os declaramos com a palavra-chave `fn` e um
nome, eles podem ter parâmetros e um valor de retorno e conter algum código
isso é executado quando o método é chamado de outro lugar. Ao contrário das funções,
métodos são definidos dentro do contexto de uma estrutura (ou um enum ou um traço
objeto, que abordamos no [Capítulo 6][enums]<!-- ignore --> e no [Capítulo
18][trait-objects]<!-- ignore -->, respectivamente), e seu primeiro parâmetro é
sempre `self`, que representa a instância da estrutura que o método está sendo
chamado.

<!-- Old headings. Do not remove or links may break. -->

<a id="defining-methods"></a>

### Sintaxe do método

Vamos alterar a função `area` que tem uma instância `Rectangle` como parâmetro
e em vez disso crie um método `area` definido na estrutura `Rectangle`, conforme mostrado
na Listagem 5-13.

<Listing number="5-13" file-name="src/main.rs" caption="Defining an `area` method on the `Rectangle` struct">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-13/src/main.rs}}
```

</Listing>

Para definir a função dentro do contexto de `Rectangle`, iniciamos um `impl`
(implementação) bloco para `Rectangle`. Tudo dentro deste bloco `impl`
será associado ao tipo `Rectangle`. Então, movemos a função `area`
dentro das chaves `impl` e altere o primeiro (e neste caso, apenas)
parâmetro seja `self` na assinatura e em qualquer lugar dentro do corpo. Em
`main`, onde chamamos a função `area` e passamos `rect1` como argumento,
em vez disso, podemos usar a _sintaxe do método_ para chamar o método `area` em nosso `Rectangle`
exemplo. A sintaxe do método segue uma instância: adicionamos um ponto seguido de
o nome do método, parênteses e quaisquer argumentos.

Na assinatura de `area`, usamos `&self` em vez de `rectangle: &Rectangle`.
O `&self` é na verdade uma abreviação de `self: &Self`. Dentro de um bloco `impl`, o
type `Self` é um alias para o tipo ao qual o bloco `impl` se destina. Os métodos devem
têm um parâmetro chamado `self` do tipo `Self` para seu primeiro parâmetro, então Rust
permite abreviar isso apenas com o nome `self` no primeiro parâmetro.
Observe que ainda precisamos usar `&` na frente da abreviação `self` para
indicam que este método pega emprestada a instância `Self`, assim como fizemos em
`rectangle: &Rectangle`. Os métodos podem assumir a propriedade de `self`, emprestar `self`
imutavelmente, como fizemos aqui, ou emprestar `self` de forma mutável, assim como qualquer
outro parâmetro.

Escolhemos `&self` aqui pelo mesmo motivo que usamos `&Rectangle` na função
versão: não queremos assumir a propriedade e queremos apenas ler os dados em
a estrutura, não escreva nela. Se quiséssemos mudar a instância que temos
chamado o método como parte do que o método faz, usaríamos `&mut self` como
o primeiro parâmetro. Ter um método que se aproprie da instância por
usar apenas `self` como primeiro parâmetro é raro; essa técnica geralmente é
usado quando o método transforma `self` em outra coisa e você deseja
impedir que o chamador use a instância original após a transformação.

A principal razão para usar métodos em vez de funções, além de
fornecendo sintaxe de método e não tendo que repetir o tipo de `self` em cada
assinatura do método, é para organização. Colocamos todas as coisas que podemos fazer
com uma instância de um tipo em um bloco `impl` em vez de fazer com que futuros usuários
do nosso código, procure recursos de `Rectangle` em vários lugares do
biblioteca que fornecemos.

Observe que podemos escolher dar a um método o mesmo nome de uma das estruturas
campos. Por exemplo, podemos definir um método em `Rectangle` que também é denominado
`width`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-06-method-field-interaction/src/main.rs:here}}
```

</Listing>

Aqui, escolhemos fazer com que o método `width` retorne `true` se o valor em
o campo `width` da instância for maior que `0` e `false` se o valor for
`0`: Podemos usar um campo dentro de um método de mesmo nome para qualquer finalidade. Em
`main`, quando seguimos `rect1.width` com parênteses, Rust sabe que queremos dizer o
método `width`. Quando não usamos parênteses, Rust sabe que nos referimos ao campo
`width`.

Frequentemente, mas nem sempre, quando damos a um método o mesmo nome de um campo que queremos
para retornar apenas o valor no campo e não fazer mais nada. Métodos como este
são chamados _getters_ e Rust não os implementa automaticamente para struct
campos como algumas outras linguagens fazem. Getters são úteis porque você pode fazer o
campo privado, mas o método público e, assim, permitir acesso somente leitura a esse
campo como parte da API pública do tipo. Discutiremos o que é público e privado
são e como designar um campo ou método como público ou privado no [Capítulo
7][public]<!-- ignore -->.

> ### Onde está o operador `->`?
>
> Em C e C++, dois operadores diferentes são usados ​​para chamar métodos: Você usa
> `.` se você estiver chamando um método diretamente no objeto e `->` se estiver
> chamando o método em um ponteiro para o objeto e precisa desreferenciar o
> ponteiro primeiro. Em outras palavras, se `object` for um ponteiro,
> `object->something()` é semelhante a `(*object).something()`.
>
> Rust não possui equivalente ao operador `->`; em vez disso, Rust tem um
> recurso chamado _referência e desreferência automática_. Chamar métodos é
> um dos poucos lugares em Rust com esse comportamento.
>
> Veja como funciona: quando você chama um método com `object.something()`, Rust
> adiciona automaticamente `&`, `&mut` ou `*` para que `object` corresponda ao
> assinatura do método. Em outras palavras, o seguinte é o mesmo:
>
> <!-- CAN'T EXTRACT SEE BUG https://github.com/rust-lang/mdBook/issues/1127 -->
>
> ```ferrugem
> # #[derivar(Depurar,Copiar,Clone)]
> # estrutura Ponto {
> #     x: f64,
> #     e: f64,
> # }
> #
> # ponto impl {
> #    fn distância(&self, outro: &Ponto) -> f64 {
> #        deixe x_squared = f64::powi(other.x - self.x, 2);
> #        deixe y_squared = f64::powi(other.y - self.y, 2);
> #
> #        f64::sqrt(x_quadrado + y_quadrado)
> #    }
> # }
> # seja p1 = Ponto { x: 0,0, y: 0,0 };
> # seja p2 = ponto { x: 5,0, y: 6,5 };
> p1.distância(&p2);
> (&p1).distância(&p2);
> ```
>
> O primeiro parece muito mais limpo. Este comportamento de referência automática funciona
> porque os métodos têm um receptor claro - o tipo `self`. Dado o receptor
> e nome de um método, Rust pode descobrir definitivamente se o método é
> lendo (`&self`), mutando (`&mut self`) ou consumindo (`self`). O fato
> que Rust torna o empréstimo implícito para receptores de métodos é uma grande parte do
> tornando a propriedade ergonômica na prática.

### Métodos com mais parâmetros

Vamos praticar o uso de métodos implementando um segundo método no `Rectangle`
estrutura. Desta vez queremos que uma instância de `Rectangle` pegue outra instância
de `Rectangle` e retorne `true` se o segundo `Rectangle` puder caber completamente
dentro de `self` (o primeiro `Rectangle`); caso contrário, deverá retornar `false`.
Ou seja, uma vez definido o método `can_hold`, queremos ser capazes de escrever
o programa mostrado na Listagem 5-14.

<Listing number="5-14" file-name="src/main.rs" caption="Using the as-yet-unwritten `can_hold` method">

```rust,ignore
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-14/src/main.rs}}
```

</Listing>

O resultado esperado seria semelhante ao seguinte porque ambas as dimensões do
`rect2` são menores que as dimensões de `rect1`, mas `rect3` é mais largo que
`rect1`:

```text
Can rect1 hold rect2? true
Can rect1 hold rect3? false
```

Sabemos que queremos definir um método, então ele estará dentro do `impl Rectangle`
bloquear. O nome do método será `can_hold` e será necessário um empréstimo imutável
de outro `Rectangle` como parâmetro. Podemos dizer qual o tipo de
parâmetro será observando o código que chama o método:
`rect1.can_hold(&rect2)` passa `&rect2`, que é um empréstimo imutável para
`rect2`, uma instância de `Rectangle`. Isso faz sentido porque só precisamos
leia `rect2` (em vez de escrever, o que significaria que precisaríamos de um empréstimo mutável),
e queremos que `main` mantenha a propriedade de `rect2` para que possamos usá-lo novamente
depois de chamar o método `can_hold`. O valor de retorno de `can_hold` será um
Booleano, e a implementação verificará se a largura e a altura de
`self` são maiores que a largura e a altura do outro `Rectangle`,
respectivamente. Vamos adicionar o novo método `can_hold` ao bloco `impl` de
Listagem 5-13, mostrada na Listagem 5-15.

<Listing number="5-15" file-name="src/main.rs" caption="Implementing the `can_hold` method on `Rectangle` that takes another `Rectangle` instance as a parameter">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-15/src/main.rs:here}}
```

</Listing>

Quando executarmos este código com a função `main` na Listagem 5.14, obteremos nosso
saída desejada. Os métodos podem receber vários parâmetros que adicionamos ao
assinatura após o parâmetro `self`, e esses parâmetros funcionam exatamente como
parâmetros em funções.

### Funções Associadas

Todas as funções definidas em um bloco `impl` são chamadas de _funções associadas_
porque eles estão associados ao tipo nomeado após `impl`. Podemos definir
funções associadas que não têm `self` como primeiro parâmetro (e, portanto,
não são métodos) porque não precisam de uma instância do tipo para trabalhar.
Já usamos uma função como esta: a função `String::from` que é
definido no tipo `String`.

Funções associadas que não são métodos são frequentemente usadas para construtores que
retornará uma nova instância da estrutura. Geralmente são chamados de `new`, mas
`new` não é um nome especial e não está embutido na linguagem. Por exemplo, nós
poderia optar por fornecer uma função associada chamada `square` que teria
um parâmetro de dimensão e usá-lo como largura e altura, tornando-o assim
mais fácil criar um quadrado `Rectangle` em vez de especificar o mesmo
valor duas vezes:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-03-associated-functions/src/main.rs:here}}
```

As palavras-chave `Self` no tipo de retorno e no corpo da função são
aliases para o tipo que aparece após a palavra-chave `impl`, que neste caso
é `Rectangle`.

Para chamar esta função associada, usamos a sintaxe `::` com o nome da estrutura;
`let sq = Rectangle::square(3);` é um exemplo. Esta função tem namespace por
a estrutura: A sintaxe `::` é usada para funções associadas e
namespaces criados por módulos. Discutiremos os módulos no [Capítulo
7][modules]<!-- ignore -->.

### Vários blocos `impl`

Cada estrutura pode ter vários blocos `impl`. Por exemplo, Listagem
5-15 é equivalente ao código mostrado na Listagem 5-16, que possui cada método em
seu próprio bloco `impl`.

<Listing number="5-16" caption="Rewriting Listing 5-15 using multiple `impl` blocks">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-16/src/main.rs:here}}
```

</Listing>

Não há razão para separar esses métodos em vários blocos `impl` aqui,
mas esta é uma sintaxe válida. Veremos um caso em que vários blocos `impl` são
útil no Capítulo 10, onde discutimos tipos e características genéricos.

## Resumo

As estruturas permitem criar tipos personalizados que sejam significativos para o seu domínio. Por
usando estruturas, você pode manter dados associados conectados entre si
e nomeie cada peça para deixar seu código claro. Nos blocos `impl`, você pode definir
funções associadas ao seu tipo e os métodos são uma espécie de
função associada que permite especificar o comportamento que as instâncias do seu
estruturas têm.

Mas structs não são a única maneira de criar tipos personalizados: vamos voltar para
Recurso enum do Rust para adicionar outra ferramenta à sua caixa de ferramentas.

[enums]: ch06-00-enums.html
[trait-objects]: ch18-02-trait-objects.md
[public]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#exposing-paths-with-the-pub-keyword
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
