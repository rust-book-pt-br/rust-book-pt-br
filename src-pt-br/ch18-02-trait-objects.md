<!-- Old headings. Do not remove or links may break. -->

<a id="using-trait-objects-that-allow-for-values-of-different-types"></a>

## Usando Objetos Trait Para Abstrair Comportamento Compartilhado

No Capítulo 8, mencionamos que uma limitação dos vetores é que eles podem
armazenar elementos de apenas um tipo. Criamos uma solução alternativa na
Listagem 8-9, em que definimos um enum `SpreadsheetCell` com variantes para
armazenar inteiros, floats e texto. Isso significava que poderíamos armazenar
diferentes tipos de dados em cada célula e ainda ter um vetor que representava
uma linha de células. Essa é uma solução perfeitamente boa quando nossos itens
intercambiáveis são um conjunto fixo de tipos que conhecemos quando nosso
código é compilado.

No entanto, às vezes queremos que o usuário da nossa biblioteca consiga
estender o conjunto de tipos válidos em uma situação específica. Para mostrar
como poderíamos fazer isso, criaremos um exemplo de ferramenta de interface
gráfica do usuário (GUI) que itera por uma lista de itens, chamando um método
`draw` em cada um para desenhá-lo na tela, uma técnica comum em ferramentas
GUI. Criaremos um crate de biblioteca chamado `gui`, que contém a estrutura de
uma biblioteca GUI. Esse crate poderia incluir alguns tipos para as pessoas
usarem, como `Button` ou `TextField`. Além disso, usuários de `gui` vão querer
criar seus próprios tipos que possam ser desenhados: por exemplo, uma pessoa
programadora poderia adicionar um `Image`, e outra poderia adicionar um
`SelectBox`.

No momento em que escrevemos a biblioteca, não podemos conhecer e definir todos
os tipos que outras pessoas programadoras talvez queiram criar. Mas sabemos que
`gui` precisa acompanhar muitos valores de tipos diferentes e precisa chamar um
método `draw` em cada um desses valores de tipos diferentes. Ela não precisa
saber exatamente o que acontecerá quando chamarmos o método `draw`, apenas que
o valor terá esse método disponível para chamarmos.

Para fazer isso em uma linguagem com herança, poderíamos definir uma classe
chamada `Component` com um método chamado `draw`. As outras classes, como
`Button`, `Image` e `SelectBox`, herdariam de `Component` e, portanto,
herdariam o método `draw`. Cada uma poderia sobrescrever o método `draw` para
definir seu comportamento personalizado, mas o framework poderia tratar todos
os tipos como se fossem instâncias de `Component` e chamar `draw` neles. Mas,
como Rust não tem herança, precisamos de outra forma de estruturar a biblioteca
`gui` para permitir que usuários criem novos tipos compatíveis com a
biblioteca.

### Definindo uma Trait Para Comportamento Comum

Para implementar o comportamento que queremos que `gui` tenha, definiremos uma
trait chamada `Draw` com um método chamado `draw`. Então podemos definir um
vetor que recebe um objeto trait. Um _objeto trait_ aponta tanto para uma
instância de um tipo que implementa a trait especificada quanto para uma tabela
usada para procurar métodos dessa trait nesse tipo em tempo de execução.
Criamos um objeto trait especificando algum tipo de ponteiro, como uma
referência ou um smart pointer `Box<T>`, depois a palavra-chave `dyn` e então a
trait relevante. (Falaremos sobre o motivo pelo qual objetos trait precisam
usar um ponteiro em [“Tipos de Tamanho Dinâmico e a Trait `Sized`”][dynamically-sized]<!-- ignore -->
no Capítulo 20.) Podemos usar objetos trait no lugar de um tipo genérico ou
concreto. Onde quer que usemos um objeto trait, o sistema de tipos de Rust
garantirá em tempo de compilação que qualquer valor usado nesse contexto
implementará a trait do objeto trait. Consequentemente, não precisamos conhecer
todos os tipos possíveis em tempo de compilação.

Mencionamos que, em Rust, evitamos chamar structs e enums de “objetos” para
distingui-los dos objetos de outras linguagens. Em uma struct ou enum, os dados
nos campos da struct e o comportamento nos blocos `impl` ficam separados,
enquanto em outras linguagens a combinação de dados e comportamento em um único
conceito costuma receber o rótulo de objeto. Objetos trait diferem de objetos
em outras linguagens porque não podemos adicionar dados a um objeto trait.
Objetos trait não são tão geralmente úteis quanto objetos em outras linguagens:
seu propósito específico é permitir abstração sobre comportamento comum.

