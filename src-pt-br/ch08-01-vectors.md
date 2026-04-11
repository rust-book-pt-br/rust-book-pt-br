## Armazenando listas de valores com vetores

O primeiro tipo de coleção que veremos é `Vec<T>`, também conhecido como vetor.
Os vetores permitem armazenar mais de um valor em uma única estrutura de dados que
coloca todos os valores um ao lado do outro na memória. Vetores só podem armazenar valores
do mesmo tipo. Eles são úteis quando você tem uma lista de itens, como o
linhas de texto em um arquivo ou os preços dos itens em um carrinho de compras.

### Criando um novo vetor

Para criar um novo vetor vazio, chamamos a função `Vec::new`, conforme mostrado em
Listagem 8-1.

<Listing number="8-1" caption="Creating a new, empty vector to hold values of type `i32`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-01/src/main.rs:here}}
```

</Listing>

Observe que adicionamos uma anotação de tipo aqui. Porque não estamos inserindo nenhum
valores neste vetor, Rust não sabe que tipo de elementos pretendemos
loja. Este é um ponto importante. Os vetores são implementados usando genéricos;
abordaremos como usar genéricos com seus próprios tipos no Capítulo 10. Por enquanto,
saiba que o tipo `Vec<T>` fornecido pela biblioteca padrão pode conter qualquer tipo.
Quando criamos um vetor para conter um tipo específico, podemos especificar o tipo dentro
colchetes angulares. Na Listagem 8-1, dissemos a Rust que `Vec<T>` em `v` irá
contém elementos do tipo `i32`.

Mais frequentemente, você criará um `Vec<T>` com valores iniciais e Rust irá inferir
o tipo de valor que você deseja armazenar, então raramente você precisa fazer esse tipo
anotação. Rust fornece convenientemente a macro `vec!`, que criará um
novo vetor que contém os valores que você atribui. A Listagem 8-2 cria um novo
`Vec<i32>` que contém os valores `1`, `2` e `3`. O tipo inteiro é `i32`
porque esse é o tipo inteiro padrão, conforme discutimos na seção [“Data
Tipos”][data-types]<!-- ignore --> seção do Capítulo 3.

<Listing number="8-2" caption="Creating a new vector containing values">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-02/src/main.rs:here}}
```

</Listing>

Como fornecemos valores iniciais `i32`, Rust pode inferir que o tipo de `v`
é `Vec<i32>` e a anotação de tipo não é necessária. A seguir, veremos como
para modificar um vetor.

### Atualizando um vetor

Para criar um vetor e depois adicionar elementos a ele, podemos usar o método `push`,
conforme mostrado na Listagem 8-3.

<Listing number="8-3" caption="Using the `push` method to add values to a vector">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-03/src/main.rs:here}}
```

</Listing>

Como acontece com qualquer variável, se quisermos alterar seu valor, precisamos
torne-o mutável usando a palavra-chave `mut`, conforme discutido no Capítulo 3. Os números
colocamos dentro são todos do tipo `i32`, e Rust infere isso a partir dos dados, então
não precisamos da anotação `Vec<i32>`.

### Lendo Elementos de Vetores

Existem duas maneiras de referenciar um valor armazenado em um vetor: via indexação ou por
usando o método `get`. Nos exemplos a seguir, anotamos os tipos de
os valores retornados dessas funções para maior clareza.

A Listagem 8-4 mostra os dois métodos de acesso a um valor em um vetor, com indexação
sintaxe e o método `get`.

<Listing number="8-4" caption="Using indexing syntax and using the `get` method to access an item in a vector">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-04/src/main.rs:here}}
```

</Listing>

Observe alguns detalhes aqui. Usamos o valor do índice `2` para obter o terceiro elemento
porque os vetores são indexados por número, começando em zero. Usando `&` e `[]`
nos dá uma referência ao elemento no valor do índice. Quando usamos o `get`
método com o índice passado como argumento, obtemos um `Option<&T>` que podemos
use com `match`.

