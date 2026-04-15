## Armazenando listas de valores com vetores

O primeiro tipo de coleção que veremos é `Vec<T>`, também conhecido como vetor.
Vetores permitem armazenar mais de um valor em uma única estrutura de dados que
coloca todos esses valores lado a lado na memória. Vetores só podem armazenar
valores do mesmo tipo. Eles são úteis quando você tem uma lista de itens, como
as linhas de texto de um arquivo ou os preços dos itens em um carrinho de
compras.

### Criando um novo vetor

Para criar um novo vetor vazio, chamamos a função `Vec::new`, como mostra a
Listagem 8-1.

<Listing number="8-1" caption="Criando um novo vetor vazio para armazenar valores do tipo `i32`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-01/src/main.rs:here}}
```

</Listing>

Observe que adicionamos aqui uma anotação de tipo. Como ainda não estamos
inserindo nenhum valor nesse vetor, Rust não sabe que tipo de elemento
pretendemos armazenar. Esse é um ponto importante. Vetores são implementados
usando genéricos; veremos como usar genéricos com seus próprios tipos no
Capítulo 10. Por enquanto, basta saber que o tipo `Vec<T>` fornecido pela
biblioteca padrão pode armazenar qualquer tipo. Quando criamos um vetor para
guardar um tipo específico, podemos especificar esse tipo entre colchetes
angulares. Na Listagem 8-1, dissemos a Rust que o `Vec<T>` em `v` conterá
elementos do tipo `i32`.

Mais frequentemente, você criará um `Vec<T>` com valores iniciais, e Rust
inferirá o tipo do valor que você quer armazenar, então raramente precisará
fazer essa anotação. Rust convenientemente fornece a macro `vec!`, que cria um
novo vetor contendo os valores que você fornecer. A Listagem 8-2 cria um novo
`Vec<i32>` com os valores `1`, `2` e `3`. O tipo inteiro é `i32` porque esse é
o tipo inteiro padrão, como discutimos na seção [“Tipos de
dados”][data-types]<!-- ignore --> do Capítulo 3.

<Listing number="8-2" caption="Criando um novo vetor contendo valores">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-02/src/main.rs:here}}
```

</Listing>

Como fornecemos valores iniciais do tipo `i32`, Rust pode inferir que o tipo de
`v` é `Vec<i32>`, e a anotação de tipo deixa de ser necessária. A seguir,
veremos como modificar um vetor.

### Atualizando um vetor

Para criar um vetor e depois adicionar elementos a ele, podemos usar o método
`push`, como mostra a Listagem 8-3.

<Listing number="8-3" caption="Usando o método `push` para adicionar valores a um vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-03/src/main.rs:here}}
```

</Listing>

Como acontece com qualquer variável, se quisermos poder alterar seu valor,
precisamos torná-la mutável usando a palavra-chave `mut`, como discutimos no
Capítulo 3. Os números que colocamos dentro são todos do tipo `i32`, e Rust
infere isso a partir dos dados, então não precisamos da anotação `Vec<i32>`.

### Lendo elementos de vetores

Há duas formas de referenciar um valor armazenado em um vetor: por indexação ou
usando o método `get`. Nos exemplos a seguir, anotamos os tipos dos valores
retornados por essas funções para dar mais clareza.

A Listagem 8-4 mostra os dois jeitos de acessar um valor em um vetor: com a
sintaxe de indexação e com o método `get`.

<Listing number="8-4" caption="Usando a sintaxe de indexação e o método `get` para acessar um item de um vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-04/src/main.rs:here}}
```

</Listing>

Observe alguns detalhes aqui. Usamos o índice `2` para obter o terceiro
elemento porque vetores são indexados por números começando em zero. Usar `&`
e `[]` nos dá uma referência ao elemento naquele índice. Quando usamos o
método `get` com o índice passado como argumento, recebemos um `Option<&T>`,
que podemos usar com `match`.

Rust oferece essas duas maneiras de referenciar um elemento para que você possa
escolher como o programa deve se comportar quando tentar usar um índice fora do
intervalo de elementos existentes. Como exemplo, vamos ver o que acontece
quando temos um vetor com cinco elementos e então tentamos acessar o elemento
no índice 100 com cada uma dessas técnicas, como mostra a Listagem 8-5.

<Listing number="8-5" caption="Tentando acessar o elemento no índice 100 em um vetor que contém cinco elementos">

```rust,should_panic,panics
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-05/src/main.rs:here}}
```

</Listing>

Quando executamos esse código, o primeiro método, com `[]`, fará o programa
entrar em pânico porque ele referencia um elemento inexistente. Esse método é
mais apropriado quando você quer que o programa falhe caso haja uma tentativa
de acessar um elemento além do fim do vetor.

Quando o método `get` recebe um índice fora do intervalo do vetor, ele retorna
`None` sem entrar em pânico. Você usaria esse método se acessar um elemento
fora dos limites do vetor puder acontecer ocasionalmente em circunstâncias
normais. Nesse caso, seu código terá a lógica para lidar com `Some(&element)`
ou `None`, como discutimos no Capítulo 6. Por exemplo, o índice pode vir de
uma pessoa digitando um número. Se ela acidentalmente informar um número grande
demais e o programa receber `None`, você pode dizer à pessoa quantos itens há
no vetor atual e dar outra chance de informar um valor válido. Isso seria mais
amigável do que derrubar o programa por causa de um erro de digitação!

Quando o programa possui uma referência válida, o borrow checker aplica as
regras de ownership e borrowing, abordadas no Capítulo 4, para garantir que
essa referência e quaisquer outras referências ao conteúdo do vetor permaneçam
válidas. Lembre-se da regra que diz que você não pode ter referências mutáveis
e imutáveis ao mesmo tempo no mesmo escopo. Essa regra se aplica à Listagem
8-6, em que mantemos uma referência imutável ao primeiro elemento de um vetor e
tentamos adicionar um elemento ao final. Esse programa não funcionará se também
tentarmos usar esse elemento mais tarde na função.

