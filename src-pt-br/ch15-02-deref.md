<!-- Old headings. Do not remove or links may break. -->

<a id="treating-smart-pointers-like-regular-references-with-the-deref-trait"></a>
<a id="treating-smart-pointers-like-regular-references-with-deref"></a>

## Tratando Ponteiros Inteligentes como Referências Comuns

Implementar a trait `Deref` permite personalizar o comportamento do _operador
de desreferência_ `*` (não confundir com o operador de multiplicação ou glob).
Ao implementar `Deref` de modo que um ponteiro inteligente possa ser tratado
como uma referência comum, você pode escrever código que opera sobre
referências e usar esse código também com ponteiros inteligentes.

Vamos primeiro ver como o operador de desreferência funciona com referências
comuns. Depois, tentaremos definir um tipo personalizado que se comporta como
`Box<T>` e veremos por que o operador de desreferência não funciona como uma
referência no nosso tipo recém-definido. Exploraremos como implementar a trait
`Deref` torna possível que ponteiros inteligentes funcionem de maneiras
semelhantes a referências. Então veremos o recurso de coerção de desreferência
de Rust e como ele nos permite trabalhar tanto com referências quanto com
ponteiros inteligentes.

<!-- Old headings. Do not remove or links may break. -->

<a id="following-the-pointer-to-the-value-with-the-dereference-operator"></a>
<a id="following-the-pointer-to-the-value"></a>

### Seguindo a Referência até o Valor

Uma referência comum é um tipo de ponteiro, e uma forma de pensar em um
ponteiro é como uma seta para um valor armazenado em outro lugar. Na Listagem
15-6, criamos uma referência para um valor `i32` e então usamos o operador de
desreferência para seguir a referência até o valor.

<Listing number="15-6" file-name="src/main.rs" caption="Usando o operador de desreferência para seguir uma referência até um valor `i32`">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-06/src/main.rs}}
```

</Listing>

A variável `x` armazena um valor `i32`, `5`. Definimos `y` como uma referência
a `x`. Podemos verificar que `x` é igual a `5`. No entanto, se quisermos fazer
uma asserção sobre o valor em `y`, precisamos usar `*y` para seguir a
referência até o valor para o qual ela aponta (daí _desreferenciar_), para que
o compilador possa comparar o valor real. Depois de desreferenciar `y`, temos
acesso ao valor inteiro para o qual `y` aponta, que podemos comparar com `5`.

Se tentássemos escrever `assert_eq!(5, y);`, receberíamos este erro de
compilação:

```console
{{#include ../listings/ch15-smart-pointers/output-only-01-comparing-to-reference/output.txt}}
```

Comparar um número com uma referência para um número não é permitido, porque
eles são tipos diferentes. Precisamos usar o operador de desreferência para
seguir a referência até o valor para o qual ela aponta.

### Usando `Box<T>` como uma Referência

Podemos reescrever o código da Listagem 15-6 para usar um `Box<T>` em vez de
uma referência; o operador de desreferência usado no `Box<T>` da Listagem 15-7
funciona da mesma forma que o operador de desreferência usado na referência da
Listagem 15-6.

<Listing number="15-7" file-name="src/main.rs" caption="Usando o operador de desreferência em um `Box<i32>`">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-07/src/main.rs}}
```

</Listing>

A principal diferença entre a Listagem 15-7 e a Listagem 15-6 é que aqui
definimos `y` como uma instância de um box que aponta para uma cópia do valor
de `x`, em vez de uma referência que aponta para o valor de `x`. Na última
asserção, podemos usar o operador de desreferência para seguir o ponteiro do
box da mesma forma que fizemos quando `y` era uma referência. A seguir,
exploraremos o que há de especial em `Box<T>` que nos permite usar o operador
de desreferência, definindo nosso próprio tipo de box.

### Definindo Nosso Próprio Ponteiro Inteligente

Vamos construir um tipo wrapper semelhante ao tipo `Box<T>` fornecido pela
biblioteca padrão para experimentar como tipos de ponteiros inteligentes se
comportam de forma diferente de referências por padrão. Depois, veremos como
adicionar a capacidade de usar o operador de desreferência.

> Observação: há uma grande diferença entre o tipo `MyBox<T>` que estamos
> prestes a construir e o `Box<T>` real: nossa versão não armazenará seus dados
> no heap. Estamos focando este exemplo em `Deref`, então o local real onde os
> dados são armazenados é menos importante que o comportamento semelhante ao de
> ponteiro.

No fim das contas, o tipo `Box<T>` é definido como uma tuple struct com um
elemento, então a Listagem 15-8 define um tipo `MyBox<T>` da mesma forma.
Também definiremos uma função `new` para corresponder à função `new` definida
em `Box<T>`.

<Listing number="15-8" file-name="src/main.rs" caption="Definindo um tipo `MyBox<T>`">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-08/src/main.rs:here}}
```

</Listing>

Definimos uma struct chamada `MyBox` e declaramos um parâmetro genérico `T`
porque queremos que nosso tipo armazene valores de qualquer tipo. O tipo
`MyBox` é uma tuple struct com um elemento do tipo `T`. A função `MyBox::new`
recebe um parâmetro do tipo `T` e retorna uma instância de `MyBox` que armazena
o valor passado.

Vamos tentar adicionar a função `main` da Listagem 15-7 à Listagem 15-8 e
alterá-la para usar o tipo `MyBox<T>` que definimos em vez de `Box<T>`. O
código da Listagem 15-9 não compilará, porque Rust não sabe como
desreferenciar `MyBox`.

<Listing number="15-9" file-name="src/main.rs" caption="Tentando usar `MyBox<T>` da mesma forma que usamos referências e `Box<T>`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-09/src/main.rs:here}}
```

