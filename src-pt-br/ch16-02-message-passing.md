<!-- Old headings. Do not remove or links may break. -->

<a id="using-message-passing-to-transfer-data-between-threads"></a>

## Transferindo Dados Entre Threads com Passagem de Mensagens

Uma abordagem cada vez mais popular para garantir concorrência segura é a
passagem de mensagens, em que threads ou atores se comunicam enviando mensagens
contendo dados uns aos outros. Aqui está a ideia em um slogan da [documentação
da linguagem Go](https://golang.org/doc/effective_go.html#concurrency): “Não
se comunique compartilhando memória; em vez disso, compartilhe memória se
comunicando.”

Para realizar concorrência por passagem de mensagens, a biblioteca padrão de Rust
fornece uma implementação de canais. Um _canal_ é um conceito geral de
programação pelo qual dados são enviados de uma thread para outra.

Você pode imaginar um canal em programação como um canal direcional de água,
como um riacho ou um rio. Se você colocar algo como um pato de borracha em um
rio, ele viajará rio abaixo até o fim do curso d'água.

Um canal tem duas metades: um transmissor e um receptor. A metade transmissora
é o local rio acima onde você coloca o pato de borracha no rio, e a metade
receptora é onde o pato de borracha chega rio abaixo. Uma parte do seu código
chama métodos no transmissor com os dados que você quer enviar, e outra parte
verifica a extremidade receptora em busca de mensagens que chegam. Dizemos que
um canal está _fechado_ se a metade transmissora ou a metade receptora for
descartada.

Aqui, construiremos gradualmente um programa que tem uma thread para gerar
valores e enviá-los por um canal, e outra thread que receberá os valores e os
imprimirá. Enviaremos valores simples entre threads usando um canal para
ilustrar o recurso. Depois que você estiver familiarizado com a técnica, poderá
usar canais para quaisquer threads que precisem se comunicar entre si, como um
sistema de chat ou um sistema em que muitas threads executam partes de um
cálculo e enviam as partes para uma thread que agrega os resultados.

Primeiro, na Listagem 16-6, criaremos um canal, mas não faremos nada com ele.
Observe que isso ainda não compila, porque Rust não consegue dizer que tipo de
valores queremos enviar pelo canal.

<Listing number="16-6" file-name="src/main.rs" caption="Criando um canal e atribuindo suas duas metades a `tx` e `rx`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-06/src/main.rs}}
```

</Listing>

Criamos um novo canal usando a função `mpsc::channel`; `mpsc` significa
_multiple producer, single consumer_ (_múltiplos produtores, consumidor único_).
Em resumo, a forma como a biblioteca padrão de Rust implementa canais significa
que um canal pode ter várias extremidades de _envio_ que produzem valores, mas
apenas uma extremidade de _recebimento_ que consome esses valores. Imagine
vários riachos fluindo juntos para um grande rio: tudo que for enviado por
qualquer um dos riachos terminará em um único rio no final. Começaremos com um
único produtor por enquanto, mas adicionaremos múltiplos produtores quando este
exemplo estiver funcionando.

A função `mpsc::channel` retorna uma tupla, cujo primeiro elemento é a
extremidade de envio, o transmissor, e cujo segundo elemento é a extremidade de
recebimento, o receptor. As abreviações `tx` e `rx` são tradicionalmente usadas
em muitos campos para _transmitter_ e _receiver_, respectivamente, então damos
esses nomes às variáveis para indicar cada extremidade. Estamos usando uma
instrução `let` com um padrão que desestrutura a tupla; discutiremos o uso de
padrões em instruções `let` e desestruturação no Capítulo 19. Por enquanto,
saiba que usar uma instrução `let` dessa forma é uma abordagem conveniente para
extrair as partes da tupla retornada por `mpsc::channel`.

Vamos mover a extremidade transmissora para uma thread gerada e fazer com que
ela envie uma string, para que a thread gerada se comunique com a thread
principal, como mostrado na Listagem 16-7. Isso é como colocar um pato de
borracha no rio, rio acima, ou enviar uma mensagem de chat de uma thread para
outra.

<Listing number="16-7" file-name="src/main.rs" caption='Movendo `tx` para uma thread gerada e enviando `"hi"`'>

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-07/src/main.rs}}
```

</Listing>

Novamente, usamos `thread::spawn` para criar uma nova thread e depois usamos
`move` para mover `tx` para a closure, de modo que a thread gerada tenha
ownership de `tx`. A thread gerada precisa ter ownership do transmissor para
poder enviar mensagens pelo canal.

O transmissor tem um método `send` que recebe o valor que queremos enviar. O
método `send` retorna um tipo `Result<T, E>`, então, se o receptor já tiver
sido descartado e não houver para onde enviar um valor, a operação de envio
retornará um erro. Neste exemplo, chamamos `unwrap` para entrar em pânico em
caso de erro. Mas, em uma aplicação real, trataríamos isso corretamente: volte
ao Capítulo 9 para revisar estratégias de tratamento de erros adequado.

Na Listagem 16-8, obteremos o valor do receptor na thread principal. Isso é
como recuperar o pato de borracha da água no fim do rio ou receber uma mensagem
de chat.

<Listing number="16-8" file-name="src/main.rs" caption='Recebendo o valor `"hi"` na thread principal e imprimindo-o'>

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-08/src/main.rs}}
```

</Listing>

O receptor tem dois métodos úteis: `recv` e `try_recv`. Estamos usando `recv`,
abreviação de _receive_, que bloqueará a execução da thread principal e
aguardará até que um valor seja enviado pelo canal. Assim que um valor for
enviado, `recv` o retornará em um `Result<T, E>`. Quando o transmissor for
fechado, `recv` retornará um erro para sinalizar que nenhum outro valor virá.

O método `try_recv` não bloqueia; em vez disso, retorna imediatamente um
`Result<T, E>`: um valor `Ok` contendo uma mensagem, se houver alguma
disponível, e um valor `Err` se não houver nenhuma mensagem nesse momento. Usar
`try_recv` é útil se essa thread tiver outro trabalho a fazer enquanto espera
por mensagens: poderíamos escrever um loop que chama `try_recv` de vez em
quando, trata uma mensagem se houver uma disponível e, caso contrário, faz
outro trabalho por um tempo até verificar novamente.

Usamos `recv` neste exemplo por simplicidade; não temos nenhum outro trabalho
para a thread principal fazer além de esperar por mensagens, então bloquear a
thread principal é apropriado.

Quando executarmos o código da Listagem 16-8, veremos o valor impresso pela
thread principal:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
Got: hi
```

