<!-- Old headings. Do not remove or links may break. -->

<a id="turning-our-single-threaded-server-into-a-multithreaded-server"></a>
<a id="from-single-threaded-to-multithreaded-server"></a>

## De um Servidor Single-Threaded para um Servidor Multithreaded

Neste momento, o servidor processa cada requisição por vez, o que significa que
não processará uma segunda conexão até que o processamento da primeira termine.
Se o servidor recebesse cada vez mais requisições, essa execução em série se
mostraria cada vez menos adequada. Se o servidor receber uma requisição que
demora muito para ser processada, as requisições subsequentes terão de esperar
até que a requisição longa termine, mesmo que as novas requisições possam ser
processadas rapidamente. Precisaremos corrigir isso, mas primeiro veremos o
problema em ação.

<!-- Old headings. Do not remove or links may break. -->

<a id="simulating-a-slow-request-in-the-current-server-implementation"></a>

### Simulando uma requisição lenta

Veremos como uma requisição de processamento lento pode afetar outras
requisições feitas ao nosso servidor atual. A Listagem 21-10 implementa o
tratamento de uma requisição para _/sleep_ com uma resposta lenta simulada que fará o servidor dormir
por cinco segundos antes de responder.

<Listing number="21-10" file-name="src/main.rs" caption="Simulando uma requisição lenta ao dormir por cinco segundos">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-10/src/main.rs:here}}
```

</Listing>

Mudamos de `if` para `match` agora que temos três casos. Precisamos
fazer `match` explicitamente em um slice de `request_line` para comparar padrões com
valores literais de string; `match` não faz referência automática e
desreferenciação, como faz o método da igualdade.

O primeiro braço é igual ao bloco `if` da Listagem 21-9. O segundo braço
corresponde a uma requisição para _/sleep_. Quando essa requisição for recebida, o servidor
dormirá por cinco segundos antes de renderizar a página HTML bem-sucedida. O terceiro braço
é igual ao bloco `else` da Listagem 21-9.

Você pode ver o quão primitivo é o nosso servidor: bibliotecas reais lidariam com o
reconhecimento de múltiplas solicitações de uma forma muito menos detalhada!

Inicie o servidor usando `cargo run`. Em seguida, abra duas janelas do
navegador: uma para _http://127.0.0.1:7878_ e outra para
_http://127.0.0.1:7878/sleep_. Se você acessar o URI _/_ algumas vezes, como
antes, verá que ele responde rapidamente. Mas, se acessar _/sleep_ e depois
carregar _/_, verá que _/_ precisa esperar `sleep` completar os cinco segundos
antes de carregar.

Existem várias técnicas que podemos usar para evitar que uma requisição lenta
faça outras requisições se acumularem, incluindo o uso de async, como fizemos
no Capítulo 17; a que implementaremos aqui é um thread pool.

### Melhorando o rendimento com um pool de threads

Um _thread pool_ é um grupo de threads criadas que estão prontas e esperando
para lidar com uma tarefa. Quando o programa recebe uma nova tarefa, ele
atribui essa tarefa a uma das threads do pool, e essa thread a processa. As
threads restantes do pool ficam disponíveis para lidar com qualquer outra tarefa
que apareça enquanto a primeira thread está ocupada. Quando a primeira thread
termina de processar sua tarefa, ela volta ao conjunto de threads ociosas,
pronta para lidar com uma nova tarefa. Um thread pool permite processar conexões simultaneamente,
aumentando o rendimento do seu servidor.

Limitaremos o número de threads no pool a um número pequeno para nos proteger
de ataques DoS; se nosso programa criasse uma nova thread para cada requisição
conforme ela chegasse, alguém fazendo 10 milhões de requisições ao nosso
servidor poderia causar estragos, consumindo todos os recursos do servidor e
paralisando o processamento.

Em vez de criar threads ilimitadas, teremos um número fixo de threads
esperando no pool. As requisições que chegarem serão enviadas ao pool para
processamento. O pool manterá uma fila de requisições de entrada. Cada thread
do pool retirará uma requisição dessa fila, tratará a requisição e então
pedirá outra à fila. Com esse design, podemos processar até _`N`_
requisições simultaneamente, em que _`N`_ é o número de threads. Se cada
thread estiver respondendo a uma requisição longa, as requisições
subsequentes ainda poderão se acumular na fila, mas aumentamos o número de
requisições longas que conseguimos tratar antes de chegar a esse ponto.

Essa técnica é apenas uma das muitas formas de melhorar o throughput de um web
server. Outras opções que você pode explorar são o modelo fork/join, o modelo
de E/S async single-threaded e o modelo de E/S async multithreaded. Se você se
interessa por esse tema, pode ler mais sobre outras soluções e tentar
implementá-las; com uma linguagem de baixo nível como Rust, todas essas opções
são possíveis.

Antes de começarmos a implementar um thread pool, vamos falar sobre como seu uso
deve se parecer. Quando você está tentando projetar código, escrever primeiro a interface do
cliente pode ajudar a orientar o design. Escreva a API do código de modo que ela
fique estruturada da maneira como você deseja chamá-la; então, implemente a
funcionalidade dentro dessa estrutura, em vez de implementar a funcionalidade
e só depois projetar a API pública.

Semelhante à forma como usamos o desenvolvimento orientado a testes no projeto no Capítulo 12,
usaremos desenvolvimento orientado a compilador aqui. Escreveremos o código que chama o
funções que queremos e, em seguida, examinaremos os erros do compilador para determinar
o que devemos mudar a seguir para fazer o código funcionar. Antes de fazermos isso, no entanto,
exploraremos a técnica que não usaremos como ponto de partida.

<!-- Old headings. Do not remove or links may break. -->

<a id="code-structure-if-we-could-spawn-a-thread-for-each-request"></a>

#### Gerando uma Thread para Cada Requisição

Primeiro, vamos explorar como nosso código ficaria se ele criasse uma nova
thread para cada conexão. Como mencionado anteriormente, esse não é o plano
final por causa dos problemas de potencialmente criar um número ilimitado de
threads, mas é um bom ponto de partida para obter primeiro um servidor
multithreaded funcional. Depois, adicionaremos o thread pool como melhoria, e
contrastar as duas soluções ficará mais fácil.

A Listagem 21-11 mostra as alterações a serem feitas em `main` para gerar um novo thread para
lidar com cada stream dentro do loop `for`.

<Listing number="21-11" file-name="src/main.rs" caption="Criando uma nova thread para cada stream">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-11/src/main.rs:here}}
```

