## Futures e a Sintaxe Async

Os elementos principais da programação assíncrona em Rust são _futures_ e as
palavras-chave `async` e `await`.

Um _future_ é um valor que pode não estar pronto agora, mas ficará pronto em
algum momento no futuro. (Esse mesmo conceito aparece em muitas linguagens, às
vezes com outros nomes, como _task_ ou _promise_.) Rust fornece a trait
`Future` como um bloco de construção para que diferentes operações async possam
ser implementadas com estruturas de dados diferentes, mas com uma interface
comum. Em Rust, futures são tipos que implementam a trait `Future`. Cada future
mantém suas próprias informações sobre o progresso já feito e sobre o que
significa estar “pronto”.

Você pode aplicar a palavra-chave `async` a blocos e funções para especificar
que eles podem ser interrompidos e retomados. Dentro de um bloco async ou de
uma função async, você pode usar a palavra-chave `await` para _aguardar um
future_ (isto é, esperar que ele fique pronto). Qualquer ponto em que você
aguarda um future dentro de um bloco ou função async é um local em potencial
para esse bloco ou função pausar e retomar. O processo de verificar um future
para ver se seu valor já está disponível é chamado de _polling_.

Algumas outras linguagens, como C# e JavaScript, também usam as palavras-chave
`async` e `await` para programação async. Se você conhece essas linguagens,
pode notar algumas diferenças significativas na forma como Rust lida com a
sintaxe. Isso acontece por bons motivos, como veremos!

Ao escrever Rust async, usamos as palavras-chave `async` e `await` na maior
parte do tempo. Rust as compila em código equivalente usando a trait `Future`,
da mesma forma que compila loops `for` em código equivalente usando a trait
`Iterator`. Como Rust fornece a trait `Future`, porém, você também pode
implementá-la para seus próprios tipos de dados quando precisar. Muitas das
funções que veremos ao longo deste capítulo retornam tipos com suas próprias
implementações de `Future`. Voltaremos à definição da trait no fim do capítulo
e nos aprofundaremos mais em como ela funciona, mas esses detalhes já são
suficientes para seguirmos em frente.

Tudo isso pode parecer um pouco abstrato, então vamos escrever nosso primeiro
programa async: um pequeno web scraper. Passaremos duas URLs pela linha de
comando, buscaremos ambas concorrentemente e retornaremos o resultado daquela
que terminar primeiro. Este exemplo terá bastante sintaxe nova, mas não se
preocupe: explicaremos tudo que você precisa saber conforme avançarmos.

## Nosso Primeiro Programa Async

Para manter o foco deste capítulo no aprendizado de async, em vez de lidar com
várias partes do ecossistema, criamos o crate `trpl` (`trpl` é abreviação de
“The Rust Programming Language”). Ele reexporta todos os tipos, traits e
funções de que você precisará, principalmente dos crates
[`futures`][futures-crate]<!-- ignore --> e [`tokio`][tokio]<!-- ignore -->. O
crate `futures` é um lar oficial para a experimentação de Rust com código
async, e foi ali que a trait `Future` foi originalmente projetada. Tokio é o
runtime async mais usado em Rust hoje, especialmente para aplicações web. Há
outros ótimos runtimes por aí, e eles podem ser mais adequados aos seus
objetivos. Usamos o crate `tokio` por baixo dos panos em `trpl` porque ele é
bem testado e amplamente usado.

Em alguns casos, `trpl` também renomeia ou envolve as APIs originais para
manter seu foco nos detalhes relevantes para este capítulo. Se você quiser
entender o que o crate faz, recomendamos conferir [seu código-fonte][crate-source].
Você poderá ver de qual crate vem cada reexportação, e deixamos comentários
extensos explicando o que o crate faz.

Crie um novo projeto binário chamado `hello-async` e adicione o crate `trpl`
como dependência:

```console
$ cargo new hello-async
$ cd hello-async
$ cargo add trpl
```

Agora podemos usar as várias partes fornecidas por `trpl` para escrever nosso
primeiro programa async. Construiremos uma pequena ferramenta de linha de
comando que busca duas páginas web, extrai o elemento `<title>` de cada uma e
imprime o título da página que terminar todo esse processo primeiro.

