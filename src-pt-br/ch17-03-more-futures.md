
<!-- Old headings. Do not remove or links may break. -->

<a id="yielding"></a>

### Entregando controle ao tempo de execução

Lembre-se da seção [“Nosso primeiro programa async”][async-program]<!-- ignore -->
de que, em cada ponto `await`, Rust dá ao runtime a chance de pausar a
tarefa e mude para outra se o future aguardado não estiver pronto. O
o inverso também é verdadeiro: Rust _apenas_ pausa os blocos async e devolve o controle para
um tempo de execução em um ponto await. Tudo entre os pontos await é síncrono.

Isso significa que se você fizer muito trabalho em um bloco async sem um ponto await,
que future bloqueará qualquer outro futures de progredir. Você pode às vezes
ouça isso sendo chamado de um future _faminto_ outro futures. Em alguns casos,
isso pode não ser grande coisa. No entanto, se você estiver fazendo algum tipo de trabalho caro
configuração ou trabalho de longa duração, ou se você tiver um future que continuará fazendo alguns
tarefa específica indefinidamente, você precisará pensar sobre quando e onde entregar
controle de volta ao tempo de execução.

Vamos simular uma operação demorada para ilustrar o problema de starvation e,
depois, explorar como resolvê-lo. A Listagem 17-14 apresenta uma função `slow`.

<Listing number="17-14" caption="Usando `thread::sleep` para simular operações lentas" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-14/src/main.rs:slow}}
```

</Listing>

Este código usa `std::thread::sleep` em vez de `trpl::sleep` para que a chamada
`slow ` bloqueará o thread atual por alguns milissegundos. Nós podemos
use`slow` para substituir operações do mundo real que são de longa duração e
bloqueio.

Na Listagem 17-15, usamos `slow` para emular esse tipo de trabalho vinculado à CPU em
um par de futures.

<Listing number="17-15" caption="Chamando a função `slow` para simular operações lentas" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-15/src/main.rs:slow-futures}}
```

</Listing>

Cada future devolve o controle ao tempo de execução somente _depois_ de realizar um monte
de operações lentas. Se você executar este código, verá esta saída:

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

Assim como na Listagem 17-5, onde usamos `trpl::select` para correr com futures buscando dois
URLs, `select` ainda termina assim que `a` é concluído. Não há intercalação
entre as chamadas para `slow` nos dois futures. O `a` future faz tudo
de seu trabalho até que a chamada `trpl::sleep` seja aguardada, então o `b` future faz
todo o seu trabalho até que sua própria chamada `trpl::sleep` seja aguardada e, finalmente, o
`a` future concluído. Para permitir que ambos futures progridam entre seus movimentos lentos
tarefas, precisamos de pontos await para que possamos devolver o controle ao tempo de execução. Isso
significa que precisamos de algo que possamos await!

Já podemos ver esse tipo de transferência acontecendo na Listagem 17-15: se
removeu o `trpl::sleep` no final do `a` future, ele seria concluído
sem o `b` future funcionando _de todo_. Vamos tentar usar o `trpl::sleep`
funcionar como um ponto de partida para permitir que as operações sejam interrompidas e progridam,
conforme mostrado na Listagem 17-16.

<Listing number="17-16" caption="Usando `trpl::sleep` para permitir que operações cedam lugar enquanto avançam" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-16/src/main.rs:here}}
```

</Listing>

Adicionamos chamadas `trpl::sleep` com pontos await entre cada chamada para `slow`.
Agora os dois trabalhos do futures estão intercalados:

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

O `a` future ainda funciona um pouco antes de passar o controle para `b`, porque
ele chama ` slow`antes mesmo de chamar ` trpl::sleep`, mas depois disso o futures
troque para frente e para trás cada vez que um deles atingir um ponto await. Neste caso, nós
fizemos isso após cada chamada para ` slow`, mas poderíamos interromper o trabalho em
qualquer maneira que faça mais sentido para nós.

Na verdade, não queremos _dormir_ aqui: queremos progredir o mais rápido
como pudermos. Precisamos apenas devolver o controle ao tempo de execução. Nós podemos fazer isso
diretamente, usando a função `trpl::yield_now`. Na Listagem 17-17, substituímos
todas aquelas chamadas ` trpl::sleep`com ` trpl::yield_now`.

<Listing number="17-17" caption="Usando `yield_now` para permitir que operações cedam lugar enquanto avançam" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-17/src/main.rs:yields}}
```

</Listing>

Este código é mais claro sobre a intenção real e pode ser significativamente
mais rápido do que usar `sleep`, porque temporizadores como o usado por ` sleep`geralmente
têm limites sobre o quão granulares eles podem ser. A versão do ` sleep`que estamos usando,
por exemplo, sempre dormirá por pelo menos um milissegundo, mesmo que passemos um
` Duration`de um nanossegundo. Novamente, os computadores modernos são _rápidos_: eles podem fazer uma
muito em um milissegundo!

