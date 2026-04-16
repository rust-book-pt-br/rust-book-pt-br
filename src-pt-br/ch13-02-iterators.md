## Processando uma Série de Itens com Iteradores

O padrão de iterador permite executar alguma tarefa sobre uma sequência de
itens, um de cada vez. Um iterador é responsável pela lógica de percorrer cada
item e de determinar quando a sequência terminou. Quando você usa iteradores,
não precisa reimplementar essa lógica por conta própria.

Em Rust, iteradores são _preguiçosos_, o que significa que eles não fazem nada
até que você chame métodos que consumam o iterador para efetivamente usá-lo.
Por exemplo, o código da Listagem 13-10 cria um iterador sobre os itens do
vetor `v1` chamando o método `iter` definido em `Vec<T>`. Sozinho, esse código
não faz nada de útil.

<Listing number="13-10" file-name="src/main.rs" caption="Criando um iterador">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-10/src/main.rs:here}}
```

</Listing>

O iterador é armazenado na variável `v1_iter`. Depois de criar um iterador,
podemos usá-lo de várias maneiras. Na Listagem 3-5, iteramos sobre um array
usando um laço `for` para executar algum código sobre cada um de seus itens.
Nos bastidores, isso criou e depois consumiu um iterador de forma implícita,
mas deixamos de lado como exatamente isso funcionava até agora.

No exemplo da Listagem 13-11, separamos a criação do iterador do uso do
iterador no laço `for`. Quando o laço `for` é executado usando o iterador em
`v1_iter`, cada elemento do iterador é usado em uma iteração do laço, o que
imprime cada valor.

<Listing number="13-11" file-name="src/main.rs" caption="Usando um iterador em um laço `for`">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-11/src/main.rs:here}}
```

</Listing>

Em linguagens que não têm iteradores fornecidos por suas bibliotecas padrão,
você provavelmente escreveria essa mesma funcionalidade criando uma variável
inicializada com índice 0, usando essa variável para indexar o vetor e obter um
valor, e incrementando a variável em um laço até ela atingir o número total de
itens no vetor.

Os iteradores cuidam de toda essa lógica para você, reduzindo a quantidade de
código repetitivo que você poderia facilmente escrever errado. Eles também dão
mais flexibilidade para reutilizar a mesma lógica com muitos tipos diferentes
de sequências, não apenas estruturas de dados que podem ser indexadas, como
vetores. Vamos ver como os iteradores fazem isso.

### A Trait `Iterator` e o Método `next`

Todos os iteradores implementam uma trait chamada `Iterator`, definida na
biblioteca padrão. A definição dessa trait se parece com isto:

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // methods with default implementations elided
}
```

Observe que essa definição usa uma sintaxe nova: `type Item` e `Self::Item`,
que definem um tipo associado a essa trait. Falaremos de tipos associados em
detalhes no Capítulo 20. Por enquanto, tudo o que você precisa saber é que esse
código diz que implementar a trait `Iterator` exige que você também defina um
tipo `Item`, e esse tipo é usado no valor de retorno do método `next`. Em
outras palavras, `Item` será o tipo retornado pelo iterador.

A trait `Iterator` exige apenas que implementadores definam um método: `next`,
que retorna um item do iterador por vez, envolto em `Some`, e, quando a
iteração termina, retorna `None`.

Podemos chamar o método `next` diretamente em iteradores; a Listagem 13-12
demonstra quais valores são retornados por chamadas repetidas a `next` no
iterador criado a partir do vetor.

<Listing number="13-12" file-name="src/lib.rs" caption="Chamando o método `next` em um iterador">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-12/src/lib.rs:here}}
```

</Listing>

Observe que tivemos de tornar `v1_iter` mutável: chamar `next` em um iterador
altera o estado interno que ele usa para controlar onde está na sequência. Em
outras palavras, esse código _consome_, ou esgota, o iterador. Cada chamada a
`next` consome um item do iterador. Não precisamos tornar `v1_iter` mutável
quando usamos um laço `for`, porque o laço tomou ownership de `v1_iter` e o
tornou mutável nos bastidores.

Observe também que os valores obtidos das chamadas a `next` são referências
imutáveis aos valores do vetor. O método `iter` produz um iterador sobre
referências imutáveis. Se quisermos criar um iterador que tome ownership de
`v1` e retorne valores possuídos, podemos chamar `into_iter` em vez de `iter`.
Da mesma forma, se quisermos iterar sobre referências mutáveis, podemos chamar
`iter_mut` em vez de `iter`.

### Métodos que Consomem o Iterador

A trait `Iterator` possui vários métodos com implementações padrão fornecidas
pela biblioteca padrão; você pode conhecê-los consultando a documentação da API
de `Iterator`. Alguns desses métodos chamam `next` em sua definição, e é por
isso que você precisa implementar `next` ao implementar a trait `Iterator`.

