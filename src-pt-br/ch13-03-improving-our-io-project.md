## Melhorando Nosso Projeto de E/S

Com esse novo conhecimento sobre iteradores, podemos melhorar o projeto de E/S
do Capítulo 12 usando iteradores para tornar partes do código mais claras e
mais concisas. Vamos ver como iteradores podem melhorar nossa implementação de
`Config::build` e da função `search`.

### Removendo um `clone` com um Iterador

Na Listagem 12-6, adicionamos código que recebia uma fatia de valores `String`
e criava uma instância da struct `Config` indexando essa fatia e clonando os
valores, para permitir que `Config` passasse a ser dona desses dados. Na
Listagem 13-17, reproduzimos a implementação da função `Config::build` como
ela estava na Listagem 12-23.

<Listing number="13-17" file-name="src/main.rs" caption="Reprodução da função `Config::build` da Listagem 12-23">

```rust,ignore
{{#rustdoc_include ../listings/ch13-functional-features/listing-12-23-reproduced/src/main.rs:ch13}}
```

</Listing>

Na época, dissemos para não se preocupar com as chamadas ineficientes a
`clone`, porque as removeríamos no futuro. Pois bem, esse momento chegou!

Precisávamos de `clone` porque temos uma fatia com elementos `String` no
parâmetro `args`, mas a função `build` não tem ownership de `args`. Para
retornar ownership de uma instância de `Config`, tivemos de clonar os valores
dos campos `query` e `file_path`, para que a própria instância de `Config`
passasse a possuí-los.

Com nosso novo conhecimento sobre iteradores, podemos alterar `build` para
receber ownership de um iterador como argumento, em vez de emprestar uma fatia.
Vamos usar a funcionalidade dos iteradores no lugar do código que verifica o
comprimento da fatia e indexa posições específicas. Isso deixará mais claro o
que `Config::build` está fazendo, porque será o iterador que acessará os
valores.

Quando `Config::build` passar a tomar ownership do iterador e deixar de usar
operações de indexação que fazem empréstimos, poderemos mover os valores
`String` do iterador para `Config`, em vez de chamar `clone` e fazer uma nova
alocação.

#### Usando Diretamente o Iterador Retornado

Abra o arquivo _src/main.rs_ do seu projeto de E/S, que deve se parecer com
isto:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch13-functional-features/listing-12-24-reproduced/src/main.rs:ch13}}
```

Primeiro, vamos alterar o início da função `main`, que estava na Listagem
12-24, para o código da Listagem 13-18, que desta vez usa um iterador. Isso
ainda não compilará até que atualizemos também `Config::build`.

<Listing number="13-18" file-name="src/main.rs" caption="Passando o valor de retorno de `env::args` para `Config::build`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-18/src/main.rs:here}}
```

</Listing>

A função `env::args` retorna um iterador! Em vez de coletar os valores do
iterador em um vetor e depois passar uma fatia para `Config::build`, agora
estamos passando diretamente para `Config::build` o ownership do iterador
retornado por `env::args`.

Em seguida, precisamos atualizar a definição de `Config::build`. Vamos alterar
a assinatura de `Config::build` para que se pareça com a Listagem 13-19. Isso
ainda não compilará, porque também precisamos atualizar o corpo da função.

