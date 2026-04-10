<!-- Old headings. Do not remove or links may break. -->

<a id="using-trait-objects-that-allow-for-values-of-different-types"></a>

## Usando objetos trait para abstrair comportamento compartilhado

No Capítulo 8, mencionamos que uma limitação dos vetores é que eles podem
armazenar elementos de apenas um tipo. Criamos uma solução alternativa na Listagem 8-9 onde
definimos um enum `SpreadsheetCell` que tinha variantes para conter números inteiros, flutuantes,
e texto. Isso significava que poderíamos armazenar diferentes tipos de dados em cada célula e
ainda tem um vetor que representa uma linha de células. Isto é perfeitamente bom
solução quando nossos itens intercambiáveis são um conjunto fixo de tipos que conhecemos
quando nosso código é compilado.

No entanto, às vezes queremos que o usuário da nossa biblioteca seja capaz de estender o conjunto de
tipos que são válidos em uma situação particular. Para mostrar como podemos alcançar
isso, criaremos um exemplo de ferramenta de interface gráfica do usuário (GUI) que itera
através de uma lista de itens, chamando um método `draw` em cada um para atraí-los para o
tela – uma técnica comum para ferramentas GUI. Criaremos uma biblioteca crate chamada
`gui ` que contém a estrutura de uma biblioteca GUI. Este crate pode incluir
alguns tipos para as pessoas usarem, como`Button ` ou`TextField `. Além disso,
Os usuários do` gui `desejarão criar seus próprios tipos que possam ser desenhados: Para
Por exemplo, um programador pode adicionar um` Image `e outro pode adicionar um
` SelectBox`.

No momento em que escrevo a biblioteca, não podemos conhecer e definir todos os tipos
outros programadores podem querer criar. Mas sabemos que `gui` precisa manter
rastreia muitos valores de tipos diferentes e precisa chamar um método `draw`
em cada um desses valores de tipo diferente. Não é preciso saber exatamente o que
acontecerá quando chamarmos o método ` draw`, basta que o valor tenha aquele
método disponível para chamarmos.

Para fazer isso em uma linguagem com herança, podemos definir uma classe chamada
`Component ` que possui um método chamado`draw `. As outras aulas, como
` Button `,` Image `e` SelectBox `herdariam de` Component `e, portanto,
herdar o método` draw `. Cada um deles poderia substituir o método` draw `para definir
seu comportamento personalizado, mas a estrutura poderia tratar todos os tipos como se
elas eram instâncias` Component `e chamam` draw `nelas. Mas porque Rust
não tem herança, precisamos de outra forma de estruturar a biblioteca` gui`para
permitir que os usuários criem novos tipos compatíveis com a biblioteca.

### Definindo uma trait para comportamento comum

Para implementar o comportamento que queremos que `gui` tenha, definiremos uma
trait chamada `Draw`, com um método chamado `draw`. Então, podemos definir um
vetor que recebe um objeto trait. Um _objeto trait_ aponta para uma instância
de um tipo que implementa a trait especificada e para uma tabela usada para
procurar métodos da trait nesse tipo em tempo de execução. Criamos um objeto
trait especificando algum tipo de ponteiro, como uma referência ou um smart
pointer `Box<T>`, seguido da palavra-chave `dyn` e, então, da trait
relevante. (Falaremos sobre a razão pela qual os objetos trait precisam usar
um ponteiro em [“Tipos de tamanho dinâmico e a trait `Sized`”][dynamically-sized]<!--
ignore --> no Capítulo 20.) Podemos usar objetos trait no lugar de um tipo
genérico ou concreto. Onde quer que usemos um objeto trait, o sistema de tipos
do Rust garantirá, em tempo de compilação, que qualquer valor usado nesse
contexto implementará a trait do objeto trait. Consequentemente, não
precisamos conhecer todos os tipos possíveis em tempo de compilação.

Mencionamos que, em Rust, evitamos chamar structs e enums
“objetos” para distingui-los dos objetos de outras línguas. Em uma estrutura ou
enum, os dados nos campos struct e o comportamento nos blocos `impl` são
separados, enquanto em outras línguas, os dados e o comportamento combinados em um
conceito é frequentemente rotulado como objeto. Objetos trait diferem de
objetos em outras linguagens porque não podemos adicionar dados a um objeto
trait. Objetos trait não são tão geralmente úteis quanto objetos em outras
línguas: seu propósito específico é
permitir abstração em comportamento comum.

A Listagem 18-3 mostra como definir um trait denominado `Draw` com um método denominado
`draw`.