A Listagem 18-3 mostra como definir uma trait chamada `Draw` com um método
chamado `draw`.

<Listing number="18-3" file-name="src/lib.rs" caption="Definição da trait `Draw`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-03/src/lib.rs}}
```

</Listing>

Essa sintaxe deve parecer familiar a partir das nossas discussões sobre como
definir traits no Capítulo 10. Em seguida vem uma sintaxe nova: a Listagem 18-4
define uma struct chamada `Screen` que guarda um vetor chamado `components`.
Esse vetor é do tipo `Box<dyn Draw>`, que é um objeto trait; ele substitui
qualquer tipo dentro de um `Box` que implemente a trait `Draw`.

<Listing number="18-4" file-name="src/lib.rs" caption="Definição da struct `Screen` com um campo `components` que guarda um vetor de objetos trait que implementam a trait `Draw`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-04/src/lib.rs:here}}
```

</Listing>

Na struct `Screen`, definiremos um método chamado `run` que chamará o método
`draw` em cada um de seus `components`, como mostrado na Listagem 18-5.

<Listing number="18-5" file-name="src/lib.rs" caption="Um método `run` em `Screen` que chama o método `draw` em cada componente">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-05/src/lib.rs:here}}
```

</Listing>

Isso funciona de forma diferente de definir uma struct que usa um parâmetro de
tipo genérico com trait bounds. Um parâmetro de tipo genérico só pode ser
substituído por um tipo concreto por vez, enquanto objetos trait permitem que
múltiplos tipos concretos ocupem o lugar do objeto trait em tempo de execução.
Por exemplo, poderíamos ter definido a struct `Screen` usando um tipo genérico
e um trait bound, como na Listagem 18-6.

<Listing number="18-6" file-name="src/lib.rs" caption="Uma implementação alternativa da struct `Screen` e de seu método `run` usando genéricos e trait bounds">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-06/src/lib.rs:here}}
```

</Listing>

Isso nos restringe a uma instância de `Screen` que tenha uma lista de
componentes todos do tipo `Button` ou todos do tipo `TextField`. Se você sempre
tiver coleções homogêneas, usar genéricos e trait bounds é preferível porque as
definições serão monomorfizadas em tempo de compilação para usar os tipos
concretos.

Por outro lado, com o método que usa objetos trait, uma instância de `Screen`
pode guardar um `Vec<T>` que contém um `Box<Button>` e também um
`Box<TextField>`. Vamos ver como isso funciona e depois falaremos sobre as
implicações de desempenho em tempo de execução.

### Implementando a Trait

Agora adicionaremos alguns tipos que implementam a trait `Draw`. Forneceremos o
tipo `Button`. Novamente, implementar de fato uma biblioteca GUI está além do
escopo deste livro, então o método `draw` não terá nenhuma implementação útil
em seu corpo. Para imaginar como seria a implementação, uma struct `Button`
poderia ter campos para `width`, `height` e `label`, como mostrado na Listagem
18-7.

<Listing number="18-7" file-name="src/lib.rs" caption="Uma struct `Button` que implementa a trait `Draw`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-07/src/lib.rs:here}}
```

</Listing>

Os campos `width`, `height` e `label` em `Button` serão diferentes dos campos
em outros componentes; por exemplo, um tipo `TextField` poderia ter esses
mesmos campos mais um campo `placeholder`. Cada um dos tipos que queremos
desenhar na tela implementará a trait `Draw`, mas usará código diferente no
método `draw` para definir como desenhar aquele tipo específico, como `Button`
fez aqui (sem o código GUI real, como mencionado). O tipo `Button`, por
exemplo, poderia ter um bloco `impl` adicional contendo métodos relacionados ao
que acontece quando um usuário clica no botão. Esses tipos de métodos não se
aplicarão a tipos como `TextField`.

Se alguém usando nossa biblioteca decidir implementar uma struct `SelectBox`
com campos `width`, `height` e `options`, também implementará a trait `Draw` no
tipo `SelectBox`, como mostrado na Listagem 18-8.

<Listing number="18-8" file-name="src/main.rs" caption="Outro crate usando `gui` e implementando a trait `Draw` em uma struct `SelectBox`">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-08/src/main.rs:here}}
```

</Listing>

O usuário da nossa biblioteca agora pode escrever sua função `main` para criar
uma instância de `Screen`. Na instância de `Screen`, ele pode adicionar um
`SelectBox` e um `Button`, colocando cada um em um `Box<T>` para se tornar um
objeto trait. Ele pode então chamar o método `run` na instância de `Screen`,
que chamará `draw` em cada um dos componentes. A Listagem 18-9 mostra essa
implementação.