Perfeito!

<!-- Old headings. Do not remove or links may break. -->

<a id="channels-and-ownership-transference"></a>

### Transferindo Ownership por Meio de Canais

As regras de ownership desempenham um papel vital no envio de mensagens porque
ajudam você a escrever código concorrente seguro. Prevenir erros em programação
concorrente é a vantagem de pensar em ownership em todos os seus programas
Rust. Vamos fazer um experimento para mostrar como canais e ownership trabalham
juntos para evitar problemas: tentaremos usar um valor `val` na thread gerada
_depois_ de enviá-lo pelo canal. Tente compilar o código da Listagem 16-9 para
ver por que esse código não é permitido.

<Listing number="16-9" file-name="src/main.rs" caption="Tentando usar `val` depois de enviá-lo pelo canal">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-09/src/main.rs}}
```

</Listing>

Aqui, tentamos imprimir `val` depois de enviá-lo pelo canal via `tx.send`.
Permitir isso seria uma má ideia: depois que o valor foi enviado para outra
thread, essa thread poderia modificá-lo ou descartá-lo antes de tentarmos usar
o valor novamente. Potencialmente, as modificações da outra thread poderiam
causar erros ou resultados inesperados por causa de dados inconsistentes ou
inexistentes. No entanto, Rust nos dá um erro se tentarmos compilar o código da
Listagem 16-9:

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-09/output.txt}}
```

Nosso erro de concorrência causou um erro em tempo de compilação. A função
`send` toma ownership de seu parâmetro e, quando o valor é movido, o receptor
assume ownership dele. Isso nos impede de usar acidentalmente o valor novamente
depois de enviá-lo; o sistema de ownership verifica se está tudo certo.

<!-- Old headings. Do not remove or links may break. -->

<a id="sending-multiple-values-and-seeing-the-receiver-waiting"></a>

### Enviando Vários Valores

O código da Listagem 16-8 compilou e rodou, mas não nos mostrou claramente que
duas threads separadas estavam conversando entre si pelo canal.

Na Listagem 16-10, fizemos algumas modificações que deixarão claro que o código
da Listagem 16-8 está rodando concorrentemente: a thread gerada agora enviará
várias mensagens e fará uma pausa de um segundo entre cada mensagem.

<Listing number="16-10" file-name="src/main.rs" caption="Enviando várias mensagens e pausando entre cada uma">

```rust,noplayground
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-10/src/main.rs}}
```

</Listing>

Desta vez, a thread gerada tem um vetor de strings que queremos enviar para a
thread principal. Iteramos sobre elas, enviando cada uma individualmente, e
pausamos entre cada envio chamando a função `thread::sleep` com um valor
`Duration` de um segundo.

Na thread principal, não chamamos mais a função `recv` explicitamente. Em vez
disso, tratamos `rx` como um iterador. Para cada valor recebido, imprimimos
esse valor. Quando o canal for fechado, a iteração terminará.

Ao executar o código da Listagem 16-10, você deve ver a seguinte saída com uma
pausa de um segundo entre cada linha:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
Got: hi
Got: from
Got: the
Got: thread
```

Como não temos nenhum código que pause ou atrase o loop `for` na thread
principal, podemos perceber que a thread principal está esperando para receber
valores da thread gerada.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-multiple-producers-by-cloning-the-transmitter"></a>

### Criando Múltiplos Produtores

Mencionamos anteriormente que `mpsc` é um acrônimo para _multiple producer,
single consumer_. Vamos colocar `mpsc` em uso e expandir o código da Listagem
16-10 para criar múltiplas threads que enviam valores para o mesmo receptor.
Podemos fazer isso clonando o transmissor, como mostrado na Listagem 16-11.

<Listing number="16-11" file-name="src/main.rs" caption="Enviando várias mensagens a partir de múltiplos produtores">

```rust,noplayground
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-11/src/main.rs:here}}
```

</Listing>

Desta vez, antes de criarmos a primeira thread gerada, chamamos `clone` no
transmissor. Isso nos dará um novo transmissor que podemos passar para a
primeira thread gerada. Passamos o transmissor original para uma segunda thread
gerada. Isso nos dá duas threads, cada uma enviando mensagens diferentes para o
mesmo receptor.

Ao executar o código, sua saída deve se parecer com esta:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
Got: hi
Got: more
Got: from
Got: messages
Got: for
Got: the
Got: thread
Got: you
```

Você pode ver os valores em outra ordem, dependendo do seu sistema. Isso é o
que torna a concorrência interessante e também difícil. Se você experimentar
com `thread::sleep`, fornecendo valores variados nas diferentes threads, cada
execução será mais não determinística e produzirá uma saída diferente a cada
vez.

Agora que vimos como os canais funcionam, vamos ver outro método de
concorrência.