<Listing number="18-3" file-name="src/lib.rs" caption="Definição da trait `Draw`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-03/src/lib.rs}}
```

</Listing>

Esta sintaxe deve parecer familiar em nossas discussões sobre como definir traits
no Capítulo 10. A seguir vem uma nova sintaxe: a Listagem 18-4 define uma estrutura chamada
`Screen ` que contém um vetor denominado`components `. Este vetor é do tipo
` Box<dyn Draw> `, que é um objeto trait; é um substituto para qualquer tipo dentro de um
` Box `que implementa o` Draw`trait.

<Listing number="18-4" file-name="src/lib.rs" caption="Definição da struct `Screen` com um campo `components` que guarda um vetor de objetos trait que implementam a trait `Draw`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-04/src/lib.rs:here}}
```

</Listing>

Na estrutura `Screen`, definiremos um método chamado ` run`que chamará o
` draw `em cada um de seus` components`, conforme mostrado na Listagem 18-5.

<Listing number="18-5" file-name="src/lib.rs" caption="Um método `run` em `Screen` que chama o método `draw` em cada componente">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-05/src/lib.rs:here}}
```

</Listing>

Isso funciona de maneira diferente de definir uma estrutura que usa um tipo genérico
parâmetro com limites trait. Um parâmetro de tipo genérico pode ser substituído por
apenas um tipo concreto por vez, enquanto os objetos trait permitem vários
tipos concretos para preencher o objeto trait em tempo de execução. Por exemplo, nós
poderia ter definido a estrutura `Screen` usando um tipo genérico e um limite trait,
como na Listagem 18-6.

<Listing number="18-6" file-name="src/lib.rs" caption="Uma implementação alternativa da struct `Screen` e de seu método `run` usando genéricos e limites de trait">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-06/src/lib.rs:here}}
```

</Listing>

Isso nos restringe a uma instância `Screen` que possui uma lista de componentes, todos
digite `Button` ou todos do tipo `TextField`. Se você sempre tiver homogêneo
coleções, usar genéricos e limites trait é preferível porque o
as definições serão monomorfizadas em tempo de compilação para usar os tipos concretos.

Por outro lado, com o método que utiliza objetos trait, uma instância `Screen`
pode conter um ` Vec<T>`que contém um ` Box<Button>`, bem como um
` Box<TextField>`. Vejamos como isso funciona e depois falaremos sobre o
implicações de desempenho em tempo de execução.

### Implementando a trait

Agora adicionaremos alguns tipos que implementam o `Draw` trait. Nós forneceremos o
Tipo `Button`. Novamente, implementar de fato uma biblioteca GUI está além do escopo
deste livro, portanto o método ` draw`não terá nenhuma implementação útil em sua
corpo. Para imaginar como seria a implementação, uma estrutura ` Button`
pode ter campos para ` width`, ` height`e ` label`, conforme mostrado na Listagem 18-7.

<Listing number="18-7" file-name="src/lib.rs" caption="Uma struct `Button` que implementa a trait `Draw`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-07/src/lib.rs:here}}
```

</Listing>

Os campos `width`, ` height`e ` label`em ` Button`serão diferentes dos campos
campos em outros componentes; por exemplo, um tipo ` TextField`pode ter aqueles
mesmos campos mais um campo ` placeholder`. Cada um dos tipos que queremos desenhar
a tela implementará o ` Draw`trait, mas usará um código diferente no
Método ` draw`para definir como desenhar aquele tipo específico, como ` Button`fez aqui
(sem o código GUI real, conforme mencionado). O tipo ` Button`, por exemplo,
pode ter um bloco ` impl`adicional contendo métodos relacionados ao que
acontece quando um usuário clica no botão. Esses tipos de métodos não se aplicam a
tipos como ` TextField`.

Se alguém usando nossa biblioteca decidir implementar uma estrutura `SelectBox` que tenha
Campos `width`, ` height`e ` options`, eles implementariam o ` Draw`trait
também no tipo ` SelectBox`, conforme mostrado na Listagem 18-8.

<Listing number="18-8" file-name="src/main.rs" caption="Outro crate usando `gui` e implementando a trait `Draw` em uma struct `SelectBox`">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-08/src/main.rs:here}}
```

</Listing>

O usuário da nossa biblioteca agora pode escrever sua função `main` para criar um `Screen`
instância. Para a instância ` Screen`, eles podem adicionar um ` SelectBox`e um ` Button`
colocando cada um em um ` Box<T>`para se tornar um objeto trait. Eles podem então ligar para o
Método ` run`na instância ` Screen`, que chamará ` draw`em cada um dos
componentes. A Listagem 18-9 mostra esta implementação.

