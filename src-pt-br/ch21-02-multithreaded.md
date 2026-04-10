<!-- Old headings. Do not remove or links may break. -->

<a id="turning-our-single-threaded-server-into-a-multithreaded-server"></a>
<a id="from-single-threaded-to-multithreaded-server"></a>

## De um servidor single-thread para um servidor multithread

Neste momento, o servidor processará cada solicitação por vez, o que significa que não
processar uma segunda conexão até que o processamento da primeira conexão seja concluído.
Se o servidor recebesse cada vez mais solicitações, esta execução serial seria
cada vez menos ideal. Se o servidor receber uma solicitação que demora muito
para processar, as solicitações subsequentes terão que esperar até que a solicitação longa seja
concluído, mesmo que as novas solicitações possam ser processadas rapidamente. Precisaremos consertar
isso, mas primeiro veremos o problema em ação.

<!-- Old headings. Do not remove or links may break. -->

<a id="simulating-a-slow-request-in-the-current-server-implementation"></a>

### Simulating a Slow Request

Veremos como uma solicitação de processamento lento pode afetar outras solicitações feitas para
nossa implementação de servidor atual. A Listagem 21-10 implementa o tratamento de uma solicitação
para _/sleep_ com uma resposta lenta simulada que fará o servidor dormir
por cinco segundos antes de responder.

