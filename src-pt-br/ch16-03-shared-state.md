## Concorrência com Estado Compartilhado

A passagem de mensagens é uma ótima maneira de lidar com concorrência, mas não
é a única. Outro método seria permitir que várias threads acessassem os mesmos
dados compartilhados. Considere novamente esta parte do slogan da documentação
da linguagem Go: “Não se comunique compartilhando memória.”

Como seria a comunicação por meio do compartilhamento de memória? Além disso,
por que entusiastas da passagem de mensagens alertariam contra o uso de
memória compartilhada?

De certa forma, canais em qualquer linguagem de programação são semelhantes ao
ownership único, porque, depois que você transfere um valor por um canal, não
deve mais usar esse valor. Concorrência com memória compartilhada é como
ownership múltiplo: várias threads podem acessar o mesmo local de memória ao
mesmo tempo. Como você viu no Capítulo 15, em que smart pointers tornaram
possível o ownership múltiplo, o ownership múltiplo pode adicionar
complexidade, porque esses diferentes owners precisam ser gerenciados. O
sistema de tipos e as regras de ownership de Rust ajudam muito a fazer esse
gerenciamento corretamente. Como exemplo, vejamos mutexes, uma das primitivas
de concorrência mais comuns para memória compartilhada.

<!-- Old headings. Do not remove or links may break. -->

<a id="using-mutexes-to-allow-access-to-data-from-one-thread-at-a-time"></a>

### Controlando Acesso com Mutexes

_Mutex_ é uma abreviação de _mutual exclusion_ (_exclusão mútua_), no sentido
de que um mutex permite que apenas uma thread acesse determinados dados em um
dado momento. Para acessar os dados em um mutex, uma thread deve primeiro
sinalizar que quer acesso solicitando a aquisição do lock do mutex. O _lock_ é
uma estrutura de dados que faz parte do mutex e mantém registro de quem tem
acesso exclusivo aos dados naquele momento. Portanto, dizemos que o mutex
_protege_ os dados que contém por meio do sistema de locking.

Mutexes têm a reputação de serem difíceis de usar porque você precisa se
lembrar de duas regras:

1. Você deve tentar adquirir o lock antes de usar os dados.
2. Quando terminar de usar os dados protegidos pelo mutex, você deve liberar o
   lock para que outras threads possam adquiri-lo.

Como metáfora do mundo real para um mutex, imagine uma mesa-redonda em uma
conferência com apenas um microfone. Antes de uma pessoa no painel poder falar,
ela precisa pedir ou sinalizar que quer usar o microfone. Quando recebe o
microfone, pode falar pelo tempo que quiser e depois entregá-lo à próxima
pessoa que solicitar a palavra. Se alguém se esquecer de entregar o microfone
quando terminar, ninguém mais conseguirá falar. Se o gerenciamento do microfone
compartilhado der errado, o painel não funcionará como planejado!

Gerenciar mutexes corretamente pode ser incrivelmente complicado, e é por isso
que tantas pessoas se animam com canais. No entanto, graças ao sistema de tipos
e às regras de ownership de Rust, você não consegue errar ao adquirir e liberar
locks.

#### A API de `Mutex<T>`

Como exemplo de como usar um mutex, vamos começar usando um mutex em um
contexto single-threaded, como mostrado na Listagem 16-12.

