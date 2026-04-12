## Métodos

Métodos são parecidos com funções: nós os declaramos com a palavra-chave `fn`
e um nome, eles podem ter parâmetros e valor de retorno, e contêm algum
código que é executado quando o método é chamado. Diferentemente das funções,
os métodos são definidos no contexto de uma struct, de um enum ou de um trait
object, que veremos respectivamente no [Capítulo 6][enums]<!-- ignore --> e no
[Capítulo 18][trait-objects]<!-- ignore -->. Além disso, o primeiro parâmetro
de um método é sempre `self`, que representa a instância da struct sobre a
qual o método está sendo chamado.

<!-- Old headings. Do not remove or links may break. -->

<a id="defining-methods"></a>

### Sintaxe de Métodos

Vamos mudar a função `area`, que recebe uma instância de `Rectangle` como
parâmetro, para um método `area` definido na própria struct `Rectangle`, como
mostra a Listagem 5-13.

<Listing number="5-13" file-name="src/main.rs" caption="Definindo um método `area` na struct `Rectangle`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-13/src/main.rs}}
```

</Listing>

Para definir a função no contexto de `Rectangle`, começamos um bloco `impl`
(de implementação) para `Rectangle`. Tudo dentro desse bloco `impl` ficará
associado ao tipo `Rectangle`. Em seguida, movemos a função `area` para dentro
das chaves do `impl` e alteramos o primeiro parâmetro, que neste caso é o
único, para `self` na assinatura e em todo o corpo da função. Em `main`, onde
antes chamávamos a função `area` e passávamos `rect1` como argumento, agora
podemos usar a _sintaxe de métodos_ para chamar o método `area` em nossa
instância de `Rectangle`. A sintaxe de métodos vem depois da instância:
adicionamos um ponto, o nome do método, parênteses e eventuais argumentos.

Na assinatura de `area`, usamos `&self` em vez de `rectangle: &Rectangle`.
`&self` é, na verdade, uma abreviação de `self: &Self`. Dentro de um bloco
`impl`, o tipo `Self` é um alias para o tipo ao qual o bloco `impl` se refere.
Métodos precisam ter um parâmetro chamado `self` do tipo `Self` como primeiro
parâmetro, então o Rust permite abreviar isso usando apenas o nome `self`
nessa posição. Repare que ainda precisamos usar `&` antes de `self` para
indicar que esse método toma a instância `Self` por empréstimo, assim como
fizemos em `rectangle: &Rectangle`. Métodos podem assumir o ownership de
`self`, tomar `self` por empréstimo imutável, como fizemos aqui, ou tomar
`self` por empréstimo mutável, como fariam com qualquer outro parâmetro.

Escolhemos `&self` aqui pelo mesmo motivo que usamos `&Rectangle` na versão em
forma de função: não queremos assumir o ownership, apenas ler os dados da
struct, sem modificá-los. Se quiséssemos alterar a instância sobre a qual o método foi
chamado, usaríamos `&mut self` como primeiro parâmetro. Métodos que assumem o
ownership da instância usando apenas `self` como primeiro parâmetro são mais
raros; essa técnica costuma ser usada quando o método transforma `self` em
outra coisa e você quer impedir que o chamador use a instância original depois
da transformação.

A principal razão para usar métodos em vez de funções, além da sintaxe mais
natural e do fato de não precisarmos repetir o tipo de `self` em toda
assinatura, é organização. Colocamos tudo o que pode ser feito com uma
instância de um tipo em um único bloco `impl`, em vez de obrigar usuários
futuros do código a procurar as capacidades de `Rectangle` em vários lugares
da biblioteca.

Observe que podemos escolher dar a um método o mesmo nome de um dos campos da
struct. Por exemplo, podemos definir um método em `Rectangle` também chamado
`width`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-06-method-field-interaction/src/main.rs:here}}
```

</Listing>

Aqui, escolhemos fazer o método `width` retornar `true` se o valor do campo
`width` da instância for maior que `0` e `false` se esse valor for `0`. Podemos
usar um campo dentro de um método com o mesmo nome para qualquer finalidade.
Em `main`, quando escrevemos `rect1.width` seguido de parênteses, o Rust sabe
que queremos dizer o método `width`. Quando não usamos parênteses, o Rust sabe
que estamos nos referindo ao campo `width`.