Isso significa que async pode ser útil até mesmo para tarefas vinculadas a computação, dependendo
o que mais seu programa está fazendo, porque fornece uma ferramenta útil para
estruturar as relações entre diferentes partes do programa (mas em um nível
custo da sobrecarga da máquina de estado async). Esta é uma forma de
_multitarefa cooperativa_, onde cada future tem o poder de determinar quando
ele transfere o controle por meio de pontos await. Portanto, cada future também possui o
responsabilidade de evitar o bloqueio por muito tempo. Em alguns sistemas incorporados baseados em Rust
sistemas operacionais, este é o _único_ tipo de multitarefa!

No código do mundo real, você normalmente não alternará chamadas de função com await
pontos em cada linha, é claro. Embora ceder o controle desta forma seja
relativamente barato, não é gratuito. Em muitos casos, tentar romper um
tarefa vinculada à computação pode torná-la significativamente mais lenta, então às vezes é melhor
para desempenho _geral_ permitir que uma operação seja bloqueada brevemente. Sempre
medir para ver quais são os gargalos reais de desempenho do seu código. O
dinâmica subjacente é importante ter em mente, se você _está_ vendo um
muito trabalho acontecendo em série que você esperava que acontecesse simultaneamente!

### Construindo nossas próprias abstrações assíncronas

Também podemos compor futures juntos para criar novos padrões. Por exemplo, podemos
construir uma função `timeout` com os blocos de construção async que já temos. Quando
terminamos, o resultado será outro bloco de construção que poderíamos usar para criar
ainda mais abstrações async.

A Listagem 17-18 mostra como esperaríamos que este `timeout` funcionasse com uma velocidade lenta
future.

<Listing number="17-18" caption="Usando nosso `timeout` imaginado para executar uma operação lenta com limite de tempo" file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-18/src/main.rs:here}}
```

</Listing>

Vamos implementar isso! Para começar, vamos pensar na API do `timeout`:

- Ela precisa ser uma função async para que possamos await.
- Seu primeiro parâmetro deverá ser um future para rodar. Podemos torná-lo genérico para permitir
  para funcionar com qualquer future.
- Seu segundo parâmetro será o tempo máximo de espera. Se usarmos um `Duration`,
  isso facilitará a transferência para ` trpl::sleep`.
- Deve retornar um ` Result`. Se o future for concluído com sucesso, o
 ` Result `será` Ok `com o valor produzido pelo future. Se o tempo limite
  decorre primeiro, o` Result `será` Err`com a duração que o tempo limite
  esperei.

A Listagem 17-19 mostra esta declaração.

<!-- This is not tested because it intentionally does not compile. -->

<Listing number="17-19" caption="Definindo a assinatura de `timeout`" file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-19/src/main.rs:declaration}}
```

</Listing>

Isso satisfaz nossos objetivos para os tipos. Agora vamos pensar sobre o _comportamento_ que
necessidade: queremos competir com o future transmitido em relação à duração. Podemos usar
`trpl::sleep ` para criar um cronômetro future a partir da duração e usar`trpl::select`
para executar esse cronômetro com o future que o chamador passa.

In Listing 17-20, we implement `timeout` by matching on the result of awaiting
`trpl::select`.

<Listing number="17-20" caption="Definindo `timeout` com `select` e `sleep`" file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-20/src/main.rs:implementation}}
```

</Listing>

A implementação do `trpl::select` não é justa: ele sempre pesquisa argumentos em
a ordem em que são passados ​​(outras implementações `select` serão
escolher aleatoriamente qual argumento pesquisar primeiro). Assim, passamos `future_to_try` para
`select ` primeiro para que tenha a chance de ser concluído mesmo que`max_time ` seja muito
curta duração. Se`future_to_try ` terminar primeiro,`select ` retornará`Left `
com a saída de` future_to_try `. Se` timer `terminar primeiro,` select `irá
retorne` Right `com a saída do temporizador de` ()`.

Se o `future_to_try` for bem-sucedido e obtivermos um `Left(output)`, retornamos
` Ok(output) `. Se o temporizador terminar e obtivermos um` Right(()) `,
ignore` () `com` _ `e retorne` Err(max_time)`.

Com isso, temos um `timeout` funcional construído a partir de dois outros auxiliares async. Se
executamos nosso código, ele imprimirá o modo de falha após o tempo limite:

```text
Failed after 2 seconds
```

Como o futures é composto com outros futures, você pode criar ferramentas realmente poderosas
usando blocos de construção async menores. Por exemplo, você pode usar este mesmo
abordagem para combinar tempos limite com novas tentativas e, por sua vez, usar aqueles com
operações como chamadas de rede (como as da Listagem 17-5).

Na prática, você normalmente trabalhará diretamente com `async` e `await`, e
secundariamente com funções como ` select`e macros como ` join!`
macro para controlar como o futures mais externo é executado.

Já vimos várias maneiras de trabalhar com vários futures ao mesmo tempo.
A seguir, veremos como podemos trabalhar com vários futures em uma sequência
tempo com _streams_.

[async-program]: ch17-01-futures-and-syntax.html#our-first-async-program