<Listing number="16-12" file-name="src/main.rs" caption="Explorando a API de `Mutex<T>` em um contexto single-threaded, por simplicidade">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-12/src/main.rs}}
```

</Listing>

Como acontece com muitos tipos, criamos um `Mutex<T>` usando a função associada
`new`. Para acessar os dados dentro do mutex, usamos o método `lock` para
adquirir o lock. Essa chamada bloqueará a thread atual para que ela não possa
fazer nenhum trabalho até chegar nossa vez de ter o lock.

A chamada a `lock` falharia se outra thread que estava segurando o lock tivesse
entrado em pânico. Nesse caso, ninguém jamais conseguiria obter o lock, então
escolhemos chamar `unwrap` e fazer esta thread entrar em pânico se estivermos
nessa situação.

Depois de adquirir o lock, podemos tratar o valor de retorno, chamado `num`
neste caso, como uma referência mutável aos dados internos. O sistema de tipos
garante que adquirimos um lock antes de usar o valor em `m`. O tipo de `m` é
`Mutex<i32>`, não `i32`, então _precisamos_ chamar `lock` para poder usar o
valor `i32`. Não podemos esquecer; caso contrário, o sistema de tipos não nos
deixará acessar o `i32` interno.

A chamada a `lock` retorna um tipo chamado `MutexGuard`, envolvido em um
`LockResult` que tratamos com a chamada a `unwrap`. O tipo `MutexGuard`
implementa `Deref` para apontar para nossos dados internos; esse tipo também
tem uma implementação de `Drop` que libera o lock automaticamente quando um
`MutexGuard` sai de escopo, o que acontece no fim do escopo interno. Como
resultado, não corremos o risco de esquecer de liberar o lock e impedir que o
mutex seja usado por outras threads, porque a liberação do lock acontece
automaticamente.

Depois de liberar o lock, podemos imprimir o valor do mutex e ver que
conseguimos alterar o `i32` interno para `6`.

<!-- Old headings. Do not remove or links may break. -->

<a id="sharing-a-mutext-between-multiple-threads"></a>

#### Acesso Compartilhado a `Mutex<T>`

Agora vamos tentar compartilhar um valor entre várias threads usando
`Mutex<T>`. Vamos iniciar 10 threads e fazer cada uma incrementar um contador
em 1, de modo que o contador vá de 0 a 10. O exemplo da Listagem 16-13 terá um
erro de compilação, e usaremos esse erro para aprender mais sobre como usar
`Mutex<T>` e como Rust nos ajuda a usá-lo corretamente.

<Listing number="16-13" file-name="src/main.rs" caption="Dez threads, cada uma incrementando um contador protegido por um `Mutex<T>`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-13/src/main.rs}}
```

</Listing>

Criamos uma variável `counter` para armazenar um `i32` dentro de um
`Mutex<T>`, como fizemos na Listagem 16-12. Em seguida, criamos 10 threads
iterando sobre um intervalo de números. Usamos `thread::spawn` e damos a todas
as threads a mesma closure: uma closure que move o contador para dentro da
thread, adquire um lock no `Mutex<T>` chamando o método `lock` e então adiciona
1 ao valor dentro do mutex. Quando uma thread termina de executar sua closure,
`num` sai de escopo e libera o lock para que outra thread possa adquiri-lo.

Na thread principal, coletamos todos os join handles. Então, como fizemos na
Listagem 16-2, chamamos `join` em cada handle para garantir que todas as
threads terminem. Nesse ponto, a thread principal adquirirá o lock e imprimirá
o resultado deste programa.

Indicamos que este exemplo não compilaria. Agora vamos descobrir por quê!

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-13/output.txt}}
```

A mensagem de erro afirma que o valor `counter` foi movido na iteração anterior
do loop. Rust está nos dizendo que não podemos mover o ownership do lock
`counter` para várias threads. Vamos corrigir o erro do compilador com o método
de ownership múltiplo que discutimos no Capítulo 15.

#### Ownership Múltiplo com Múltiplas Threads

No Capítulo 15, demos um valor a vários owners usando o smart pointer `Rc<T>`
para criar um valor com contagem de referências. Vamos fazer o mesmo aqui e ver
o que acontece. Envolveremos o `Mutex<T>` em `Rc<T>` na Listagem 16-14 e
clonaremos o `Rc<T>` antes de mover o ownership para a thread.

<Listing number="16-14" file-name="src/main.rs" caption="Tentando usar `Rc<T>` para permitir que múltiplas threads tenham ownership do `Mutex<T>`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-14/src/main.rs}}
```

</Listing>

Mais uma vez, compilamos e obtemos... erros diferentes! O compilador está nos
ensinando bastante:

```console
{{#include ../listings/ch16-fearless-concurrency/listing-16-14/output.txt}}
```

Uau, essa mensagem de erro é bem verbosa! Aqui está a parte importante em que
devemos focar: `` `Rc<Mutex<i32>>` cannot be sent between threads safely ``. O
compilador também nos diz o motivo: `` the trait `Send` is not implemented for
`Rc<Mutex<i32>>` ``. Falaremos sobre `Send` na próxima seção: essa é uma das
traits que garante que os tipos que usamos com threads sejam adequados para
uso em situações concorrentes.

Infelizmente, `Rc<T>` não é seguro para ser compartilhado entre threads. Quando
`Rc<T>` gerencia a contagem de referências, ele incrementa a contagem a cada
chamada a `clone` e decrementa a contagem quando cada clone é descartado. Mas
ele não usa nenhuma primitiva de concorrência para garantir que alterações na
contagem não possam ser interrompidas por outra thread. Isso poderia levar a
contagens incorretas, bugs sutis que por sua vez poderiam causar vazamentos de
memória ou fazer um valor ser descartado antes de terminarmos de usá-lo. O que
precisamos é de um tipo exatamente como `Rc<T>`, mas que faça alterações na
contagem de referências de uma forma thread-safe.

