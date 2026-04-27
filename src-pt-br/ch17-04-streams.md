<!-- Old headings. Do not remove or links may break. -->

<a id="streams"></a>

## Streams: Futures em Sequência

Lembre-se de como usamos o receptor do nosso canal async anteriormente neste capítulo,
na seção [“Passagem de mensagens”][17-02-messages]<!-- ignore -->. O método async
`recv` produz uma sequência de itens ao longo do tempo. Esse é um exemplo de um
padrão muito mais geral conhecido como _stream_. Muitos conceitos são naturalmente
representados como streams: itens ficando disponíveis em uma fila, pedaços de dados
sendo extraídos incrementalmente do sistema de arquivos quando o conjunto completo é muito
grande para a memória do computador ou dados chegando pela rede ao longo do tempo.
Como streams são futures, podemos usá-los com qualquer outro tipo de future e
combiná-los de maneiras interessantes. Por exemplo, podemos agrupar eventos para evitar
disparar muitas chamadas de rede, definir timeouts em sequências de operações longas
ou limitar eventos da interface do usuário para evitar trabalho desnecessário.

Vimos uma sequência de itens no Capítulo 13, quando examinamos a trait
`Iterator` na seção [“A trait `Iterator` e o Método `next`”][iterator-trait]<!--
ignore -->, mas há duas diferenças entre iteradores e o receptor de canal async.
A primeira diferença é o tempo: iteradores são síncronos, enquanto o receptor do
canal é assíncrono. A segunda diferença é a API. Ao trabalhar diretamente com
`Iterator`, chamamos seu método síncrono `next`. Com a stream `trpl::Receiver`,
em particular, chamamos um método assíncrono `recv`. Fora isso, essas APIs
parecem muito semelhantes, e essa semelhança não é coincidência. Uma stream é
como uma forma assíncrona de iteração. Enquanto `trpl::Receiver` espera
especificamente receber mensagens, porém, a API geral de streams é muito mais
ampla: ela fornece o próximo item da mesma forma que `Iterator`, mas de modo
assíncrono.

A semelhança entre iteradores e streams em Rust significa que podemos realmente
criar uma stream a partir de qualquer iterador. Assim como acontece com um
iterador, podemos trabalhar com uma stream chamando seu método `next` e
aguardando a saída, como na Listagem 17-21, que ainda não compilará.

<Listing number="17-21" caption="Criando uma stream a partir de um iterador e imprimindo seus valores" file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-21/src/main.rs:stream}}
```

</Listing>

Começamos com um array de números, que convertemos em um iterador e depois
chamamos `map` para dobrar todos os valores. Então convertemos o iterador em uma
stream usando a função `trpl::stream_from_iter`. Em seguida, iteramos sobre os
itens da stream à medida que eles chegam com o loop `while let`.

Infelizmente, quando tentamos executar o código, ele não compila; em vez disso,
relata que não há método `next` disponível:

<!-- manual-regeneration
cd listings/ch17-async-await/listing-17-21
cargo build
copy only the error output
-->

```text
error[E0599]: no method named `next` found for struct `tokio_stream::iter::Iter` in the current scope
  --> src/main.rs:10:40
   |
10 |         while let Some(value) = stream.next().await {
   |                                        ^^^^
   |
   = help: items from traits can only be used if the trait is in scope
help: the following traits which provide `next` are implemented but not in scope; perhaps you want to import one of them
   |
1  + use crate::trpl::StreamExt;
   |
1  + use futures_util::stream::stream::StreamExt;
   |
1  + use std::iter::Iterator;
   |
1  + use std::str::pattern::Searcher;
   |
help: there is a method `try_next` with a similar name
   |
10 |         while let Some(value) = stream.try_next().await {
   |                                        ~~~~~~~~
```

Como essa saída explica, o motivo do erro do compilador é que precisamos da
trait correta em escopo para poder usar o método `next`. Dada a nossa discussão
até agora, você poderia razoavelmente esperar que essa trait fosse `Stream`, mas é
na verdade `StreamExt`. Abreviação de _extension_, `Ext` é um padrão comum na
comunidade Rust para estender uma trait com outra.

A trait `Stream` define uma interface de baixo nível que combina efetivamente as
traits `Iterator` e `Future`. `StreamExt` fornece um conjunto de APIs de nível
mais alto sobre `Stream`, incluindo o método `next`, bem como outros métodos
utilitários semelhantes aos fornecidos pela trait `Iterator`. `Stream` e
`StreamExt` ainda não fazem parte da biblioteca padrão de Rust, mas a maior
parte dos crates do ecossistema usa definições semelhantes.

A correção para o erro do compilador é adicionar uma instrução `use` para
`trpl::StreamExt`, como na Listagem 17-22.

<Listing number="17-22" caption="Usando com sucesso um iterador como base para uma stream" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-22/src/main.rs:all}}
```

</Listing>

Com todas essas peças juntas, esse código funciona da maneira que queremos!
Além disso, agora que temos `StreamExt` em escopo, podemos usar todos os seus
métodos utilitários, assim como fazemos com iteradores.

[17-02-messages]: ch17-02-concurrency-with-async.html#message-passing
[iterator-trait]: ch13-02-iterators.html#the-iterator-trait-and-the-next-method