Muitas vezes, embora nem sempre, quando damos a um método o mesmo nome de um
campo, queremos que ele apenas devolva o valor armazenado nesse campo e não
faça mais nada. Métodos desse tipo são chamados de _getters_, e o Rust não os
implementa automaticamente para campos de struct, como algumas outras
linguagens fazem. Getters são úteis porque você pode tornar o campo privado e
o método público, permitindo acesso somente leitura a esse campo como parte da
API pública do tipo. Vamos discutir o que é público e privado, bem como como
marcar um campo ou método dessa forma, no [Capítulo 7][public]<!-- ignore
-->.

> ### Onde Está o Operador `->`?
>
> Em C e C++, dois operadores diferentes são usados para chamar métodos: você
> usa `.` se estiver chamando um método diretamente no objeto e `->` se
> estiver chamando o método em um ponteiro para o objeto e precisar
> desreferenciar o ponteiro primeiro. Em outras palavras, se `object` for um
> ponteiro, `object->something()` é semelhante a `(*object).something()`.
>
> O Rust não tem um equivalente ao operador `->`; em vez disso, ele conta com
> um recurso de _referência e desreferenciação automáticas_. A chamada de
> métodos é um dos poucos lugares em Rust em que esse comportamento ocorre.
>
> Funciona assim: quando você chama um método com `object.something()`, o Rust
> adiciona automaticamente `&`, `&mut` ou `*` para que `object` corresponda à
> assinatura do método. Em outras palavras, as linhas a seguir são
> equivalentes:
>
> <!-- CAN'T EXTRACT SEE BUG https://github.com/rust-lang/mdBook/issues/1127 -->
>
> ```rust
> # #[derive(Debug,Copy,Clone)]
> # struct Point {
> #     x: f64,
> #     y: f64,
> # }
> #
> # impl Point {
> #    fn distance(&self, other: &Point) -> f64 {
> #        let x_squared = f64::powi(other.x - self.x, 2);
> #        let y_squared = f64::powi(other.y - self.y, 2);
> #
> #        f64::sqrt(x_squared + y_squared)
> #    }
> # }
> # let p1 = Point { x: 0.0, y: 0.0 };
> # let p2 = Point { x: 5.0, y: 6.5 };
> p1.distance(&p2);
> (&p1).distance(&p2);
> ```
>
> A primeira forma parece bem mais limpa. Esse comportamento de referência
> automática funciona porque métodos têm um receptor claro: o tipo de `self`.
> Dado o receptor e o nome de um método, o Rust consegue determinar se ele está
> apenas lendo (`&self`), mutando (`&mut self`) ou consumindo (`self`). O fato
> de o Rust tornar implícito o empréstimo para receptores de método é uma parte
> importante do que faz o ownership ser ergonômico na prática.

### Métodos com Mais Parâmetros

Vamos praticar o uso de métodos implementando um segundo método na struct
`Rectangle`. Desta vez, queremos que uma instância de `Rectangle` receba outra
instância de `Rectangle` e retorne `true` se o segundo `Rectangle` puder caber
inteiramente dentro de `self`, isto é, do primeiro `Rectangle`; caso
contrário, deve retornar `false`. Em outras palavras, depois de definir o
método `can_hold`, queremos poder escrever o programa mostrado na Listagem
5-14.

<Listing number="5-14" file-name="src/main.rs" caption="Usando o método `can_hold`, que ainda não foi escrito">

```rust,ignore
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-14/src/main.rs}}
```

</Listing>

A saída esperada deve ser parecida com a seguinte, porque as duas dimensões de
`rect2` são menores que as dimensões de `rect1`, enquanto `rect3` é mais largo
que `rect1`:

```text
Can rect1 hold rect2? true
Can rect1 hold rect3? false
```

