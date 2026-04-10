<!-- Old headings. Do not remove or links may break. -->

<a id="concurrency-with-async"></a>

## Aplicando simultaneidade com Async

Nesta seção, aplicaremos async a alguns dos mesmos desafios de simultaneidade
abordamos threads no Capítulo 16. Porque já falamos sobre muitos
ideias-chave, nesta seção vamos nos concentrar no que há de diferente entre
threads e futures.

Em muitos casos, as APIs para trabalhar com simultaneidade usando async são muito
semelhantes àqueles para usar threads. Em outros casos, acabam sendo bastante
diferente. Mesmo quando as APIs _parecem_ semelhantes entre threads e async, elas
muitas vezes têm comportamentos diferentes – e quase sempre têm desempenhos diferentes
características.

<!-- Old headings. Do not remove or links may break. -->

<a id="counting"></a>

### Criando uma nova tarefa com `spawn_task`

A primeira operação que abordamos em [“Criando um novo tópico com
`spawn ` ”][thread-spawn]A seção <!-- ignore --> no Capítulo 16 estava contando com
dois threads separados. Vamos fazer o mesmo usando async. O`trpl ` crate fornece
uma função`spawn_task ` que se parece muito com a API`thread::spawn `, e
uma função` sleep `que é uma versão async da API` thread::sleep`. Nós podemos
use-os juntos para implementar o exemplo de contagem, conforme mostrado na Listagem 17-6.

<Listing number="17-6" caption="Criando uma nova tarefa para imprimir algo enquanto a tarefa principal imprime outra coisa" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-06/src/main.rs:all}}
```

</Listing>

Como ponto de partida, configuramos nossa função `main` com `trpl::block_on` para
que nossa função de nível superior pode ser async.

> Nota: Deste ponto em diante no capítulo, cada exemplo incluirá este
> exatamente o mesmo código de empacotamento com `trpl::block_on` em `main`, então frequentemente o ignoraremos
> assim como fazemos com ` main`. Lembre-se de incluí-lo em seu código!

Então escrevemos dois loops dentro desse bloco, cada um contendo um `trpl::sleep`
chamada, que espera meio segundo (500 milissegundos) antes de enviar a próxima
mensagem. Colocamos um loop no corpo de um ` trpl::spawn_task`e o outro em um
loop ` for`de nível superior. Também adicionamos um ` await`após as chamadas ` sleep`.

Este código se comporta de forma semelhante à implementação baseada em thread - incluindo o
fato de que você pode ver as mensagens aparecerem em uma ordem diferente em seu próprio
terminal quando você o executa:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
changes in the compiler -->

```text
hi number 1 from the second task!
hi number 1 from the first task!
hi number 2 from the first task!
hi number 2 from the second task!
hi number 3 from the first task!
hi number 3 from the second task!
hi number 4 from the first task!
hi number 4 from the second task!
hi number 5 from the first task!
```

Esta versão para assim que o loop `for` no corpo do async principal
bloco termina, porque a tarefa gerada por `spawn_task` é encerrada quando o
A função `main` termina. Se você quiser que ele seja executado até o final da tarefa
conclusão, você precisará usar um identificador de junção para aguardar a conclusão da primeira tarefa.
completo. Com threads, usamos o método `join` para “bloquear” até o thread
terminou de correr. Na Listagem 17-7, podemos usar `await` para fazer a mesma coisa,
porque o identificador da tarefa em si é um future. Seu tipo `Output` é um `Result`, então
também o desembrulhamos depois de esperar.

<Listing number="17-7" caption="Usando `await` com um join handle para executar uma tarefa até a conclusão" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-07/src/main.rs:handle}}
```

</Listing>

Esta versão atualizada é executada até que _ambos_ os loops terminem:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
changes in the compiler -->