<Listing number="21-10" file-name="src/main.rs" caption="Simulando uma requisição lenta ao dormir por cinco segundos">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-10/src/main.rs:here}}
```

</Listing>

Mudamos de `if` para `match` agora que temos três casos. Nós precisamos
explicitamente match em um slice de `request_line` para padrão-match em relação ao
valores literais de string; `match` não faz referência automática e
desreferenciação, como faz o método da igualdade.

O primeiro braço é igual ao bloco `if` da Listagem 21-9. O segundo braço
corresponde a uma solicitação para _/sleep_. Quando essa solicitação for recebida, o servidor irá
durma por cinco segundos antes de renderizar a página HTML bem-sucedida. O terceiro braço
é igual ao bloco `else` da Listagem 21-9.

Você pode ver o quão primitivo é o nosso servidor: bibliotecas reais lidariam com o
reconhecimento de múltiplas solicitações de uma forma muito menos detalhada!

Inicie o servidor usando `cargo run`. Em seguida, abra duas janelas do navegador: uma para
_http://127.0.0.1:7878_ e outro para _http://127.0.0.1:7878/sleep_. Se você
insira o URI _/_ algumas vezes, como antes, você verá que ele responde rapidamente. Mas se
você digita _/sleep_ e então carrega _/_, você verá que _/_ espera até ` sleep`
dormiu cinco segundos inteiros antes de carregar.

Existem várias técnicas que podemos usar para evitar solicitações de backup
uma solicitação lenta, incluindo o uso de async como fizemos no Capítulo 17; aquele que iremos
implementar é um pool thread.

### Melhorando o rendimento com um pool de threads

Um _thread pool_ é um grupo de threads gerados que estão prontos e aguardando para
lidar com uma tarefa. Quando o programa recebe uma nova tarefa, ele atribui uma das
threads no pool para a tarefa e que thread processará a tarefa. O
threads restantes no pool estão disponíveis para lidar com quaisquer outras tarefas que venham
enquanto o primeiro thread está sendo processado. Quando o primeiro thread estiver pronto
processando sua tarefa, ele retorna ao pool de threads ocioso, pronto para lidar
uma nova tarefa. Um pool thread permite processar conexões simultaneamente,
aumentando o rendimento do seu servidor.

Limitaremos o número de threads no pool a um pequeno número para nos proteger
de ataques DoS; se nosso programa criasse um novo thread para cada solicitação como
quando chegou, alguém fazendo 10 milhões de solicitações ao nosso servidor poderia causar estragos
usando todos os recursos do nosso servidor e processando solicitações
parar.

Em vez de gerar threads ilimitado, teremos um número fixo de
threads esperando na piscina. As solicitações recebidas são enviadas ao pool para
processamento. O pool manterá uma fila de solicitações recebidas. Cada um dos
threads no pool irá gerar uma solicitação desta fila, tratar a solicitação,
e então solicite outra solicitação à fila. Com este design, podemos processar
para solicitações _ `N` _ simultaneamente, onde _ `N` _ é o número de threads. Se cada
thread está respondendo a uma solicitação de longa duração, as solicitações subsequentes ainda podem
fazer backup na fila, mas aumentamos o número de solicitações de longa duração
podemos lidar antes de chegar a esse ponto.

Esta técnica é apenas uma das muitas maneiras de melhorar o rendimento de uma web
servidor. Outras opções que você pode explorar são o modelo fork/join, o
modelo de E/S async de thread único e o modelo de E/S async multithread. Se
você está interessado neste tópico, você pode ler mais sobre outras soluções e
tente implementá-los; com uma linguagem de baixo nível como Rust, todos esses
opções são possíveis.

Antes de começarmos a implementar um pool thread, vamos falar sobre o que usar o
piscina deve ser semelhante. Quando você está tentando projetar código, escrevendo o cliente
interface primeiro pode ajudar a orientar seu design. Escreva a API do código para que
está estruturado da maneira que você deseja chamá-lo; então, implemente o
funcionalidade dentro dessa estrutura, em vez de implementar a funcionalidade
e então projetar a API pública.

Semelhante à forma como usamos o desenvolvimento orientado a testes no projeto no Capítulo 12,
usaremos desenvolvimento orientado a compilador aqui. Escreveremos o código que chama o
funções que queremos e, em seguida, examinaremos os erros do compilador para determinar
o que devemos mudar a seguir para fazer o código funcionar. Antes de fazermos isso, no entanto,
exploraremos a técnica que não usaremos como ponto de partida.

<!-- Old headings. Do not remove or links may break. -->

<a id="code-structure-if-we-could-spawn-a-thread-for-each-request"></a>

#### Gerando um Thread para Cada Solicitação

Primeiro, vamos explorar como nosso código ficaria se ele criasse um novo thread para
cada conexão. Como mencionado anteriormente, este não é o nosso plano final devido ao
problemas com a geração potencial de um número ilimitado de threads, mas é um
ponto de partida para obter primeiro um servidor multithread funcional. Então, adicionaremos o
Pool thread como uma melhoria e contrastar as duas soluções será mais fácil.

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

#### Criando um número finito de threads

Queremos que nosso pool thread funcione de maneira semelhante e familiar, para que a troca
de threads para um pool thread não requer grandes alterações no código que
usa nossa API. A Listagem 21-12 mostra a interface hipotética para um `ThreadPool`
struct que queremos usar em vez de ` thread::spawn`.

<Listing number="21-12" file-name="src/main.rs" caption="Nossa interface ideal para `ThreadPool`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch21-web-server/listing-21-12/src/main.rs:here}}
```

</Listing>

Usamos `ThreadPool::new` para criar um novo pool thread com um número configurável
de threads, neste caso quatro. Então, no loop `for`, ` pool.execute`tem um
interface semelhante ao ` thread::spawn`, pois é necessário um closure que o pool
deve ser executado para cada stream. Precisamos implementar ` pool.execute`para que
pega o closure e o entrega a um thread no pool para execução. Este código não
ainda compilar, mas tentaremos para que o compilador possa nos orientar sobre como corrigi-lo.

<!-- Old headings. Do not remove or links may break. -->

<a id="building-the-threadpool-struct-using-compiler-driven-development"></a>

#### Construindo `ThreadPool` usando desenvolvimento orientado a compilador

Faça as alterações na Listagem 21-12 em _src/main.rs_ e então vamos usar o
erros do compilador do `cargo check` para impulsionar nosso desenvolvimento. Aqui está o primeiro
erro que obtemos:

```console
{{#include ../listings/ch21-web-server/listing-21-12/output.txt}}
```

Ótimo! Este erro nos diz que precisamos de um tipo ou módulo `ThreadPool`, então vamos
construa um agora. Nossa implementação ` ThreadPool`será independente do tipo
de trabalho que nosso web server está realizando. Então, vamos trocar o ` hello`crate de um
binário crate para uma biblioteca crate para armazenar nossa implementação ` ThreadPool`. Depois
mudarmos para uma biblioteca crate, também poderíamos usar o pool thread separado
biblioteca para qualquer trabalho que queiramos fazer usando um pool thread, não apenas para servir
solicitações da web.

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

Este erro indica que a seguir precisamos criar uma função associada chamada
`new ` para`ThreadPool `. Também sabemos que` new `precisa ter um parâmetro
que pode aceitar` 4 `como argumento e deve retornar uma instância` ThreadPool `.
Vamos implementar a função` new`mais simples que terá esses
características:

<Listing file-name="src/lib.rs">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/no-listing-02-impl-threadpool-new/src/lib.rs}}
```

</Listing>

Escolhemos `usize` como o tipo do parâmetro `size` porque sabemos que um
número negativo de threads não faz sentido. Também sabemos que usaremos isso
`4 ` como o número de elementos em uma coleção de threads, que é o que o
O tipo`usize` é para, conforme discutido na seção [“Tipos inteiros”][integer-types]<!--
ignore --> no Capítulo 3.

Vamos verificar o código novamente:

```console
{{#include ../listings/ch21-web-server/no-listing-02-impl-threadpool-new/output.txt}}
```

Agora o erro ocorre porque não temos um método `execute` em `ThreadPool`.
Lembre-se do artigo [“Criando um Número Finito de
Threads”](#creating-a-finite-number-of-threads)seção <!-- ignore --> que
decidimos que nosso pool thread deveria ter uma interface semelhante ao ` thread::spawn`. Em
Além disso, implementaremos a função ` execute`para que ela leve o closure
ele é fornecido e entregue a um thread ocioso no pool para ser executado.

Definiremos o método `execute` em `ThreadPool` para tomar um closure como
parâmetro. Lembre-se do artigo [“Movendo valores capturados para fora
Fechamentos”][moving-out-of-closures]<!-- ignore --> no Capítulo 13 que podemos
tome closures como parâmetros com três traits diferentes: `Fn`, ` FnMut`e
` FnOnce `. Precisamos decidir que tipo de closure usar aqui. Nós sabemos que vamos
acabar fazendo algo semelhante à biblioteca padrão` thread::spawn `
implementação, para que possamos ver o que limita a assinatura de` thread::spawn`
tem em seu parâmetro. A documentação nos mostra o seguinte:

```rust,ignore
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
    where
        F: FnOnce() -> T,
        F: Send + 'static,
        T: Send + 'static,
```

O parâmetro de tipo `F` é o que nos preocupa aqui; o tipo `T`
parâmetro está relacionado ao valor de retorno e não estamos preocupados com isso. Nós
podemos ver que ` spawn`usa ` FnOnce`como trait vinculado a ` F`. Isto é provavelmente
o que queremos também, porque eventualmente passaremos no argumento que entramos
` execute `para` spawn `. Podemos ter ainda mais certeza de que` FnOnce `é o trait que
deseja usar porque o thread para executar uma solicitação executará apenas aquela
closure da solicitação uma vez, que corresponde ao` Once `em` FnOnce`.

O parâmetro de tipo `F` também possui o trait vinculado ao `Send` e o lifetime vinculado
`'static `, que são úteis em nossa situação: Precisamos de` Send `para transferir o
closure de um thread para outro e` 'static `porque não sabemos quanto tempo
o thread levará para ser executado. Vamos criar um método` execute `em
` ThreadPool `que receberá um parâmetro genérico do tipo` F`com estes limites:

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

Ele compila! Mas observe que se você tentar `cargo run` e fizer uma solicitação no
navegador, você verá os erros no navegador que vimos no início de
o capítulo. Nossa biblioteca não está realmente chamando o closure passado para `execute`
ainda!

> Nota: Um ditado que você pode ouvir sobre linguagens com compiladores estritos, como
> Haskell e Rust, é “Se o código compilar, ele funciona”. Mas este ditado não é
> universalmente verdadeiro. Nosso projeto compila, mas não faz absolutamente nada! Se nós
> estamos construindo um projeto real e completo, este seria um bom momento para começar
> escrever testes unitários para verificar se o código compila _e_ tem o comportamento que
> quero.

Consider: What would be different here if we were going to execute a future
instead of a closure?

#### Validando o número de threads em `new`

Não estamos fazendo nada com os parâmetros `new` e `execute`. Vamos
implementar os corpos dessas funções com o comportamento que desejamos. Para começar,
vamos pensar em ` new`. Anteriormente escolhemos um tipo não assinado para ` size`
parâmetro porque um pool com um número negativo de threads não faz sentido.
No entanto, um pool com zero threads também não faz sentido, mas zero é perfeitamente
` usize `válido. Adicionaremos código para verificar se` size `é maior que zero antes
retornamos uma instância` ThreadPool `e teremos o programa panic se
recebe um zero usando a macro` assert!`, conforme mostrado na Listagem 21-13.

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

Em vez de adicionar a macro `assert!` como fizemos aqui, poderíamos alterar `new`
em ` build`e retornar um ` Result`como fizemos com ` Config::build`no I/O
projeto na Listagem 12-9. Mas decidimos, neste caso, que tentar criar um
O pool thread sem qualquer threads deve ser um erro irrecuperável. Se você estiver
sentindo-se ambicioso, tente escrever uma função chamada ` build`com o seguinte
assinatura para comparar com a função ` new`:

```rust,ignore
pub fn build(size: usize) -> Result<ThreadPool, PoolCreationError> {
```

#### Criando espaço para armazenar os threads

Agora que temos uma maneira de saber que temos um número válido de threads para armazenar
o pool, podemos criar esses threads e armazená-los na estrutura `ThreadPool`
antes de retornar a estrutura. Mas como “armazenamos” um thread? Vamos pegar outro
veja a assinatura ` thread::spawn`:

```rust,ignore
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
    where
        F: FnOnce() -> T,
        F: Send + 'static,
        T: Send + 'static,
```

A função `spawn` retorna um `JoinHandle<T>`, onde ` T`é o tipo que o
closure retorna. Vamos tentar usar ` JoinHandle`também e ver o que acontece. Em nosso
caso, o closures que estamos passando para o pool thread cuidará da conexão
e não retornar nada, então ` T`será o tipo de unidade ` ()`.

O código na Listagem 21.14 será compilado, mas ainda não criará nenhum threads.
Mudamos a definição de `ThreadPool` para conter um vetor de
Instâncias `thread::JoinHandle<()>`, inicializaram o vetor com capacidade de
` size `, configure um loop` for `que executará algum código para criar o threads e
retornou uma instância` ThreadPool`contendo-os.

<Listing number="21-14" file-name="src/lib.rs" caption="Criando um vetor para `ThreadPool` armazenar as threads">

```rust,ignore,not_desired_behavior
{{#rustdoc_include ../listings/ch21-web-server/listing-21-14/src/lib.rs:here}}
```

</Listing>

Colocamos `std::thread` no escopo da biblioteca crate porque estamos
usando `thread::JoinHandle` como o tipo dos itens no vetor em
`ThreadPool`.

Assim que um tamanho válido for recebido, nosso `ThreadPool` cria um novo vetor que pode
mantenha itens `size`. A função ` with_capacity`executa a mesma tarefa que
` Vec::new `mas com uma diferença importante: pré-aloca espaço no
vetor. Porque sabemos que precisamos armazenar elementos` size `no vetor, fazendo
esta alocação inicial é um pouco mais eficiente do que usar` Vec::new`,
que se redimensiona à medida que os elementos são inseridos.

Quando você executar `cargo check` novamente, ele deverá ter sucesso.

<!-- Old headings. Do not remove or links may break. -->
<a id ="a-worker-struct-responsible-for-sending-code-from-the-threadpool-to-a-thread"></a>

#### Enviando código do `ThreadPool` para um thread

Deixamos um comentário no loop `for` da Listagem 21-14 sobre a criação de
threads. Aqui, veremos como realmente criamos o threads. O padrão
biblioteca fornece `thread::spawn` como uma forma de criar threads, e
`thread::spawn` espera obter algum código que o thread deve executar assim que o
thread é criado. Porém, no nosso caso, queremos criar o threads e ter
eles _esperam_ pelo código que enviaremos mais tarde. A biblioteca padrão
a implementação do threads não inclui nenhuma maneira de fazer isso; nós temos que
implementá-lo manualmente.

Implementaremos esse comportamento introduzindo uma nova estrutura de dados entre o
`ThreadPool ` e o threads que irão gerenciar esse novo comportamento. Nós ligaremos
esta estrutura de dados _Worker_, que é um termo comum em pooling
implementações. O`Worker` pega o código que precisa ser executado e executa o
código em seu thread.

Pense nas pessoas que trabalham na cozinha de um restaurante: os trabalhadores esperam até
os pedidos chegam dos clientes e eles são responsáveis ​​por recebê-los
pedidos e preenchê-los.

Em vez de armazenar um vetor de instâncias `JoinHandle<()>` no pool thread,
armazenaremos instâncias da estrutura `Worker`. Cada ` Worker`armazenará um único
Instância ` JoinHandle<()>`. Então, implementaremos um método em ` Worker`que irá
pegue um closure de código para executar e envie-o para o thread já em execução para
execução. Também daremos a cada ` Worker`um ` id`para que possamos distinguir
entre as diferentes instâncias de ` Worker`no pool ao registrar ou
depuração.

Aqui está o novo processo que acontecerá quando criarmos um `ThreadPool`. Nós vamos
implementar o código que envia o closure para o thread depois de termos ` Worker`
configurar desta forma:

1. Defina uma estrutura `Worker` que contenha um `id` e um `JoinHandle<()>`.
2. Altere ` ThreadPool`para conter um vetor de instâncias ` Worker`.
3. Defina uma função ` Worker::new`que receba um número ` id`e retorne um
   Instância ` Worker`que contém o ` id`e um thread gerado com um vazio
   closure.
4. Em ` ThreadPool::new`, use o contador de loop ` for`para gerar um ` id`, crie
   um novo ` Worker`com aquele ` id`e armazene o ` Worker`no vetor.

Se você estiver pronto para um desafio, tente implementar essas mudanças sozinho antes
olhando o código na Listagem 21-15.

Preparar? Aqui está a Listagem 21-15 com uma maneira de fazer as modificações anteriores.

<Listing number="21-15" file-name="src/lib.rs" caption="Modificando `ThreadPool` para armazenar instâncias de `Worker` em vez de armazenar threads diretamente">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-15/src/lib.rs:here}}
```

</Listing>

Alteramos o nome do campo em `ThreadPool` de `threads` para `workers`
porque agora contém instâncias ` Worker`em vez de ` JoinHandle<()>`
instâncias. Usamos o contador no loop ` for`como argumento para
` Worker::new `, e armazenamos cada novo` Worker `no vetor denominado` workers`.

Código externo (como nosso servidor em _src/main.rs_) não precisa saber o
detalhes de implementação sobre o uso de uma estrutura `Worker` dentro de `ThreadPool`,
portanto, tornamos a estrutura ` Worker`e sua função ` new`privadas. O
A função ` Worker::new`usa o ` id`que fornecemos e armazena um ` JoinHandle<()>`
instância criada gerando um novo thread usando um closure vazio.

> Nota: Se o sistema operacional não puder criar um thread porque não há
> recursos de sistema suficientes, `thread::spawn` será panic. Isso fará com que o nosso
> servidor inteiro para panic, mesmo que a criação de alguns threads possa
> ter sucesso. Para simplificar, esse comportamento é bom, mas em uma produção
> Implementação do pool thread, você provavelmente desejaria usar
> [`std::thread::Builder `][builder]<!-- ignore --> e seus
> [` spawn `][builder-spawn]Método <!-- ignore --> que retorna` Result`.

Este código irá compilar e armazenar o número de instâncias `Worker` que
especificado como um argumento para `ThreadPool::new`. Mas _ainda_ não estamos processando
o closure que obtemos em ` execute`. Vejamos como fazer isso a seguir.

#### Enviando requisições para threads por meio de canais

O próximo problema que abordaremos é que o closures dado ao `thread::spawn` faz
absolutamente nada. Atualmente, obtemos o closure que queremos executar no
Método `execute`. Mas precisamos dar ao ` thread::spawn`um closure para ser executado quando
crie cada ` Worker`durante a criação do ` ThreadPool`.

Queremos que as estruturas `Worker` que acabamos de criar busquem o código para execução
uma fila mantida no `ThreadPool` e enviar esse código para seu thread para execução.

Os canais que aprendemos no Capítulo 16 – uma maneira simples de comunicação entre
dois threads – seriam perfeitos para este caso de uso. Usaremos um canal para funcionar
como a fila de trabalhos, e `execute` enviará um trabalho do `ThreadPool` para
as instâncias `Worker`, que enviarão o trabalho para seu thread. Aqui está o plano:

1. O `ThreadPool` criará um canal e manterá o remetente.
2. Cada `Worker` irá segurar o receptor.
3. Criaremos uma nova estrutura `Job` que conterá o closures que queremos enviar
   abaixo do canal.
4. O método `execute` enviará o trabalho que deseja executar através do
   remetente.
5. Em seu thread, o `Worker` fará um loop em seu receptor e executará o
   closures de quaisquer trabalhos recebidos.

Vamos começar criando um canal em `ThreadPool::new` e mantendo o remetente
na instância `ThreadPool`, conforme mostrado na Listagem 21-16. A estrutura ` Job`
não contém nada por enquanto, mas será o tipo de item que estamos enviando
o canal.

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

O código está tentando passar `receiver` para várias instâncias de `Worker`. Isto
não funcionará, como você deve se lembrar do Capítulo 16: A implementação do canal que
Rust fornece múltiplos _produtores_ e único _consumidor_. Isso significa que não podemos
basta clonar a extremidade consumidora do canal para corrigir esse código. Nós também não
deseja enviar uma mensagem diversas vezes para vários consumidores; queremos uma lista
de mensagens com múltiplas instâncias ` Worker`, de modo que cada mensagem receba
processado uma vez.

Além disso, retirar um trabalho da fila do canal envolve alterar o
`receiver `, então o threads precisa de uma maneira segura de compartilhar e modificar` receiver`;
caso contrário, poderemos obter condições de corrida (conforme abordado no Capítulo 16).

Lembre-se do thread seguro para smart pointers discutido no Capítulo 16: Para compartilhar
ownership em vários threads e permitir que o threads altere o valor, nós
precisa usar `Arc<Mutex<T>>`. O tipo ` Arc`permitirá múltiplas instâncias ` Worker`
possui o receptor e ` Mutex`garantirá que apenas um ` Worker`obtenha um trabalho de
receptor de cada vez. A Listagem 21-18 mostra as mudanças que precisamos fazer.

<Listing number="21-18" file-name="src/lib.rs" caption="Compartilhando o receptor entre as instâncias de `Worker` usando `Arc` e `Mutex`">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-18/src/lib.rs:here}}
```

