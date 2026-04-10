## Processando uma série de itens com iteradores

O padrão iterator permite executar alguma tarefa em uma sequência de itens em
vire. Um iterator é responsável pela lógica de iteração sobre cada item e
determinar quando a sequência terminou. Ao usar iterators, você não
você mesmo terá que reimplementar essa lógica.

Em Rust, iterators são _preguiçosos_, o que significa que não têm efeito até que você ligue
métodos que consomem o iterator para utilizá-lo. Por exemplo, o código em
A Listagem 13-10 cria um iterator sobre os itens no vetor `v1` chamando
o método `iter` definido em `Vec<T>`. Este código por si só não faz nada
útil.

<Listing number="13-10" file-name="src/main.rs" caption="Criando um iterador">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-10/src/main.rs:here}}
```

</Listing>

O iterator é armazenado na variável `v1_iter`. Depois de criarmos um
iterator, podemos usá-lo de várias maneiras. Na Listagem 3-5, iteramos
uma matriz usando um loop ` for`para executar algum código em cada um de seus itens. Abaixo
o capô, isso criou implicitamente e depois consumiu um iterator, mas nós encobrimos
sobre como exatamente isso funciona até agora.

No exemplo da Listagem 13-11, separamos a criação do iterator de
o uso do iterator no loop `for`. Quando o loop ` for`é chamado usando
o iterator em ` v1_iter`, cada elemento no iterator é usado em um
iteração do loop, que imprime cada valor.

<Listing number="13-11" file-name="src/main.rs" caption="Usando um iterador em um loop `for`">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-11/src/main.rs:here}}
```

</Listing>

Em linguagens que não possuem iterators fornecido por suas bibliotecas padrão,
você provavelmente escreveria essa mesma funcionalidade iniciando uma variável no índice
0, usando essa variável para indexar no vetor para obter um valor, e
incrementando o valor da variável em um loop até atingir o número total de
itens no vetor.

Os iteradores cuidam de toda essa lógica para você, reduzindo o código repetitivo que você
poderia potencialmente bagunçar. Iteradores oferecem mais flexibilidade para usar o mesmo
lógica com muitos tipos diferentes de sequências, não apenas estruturas de dados que você pode
indexar em, como vetores. Vamos examinar como o iterators faz isso.

### A característica `Iterator` e o método `next`

Todos os iterators implementam um trait denominado `Iterator` que é definido no
biblioteca padrão. A definição do trait é assim:

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // methods with default implementations elided
}
```

Observe que esta definição usa uma nova sintaxe: `type Item` e `Self::Item`,
que estão definindo um tipo associado a este trait. Nós falaremos sobre
tipos associados em detalhes no Capítulo 20. Por enquanto, tudo que você precisa saber é que
este código diz que a implementação do ` Iterator`trait requer que você também defina
um tipo ` Item`, e este tipo ` Item`é usado no tipo de retorno do ` next`
método. Em outras palavras, o tipo ` Item`será o tipo retornado do
iterator.

O `Iterator` trait requer apenas que os implementadores definam um método: o
Método `next`, que retorna um item do iterator por vez, agrupado em
` Some `e, quando a iteração terminar, retorna` None`.

Podemos chamar o método `next` diretamente em iterators; A Listagem 13-12 demonstra
quais valores são retornados de chamadas repetidas para `next` no iterator criado
do vetor.

<Listing number="13-12" file-name="src/lib.rs" caption="Chamando o método `next` em um iterador">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-12/src/lib.rs:here}}
```

</Listing>

Observe que precisávamos tornar `v1_iter` mutável: Chamando o método `next` em um
iterator altera o estado interno que o iterator usa para controlar onde
está na sequência. Em outras palavras, este código _consome_, ou esgota, o
iterator. Cada chamada para `next` consome um item do iterator. Nós não precisávamos
para tornar `v1_iter` mutável quando usamos um loop `for`, porque o loop demorou
ownership de ` v1_iter`e tornou-o mutável nos bastidores.

Observe também que os valores que obtemos das chamadas para `next` são imutáveis
referências aos valores no vetor. O método `iter` produz um iterator
sobre referências imutáveis. Se quisermos criar um iterator que leve
ownership de `v1` e retorna valores próprios, podemos chamar `into_iter` em vez de
`iter `. Da mesma forma, se quisermos iterar sobre referências mutáveis, podemos chamar
` iter_mut `em vez de` iter`.

### Métodos que consomem o iterador

O `Iterator` trait possui vários métodos diferentes com padrão
implementações fornecidas pela biblioteca padrão; você pode descobrir mais sobre isso
métodos consultando a documentação da API da biblioteca padrão para o `Iterator`
trait. Alguns desses métodos chamam o método ` next`em sua definição, que
é por isso que você é obrigado a implementar o método ` next`ao implementar o
` Iterator`trait.