```text
hi number 1 from the second task!
hi number 1 from the first task!
hi number 2 from the first task!
hi number 2 from the second task!
hi number 3 from the first task!
hi number 3 from the second task!
hi number 4 from the first task!
hi number 4 from the second task!
hi number 5 from the first task!
hi number 6 from the first task!
hi number 7 from the first task!
hi number 8 from the first task!
hi number 9 from the first task!
```

Até aqui, async e threads parecem nos dar resultados parecidos, apenas com uma
sintaxe diferente: usamos `await` em vez de chamar `join` no `JoinHandle`, e
aguardamos as chamadas a `sleep`.

A diferença maior é que não precisamos criar outra thread do sistema
operacional para fazer isso. Na verdade, nem precisamos gerar uma tarefa aqui.
Como blocos async são compilados em futures anônimos, podemos colocar cada loop
em um bloco async e fazer o runtime executar ambos até o fim usando a função
`trpl::join`.

Na seção [“Esperando todas as threads terminarem”][join-handles]<!-- ignore -->
do Capítulo 16, mostramos como usar o método `join` no tipo `JoinHandle`
retornado quando você chama `std::thread::spawn`. A função `trpl::join` é
parecida, mas para futures. Quando você entrega dois futures a ela, ela produz
um único novo future cuja saída é uma tupla contendo a saída de cada future que
você passou, assim que _ambos_ forem concluídos. Por isso, na Listagem 17-8,
usamos `trpl::join` para esperar que `fut1` e `fut2` terminem. Nós _não_
aguardamos `fut1` e `fut2` diretamente, mas sim o novo future produzido por
`trpl::join`. Ignoramos a saída porque ela é apenas uma tupla contendo dois
valores unitários.

<Listing number="17-8" caption="Usando `trpl::join` para aguardar dois futures anônimos" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-08/src/main.rs:join}}
```

</Listing>

Quando executamos isso, vemos ambos futures sendo executados até a conclusão:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
changes in the compiler -->

```text
hi number 1 from the first task!
hi number 1 from the second task!
hi number 2 from the first task!
hi number 2 from the second task!
hi number 3 from the first task!
hi number 3 from the second task!
hi number 4 from the first task!
hi number 4 from the second task!
hi number 5 from the first task!
hi number 6 from the first task!
hi number 7 from the first task!
hi number 8 from the first task!
hi number 9 from the first task!
```

Agora, você verá exatamente a mesma ordem em todas as execuções, o que é bem
diferente do que vimos com threads e com `trpl::spawn_task` na Listagem 17-7.
Isso acontece porque a função `trpl::join` é _justa_, o que significa que ela
verifica cada future com a mesma frequência, alternando entre eles, e nunca
deixa um disparar muito à frente se o outro estiver pronto. Com threads, o
sistema operacional decide qual thread verificar e por quanto tempo deixá-la
executar. Com async em Rust, o runtime decide qual tarefa verificar. Na
prática, os detalhes ficam complicados, porque um runtime async pode usar
threads do sistema operacional nos bastidores como parte de como gerencia a
concorrência, então garantir justiça pode dar mais trabalho, mas ainda assim é
possível. Runtimes não precisam garantir justiça para toda operação e, com
frequência, oferecem APIs diferentes para permitir que você escolha se quer ou
não esse comportamento.

Experimente algumas destas variações ao aguardar os futures e veja o que elas
fazem:

- Remova o bloco async ao redor de um ou de ambos os loops.
- Aguarde cada bloco async imediatamente após defini-lo.
- Enrole apenas o primeiro loop em um bloco async e await o future resultante
  após o corpo do segundo loop.

Como desafio extra, tente descobrir qual será o resultado em cada caso _antes_
de executar o código!

<!-- Old headings. Do not remove or links may break. -->

<a id="message-passing"></a>
<a id="counting-up-on-two-tasks-using-message-passing"></a>

### Envio de dados entre duas tarefas usando passagem de mensagens

Compartilhar dados entre futures também vai soar familiar: usaremos novamente a
passagem de mensagens, mas agora com versões async dos tipos e das funções.
Vamos seguir um caminho um pouco diferente do que seguimos na seção
[“Transferindo dados entre threads com passagem de
mensagens”][message-passing-threads]<!-- ignore --> do Capítulo 16 para
ilustrar algumas das diferenças principais entre concorrência baseada em
threads e concorrência baseada em futures. Na Listagem 17-9, vamos começar com
apenas um bloco async, _sem_ gerar uma tarefa separada, da mesma forma que
antes geramos uma thread separada.

<Listing number="17-9" caption="Criando um canal async e atribuindo suas duas metades a `tx` e `rx`" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-09/src/main.rs:channel}}
```

