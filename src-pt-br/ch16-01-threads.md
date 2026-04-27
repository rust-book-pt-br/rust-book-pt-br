## Usando Threads para Executar Código Simultaneamente

Na maioria dos sistemas operacionais atuais, o código de um programa em
execução roda em um _processo_, e o sistema operacional gerencia vários
processos ao mesmo tempo. Dentro de um programa, você também pode ter partes
independentes que rodam simultaneamente. Os recursos que executam essas partes
independentes são chamados de _threads_. Por exemplo, um servidor web poderia
ter várias threads para responder a mais de uma requisição ao mesmo tempo.

Dividir a computação do seu programa em várias threads para executar várias
tarefas ao mesmo tempo pode melhorar o desempenho, mas também adiciona
complexidade. Como threads podem rodar simultaneamente, não há garantia
inerente sobre a ordem em que partes do seu código em diferentes threads serão
executadas. Isso pode levar a problemas como:

- Condições de corrida, em que threads acessam dados ou recursos em uma ordem
  inconsistente
- Deadlocks, em que duas threads ficam esperando uma pela outra, impedindo que
  ambas continuem
- Bugs que acontecem apenas em determinadas situações e são difíceis de
  reproduzir e corrigir de forma confiável

Rust tenta mitigar os efeitos negativos do uso de threads, mas programar em um
contexto multithread ainda exige reflexão cuidadosa e requer uma estrutura de
código diferente daquela usada em programas que rodam em uma única thread.

Linguagens de programação implementam threads de algumas maneiras diferentes, e
muitos sistemas operacionais fornecem uma API que a linguagem de programação
pode chamar para criar novas threads. A biblioteca padrão de Rust usa um modelo
de implementação de threads _1:1_, em que um programa usa uma thread do sistema
operacional para cada thread da linguagem. Existem crates que implementam
outros modelos de threading, com trade-offs diferentes em relação ao modelo
1:1. (O sistema async de Rust, que veremos no próximo capítulo, também fornece
outra abordagem para concorrência.)

### Criando uma Nova Thread com `spawn`

Para criar uma nova thread, chamamos a função `thread::spawn` e passamos a ela
uma closure (falamos sobre closures no Capítulo 13) contendo o código que
queremos executar na nova thread. O exemplo da Listagem 16-1 imprime algum
texto de uma thread principal e outro texto de uma nova thread.

<Listing number="16-1" file-name="src/main.rs" caption="Criando uma nova thread para imprimir uma coisa enquanto a thread principal imprime outra">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-01/src/main.rs}}
```

</Listing>

Observe que, quando a thread principal de um programa Rust termina, todas as
threads geradas são encerradas, tenham ou não terminado sua execução. A saída
desse programa pode ser um pouco diferente a cada vez, mas será parecida com a
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

As chamadas a `thread::sleep` forçam uma thread a interromper sua execução por
um curto período, permitindo que outra thread rode. As threads provavelmente se
alternarão, mas isso não é garantido: depende de como o sistema operacional
agenda as threads. Nesta execução, a thread principal imprimiu primeiro, embora
a instrução de impressão da thread gerada apareça primeiro no código. E, embora
tenhamos dito à thread gerada para imprimir até que `i` fosse `9`, ela só
chegou a `5` antes de a thread principal ser encerrada.

Se você executar esse código e vir apenas a saída da thread principal, ou não
vir nenhuma sobreposição, tente aumentar os números nos intervalos para criar
mais oportunidades para o sistema operacional alternar entre as threads.

<!-- Old headings. Do not remove or links may break. -->

<a id="waiting-for-all-threads-to-finish-using-join-handles"></a>

### Esperando Todas as Threads Terminarem

O código da Listagem 16-1 não apenas interrompe a thread gerada prematuramente
na maior parte do tempo por causa do término da thread principal, mas, como não
há garantia sobre a ordem em que as threads rodam, também não podemos garantir
que a thread gerada chegará a rodar!

Podemos corrigir o problema da thread gerada não rodar ou terminar
prematuramente salvando o valor de retorno de `thread::spawn` em uma variável.
O tipo de retorno de `thread::spawn` é `JoinHandle<T>`. Um `JoinHandle<T>` é um
valor com ownership que, quando chamamos o método `join` nele, espera sua
thread terminar. A Listagem 16-2 mostra como usar o `JoinHandle<T>` da thread
que criamos na Listagem 16-1 e como chamar `join` para garantir que a thread
gerada termine antes de `main` sair.

<Listing number="16-2" file-name="src/main.rs" caption="Salvando um `JoinHandle<T>` retornado por `thread::spawn` para garantir que a thread execute até o fim">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-02/src/main.rs}}
```

</Listing>

Chamar `join` no handle bloqueia a thread atualmente em execução até que a
thread representada pelo handle termine. _Bloquear_ uma thread significa que
ela fica impedida de realizar trabalho ou sair. Como colocamos a chamada a
`join` depois do loop `for` da thread principal, executar a Listagem 16-2 deve
produzir uma saída parecida com esta:

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

As duas threads continuam alternando, mas a thread principal espera por causa
da chamada a `handle.join()` e não termina até que a thread gerada tenha
terminado.