<Listing number="18-9" file-name="src/main.rs" caption="Usando objetos trait para armazenar valores de tipos diferentes que implementam a mesma trait">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-09/src/main.rs:here}}
```

</Listing>

Quando escrevemos a biblioteca, não sabíamos que alguém poderia adicionar o
tipo `SelectBox`, mas nossa implementação ` Screen`foi capaz de operar no
novo tipo e desenhe-o porque ` SelectBox`implementa o ` Draw`trait, que
significa que implementa o método ` draw`.

Este conceito - de se preocupar apenas com as mensagens às quais um valor responde
em vez do tipo concreto do valor - é semelhante ao conceito de _duck
typing_ em linguagens de tipagem dinâmica: se ele anda como um pato e grasna como
um pato, então deve ser um pato! Na implementação de `run` em `Screen` em
Listagem 18-5, `run` não precisa saber qual é o tipo concreto de cada
componente é. Não verifica se um componente é uma instância de `Button`
ou ` SelectBox`, ele apenas chama o método ` draw`no componente. Por
especificando ` Box<dyn Draw>`como o tipo dos valores no ` components`
vetor, definimos ` Screen`para precisar de valores que podemos chamar de ` draw`
método ativado.

A vantagem de usar objetos trait e o sistema de tipos Rust para escrever código
semelhante ao código usando digitação duck é que nunca precisamos verificar se um
valor implementa um método específico em tempo de execução nem nos preocupar
com erros se um valor não implementar um método, mas o chamarmos mesmo assim.
Rust não compila nosso código se os valores não implementarem as traits
exigidas pelos objetos trait.

Por exemplo, a Listagem 18-10 mostra o que acontece se tentarmos criar um `Screen`
com um ` String`como componente.

<Listing number="18-10" file-name="src/main.rs" caption="Tentando usar um tipo que não implementa a trait exigida pelo objeto trait">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch18-oop/listing-18-10/src/main.rs}}
```

</Listing>

Receberemos este erro porque `String` não implementa `Draw` trait:

```console
{{#include ../listings/ch18-oop/listing-18-10/output.txt}}
```

Este erro nos informa que estamos passando algo para `Screen` que
não pretendíamos passar e, portanto, deveríamos passar um tipo diferente, ou deveríamos implementar
`Draw ` em`String ` para que`Screen ` possa chamar`draw` nele.

<!-- Old headings. Do not remove or links may break. -->

<a id="trait-objects-perform-dynamic-dispatch"></a>

### Realizando despacho dinâmico

Lembre-se em [“Desempenho do código usando
Genéricos”][performance-of-code-using-generics]<!-- ignore --> no Capítulo 10 nosso
discussão sobre o processo de monomorfização realizado em genéricos pelo
compilador: O compilador gera implementações não genéricas de funções e
métodos para cada tipo concreto que usamos no lugar de um tipo genérico
parâmetro. O código resultante da monomorfização está fazendo _static
dispatch_, que é quando o compilador sabe qual método você está chamando
tempo de compilação. Isso se opõe ao _despacho dinâmico_, que é quando o compilador
não consigo dizer em tempo de compilação qual método você está chamando. Em despacho dinâmico
casos, o compilador emite código que em tempo de execução saberá qual método chamar.

Quando usamos objetos trait, Rust deve usar despacho dinâmico. O compilador não
conhecer todos os tipos que podem ser usados com o código que usa objetos trait,
portanto, ele não sabe qual método implementado em qual tipo chamar. Em vez disso, em
tempo de execução, Rust usa os ponteiros dentro do objeto trait para saber qual método
ligue. Essa pesquisa incorre em um custo de tempo de execução que não ocorre com o envio estático.
O despacho dinâmico também evita que o compilador opte por incorporar o método de um método.
código, o que por sua vez impede algumas otimizações, e Rust tem algumas regras sobre
onde você pode e não pode usar o envio dinâmico, chamado _compatibilidade dyn_. Aqueles
as regras estão além do escopo desta discussão, mas você pode ler mais sobre elas
[na referência][dyn-compatibility]<!-- ignore -->. No entanto, conseguimos mais
flexibilidade no código que escrevemos na Listagem 18-5 e conseguimos suportar
na Listagem 18-9, portanto é uma compensação a ser considerada.

[performance-of-code-using-generics]: ch10-01-syntax.html#performance-of-code-using-generics
[dynamically-sized]: ch20-03-advanced-types.html#dynamically-sized-types-and-the-sized-trait
[dyn-compatibility]: https://doc.rust-lang.org/reference/items/traits.html#dyn-compatibility
