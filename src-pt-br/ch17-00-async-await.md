# Fundamentos da programação assíncrona: Async, Await, Futures e Streams

Muitas operações que pedimos ao computador podem demorar um pouco para serem
concluídas. Seria ótimo se pudéssemos fazer outra coisa enquanto esperamos
esses processos de longa duração terminarem. Os computadores modernos oferecem
duas técnicas para trabalhar em mais de uma operação ao mesmo tempo:
paralelismo e concorrência. Nossa lógica de programa, entretanto, é escrita de
maneira predominantemente linear. Gostaríamos de ser capazes de especificar as
operações que um programa deve realizar e os pontos em que uma função poderia
pausar e alguma outra parte do programa pudesse ser executada, sem a
necessidade de especificar antecipadamente exatamente a ordem e a maneira como
cada pedaço de código deve ser executado. _Programação assíncrona_ é uma
abstração que nos permite expressar nosso código em termos de possíveis pontos
de pausa e resultados futuros, enquanto ela cuida dos detalhes de coordenação
para nós.

Este capítulo se baseia no uso de threads no Capítulo 16 para paralelismo e
concorrência, introduzindo uma abordagem alternativa para escrever código: os
futures, streams e a sintaxe `async` e `await` do Rust, que nos permitem expressar como
as operações podem ser assíncronas, além dos crates de terceiros que implementam
runtimes assíncronos: código que gerencia e coordena a execução de
operações assíncronas.

Vamos considerar um exemplo. Digamos que você esteja exportando um vídeo que criou de uma
celebração familiar, uma operação que pode levar de minutos a
horas. A exportação de vídeo usará o máximo de potência de CPU e GPU possível. Se você
tinha apenas um núcleo de CPU e seu sistema operacional não pausou a exportação até
foi concluído - isto é, se ele executou a exportação _sincronamente_ - você não poderia fazer
qualquer outra coisa no seu computador enquanto a tarefa estava em execução. Isso seria um
experiência bastante frustrante. Felizmente, o sistema operacional do seu computador
pode, e interrompe invisivelmente, a exportação com frequência suficiente para permitir que você faça
outros trabalhos simultaneamente.

Agora digamos que você esteja baixando um vídeo compartilhado por outra pessoa, o que também pode levar
um tempo, mas não ocupa tanto tempo de CPU. Neste caso, a CPU deve
espere que os dados cheguem da rede. Embora você possa começar a ler os dados
assim que começar a chegar, pode levar algum tempo para que tudo apareça.
Mesmo quando todos os dados estiverem presentes, se o vídeo for muito grande, poderá demorar
pelo menos um ou dois segundos para carregar tudo. Isso pode não parecer muito, mas
é muito tempo para um processador moderno, que pode executar bilhões de
operações a cada segundo. Novamente, seu sistema operacional interromperá invisivelmente
seu programa para permitir que a CPU execute outro trabalho enquanto espera pelo
chamada de rede para terminar.

A exportação de vídeo é um exemplo de operação _CPU-bound_ ou
_compute-bound_. Ela é limitada pela velocidade potencial de processamento de
dados do computador na CPU ou na GPU e por quanto dessa velocidade pode ser
dedicada à operação. O download do vídeo é um exemplo de operação _I/O-bound_,
porque é limitado pela velocidade de _entrada e saída_ do computador; ele só
pode avançar tão rápido quanto os dados conseguem ser enviados pela rede.

Em ambos os exemplos, as interrupções invisíveis do sistema operacional
fornecem uma forma de concorrência. Essa concorrência acontece apenas no nível
do programa inteiro, porém: o sistema operacional interrompe um programa para
permitir que outros programas realizem trabalho. Em muitos casos, como
compreendemos nossos programas em um nível muito mais granular do que o sistema
operacional, podemos detectar oportunidades de concorrência que ele não
consegue ver.

Por exemplo, se estivermos construindo uma ferramenta para gerenciar downloads de arquivos, deveríamos estar
capaz de escrever nosso programa de forma que iniciar um download não bloqueie a interface do usuário,
e os usuários devem poder iniciar vários downloads ao mesmo tempo. Muitos
Porém, as APIs do sistema operacional para interagir com a rede estão _bloqueando_;
isto é, eles bloqueiam o progresso do programa até que os dados que estão processando sejam
completamente pronto.

> Nota: é assim que _a maioria_ das chamadas de função funcionam, se você pensar bem. No entanto,
> o termo _bloqueio_ geralmente é reservado para chamadas de função que interagem com
> arquivos, rede ou outros recursos do computador, porque esses são os
> casos em que um programa individual beneficiaria com a operação a ser
> _não_ bloqueador.

Poderíamos evitar o bloqueio da thread principal criando uma thread dedicada
para baixar cada arquivo. No entanto, a sobrecarga dos recursos do sistema
usados por essas threads acabaria se tornando um problema. Seria preferível que
a chamada já não fosse bloqueante e que, em vez disso, pudéssemos definir uma
série de tarefas que gostaríamos que nosso programa concluísse e deixar o
runtime escolher a melhor ordem e maneira de executá-las.

Isso é exatamente o que a abstração _async_ (abreviação de _asynchronous_) do
Rust nos oferece. Neste capítulo, você aprenderá tudo sobre async à medida que
abordarmos os seguintes tópicos:

- Como usar a sintaxe `async` e `await` do Rust e executar funções
  assíncronas com um runtime
- Como usar o modelo async para resolver alguns dos mesmos desafios que analisamos
  no Capítulo 16
