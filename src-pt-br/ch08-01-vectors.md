## Armazenando Listas de Valores com Vetores

O primeiro tipo de coleção que veremos é `Vec<T>`, também conhecido como
_vetor_. Vetores permitem armazenar mais de um valor em uma única estrutura de
dados que coloca todos os valores lado a lado na memória. Vetores só podem
armazenar valores do mesmo tipo. Eles são úteis quando você tem uma lista de
itens, como as linhas de texto em um arquivo ou os preços dos itens em um
carrinho de compras.

### Criando um Novo Vetor

Para criar um vetor novo e vazio, chamamos a função `Vec::new`, como mostrado
na Listagem 8-1.

<Listing number="8-1" caption="Criando um vetor novo e vazio para armazenar valores do tipo `i32`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-01/src/main.rs:here}}
```

</Listing>

Observe que adicionamos aqui uma anotação de tipo. Como não estamos inserindo
nenhum valor nesse vetor, Rust não sabe que tipo de elemento pretendemos
armazenar. Esse é um ponto importante. Vetores são implementados usando
genéricos; veremos como usar genéricos em seus próprios tipos no Capítulo 10.
Por enquanto, basta saber que o tipo `Vec<T>`, fornecido pela biblioteca
padrão, pode armazenar qualquer tipo. Quando criamos um vetor para armazenar um
tipo específico, podemos indicar esse tipo entre sinais de menor e maior. Na
Listagem 8-1, dissemos a Rust que o `Vec<T>` em `v` armazenará elementos do
tipo `i32`.

Mais frequentemente, você criará um `Vec<T>` com valores iniciais, e Rust
inferirá o tipo de valor que deseja armazenar; por isso, raramente será
necessário escrever essa anotação de tipo. Rust oferece convenientemente a
macro `vec!`, que cria um novo vetor contendo os valores que você fornecer. A
Listagem 8-2 cria um novo `Vec<i32>` contendo os valores `1`, `2` e `3`. O
tipo inteiro é `i32` porque esse é o tipo inteiro padrão, como discutimos na
seção [“Tipos de Dados”][data-types]<!-- ignore -->, no Capítulo 3.

<Listing number="8-2" caption="Criando um novo vetor contendo valores">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-02/src/main.rs:here}}
```

</Listing>

Como fornecemos valores iniciais do tipo `i32`, Rust pode inferir que o tipo de
`v` é `Vec<i32>`, e a anotação de tipo não é necessária. A seguir, veremos
como modificar um vetor.

### Atualizando um Vetor

Para criar um vetor e, em seguida, adicionar elementos a ele, podemos usar o
método `push`, como mostrado na Listagem 8-3.

<Listing number="8-3" caption="Usando o método `push` para adicionar valores a um vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-03/src/main.rs:here}}
```

</Listing>

Como acontece com qualquer variável, se quisermos poder alterar seu valor,
precisamos torná-la mutável usando a palavra-chave `mut`, como discutido no
Capítulo 3. Os números colocados no vetor são todos do tipo `i32`, e Rust
infere isso a partir dos dados, então não precisamos da anotação `Vec<i32>`.

### Lendo Elementos de Vetores

Há duas formas de fazer referência a um valor armazenado em um vetor: por meio
de indexação ou usando o método `get`. Nos exemplos a seguir, anotamos os tipos
dos valores retornados por essas operações para deixar tudo mais claro.

A Listagem 8-4 mostra os dois modos de acessar um valor em um vetor, usando a
sintaxe de indexação e o método `get`.

<Listing number="8-4" caption="Usando a sintaxe de indexação e o método `get` para acessar um item em um vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-04/src/main.rs:here}}
```

</Listing>

Observe alguns detalhes aqui. Usamos o valor de índice `2` para obter o
terceiro elemento porque vetores são indexados a partir de zero. Usar `&` e
`[]` nos dá uma referência ao elemento nesse índice. Quando usamos o método
`get` com o índice passado como argumento, recebemos um `Option<&T>`, que pode
ser usado com `match`.

