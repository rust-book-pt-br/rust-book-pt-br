## Futures e a sintaxe assíncrona

Os elementos-chave da programação assíncrona em Rust são _futuros_ e Rust
Palavras-chave `async` e `await`.

Um _futuro_ é um valor que pode não estar pronto agora, mas estará pronto em algum momento.
ponto no future. (Este mesmo conceito aparece em muitas línguas, às vezes
sob outros nomes, como _task_ ou _promise_.) Rust fornece um `Future` trait
como um bloco de construção para que diferentes operações async possam ser implementadas com
estruturas de dados diferentes, mas com uma interface comum. Em Rust, futures são
tipos que implementam o `Future` trait. Cada future contém suas próprias informações
sobre o progresso que foi feito e o que significa “pronto”.

Você pode aplicar a palavra-chave `async` a blocos e funções para especificar que eles
pode ser interrompido e retomado. Dentro de um bloco async ou função async, você
pode usar a palavra-chave `await` para _aguardar um futuro_ (ou seja, esperar que ele se torne
pronto). Qualquer ponto onde você await um future dentro de um bloco ou função async é
um local potencial para esse bloco ou função pausar e retomar. O processo de
verificar com um future para ver se seu valor ainda está disponível é chamado de _polling_.

Algumas outras linguagens, como C# e JavaScript, também usam `async` e `await`
palavras-chave para programação async. Se você estiver familiarizado com esses idiomas, você
pode notar algumas diferenças significativas em como Rust lida com a sintaxe. Isso é
por um bom motivo, como veremos!

Ao escrever async Rust, usamos as palavras-chave `async` e `await` na maioria dos
tempo. Rust os compila em código equivalente usando o `Future` trait, tanto quanto
ele compila loops `for` em código equivalente usando `Iterator` trait.
Como o Rust fornece o `Future` trait, você também pode implementá-lo para
seus próprios tipos de dados quando necessário. Muitas das funções que veremos
ao longo deste capítulo retornam tipos com suas próprias implementações de
`Future`. Voltaremos à definição do trait no final do capítulo
e nos aprofundarmos mais em como funciona, mas isso é detalhe suficiente para nos manter em movimento
para frente.

Tudo isso pode parecer um pouco abstrato, então vamos escrever nosso primeiro programa async: um
pequeno raspador de teia. Passaremos dois URLs da linha de comando, buscaremos ambos
simultaneamente e retornar o resultado de qualquer um que termine primeiro. Isto
exemplo terá uma boa sintaxe nova, mas não se preocupe - explicaremos
tudo o que você precisa saber enquanto avançamos.

## Nosso primeiro programa assíncrono

Para manter o foco deste capítulo no aprendizado do async, em vez de fazer malabarismos com as peças
do ecossistema, criamos o `trpl` crate (`trpl ` é a abreviação de “The Rust
Linguagem de Programação”). Ele reexporta todos os tipos, traits e funções
você precisará, principalmente do [`futures `][futures-crate]<!-- ignore --> e
[` tokio `][tokio]<!-- ignore --> crates. O` futures `crate é uma casa oficial
para experimentação Rust para código async, e é realmente onde o` Future `
trait foi originalmente projetado. Tokio é o runtime async mais usado em
Rust hoje, especialmente para aplicações web. Existem outros ótimos tempos de execução
lá, e eles podem ser mais adequados para seus propósitos. Usamos o` tokio `
crate está oculto para` trpl`porque é bem testado e amplamente utilizado.

Em alguns casos, `trpl` também renomeia ou agrupa as APIs originais para mantê-lo
focado nos detalhes relevantes para este capítulo. Se você quiser entender o que
o crate faz, recomendamos que você verifique [seu código-fonte] [crate-source].
Você poderá ver de onde vem crate cada reexportação, e deixamos
extensos comentários explicando o que o crate faz.

Crie um novo projeto binário chamado `hello-async` e adicione `trpl` crate como
dependência:

```console
$ cargo new hello-async
$ cd hello-async
$ cargo add trpl
```