Mas vamos ver o que acontece quando movemos `handle.join()` para antes do loop
`for` em `main`, assim:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/no-listing-01-join-too-early/src/main.rs}}
```

</Listing>

A thread principal aguardará a thread gerada terminar e então executará seu
loop `for`, de modo que a saída não será mais intercalada, como mostrado aqui:

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

Pequenos detalhes, como onde `join` é chamado, podem afetar se suas threads
rodam ou não ao mesmo tempo.

### Usando Closures `move` com Threads

Frequentemente usaremos a palavra-chave `move` com closures passadas para
`thread::spawn`, porque a closure então tomará ownership dos valores que usa do
ambiente, transferindo o ownership desses valores de uma thread para outra. Em
[“Capturando Referências ou Movendo Ownership”][capture]<!-- ignore --> no
Capítulo 13, discutimos `move` no contexto de closures. Agora vamos nos
concentrar mais na interação entre `move` e `thread::spawn`.

Observe na Listagem 16-1 que a closure que passamos para `thread::spawn` não
recebe argumentos: não estamos usando nenhum dado da thread principal no código
da thread gerada. Para usar dados da thread principal na thread gerada, a
closure da thread gerada deve capturar os valores de que precisa. A Listagem
16-3 mostra uma tentativa de criar um vetor na thread principal e usá-lo na
thread gerada. No entanto, isso ainda não funcionará, como você verá em breve.

<Listing number="16-3" file-name="src/main.rs" caption="Tentando usar em outra thread um vetor criado pela thread principal">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-03/src/main.rs}}
```

</Listing>

A closure usa `v`, então ela capturará `v` e o tornará parte do ambiente da
closure. Como `thread::spawn` executa essa closure em uma nova thread, deveríamos
conseguir acessar `v` dentro dessa nova thread. Mas, quando compilamos esse
exemplo, recebemos o seguinte erro:

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-03/output.txt}}
```

Rust _infere_ como capturar `v` e, como `println!` precisa apenas de uma
referência para `v`, a closure tenta pegar `v` emprestado. No entanto, há um
problema: Rust não consegue dizer por quanto tempo a thread gerada será
executada, então não sabe se a referência para `v` sempre será válida.

A Listagem 16-4 apresenta um cenário em que é mais provável que uma referência
para `v` não seja válida.

<Listing number="16-4" file-name="src/main.rs" caption="Uma thread com uma closure que tenta capturar uma referência a `v` de uma thread principal que faz `drop` de `v`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-04/src/main.rs}}
```

</Listing>

Se Rust nos permitisse executar esse código, haveria a possibilidade de a
thread gerada ser colocada imediatamente em segundo plano sem rodar. A thread
gerada tem uma referência para `v` dentro dela, mas a thread principal descarta
`v` imediatamente usando a função `drop` que discutimos no Capítulo 15. Então,
quando a thread gerada começasse a executar, `v` não seria mais válido, de modo
que uma referência a ele também seria inválida. Ah, não!

Para corrigir o erro do compilador na Listagem 16-3, podemos usar o conselho da
mensagem de erro:

<!-- manual-regeneration
after automatic regeneration, look at listings/ch16-fearless-concurrency/listing-16-03/output.txt and copy the relevant part
-->

```text
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ++++
```

Ao adicionar a palavra-chave `move` antes da closure, forçamos a closure a
tomar ownership dos valores que está usando, em vez de permitir que Rust infira
que ela deve pegar os valores emprestados. A modificação da Listagem 16-3
mostrada na Listagem 16-5 compilará e rodará como pretendemos.

<Listing number="16-5" file-name="src/main.rs" caption="Usando a palavra-chave `move` para forçar uma closure a tomar ownership dos valores que utiliza">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-05/src/main.rs}}
```

</Listing>

Poderíamos ficar tentados a tentar a mesma coisa para corrigir o código da
Listagem 16-4, em que a thread principal chamou `drop`, usando uma closure
`move`. No entanto, essa correção não funcionará, porque o que a Listagem 16-4
está tentando fazer é proibido por outro motivo. Se adicionássemos `move` à
closure, moveríamos `v` para o ambiente da closure e não poderíamos mais chamar
`drop` nele na thread principal. Em vez disso, receberíamos este erro do
compilador:

```console
{{#include ../listings/ch16-fearless-concurrency/output-only-01-move-drop/output.txt}}
```

As regras de ownership de Rust nos salvaram novamente! Recebemos um erro no
código da Listagem 16-3 porque Rust estava sendo conservador e apenas pegando
`v` emprestado para a thread, o que significava que a thread principal poderia,
em teoria, invalidar a referência da thread gerada. Ao dizer a Rust para mover
o ownership de `v` para a thread gerada, garantimos a Rust que a thread
principal não usará mais `v`. Se alterarmos a Listagem 16-4 da mesma forma,
violaremos as regras de ownership ao tentar usar `v` na thread principal. A
palavra-chave `move` substitui o padrão conservador de Rust de pegar emprestado;
ela não nos permite violar as regras de ownership.

Agora que cobrimos o que são threads e os métodos fornecidos pela API de
threads, vejamos algumas situações em que podemos usar threads.

[capture]: ch13-01-closures.html#capturing-references-or-moving-ownership