</Listing>

Aqui usamos `trpl::channel`, uma versão async da API de canal com múltiplos
produtores e um único consumidor que usamos com threads no Capítulo 16. A
versão async da API é apenas um pouco diferente da versão baseada em threads:
ela usa um receptor mutável, e não imutável, `rx`, e seu método `recv`
produz um future que precisamos aguardar, em vez de produzir o valor
diretamente. Agora podemos enviar mensagens do emissor para o receptor.
Observe que não precisamos criar uma thread separada nem mesmo uma tarefa;
basta aguardar a chamada a `rx.recv`.

O método síncrono `Receiver::recv` em `std::mpsc::channel` bloqueia até
recebe uma mensagem. O método `trpl::Receiver::recv` não, porque é
async. Em vez de bloquear, ele devolve o controle ao tempo de execução até que um
a mensagem é recebida ou o lado de envio do canal é fechado. Em contrapartida, nós
não await a chamada `send`, porque ela não bloqueia. Não é necessário,
porque o canal para o qual estamos enviando é ilimitado.

> Nota: Como todo esse código async é executado dentro de um bloco async em uma
> chamada a `trpl::block_on`, tudo o que está dentro dele pode evitar bloqueio.
> Em contrapartida, o código _fora_ dele ficará bloqueado até que a função
> `block_on` retorne. Esse é justamente o objetivo de `trpl::block_on`: deixar
> você _escolher_ onde bloquear em um conjunto de código async e, portanto,
> onde fazer a transição entre código síncrono e assíncrono.

Observe duas coisas neste exemplo. Primeiro, a mensagem chegará imediatamente.
Segundo, embora estejamos usando um future aqui, ainda não há concorrência.
Tudo na listagem acontece em sequência, exatamente como aconteceria se não
houvesse futures envolvidos.

Vamos abordar a primeira parte enviando uma série de mensagens e dormindo
entre eles, conforme mostrado na Listagem 17-10.

<!-- We cannot test this one because it never stops! -->