Sabemos que queremos definir um método, então ele ficará dentro do bloco
`impl Rectangle`. O nome do método será `can_hold`, e ele receberá um
empréstimo imutável de outro `Rectangle` como parâmetro. Podemos inferir o tipo
desse parâmetro olhando para o código que chama o método:
`rect1.can_hold(&rect2)` passa `&rect2`, que é um empréstimo imutável de
`rect2`, uma instância de `Rectangle`. Isso faz sentido porque só precisamos
ler `rect2`, e não escrevê-lo, o que exigiria um empréstimo mutável. Além
disso, queremos que `main` mantenha o ownership de `rect2` para poder usá-lo
novamente depois de chamar `can_hold`. O valor de retorno de `can_hold` será
um booleano, e a implementação verificará se a largura e a altura de `self`
são maiores que a largura e a altura do outro `Rectangle`, respectivamente.
Vamos adicionar esse novo método `can_hold` ao bloco `impl` da Listagem 5-13,
como mostra a Listagem 5-15.

<Listing number="5-15" file-name="src/main.rs" caption="Implementando o método `can_hold` em `Rectangle`, recebendo outra instância de `Rectangle` como parâmetro">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-15/src/main.rs:here}}
```

</Listing>

Quando executarmos esse código com a função `main` da Listagem 5-14,
obteremos a saída desejada. Métodos podem receber vários parâmetros depois do
parâmetro `self`, e esses parâmetros funcionam exatamente como parâmetros em
funções.

### Funções Associadas

Todas as funções definidas dentro de um bloco `impl` são chamadas de _funções
associadas_ porque estão associadas ao tipo nomeado depois de `impl`. Podemos
definir funções associadas que não têm `self` como primeiro parâmetro e, por
isso, não são métodos, porque elas não precisam de uma instância do tipo para
trabalhar. Já usamos uma função assim: `String::from`, definida no tipo
`String`.

Funções associadas que não são métodos costumam ser usadas como construtores,
retornando uma nova instância da struct. Frequentemente elas recebem o nome
`new`, mas `new` não é um nome especial nem faz parte da linguagem. Por
exemplo, poderíamos fornecer uma função associada chamada `square` que recebe
um parâmetro de dimensão e o usa tanto como largura quanto como altura,
facilitando a criação de um `Rectangle` quadrado sem precisar repetir o mesmo
valor duas vezes:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/no-listing-03-associated-functions/src/main.rs:here}}
```

As palavras-chave `Self` no tipo de retorno e no corpo da função são aliases
para o tipo que aparece após a palavra-chave `impl`, que neste caso é
`Rectangle`.

Para chamar essa função associada, usamos a sintaxe `::` com o nome da struct;
`let sq = Rectangle::square(3);` é um exemplo. Essa função fica no namespace da
struct: a sintaxe `::` é usada tanto para funções associadas quanto para
namespaces criados por módulos. Vamos falar sobre módulos no [Capítulo
7][modules]<!-- ignore -->.

### Vários Blocos `impl`

Cada struct pode ter vários blocos `impl`. Por exemplo, a Listagem 5-15 é
equivalente ao código mostrado na Listagem 5-16, que coloca cada método em seu
próprio bloco `impl`.

<Listing number="5-16" caption="Reescrevendo a Listagem 5-15 com vários blocos `impl`">

```rust
{{#rustdoc_include ../listings/ch05-using-structs-to-structure-related-data/listing-05-16/src/main.rs:here}}
```

</Listing>

Não há motivo para separar esses métodos em vários blocos `impl` aqui, mas
essa é uma sintaxe válida. Veremos um caso em que vários blocos `impl` são
úteis no Capítulo 10, quando discutirmos tipos genéricos e traits.

## Resumo

Structs permitem criar tipos personalizados que façam sentido para o seu
domínio. Ao usar structs, você consegue manter dados relacionados juntos e dar
nome a cada parte, deixando o código mais claro. Em blocos `impl`, você pode
definir funções associadas ao tipo, e métodos são uma forma de função
associada que permite especificar o comportamento das instâncias dessas
structs.

Mas structs não são a única forma de criar tipos personalizados: vamos agora
para o recurso de enums do Rust, adicionando mais uma ferramenta à nossa caixa
de ferramentas.

[enums]: ch06-00-enums.html
[trait-objects]: ch18-02-trait-objects.md
[public]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#exposing-paths-with-the-pub-keyword
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