Métodos que chamam `next` são chamados de _adaptadores consumidores_, porque
chamá-los esgota o iterador. Um exemplo é o método `sum`, que toma ownership
do iterador e percorre seus itens chamando `next` repetidamente, consumindo-o.
Durante a iteração, ele soma cada item a um total acumulado e retorna esse
total quando a iteração termina. A Listagem 13-13 tem um teste que ilustra o
uso de `sum`.

<Listing number="13-13" file-name="src/lib.rs" caption="Chamando o método `sum` para obter o total de todos os itens do iterador">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-13/src/lib.rs:here}}
```

</Listing>

Não temos permissão para usar `v1_iter` depois da chamada a `sum`, porque
`sum` toma ownership do iterador sobre o qual é chamado.

### Métodos que Produzem Outros Iteradores

_Adaptadores de iteradores_ são métodos definidos na trait `Iterator` que não
consomem o iterador. Em vez disso, produzem iteradores diferentes, alterando
algum aspecto do iterador original.

A Listagem 13-14 mostra um exemplo de chamada ao método adaptador `map`, que
recebe uma closure a ser aplicada a cada item à medida que eles são
percorridos. O método `map` retorna um novo iterador que produz os itens
modificados. A closure aqui cria um novo iterador em que cada item do vetor é
incrementado em 1.

<Listing number="13-14" file-name="src/main.rs" caption="Chamando o adaptador de iterador `map` para criar um novo iterador">

```rust,not_desired_behavior
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-14/src/main.rs:here}}
```

</Listing>

Entretanto, esse código gera um aviso:

```console
{{#include ../listings/ch13-functional-features/listing-13-14/output.txt}}
```

O código da Listagem 13-14 não faz nada; a closure que especificamos nunca é
chamada. O aviso nos lembra o motivo: adaptadores de iteradores são
preguiçosos, e aqui precisamos consumir o iterador.

Para corrigir esse aviso e consumir o iterador, usaremos o método `collect`,
que já usamos com `env::args` na Listagem 12-1. Esse método consome o iterador
e reúne os valores resultantes em um tipo de coleção.

Na Listagem 13-15, coletamos os resultados da iteração sobre o iterador
retornado pela chamada a `map` em um vetor. Esse vetor acabará contendo cada
item do vetor original, incrementado em 1.

<Listing number="13-15" file-name="src/main.rs" caption="Chamando `map` para criar um novo iterador e depois `collect` para consumi-lo e criar um vetor">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-15/src/main.rs:here}}
```

</Listing>

Como `map` recebe uma closure, podemos especificar qualquer operação que
quisermos realizar sobre cada item. Esse é um ótimo exemplo de como closures
permitem personalizar um comportamento ao mesmo tempo que reutilizam o
comportamento de iteração fornecido pela trait `Iterator`.

Você pode encadear várias chamadas a adaptadores de iteradores para executar
ações complexas de maneira legível. Mas, como todos os iteradores são
preguiçosos, é necessário chamar um dos métodos consumidores para obter
resultados das chamadas a esses adaptadores.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-closures-that-capture-their-environment"></a>

### Closures que Capturam o Ambiente

Muitos adaptadores de iteradores recebem closures como argumentos, e
frequentemente as closures que especificamos nesses casos são closures que
capturam o ambiente onde foram definidas.

Neste exemplo, usaremos o método `filter`, que recebe uma closure. A closure
recebe um item do iterador e retorna um `bool`. Se a closure retornar `true`,
o valor será incluído na iteração produzida por `filter`. Se retornar `false`,
o valor não será incluído.

Na Listagem 13-16, usamos `filter` com uma closure que captura a variável
`shoe_size` do ambiente para iterar sobre uma coleção de instâncias da struct
`Shoe`. Ela retornará apenas os sapatos que tiverem o tamanho especificado.

<Listing number="13-16" file-name="src/lib.rs" caption="Usando o método `filter` com uma closure que captura `shoe_size`">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-16/src/lib.rs}}
```

</Listing>

A função `shoes_in_size` toma ownership de um vetor de sapatos e de um tamanho
de sapato como parâmetros. Ela retorna um vetor contendo apenas os sapatos do
tamanho especificado.

No corpo de `shoes_in_size`, chamamos `into_iter` para criar um iterador que
toma ownership do vetor. Em seguida, chamamos `filter` para adaptar esse
iterador em um novo iterador que contém apenas os elementos para os quais a
closure retorna `true`.

A closure captura o parâmetro `shoe_size` do ambiente e compara esse valor com
o tamanho de cada sapato, mantendo apenas os sapatos do tamanho especificado.
Por fim, chamar `collect` reúne os valores retornados pelo iterador adaptado em
um vetor, que é retornado pela função.

O teste mostra que, quando chamamos `shoes_in_size`, recebemos de volta apenas
os sapatos que têm o mesmo tamanho do valor especificado.
