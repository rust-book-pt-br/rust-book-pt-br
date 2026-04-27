
<!-- Old headings. Do not remove or links may break. -->

<a id="yielding"></a>

### Cedendo Controle ao Runtime

Lembre-se da seção [“Nosso Primeiro Programa Async”][async-program]<!-- ignore
-->: em cada ponto de await, Rust dá ao runtime uma chance de pausar a tarefa e
alternar para outra se o future que está sendo aguardado ainda não estiver
pronto. O inverso também é verdadeiro: Rust _só_ pausa blocos async e devolve
controle ao runtime em um ponto de await. Tudo entre pontos de await é
síncrono.

Isso significa que, se você fizer um monte de trabalho em um bloco async sem um
ponto de await, esse future impedirá que quaisquer outros futures façam
progresso. Às vezes você pode ouvir isso descrito como um future deixando
outros futures em _starvation_. Em alguns casos, isso pode não ser um grande
problema. No entanto, se você estiver fazendo algum tipo de setup caro ou
trabalho de longa duração, ou se tiver um future que continuará realizando uma
tarefa específica indefinidamente, precisará pensar sobre quando e onde devolver
controle ao runtime.

Vamos simular uma operação de longa duração para ilustrar o problema de
starvation e depois explorar como resolvê-lo. A Listagem 17-14 apresenta uma
função `slow`.

<Listing number="17-14" caption="Usando `thread::sleep` para simular operações lentas" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-14/src/main.rs:slow}}
```

</Listing>

Esse código usa `std::thread::sleep` em vez de `trpl::sleep`, de modo que
chamar `slow` bloqueará a thread atual por alguns milissegundos. Podemos usar
`slow` para representar operações do mundo real que são de longa duração e
bloqueantes.

Na Listagem 17-15, usamos `slow` para emular esse tipo de trabalho CPU-bound em
um par de futures.

<Listing number="17-15" caption="Chamando a função `slow` para simular operações lentas" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-15/src/main.rs:slow-futures}}
```

</Listing>

Cada future devolve controle ao runtime somente _depois_ de realizar várias
operações lentas. Se você executar esse código, verá esta saída:

<!-- manual-regeneration
cd listings/ch17-async-await/listing-17-15/
cargo run
copy just the output
-->

```text
'a' started.
'a' ran for 30ms
'a' ran for 10ms
'a' ran for 20ms
'b' started.
'b' ran for 75ms
'b' ran for 10ms
'b' ran for 15ms
'b' ran for 350ms
'a' finished.
```

Assim como na Listagem 17-5, em que usamos `trpl::select` para colocar futures
que buscam duas URLs para competir, `select` ainda termina assim que `a` é
concluído. Porém, não há intercalação entre as chamadas a `slow` nos dois
futures. O future `a` faz todo o seu trabalho até a chamada a `trpl::sleep` ser
aguardada; então o future `b` faz todo o seu trabalho até sua própria chamada a
`trpl::sleep` ser aguardada; por fim, o future `a` completa. Para permitir que
ambos os futures façam progresso entre suas tarefas lentas, precisamos de
pontos de await para devolver controle ao runtime. Isso significa que
precisamos de algo que possamos aguardar!

Já conseguimos ver esse tipo de transferência acontecendo na Listagem 17-15: se
removêssemos o `trpl::sleep` no fim do future `a`, ele completaria sem que o
future `b` rodasse _de forma alguma_. Vamos tentar usar a função `trpl::sleep`
como ponto de partida para permitir que as operações se alternem fazendo
progresso, como mostrado na Listagem 17-16.

<Listing number="17-16" caption="Usando `trpl::sleep` para permitir que operações se alternem fazendo progresso" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-16/src/main.rs:here}}
```

</Listing>

Adicionamos chamadas a `trpl::sleep` com pontos de await entre cada chamada a
`slow`. Agora o trabalho dos dois futures é intercalado:

<!-- manual-regeneration
cd listings/ch17-async-await/listing-17-16
cargo run
copy just the output
-->

```text
'a' started.
'a' ran for 30ms
'b' started.
'b' ran for 75ms
'a' ran for 10ms
'b' ran for 10ms
'a' ran for 20ms
'b' ran for 15ms
'a' finished.
```

O future `a` ainda roda por um tempo antes de entregar o controle a `b`, porque
ele chama `slow` antes de chamar `trpl::sleep` pela primeira vez. Depois disso,
porém, os futures alternam entre si cada vez que um deles atinge um ponto de
await. Neste caso, fizemos isso depois de cada chamada a `slow`, mas poderíamos
dividir o trabalho da maneira que fizesse mais sentido para nós.

Não queremos realmente _dormir_ aqui, porém: queremos fazer progresso o mais
rápido possível. Só precisamos devolver controle ao runtime. Podemos fazer isso
diretamente usando a função `trpl::yield_now`. Na Listagem 17-17, substituímos
todas aquelas chamadas a `trpl::sleep` por `trpl::yield_now`.

<Listing number="17-17" caption="Usando `yield_now` para permitir que operações se alternem fazendo progresso" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-17/src/main.rs:yields}}
```

</Listing>