### Definindo a Função page_title

Vamos começar escrevendo uma função que recebe a URL de uma página como
parâmetro, faz uma requisição para ela e retorna o texto do elemento `<title>`
(veja a Listagem 17-1).

<Listing number="17-1" file-name="src/main.rs" caption="Definindo uma função async para obter o elemento title de uma página HTML">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-01/src/main.rs:all}}
```

</Listing>

Primeiro, definimos uma função chamada `page_title` e a marcamos com a
palavra-chave `async`. Em seguida, usamos a função `trpl::get` para buscar
qualquer URL que tenha sido passada e adicionamos a palavra-chave `await` para
aguardar a resposta. Para obter o texto da `response`, chamamos seu método
`text` e mais uma vez o aguardamos com a palavra-chave `await`. Ambas as etapas
são assíncronas. Para a função `get`, precisamos esperar o servidor enviar de
volta a primeira parte da resposta, que incluirá cabeçalhos HTTP, cookies e
assim por diante, e pode ser entregue separadamente do corpo da resposta.
Especialmente se o corpo for muito grande, pode levar algum tempo até que ele
chegue inteiro. Como precisamos esperar a resposta _inteira_ chegar, o método
`text` também é async.

Precisamos aguardar explicitamente ambos os futures, porque futures em Rust são
_lazy_: eles não fazem nada até você pedir com a palavra-chave `await`. (Na
verdade, Rust mostrará um aviso do compilador se você não usar um future.) Isso
pode lembrar a discussão sobre iteradores na seção [“Processando uma Série de
Itens com Iteradores”][iterators-lazy]<!-- ignore --> do Capítulo 13.
Iteradores não fazem nada a menos que você chame o método `next` deles, seja
diretamente ou usando loops `for` ou métodos como `map`, que usam `next` por
baixo dos panos. Da mesma forma, futures não fazem nada a menos que você peça
explicitamente. Essa preguiça permite que Rust evite executar código async até
que ele seja realmente necessário.

> Nota: Isso é diferente do comportamento que vimos ao usar `thread::spawn` na
> seção [“Criando uma Nova Thread com `spawn`”][thread-spawn]<!-- ignore --> do
> Capítulo 16, em que a closure que passamos para outra thread começou a rodar
> imediatamente. Também é diferente de como muitas outras linguagens abordam
> async. Mas é importante para que Rust consiga fornecer suas garantias de
> desempenho, assim como acontece com iteradores.

Depois que temos `response_text`, podemos analisá-lo em uma instância do tipo
`Html` usando `Html::parse`. Em vez de uma string bruta, agora temos um tipo de
dado que podemos usar para trabalhar com o HTML como uma estrutura de dados
mais rica. Em particular, podemos usar o método `select_first` para encontrar a
primeira instância de um determinado seletor CSS. Ao passar a string `"title"`,
obteremos o primeiro elemento `<title>` do documento, se houver um. Como pode
não haver nenhum elemento correspondente, `select_first` retorna um
`Option<ElementRef>`. Por fim, usamos o método `Option::map`, que nos permite
trabalhar com o item dentro do `Option` se ele estiver presente, e não fazer
nada se não estiver. (Também poderíamos usar uma expressão `match` aqui, mas
`map` é mais idiomático.) No corpo da função que fornecemos a `map`, chamamos
`inner_html` em `title` para obter seu conteúdo, que é uma `String`. Ao final
de tudo, temos um `Option<String>`.

Observe que a palavra-chave `await` de Rust vai _depois_ da expressão que você
está aguardando, não antes dela. Isto é, ela é uma palavra-chave _postfix_.
Isso pode ser diferente do que você está acostumado se já usou `async` em
outras linguagens, mas em Rust isso torna cadeias de métodos muito mais
agradáveis de usar. Como resultado, poderíamos alterar o corpo de `page_title`
para encadear as chamadas às funções `trpl::get` e `text` com `await` entre
elas, como mostrado na Listagem 17-2.

<Listing number="17-2" file-name="src/main.rs" caption="Encadeando com a palavra-chave `await`">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-02/src/main.rs:chaining}}
```

</Listing>