<Listing number="8-6" caption="Tentando adicionar um elemento a um vetor enquanto se mantém uma referência a um item">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-06/src/main.rs:here}}
```

</Listing>

Compilar esse código resultará neste erro:

```console
{{#include ../listings/ch08-common-collections/listing-08-06/output.txt}}
```

O código da Listagem 8-6 pode parecer que deveria funcionar: por que uma
referência ao primeiro elemento se importaria com mudanças no final do vetor?
Esse erro existe por causa de como vetores funcionam: como vetores colocam os
valores lado a lado na memória, adicionar um novo elemento ao final do vetor
pode exigir alocar uma nova região de memória e copiar os elementos antigos
para esse novo espaço, caso não haja espaço suficiente para manter todos os
elementos juntos onde o vetor está armazenado atualmente. Nesse caso, a
referência ao primeiro elemento apontaria para memória já desalocada. As regras
de borrowing impedem que programas acabem nessa situação.

> Nota: para mais detalhes sobre a implementação do tipo `Vec<T>`, veja
> [“The Rustonomicon”][nomicon].

### Iterando sobre os valores de um vetor

Para acessar cada elemento de um vetor em sequência, iteramos por todos os
elementos, em vez de usar índices para acessar um de cada vez. A Listagem 8-7
mostra como usar um laço `for` para obter referências imutáveis a cada elemento
de um vetor de valores `i32` e imprimi-los.

<Listing number="8-7" caption="Imprimindo cada elemento de um vetor ao iterar pelos elementos com um laço `for`">

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

Para alterar o valor ao qual a referência mutável aponta, precisamos usar o
operador de desreferência `*` para chegar ao valor em `i` antes de podermos
usar o operador `+=`. Falaremos mais sobre o operador de desreferência na
seção [“Seguindo o ponteiro até o valor com o operador de
desreferência”][deref]<!-- ignore --> do Capítulo 15.

Iterar sobre um vetor, de forma imutável ou mutável, é seguro por causa das
regras do borrow checker. Se tentássemos inserir ou remover itens dentro dos
corpos dos laços `for` das Listagens 8-7 e 8-8, receberíamos um erro do
compilador semelhante ao que vimos no código da Listagem 8-6. A referência ao
vetor que o laço `for` mantém impede a modificação simultânea do vetor inteiro.

### Usando um enum para armazenar vários tipos

Vetores só podem armazenar valores do mesmo tipo. Isso pode ser inconveniente:
há, sem dúvida, casos de uso em que precisamos armazenar uma lista de itens de
tipos diferentes. Felizmente, as variantes de um enum são definidas sob o mesmo
tipo enum, então, quando precisamos que um único tipo represente elementos de
tipos diferentes, podemos definir e usar um enum.

Por exemplo, digamos que queremos obter valores de uma linha em uma planilha, e
algumas colunas dessa linha contêm inteiros, algumas contêm números de ponto
flutuante e outras contêm strings. Podemos definir um enum cujas variantes
armazenem esses diferentes tipos de valor, e todas as variantes do enum serão
consideradas do mesmo tipo: o tipo do próprio enum. Então, podemos criar um
vetor para armazenar esse enum e, no fim das contas, guardar tipos diferentes.
Fizemos essa demonstração na Listagem 8-9.

<Listing number="8-9" caption="Definindo um enum para armazenar valores de tipos diferentes em um mesmo vetor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-09/src/main.rs:here}}
```

</Listing>

Rust precisa saber, em tempo de compilação, quais tipos estarão no vetor para
que saiba exatamente quanta memória no heap será necessária para armazenar cada
elemento. Também precisamos ser explícitos sobre quais tipos são permitidos
nesse vetor. Se Rust permitisse que um vetor armazenasse qualquer tipo, haveria
a possibilidade de que um ou mais desses tipos causassem erros nas operações
realizadas sobre os elementos do vetor. Usar um enum com uma expressão `match`
significa que Rust garantirá em tempo de compilação que todos os casos
possíveis serão tratados, como discutimos no Capítulo 6.

Se você não conhece, em tempo de compilação, o conjunto completo de tipos que
um programa pode receber em tempo de execução para armazenar em um vetor, a
técnica com enum não funcionará. Nesse caso, você pode usar um trait object,
assunto que veremos no Capítulo 18.

Agora que discutimos algumas das formas mais comuns de usar vetores, não deixe
de revisar [a documentação da API][vec-api]<!-- ignore --> para conhecer os
muitos métodos úteis definidos para `Vec<T>` na biblioteca padrão. Por exemplo,
além de `push`, existe também um método `pop`, que remove e retorna o último
elemento.

### Descartar um vetor descarta seus elementos

Como qualquer outro `struct`, um vetor é liberado quando sai de escopo, como
indicado na Listagem 8-10.

<Listing number="8-10" caption="Mostrando onde o vetor e seus elementos são descartados">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-10/src/main.rs:here}}
```

</Listing>

Quando o vetor é descartado, todo o seu conteúdo também é descartado, o que
significa que os inteiros que ele contém serão limpos. O borrow checker garante
que quaisquer referências ao conteúdo de um vetor só sejam usadas enquanto o
próprio vetor for válido.

Vamos passar para o próximo tipo de coleção: `String`!

[data-types]: ch03-02-data-types.html#data-types
[nomicon]: ../nomicon/vec/vec.html
[vec-api]: ../std/vec/struct.Vec.html
[deref]: ch15-02-deref.html#following-the-pointer-to-the-value-with-the-dereference-operator
