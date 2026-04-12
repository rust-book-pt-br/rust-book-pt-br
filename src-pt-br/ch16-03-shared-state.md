## Simultaneidade de estado compartilhado

A passagem de mensagens é uma ótima maneira de lidar com a concorrência, mas não é a única.
Outro método seria permitir que várias threads acessassem os mesmos dados compartilhados.
Considere novamente esta parte do slogan da documentação da linguagem Go: “Não
não se comunique compartilhando memória.”

Como seria a comunicação através do compartilhamento de memória? Além disso, por que
entusiastas da passagem de mensagens alertam contra o uso de compartilhamento de memória?

De certa forma, os canais em qualquer linguagem de programação são semelhantes ao ownership único,
porque, depois de transferir um valor para um canal, você não deve mais usá-lo.
A concorrência com memória compartilhada é como ownership múltiplo: várias threads
podem acessar o mesmo local de memória ao mesmo tempo. Como você viu no Capítulo 15,
onde smart pointers tornaram possível o ownership múltiplo, ter vários owners pode
adicionar complexidade porque esses diferentes proprietários precisam ser gerenciados. O sistema de tipos do Rust
e as regras de ownership ajudam muito a acertar esse gerenciamento. Como exemplo,
vejamos mutexes, uma das primitivas de concorrência mais comuns
para memória compartilhada.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-mutexes-to-allow-access-to-data-from-one-thread-at-a-time"></a>

### Controlando o acesso com mutexes

_Mutex_ é uma abreviatura de _exclusão mútua_, pois em um mutex permite apenas
um thread para acessar alguns dados a qualquer momento. Para acessar os dados em um
mutex, um thread deve primeiro sinalizar que deseja acesso solicitando a aquisição do
bloqueio do mutex. O _lock_ é uma estrutura de dados que faz parte do mutex que
mantém registro de quem atualmente tem acesso exclusivo aos dados. Portanto, o
mutex é descrito como _proteger_ os dados que contém por meio do sistema de bloqueio.

Mutexes têm a reputação de serem difíceis de usar porque você precisa
lembre-se de duas regras:

1. Você deve tentar adquirir o bloqueio antes de usar os dados.
2. Quando terminar de usar os dados que o mutex protege, você deve desbloquear o
   dados para que outro threads possa adquirir o bloqueio.

Para uma metáfora do mundo real para um mutex, imagine um painel de discussão em um
conferência com apenas um microfone. Antes que um painelista possa falar, ele deve
pergunte ou sinalize que deseja usar o microfone. Quando eles conseguirem o
microfone, eles podem falar o tempo que quiserem e depois entregar o
microfone para o próximo palestrante que solicitar falar. Se um painelista se esquecer de
entregar o microfone quando terminarem, ninguém mais será capaz de
fale. Se o gerenciamento do microfone compartilhado der errado, o painel não funcionará
como planejado!

O gerenciamento de mutexes pode ser incrivelmente complicado de acertar, e é por isso que
muitas pessoas estão entusiasmadas com os canais. No entanto, graças ao tipo de Rust
sistema e regras ownership, você não pode errar no bloqueio e desbloqueio.

#### A API do `Mutex<T>`

Como exemplo de como usar um mutex, vamos começar usando um mutex em um
contexto de thread único, conforme mostrado na Listagem 16-12.

