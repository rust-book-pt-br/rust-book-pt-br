<!-- Old headings. Do not remove or links may break. -->

<a id="using-message-passing-to-transfer-data-between-threads"></a>

## Transferir dados entre threads com passagem de mensagens

Uma abordagem cada vez mais popular para garantir simultaneidade segura é a transmissão de mensagens.
passagem, onde threads ou atores se comunicam enviando mensagens uns aos outros
contendo dados. Aqui está a ideia em um slogan da [documentação da linguagem Go](https://golang.org/doc/effective_go.html#concurrency):
“Não comunique através da partilha de memória; em vez disso, partilhe a memória através da comunicação.”

Para realizar a simultaneidade de envio de mensagens, a biblioteca padrão do Rust fornece um
implementação de canais. Um _canal_ é um conceito geral de programação criado por
quais dados são enviados de um thread para outro.

Você pode imaginar um canal na programação como sendo um canal direcional de
água, como um stream ou um rio. Se você colocar algo como um pato de borracha
em um rio, ele viajará rio abaixo até o final do curso de água.

Um canal tem duas metades: um transmissor e um receptor. A metade do transmissor é
o local a montante onde você coloca o pato de borracha no rio, e o
A metade do receptor é onde o pato de borracha termina a jusante. Uma parte do seu
o código chama métodos no transmissor com os dados que você deseja enviar e
outra parte verifica a extremidade receptora para mensagens que chegam. Um canal é dito
para ser _fechado_ se a metade do transmissor ou do receptor cair.

Aqui, trabalharemos em um programa que possui um thread para gerar valores e
enviá-los por um canal, e outro thread que receberá os valores e
imprima-os. Estaremos enviando valores simples entre threads usando um canal
para ilustrar o recurso. Depois de estar familiarizado com a técnica, você poderá
use canais para qualquer threads que precise se comunicar entre si, como
um sistema de chat ou um sistema onde muitos threads realizam partes de um cálculo e
envie as peças para um thread que agrega os resultados.

Primeiro, na Listagem 16.6, criaremos um canal, mas não faremos nada com ele.
Observe que isso ainda não será compilado porque Rust não pode dizer que tipo de valores
deseja enviar pelo canal.

<Listing number="16-6" file-name="src/main.rs" caption="Criando um canal e atribuindo suas duas metades a `tx` e `rx`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-06/src/main.rs}}
```

</Listing>

Criamos um novo canal usando a função `mpsc::channel`; ` mpsc`significa
_múltiplo produtor, único consumidor_. Resumindo, a forma como a biblioteca padrão do Rust
implementa canais significa que um canal pode ter vários fins de _envio_ que
produzem valores, mas apenas uma extremidade _recetora_ que consome esses valores. Imagine
vários streams fluindo juntos em um grande rio: tudo enviado de qualquer maneira
do streams terminará em um rio no final. Começaremos com um único
produtor por enquanto, mas adicionaremos vários produtores quando tivermos este exemplo
trabalhando.

A função `mpsc::channel` retorna uma tupla, cujo primeiro elemento é o
extremidade emissora - o transmissor - e cujo segundo elemento é o receptor
fim – o receptor. As abreviaturas `tx` e `rx` são tradicionalmente usadas em
muitos campos para _transmissor_ e _receptor_, respectivamente, então nomeamos nosso
variáveis como tais para indicar cada extremidade. Estamos usando uma instrução `let` com um
padrão que desestrutura as tuplas; discutiremos o uso de padrões em
Instruções `let` e desestruturação no Capítulo 19. Por enquanto, saiba que usar um
A instrução `let` desta forma é uma abordagem conveniente para extrair as partes de
a tupla retornada por `mpsc::channel`.

Vamos mover a extremidade de transmissão para um thread gerado e fazer com que ele envie um
string para que o thread gerado esteja se comunicando com o thread principal, como
mostrado na Listagem 16-7. Isto é como colocar um pato de borracha rio acima
ou enviar uma mensagem de chat de um thread para outro.

<Listing number="16-7" file-name="src/main.rs" caption='Moving `tx` to a spawned thread and sending `"hi"` '>

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-07/src/main.rs}}
```

</Listing>

Novamente, estamos usando `thread::spawn` para criar um novo thread e depois usando `move`
para mover ` tx`para o closure para que o thread gerado possua ` tx`. O gerado
thread precisa possuir o transmissor para poder enviar mensagens através do
canal.

O transmissor possui um método `send` que pega o valor que queremos enviar. O
O método `send` retorna um tipo `Result<T, E>`, portanto, se o receptor já tiver
foi descartado e não há para onde enviar um valor, a operação de envio será
retornar um erro. Neste exemplo, estamos chamando ` unwrap`para panic no caso de um
erro. Mas em uma aplicação real, nós lidaríamos com isso corretamente: Voltar para
Capítulo 9 para revisar estratégias para tratamento adequado de erros.

Na Listagem 16-8, obteremos o valor do receptor no thread principal. Isto
é como resgatar o pato de borracha da água no final do rio ou
recebendo uma mensagem de bate-papo.

<Listing number="16-8" file-name="src/main.rs" caption='Receiving the value `"hi"` in the main thread and printing it'>

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-08/src/main.rs}}
```

</Listing>

O receptor possui dois métodos úteis: `recv` e `try_recv`. Estamos usando ` recv`,
abreviação de _receive_, que bloqueará a execução do thread principal e aguardará
até que um valor seja enviado pelo canal. Assim que um valor for enviado, ` recv`irá
retorne-o em um ` Result<T, E>`. Quando o transmissor fechar, ` recv`retornará
um erro para sinalizar que nenhum outro valor virá.

O método `try_recv` não bloqueia, mas retornará um `Result<T, E>`
imediatamente: um valor ` Ok`contendo uma mensagem, se houver alguma disponível, e um ` Err`
valor se não houver nenhuma mensagem desta vez. Usar ` try_recv`é útil se
este thread tem outro trabalho a fazer enquanto espera por mensagens: poderíamos escrever um
loop que chama ` try_recv`de vez em quando, trata uma mensagem se houver
disponível e, caso contrário, faz outro trabalho por um tempo até verificar
novamente.

Usamos `recv` neste exemplo para simplificar; não temos nenhum outro trabalho
para o thread principal fazer outra coisa além de esperar por mensagens, bloqueando assim o principal
thread é apropriado.

Quando executarmos o código da Listagem 16-8, veremos o valor impresso no valor principal
thread:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
changes in the compiler -->

```text
Got: hi
```

Perfeito!

<!-- Old headings. Do not remove or links may break. -->

<a id="channels-and-ownership-transference"></a>

### Transferência de ownership por meio de canais

As regras ownership desempenham um papel vital no envio de mensagens porque ajudam você
escrever código simultâneo e seguro. Prevenir erros na programação simultânea é o
vantagem de pensar no ownership em todos os seus programas Rust. Vamos fazer
um experimento para mostrar como os canais e o ownership funcionam juntos para evitar
problemas: tentaremos usar um valor `val` no thread gerado _depois_ de termos
enviou-o pelo canal. Tente compilar o código da Listagem 16-9 para ver por que
este código não é permitido.

<Listing number="16-9" file-name="src/main.rs" caption="Tentando usar `val` depois de enviá-lo pelo canal">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-09/src/main.rs}}
```

