<!-- Old headings. Do not remove or links may break. -->

<a id="concurrency-with-async"></a>

## Aplicando Concorrência com Async

Nesta seção, aplicaremos async a alguns dos mesmos desafios de concorrência que
enfrentamos com threads no Capítulo 16. Como já falamos sobre muitas das ideias
principais lá, nesta seção vamos nos concentrar no que há de diferente entre
threads e futures.

Em muitos casos, as APIs para trabalhar com concorrência usando async são muito
parecidas com as APIs para usar threads. Em outros casos, elas acabam sendo bem
diferentes. Mesmo quando as APIs _parecem_ semelhantes entre threads e async,
elas frequentemente têm comportamento diferente, e quase sempre têm
características de desempenho diferentes.

<!-- Old headings. Do not remove or links may break. -->

<a id="counting"></a>

### Criando uma Nova Tarefa com `spawn_task`

A primeira operação que enfrentamos na seção [“Criando uma Nova Thread com
`spawn`”][thread-spawn]<!-- ignore --> do Capítulo 16 foi contar em duas
threads separadas. Vamos fazer o mesmo usando async. O crate `trpl` fornece uma
função `spawn_task` que se parece muito com a API `thread::spawn`, e uma função
`sleep` que é uma versão async da API `thread::sleep`. Podemos usá-las juntas
para implementar o exemplo de contagem, como mostrado na Listagem 17-6.

<Listing number="17-6" caption="Criando uma nova tarefa para imprimir uma coisa enquanto a tarefa principal imprime outra" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-06/src/main.rs:all}}
```

</Listing>

Como ponto de partida, configuramos nossa função `main` com `trpl::block_on`
para que nossa função de nível superior possa ser async.

> Nota: Deste ponto em diante no capítulo, todos os exemplos incluirão
> exatamente este mesmo código de envolvimento com `trpl::block_on` em `main`,
> então muitas vezes o omitiremos, assim como fazemos com `main`. Lembre-se de
> incluí-lo no seu código!

Então escrevemos dois loops dentro desse bloco, cada um contendo uma chamada a
`trpl::sleep`, que espera meio segundo (500 milissegundos) antes de enviar a
próxima mensagem. Colocamos um loop no corpo de `trpl::spawn_task` e o outro em
um loop `for` de nível superior. Também adicionamos um `await` depois das
chamadas a `sleep`.

Este código se comporta de forma parecida com a implementação baseada em
threads, incluindo o fato de que você pode ver as mensagens aparecerem em uma
ordem diferente no seu próprio terminal ao executá-lo:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
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

Esta versão para assim que o loop `for` no corpo do bloco async principal
termina, porque a tarefa gerada por `spawn_task` é encerrada quando a função
`main` termina. Se você quiser que ela rode até a conclusão da tarefa, precisará
usar um join handle para aguardar a primeira tarefa terminar. Com threads,
usamos o método `join` para “bloquear” até que a thread terminasse de rodar. Na
Listagem 17-7, podemos usar `await` para fazer a mesma coisa, porque o handle
da tarefa é ele próprio um future. Seu tipo `Output` é um `Result`, então
também chamamos `unwrap` nele depois de aguardá-lo.

<Listing number="17-7" caption="Usando `await` com um join handle para executar uma tarefa até a conclusão" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-07/src/main.rs:handle}}
```

</Listing>

Esta versão atualizada roda até que _ambos_ os loops terminem:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
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

Até aqui, parece que async e threads nos dão resultados semelhantes, apenas com
sintaxe diferente: usamos `await` em vez de chamar `join` no join handle, e
aguardamos as chamadas a `sleep`.

A diferença maior é que não precisamos gerar outra thread do sistema
operacional para fazer isso. Na verdade, nem precisamos gerar uma tarefa aqui.
Como blocos async são compilados em futures anônimos, podemos colocar cada loop
em um bloco async e fazer o runtime executar ambos até o fim usando a função
`trpl::join`.

Na seção [“Esperando Todas as Threads Terminarem”][join-handles]<!-- ignore -->
do Capítulo 16, mostramos como usar o método `join` no tipo `JoinHandle`
retornado quando você chama `std::thread::spawn`. A função `trpl::join` é
semelhante, mas para futures. Quando você entrega dois futures a ela, ela
produz um único novo future cuja saída é uma tupla contendo a saída de cada
future que você passou, depois que _ambos_ terminarem. Assim, na Listagem 17-8,
usamos `trpl::join` para esperar que `fut1` e `fut2` terminem. Nós _não_
aguardamos `fut1` e `fut2`, mas sim o novo future produzido por `trpl::join`.
Ignoramos a saída, porque ela é apenas uma tupla contendo dois valores unit.