Rust oferece essas duas formas de referenciar um elemento para que você possa
escolher como o programa deve se comportar quando tentar usar um índice fora da
faixa de elementos existentes. Como exemplo, vamos ver o que acontece quando
temos um vetor com cinco elementos e tentamos acessar o elemento de índice 100
com cada uma das técnicas, como mostra a Listagem 8-5.

<Listing number="8-5" caption="Tentando acessar o elemento de índice 100 em um vetor com cinco elementos">

```rust,should_panic,panics
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-05/src/main.rs:here}}
```

</Listing>

Quando executarmos esse código, o primeiro método, usando `[]`, fará o programa
entrar em pânico porque ele referencia um elemento inexistente. Esse método é
mais apropriado quando você quer que o programa falhe se houver uma tentativa
de acessar um elemento além do fim do vetor.

Quando o método `get` recebe um índice que está fora do vetor, ele retorna
`None` sem entrar em pânico. Você usaria esse método se acessar um elemento
fora da faixa do vetor puder acontecer ocasionalmente em circunstâncias
normais. Seu código então terá lógica para tratar `Some(&element)` ou `None`,
como discutimos no Capítulo 6. Por exemplo, o índice pode vir de uma pessoa
digitando um número. Se ela acidentalmente inserir um número muito grande e o
programa receber `None`, você poderia informar quantos itens existem no vetor
atual e dar outra chance para que a pessoa digite um valor válido. Isso seria
mais amigável do que derrubar o programa por causa de um erro de digitação!

Quando o programa possui uma referência válida, o borrow checker impõe as
regras de propriedade e empréstimo, vistas no Capítulo 4, para garantir que
essa referência e quaisquer outras referências ao conteúdo do vetor permaneçam
válidas. Lembre-se da regra que diz que você não pode ter referências mutáveis
e imutáveis no mesmo escopo. Essa regra se aplica na Listagem 8-6, em que
mantemos uma referência imutável ao primeiro elemento de um vetor e tentamos
adicionar um elemento ao fim. Esse programa não funcionará se também tentarmos
usar esse elemento mais tarde na função.

