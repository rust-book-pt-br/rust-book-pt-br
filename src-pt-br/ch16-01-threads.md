## Usando Threads para Executar Código Simultaneamente

Na maioria dos sistemas operacionais atuais, o código de um programa é executado em um
_process_, e o sistema operacional gerencia vários processos ao mesmo tempo.
Dentro de um programa, você também pode ter partes independentes que são executadas simultaneamente.
Os recursos que executam essas partes independentes são chamados de _threads_. Por
exemplo, um web server pode ter várias threads para que possa responder a
mais de uma solicitação ao mesmo tempo.

Dividir o cálculo do seu programa em várias threads para executar várias
tarefas ao mesmo tempo pode melhorar o desempenho, mas também adiciona complexidade.
Como as threads podem ser executadas simultaneamente, não há garantia inerente sobre a
ordem em que partes do seu código em diferentes threads serão executadas. Isso pode levar
a problemas, como:

- Condições de corrida, nas quais threads acessam dados ou recursos em uma
  ordem inconsistente
- Deadlocks, nos quais duas threads ficam esperando uma pela outra, impedindo que ambas
  as threads continuem
- Bugs que só acontecem em determinadas situações e são difíceis de reproduzir e corrigir
  de forma confiável

Rust tenta mitigar os efeitos negativos do uso de threads, mas
a programação em um contexto multithread ainda exige reflexão cuidadosa e requer
uma estrutura de código diferente daquela dos programas executados em um único
thread.

As linguagens de programação implementam threads de maneiras diferentes, e muitos
sistemas operacionais fornecem uma API que a linguagem pode chamar para criar
novas threads. A biblioteca padrão do Rust usa um modelo de implementação de
threads _1:1_, em que um programa usa uma thread do sistema operacional para cada
thread da linguagem. Existem crates que implementam outros modelos de threading,
fazendo trade-offs diferentes em relação ao modelo 1:1. (O sistema async do Rust,
que veremos no próximo capítulo, também oferece outra abordagem para a
concorrência.)

### Criando um novo thread com `spawn`

Para criar um novo thread, chamamos a função `thread::spawn` e passamos a ela um
closure (falamos sobre closures no Capítulo 13) contendo o código que queremos
execute no novo thread. O exemplo na Listagem 16-1 imprime algum texto de um main
thread e outros textos de um novo thread.

<Listing number="16-1" file-name="src/main.rs" caption="Criando uma nova thread para imprimir algo enquanto a thread principal imprime outra coisa">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-01/src/main.rs}}
```

</Listing>

Observe que quando o thread principal de um programa Rust for concluído, todos os threads gerados
são desligados, tenham ou não terminado a execução. A saída deste
programa pode ser um pouco diferente a cada vez, mas será semelhante ao
seguinte:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
hi number 1 from the main thread!
hi number 1 from the spawned thread!
hi number 2 from the main thread!
hi number 2 from the spawned thread!
hi number 3 from the main thread!
hi number 3 from the spawned thread!
hi number 4 from the main thread!
hi number 4 from the spawned thread!
hi number 5 from the spawned thread!
```

As chamadas para `thread::sleep` forçam um thread a interromper sua execução por um breve período.
duração, permitindo que um thread diferente seja executado. O threads provavelmente levará
gira, mas isso não é garantido: depende de como o seu sistema operacional
agenda o threads. Nesta execução, o thread principal foi impresso primeiro, embora
a instrução print do thread gerado aparece primeiro no código. E mesmo
embora tenhamos dito ao thread gerado para imprimir até que `i` seja `9`, ele só chegou a ` 5`
antes que o thread principal seja desligado.

Se você executar este código e ver apenas a saída do thread principal ou não ver nenhum
sobreposição, tente aumentar os números nos intervalos para criar mais oportunidades
para o sistema operacional alternar entre o threads.

<!-- Old headings. Do not remove or links may break. -->