Com isso, escrevemos com sucesso nossa primeira função async! Antes de adicionar
algum código em `main` para chamá-la, vamos falar um pouco mais sobre o que
escrevemos e o que isso significa.

Quando Rust vê um _bloco_ marcado com a palavra-chave `async`, ele o compila em
um tipo de dado anônimo e único que implementa a trait `Future`. Quando Rust vê
uma _função_ marcada com `async`, ele a compila em uma função não async cujo
corpo é um bloco async. O tipo de retorno de uma função async é o tipo do dado
anônimo que o compilador cria para esse bloco async.

Assim, escrever `async fn` é equivalente a escrever uma função que retorna um
_future_ do tipo de retorno. Para o compilador, uma definição de função como
`async fn page_title` na Listagem 17-1 é aproximadamente equivalente a uma
função não async definida assim:

```rust
# extern crate trpl; // required for mdbook test
use std::future::Future;
use trpl::Html;

fn page_title(url: &str) -> impl Future<Output = Option<String>> {
    async move {
        let text = trpl::get(url).await.text().await;
        Html::parse(&text)
            .select_first("title")
            .map(|title| title.inner_html())
    }
}
```

Vamos percorrer cada parte da versão transformada:

- Ela usa a sintaxe `impl Trait` que discutimos no Capítulo 10, na seção
  [“Traits como Parâmetros”][impl-trait]<!-- ignore -->.
- O valor retornado implementa a trait `Future` com um tipo associado
  `Output`. Observe que o tipo `Output` é `Option<String>`, que é o mesmo que
  o tipo de retorno original da versão `async fn` de `page_title`.
- Todo o código chamado no corpo da função original é envolvido em um bloco
  `async move`. Lembre-se de que blocos são expressões. Esse bloco inteiro é a
  expressão retornada pela função.
- Esse bloco async produz um valor do tipo `Option<String>`, como acabamos de
  descrever. Esse valor corresponde ao tipo `Output` no tipo de retorno. Isso é
  igual a outros blocos que você já viu.
- O novo corpo da função é um bloco `async move` por causa da forma como ele
  usa o parâmetro `url`. (Falaremos muito mais sobre `async` versus
  `async move` mais adiante neste capítulo.)

Agora podemos chamar `page_title` em `main`.

<!-- Old headings. Do not remove or links may break. -->

<a id ="determining-a-single-pages-title"></a>

### Executando uma Função Async com um Runtime

Para começar, obteremos o título de uma única página, mostrado na Listagem
17-3. Infelizmente, este código ainda não compila.

<Listing number="17-3" file-name="src/main.rs" caption="Chamando a função `page_title` a partir de `main` com um argumento fornecido pelo usuário">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-03/src/main.rs:main}}
```

</Listing>

Seguimos o mesmo padrão que usamos para obter argumentos de linha de comando na
seção [“Aceitando Argumentos de Linha de Comando”][cli-args]<!-- ignore --> do
Capítulo 12. Então passamos o argumento da URL para `page_title` e aguardamos o
resultado. Como o valor produzido pelo future é um `Option<String>`, usamos uma
expressão `match` para imprimir mensagens diferentes levando em conta se a
página tinha um `<title>`.

O único lugar em que podemos usar a palavra-chave `await` é em funções ou
blocos async, e Rust não nos permite marcar a função especial `main` como
`async`.

<!-- manual-regeneration
cd listings/ch17-async-await/listing-17-03
cargo build
copy just the compiler error
-->

```text
error[E0752]: `main` function is not allowed to be `async`
 --> src/main.rs:6:1
  |