- Como o multithreading e o async fornecem soluções complementares que você pode
  combinar em muitos casos

Antes de vermos como o async funciona na prática, precisamos fazer uma breve
desvio para discutir as diferenças entre paralelismo e simultaneidade.

## Paralelismo e simultaneidade

Até agora, tratamos o paralelismo e a simultaneidade como praticamente
intercambiáveis. Agora precisamos distingui-los com mais precisão, porque as
diferenças aparecerão quando começarmos a trabalhar.

Considere as diferentes maneiras pelas quais uma equipe poderia dividir o trabalho em um projeto de software.
Você pode atribuir múltiplas tarefas a um único membro, atribuir uma tarefa a cada membro,
ou use uma combinação das duas abordagens.

Quando um indivíduo trabalha em diversas tarefas diferentes antes de qualquer uma delas ser
completo, isso é _simultaneidade_. Uma maneira de implementar a simultaneidade é semelhante a
ter dois projetos diferentes verificados em seu computador e quando você chegar
entediado ou preso em um projeto, você muda para outro. Você é apenas uma pessoa,
então você não pode progredir em ambas as tarefas exatamente ao mesmo tempo, mas pode
multitarefa, progredindo uma de cada vez, alternando entre elas (consulte
Figura 17-1).

<figure>

<img src="img/trpl17-01.svg" class="center" alt="Um diagrama com caixas empilhadas rotuladas Tarefa A e Tarefa B, com losangos representando subtarefas. Setas apontam de A1 para B1, de B1 para A2, de A2 para B2, de B2 para A3, de A3 para A4 e de A4 para B3. As setas entre as subtarefas cruzam as caixas entre a Tarefa A e a Tarefa B." />

<figcaption>Figura 17-1: Um fluxo de trabalho concorrente, alternando entre a Tarefa A e a Tarefa B</figcaption>

</figure>

Quando a equipe divide um grupo de tarefas fazendo com que cada membro execute uma tarefa
e trabalhar nisso sozinho, isso é _paralelismo_. Cada pessoa da equipe pode fazer
progride exatamente ao mesmo tempo (veja a Figura 17-2).

<figure>

<img src="img/trpl17-02.svg" class="center" alt="Um diagrama com caixas empilhadas rotuladas Tarefa A e Tarefa B, com losangos representando subtarefas. Setas apontam de A1 para A2, de A2 para A3, de A3 para A4, de B1 para B2 e de B2 para B3. Nenhuma seta cruza entre as caixas da Tarefa A e da Tarefa B." />

<figcaption>Figura 17-2: Um fluxo de trabalho paralelo, em que o trabalho acontece independentemente na Tarefa A e na Tarefa B</figcaption>

</figure>

Em ambos os fluxos de trabalho, talvez seja necessário coordenar entre diferentes
tarefas. Talvez você tenha pensado que a tarefa atribuída a uma pessoa era totalmente
independente do trabalho de todos os outros, mas na verdade requer outra pessoa
na equipe para terminar sua tarefa primeiro. Parte do trabalho poderia ser feito em
paralelo, mas parte disso era na verdade _serial_: só poderia acontecer em um
série, uma tarefa após a outra, como na Figura 17-3.

<figure>

<img src="img/trpl17-03.svg" class="center" alt="Um diagrama com caixas empilhadas rotuladas Tarefa A e Tarefa B, com losangos representando subtarefas. Na Tarefa A, setas apontam de A1 para A2, de A2 para um par de linhas verticais grossas, como um símbolo de pausa, e desse símbolo para A3. Na Tarefa B, setas apontam de B1 para B2, de B2 para B3, de B3 para A3 e de B3 para B4." />

<figcaption>Figura 17-3: Um fluxo de trabalho parcialmente paralelo, onde o trabalho acontece na Tarefa A e na Tarefa B de forma independente até que a Tarefa A3 seja bloqueada nos resultados da Tarefa B3.</figcaption>

</figure>

Da mesma forma, você pode perceber que uma de suas próprias tarefas depende de
outra tarefa sua. Nesse caso, seu trabalho concorrente também se tornou serial.

Paralelismo e simultaneidade também podem se cruzar. Se você aprender
que um colega está preso até você terminar uma de suas tarefas, você provavelmente
concentre todos os seus esforços nessa tarefa para “desbloquear” seu colega. Você e seu
colega de trabalho não consegue mais trabalhar em paralelo e você também não consegue mais
para trabalhar simultaneamente em suas próprias tarefas.

A mesma dinâmica básica entra em jogo com software e hardware. Em uma máquina
com um único núcleo de CPU, a CPU pode realizar apenas uma operação por vez, mas
ainda pode funcionar simultaneamente. Usando ferramentas como threads, processos e
async, o computador pode pausar uma atividade e mudar para outras antes
eventualmente voltando para a primeira atividade novamente. Em uma máquina com
vários núcleos de CPU, ele também pode funcionar em paralelo. Um núcleo pode estar executando
uma tarefa enquanto outro núcleo executa outra completamente não relacionada, e essas
as operações realmente acontecem ao mesmo tempo.

A execução do código async em Rust geralmente acontece simultaneamente. Dependendo do
hardware, o sistema operacional e o tempo de execução async que estamos usando (mais sobre
async será executado em breve), essa simultaneidade também pode usar paralelismo sob o
capuz.

Agora, vamos nos aprofundar em como a programação do async no Rust realmente funciona.