Esse código expressa a intenção real com mais clareza e pode ser
significativamente mais rápido do que usar `sleep`, porque timers como o usado
por `sleep` muitas vezes têm limites sobre sua granularidade. A versão de
`sleep` que estamos usando, por exemplo, sempre dormirá por pelo menos um
milissegundo, mesmo que passemos uma `Duration` de um nanossegundo. Novamente,
computadores modernos são _rápidos_: eles conseguem fazer muita coisa em um
milissegundo!

Isso significa que async pode ser útil até mesmo para tarefas compute-bound,
dependendo do que mais seu programa está fazendo, porque fornece uma ferramenta
útil para estruturar as relações entre diferentes partes do programa (mas com o
custo da sobrecarga da máquina de estados async). Essa é uma forma de
_multitarefa cooperativa_, em que cada future tem o poder de determinar quando
entrega controle por meio de pontos de await. Portanto, cada future também tem
a responsabilidade de evitar bloquear por tempo demais. Em alguns sistemas
operacionais embarcados baseados em Rust, esse é o _único_ tipo de
multitarefa!

Em código do mundo real, é claro, você normalmente não alternará chamadas de
função com pontos de await em cada linha. Embora ceder controle dessa forma
seja relativamente barato, não é gratuito. Em muitos casos, tentar dividir uma
tarefa compute-bound pode torná-la significativamente mais lenta, então às
vezes é melhor para o desempenho _geral_ deixar uma operação bloquear por pouco
tempo. Sempre meça para ver quais são os gargalos reais de desempenho do seu
código. Porém, vale manter essa dinâmica subjacente em mente se você _estiver_
vendo muito trabalho acontecer em série quando esperava que acontecesse de
forma concorrente!

### Construindo Nossas Próprias Abstrações Async

Também podemos compor futures para criar novos padrões. Por exemplo, podemos
construir uma função `timeout` com os blocos de construção async que já temos.
Quando terminarmos, o resultado será outro bloco de construção que poderíamos
usar para criar ainda mais abstrações async.

A Listagem 17-18 mostra como esperaríamos que esse `timeout` funcionasse com um
future lento.

<Listing number="17-18" caption="Usando nosso `timeout` imaginado para executar uma operação lenta com limite de tempo" file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-18/src/main.rs:here}}
```

</Listing>

Vamos implementar isso! Para começar, vamos pensar sobre a API de `timeout`:

- Ela precisa ser uma função async para que possamos aguardá-la.
- Seu primeiro parâmetro deve ser um future a executar. Podemos torná-la
  genérica para permitir que funcione com qualquer future.
- Seu segundo parâmetro será o tempo máximo de espera. Se usarmos uma
  `Duration`, isso facilitará passá-la adiante para `trpl::sleep`.
- Ela deve retornar um `Result`. Se o future completar com sucesso, o `Result`
  será `Ok` com o valor produzido pelo future. Se o timeout expirar primeiro, o
  `Result` será `Err` com a duração pela qual o timeout esperou.

A Listagem 17-19 mostra essa declaração.

<!-- This is not tested because it intentionally does not compile. -->

<Listing number="17-19" caption="Definindo a assinatura de `timeout`" file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-19/src/main.rs:declaration}}
```

</Listing>

Isso satisfaz nossos objetivos para os tipos. Agora vamos pensar sobre o
_comportamento_ de que precisamos: queremos colocar o future recebido para
competir contra a duração. Podemos usar `trpl::sleep` para criar um future de
timer a partir da duração e usar `trpl::select` para executar esse timer junto
com o future que o chamador passa.

Na Listagem 17-20, implementamos `timeout` fazendo `match` sobre o resultado de
aguardar `trpl::select`.

<Listing number="17-20" caption="Definindo `timeout` com `select` e `sleep`" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-20/src/main.rs:implementation}}
```

</Listing>

A implementação de `trpl::select` não é justa: ela sempre faz `poll` nos
argumentos na ordem em que eles são passados (outras implementações de `select`
podem escolher aleatoriamente qual argumento consultar primeiro). Assim,
passamos `future_to_try` para `select` primeiro, para que ele tenha a chance de
completar mesmo que `max_time` seja uma duração muito curta. Se
`future_to_try` terminar primeiro, `select` retornará `Left` com a saída de
`future_to_try`. Se `timer` terminar primeiro, `select` retornará `Right` com a
saída do timer, `()`.

Se `future_to_try` for bem-sucedido e obtivermos `Left(output)`, retornamos
`Ok(output)`. Se o timer de sleep expirar em vez disso e obtivermos
`Right(())`, ignoramos `()` com `_` e retornamos `Err(max_time)`.

Com isso, temos um `timeout` funcional construído a partir de dois outros
helpers async. Se executarmos nosso código, ele imprimirá o modo de falha após
o timeout:

```text
Failed after 2 seconds
```

Como futures compõem com outros futures, você pode construir ferramentas muito
poderosas usando blocos de construção async menores. Por exemplo, você pode
usar essa mesma abordagem para combinar timeouts com novas tentativas e, por
sua vez, usar isso com operações como chamadas de rede (como aquelas da
Listagem 17-5).

Na prática, você normalmente trabalhará diretamente com `async` e `await`, e
secundariamente com funções como `select` e macros como `join!` para controlar
como os futures mais externos são executados.

Agora vimos várias maneiras de trabalhar com múltiplos futures ao mesmo tempo.
A seguir, veremos como trabalhar com múltiplos futures em uma sequência ao
longo do tempo usando _streams_.

[async-program]: ch17-01-futures-and-syntax.html#our-first-async-program