6 | async fn main() {
  | ^^^^^^^^^^^^^^^ `main` function is not allowed to be `async`
```

A razão pela qual `main` não pode ser marcada como `async` é que código async
precisa de um _runtime_: um crate Rust que gerencia os detalhes da execução de
código assíncrono. A função `main` de um programa pode _inicializar_ um
runtime, mas ela não é um runtime _em si_. (Veremos mais sobre por que esse é o
caso em breve.) Todo programa Rust que executa código async tem pelo menos um
lugar em que configura um runtime que executa os futures.

A maioria das linguagens que dão suporte a async inclui um runtime, mas Rust
não. Em vez disso, há muitos runtimes async diferentes disponíveis, cada um com
trade-offs diferentes, adequados ao caso de uso que ele busca atender. Por
exemplo, um servidor web de alta vazão com muitos núcleos de CPU e uma grande
quantidade de RAM tem necessidades muito diferentes das de um microcontrolador
com um único núcleo, pouca RAM e sem capacidade de alocação no heap. Os crates
que fornecem esses runtimes também costumam fornecer versões async de
funcionalidades comuns, como I/O de arquivos ou de rede.

Aqui, e ao longo do restante deste capítulo, usaremos a função `block_on` do
crate `trpl`, que recebe um future como argumento e bloqueia a thread atual até
que esse future execute até o fim. Por baixo dos panos, chamar `block_on`
configura um runtime usando o crate `tokio`, que é usado para executar o future
recebido (o comportamento de `block_on` do crate `trpl` é parecido com o das
funções `block_on` de outros crates de runtime). Quando o future termina,
`block_on` retorna qualquer valor produzido por ele.

Poderíamos passar o future retornado por `page_title` diretamente para
`block_on` e, quando ele terminasse, usar `match` no `Option<String>` resultante
como tentamos fazer na Listagem 17-3. No entanto, na maioria dos exemplos do
capítulo (e na maior parte do código async no mundo real), faremos mais do que
apenas uma chamada de função async. Por isso, em vez disso, passaremos um bloco
`async` e aguardaremos explicitamente o resultado da chamada a `page_title`,
como na Listagem 17-4.

<Listing number="17-4" caption="Aguardando um bloco async com `trpl::block_on`" file-name="src/main.rs">

<!-- should_panic,noplayground because mdbook test does not pass args -->

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch17-async-await/listing-17-04/src/main.rs:run}}
```

</Listing>

Quando executamos esse código, obtemos o comportamento que esperávamos
inicialmente:

<!-- manual-regeneration
cd listings/ch17-async-await/listing-17-04
cargo build # skip all the build noise
cargo run -- "https://www.rust-lang.org"
# copy the output here
-->

```console
$ cargo run -- "https://www.rust-lang.org"
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.05s
     Running `target/debug/async_await 'https://www.rust-lang.org'`
The title for https://www.rust-lang.org was
            Rust Programming Language
```

Ufa, finalmente temos algum código async funcionando! Mas, antes de adicionar o
código para colocar dois sites para competir um contra o outro, vamos voltar
brevemente nossa atenção para como futures funcionam.

Cada _ponto de await_, isto é, cada lugar em que o código usa a palavra-chave
`await`, representa um lugar em que o controle é devolvido ao runtime. Para que
isso funcione, Rust precisa acompanhar o estado envolvido no bloco async, de
modo que o runtime possa iniciar algum outro trabalho e depois voltar quando
estiver pronto para tentar avançar o primeiro novamente. Essa é uma máquina de
estados invisível, como se você tivesse escrito um enum como este para salvar o
estado atual em cada ponto de await:

```rust
{{#rustdoc_include ../listings/ch17-async-await/no-listing-state-machine/src/lib.rs:enum}}
```

Escrever manualmente o código para fazer a transição entre cada estado seria
tedioso e propenso a erros, especialmente quando você precisasse adicionar mais
funcionalidades e mais estados ao código depois. Felizmente, o compilador Rust
cria e gerencia automaticamente as estruturas de dados da máquina de estados
para código async. As regras normais de borrowing e ownership em torno de
estruturas de dados continuam se aplicando e, felizmente, o compilador também
cuida de verificá-las para nós e fornece mensagens de erro úteis. Vamos passar
por algumas delas mais adiante neste capítulo.

No fim das contas, algo precisa executar essa máquina de estados, e esse algo é
um runtime. (É por isso que você talvez encontre menções a _executors_ ao
estudar runtimes: um executor é a parte de um runtime responsável por executar
o código async.)

Agora você pode ver por que o compilador nos impediu de tornar a própria
função `main` async na Listagem 17-3. Se `main` fosse uma função async, alguma
outra coisa precisaria gerenciar a máquina de estados para qualquer future
retornado por `main`, mas `main` é o ponto de partida do programa! Em vez
disso, chamamos a função `trpl::block_on` em `main` para configurar um runtime
e executar o future retornado pelo bloco `async` até ele terminar.

> Nota: Alguns runtimes fornecem macros para que você _possa_ escrever uma
> função `main` async. Essas macros reescrevem `async fn main() { ... }` como
> uma `fn main` normal, que faz a mesma coisa que fizemos manualmente na
> Listagem 17-4: chamar uma função que executa um future até o fim, da forma
> como `trpl::block_on` faz.

Agora vamos juntar essas peças e ver como podemos escrever código concorrente.

<!-- Old headings. Do not remove or links may break. -->

<a id="racing-our-two-urls-against-each-other"></a>

### Colocando Duas URLs Para Competir Concorrentemente

Na Listagem 17-5, chamamos `page_title` com duas URLs diferentes passadas pela
linha de comando e as colocamos para competir selecionando o future que termina
primeiro.

<Listing number="17-5" caption="Chamando `page_title` para duas URLs para ver qual retorna primeiro" file-name="src/main.rs">

<!-- should_panic,noplayground because mdbook does not pass args -->

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch17-async-await/listing-17-05/src/main.rs:all}}
```

</Listing>

Começamos chamando `page_title` para cada uma das URLs fornecidas pelo usuário.
Salvamos os futures resultantes como `title_fut_1` e `title_fut_2`. Lembre-se:
eles ainda não fazem nada, porque futures são lazy e ainda não os aguardamos.
Então passamos os futures para `trpl::select`, que retorna um valor indicando
qual dos futures passados a ela termina primeiro.

> Nota: Por baixo dos panos, `trpl::select` é construída sobre uma função
> `select` mais geral definida no crate `futures`. A função `select` do crate
> `futures` consegue fazer muitas coisas que a função `trpl::select` não
> consegue, mas também tem alguma complexidade adicional que podemos deixar de
> lado por enquanto.

Qualquer future pode “vencer” legitimamente, então não faz sentido retornar um
`Result`. Em vez disso, `trpl::select` retorna um tipo que ainda não vimos,
`trpl::Either`. O tipo `Either` é um pouco parecido com um `Result`, no sentido
de que tem dois casos. Diferentemente de `Result`, porém, não há uma noção de
sucesso ou falha embutida em `Either`. Em vez disso, ele usa `Left` e `Right`
para indicar “um ou outro”:

```rust
enum Either<A, B> {
    Left(A),
    Right(B),
}
```

A função `select` retorna `Left` com a saída daquele future se o primeiro
argumento vencer, e `Right` com a saída do segundo argumento future se _aquele_
vencer. Isso corresponde à ordem em que os argumentos aparecem ao chamar a
função: o primeiro argumento fica à esquerda do segundo argumento.

Também atualizamos `page_title` para retornar a mesma URL que recebeu. Dessa
forma, se a página que retorna primeiro não tiver um `<title>` que possamos
resolver, ainda podemos imprimir uma mensagem significativa. Com essa
informação disponível, concluímos atualizando nossa saída de `println!` para
indicar qual URL terminou primeiro e qual é o `<title>`, se houver, da página
web naquela URL.

Agora você construiu um pequeno web scraper funcional! Escolha algumas URLs e
execute a ferramenta de linha de comando. Você pode descobrir que alguns sites
são consistentemente mais rápidos que outros, enquanto em outros casos o site
mais rápido varia de uma execução para outra. Mais importante: você aprendeu o
básico para trabalhar com futures, então agora podemos nos aprofundar no que
conseguimos fazer com async.

[impl-trait]: ch10-02-traits.html#traits-as-parameters
[iterators-lazy]: ch13-02-iterators.html
[thread-spawn]: ch16-01-threads.html#creating-a-new-thread-with-spawn
[cli-args]: ch12-01-accepting-command-line-arguments.html

<!-- TODO: map source link version to version of Rust? -->

[crate-source]: https://github.com/rust-lang/book/tree/main/packages/trpl
[futures-crate]: https://crates.io/crates/futures
[tokio]: https://tokio.rs