<Listing number="18-9" file-name="src/main.rs" caption="Usando objetos trait para armazenar valores de tipos diferentes que implementam a mesma trait">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-09/src/main.rs:here}}
```

</Listing>

Quando escrevemos a biblioteca, não sabíamos que alguém poderia adicionar o tipo
`SelectBox`, mas nossa implementação de `Screen` conseguiu operar sobre o novo
tipo e desenhá-lo porque `SelectBox` implementa a trait `Draw`, o que significa
que implementa o método `draw`.

Esse conceito, de se preocupar apenas com as mensagens às quais um valor
responde, em vez do tipo concreto do valor, é semelhante ao conceito de _duck
typing_ em linguagens de tipagem dinâmica: se anda como um pato e faz quack
como um pato, então deve ser um pato! Na implementação de `run` em `Screen` na
Listagem 18-5, `run` não precisa saber qual é o tipo concreto de cada
componente. Ele não verifica se um componente é uma instância de `Button` ou
`SelectBox`; apenas chama o método `draw` no componente. Ao especificar
`Box<dyn Draw>` como o tipo dos valores no vetor `components`, definimos que
`Screen` precisa de valores nos quais possamos chamar o método `draw`.

A vantagem de usar objetos trait e o sistema de tipos de Rust para escrever
código semelhante a código que usa duck typing é que nunca precisamos verificar
se um valor implementa um método específico em tempo de execução nem nos
preocupar com erros caso um valor não implemente um método mas o chamemos mesmo
assim. Rust não compilará nosso código se os valores não implementarem as
traits exigidas pelos objetos trait.

Por exemplo, a Listagem 18-10 mostra o que acontece se tentarmos criar um
`Screen` com uma `String` como componente.

<Listing number="18-10" file-name="src/main.rs" caption="Tentando usar um tipo que não implementa a trait exigida pelo objeto trait">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch18-oop/listing-18-10/src/main.rs}}
```

</Listing>

Receberemos este erro porque `String` não implementa a trait `Draw`:

```console
{{#include ../listings/ch18-oop/listing-18-10/output.txt}}
```

Esse erro nos informa que estamos passando algo para `Screen` que não
pretendíamos passar e, portanto, devemos passar um tipo diferente, ou então
devemos implementar `Draw` para `String` para que `Screen` consiga chamar
`draw` nela.

<!-- Old headings. Do not remove or links may break. -->

<a id="trait-objects-perform-dynamic-dispatch"></a>

### Realizando Despacho Dinâmico

Lembre-se da discussão sobre o processo de monomorfização realizado pelo
compilador em genéricos na seção [“Desempenho de Código Usando
Genéricos”][performance-of-code-using-generics]<!-- ignore --> do Capítulo 10:
o compilador gera implementações não genéricas de funções e métodos para cada
tipo concreto que usamos no lugar de um parâmetro de tipo genérico. O código
resultante da monomorfização faz _static dispatch_, que é quando o compilador
sabe em tempo de compilação qual método você está chamando. Isso se opõe ao
_dynamic dispatch_, que é quando o compilador não consegue dizer em tempo de
compilação qual método você está chamando. Em casos de despacho dinâmico, o
compilador emite código que saberá em tempo de execução qual método chamar.

Quando usamos objetos trait, Rust precisa usar despacho dinâmico. O compilador
não conhece todos os tipos que podem ser usados com o código que usa objetos
trait, então não sabe qual método implementado em qual tipo deve chamar. Em vez
disso, em tempo de execução, Rust usa os ponteiros dentro do objeto trait para
saber qual método chamar. Essa busca incorre em um custo em tempo de execução
que não ocorre com despacho estático. O despacho dinâmico também impede que o
compilador escolha fazer inline do código de um método, o que por sua vez
impede algumas otimizações, e Rust tem algumas regras sobre onde você pode e
não pode usar despacho dinâmico, chamadas _compatibilidade dyn_. Essas regras
estão além do escopo desta discussão, mas você pode ler mais sobre elas [na
referência][dyn-compatibility]<!-- ignore -->. No entanto, obtivemos
flexibilidade extra no código que escrevemos na Listagem 18-5 e conseguimos dar
suporte ao código da Listagem 18-9, então esse é um trade-off a considerar.

[performance-of-code-using-generics]: ch10-01-syntax.html#performance-of-code-using-generics
[dynamically-sized]: ch20-03-advanced-types.html#dynamically-sized-types-and-the-sized-trait
[dyn-compatibility]: https://doc.rust-lang.org/reference/items/traits.html#dyn-compatibility
