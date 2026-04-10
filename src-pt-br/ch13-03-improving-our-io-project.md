## Melhorando nosso projeto de E/S

Com este novo conhecimento sobre o iterators, podemos melhorar o projeto de I/O em
Capítulo 12 usando iterators para tornar os locais no código mais claros e mais
conciso. Vejamos como iterators pode melhorar nossa implementação do
Função `Config::build` e a função `search`.

### Removendo um `clone` usando um iterador

Na Listagem 12-6, adicionamos código que pegou um slice de valores `String` e criou
uma instância da estrutura `Config` indexando no slice e clonando o
valores, permitindo que a estrutura `Config` possua esses valores. Na Listagem 13-17,
reproduzimos a implementação da função `Config::build` como era
na Listagem 12-23.

<Listing number="13-17" file-name="src/main.rs" caption="Reprodução da função `Config::build` da Listagem 12-23">

```rust,ignore
{{#rustdoc_include ../listings/ch13-functional-features/listing-12-23-reproduced/src/main.rs:ch13}}
```

</Listing>

Na época, dissemos para não nos preocuparmos com as chamadas `clone` ineficientes porque
nós os removeríamos no future. Bem, essa hora é agora!

Precisávamos de `clone` aqui porque temos um slice com elementos `String` no
parâmetro `args`, mas a função ` build`não possui ` args`. Para voltar
ownership de uma instância ` Config`, tivemos que clonar os valores do ` query`
e ` file_path`de ` Config`para que a instância ` Config`possa possuir seu
valores.

Com nosso novo conhecimento sobre iterators, podemos alterar a função `build` para
considere ownership de um iterator como argumento em vez de borrowing e slice.
Usaremos a funcionalidade iterator em vez do código que verifica o comprimento
do slice e índices em locais específicos. Isso esclarecerá o que
A função `Config::build` está funcionando porque o iterator acessará os valores.

Uma vez que `Config::build` pega ownership do iterator e para de usar indexação
operações que emprestam, podemos mover os valores `String` do iterator para
`Config ` em vez de chamar`clone` e fazer uma nova alocação.

#### Usando o iterador retornado diretamente

Abra o arquivo _src/main.rs_ do seu projeto de E/S, que deve estar assim:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch13-functional-features/listing-12-24-reproduced/src/main.rs:ch13}}
```

Primeiro alteraremos o início da função `main` que tínhamos na Listagem
12-24 ao código da Listagem 13-18, que desta vez usa um iterator. Isto
não será compilado até que atualizemos o `Config::build` também.

<Listing number="13-18" file-name="src/main.rs" caption="Passando o valor de retorno de `env::args` para `Config::build`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-18/src/main.rs:here}}
```

</Listing>

A função `env::args` retorna um iterator! Em vez de coletar os
valores iterator em um vetor e depois passar um slice para `Config::build`, agora
estamos passando ownership do iterator retornado de ` env::args`para
` Config::build`diretamente.

A seguir, precisamos atualizar a definição de `Config::build`. Vamos mudar o
assinatura de ` Config::build`para se parecer com a Listagem 13-19. Isso ainda não vai
compilar, porque precisamos atualizar o corpo da função.

<Listing number="13-19" file-name="src/main.rs" caption="Atualizando a assinatura de `Config::build` para esperar um iterador">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-19/src/main.rs:here}}
```

</Listing>

A documentação da biblioteca padrão para a função `env::args` mostra que o
o tipo de iterator que ele retorna é `std::env::Args`, e esse tipo implementa
o ` Iterator`trait e retorna valores ` String`.

Atualizamos a assinatura da função `Config::build` para que o
o parâmetro `args` possui um tipo genérico com os limites trait `impl Iterator<Item =
String>` em vez de `&[String]`. Este uso da sintaxe ` impl Trait`nós
discutimos na seção [“Usando traits como parâmetros”][impl-trait]<!-- ignore -->
do Capítulo 10, e isso significa que `args` pode ser qualquer tipo que implemente a
`Iterator ` trait e retorna itens`String`.

Porque estamos pegando ownership de `args` e estaremos mutando `args` por
iterando sobre ele, podemos adicionar a palavra-chave `mut` na especificação do
Parâmetro `args` para torná-lo mutável.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-iterator-trait-methods-instead-of-indexing"></a>

#### Usando métodos de característica `Iterator`

A seguir, consertaremos o corpo de `Config::build`. Como ` args`implementa o
` Iterator `trait, sabemos que podemos chamar o método` next `nele! Listagem 13-20
atualiza o código da Listagem 12-23 para usar o método` next`.

<Listing number="13-20" file-name="src/main.rs" caption="Mudando o corpo de `Config::build` para usar métodos de iterador">

```rust,ignore,noplayground
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-20/src/main.rs:here}}
```

</Listing>

Lembre-se de que o primeiro valor no valor de retorno de `env::args` é o nome do
o programa. Queremos ignorar isso e chegar ao próximo valor, então primeiro chamamos
`next ` e não faça nada com o valor de retorno. Então, chamamos`next ` para obter o
valor que queremos colocar no campo`query ` de`Config `. Se` next `retornar
` Some `, usamos um` match `para extrair o valor. Se retornar` None `, significa
não foram fornecidos argumentos suficientes e retornamos antecipadamente com um valor` Err `. Nós fazemos
a mesma coisa para o valor` file_path`.

<!-- Old headings. Do not remove or links may break. -->

<a id="making-code-clearer-with-iterator-adapters"></a>

### Esclarecendo código com adaptadores iteradores

Também podemos tirar proveito dos iteradores na função `search` do nosso
projeto de E/S, reproduzida aqui na Listagem 13-21 como ela aparecia na
Listagem 12-19.

<Listing number="13-21" file-name="src/lib.rs" caption="A implementação da função `search` da Listagem 12-19">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-19/src/lib.rs:ch13}}
```