<Listing number="17-8" caption="Usando `trpl::join` para aguardar dois futures anônimos" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-08/src/main.rs:join}}
```

</Listing>

Quando executamos isso, vemos ambos os futures rodarem até o fim:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
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

Agora você verá exatamente a mesma ordem todas as vezes, o que é bem diferente
do que vimos com threads e com `trpl::spawn_task` na Listagem 17-7. Isso
acontece porque a função `trpl::join` é _justa_, o que significa que ela
verifica cada future com a mesma frequência, alternando entre eles, e nunca
deixa um disparar à frente se o outro estiver pronto. Com threads, o sistema
operacional decide qual thread verificar e por quanto tempo deixá-la rodar. Com
Rust async, o runtime decide qual tarefa verificar. (Na prática, os detalhes
ficam complicados porque um runtime async pode usar threads do sistema
operacional por baixo dos panos como parte de como gerencia concorrência, então
garantir justiça pode dar mais trabalho para um runtime, mas ainda é possível!)
Runtimes não precisam garantir justiça para qualquer operação específica, e
frequentemente oferecem APIs diferentes para permitir que você escolha se quer
ou não justiça.

Experimente algumas destas variações ao aguardar os futures e veja o que elas
fazem:

- Remova o bloco async ao redor de um ou de ambos os loops.
- Aguarde cada bloco async imediatamente depois de defini-lo.
- Envolva apenas o primeiro loop em um bloco async e aguarde o future
  resultante depois do corpo do segundo loop.

Como desafio extra, veja se consegue descobrir qual será a saída em cada caso
_antes_ de executar o código!

<!-- Old headings. Do not remove or links may break. -->

<a id="message-passing"></a>
<a id="counting-up-on-two-tasks-using-message-passing"></a>

### Enviando Dados Entre Duas Tarefas Usando Passagem de Mensagens

Compartilhar dados entre futures também será familiar: usaremos passagem de
mensagens novamente, mas desta vez com versões async dos tipos e funções. Vamos
seguir um caminho um pouco diferente daquele que seguimos na seção
[“Transferindo Dados Entre Threads com Passagem de Mensagens”][message-passing-threads]<!-- ignore -->
do Capítulo 16 para ilustrar algumas das principais diferenças entre
concorrência baseada em threads e concorrência baseada em futures. Na Listagem
17-9, começaremos com apenas um bloco async, _sem_ gerar uma tarefa separada
como geramos uma thread separada antes.

<Listing number="17-9" caption="Criando um canal async e atribuindo suas duas metades a `tx` e `rx`" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-09/src/main.rs:channel}}
```

</Listing>

Aqui, usamos `trpl::channel`, uma versão async da API de canal com múltiplos
produtores e consumidor único que usamos com threads no Capítulo 16. A versão
async da API é só um pouco diferente da versão baseada em threads: ela usa um
receptor mutável, em vez de um receptor imutável, `rx`, e seu método `recv`
produz um future que precisamos aguardar, em vez de produzir o valor
diretamente. Agora podemos enviar mensagens do sender para o receiver. Observe
que não precisamos gerar uma thread separada nem mesmo uma tarefa; precisamos
apenas aguardar a chamada a `rx.recv`.

O método síncrono `Receiver::recv` em `std::mpsc::channel` bloqueia até receber
uma mensagem. O método `trpl::Receiver::recv` não bloqueia, porque é async. Em
vez de bloquear, ele devolve o controle ao runtime até que uma mensagem seja
recebida ou o lado de envio do canal seja fechado. Em contraste, não aguardamos
a chamada a `send`, porque ela não bloqueia. Ela não precisa bloquear, porque o
canal para o qual estamos enviando é ilimitado.

> Nota: Como todo esse código async roda em um bloco async dentro de uma chamada
> a `trpl::block_on`, tudo dentro dele pode evitar bloqueio. No entanto, o
> código _fora_ dele bloqueará enquanto espera a função `block_on` retornar.
> Esse é o objetivo da função `trpl::block_on`: ela permite que você _escolha_
> onde bloquear em algum conjunto de código async e, portanto, onde fazer a
> transição entre código sync e async.

Observe duas coisas sobre este exemplo. Primeiro, a mensagem chegará
imediatamente. Segundo, embora usemos um future aqui, ainda não há concorrência.
Tudo na listagem acontece em sequência, exatamente como aconteceria se não
houvesse futures envolvidos.

