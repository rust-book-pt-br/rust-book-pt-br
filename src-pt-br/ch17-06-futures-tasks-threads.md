## Juntando tudo: Futures, tarefas e threads

Como vimos no [Capítulo 16][ch16]<!-- ignore -->, threads fornecem uma forma de
concorrência. Neste capítulo vimos outra abordagem: usar async com futures e
streams. Se você está se perguntando quando escolher um método em vez do outro,
a resposta é: depende! E, em muitos casos, a escolha não é threads _ou_ async,
mas sim threads _e_ async.

Há décadas muitos sistemas operacionais oferecem modelos de concorrência
baseados em threads e, por isso, muitas linguagens de programação também os
suportam. No entanto, esses modelos não vêm sem trade-offs. Em muitos sistemas
operacionais, eles usam uma quantidade considerável de memória por thread.
Além disso, threads só são uma opção quando o sistema operacional e o hardware
as suportam. Diferentemente de desktops e dispositivos móveis convencionais,
alguns sistemas embarcados nem sequer têm sistema operacional e, portanto, não
têm threads.

O modelo async oferece um conjunto diferente, e em última análise
complementar, de trade-offs. No modelo async, operações concorrentes não
precisam de suas próprias threads. Em vez disso, podem ser executadas em
tarefas, como quando usamos `trpl::spawn_task` para iniciar trabalho a partir
de uma função síncrona na seção sobre streams. Uma tarefa é semelhante a uma
thread, mas, em vez de ser gerenciada pelo sistema operacional, é gerenciada
por código em nível de biblioteca: o runtime.

Existe um motivo para as APIs de criação de threads e de criação de tarefas
serem tão parecidas. Threads funcionam como uma fronteira para conjuntos de
operações síncronas; a concorrência é possível _entre_ threads. Tarefas
funcionam como uma fronteira para conjuntos de operações _assíncronas_; a
concorrência é possível tanto _entre_ quanto _dentro_ das tarefas, porque uma
tarefa pode alternar entre os futures em seu corpo. Por fim, futures são a
unidade mais granular de concorrência em Rust, e cada future pode representar
uma árvore de outros futures. O runtime, mais especificamente seu executor,
gerencia tarefas, e tarefas gerenciam futures. Nesse sentido, tarefas se
parecem com threads leves gerenciadas em runtime, com capacidades adicionais
que surgem do fato de serem gerenciadas por um runtime e não pelo sistema
operacional.

Isso não significa que tarefas async sejam sempre melhores do que threads, nem
o contrário. A concorrência com threads é, em alguns aspectos, um modelo de
programação mais simples do que a concorrência com `async`. Isso pode ser uma
força ou uma fraqueza. Threads são um pouco "dispare e esqueça": elas não têm
um equivalente nativo a um future e, portanto, simplesmente executam até o fim,
sem interrupção, exceto pelo próprio sistema operacional.

E acontece que threads e tarefas muitas vezes funcionam muito bem juntas,
porque tarefas podem, pelo menos em alguns runtimes, ser movidas entre
threads. De fato, nos bastidores, o runtime que estamos usando, incluindo as
funções `spawn_blocking` e `spawn_task`, é multithread por padrão! Muitos
runtimes usam uma abordagem chamada _work stealing_ para mover tarefas de forma
transparente entre threads, com base em como elas estão sendo utilizadas no
momento, a fim de melhorar o desempenho geral do sistema. Essa abordagem, na
verdade, exige tarefas _e_ threads e, portanto, também futures.

Ao pensar em qual método usar em cada situação, considere estas regras
práticas:

- Se o trabalho for _muito paralelizável_ (isto é, limitado por CPU), como
  processar um grande volume de dados em que cada parte pode ser tratada
  separadamente, threads costumam ser a melhor escolha.
- Se o trabalho for _muito concorrente_ (isto é, limitado por E/S), como lidar
  com mensagens vindas de muitas fontes diferentes e chegando em intervalos ou
  velocidades diferentes, async costuma ser a melhor escolha.

E, se você precisa tanto de paralelismo quanto de concorrência, não precisa
escolher entre threads e async. Você pode usá-los juntos livremente, deixando
cada um cumprir o papel em que se sai melhor. Por exemplo, a Listagem 17-25
mostra um exemplo bastante comum desse tipo de combinação em código Rust do
mundo real.

<Listing number="17-25" caption="Enviando mensagens com código bloqueante em uma thread e aguardando as mensagens em um bloco async" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-25/src/main.rs:all}}
```

</Listing>

Começamos criando um canal async e, em seguida, iniciando uma thread que toma
ownership do lado transmissor do canal usando a palavra-chave `move`. Dentro da
thread, enviamos os números de 1 a 10, dormindo um segundo entre cada envio.
Por fim, executamos um future criado com um bloco async passado a
`trpl::block_on`, como fizemos ao longo deste capítulo. Nesse future,
aguardamos essas mensagens, assim como nos outros exemplos de passagem de
mensagens que vimos.

Voltando ao cenário com o qual abrimos o capítulo, imagine executar um conjunto
de tarefas de codificação de vídeo usando uma thread dedicada, porque a
codificação de vídeo é limitada por computação, mas notificar a interface de
usuário de que essas operações terminaram por meio de um canal async. Existem
inúmeros exemplos desse tipo de combinação em casos de uso do mundo real.

## Resumo

Esta não é a última vez que você verá concorrência neste livro. O projeto do
[Capítulo 21][ch21]<!-- ignore --> vai aplicar esses conceitos em uma situação
mais realista do que os exemplos mais simples discutidos aqui e comparar de
forma mais direta a resolução de problemas com threads versus tarefas e
futures.

Independentemente de qual dessas abordagens você escolha, Rust oferece as
ferramentas necessárias para escrever código seguro, rápido e concorrente, seja
para um servidor web de alta vazão, seja para um sistema operacional embarcado.

A seguir, falaremos sobre formas idiomáticas de modelar problemas e estruturar
soluções à medida que seus programas em Rust ficam maiores. Além disso,
discutiremos como os idiomas de Rust se relacionam com aqueles com que você
pode estar familiarizado na programação orientada a objetos.

[ch16]: http://localhost:3000/ch16-00-concurrency.html
[combining-futures]: ch17-03-more-futures.html#building-our-own-async-abstractions
[streams]: ch17-04-streams.html#composing-streams
[ch21]: ch21-00-final-project-a-web-server.html