<Listing number="16-12" file-name="src/main.rs" caption="Explorando a API de `Mutex<T>` em um contexto single-threaded por simplicidade">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-12/src/main.rs}}
```

</Listing>

Tal como acontece com muitos tipos, criamos um `Mutex<T>` usando a função associada `new`.
Para acessar os dados dentro do mutex, usamos o método ` lock`para adquirir o
bloqueio. Esta chamada bloqueará o thread atual para que ele não possa realizar nenhum trabalho
até que seja a nossa vez de ter a fechadura.

A chamada para `lock` falharia se outro thread segurando o bloqueio entrasse em pânico. Em
nesse caso, ninguém jamais conseguiria obter a fechadura, então optamos por
`unwrap` e tenha este thread panic se estivermos nessa situação.

Após adquirirmos o bloqueio, podemos tratar o valor de retorno, denominado `num` em
neste caso, como uma referência mutável aos dados internos. O sistema de tipos garante
que adquirimos um bloqueio antes de usar o valor em `m`. O tipo de `m` é
`Mutex<i32>`, não `i32`, então _devemos_ chamar `lock` para poder usar o valor
`i32`. Não podemos esquecer; o sistema de tipos não nos permite acessar o `i32`
interno de outra forma.

A chamada para `lock` retorna um tipo chamado `MutexGuard`, envolvido em um
`LockResult` que tratamos com a chamada para `unwrap`. O tipo `MutexGuard`
implementa `Deref` para apontar para nossos dados internos; o tipo também possui uma
implementação de `Drop` que libera o bloqueio automaticamente quando um
`MutexGuard` sai do escopo, o que acontece no final do escopo interno. Como resultado, nós
não corra o risco de esquecer de liberar o bloqueio e bloquear o mutex de ser
usado por outro threads porque a liberação do bloqueio acontece automaticamente.

Depois de eliminar o bloqueio, podemos imprimir o valor mutex e ver se conseguimos
para alterar o `i32` interno para `6`.

<!-- Old headings. Do not remove or links may break. -->

<a id="sharing-a-mutext-between-multiple-threads"></a>

#### Acesso compartilhado ao `Mutex<T>`

Agora vamos tentar compartilhar um valor entre vários threads usando `Mutex<T>`. Nós vamos
gire 10 threads e faça com que cada um deles incremente um valor de contador em 1, então o
contador vai de 0 a 10. O exemplo na Listagem 16-13 terá um compilador
erro, e usaremos esse erro para aprender mais sobre como usar ` Mutex<T>`e como
Rust nos ajuda a usá-lo corretamente.

<Listing number="16-13" file-name="src/main.rs" caption="Dez threads, cada uma incrementando um contador protegido por um `Mutex<T>`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-13/src/main.rs}}
```

</Listing>

Criamos uma variável `counter` para armazenar um `i32` dentro de um `Mutex<T>`, como fizemos
na Listagem 16-12. A seguir, criamos 10 threads iterando em um intervalo de
números. Usamos ` thread::spawn`e damos a todos os threads o mesmo closure: um
que move o contador para o thread, adquire um bloqueio no ` Mutex<T>`
chamando o método ` lock`e, em seguida, adiciona 1 ao valor no mutex. Quando um
thread termina de executar seu closure, ` num`sairá do escopo e liberará o
lock para que outro thread possa adquiri-lo.

No thread principal, coletamos todos os identificadores de junção. Então, como fizemos na Listagem
16-2, chamamos `join` em cada identificador para garantir que todo o threads termine. Em
nesse ponto, o thread principal irá adquirir o bloqueio e imprimir o resultado deste
programa.

Sugerimos que este exemplo não seria compilado. Agora vamos descobrir o porquê!

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-13/output.txt}}
```

A mensagem de erro informa que o valor `counter` foi movido no anterior
iteração do loop. Rust está nos dizendo que não podemos mover o ownership de
bloqueie `counter` em vários threads. Vamos corrigir o erro do compilador com o
método multiple-ownership que discutimos no Capítulo 15.

#### Propriedade múltipla com vários threads

No Capítulo 15, atribuímos um valor a vários proprietários usando o smart pointer
`Rc<T> ` para criar um valor contado por referência. Vamos fazer o mesmo aqui e ver
o que acontece. Iremos agrupar o`Mutex<T> ` em`Rc<T> ` na Listagem 16-14 e clonar
o`Rc<T>` antes de mover o ownership para o thread.

<Listing number="16-14" file-name="src/main.rs" caption="Tentando usar `Rc<T>` para permitir que múltiplas threads tenham ownership do `Mutex<T>`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-14/src/main.rs}}
```

</Listing>