Agora podemos usar as diversas peças fornecidas pelo `trpl` para escrever nosso primeiro async
programa. Construiremos uma pequena ferramenta de linha de comando que busca duas páginas da web,
extrai o elemento `<title>` de cada um e imprime o título de qualquer
page termina todo o processo primeiro.

### Definindo a função page_title

Vamos começar escrevendo uma função que usa o URL de uma página como parâmetro, faz
uma solicitação para ele e retorna o texto do elemento `<title>` (consulte a Listagem
17-1).

<Listing number="17-1" file-name="src/main.rs" caption="Definindo uma função async para obter o elemento de título de uma página HTML">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-01/src/main.rs:all}}
```

</Listing>

Primeiro, definimos uma função chamada `page_title` e a marcamos com `async`
palavra-chave. Em seguida, usamos a função ` trpl::get`para buscar qualquer URL passada
e adicione a palavra-chave ` await`a await a resposta. Para obter o texto do
` response `, chamamos seu método` text `e mais uma vez await com o` await `
palavra-chave. Ambas as etapas são assíncronas. Para a função` get `, temos
esperar que o servidor envie de volta a primeira parte de sua resposta, que será
incluem cabeçalhos HTTP, cookies e assim por diante e podem ser entregues separadamente de
o corpo de resposta. Principalmente se o corpo for muito grande, pode demorar algum tempo
para que tudo chegue. Porque temos que esperar _todo_ o
resposta chegar, o método` text`também será async.

Temos que explicitamente await ambos futures, porque futures em Rust são
_preguiçoso_: eles não fazem nada até que você peça com a palavra-chave `await`.
(Na verdade, Rust mostrará um aviso do compilador se você não usar um future.) Isto
pode lembrá-lo da discussão sobre iterators no [“Processando uma série de
Itens com Iteradores”][iterators-lazy]Seção <!-- ignore --> no Capítulo 13.
Os iteradores não fazem nada a menos que você chame seu método ` next`— seja diretamente ou por
usando loops ` for`ou métodos como ` map`que usam ` next`nos bastidores.
Da mesma forma, futures não faz nada a menos que você solicite explicitamente. Essa preguiça
permite que Rust evite a execução do código async até que seja realmente necessário.

> Nota: Isso é diferente do comportamento que vimos ao usar `thread::spawn`
> na seção [“Criando uma nova thread com `spawn`”][thread-spawn]<!-- ignore -->
> do Capítulo 16, onde a closure que passamos para outra thread começou a
> funcionando imediatamente. Também é diferente de quantas outras línguas
> abordagem async. Mas é importante que o Rust seja capaz de fornecer seu
> garantias de desempenho, assim como acontece com iterators.

Assim que tivermos `response_text`, podemos analisá-lo em uma instância do ` Html`
digite usando ` Html::parse`. Em vez de uma string bruta, agora temos um tipo de dados que
pode usar para trabalhar com o HTML como uma estrutura de dados mais rica. Em particular, podemos
use o método ` select_first`para encontrar a primeira instância de um determinado CSS
seletor. Passando a string ` "title"`, obteremos o primeiro ` <title>`
elemento no documento, se houver. Porque pode não haver nenhuma correspondência
elemento, ` select_first`retorna um ` Option<ElementRef>`. Por fim, usamos o
Método ` Option::map`, que nos permite trabalhar com o item no ` Option`se for
presente e não faça nada se não estiver. (Também poderíamos usar uma expressão ` match`
aqui, mas ` map`é mais idiomático.) No corpo da função que fornecemos para
` map `, chamamos` inner_html `no` title `para obter seu conteúdo, que é um
` String `. No final das contas, temos um` Option<String>`.

Observe que a palavra-chave `await` de Rust vai _depois_ da expressão que você está aguardando,
não antes disso. Ou seja, é uma palavra-chave _postfix_. Isto pode diferir do que
você está acostumado se já usou `async` em outros idiomas, mas em Rust faz
cadeias de métodos muito mais agradáveis de trabalhar. Como resultado, poderíamos mudar o
corpo de `page_title` para encadear as chamadas de função `trpl::get` e `text`
juntamente com ` await`entre eles, conforme mostrado na Listagem 17-2.

<Listing number="17-2" file-name="src/main.rs" caption="Encadeando com a palavra-chave `await`">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-02/src/main.rs:chaining}}
```