#### Contagem de Referências Atômica com `Arc<T>`

Felizmente, `Arc<T>` _é_ um tipo como `Rc<T>` que é seguro para uso em
situações concorrentes. O _a_ significa _atomic_, ou seja, é um tipo com
_contagem de referências atômica_. Atômicos são outro tipo de primitiva de
concorrência que não abordaremos em detalhes aqui: consulte a documentação da
biblioteca padrão para [`std::sync::atomic`][atomic]<!-- ignore --> para mais
detalhes. Neste ponto, você só precisa saber que atômicos funcionam como tipos
primitivos, mas são seguros para compartilhar entre threads.

Você poderia se perguntar então por que todos os tipos primitivos não são
atômicos e por que os tipos da biblioteca padrão não são implementados para
usar `Arc<T>` por padrão. A razão é que thread safety vem com uma penalidade de
desempenho que você só quer pagar quando realmente precisa. Se você está apenas
realizando operações em valores dentro de uma única thread, seu código pode
rodar mais rápido se não precisar impor as garantias que atômicos fornecem.

Vamos voltar ao nosso exemplo: `Arc<T>` e `Rc<T>` têm a mesma API, então
corrigimos nosso programa alterando a linha `use`, a chamada a `new` e a
chamada a `clone`. O código da Listagem 16-15 finalmente compilará e rodará.

<Listing number="16-15" file-name="src/main.rs" caption="Usando `Arc<T>` para envolver o `Mutex<T>` e compartilhar ownership entre múltiplas threads">

```rust
{{#rustdoc_include ../listings/ch16-fearless-concurrency/listing-16-15/src/main.rs}}
```

</Listing>

Esse código imprimirá o seguinte:

<!-- Not extracting output because changes to this output aren't significant;
the changes are likely to be due to the threads running differently rather than
changes in the compiler -->

```text
Result: 10
```

Conseguimos! Contamos de 0 a 10, o que pode não parecer muito impressionante,
mas nos ensinou bastante sobre `Mutex<T>` e thread safety. Você também poderia
usar a estrutura desse programa para fazer operações mais complicadas do que
apenas incrementar um contador. Usando essa estratégia, você pode dividir um
cálculo em partes independentes, distribuir essas partes entre threads e então
usar um `Mutex<T>` para fazer cada thread atualizar o resultado final com sua
parte.

Observe que, se você estiver fazendo operações numéricas simples, existem tipos
mais simples que `Mutex<T>` fornecidos pelo [módulo `std::sync::atomic` da
biblioteca padrão][atomic]<!-- ignore -->. Esses tipos fornecem acesso atômico,
concorrente e seguro a tipos primitivos. Escolhemos usar `Mutex<T>` com um tipo
primitivo neste exemplo para que pudéssemos nos concentrar em como `Mutex<T>`
funciona.

<!-- Old headings. Do not remove or links may break. -->

<a id="similarities-between-refcelltrct-and-mutextarct"></a>

### Comparando `RefCell<T>`/`Rc<T>` e `Mutex<T>`/`Arc<T>`

Você deve ter notado que `counter` é imutável, mas que conseguimos obter uma
referência mutável ao valor dentro dele; isso significa que `Mutex<T>` fornece
mutabilidade interior, assim como a família `Cell`. Da mesma forma que usamos
`RefCell<T>` no Capítulo 15 para permitir mutar o conteúdo dentro de um
`Rc<T>`, usamos `Mutex<T>` para mutar o conteúdo dentro de um `Arc<T>`.

Outro detalhe a observar é que Rust não consegue proteger você de todos os
tipos de erro de lógica ao usar `Mutex<T>`. Lembre-se do Capítulo 15: usar
`Rc<T>` vinha com o risco de criar ciclos de referência, em que dois valores
`Rc<T>` apontam um para o outro, causando vazamentos de memória. De modo
semelhante, `Mutex<T>` vem com o risco de criar _deadlocks_. Eles ocorrem
quando uma operação precisa travar dois recursos e duas threads adquiriram,
cada uma, um dos locks, fazendo com que esperem uma pela outra para sempre. Se
você tiver interesse em deadlocks, tente criar um programa Rust que tenha um
deadlock; depois, pesquise estratégias de mitigação de deadlocks para mutexes
em qualquer linguagem e tente implementá-las em Rust. A documentação da API da
biblioteca padrão para `Mutex<T>` e `MutexGuard` oferece informações úteis.

Concluiremos este capítulo falando sobre as traits `Send` e `Sync` e como
podemos usá-las com tipos personalizados.

[atomic]: ../std/sync/atomic/index.html
