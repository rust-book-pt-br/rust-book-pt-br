# Fundamentos da Programação Assíncrona: Async, Await, Futures e Streams

Muitas operações que pedimos ao computador para fazer podem demorar um pouco
para terminar. Seria ótimo se pudéssemos fazer outra coisa enquanto esperamos
esses processos longos serem concluídos. Computadores modernos oferecem duas
técnicas para trabalhar em mais de uma operação ao mesmo tempo: paralelismo e
concorrência. A lógica dos nossos programas, porém, é escrita de forma
predominantemente linear. Gostaríamos de conseguir especificar as operações que
um programa deve executar e os pontos em que uma função poderia pausar para que
alguma outra parte do programa rodasse no lugar dela, sem precisar especificar
de antemão exatamente a ordem e a maneira como cada pedaço de código deve
rodar. _Programação assíncrona_ é uma abstração que nos permite expressar nosso
código em termos de possíveis pontos de pausa e resultados eventuais, cuidando
dos detalhes de coordenação para nós.

Este capítulo se baseia no uso de threads para paralelismo e concorrência no
Capítulo 16, introduzindo uma abordagem alternativa para escrever código: os
futures e streams de Rust, a sintaxe `async` e `await` que nos permite
expressar como operações poderiam ser assíncronas, e crates de terceiros que
implementam runtimes assíncronos: código que gerencia e coordena a execução de
operações assíncronas.

Vamos considerar um exemplo. Digamos que você esteja exportando um vídeo que
criou de uma celebração familiar, uma operação que poderia levar de minutos a
horas. A exportação do vídeo usará o máximo possível de CPU e GPU. Se você
tivesse apenas um núcleo de CPU e seu sistema operacional não pausasse essa
exportação até ela terminar, isto é, se ele executasse a exportação
_sincronamente_, você não conseguiria fazer mais nada no computador enquanto
essa tarefa estivesse rodando. Essa seria uma experiência bastante frustrante.
Felizmente, o sistema operacional do seu computador pode interromper, e de fato
interrompe, a exportação de forma invisível com frequência suficiente para
permitir que você faça outros trabalhos simultaneamente.

Agora digamos que você esteja baixando um vídeo compartilhado por outra pessoa,
o que também pode levar um tempo, mas não ocupa tanto tempo de CPU. Nesse caso,
a CPU precisa esperar que os dados cheguem da rede. Embora você possa começar a
ler os dados assim que eles começam a chegar, pode levar algum tempo até que
todos apareçam. Mesmo depois que todos os dados estejam presentes, se o vídeo
for muito grande, pode levar pelo menos um ou dois segundos para carregar tudo.
Isso pode não parecer muito, mas é muito tempo para um processador moderno, que
consegue executar bilhões de operações por segundo. Novamente, seu sistema
operacional interromperá seu programa de forma invisível para permitir que a
CPU faça outro trabalho enquanto espera a chamada de rede terminar.

A exportação de vídeo é um exemplo de operação _CPU-bound_ ou
_compute-bound_. Ela é limitada pela velocidade potencial de processamento de
dados do computador dentro da CPU ou GPU, e por quanto dessa velocidade pode
ser dedicado à operação. O download do vídeo é um exemplo de operação
_I/O-bound_, porque é limitado pela velocidade de _entrada e saída_ do
computador; ele só consegue avançar tão rápido quanto os dados conseguem ser
enviados pela rede.

Em ambos os exemplos, as interrupções invisíveis do sistema operacional
fornecem uma forma de concorrência. Essa concorrência acontece apenas no nível
do programa inteiro, porém: o sistema operacional interrompe um programa para
permitir que outros programas façam trabalho. Em muitos casos, como entendemos
nossos programas em um nível muito mais granular do que o sistema operacional,
conseguimos identificar oportunidades de concorrência que o sistema operacional
não consegue ver.

Por exemplo, se estivermos criando uma ferramenta para gerenciar downloads de
arquivos, deveríamos conseguir escrever nosso programa de modo que iniciar um
download não trave a interface, e os usuários deveriam poder iniciar vários
downloads ao mesmo tempo. Muitas APIs de sistemas operacionais para interagir
com a rede são _bloqueantes_, porém; isto é, bloqueiam o progresso do programa
até que os dados que estão processando estejam completamente prontos.

> Nota: É assim que _a maioria_ das chamadas de função funciona, se você pensar
> bem. No entanto, o termo _bloqueante_ geralmente é reservado para chamadas de
> função que interagem com arquivos, rede ou outros recursos do computador,
> porque esses são os casos em que um programa individual se beneficiaria se a
> operação fosse _não_ bloqueante.

Poderíamos evitar bloquear a thread principal criando uma thread dedicada para
baixar cada arquivo. No entanto, a sobrecarga dos recursos do sistema usados
por essas threads acabaria se tornando um problema. Seria preferível que a
chamada não bloqueasse logo de início e, em vez disso, pudéssemos definir um
conjunto de tarefas que gostaríamos que nosso programa concluísse e permitir
que o runtime escolhesse a melhor ordem e a melhor maneira de executá-las.

É exatamente isso que a abstração _async_ (abreviação de _asynchronous_) de
Rust nos oferece. Neste capítulo, você aprenderá tudo sobre async enquanto
abordamos os seguintes tópicos:

- Como usar a sintaxe `async` e `await` de Rust e executar funções assíncronas
  com um runtime