</Listing>

Com isso, escrevemos com sucesso nossa primeira função async! Antes de adicionarmos
algum código em `main` para chamá-lo, vamos falar um pouco mais sobre o que temos
escrito e o que significa.

Quando Rust vê um _bloco_ marcado com a palavra-chave `async`, ele o compila em um
tipo de dados exclusivo e anônimo que implementa o ` Future`trait. Quando Rust vê
uma _função_ marcada com ` async`, ela a compila em uma função não async
cujo corpo é um bloco async. O tipo de retorno de uma função async é o tipo de
o tipo de dados anônimo que o compilador cria para esse bloco async.

Assim, escrever `async fn` é equivalente a escrever uma função que retorna um
_futuro_ do tipo de retorno. Para o compilador, uma definição de função como a
`async fn page_title` na Listagem 17-1 é aproximadamente equivalente a um não-async
função definida assim:

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

- Ele usa a sintaxe `impl Trait` que discutimos no Capítulo 10 no
  [“Traços como parâmetros”][impl-trait]Seção <!-- ignore -->.
- O valor retornado implementa o `Future` trait com um tipo associado de
 `Output `. Observe que o tipo` Output `é` Option<String> `, que é o
  igual ao tipo de retorno original da versão` async fn `de` page_title `.
- Todo o código chamado no corpo da função original é encapsulado em
  um bloco` async move `. Lembre-se de que os blocos são expressões. Todo este bloco
  é a expressão retornada da função.
- Este bloco async produz um valor do tipo` Option<String> `, assim como
  descrito. Esse valor corresponde ao tipo` Output `no tipo de retorno. Isto é
  assim como outros blocos que você viu.
- O novo corpo da função é um bloco` async move `devido à forma como ele usa o
  Parâmetro` url `. (Falaremos muito mais sobre` async `versus` async move`
  mais adiante no capítulo.)

Now we can call `page_title` in `main`.

<!-- Old headings. Do not remove or links may break. -->

<a id ="determining-a-single-pages-title"></a>

### Executando uma função assíncrona com um tempo de execução

Para começar, obteremos o título de uma única página, mostrada na Listagem 17-3.
Infelizmente, este código ainda não é compilado.

<Listing number="17-3" file-name="src/main.rs" caption="Chamando a função `page_title` a partir de `main` com um argumento fornecido pelo usuário">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-03/src/main.rs:main}}
```

</Listing>

Seguimos o mesmo padrão que usamos para obter argumentos de linha de comando no
[“Aceitando argumentos de linha de comando”][cli-args]Seção <!-- ignore --> em
Capítulo 12. Em seguida, passamos o argumento URL para `page_title` e await o resultado.
Como o valor produzido pelo future é um `Option<String>`, usamos um
Expressão ` match`para imprimir mensagens diferentes para considerar se a página
tinha um ` <title>`.

O único lugar onde podemos usar a palavra-chave `await` é nas funções ou blocos async,
e Rust não nos permite marcar a função especial `main` como `async`.

<!-- manual-regeneration
listagens de cd/ch17-async-await/listing-17-03
Construção cargo
copie apenas o erro do compilador
-->

```text
error[E0752]: `main` function is not allowed to be `async`
 --> src/main.rs:6:1
  |