</Listing>

Aqui está o erro de compilação resultante:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-09/output.txt}}
```

Nosso tipo `MyBox<T>` não pode ser desreferenciado porque não implementamos
essa capacidade no tipo. Para habilitar a desreferência com o operador `*`,
implementamos a trait `Deref`.

<!-- Old headings. Do not remove or links may break. -->

<a id="treating-a-type-like-a-reference-by-implementing-the-deref-trait"></a>

### Implementando a Trait `Deref`

Como discutimos em [“Implementando uma Trait em um Tipo”][impl-trait]<!-- ignore -->
no Capítulo 10, para implementar uma trait precisamos fornecer implementações
para os métodos exigidos por ela. A trait `Deref`, fornecida pela biblioteca
padrão, exige que implementemos um método chamado `deref`, que pega `self`
emprestado e retorna uma referência para os dados internos. A Listagem 15-10
contém uma implementação de `Deref` para adicionar à definição de `MyBox<T>`.

<Listing number="15-10" file-name="src/main.rs" caption="Implementando `Deref` em `MyBox<T>`">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-10/src/main.rs:here}}
```

</Listing>

A sintaxe `type Target = T;` define um tipo associado para a trait `Deref`
usar. Tipos associados são uma forma um pouco diferente de declarar um
parâmetro genérico, mas você não precisa se preocupar com eles por enquanto;
vamos cobri-los em mais detalhes no Capítulo 20.

Preenchemos o corpo do método `deref` com `&self.0` para que `deref` retorne
uma referência ao valor que queremos acessar com o operador `*`; lembre-se de
[“Criando Diferentes Tipos com Tuple Structs”][tuple-structs]<!-- ignore --> no
Capítulo 5 que `.0` acessa o primeiro valor em uma tuple struct. A função
`main` da Listagem 15-9, que chama `*` no valor `MyBox<T>`, agora compila, e
as asserções passam!

Sem a trait `Deref`, o compilador só consegue desreferenciar referências `&`.
O método `deref` dá ao compilador a capacidade de pegar um valor de qualquer
tipo que implemente `Deref` e chamar o método `deref` para obter uma referência
que ele sabe desreferenciar.

Quando escrevemos `*y` na Listagem 15-9, por trás dos panos Rust executou, na
verdade, este código:

```rust,ignore
*(y.deref())
```

Rust substitui o operador `*` por uma chamada ao método `deref` e depois por
uma desreferência comum, para que não precisemos pensar se devemos ou não
chamar o método `deref`. Esse recurso de Rust nos permite escrever código que
funciona de forma idêntica quando temos uma referência comum ou um tipo que
implementa `Deref`.

O motivo pelo qual o método `deref` retorna uma referência a um valor, e pelo
qual a desreferência comum fora dos parênteses em `*(y.deref())` ainda é
necessária, tem a ver com o sistema de ownership. Se o método `deref` retornasse
o valor diretamente em vez de uma referência ao valor, o valor seria movido para
fora de `self`. Não queremos tomar ownership do valor interno dentro de
`MyBox<T>` neste caso nem na maioria dos casos em que usamos o operador de
desreferência.

Observe que o operador `*` é substituído por uma chamada ao método `deref` e
então por uma chamada ao operador `*` apenas uma vez, cada vez que usamos `*` em
nosso código. Como a substituição do operador `*` não recorre infinitamente,
acabamos com dados do tipo `i32`, que correspondem ao `5` em `assert_eq!` na
Listagem 15-9.

<!-- Old headings. Do not remove or links may break. -->

<a id="implicit-deref-coercions-with-functions-and-methods"></a>
<a id="using-deref-coercions-in-functions-and-methods"></a>

### Usando Coerção de Desreferência em Funções e Métodos

_Coerção de desreferência_ (_deref coercion_) converte uma referência para um
tipo que implementa a trait `Deref` em uma referência para outro tipo. Por
exemplo, a coerção de desreferência pode converter `&String` em `&str` porque
`String` implementa a trait `Deref` de modo que retorna `&str`. A coerção de
desreferência é uma conveniência que Rust aplica a argumentos de funções e
métodos, e funciona apenas em tipos que implementam a trait `Deref`. Ela
acontece automaticamente quando passamos uma referência para o valor de um tipo
específico como argumento para uma função ou método que não corresponde ao tipo
do parâmetro na definição da função ou do método. Uma sequência de chamadas ao
método `deref` converte o tipo que fornecemos no tipo de que o parâmetro
precisa.

