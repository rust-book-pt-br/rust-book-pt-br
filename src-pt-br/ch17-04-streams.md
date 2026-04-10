<!-- Old headings. Do not remove or links may break. -->

<a id="streams"></a>

## Streams: Futures em sequência

Lembre-se de como usamos o receptor para nosso canal async anteriormente neste capítulo
na seção [“Passagem de mensagem”][17-02-messages]<!-- ignore -->. O async
O método `recv` produz uma sequência de itens ao longo do tempo. Este é um exemplo de
padrão muito mais geral conhecido como _stream_. Muitos conceitos são naturalmente
representado como streams: itens ficando disponíveis em uma fila, pedaços de dados
sendo extraído incrementalmente do sistema de arquivos quando o conjunto de dados completo é muito
grande para a memória do computador ou dados que chegam pela rede ao longo do tempo.
Como streams são futures, podemos usá-los com qualquer outro tipo de future e
combine-os de maneiras interessantes. Por exemplo, podemos agrupar eventos para evitar
acionando muitas chamadas de rede, defina tempos limite em sequências de longa duração
operações ou limitar eventos da interface do usuário para evitar trabalhos desnecessários.

Vimos uma sequência de itens no Capítulo 13, quando examinamos o Iterator
trait na seção [“A característica do iterador e o método `next` ”][iterator-trait]<!--
ignore -->, mas há duas diferenças entre iterators e o
Receptor de canal async. A primeira diferença é o tempo: iterators são
síncrono, enquanto o receptor do canal é assíncrono. A segunda diferença
é a API. Ao trabalhar diretamente com `Iterator`, chamamos seu síncrono
Método ` next`. Com o ` trpl::Receiver`stream em particular, chamamos um
método assíncrono ` recv`. Caso contrário, essas APIs parecem muito semelhantes,
e essa semelhança não é uma coincidência. Um stream é como um formulário assíncrono
de iteração. Considerando que o ` trpl::Receiver`espera especificamente para receber
mensagens, porém, a API stream de uso geral é muito mais ampla: ela fornece
o próximo item da mesma forma que ` Iterator`, mas de forma assíncrona.

A semelhança entre iterators e streams em Rust significa que podemos realmente
crie um stream a partir de qualquer iterator. Tal como acontece com um iterator, podemos trabalhar com um
stream chamando seu método `next` e aguardando a saída, como na Listagem
17-21, que ainda não será compilado.

<Listing number="17-21" caption="Criando uma stream a partir de um iterador e imprimindo seus valores" file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-21/src/main.rs:stream}}
```

</Listing>

Começamos com uma matriz de números, que convertemos em iterator e depois
chame `map` para dobrar todos os valores. Então convertemos o iterator em um
stream usando a função `trpl::stream_from_iter`. A seguir, fazemos um loop sobre o
itens no stream conforme eles chegam com o loop ` while let`.

Infelizmente, quando tentamos executar o código, ele não compila, mas sim
relata que não há método `next` disponível:

<!-- manual-regeneration
listagens de cd/ch17-async-await/listing-17-21
Construção cargo
copie apenas a saída do erro
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

Como esta saída explica, o motivo do erro do compilador é que precisamos do
direito trait no escopo para poder usar o método `next`. Dada a nossa discussão
até agora, você poderia razoavelmente esperar que trait fosse ` Stream`, mas é
na verdade ` StreamExt`. Abreviação de _extensão_, ` Ext`é um padrão comum no
comunidade Rust para estender um trait por outro.

O `Stream` trait define uma interface de baixo nível que combina efetivamente o
`Iterator ` e`Future ` traits.`StreamExt ` fornece um conjunto de APIs de nível superior
sobre`Stream `, incluindo o método` next `, bem como outros utilitários
métodos semelhantes aos fornecidos pelo` Iterator `trait.` Stream `e
` StreamExt`ainda não faz parte da biblioteca padrão do Rust, mas a maioria dos ecossistemas
crates usa definições semelhantes.

A correção para o erro do compilador é adicionar uma instrução `use` para
`trpl::StreamExt`, como na Listagem 17-22.

<Listing number="17-22" caption="Usando com sucesso um iterador como base para uma stream" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-22/src/main.rs:all}}
```

</Listing>

Com todas essas peças juntas, esse código funciona da maneira que queremos! O que é
mais, agora que temos `StreamExt` no escopo, podemos usar toda a sua utilidade
métodos, assim como com iterators.

[17-02-messages]: ch17-02-concurrency-with-async.html#message-passing
[iterator-trait]: ch13-02-iterators.html#the-iterator-trait-and-the-next-method