- Como usar o modelo async para resolver alguns dos mesmos desafios que vimos
  no Capítulo 16
- Como multithreading e async fornecem soluções complementares que você pode
  combinar em muitos casos

Antes de vermos como async funciona na prática, porém, precisamos fazer um
breve desvio para discutir as diferenças entre paralelismo e concorrência.

## Paralelismo e Concorrência

Até aqui, tratamos paralelismo e concorrência como se fossem praticamente
intercambiáveis. Agora precisamos distingui-los com mais precisão, porque as
diferenças aparecerão quando começarmos a trabalhar.

Considere as diferentes maneiras como uma equipe poderia dividir o trabalho em
um projeto de software. Você poderia atribuir várias tarefas a uma única pessoa
da equipe, atribuir uma tarefa a cada pessoa ou usar uma combinação das duas
abordagens.

Quando uma pessoa trabalha em várias tarefas diferentes antes que qualquer uma
delas esteja completa, isso é _concorrência_. Uma maneira de implementar
concorrência é parecida com ter dois projetos diferentes abertos no seu
computador e, quando você fica entediado ou travado em um projeto, alterna para
o outro. Você é apenas uma pessoa, então não consegue avançar nas duas tarefas
exatamente ao mesmo tempo, mas consegue realizar multitarefa, avançando em uma
por vez ao alternar entre elas (veja a Figura 17-1).

<figure>

<img src="img/trpl17-01.svg" class="center" alt="Um diagrama com caixas empilhadas rotuladas Tarefa A e Tarefa B, com losangos representando subtarefas. Setas apontam de A1 para B1, de B1 para A2, de A2 para B2, de B2 para A3, de A3 para A4 e de A4 para B3. As setas entre as subtarefas cruzam as caixas entre a Tarefa A e a Tarefa B." />

<figcaption>Figura 17-1: Um fluxo de trabalho concorrente, alternando entre a Tarefa A e a Tarefa B</figcaption>

</figure>

Quando a equipe divide um grupo de tarefas fazendo cada pessoa assumir uma
tarefa e trabalhar nela sozinha, isso é _paralelismo_. Cada pessoa da equipe
consegue avançar exatamente ao mesmo tempo (veja a Figura 17-2).

<figure>

<img src="img/trpl17-02.svg" class="center" alt="Um diagrama com caixas empilhadas rotuladas Tarefa A e Tarefa B, com losangos representando subtarefas. Setas apontam de A1 para A2, de A2 para A3, de A3 para A4, de B1 para B2 e de B2 para B3. Nenhuma seta cruza entre as caixas da Tarefa A e da Tarefa B." />

<figcaption>Figura 17-2: Um fluxo de trabalho paralelo, em que o trabalho acontece nas Tarefas A e B de forma independente</figcaption>

</figure>

Em ambos os fluxos de trabalho, talvez você precise coordenar entre diferentes
tarefas. Talvez você tenha pensado que a tarefa atribuída a uma pessoa era
totalmente independente do trabalho de todas as outras, mas na verdade ela
exige que outra pessoa da equipe termine sua tarefa primeiro. Parte do trabalho
poderia ser feita em paralelo, mas parte dele era na verdade _serial_: só
poderia acontecer em série, uma tarefa depois da outra, como na Figura 17-3.

<figure>

<img src="img/trpl17-03.svg" class="center" alt="Um diagrama com caixas empilhadas rotuladas Tarefa A e Tarefa B, com losangos representando subtarefas. Na Tarefa A, setas apontam de A1 para A2, de A2 para um par de linhas verticais grossas, como um símbolo de pausa, e desse símbolo para A3. Na Tarefa B, setas apontam de B1 para B2, de B2 para B3, de B3 para A3 e de B3 para B4." />

<figcaption>Figura 17-3: Um fluxo de trabalho parcialmente paralelo, em que o trabalho acontece nas Tarefas A e B de forma independente até que a Tarefa A3 fique bloqueada nos resultados da Tarefa B3.</figcaption>

</figure>

Da mesma forma, você pode perceber que uma das suas próprias tarefas depende de
outra tarefa sua. Agora seu trabalho concorrente também se tornou serial.

Paralelismo e concorrência também podem se cruzar. Se você descobrir que uma
pessoa da equipe está travada até você terminar uma das suas tarefas,
provavelmente concentrará todos os seus esforços nessa tarefa para
“desbloqueá-la”. Vocês não conseguem mais trabalhar em paralelo e você também
não consegue mais trabalhar de forma concorrente nas suas próprias tarefas.

A mesma dinâmica básica entra em jogo com software e hardware. Em uma máquina
com um único núcleo de CPU, a CPU consegue executar apenas uma operação por vez,
mas ainda consegue trabalhar de forma concorrente. Usando ferramentas como
threads, processos e async, o computador pode pausar uma atividade e alternar
para outras antes de, eventualmente, voltar à primeira atividade. Em uma
máquina com múltiplos núcleos de CPU, ele também consegue fazer trabalho em
paralelo. Um núcleo pode estar executando uma tarefa enquanto outro núcleo
executa outra completamente não relacionada, e essas operações realmente
acontecem ao mesmo tempo.

Executar código async em Rust geralmente acontece de forma concorrente.
Dependendo do hardware, do sistema operacional e do runtime async que estamos
usando (falaremos mais sobre runtimes async em breve), essa concorrência também
pode usar paralelismo por baixo dos panos.

Agora, vamos mergulhar em como a programação async em Rust realmente funciona.