</Listing>

Podemos escrever esse código de forma mais concisa usando métodos do adaptador iterator.
Fazer isso também nos permite evitar um vetor `results` intermediário mutável. O
O estilo de programação funcional prefere minimizar a quantidade de estado mutável para
tornar o código mais claro. A remoção do estado mutável pode permitir um aprimoramento do future
para fazer a pesquisa acontecer em paralelo porque não teríamos que gerenciar
acesso simultâneo ao vetor `results`. A Listagem 13-22 mostra essa mudança.

<Listing number="13-22" file-name="src/lib.rs" caption="Usando métodos adaptadores de iterador na implementação da função `search`">

```rust,ignore
{{#rustdoc_include ../listings/ch13-functional-features/listing-13-22/src/lib.rs:here}}
```

</Listing>

Lembre-se de que o objetivo da função `search` é retornar todas as linhas
`contents ` que contém o`query `. Semelhante ao exemplo` filter `na Listagem
13-16, este código usa o adaptador` filter `para manter apenas as linhas para as quais
` line.contains(query) `retorna` true `. Em seguida, coletamos as linhas correspondentes em
outro vetor com` collect `. Muito mais simples! Sinta-se à vontade para fazer a mesma alteração
para usar métodos iterator na função` search_case_insensitive`também.

Para uma melhoria adicional, retorne um iterator da função `search` por
removendo a chamada para `collect` e alterando o tipo de retorno para `impl
Iterator<Item = &'a str>` para que a função se torne um adaptador iterator.
Observe que você também precisará atualizar os testes! Pesquise em um arquivo grande
usando sua ferramenta `minigrep` antes e depois de fazer esta alteração para observar o
diferença de comportamento. Antes desta alteração, o programa não imprimirá nenhum resultado
até coletar todos os resultados, mas após a alteração, os resultados
será impresso à medida que cada linha correspondente for encontrada porque o loop `for` no
A função `run` é capaz de aproveitar a preguiça do iterator.

<!-- Old headings. Do not remove or links may break. -->

<a id="choosing-between-loops-or-iterators"></a>

### Escolhendo entre Loops e Iteradores

A próxima questão lógica é qual estilo você deve escolher em seu próprio código e
porquê: a implementação original na Listagem 13-21 ou a versão usando
iterators na Listagem 13-22 (assumindo que estamos coletando todos os resultados antes
devolvê-los em vez de devolver o iterator). A maioria dos programadores Rust
prefira usar o estilo iterator. É um pouco mais difícil pegar o jeito
primeiro, mas depois de conhecer os vários adaptadores iterator e o que eles
fazer, iterators pode ser mais fácil de entender. Em vez de brincar com os vários
bits de loop e construção de novos vetores, o código se concentra no alto nível
objetivo do circuito. Isso abstrai parte do código comum para que
é mais fácil ver os conceitos exclusivos deste código, como o
condição de filtragem que cada elemento no iterator deve passar.

Mas serão as duas implementações verdadeiramente equivalentes? A suposição intuitiva
pode ser que o loop de nível inferior seja mais rápido. Vamos falar sobre desempenho.

[impl-trait]: ch10-02-traits.html#traits-as-parameters