</Listing>

Como você aprendeu no Capítulo 16, `thread::spawn` criará um novo thread e então
execute o código no closure no novo thread. Se você executar este código e carregar
_/sleep_ no seu navegador, então _/_ em mais duas guias do navegador, você realmente verá
que as solicitações para _/_ não precisam esperar que _/sleep_ termine. No entanto, como
mencionamos, isso acabará sobrecarregando o sistema porque você estaria fazendo
novo threads sem qualquer limite.

Você também deve se lembrar do Capítulo 17 que este é exatamente o tipo de situação
onde async e await realmente brilham! Tenha isso em mente enquanto construímos o thread
pool e pense em como as coisas seriam diferentes ou iguais com async.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-a-similar-interface-for-a-finite-number-of-threads"></a>

#### Criando um Número Finito de Threads

Queremos que nosso thread pool funcione de maneira semelhante e familiar, para
que trocar threads por um thread pool não exija grandes alterações no código
que usa nossa API. A Listagem 21-12 mostra a interface hipotética da struct
`ThreadPool` que queremos usar no lugar de `thread::spawn`.

<Listing number="21-12" file-name="src/main.rs" caption="Nossa interface ideal para `ThreadPool`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch21-web-server/listing-21-12/src/main.rs:here}}
```

</Listing>

Usamos `ThreadPool::new` para criar um novo thread pool com um número
configurável de threads, neste caso quatro. Então, no loop `for`,
`pool.execute` tem uma interface semelhante à de `thread::spawn`, pois recebe
uma closure que o pool deve executar para cada stream. Precisamos implementar
`pool.execute` para que ele receba essa closure e a entregue a uma thread do
pool para execução. Esse código ainda não compila, mas vamos tentar
compilá-lo para que o compilador nos oriente sobre como corrigi-lo.

<!-- Old headings. Do not remove or links may break. -->

<a id="building-the-threadpool-struct-using-compiler-driven-development"></a>

#### Construindo `ThreadPool` usando desenvolvimento orientado a compilador

Faça as alterações na Listagem 21-12 em _src/main.rs_ e então vamos usar o
erros do compilador do `cargo check` para impulsionar nosso desenvolvimento. Aqui está o primeiro
erro que obtemos:

```console
{{#include ../listings/ch21-web-server/listing-21-12/output.txt}}
```

Ótimo! Esse erro nos diz que precisamos de um tipo ou módulo `ThreadPool`,
então vamos construí-lo agora. Nossa implementação de `ThreadPool` será
independente do tipo de trabalho que nosso web server está realizando. Então,
vamos transformar o crate `hello` de um crate binário em um crate de
biblioteca para armazenar nossa implementação de `ThreadPool`. Depois de
mudarmos para um crate de biblioteca, também poderíamos usar essa biblioteca de
thread pool separadamente para qualquer trabalho que quiséssemos fazer, não
apenas para atender requisições web.

Crie um arquivo _src/lib.rs_ que contenha o seguinte, que é o mais simples
definição de uma estrutura `ThreadPool` que podemos ter por enquanto:

<Listing file-name="src/lib.rs">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/no-listing-01-define-threadpool-struct/src/lib.rs}}
```

</Listing>


Em seguida, edite o arquivo _main.rs_ para trazer `ThreadPool` para o escopo da biblioteca
crate adicionando o seguinte código ao topo de _src/main.rs_:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch21-web-server/no-listing-01-define-threadpool-struct/src/main.rs:here}}
```

</Listing>

Este código ainda não funcionará, mas vamos verificá-lo novamente para obter o próximo erro que
precisamos abordar:

```console
{{#include ../listings/ch21-web-server/no-listing-01-define-threadpool-struct/output.txt}}
```

Esse erro indica que, agora, precisamos criar uma função associada chamada
`new` para `ThreadPool`. Também sabemos que `new` precisa ter um parâmetro que
aceite `4` como argumento e deve retornar uma instância de `ThreadPool`.
Vamos implementar a forma mais simples de `new` com essas características:

<Listing file-name="src/lib.rs">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/no-listing-02-impl-threadpool-new/src/lib.rs}}
```

</Listing>

Escolhemos `usize` como o tipo do parâmetro `size` porque sabemos que um
número negativo de threads não faz sentido. Também sabemos que usaremos esse
`4` como o número de elementos em uma coleção de threads, que é justamente
para isso que serve o tipo `usize`, conforme discutido na seção [“Tipos inteiros”][integer-types]<!--
ignore --> no Capítulo 3.

Vamos verificar o código novamente:

```console
{{#include ../listings/ch21-web-server/no-listing-02-impl-threadpool-new/output.txt}}
```

Agora o erro ocorre porque não temos um método `execute` em `ThreadPool`.
Lembre-se da seção [“Criando um Número Finito de
Threads”](#creating-a-finite-number-of-threads)<!-- ignore -->, em que
decidimos que nosso thread pool deveria ter uma interface semelhante à de
`thread::spawn`. Além disso, implementaremos a função `execute` para que ela
receba a closure fornecida e a entregue a uma thread ociosa no pool para ser
executada.

Definiremos o método `execute` em `ThreadPool` para receber uma closure como
parâmetro. Lembre-se da seção [“Movendo Valores Capturados para Fora de
Closures”][moving-out-of-closures]<!-- ignore -->, no Capítulo 13, em que vimos
que closures podem ser recebidas como parâmetros com três traits diferentes:
`Fn`, `FnMut` e `FnOnce`. Precisamos decidir qual tipo de closure usar aqui.
Sabemos que acabaremos fazendo algo semelhante à implementação de
`thread::spawn` da biblioteca padrão, então podemos observar quais limites a
assinatura de `thread::spawn` impõe ao seu parâmetro. A documentação nos mostra
o seguinte:

```rust,ignore
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
    where
        F: FnOnce() -> T,
        F: Send + 'static,
        T: Send + 'static,
```

O parâmetro de tipo `F` é o que nos interessa aqui; o parâmetro de tipo `T`
está relacionado ao valor de retorno, e isso não nos preocupa agora. Podemos
ver que `spawn` usa `FnOnce` como trait bound para `F`. Provavelmente isso
também é o que queremos, porque acabaremos passando o argumento recebido em
`execute` para `spawn`. Podemos ficar ainda mais confiantes de que `FnOnce` é
a trait certa porque a thread que executa uma requisição executará a closure
daquela requisição apenas uma vez, o que corresponde ao `Once` em `FnOnce`.

O parâmetro de tipo `F` também tem o trait bound `Send` e o lifetime bound
`'static`, que são úteis na nossa situação: precisamos de `Send` para
transferir a closure de uma thread para outra e de `'static` porque não sabemos
quanto tempo a thread levará para executá-la. Vamos criar um método `execute`
em `ThreadPool` que receba um parâmetro genérico do tipo `F` com esses
limites:

<Listing file-name="src/lib.rs">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/no-listing-03-define-execute/src/lib.rs:here}}
```

</Listing>

Ainda usamos `()` depois de `FnOnce` porque este `FnOnce` representa um closure
que não aceita parâmetros e retorna o tipo de unidade `()`. Assim como a função
definições, o tipo de retorno pode ser omitido da assinatura, mas mesmo se
não temos parâmetros, ainda precisamos dos parênteses.

Novamente, esta é a implementação mais simples do método `execute`: ela faz
nada, mas estamos apenas tentando compilar nosso código. Vamos verificar novamente:

```console
{{#include ../listings/ch21-web-server/no-listing-03-define-execute/output.txt}}
```

Ele compila! Mas observe que, se você tentar `cargo run` e fizer uma
requisição no navegador, verá os erros que vimos no início do capítulo. Nossa
biblioteca ainda não está realmente chamando a closure passada para `execute`!

> Nota: Um ditado que você pode ouvir sobre linguagens com compiladores estritos, como
> Haskell e Rust, é “Se o código compilar, ele funciona”. Mas esse ditado não é
> universalmente verdadeiro. Nosso projeto compila, mas não faz absolutamente nada! Se
> estivéssemos construindo um projeto real e completo, este seria um bom momento
> para começar a escrever testes unitários para verificar se o código compila _e_
> tem o comportamento que queremos.

Pense nisto: o que seria diferente aqui se fôssemos executar um future em vez
de uma closure?

#### Validando o número de threads em `new`

Não estamos fazendo nada com os parâmetros `new` e `execute`. Vamos
implementar o corpo dessas funções com o comportamento que desejamos. Para
começar, pensemos em `new`. Antes escolhemos um tipo não assinado para o
parâmetro `size` porque um pool com um número negativo de threads não faz
sentido. No entanto, um pool com zero threads também não faz sentido, e zero é
um valor perfeitamente válido para `usize`. Vamos adicionar código para
verificar se `size` é maior que zero antes de retornar uma instância de
`ThreadPool`, e faremos o programa entrar em `panic` se receber zero, usando a
macro `assert!`, como mostra a Listagem 21-13.

<Listing number="21-13" file-name="src/lib.rs" caption="Implementando `ThreadPool::new` para gerar panic se `size` for zero">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-13/src/lib.rs:here}}
```

</Listing>

Também adicionamos alguma documentação para nosso `ThreadPool` com comentários de documentos.
Observe que seguimos boas práticas de documentação adicionando uma seção que
chama as situações em que nossa função pode panic, conforme discutido em
Capítulo 14. Tente executar `cargo doc --open` e clicar na estrutura `ThreadPool`
para ver como são os documentos gerados para ` new`!

Em vez de adicionar a macro `assert!` como fizemos aqui, poderíamos transformar
`new` em `build` e retornar um `Result`, como fizemos com `Config::build` no
projeto de I/O da Listagem 12-9. Mas decidimos que, neste caso, tentar criar um
thread pool sem nenhuma thread deve ser um erro irrecuperável. Se você estiver
se sentindo ambicioso, tente escrever uma função chamada `build` com a
seguinte assinatura para compará-la com a função `new`:

```rust,ignore
pub fn build(size: usize) -> Result<ThreadPool, PoolCreationError> {
```

#### Criando espaço para armazenar os threads

Agora que temos uma forma de garantir que há um número válido de threads para
armazenar no pool, podemos criá-las e guardá-las na struct `ThreadPool` antes
de retorná-la. Mas como “armazenamos” uma thread? Vamos olhar novamente para a
assinatura de `thread::spawn`:

```rust,ignore
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
    where
        F: FnOnce() -> T,
        F: Send + 'static,
        T: Send + 'static,
```

A função `spawn` retorna um `JoinHandle<T>`, em que `T` é o tipo retornado pela
closure. Vamos tentar usar `JoinHandle` também e ver o que acontece. No nosso
caso, a closure que estamos passando para o thread pool cuidará da conexão e
não retornará nada, então `T` será o tipo unitário `()`.

O código da Listagem 21-14 compilará, mas ainda não criará nenhuma thread.
Mudamos a definição de `ThreadPool` para conter um vetor de instâncias
`thread::JoinHandle<()>`, inicializamos esse vetor com capacidade `size`,
configuramos um loop `for` que executará algum código para criar as threads e,
por fim, retornamos uma instância de `ThreadPool` contendo-as.

<Listing number="21-14" file-name="src/lib.rs" caption="Criando um vetor para `ThreadPool` armazenar as threads">

```rust,ignore,not_desired_behavior
{{#rustdoc_include ../listings/ch21-web-server/listing-21-14/src/lib.rs:here}}
```

</Listing>

Colocamos `std::thread` no escopo da biblioteca crate porque estamos
usando `thread::JoinHandle` como o tipo dos itens no vetor em
`ThreadPool`.

Assim que recebe um tamanho válido, nosso `ThreadPool` cria um novo vetor capaz
de armazenar `size` itens. A função `with_capacity` realiza a mesma tarefa que
`Vec::new`, mas com uma diferença importante: ela pré-aloca espaço no vetor.
Como sabemos que precisaremos armazenar `size` elementos, fazer essa alocação
inicial é um pouco mais eficiente do que usar `Vec::new`, que se redimensiona à
medida que elementos são inseridos.

Quando você executar `cargo check` novamente, ele deverá ter sucesso.

<!-- Old headings. Do not remove or links may break. -->
<a id ="a-worker-struct-responsible-for-sending-code-from-the-threadpool-to-a-thread"></a>

#### Enviando código do `ThreadPool` para um thread

Deixamos um comentário no loop `for` da Listagem 21-14 sobre a criação das
threads. Aqui veremos como realmente criá-las. A biblioteca padrão fornece
`thread::spawn` como uma forma de criar threads, e `thread::spawn` espera
receber algum código que a thread deve executar assim que for criada. No nosso
caso, porém, queremos criar as threads e fazer com que elas _esperem_ pelo
código que enviaremos mais tarde. A implementação de threads da biblioteca
padrão não inclui uma forma de fazer isso; teremos que implementá-la
manualmente.

Implementaremos esse comportamento introduzindo uma nova estrutura de dados entre
`ThreadPool` e as threads, que gerenciará esse novo comportamento. Chamaremos
essa estrutura de dados de _Worker_, um termo comum em implementações de pools.
`Worker` recebe o código que precisa ser executado e o executa em sua thread.

Pense nas pessoas que trabalham na cozinha de um restaurante: os trabalhadores
esperam até que os pedidos cheguem dos clientes e são responsáveis por recebê-los
e prepará-los.

Em vez de armazenar um vetor de instâncias `JoinHandle<()>` no thread pool,
armazenaremos instâncias da struct `Worker`. Cada `Worker` armazenará uma única
instância de `JoinHandle<()>`. Então, implementaremos um método em `Worker` que
receberá uma closure de código para executar e a enviará à thread já em
execução para ser executada. Também daremos a cada `Worker` um `id`, para que
possamos distinguir entre as diferentes instâncias de `Worker` no pool ao
registrar logs ou depurar.

Aqui está o novo processo que acontecerá quando criarmos um `ThreadPool`.
Implementaremos o código que envia a closure para a thread depois de termos
configurado `Worker` desta forma:

1. Defina uma estrutura `Worker` que contenha um `id` e um `JoinHandle<()>`.
2. Altere `ThreadPool` para conter um vetor de instâncias `Worker`.
3. Defina uma função `Worker::new` que receba um número `id` e retorne uma
   instância de `Worker` contendo esse `id` e uma thread criada com uma
   closure vazia.
4. Em `ThreadPool::new`, use o contador do loop `for` para gerar um `id`, crie
   um novo `Worker` com esse `id` e armazene-o no vetor.

Se você estiver pronto para um desafio, tente implementar essas mudanças sozinho antes
olhando o código na Listagem 21-15.

Preparar? Aqui está a Listagem 21-15 com uma maneira de fazer as modificações anteriores.

<Listing number="21-15" file-name="src/lib.rs" caption="Modificando `ThreadPool` para armazenar instâncias de `Worker` em vez de armazenar threads diretamente">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-15/src/lib.rs:here}}
```

</Listing>

Alteramos o nome do campo em `ThreadPool` de `threads` para `workers` porque
agora ele contém instâncias de `Worker`, e não instâncias de `JoinHandle<()>`.
Usamos o contador do loop `for` como argumento para `Worker::new` e armazenamos
cada novo `Worker` no vetor chamado `workers`.

Código externo, como nosso servidor em _src/main.rs_, não precisa conhecer os
detalhes de implementação sobre o uso da struct `Worker` dentro de
`ThreadPool`, portanto tornamos a struct `Worker` e sua função `new`
privadas. A função `Worker::new` usa o `id` fornecido e armazena uma instância
de `JoinHandle<()>` criada ao iniciar uma nova thread com uma closure vazia.

> Nota: Se o sistema operacional não puder criar um thread porque não há
> recursos de sistema suficientes, `thread::spawn` será panic. Isso fará com que o nosso
> servidor inteiro para panic, mesmo que a criação de alguns threads possa
> ter sucesso. Para simplificar, esse comportamento é bom, mas em uma produção
> implementação de thread pool, você provavelmente desejaria usar
> [`std::thread::Builder `][builder]<!-- ignore --> e seus
> [` spawn `][builder-spawn]Método <!-- ignore --> que retorna` Result`.

Este código irá compilar e armazenar o número de instâncias `Worker` que
especificado como um argumento para `ThreadPool::new`. Mas _ainda_ não estamos processando
o closure que obtemos em ` execute`. Vejamos como fazer isso a seguir.

#### Enviando requisições para threads por meio de canais

O próximo problema que abordaremos é que a closure passada a `thread::spawn`
não faz absolutamente nada. Atualmente, obtemos em `execute` a closure que
queremos executar. Mas precisamos fornecer a `thread::spawn` uma closure para
ser executada quando criamos cada `Worker` durante a construção de
`ThreadPool`.

Queremos que as estruturas `Worker` que acabamos de criar busquem o código a
ser executado em uma fila mantida por `ThreadPool` e enviem esse código para
suas threads executarem.

Os canais que aprendemos no Capítulo 16, uma forma simples de comunicação entre
duas threads, são perfeitos para este caso de uso. Usaremos um canal como fila
de trabalhos, e `execute` enviará um trabalho de `ThreadPool` para as
instâncias `Worker`, que repassarão o trabalho para suas threads. Eis o plano:

1. O `ThreadPool` criará um canal e manterá o remetente.
2. Cada `Worker` manterá o receptor.
3. Criaremos uma nova estrutura `Job` que conterá as closures que queremos
   enviar pelo canal.
4. O método `execute` enviará o trabalho que deseja executar através do
   remetente.
5. Em sua thread, `Worker` fará um loop sobre o receptor e executará as
   closures de quaisquer trabalhos recebidos.

Vamos começar criando um canal em `ThreadPool::new` e mantendo o remetente na
instância de `ThreadPool`, como mostrado na Listagem 21-16. A struct `Job` não
contém nada por enquanto, mas será o tipo de item que estaremos enviando pelo
canal.

<Listing number="21-16" file-name="src/lib.rs" caption="Modificando `ThreadPool` para armazenar o transmissor de um canal que transmite instâncias de `Job`">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-16/src/lib.rs:here}}
```

</Listing>

No `ThreadPool::new`, criamos nosso novo canal e fazemos com que o pool mantenha o
remetente. Isso será compilado com sucesso.

Vamos tentar passar um receptor do canal em cada `Worker` como o thread
pool cria o canal. Sabemos que queremos usar o receptor no thread que
as instâncias `Worker` são geradas, então faremos referência ao parâmetro `receiver` no
closure. O código na Listagem 21-17 ainda não será compilado.

<Listing number="21-17" file-name="src/lib.rs" caption="Passando o receptor para cada `Worker`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch21-web-server/listing-21-17/src/lib.rs:here}}
```

</Listing>

Fizemos algumas mudanças pequenas e diretas: passamos o receptor para
`Worker::new`, e então usamos dentro do closure.

Quando tentamos verificar este código, obtemos este erro:

```console
{{#include ../listings/ch21-web-server/listing-21-17/output.txt}}
```

O código está tentando passar `receiver` para várias instâncias de `Worker`.
Isso não funcionará, como você deve se lembrar do Capítulo 16: a implementação
de canais fornecida pelo Rust suporta múltiplos _produtores_ e um único
_consumidor_. Isso significa que não podemos simplesmente clonar a extremidade
consumidora do canal para corrigir esse código. Também não queremos enviar uma
mensagem várias vezes para vários consumidores; queremos uma fila de mensagens
compartilhada entre várias instâncias de `Worker`, de modo que cada mensagem
seja processada uma única vez.

Além disso, retirar um trabalho da fila do canal envolve modificar `receiver`,
então as threads precisam de uma forma segura de compartilhar e modificar esse
`receiver`; caso contrário, poderíamos ter condições de corrida, como vimos no
Capítulo 16.

Lembre-se dos smart pointers thread-safe discutidos no Capítulo 16: para
compartilhar ownership entre várias threads e permitir que essas threads
alterem o valor, precisamos usar `Arc<Mutex<T>>`. O tipo `Arc` permitirá que
múltiplas instâncias de `Worker` possuam o receptor, e `Mutex` garantirá que
apenas um `Worker` por vez obtenha um trabalho do receptor. A Listagem 21-18
mostra as mudanças que precisamos fazer.

<Listing number="21-18" file-name="src/lib.rs" caption="Compartilhando o receptor entre as instâncias de `Worker` usando `Arc` e `Mutex`">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-18/src/lib.rs:here}}
```

</Listing>

Em `ThreadPool::new`, colocamos o receptor dentro de um `Arc` e de um `Mutex`.
Para cada novo `Worker`, clonamos o `Arc` para aumentar a contagem de
referências, de modo que as instâncias de `Worker` possam compartilhar a
ownership do receptor.

Com essas mudanças, o código compila! Estamos chegando lá!

#### Implementando o Método `execute`

Vamos finalmente implementar o método `execute` em `ThreadPool`. Também vamos
transformar `Job` de uma struct em um alias de tipo para um objeto trait que
contém o tipo de closure recebido por `execute`. Como discutimos na seção
[“Sinônimos de tipo e aliases”][type-aliases]<!-- ignore --> no Capítulo 20,
aliases de tipo nos permitem encurtar tipos longos para facilitar o uso. Veja
a Listagem 21-19.

<Listing number="21-19" file-name="src/lib.rs" caption="Criando um alias de tipo `Job` para um `Box` que guarda cada closure e enviando então o job pelo canal">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-19/src/lib.rs:here}}
```

</Listing>

Depois de criar uma nova instância de `Job` usando a closure que obtemos em
`execute`, enviamos esse trabalho pela extremidade de envio do canal. Chamamos
`unwrap` em `send` para o caso de falha no envio. Isso pode acontecer se, por
exemplo, todas as nossas threads tiverem parado de executar, o que significaria
que a extremidade receptora deixou de receber novas mensagens. No momento,
porém, não temos como interromper a execução das threads: elas continuam
executando enquanto o pool existir. A razão pela qual usamos `unwrap` é que
sabemos que esse caso de falha não acontecerá, mas o compilador não sabe disso.

Mas ainda não terminamos! Em `Worker`, a closure passada para `thread::spawn`
ainda apenas _faz referência_ à extremidade receptora do canal. Em vez disso,
precisamos que essa closure faça um loop infinito, pedindo um trabalho à
extremidade receptora do canal e executando-o quando conseguir um. Vamos fazer
a mudança mostrada na Listagem 21-20 para `Worker::new`.

<Listing number="21-20" file-name="src/lib.rs" caption="Recebendo e executando os jobs na thread da instância `Worker`">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-20/src/lib.rs:here}}
```

</Listing>

Aqui, primeiro chamamos `lock` em `receiver` para adquirir o mutex e depois
chamamos `unwrap` para entrar em `panic` em caso de erro. A aquisição de um
bloqueio pode falhar se o mutex estiver em um estado _envenenado_, o que pode
acontecer se alguma outra thread entrar em pânico enquanto mantém o bloqueio em
vez de liberá-lo. Nessa situação, chamar `unwrap` para fazer essa thread entrar
em `panic` é a ação correta. Se quiser, você pode trocar esse `unwrap` por um
`expect` com uma mensagem de erro que faça sentido para você.

Se conseguirmos adquirir o bloqueio do mutex, chamamos `recv` para receber um
`Job` do canal. Um `unwrap` final também lida com quaisquer erros aqui, que
podem ocorrer se a thread que contém o remetente tiver sido desligada, de modo
semelhante ao fato de o método `send` retornar `Err` se o receptor for
desligado.

A chamada a `recv` é bloqueante; portanto, se ainda não houver trabalho, a
thread atual esperará até que um job esteja disponível. O `Mutex<T>` garante
que apenas a thread de um `Worker` por vez esteja tentando solicitar um
trabalho.

Nosso thread pool agora está funcionando! Execute `cargo run` e faça algumas
requisições:

<!-- manual-regeneration
cd listings/ch21-web-server/listing-21-20
cargo run
make some requests to 127.0.0.1:7878
Can't automate because the output depends on making requests
-->

```console
$ cargo run
   Compiling hello v0.1.0 (file:///projects/hello)
warning: field `workers` is never read
 --> src/lib.rs:7:5
  |
6 | pub struct ThreadPool {
  |            ---------- field in this struct
7 |     workers: Vec<Worker>,
  |     ^^^^^^^
  |
  = note: `#[warn(dead_code)]` on by default

warning: fields `id` and `thread` are never read
  --> src/lib.rs:48:5
   |
47 | struct Worker {
   |        ------ fields in this struct
48 |     id: usize,
   |     ^^
49 |     thread: thread::JoinHandle<()>,
   |     ^^^^^^

warning: `hello` (lib) generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 4.91s
     Running `target/debug/hello`
Worker 0 got a job; executing.
Worker 2 got a job; executing.
Worker 1 got a job; executing.
Worker 3 got a job; executing.
Worker 0 got a job; executing.
Worker 2 got a job; executing.
Worker 1 got a job; executing.
Worker 3 got a job; executing.
Worker 0 got a job; executing.
Worker 2 got a job; executing.
```

Sucesso! Agora temos um thread pool que executa conexões de forma assíncrona.
Nunca são criadas mais de quatro threads, então nosso sistema não será
sobrecarregado se o servidor receber muitas requisições. Se fizermos um pedido
para _/sleep_, o servidor poderá atender outras requisições fazendo com que
outra thread as execute.

> Nota: Se você abrir _/sleep_ em várias janelas do navegador simultaneamente, elas
> pode carregar um de cada vez em intervalos de cinco segundos. Alguns navegadores da web executam
> múltiplas instâncias da mesma solicitação sequencialmente por motivos de armazenamento em cache. Isto
> a limitação não é causada pelo nosso web server.

Este é um bom momento para fazer uma pausa e considerar como o código nas Listagens 21-18, 21-19,
e 21-20 seriam diferentes se estivéssemos usando futures em vez de closure para
o trabalho a ser feito. Que tipos mudariam? Como seriam as assinaturas dos métodos
diferente, se é que existe? Quais partes do código permaneceriam iguais?

Depois de aprender sobre o loop `while let` no Capítulo 17 e Capítulo 19, você
pode estar se perguntando por que não escrevemos o código `Worker` thread conforme mostrado em
Listagem 21-21.

<Listing number="21-21" file-name="src/lib.rs" caption="Uma implementação alternativa de `Worker::new` usando `while let`">

```rust,ignore,not_desired_behavior
{{#rustdoc_include ../listings/ch21-web-server/listing-21-21/src/lib.rs:here}}
```

</Listing>

Este código é compilado e executado, mas não resulta no threading desejado
comportamento: uma solicitação lenta ainda fará com que outras solicitações esperem para serem
processado. A razão é um tanto sutil: a estrutura `Mutex` não tem público
Método `unlock` porque o ownership do bloqueio é baseado no lifetime do
o `MutexGuard<T>` dentro do `LockResult<MutexGuard<T>>` que o `lock`
método retorna. Em tempo de compilação, o borrow checker pode então impor a regra
que um recurso protegido por um ` Mutex`não pode ser acessado a menos que tenhamos o
bloqueio. No entanto, esta implementação também pode resultar na retenção do bloqueio
mais do que o pretendido se não estivermos atentos ao lifetime do
` MutexGuard<T>`.

O código na Listagem 21-20 que usa `let job =
receiver.lock().unwrap().recv().unwrap();` funciona porque com `let`, qualquer
valores temporários usados na expressão do lado direito da igualdade
O sinal é eliminado imediatamente quando a instrução ` let`termina. No entanto, ` while
let`(e ` if let`e ` match`) não descarta valores temporários até o final do
o bloco associado. Na Listagem 21-21, o bloqueio permanece mantido durante
da chamada para ` job()`, o que significa que outras instâncias ` Worker`não podem receber trabalhos.

[type-aliases]: ch20-03-advanced-types.html#type-synonyms-and-type-aliases
[integer-types]: ch03-02-data-types.html#integer-types
[moving-out-of-closures]: ch13-01-closures.html#moving-captured-values-out-of-closures
[builder]: ../std/thread/struct.Builder.html
[builder-spawn]: ../std/thread/struct.Builder.html#method.spawn