Vamos abordar a primeira parte enviando uma série de mensagens e dormindo entre
elas, como mostrado na Listagem 17-10.

<!-- We cannot test this one because it never stops! -->

<Listing number="17-10" caption="Enviando e recebendo múltiplas mensagens pelo canal async e dormindo com um `await` entre cada mensagem" file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch17-async-await/listing-17-10/src/main.rs:many-messages}}
```

</Listing>

Além de enviar as mensagens, precisamos recebê-las. Neste caso, como sabemos
quantas mensagens virão, poderíamos fazer isso manualmente chamando
`rx.recv().await` quatro vezes. No mundo real, porém, geralmente estaremos
esperando por algum número _desconhecido_ de mensagens, então precisamos
continuar esperando até determinar que não há mais mensagens.

Na Listagem 16-10, usamos um loop `for` para processar todos os itens recebidos
de um canal síncrono. Rust ainda não tem uma forma de usar um loop `for` com
uma série de itens _produzida assincronamente_, porém, então precisamos usar um
loop que ainda não vimos: o loop condicional `while let`. Esta é a versão em
loop da construção `if let` que vimos na seção [“Fluxo de Controle Conciso com
`if let` e `let...else`”][if-let]<!-- ignore --> do Capítulo 6. O loop
continuará executando enquanto o padrão especificado continuar correspondendo
ao valor.

A chamada `rx.recv` produz um future, que aguardamos. O runtime pausará o
future até que ele esteja pronto. Assim que uma mensagem chega, o future se
resolve para `Some(message)` tantas vezes quantas mensagens chegarem. Quando o
canal fecha, independentemente de _qualquer_ mensagem ter chegado ou não, o
future se resolve para `None` para indicar que não há mais valores e, portanto,
devemos parar de fazer polling, isto é, parar de aguardar.

O loop `while let` junta tudo isso. Se o resultado de chamar
`rx.recv().await` for `Some(message)`, obtemos acesso à mensagem e podemos
usá-la no corpo do loop, assim como poderíamos fazer com `if let`. Se o
resultado for `None`, o loop termina. Toda vez que o loop completa, ele atinge
o ponto de await de novo, então o runtime o pausa novamente até que outra
mensagem chegue.

O código agora envia e recebe todas as mensagens com sucesso. Infelizmente,
ainda há alguns problemas. Primeiro, as mensagens não chegam em intervalos de
meio segundo. Elas chegam todas de uma vez, 2 segundos (2.000 milissegundos)
depois de iniciarmos o programa. Segundo, este programa também nunca termina!
Em vez disso, ele espera para sempre por novas mensagens. Você precisará
encerrá-lo usando <kbd>ctrl</kbd>-<kbd>C</kbd>.

#### Código Dentro de Um Bloco Async Executa Linearmente

Vamos começar examinando por que as mensagens chegam todas de uma vez depois
do atraso completo, em vez de chegarem com atrasos entre elas. Dentro de um
determinado bloco async, a ordem em que as palavras-chave `await` aparecem no
código também é a ordem em que elas são executadas quando o programa roda.

Há apenas um bloco async na Listagem 17-10, então tudo nele roda linearmente.
Ainda não há concorrência. Todas as chamadas a `tx.send` acontecem,
intercaladas com todas as chamadas a `trpl::sleep` e seus pontos de await
associados. Só então o loop `while let` chega a passar por algum dos pontos de
await nas chamadas a `recv`.

Para obter o comportamento que queremos, em que o atraso de sleep acontece
entre cada mensagem, precisamos colocar as operações `tx` e `rx` em seus
próprios blocos async, como mostrado na Listagem 17-11. Então o runtime pode
executar cada uma separadamente usando `trpl::join`, assim como na Listagem
17-8. Mais uma vez, aguardamos o resultado de chamar `trpl::join`, não os
futures individuais. Se aguardássemos os futures individuais em sequência,
acabaríamos voltando a um fluxo sequencial, exatamente o que estamos tentando
_não_ fazer.

<!-- We cannot test this one because it never stops! -->

<Listing number="17-11" caption="Separando `send` e `recv` em seus próprios blocos `async` e aguardando os futures desses blocos" file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch17-async-await/listing-17-11/src/main.rs:futures}}
```

</Listing>

Com o código atualizado da Listagem 17-11, as mensagens são impressas em
intervalos de 500 milissegundos, em vez de todas de uma vez depois de 2
segundos.

#### Movendo Ownership Para Dentro de Um Bloco Async

O programa ainda nunca termina, porém, por causa da forma como o loop
`while let` interage com `trpl::join`:

- O future retornado por `trpl::join` só completa quando _ambos_ os futures
  passados a ele completarem.
- O future `tx_fut` completa depois que termina de dormir após enviar a última
  mensagem em `vals`.
- O future `rx_fut` não completará até que o loop `while let` termine.
- O loop `while let` não terminará até que aguardar `rx.recv` produza `None`.
- Aguardar `rx.recv` retornará `None` somente depois que a outra extremidade do
  canal for fechada.
- O canal fechará somente se chamarmos `rx.close` ou quando o lado de envio,
  `tx`, for descartado.
- Não chamamos `rx.close` em lugar nenhum, e `tx` não será descartado até que o
  bloco async mais externo passado a `trpl::block_on` termine.
- O bloco não consegue terminar porque está bloqueado em `trpl::join`
  completando, o que nos leva de volta ao topo desta lista.

Neste momento, o bloco async em que enviamos as mensagens apenas _pega
emprestado_ `tx`, porque enviar uma mensagem não exige ownership. Mas, se
pudéssemos _mover_ `tx` para dentro desse bloco async, ele seria descartado
assim que o bloco terminasse. Na seção [“Capturando Referências ou Movendo
Ownership”][capture-or-move]<!-- ignore --> do Capítulo 13, você aprendeu a
usar a palavra-chave `move` com closures e, como discutido na seção [“Usando
Closures `move` com Threads”][move-threads]<!-- ignore --> do Capítulo 16,
muitas vezes precisamos mover dados para dentro de closures ao trabalhar com
threads. A mesma dinâmica básica se aplica a blocos async, então a
palavra-chave `move` funciona com blocos async assim como funciona com
closures.

Na Listagem 17-12, alteramos o bloco usado para enviar mensagens de `async`
para `async move`.

<Listing number="17-12" caption="Uma revisão do código da Listagem 17-11 que encerra corretamente ao terminar" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-12/src/main.rs:with-move}}
```

</Listing>

Quando executamos _esta_ versão do código, ela encerra de forma adequada depois
que a última mensagem é enviada e recebida. A seguir, vamos ver o que precisaria
mudar para enviar dados a partir de mais de um future.

#### Juntando Vários Futures com a Macro `join!`

Esse canal async também é um canal de múltiplos produtores, então podemos
chamar `clone` em `tx` se quisermos enviar mensagens a partir de múltiplos
futures, como mostrado na Listagem 17-13.

<Listing number="17-13" caption="Usando múltiplos produtores com blocos async" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-13/src/main.rs:here}}
```

</Listing>

Primeiro, clonamos `tx`, criando `tx1` fora do primeiro bloco async. Movemos
`tx1` para dentro desse bloco exatamente como fizemos antes com `tx`. Então,
mais tarde, movemos o `tx` original para dentro de um _novo_ bloco async, onde
enviamos mais mensagens com um atraso um pouco mais lento. Acontece que
colocamos esse novo bloco async depois do bloco async que recebe mensagens, mas
ele poderia vir antes também. O que importa é a ordem em que os futures são
aguardados, não a ordem em que são criados.

Ambos os blocos async para enviar mensagens precisam ser blocos `async move`
para que tanto `tx` quanto `tx1` sejam descartados quando esses blocos
terminarem. Caso contrário, voltaríamos ao mesmo loop infinito em que
começamos.

Por fim, trocamos `trpl::join` por `trpl::join!` para lidar com o future
adicional: a macro `join!` aguarda um número arbitrário de futures quando
sabemos o número de futures em tempo de compilação. Discutiremos como aguardar
uma coleção com um número desconhecido de futures mais adiante neste capítulo.

Agora vemos todas as mensagens dos dois futures de envio e, como os futures de
envio usam atrasos ligeiramente diferentes depois de enviar, as mensagens
também são recebidas nesses intervalos diferentes:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
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

Exploramos como usar passagem de mensagens para enviar dados entre futures,
como o código dentro de um bloco async roda sequencialmente, como mover
ownership para dentro de um bloco async e como juntar múltiplos futures. A
seguir, vamos discutir como e por que informar ao runtime que ele pode alternar
para outra tarefa.

[thread-spawn]: ch16-01-threads.html#creating-a-new-thread-with-spawn
[join-handles]: ch16-01-threads.html#waiting-for-all-threads-to-finish
[message-passing-threads]: ch16-02-message-passing.html
[if-let]: ch06-03-if-let.html
[capture-or-move]: ch13-01-closures.html#capturing-references-or-moving-ownership
[move-threads]: ch16-01-threads.html#using-move-closures-with-threads