<a id="waiting-for-all-threads-to-finish-using-join-handles"></a>

### Esperando que todos os threads terminem

O código na Listagem 16-1 não apenas interrompe o thread gerado prematuramente na maior parte
o tempo devido ao término principal do thread, mas porque não há garantia de
a ordem em que o threads é executado, também não podemos garantir que o thread gerado
vai começar a correr!

Podemos corrigir o problema do thread gerado não funcionar ou terminar
prematuramente salvando o valor de retorno de `thread::spawn` em uma variável. O
o tipo de retorno de `thread::spawn` é `JoinHandle<T>`. Um ` JoinHandle<T>`é um
valor de ownership que, quando chamarmos o método ` join`nele, aguardará seu
thread para finalizar. A Listagem 16-2 mostra como usar o ` JoinHandle<T>`do
thread que criamos na Listagem 16-1 e como chamar ` join`para garantir que o
thread gerado termina antes de ` main`sair.

<Listing number="16-2" file-name="src/main.rs" caption="Salvando um `JoinHandle<T>` retornado por `thread::spawn` para garantir que a thread execute até o fim">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-02/src/main.rs}}
```

</Listing>

Chamar `join` no identificador bloqueia o thread atualmente em execução até que o
thread representado pelo identificador termina. _Bloquear_ um thread significa que
thread é impedido de realizar trabalho ou sair. Porque nós colocamos a chamada
para `join` após o loop `for` do thread principal, a execução da Listagem 16-2 deve
produza uma saída semelhante a esta:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
hi number 1 from the main thread!
hi number 2 from the main thread!
hi number 1 from the spawned thread!
hi number 3 from the main thread!
hi number 2 from the spawned thread!
hi number 4 from the main thread!
hi number 3 from the spawned thread!
hi number 4 from the spawned thread!
hi number 5 from the spawned thread!
hi number 6 from the spawned thread!
hi number 7 from the spawned thread!
hi number 8 from the spawned thread!
hi number 9 from the spawned thread!
```

Os dois threads continuam alternando, mas o thread principal espera por causa do
chamada para `handle.join()` e não termina até que o thread gerado seja concluído.

Mas vamos ver o que acontece quando movemos `handle.join()` antes do
Loop `for` em `main`, assim:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/no-listing-01-join-too-early/src/main.rs}}
```

</Listing>

O thread principal aguardará o thread gerado terminar e então executará seu
Loop `for`, então a saída não será mais intercalada, conforme mostrado aqui:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
hi number 1 from the spawned thread!
hi number 2 from the spawned thread!
hi number 3 from the spawned thread!
hi number 4 from the spawned thread!
hi number 5 from the spawned thread!
hi number 6 from the spawned thread!
hi number 7 from the spawned thread!
hi number 8 from the spawned thread!
hi number 9 from the spawned thread!
hi number 1 from the main thread!
hi number 2 from the main thread!
hi number 3 from the main thread!
hi number 4 from the main thread!
```

Pequenos detalhes, como onde `join` é chamado, podem afetar se o seu
threads é executado ao mesmo tempo.

### Usando fechamentos `move` com threads

Freqüentemente usaremos a palavra-chave `move` com closures passado para `thread::spawn`
porque o closure pegará ownership dos valores que usa do
ambiente, transferindo assim ownership desses valores de um thread para
outro. Em [“Capturando referências ou movendo ownership”][capture]<!-- ignore
--> no Capítulo 13, discutimos ` move`no contexto de closures. Agora vamos
concentre-se mais na interação entre ` move`e ` thread::spawn`.

Observe na Listagem 16-1 que o closure que passamos para `thread::spawn` não leva
argumentos: não estamos usando nenhum dado do thread principal no gerado
Código de thread. Para usar dados do thread principal no thread gerado, o
O closure do thread gerado deve capturar os valores necessários. Listagem 16-3 programas
uma tentativa de criar um vetor no thread principal e usá-lo no gerado
thread. No entanto, isso ainda não funcionará, como você verá em breve.