<Listing number="8-6" caption="Tentando adicionar um elemento a um vetor enquanto mantemos uma referência a um item">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-06/src/main.rs:here}}
```

</Listing>

Compilar esse código resultará neste erro:

```console
{{#include ../listings/ch08-common-collections/listing-08-06/output.txt}}
```

O código da Listagem 8-6 pode parecer que deveria funcionar: por que uma
referência ao primeiro elemento deveria se importar com mudanças no fim do
vetor? Esse erro existe por causa de como vetores funcionam: como eles colocam
os valores lado a lado na memória, adicionar um novo elemento ao fim do vetor
pode exigir a alocação de uma nova região de memória e a cópia dos elementos
antigos para esse novo espaço, caso não haja espaço suficiente para manter
todos os elementos juntos onde o vetor está armazenado no momento. Nesse caso,
a referência ao primeiro elemento apontaria para memória já desalocada. As
regras de empréstimo impedem que programas acabem nessa situação.

> Nota: para mais detalhes sobre a implementação de `Vec<T>`, consulte [“The
> Rustonomicon”][nomicon].

### Iterando sobre os Valores de um Vetor

Para acessar cada elemento de um vetor, iteramos por todos eles, em vez de usar
índices para acessar um elemento de cada vez. A Listagem 8-7 mostra como usar
um laço `for` para obter referências imutáveis a cada elemento de um vetor de
valores `i32` e imprimi-los.

<Listing number="8-7" caption="Imprimindo cada elemento de um vetor ao iterar sobre os elementos com um laço `for`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-07/src/main.rs:here}}
```

</Listing>

Também podemos iterar sobre referências mutáveis a cada elemento de um vetor
mutável para alterar todos os elementos. O laço `for` da Listagem 8-8 adiciona
`50` a cada elemento.

<Listing number="8-8" caption="Iterando sobre referências mutáveis aos elementos de um vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-08/src/main.rs:here}}
```

</Listing>

Para alterar o valor ao qual a referência mutável se refere, precisamos usar o
operador de desreferência `*` para acessar o valor apontado por `i` antes de
podermos usar o operador `+=`. Falaremos mais sobre o operador de
desreferência na seção [“Seguindo o Ponteiro até o Valor com o Operador de
Desreferência”][deref]<!-- ignore -->, no Capítulo 15.

Iterar sobre um vetor, seja de forma imutável ou mutável, é seguro graças às
regras do borrow checker. Se tentássemos inserir ou remover itens dentro dos
corpos dos laços `for` nas Listagens 8-7 e 8-8, receberíamos um erro do
compilador semelhante ao que vimos com o código da Listagem 8-6. A referência
ao vetor mantida pelo laço `for` impede modificações simultâneas ao vetor como
um todo.

### Usando uma Enum para Armazenar Múltiplos Tipos

Vetores só podem armazenar valores de um mesmo tipo. Isso pode ser
inconveniente; certamente há casos em que precisamos armazenar em uma lista
itens de tipos diferentes. Felizmente, as variantes de uma enum são definidas
sob o mesmo tipo da enum, então, quando precisamos de um tipo que represente
elementos de tipos diferentes, podemos definir e usar uma enum!

Por exemplo, digamos que queremos obter valores de uma linha em uma planilha na
qual algumas colunas contêm inteiros, algumas números de ponto flutuante e
algumas strings. Podemos definir uma enum cujas variantes armazenem esses
diferentes tipos de valor, e todas as variantes da enum serão consideradas do
mesmo tipo: o tipo da própria enum. Depois, podemos criar um vetor para
armazenar essa enum e, assim, armazenar efetivamente diferentes tipos. Isso é
demonstrado na Listagem 8-9.

<Listing number="8-9" caption="Definindo uma enum para armazenar valores de tipos diferentes em um único vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-09/src/main.rs:here}}
```

</Listing>

Rust precisa saber, em tempo de compilação, quais tipos estarão no vetor para
conseguir determinar exatamente quanta memória no heap será necessária para
armazenar cada elemento. Também precisamos ser explícitos sobre quais tipos são
permitidos nesse vetor. Se Rust permitisse que um vetor armazenasse qualquer
tipo, haveria a chance de um ou mais tipos causarem erros nas operações
realizadas sobre os elementos do vetor. Usar uma enum junto com uma expressão
`match` significa que Rust garantirá, em tempo de compilação, que todos os
casos possíveis sejam tratados, como discutimos no Capítulo 6.

Se você não souber, em tempo de compilação, o conjunto exaustivo de tipos que o
programa receberá em tempo de execução para armazenar em um vetor, a técnica da
enum não funcionará. Em vez disso, você poderá usar um trait object, que
abordaremos no Capítulo 18.

Agora que discutimos algumas das formas mais comuns de usar vetores, não deixe
de consultar [a documentação da API][vec-api]<!-- ignore --> para conhecer os
muitos métodos úteis definidos em `Vec<T>` pela biblioteca padrão. Por exemplo,
além de `push`, o método `pop` remove e retorna o último elemento.

### Descartar um Vetor Também Descarta seus Elementos

Como qualquer outra `struct`, um vetor é liberado quando sai de escopo, como
anotado na Listagem 8-10.

<Listing number="8-10" caption="Mostrando onde o vetor e seus elementos são descartados">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-10/src/main.rs:here}}
```

</Listing>

Quando o vetor é descartado, todo o seu conteúdo também é descartado, o que
significa que os inteiros que ele contém serão liberados. O borrow checker
garante que quaisquer referências ao conteúdo de um vetor só sejam usadas
enquanto o próprio vetor for válido.

Vamos passar para o próximo tipo de coleção: `String`!

[data-types]: ch03-02-data-types.html#data-types
[nomicon]: ../nomicon/vec/vec.html
[vec-api]: ../std/vec/struct.Vec.html
[deref]: ch15-02-deref.html#following-the-pointer-to-the-value-with-the-dereference-operator