<Listing number="13-19" file-name="src/main.rs" caption="Atualizando a assinatura de `Config::build` para esperar um iterador">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-19/src/main.rs:here}}
```

</Listing>

A documentação da biblioteca padrão para `env::args` mostra que o tipo do
iterador que ela retorna é `std::env::Args`, e esse tipo implementa a trait
`Iterator`, retornando valores `String`.

Atualizamos a assinatura de `Config::build` para que o parâmetro `args` tenha
um tipo genérico com os limites de trait `impl Iterator<Item = String>`, em vez
de `&[String]`. Esse uso da sintaxe `impl Trait`, discutido na seção [“Usando
Traits como Parâmetros”][impl-trait]<!-- ignore --> do Capítulo 10, significa
que `args` pode ser qualquer tipo que implemente a trait `Iterator` e retorne
itens do tipo `String`.

Como estamos tomando ownership de `args` e vamos modificá-lo ao iterar sobre
ele, podemos adicionar a palavra-chave `mut` à especificação do parâmetro
`args` para torná-lo mutável.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-iterator-trait-methods-instead-of-indexing"></a>

#### Usando Métodos da Trait `Iterator`

Agora vamos corrigir o corpo de `Config::build`. Como `args` implementa a trait
`Iterator`, sabemos que podemos chamar `next` nele! A Listagem 13-20 atualiza o
código da Listagem 12-23 para usar o método `next`.

<Listing number="13-20" file-name="src/main.rs" caption="Mudando o corpo de `Config::build` para usar métodos de iterador">

```rust,ignore,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-20/src/main.rs:here}}
```

</Listing>

Lembre-se de que o primeiro valor retornado por `env::args` é o nome do
programa. Queremos ignorá-lo e chegar ao próximo valor, então primeiro chamamos
`next` e não fazemos nada com o valor retornado. Em seguida, chamamos `next`
para obter o valor que queremos colocar no campo `query` de `Config`. Se
`next` retornar `Some`, usamos um `match` para extrair o valor. Se retornar
`None`, isso significa que não foram fornecidos argumentos suficientes, e
retornamos imediatamente com um valor `Err`. Fazemos a mesma coisa para o
valor `file_path`.

<!-- Old headings. Do not remove or links may break. -->

<a id="making-code-clearer-with-iterator-adapters"></a>

### Tornando o Código Mais Claro com Adaptadores de Iteradores

Também podemos tirar proveito de iteradores na função `search` do nosso
projeto de E/S, reproduzida aqui na Listagem 13-21 como ela aparecia na
Listagem 12-19.

<Listing number="13-21" file-name="src/lib.rs" caption="A implementação da função `search` da Listagem 12-19">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-19/src/lib.rs:ch13}}
```

</Listing>

Podemos escrever esse código de forma mais concisa usando métodos adaptadores
de iteradores. Isso também nos permite evitar um vetor intermediário mutável,
`results`. O estilo de programação funcional prefere minimizar a quantidade de
estado mutável para tornar o código mais claro. Remover esse estado mutável
pode até permitir uma melhoria futura que torne a busca paralela, porque não
teríamos de gerenciar acesso concorrente ao vetor `results`. A Listagem 13-22
mostra essa mudança.

<Listing number="13-22" file-name="src/lib.rs" caption="Usando métodos adaptadores de iteradores na implementação da função `search`">

```rust,ignore
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-22/src/lib.rs:here}}
```

</Listing>

Lembre-se de que o objetivo da função `search` é retornar todas as linhas de
`contents` que contêm `query`. De forma semelhante ao exemplo de `filter` na
Listagem 13-16, esse código usa o adaptador `filter` para manter apenas as
linhas para as quais `line.contains(query)` retorna `true`. Em seguida,
coletamos as linhas correspondentes em outro vetor com `collect`. Muito mais
simples! Sinta-se à vontade para fazer a mesma mudança na função
`search_case_insensitive`.

Para uma melhoria adicional, você pode fazer a função `search` retornar um
iterador removendo a chamada a `collect` e mudando o tipo de retorno para
`impl Iterator<Item = &'a str>`, de modo que a própria função se torne um
adaptador de iterador. Observe que você também precisará atualizar os testes!
Pesquise em um arquivo grande usando sua ferramenta `minigrep` antes e depois
de fazer essa alteração para observar a diferença de comportamento. Antes
dessa mudança, o programa não imprimirá nenhum resultado até ter coletado
todos eles; depois, os resultados serão impressos à medida que cada linha
correspondente for encontrada, porque o laço `for` na função `run` poderá
tirar proveito da natureza preguiçosa do iterador.

<!-- Old headings. Do not remove or links may break. -->

<a id="choosing-between-loops-or-iterators"></a>

### Escolhendo entre Laços e Iteradores

A próxima pergunta lógica é qual estilo você deve escolher no seu próprio
código e por quê: a implementação original da Listagem 13-21 ou a versão com
iteradores da Listagem 13-22, assumindo que estamos coletando todos os
resultados antes de devolvê-los, em vez de retornar o iterador. A maioria das
pessoas que programam em Rust prefere o estilo com iteradores. Pode ser um
pouco mais difícil de pegar o jeito no começo, mas, depois que você se
familiariza com os vários adaptadores e com o que eles fazem, os iteradores
podem ser mais fáceis de entender. Em vez de lidar com todos os detalhes de
controle do laço e da construção de novos vetores, o código se concentra no
objetivo de alto nível da operação. Isso abstrai parte do código rotineiro e
facilita enxergar os conceitos realmente únicos daquele trecho, como a condição
de filtragem que cada elemento precisa satisfazer.

Mas será que as duas implementações são realmente equivalentes? A intuição pode
levar você a supor que o laço de nível mais baixo será mais rápido. Vamos falar
sobre desempenho.

[impl-trait]: ch10-02-traits.html#traits-as-parameters