<Listing number="16-3" file-name="src/main.rs" caption="Tentando usar em outra thread um vetor criado pela thread principal">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-03/src/main.rs}}
```

</Listing>

O closure usa `v`, então ele irá capturar ` v`e torná-lo parte do closure
ambiente. Como ` thread::spawn`executa este closure em um novo thread, nós
deve ser capaz de acessar ` v`dentro desse novo thread. Mas quando compilamos isso
exemplo, obtemos o seguinte erro:

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-03/output.txt}}
```

Rust _infere_ como capturar `v` e porque `println!` só precisa de uma referência
para `v`, o closure tenta emprestar ` v`. No entanto, há um problema: Rust não pode
dizer por quanto tempo o thread gerado será executado, para que ele não saiba se o
referência a ` v`será sempre válida.

A Listagem 16-4 fornece um cenário com maior probabilidade de ter uma referência a `v`
isso não será válido.

<Listing number="16-4" file-name="src/main.rs" caption="Uma thread com uma closure que tenta capturar uma referência a `v` de uma thread principal que faz `drop` de `v`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-04/src/main.rs}}
```

</Listing>

Se Rust nos permitiu executar este código, existe a possibilidade de que o código gerado
thread seria imediatamente colocado em segundo plano, sem ser executado. O
gerado thread tem uma referência a `v` dentro, mas o thread principal imediatamente
descarta `v`, usando a função ` drop`que discutimos no Capítulo 15. Então, quando o
thread gerado começa a ser executado, ` v`não é mais válido, portanto, uma referência a ele
também é inválido. Oh não!

Para corrigir o erro do compilador na Listagem 16-3, podemos usar a mensagem de erro
conselho:

<!-- manual-regeneration
after automatic regeneration, look at listings/ch16-fearless-concurrency/listing-16-03/output.txt and copy the relevant part
-->

```text
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ++++
```

Ao adicionar a palavra-chave `move` antes do closure, forçamos o closure a tomar
ownership dos valores que está usando, em vez de permitir que Rust infira que
deveria emprestar os valores. A modificação na Listagem 16-3 mostrada na Listagem
16-5 será compilado e executado conforme pretendido.

<Listing number="16-5" file-name="src/main.rs" caption="Usando a palavra-chave `move` para forçar uma closure a tomar ownership dos valores que utiliza">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-05/src/main.rs}}
```

</Listing>

Poderíamos ficar tentados a tentar a mesma coisa para corrigir o código da Listagem 16-4, onde
o thread principal chamado `drop` usando um `move` closure. No entanto, esta correção irá
não funciona porque o que a Listagem 16-4 está tentando fazer não é permitido por um
motivo diferente. Se adicionarmos `move` ao closure, moveríamos `v` para o
ambiente closure, e não podíamos mais chamar `drop` nele no principal
thread. Em vez disso, receberíamos este erro do compilador:

```console
{{#include ../listings/ch16-fearless-concurrency/output-only-01-move-drop/output.txt}}
```

As regras ownership do Rust nos salvaram novamente! Recebemos um erro no código em
Listagem 16-3 porque Rust estava sendo conservador e apenas borrowing `v` para o
thread, o que significava que o thread principal poderia teoricamente invalidar o gerado
Referência do thread. Dizendo ao Rust para mover o ownership do `v` para o gerado
thread, estamos garantindo ao Rust que o thread principal não usará mais o `v`.
Se alterarmos a Listagem 16-4 da mesma maneira, estaremos violando o ownership
regras quando tentamos usar ` v`no thread principal. A palavra-chave ` move`substitui
Padrão conservador de Rust de borrowing; não nos permite violar o
Regras ownership.

Agora que cobrimos o que são threads e os métodos fornecidos pelo thread
API, vejamos algumas situações em que podemos usar threads.

[capture]: ch13-01-closures.html#capturing-references-or-moving-ownership