<Listing number="17-10" caption="Enviando e recebendo várias mensagens pelo canal async e aguardando com `await` entre cada mensagem" file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch17-async-await/listing-17-10/src/main.rs:many-messages}}
```

</Listing>

Além de enviar as mensagens, precisamos recebê-las. Neste caso,
como sabemos quantas mensagens estão chegando, poderíamos fazer isso manualmente,
ligando para `rx.recv().await` quatro vezes. No mundo real, porém, geralmente
estar esperando por um número _desconhecido_ de mensagens, então precisamos continuar esperando
até determinarmos que não há mais mensagens.

Na Listagem 16-10, usamos um loop `for` para processar todos os itens recebidos de um
canal síncrono. Rust ainda não tem como usar um loop `for` com um
série de itens _produzidos de forma assíncrona_, portanto, precisamos usar um loop que
nunca vi antes: o loop condicional `while let`. Esta é a versão em loop
da construção ` if let`que vimos na seção [“Concise Control Flow with ` if
let`and ` let...else`”][if-let]<!-- ignore --> no Capítulo 6. O loop
continuará em execução enquanto o padrão especificado continuar em match
o valor.

A chamada `rx.recv` produz um future, que nós await. O tempo de execução será pausado
o future até que esteja pronto. Assim que uma mensagem chegar, o future resolverá
para `Some(message)` quantas vezes uma mensagem chegar. Quando o canal fecha,
independentemente de _qualquer_ mensagem ter chegado, o future irá, em vez disso,
resolva para `None` para indicar que não há mais valores e, portanto, devemos
pare de pesquisar – isto é, pare de esperar.

O loop `while let` reúne tudo isso. Se o resultado da chamada
`rx.recv().await ` é`Some(message) `, temos acesso à mensagem e podemos
use-o no corpo do loop, assim como poderíamos com` if let `. Se o resultado for
` None`, o loop termina. Cada vez que o loop é concluído, ele atinge o ponto await
novamente, então o tempo de execução o pausa novamente até que outra mensagem chegue.

O código agora envia e recebe com êxito todas as mensagens.
Infelizmente, ainda existem alguns problemas. Por um lado, o
as mensagens não chegam em intervalos de meio segundo. Eles chegam todos de uma vez, 2
segundos (2.000 milissegundos) depois de iniciarmos o programa. Por outro lado, isso
o programa também nunca sai! Em vez disso, espera eternamente por novas mensagens. Você vai
precisa desligá-lo usando <kbd>ctrl</kbd>-<kbd>C</kbd>.

#### O código dentro de um bloco assíncrono é executado linearmente

Vamos começar examinando por que as mensagens chegam todas de uma vez após a mensagem completa.
atraso, em vez de entrar com atrasos entre cada um. Dentro de um determinado async
bloco, a ordem em que as palavras-chave `await` aparecem no código também é a ordem
em que eles são executados quando o programa é executado.

Há apenas um bloco async na Listagem 17-10, então tudo nele é executado
linearmente. Ainda não há simultaneidade. Todas as chamadas `tx.send` acontecem,
intercalado com todas as chamadas `trpl::sleep` e seus await associados
pontos. Só então o loop `while let` passa por qualquer um dos
`await ` aponta nas chamadas`recv`.

Para obter o comportamento que desejamos, onde o atraso do sono acontece entre cada
mensagem, precisamos colocar as operações `tx` e `rx` em seus próprios blocos async,
conforme mostrado na Listagem 17-11. Então o tempo de execução pode executar cada um deles separadamente
usando `trpl::join`, assim como na Listagem 17-8. Mais uma vez, temos await o resultado de
chamando ` trpl::join`, não o futures individual. Se esperássemos o indivíduo
futures em sequência, acabaríamos voltando a um fluxo sequencial - exatamente
o que estamos tentando _não_ fazer.

<!-- We cannot test this one because it never stops! -->

<Listing number="17-11" caption="Separando `send` e `recv` em seus próprios blocos `async` e aguardando os futures desses blocos" file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch17-async-await/listing-17-11/src/main.rs:futures}}
```

</Listing>

Com o código atualizado na Listagem 17-11, as mensagens são impressas em
Intervalos de 500 milissegundos, em vez de tudo com pressa após 2 segundos.

#### Movendo a ownership para um bloco assíncrono

O programa ainda nunca sai, devido à forma como o loop `while let`
interage com ` trpl::join`:

- O future retornado de `trpl::join` é concluído apenas uma vez _ambos_ futures
  passado para ele foi concluído.
- O `tx_fut` future é concluído quando termina de dormir após enviar o último
  mensagem em `vals`.
- O ` rx_fut`future não será concluído até que o loop ` while let`termine.
- O loop ` while let`não terminará até que a espera de ` rx.recv`produza ` None`.
- Aguardando ` rx.recv`retornará ` None`apenas uma vez na outra extremidade do canal
  está fechado.
- O canal será fechado somente se chamarmos ` rx.close`ou quando o lado do remetente,
 ` tx `, foi descartado.
- Não chamamos` rx.close `em lugar nenhum e` tx `não será descartado até o
  o bloco async mais externo passado para as extremidades` trpl::block_on `.