Rust fornece essas duas maneiras de referenciar um elemento para que você possa escolher como
o programa se comporta quando você tenta usar um valor de índice fora do intervalo de
elementos existentes. Como exemplo, vamos ver o que acontece quando temos um vetor
de cinco elementos e então tentamos acessar um elemento no índice 100 com cada
técnica, conforme mostrado na Listagem 8-5.

<Listing number="8-5" caption="Attempting to access the element at index 100 in a vector containing five elements">

```rust,should_panic,panics
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-05/src/main.rs:here}}
```

</Listing>

Quando executamos este código, o primeiro método `[]` fará com que o programa entre em pânico
porque faz referência a um elemento inexistente. Este método é melhor usado quando você
deseja que seu programa trave se houver uma tentativa de acessar um elemento além do
final do vetor.

Quando o método `get` recebe um índice que está fora do vetor, ele retorna
`None` sem entrar em pânico. Você usaria este método se acessasse um elemento
além do alcance do vetor pode acontecer ocasionalmente sob condições normais
circunstâncias. Seu código terá então lógica para lidar com qualquer um
`Some(&element)` ou `None`, conforme discutido no Capítulo 6. Por exemplo, o índice
pode vir de uma pessoa digitando um número. Se eles acidentalmente entrarem em um
número que é muito grande e o programa obtém um valor `None`, você pode dizer ao
usuário quantos itens estão no vetor atual e dê a eles outra chance de
insira um valor válido. Isso seria mais fácil de usar do que travar o programa
devido a um erro de digitação!

Quando o programa tem uma referência válida, o verificador de empréstimo impõe a
regras de propriedade e empréstimo (abordadas no Capítulo 4) para garantir que este
referência e quaisquer outras referências ao conteúdo do vetor permanecem válidas.
Lembre-se da regra que afirma que você não pode ter referências mutáveis ​​e imutáveis ​​em
o mesmo escopo. Essa regra se aplica na Listagem 8-6, onde mantemos uma imutável
referência ao primeiro elemento em um vetor e tente adicionar um elemento ao
fim. Este programa não funcionará se também tentarmos nos referir a esse elemento posteriormente
a função.