6 | async fn main() {
  | ^^^^^^^^^^^^^^^ `main` function is not allowed to be `async`
```

A razão pela qual `main` não pode ser marcado como `async` é que o código async precisa de um _runtime_:
um Rust crate que gerencia os detalhes da execução do código assíncrono. Um
a função `main` do programa pode _inicializar_ um tempo de execução, mas não é um tempo de execução
_ele mesmo_. (Veremos mais sobre por que esse é o caso daqui a pouco.) Cada Rust
programa que executa o código async tem pelo menos um local onde configura um
tempo de execução que executa o futures.

A maioria das linguagens que suportam async agrupa um tempo de execução, mas Rust não. Em vez disso,
existem muitos tempos de execução async diferentes disponíveis, cada um dos quais faz diferentes
compensações adequadas ao caso de uso que ele visa. Por exemplo, um sistema de alto rendimento
web server com muitos núcleos de CPU e uma grande quantidade de RAM tem características muito diferentes
necessidades do que um microcontrolador com um único núcleo, uma pequena quantidade de RAM e nenhum
capacidade de alocação de heap. O crates que fornece esses tempos de execução também costuma
fornece versões async de funcionalidades comuns, como E/S de arquivo ou rede.

Aqui, e ao longo do restante deste capítulo, usaremos o `block_on`
função do ` trpl`crate, que usa um future como argumento e bloqueia
o thread atual até que este future seja concluído. Nos bastidores,
chamar ` block_on`configura um tempo de execução usando o ` tokio`crate que é usado para executar
o future passado (o comportamento ` block_on`do ` trpl`crate é semelhante ao
outras funções crates’ ` block_on`de tempo de execução). Assim que o future for concluído,
` block_on`retorna qualquer valor produzido pelo future.

Poderíamos passar o future retornado por `page_title` diretamente para `block_on` e,
uma vez concluído, poderíamos match no `Option<String>` resultante enquanto tentamos
o que fazer na Listagem 17-3. No entanto, para a maioria dos exemplos do capítulo (e
a maioria dos códigos async no mundo real), faremos mais do que apenas um async
chamada de função, então, em vez disso, passaremos um bloco `async` e explicitamente await o
resultado da chamada `page_title`, como na Listagem 17-4.

<Listing number="17-4" caption="Aguardando um bloco async com `trpl::block_on`" file-name="src/main.rs">

<!-- should_panic,noplayground because mdbook test does not pass args -->

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch17-async-await/listing-17-04/src/main.rs:run}}
```

</Listing>

Quando executamos este código, obtemos o comportamento que esperávamos inicialmente:

<!-- manual-regeneration
listagens de cd/ch17-async-await/listing-17-04
Compilação cargo # pula todo o ruído de construção
cargo executado - "https://www.rust-lang.org"
#copie a saída aqui
-->

```console
$ cargo run -- "https://www.rust-lang.org"
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.05s
     Running `target/debug/async_await 'https://www.rust-lang.org'`
The title for https://www.rust-lang.org was
            Rust Programming Language
```

Ufa – finalmente temos algum código async funcional! Mas antes de adicionarmos o código a
competir entre dois sites, vamos voltar brevemente nossa atenção para como
futures funciona.

Cada _ponto de espera_ – ou seja, todo lugar onde o código usa o `await`
palavra-chave – representa um local onde o controle é devolvido ao tempo de execução. Para fazer
funcionar, Rust precisa acompanhar o estado envolvido no bloco async para
que o tempo de execução pode iniciar algum outro trabalho e depois voltar quando for
pronto para tentar avançar o primeiro novamente. Esta é uma máquina de estado invisível,
como se você tivesse escrito uma enumeração como esta para salvar o estado atual em cada await
ponto:

```rust
{{#rustdoc_include ../listings/ch17-async-await/no-listing-state-machine/src/lib.rs:enum}}
```

Escrever o código para fazer a transição entre cada estado manualmente seria tedioso e
propenso a erros, no entanto, especialmente quando você precisa adicionar mais funcionalidades e
mais estados ao código posteriormente. Felizmente, o compilador Rust cria e
gerencia automaticamente as estruturas de dados da máquina de estado para o código async. O
regras normais borrowing e ownership em torno de estruturas de dados ainda se aplicam,
e, felizmente, o compilador também cuida da verificação deles para nós e fornece
mensagens de erro úteis. Trabalharemos com alguns deles mais adiante neste capítulo.

Em última análise, algo tem que executar esta máquina de estado, e esse algo é
um tempo de execução. (É por isso que você pode encontrar menções de _executores_ quando
olhando para tempos de execução: um executor é a parte de um tempo de execução responsável por
executando o código async.)

Agora você pode ver por que o compilador nos impediu de tornar o próprio `main` um async
função na Listagem 17-3. Se `main` fosse uma função async, algo mais
precisaria gerenciar a máquina de estado para qualquer future `main` retornado, mas
`main ` é o ponto de partida do programa! Em vez disso, chamamos o
Função`trpl::block_on ` em`main ` para configurar um tempo de execução e executar o future
retornado pelo bloco`async` até que seja concluído.

> Nota: Alguns tempos de execução fornecem macros para que você _possa_ escrever um async `main`
> função. Essas macros reescrevem ` async fn main() {... }`para ser um ` fn
> main`normal, que faz a mesma coisa que fizemos manualmente na Listagem 17-4: chamar um
> função que executa um future até a conclusão da mesma forma que ` trpl::block_on`.

Agora vamos juntar essas peças e ver como podemos escrever código simultâneo.

<!-- Old headings. Do not remove or links may break. -->

<a id="racing-our-two-urls-against-each-other"></a>

### Racing Two URLs Against Each Other Concurrently

Na Listagem 17-5, chamamos `page_title` com duas URLs diferentes passadas do
linha de comando e execute-os selecionando o future que terminar primeiro.

<Listing number="17-5" caption="Chamando `page_title` para duas URLs para ver qual retorna primeiro" file-name="src/main.rs">

<!-- should_panic,noplayground because mdbook does not pass args -->

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch17-async-await/listing-17-05/src/main.rs:all}}
```

</Listing>

Começamos chamando `page_title` para cada um dos URLs fornecidos pelo usuário. Nós salvamos
o futures resultante como `title_fut_1` e `title_fut_2`. Lembre-se, estes não
não faça nada ainda, porque futures são preguiçosos e ainda não os esperamos. Então
passamos o futures para ` trpl::select`, que retorna um valor para indicar qual
do futures passado para ele termina primeiro.

> Nota: Nos bastidores, o `trpl::select` é construído em um `select` mais geral
> função definida no `futures` crate. O `futures` crate do `select`
> A função pode fazer muitas coisas que a função ` trpl::select`não pode, mas
> também possui alguma complexidade adicional que podemos ignorar por enquanto.

Qualquer future pode “ganhar” legitimamente, então não faz sentido retornar um
`Result `. Em vez disso,` trpl::select `retorna um tipo que não vimos antes,
` trpl::Either `. O tipo` Either `é um pouco semelhante a um` Result `no sentido de que
tem dois casos. Ao contrário do` Result `, porém, não há noção de sucesso ou
falha incorporada em` Either `. Em vez disso, usa` Left `e` Right`para indicar
“um ou outro”:

```rust
enum Either<A, B> {
    Left(A),
    Right(B),
}
```

A função `select` retorna `Left` com a saída do future se o primeiro
o argumento vence e `Right` com a saída do segundo argumento future se _that_
um vence. Isso corresponde à ordem em que os argumentos aparecem ao chamar o
função: o primeiro argumento está à esquerda do segundo argumento.

Também atualizamos `page_title` para retornar o mesmo URL passado. Dessa forma, se o
página que retorna primeiro não tem um `<title>` que possamos resolver, ainda podemos
imprimir uma mensagem significativa. Com essas informações disponíveis, encerramos com
atualizando nossa saída `println!` para indicar qual URL terminou primeiro e
qual é o `<title>`, se houver, para a página da web nesse URL.

Você construiu um pequeno raspador de web funcional agora! Escolha alguns URLs e execute o
ferramenta de linha de comando. Você pode descobrir que alguns sites são consistentemente mais rápidos
do que outros, enquanto em outros casos o site mais rápido varia de execução para execução. Mais
importante, você aprendeu o básico para trabalhar com futures, então agora podemos
aprofunde-se no que podemos fazer com async.

[impl-trait]: ch10-02-traits.html#traits-as-parameters
[iterators-lazy]: ch13-02-iterators.html
[thread-spawn]: ch16-01-threads.html#creating-a-new-thread-with-spawn
[cli-args]: ch12-01-accepting-command-line-arguments.html

<!-- TODO: map source link version to version of Rust? -->

[crate-source]: https://github.com/rust-lang/book/tree/main/packages/trpl
[futures-crate]: https://crates.io/crates/futures
[tokio]: https://tokio.rs