- O bloco não pode terminar porque está bloqueado na conclusão do` trpl::join`, o que
  nos leva de volta ao topo desta lista.

No momento, o bloco async para onde enviamos as mensagens apenas _pega emprestado_ `tx`
porque o envio de uma mensagem não requer ownership, mas se pudéssemos _mover_
` tx`nesse bloco async, ele será descartado assim que o bloco terminar. No
[“Capturing References or Moving Ownership”][capture-or-move]<!-- ignore -->
seção no Capítulo 13, você aprendeu como usar a palavra-chave `move` com closures,
e, conforme discutido em [“Usando fechamentos `move` com
Threads”][move-threads]<!-- ignore --> no Capítulo 16, muitas vezes precisamos
mova dados para closures ao trabalhar com threads. A mesma dinâmica básica
se aplica a blocos async, portanto a palavra-chave `move` funciona com blocos async da mesma forma que
faz com closures.

Na Listagem 17-12, alteramos o bloco usado para enviar mensagens de `async` para
`async move`.

<Listing number="17-12" caption="Uma revisão do código da Listagem 17-11 que encerra corretamente ao terminar" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-12/src/main.rs:with-move}}
```

</Listing>

Quando executamos _esta_ versão do código, ele é encerrado normalmente após a última
mensagem é enviada e recebida. A seguir, vamos ver o que precisaria ser alterado para enviar
dados de mais de um future.

#### Unindo um número de Futures com a macro `join!`

Este canal async também é um canal de múltiplos produtores, então podemos chamar `clone`
em ` tx`se quisermos enviar mensagens de vários futures, conforme mostrado na listagem
17-13.

<Listing number="17-13" caption="Usando múltiplos produtores com blocos async" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-13/src/main.rs:here}}
```

</Listing>

Primeiro, clonamos `tx`, criando ` tx1`fora do primeiro bloco async. Nós nos movemos
` tx1 `nesse bloco, assim como fizemos antes com` tx `. Então, mais tarde, movemos o
` tx`original em um _novo_ bloco async, onde enviamos mais mensagens em um
atraso ligeiramente mais lento. Acontece que colocamos este novo bloco async após o async
bloquear para receber mensagens, mas também poderia ir antes. A chave é
a ordem em que os futures são aguardados, não a ordem em que são criados.

Ambos os blocos async para envio de mensagens precisam ser blocos `async move`, então
que ` tx`e ` tx1`sejam eliminados quando esses blocos terminarem. Caso contrário, iremos
acabaremos de volta no mesmo loop infinito em que começamos.

Finalmente, mudamos de `trpl::join` para `trpl::join!` para lidar com o adicional
future: a macro `join!` aguarda um número arbitrário de futures onde sabemos
o número de futures em tempo de compilação. Discutiremos a espera de uma coleção de
um número desconhecido de futures posteriormente neste capítulo.

Agora vemos todas as mensagens do envio futures e porque o envio
futures usa atrasos ligeiramente diferentes após o envio, as mensagens também são
recebidos nesses diferentes intervalos:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
changes in the compiler -->

```text
received 'hi'
received 'more'
received 'from'
received 'the'
received 'messages'
received 'future'
received 'for'
received 'you'
```

Exploramos como usar a passagem de mensagens para enviar dados entre futures, como
código dentro de um bloco async é executado sequencialmente, como mover ownership para um
bloco async e como unir vários futures. A seguir, vamos discutir como e por quê
para informar ao tempo de execução que ele pode mudar para outra tarefa.

[thread-spawn]: ch16-01-threads.html#creating-a-new-thread-with-spawn
[join-handles]: ch16-01-threads.html#waiting-for-all-threads-to-finish
[message-passing-threads]: ch16-02-message-passing.html
[if-let]: ch06-03-if-let.html
[capture-or-move]: ch13-01-closures.html#capturing-references-or-moving-ownership
[move-threads]: ch16-01-threads.html#using-move-closures-with-threads