</Listing>

Aqui, tentamos imprimir `val` depois de enviá-lo pelo canal via `tx.send`.
Permitir isso seria uma má ideia: uma vez que o valor tenha sido enviado para outro
thread, que thread poderia modificá-lo ou eliminá-lo antes de tentarmos usar o valor
novamente. Potencialmente, as outras modificações do thread podem causar erros ou
resultados inesperados devido a dados inconsistentes ou inexistentes. No entanto, Rust fornece
geraremos um erro se tentarmos compilar o código da Listagem 16-9:

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-09/output.txt}}
```

Nosso erro de simultaneidade causou um erro em tempo de compilação. A função `send`
pega ownership de seu parâmetro, e quando o valor é movido o receptor
leva ownership dele. Isso nos impede de usar acidentalmente o valor novamente
após enviá-lo; o sistema ownership verifica se está tudo bem.

<!-- Old headings. Do not remove or links may break. -->

<a id="sending-multiple-values-and-seeing-the-receiver-waiting"></a>

### Enviando vários valores

O código na Listagem 16.8 foi compilado e executado, mas não nos mostrou claramente que
dois threads separados estavam conversando entre si pelo canal.

Na Listagem 16-10, fizemos algumas modificações que comprovarão o código em
A Listagem 16-8 está sendo executada simultaneamente: O thread gerado agora enviará vários
mensagens e faça uma pausa por um segundo entre cada mensagem.

<Listing number="16-10" file-name="src/main.rs" caption="Enviando várias mensagens e pausando entre cada uma">

```rust,noplayground
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-10/src/main.rs}}
```

</Listing>

Desta vez, o thread gerado tem um vetor de strings para o qual queremos enviar
o principal thread. Nós iteramos sobre eles, enviando cada um individualmente, e pausamos
entre cada um chamando a função `thread::sleep` com um valor `Duration` de
um segundo.

No thread principal, não chamamos mais a função `recv` explicitamente:
Em vez disso, estamos tratando `rx` como iterator. Para cada valor recebido, estamos
imprimindo-o. Quando o canal for fechado, a iteração terminará.

Ao executar o código na Listagem 16-10, você deverá ver a seguinte saída
com uma pausa de um segundo entre cada linha:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
changes in the compiler -->

```text
Got: hi
Got: from
Got: the
Got: thread
```

Como não temos nenhum código que pause ou atrase o loop `for` no
principal thread, podemos dizer que o thread principal está aguardando para receber valores de
o thread gerado.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-multiple-producers-by-cloning-the-transmitter"></a>

### Criando Vários Produtores

Mencionamos anteriormente que `mpsc` era um acrônimo para _produtor múltiplo, único
consumidor_. Vamos colocar `mpsc` em uso e expandir o código da Listagem 16-10 para
crie vários threads que enviem valores para o mesmo receptor. Nós podemos fazer isso
clonando o transmissor, conforme mostrado na Listagem 16-11.

<Listing number="16-11" file-name="src/main.rs" caption="Enviando várias mensagens a partir de múltiplos produtores">

```rust,noplayground
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-11/src/main.rs:here}}
```

</Listing>

Desta vez, antes de criarmos o primeiro thread gerado, chamamos `clone` no
transmissor. Isto nos dará um novo transmissor que poderemos passar para o primeiro
gerou thread. Passamos o transmissor original para um segundo thread gerado.
Isso nos dá dois threads, cada um enviando mensagens diferentes para um receptor.

Ao executar o código, sua saída deverá ser semelhante a esta:

<!-- Not extracting output because changes to this output aren't significant;
as mudanças provavelmente se devem ao fato de o threads funcionar de maneira diferente, em vez de
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

Você poderá ver os valores em outra ordem, dependendo do seu sistema. Isto é
o que torna a simultaneidade interessante e também difícil. Se você experimentar
`thread::sleep`, fornecendo vários valores nos diferentes threads, cada execução
será mais não determinístico e criará resultados diferentes a cada vez.

Agora que vimos como os canais funcionam, vamos ver um método diferente de
simultaneidade.