A coerção de desreferência foi adicionada a Rust para que programadores, ao
escrever chamadas de funções e métodos, não precisassem adicionar tantas
referências e desreferências explícitas com `&` e `*`. O recurso de coerção de
desreferência também nos permite escrever mais código que funcione tanto com
referências quanto com ponteiros inteligentes.

Para ver a coerção de desreferência em ação, vamos usar o tipo `MyBox<T>` que
definimos na Listagem 15-8, bem como a implementação de `Deref` que adicionamos
na Listagem 15-10. A Listagem 15-11 mostra a definição de uma função que tem um
parâmetro string slice.

<Listing number="15-11" file-name="src/main.rs" caption="Uma função `hello` que tem o parâmetro `name` do tipo `&str`">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-11/src/main.rs:here}}
```

</Listing>

Podemos chamar a função `hello` com um string slice como argumento, como
`hello("Rust");`, por exemplo. A coerção de desreferência torna possível chamar
`hello` com uma referência para um valor do tipo `MyBox<String>`, como mostrado
na Listagem 15-12.

<Listing number="15-12" file-name="src/main.rs" caption="Chamando `hello` com uma referência para um valor `MyBox<String>`, o que funciona por causa da coerção de desreferência">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-12/src/main.rs:here}}
```

</Listing>

Aqui chamamos a função `hello` com o argumento `&m`, que é uma referência para
um valor `MyBox<String>`. Como implementamos a trait `Deref` em `MyBox<T>` na
Listagem 15-10, Rust pode transformar `&MyBox<String>` em `&String` chamando
`deref`. A biblioteca padrão fornece uma implementação de `Deref` em `String`
que retorna um string slice, e isso está documentado na API de `Deref`. Rust
chama `deref` novamente para transformar `&String` em `&str`, que corresponde à
definição da função `hello`.

Se Rust não implementasse coerção de desreferência, teríamos que escrever o
código da Listagem 15-13 em vez do código da Listagem 15-12 para chamar
`hello` com um valor do tipo `&MyBox<String>`.

<Listing number="15-13" file-name="src/main.rs" caption="O código que teríamos que escrever se Rust não tivesse coerção de desreferência">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-13/src/main.rs:here}}
```

</Listing>

O `(*m)` desreferencia o `MyBox<String>` em uma `String`. Então, `&` e `[..]`
obtêm um string slice da `String` que é igual à string inteira para
corresponder à assinatura de `hello`. Esse código sem coerções de
desreferência é mais difícil de ler, escrever e entender com todos esses
símbolos envolvidos. A coerção de desreferência permite que Rust lide com essas
conversões automaticamente para nós.

Quando a trait `Deref` está definida para os tipos envolvidos, Rust analisará
os tipos e usará `Deref::deref` tantas vezes quanto necessário para obter uma
referência que corresponda ao tipo do parâmetro. A quantidade de vezes que
`Deref::deref` precisa ser inserida é resolvida em tempo de compilação, então
não há penalidade em tempo de execução por aproveitar a coerção de
desreferência!

<!-- Old headings. Do not remove or links may break. -->

<a id="how-deref-coercion-interacts-with-mutability"></a>

### Lidando com Coerção de Desreferência em Referências Mutáveis

De forma semelhante a como você usa a trait `Deref` para sobrescrever o
operador `*` em referências imutáveis, você pode usar a trait `DerefMut` para
sobrescrever o operador `*` em referências mutáveis.

Rust faz coerção de desreferência quando encontra tipos e implementações de
traits em três casos:

1. De `&T` para `&U` quando `T: Deref<Target=U>`
2. De `&mut T` para `&mut U` quando `T: DerefMut<Target=U>`
3. De `&mut T` para `&U` quando `T: Deref<Target=U>`

Os dois primeiros casos são iguais, exceto que o segundo implementa
mutabilidade. O primeiro caso afirma que, se você tem uma `&T` e `T` implementa
`Deref` para algum tipo `U`, você pode obter uma `&U` de forma transparente. O
segundo caso afirma que a mesma coerção de desreferência acontece para
referências mutáveis.

O terceiro caso é mais sutil: Rust também fará coerção de uma referência
mutável para uma imutável. Mas o inverso _não_ é possível: referências
imutáveis nunca serão coagidas para referências mutáveis. Por causa das regras
de borrowing, se você tem uma referência mutável, essa referência mutável deve
ser a única referência para aqueles dados (caso contrário, o programa não
compilaria). Converter uma referência mutável em uma referência imutável nunca
quebrará as regras de borrowing. Converter uma referência imutável em uma
referência mutável exigiria que a referência imutável inicial fosse a única
referência imutável para aqueles dados, mas as regras de borrowing não garantem
isso. Portanto, Rust não pode assumir que converter uma referência imutável em
uma referência mutável é possível.

[impl-trait]: ch10-02-traits.html#implementing-a-trait-on-a-type
[tuple-structs]: ch05-01-defining-structs.html#creating-different-types-with-tuple-structs