Mais uma vez, compilamos e obtemos... erros diferentes! O compilador está nos ensinando
muito:

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-14/output.txt}}
```

Uau, essa mensagem de erro é muito prolixa! Aqui está a parte importante em que focar:
`Rc<Mutex<i32>> cannot be sent between threads safely`. O compilador também está
nos dizendo o motivo: a trait `Send` não está implementada para
`Rc<Mutex<i32>>`. Falaremos sobre `Send` na próxima seção: ela é uma das
traits que garante que os tipos que usamos com threads sejam adequados para uso em
situações simultâneas.

Infelizmente, `Rc<T>` não é seguro para compartilhar no threads. Quando `Rc<T>`
gerencia a contagem de referência, adiciona à contagem de cada chamada para ` clone`e
subtrai da contagem quando cada clone é descartado. Mas não usa nenhum
primitivas de simultaneidade para garantir que alterações na contagem não possam ser
interrompido por outro thread. Isso pode levar a contagens erradas – erros sutis que
pode, por sua vez, levar a vazamentos de memória ou à eliminação de um valor antes de terminarmos
com isso. O que precisamos é de um tipo exatamente igual ao ` Rc<T>`, mas que faça
alterações na contagem de referência de maneira segura para thread.

#### Contagem de referência atômica com `Arc<T>`

Felizmente, `Arc<T>` _é_ um tipo como `Rc<T>` que é seguro para uso em
situações simultâneas. O _a_ significa _atomic_, o que significa que é um _atomicamente
tipo de contagem de referência. Atômicos são um tipo adicional de simultaneidade
primitivo que não abordaremos em detalhes aqui: Veja a biblioteca padrão
documentação para [`std::sync::atomic`][atomic]<!-- ignore --> para mais
detalhes. Neste ponto, você só precisa saber que os átomos funcionam como primitivos
tipos, mas são seguros para compartilhar no threads.

Você pode então se perguntar por que todos os tipos primitivos não são atômicos e por que os tipos padrão
tipos de biblioteca não são implementados para usar `Arc<T>` por padrão. A razão é que
A segurança do thread vem com uma penalidade de desempenho que você só deseja pagar quando
você realmente precisa. Se você estiver apenas executando operações em valores dentro de um
único thread, seu código poderá ser executado mais rapidamente se não precisar impor o
garantias que os átomos fornecem.

Vamos voltar ao nosso exemplo: `Arc<T>` e `Rc<T>` têm a mesma API, então corrigimos
nosso programa alterando a linha `use`, a chamada para ` new`e a chamada para
` clone`. O código na Listagem 16-15 será finalmente compilado e executado.

<Listing number="16-15" file-name="src/main.rs" caption="Usando `Arc<T>` para envolver o `Mutex<T>` e compartilhar ownership entre múltiplas threads">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-15/src/main.rs}}
```

</Listing>

Este código imprimirá o seguinte:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
Result: 10
```

Nós conseguimos! Contamos de 0 a 10, o que pode não parecer muito impressionante, mas
nos ensinou muito sobre a segurança `Mutex<T>` e thread. Você também pode usar isso
estrutura do programa para fazer operações mais complicadas do que apenas incrementar um
contador. Usando esta estratégia, você pode dividir um cálculo em
partes, divida essas partes em threads e, em seguida, use um `Mutex<T>` para ter cada
thread atualiza o resultado final com sua peça.

Observe que se você estiver fazendo operações numéricas simples, existem tipos mais simples
do que os tipos `Mutex<T>` fornecidos pelo [módulo `std::sync::atomic` do
biblioteca padrão][atomic]<!-- ignore -->. Esses tipos fornecem dados seguros, simultâneos,
acesso atômico a tipos primitivos. Optamos por usar `Mutex<T>` com um primitivo
digite este exemplo para que possamos nos concentrar em como o `Mutex<T>` funciona.

<!-- Old headings. Do not remove or links may break. -->

<a id="similarities-between-refcelltrct-and-mutextarct"></a>

### Comparando `RefCell<T>` / `Rc<T>` e `Mutex<T>` / `Arc<T>`

Você deve ter notado que `counter` é imutável, mas poderíamos obter um
referência mutável ao valor dentro dela; isso significa que `Mutex<T>` fornece
mutabilidade interior, como faz a família `Cell`. Da mesma forma que usamos
` RefCell<T> `no Capítulo 15 para nos permitir alterar o conteúdo dentro de um` Rc<T> `, nós
use` Mutex<T> `para alterar o conteúdo dentro de um` Arc<T>`.

Outro detalhe a ser observado é que Rust não pode protegê-lo de todos os tipos de lógica
erros quando você usa `Mutex<T>`. Lembre-se do Capítulo 15 que usar ` Rc<T>`veio
com o risco de criar ciclos de referência, onde dois valores ` Rc<T>`referem-se a
entre si, causando vazamentos de memória. Da mesma forma, ` Mutex<T>`apresenta o risco de
criando _deadlocks_. Ocorrem quando uma operação precisa bloquear dois recursos
e dois threads adquiriram, cada um, um dos bloqueios, fazendo com que esperassem
um ao outro para sempre. Se você estiver interessado em impasses, tente criar um Rust
programa que apresenta um impasse; então, pesquisar estratégias de mitigação de impasses para
mutexes em qualquer linguagem e tente implementá-los no Rust. O
documentação API da biblioteca padrão para ofertas ` Mutex<T>`e ` MutexGuard`
informações úteis.

Concluiremos este capítulo falando sobre `Send` e `Sync` traits e
como podemos usá-los com tipos personalizados.

[atomic]: ../std/sync/atomic/index.html