Os métodos que chamam `next` são chamados de _adaptadores de consumo_ porque chamá-los
usa o iterator. Um exemplo é o método `sum`, que leva ownership de
o iterator e itera pelos itens chamando repetidamente ` next`, assim
consumindo o iterator. À medida que itera, ele adiciona cada item a uma execução
total e retorna o total quando a iteração for concluída. A Listagem 13-13 tem um
teste ilustrando o uso do método ` sum`.

<Listing number="13-13" file-name="src/lib.rs" caption="Chamando o método `sum` para obter o total de todos os itens do iterador">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-13/src/lib.rs:here}}
```

</Listing>

Não temos permissão para usar `v1_iter` após a chamada para `sum`, porque ` sum`leva
ownership do iterator que chamamos.

### Métodos que produzem outros iteradores

_Adaptadores iteradores_ são métodos definidos no `Iterator` trait que não
consumir o iterator. Em vez disso, eles produzem iterators diferentes alterando
algum aspecto do iterator original.

A Listagem 13-14 mostra um exemplo de chamada do método do adaptador iterator `map`,
que leva um closure para chamar cada item à medida que os itens são iterados.
O método ` map`retorna um novo iterator que produz os itens modificados. O
closure aqui cria um novo iterator no qual cada item do vetor será
incrementado em 1.

<Listing number="13-14" file-name="src/main.rs" caption="Chamando o adaptador de iterador `map` para criar um novo iterador">

```rust,not_desired_behavior
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-14/src/main.rs:here}}
```

</Listing>

No entanto, este código produz um aviso:

```console
{{#include ../listings/ch13-functional-features/listing-13-14/output.txt}}
```

O código na Listagem 13-14 não faz nada; o closure que especificamos
nunca é chamado. O aviso nos lembra o porquê: os adaptadores iteradores são preguiçosos e
precisamos consumir o iterator aqui.

Para corrigir este aviso e consumir o iterator, usaremos o método `collect`,
que usamos com ` env::args`na Listagem 12-1. Este método consome o
iterator e coleta os valores resultantes em um tipo de dados de coleção.

Na Listagem 13-15, coletamos os resultados da iteração sobre o iterator que é
retornado da chamada para `map` em um vetor. Este vetor acabará
contendo cada item do vetor original, incrementado em 1.

<Listing number="13-15" file-name="src/main.rs" caption="Chamando o método `map` para criar um novo iterador e depois `collect` para consumi-lo e criar um vetor">

```rust
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-15/src/main.rs:here}}
```

</Listing>

Como `map` usa um closure, podemos especificar qualquer operação que desejamos realizar
em cada item. Este é um ótimo exemplo de como o closures permite personalizar alguns
comportamento ao reutilizar o comportamento de iteração que o `Iterator` trait
fornece.

Você pode encadear várias chamadas para adaptadores iterator para executar ações complexas em
uma maneira legível. Mas como todos os iterators são preguiçosos, você precisa ligar para um dos
consumindo métodos de adaptador para obter resultados de chamadas para adaptadores iterator.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-closures-that-capture-their-environment"></a>

### Fechamentos que capturam seu ambiente

Muitos adaptadores iterator usam closures como argumentos, e geralmente o closures
especificaremos como argumentos para os adaptadores iterator que serão closures que capturam
seu ambiente.

Para este exemplo, usaremos o método `filter` que utiliza closure. O
closure obtém um item do iterator e retorna um `bool`. Se o closure
retorna ` true`, o valor será incluído na iteração produzida por
` filter `. Se closure retornar` false`, o valor não será incluído.

Na Listagem 13-16, usamos `filter` com um closure que captura o `shoe_size`
variável de seu ambiente para iterar sobre uma coleção de estruturas ` Shoe`
instâncias. Ele retornará apenas sapatos do tamanho especificado.

<Listing number="13-16" file-name="src/lib.rs" caption="Usando o método `filter` com uma closure que captura `shoe_size`">

```rust,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-16/src/lib.rs}}
```

</Listing>

A função `shoes_in_size` pega ownership de um vetor de sapatos e um sapato
tamanho como parâmetros. Ele retorna um vetor contendo apenas sapatos do especificado
tamanho.

No corpo de `shoes_in_size`, chamamos ` into_iter`para criar um iterator que
pega ownership do vetor. Então, chamamos ` filter`para adaptar esse iterator
em um novo iterator que contém apenas elementos para os quais o closure retorna
` true`.

O closure captura o parâmetro `shoe_size` do ambiente e
compara o valor com o tamanho de cada sapato, mantendo apenas os sapatos do tamanho
especificado. Finalmente, chamar `collect` reúne os valores retornados pelo
adaptou iterator em um vetor retornado pela função.

O teste mostra que quando chamamos `shoes_in_size`, recebemos de volta apenas os sapatos que
tem o mesmo tamanho que o valor que especificamos.