</Listing>

No `ThreadPool::new`, colocamos o receptor em um ` Arc`e um ` Mutex`. Para cada
novo ` Worker`, clonamos o ` Arc`para aumentar a contagem de referência para que o
As instâncias ` Worker`podem compartilhar ownership do receptor.

Com essas mudanças, o código compila! Estamos chegando lá!

#### Implementando o Método `execute`

Vamos finalmente implementar o método `execute` em `ThreadPool`. Nós também vamos mudar
` Job `de uma estrutura para um alias de tipo para um objeto trait que contém o tipo de
closure que` execute`recebe. Conforme discutido em [“Sinônimos de tipo e
Aliases”][type-aliases]Seção <!-- ignore --> no Capítulo 20, digite aliases
nos permitem encurtar os tipos longos para facilitar o uso. Veja a Listagem 21-19.

<Listing number="21-19" file-name="src/lib.rs" caption="Criando um alias de tipo `Job` para um `Box` que guarda cada closure e enviando então o job pelo canal">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-19/src/lib.rs:here}}
```

</Listing>

Depois de criar uma nova instância `Job` usando o closure que obtemos em `execute`,
envie esse trabalho pela extremidade de envio do canal. Estamos ligando para ` unwrap`
` send `para o caso de falha no envio. Isto pode acontecer se, por exemplo,
impedir a execução de todos os nossos threads, o que significa que o terminal receptor parou
recebendo novas mensagens. No momento, não podemos impedir que nosso threads
executando: Nosso threads continua em execução enquanto o pool existir. O
A razão pela qual usamos` unwrap`é que sabemos que o caso de falha não acontecerá, mas o
compilador não sabe disso.

Mas ainda não terminamos! No `Worker`, nosso closure sendo passado para
` thread::spawn `ainda _refere_ apenas a extremidade receptora do canal.
Em vez disso, precisamos que o closure faça um loop eterno, solicitando ao final receptor do
canal para um trabalho e executá-lo quando ele conseguir um. Vamos fazer a mudança
mostrado na Listagem 21-20 para` Worker::new`.

<Listing number="21-20" file-name="src/lib.rs" caption="Recebendo e executando os jobs na thread da instância `Worker`">

```rust,noplayground
{{#rustdoc_include ../listings/ch21-web-server/listing-21-20/src/lib.rs:here}}
```

</Listing>

Aqui, primeiro chamamos `lock` no `receiver` para adquirir o mutex e depois
chame `unwrap` para panic em caso de erros. A aquisição de um bloqueio pode falhar se o mutex
está em um estado _envenenado_, o que pode acontecer se algum outro thread entrar em pânico enquanto
segurando a trava em vez de soltá-la. Nesta situação, ligar
`unwrap ` para ter este thread panic é a ação correta a ser tomada. Sinta-se à vontade para
altere este`unwrap ` para um`expect` com uma mensagem de erro que seja significativa para
você.

Se conseguirmos o bloqueio no mutex, chamamos `recv` para receber um `Job` do
canal. Um `unwrap` final também supera quaisquer erros aqui, que podem ocorrer
se o thread que contém o remetente foi desligado, semelhante a como o `send`
O método retorna ` Err`se o receptor for desligado.

A chamada para `recv` é bloqueada, portanto, se ainda não houver trabalho, o thread atual será
espere até que um emprego esteja disponível. O `Mutex<T>` garante que apenas um
`Worker` thread de cada vez está tentando solicitar um trabalho.

Our thread pool is now in a working state! Give it a `cargo run` and make some
requests:

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

Sucesso! Agora temos um pool thread que executa conexões de forma assíncrona.
Nunca são criados mais de quatro threads, então nosso sistema não será
sobrecarregado se o servidor receber muitas solicitações. Se fizermos um pedido para
_/sleep_, o servidor poderá atender outras solicitações tendo outro
thread execute-os.

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