<Listing number="8-6" caption="Attempting to add an element to a vector while holding a reference to an item">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-06/src/main.rs:here}}
```

</Listing>

Compilar este código resultará neste erro:

```console
{{#include ../listings/ch08-common-collections/listing-08-06/output.txt}}
```

O código na Listagem 8-6 pode parecer que deveria funcionar: Por que uma referência deveria
ao primeiro elemento se preocupa com as mudanças no final do vetor? Este erro é
devido à forma como os vetores funcionam: porque os vetores colocam os valores próximos uns dos outros
na memória, adicionar um novo elemento no final do vetor pode exigir
alocando nova memória e copiando os elementos antigos para o novo espaço, se houver
não há espaço suficiente para colocar todos os elementos próximos uns dos outros onde o vetor
está atualmente armazenado. Nesse caso, a referência ao primeiro elemento seria
apontando para memória desalocada. As regras de empréstimo impedem que os programas
acabando nessa situação.

> Nota: Para obter mais detalhes sobre a implementação do tipo `Vec<T>`, consulte [“O
> Rustonomicon”][nomicon].

### Iterando sobre os valores em um vetor

Para acessar cada elemento em um vetor, iteraríamos por todos os
elementos em vez de usar índices para acessar um de cada vez. A Listagem 8-7 mostra como
usar um loop `for` para obter referências imutáveis ​​para cada elemento em um vetor de
`i32` valores e imprima-os.

<Listing number="8-7" caption="Printing each element in a vector by iterating over the elements using a `for` loop">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-07/src/main.rs:here}}
```

</Listing>

Também podemos iterar sobre referências mutáveis ​​para cada elemento em um vetor mutável
para fazer alterações em todos os elementos. O loop `for` na Listagem 8-8
adicionará `50` a cada elemento.

<Listing number="8-8" caption="Iterating over mutable references to elements in a vector">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-08/src/main.rs:here}}
```

</Listing>

Para alterar o valor ao qual a referência mutável se refere, temos que usar o comando
Operador de desreferência `*` para chegar ao valor em `i` antes de podermos usar `+=`
operador. Falaremos mais sobre o operador de desreferência na seção [“Seguindo o
Referência à seção Valor”][deref]<!-- ignore --> do Capítulo 15.

Iterar sobre um vetor, seja imutável ou mutável, é seguro devido ao
emprestar as regras do verificador. Se tentarmos inserir ou remover itens no `for`
corpos de loop na Listagem 8-7 e na Listagem 8-8, obteríamos um erro do compilador
semelhante ao que obtivemos com o código da Listagem 8-6. A referência ao
vetor que o loop `for` contém impede a modificação simultânea do
vetor inteiro.

### Usando um Enum para armazenar vários tipos

Os vetores só podem armazenar valores do mesmo tipo. Isso pode ser
inconveniente; definitivamente existem casos de uso para a necessidade de armazenar uma lista de
itens de diferentes tipos. Felizmente, as variantes de um enum são definidas
sob o mesmo tipo enum, então quando precisamos de um tipo para representar elementos de
tipos diferentes, podemos definir e usar um enum!

Por exemplo, digamos que queremos obter valores de uma linha em uma planilha na qual
algumas das colunas da linha contêm números inteiros, alguns números de ponto flutuante,
e algumas cordas. Podemos definir um enum cujas variantes conterão os diferentes
tipos de valor, e todas as variantes enum serão consideradas do mesmo tipo: que
do enum. Então, podemos criar um vetor para armazenar esse enum e, em última análise,
mantenha diferentes tipos. Demonstramos isso na Listagem 8-9.

<Listing number="8-9" caption="Defining an enum to store values of different types in one vector">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-09/src/main.rs:here}}
```

</Listing>

Rust precisa saber quais tipos estarão no vetor em tempo de compilação para que
sabe exatamente quanta memória no heap será necessária para armazenar cada elemento.
Também devemos ser explícitos sobre quais tipos são permitidos neste vetor. Se ferrugem
permitisse que um vetor mantivesse qualquer tipo, haveria uma chance de que um ou mais dos
os tipos causariam erros nas operações executadas nos elementos de
o vetor. Usar um enum mais uma expressão `match` significa que Rust garantirá
em tempo de compilação, todos os casos possíveis são tratados, conforme discutido no Capítulo 6.

Se você não conhece o conjunto exaustivo de tipos que um programa obterá em tempo de execução para
armazenar em um vetor, a técnica enum não funcionará. Em vez disso, você pode usar uma característica
objeto, que abordaremos no Capítulo 18.

Agora que discutimos algumas das formas mais comuns de usar vetores, certifique-se
para revisar [a documentação da API][vec-api]<!-- ignore --> para todos os muitos
métodos úteis definidos em `Vec<T>` pela biblioteca padrão. Por exemplo, em
além de `push`, um método `pop` remove e retorna o último elemento.

### Eliminar um vetor elimina seus elementos

Como qualquer outro `struct`, um vetor é liberado quando sai do escopo, como
anotado na Listagem 8-10.

<Listing number="8-10" caption="Showing where the vector and its elements are dropped">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-10/src/main.rs:here}}
```

</Listing>

Quando o vetor é eliminado, todo o seu conteúdo também é eliminado, o que significa que o
inteiros que ele contém serão limpos. O verificador de empréstimo garante que qualquer
referências ao conteúdo de um vetor são usadas apenas enquanto o próprio vetor é
válido.

Vamos passar para o próximo tipo de coleção: `String`!

[data-types]: ch03-02-data-types.html#data-types
[nomicon]: ../nomicon/vec/vec.html
[vec-api]: ../std/vec/struct.Vec.html
[deref]: ch15-02-deref.html#following-the-pointer-to-the-value-with-the-dereference-operator
