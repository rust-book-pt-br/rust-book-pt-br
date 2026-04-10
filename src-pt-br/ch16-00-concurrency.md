# Simultaneidade destemida

Lidar com a programação simultânea com segurança e eficiência é outra das vantagens do Rust
objetivos principais. _Programação simultânea_, na qual diferentes partes de um programa
executar de forma independente e _programação paralela_, na qual diferentes partes do
um programa executado ao mesmo tempo, estão se tornando cada vez mais importantes à medida que mais
os computadores aproveitam seus múltiplos processadores. Historicamente,
a programação nestes contextos tem sido difícil e propensa a erros. Rust espera
mude isso.

Inicialmente, a equipe Rust pensou que garantir a segurança da memória e prevenir
problemas de simultaneidade eram dois desafios separados a serem resolvidos com diferentes
métodos. Com o tempo, a equipe descobriu que o ownership e os sistemas de tipo são
um poderoso conjunto de ferramentas para ajudar a gerenciar a segurança da memória _e_ simultaneidade
problemas! Ao aproveitar ownership e verificação de tipo, muitos erros de simultaneidade
são erros de tempo de compilação em Rust em vez de erros de tempo de execução. Portanto, em vez
do que fazer você gastar muito tempo tentando reproduzir as circunstâncias exatas
sob o qual ocorre um bug de simultaneidade em tempo de execução, o código incorreto se recusará a
compilar e apresentar um erro explicando o problema. Como resultado, você pode corrigir
seu código enquanto você está trabalhando nele, em vez de potencialmente depois de ter sido
enviado para produção. Chamamos esse aspecto de Rust de _fearless
simultaneidade_. A simultaneidade destemida permite que você escreva código livre de
bugs sutis e é fácil de refatorar sem introduzir novos bugs.

> Nota: Para simplificar, nos referiremos a muitos dos problemas como
> _concurrent_ em vez de ser mais preciso dizendo _concurrent e/ou
> paralelo_. Neste capítulo, substitua mentalmente _concurrent e/ou
> paralelo_ sempre que usarmos _concorrente_. No próximo capítulo, onde o
> a distinção é mais importante, seremos mais específicos.

Muitas línguas são dogmáticas quanto às soluções que oferecem para lidar com
problemas simultâneos. Por exemplo, Erlang possui funcionalidade elegante para
simultaneidade de passagem de mensagens, mas tem apenas maneiras obscuras de compartilhar estado entre
threads. Apoiar apenas um subconjunto de soluções possíveis é uma medida razoável
estratégia para linguagens de nível superior porque uma linguagem de nível superior promete
se beneficia de abrir mão de algum controle para obter abstrações. No entanto, de nível inferior
espera-se que as linguagens forneçam a solução com o melhor desempenho em qualquer
determinada situação e têm menos abstrações sobre o hardware. Portanto, Rust
oferece uma variedade de ferramentas para modelar problemas da maneira que for apropriada
para sua situação e necessidades.

Aqui estão os tópicos que abordaremos neste capítulo:

- Como criar threads para executar vários trechos de código ao mesmo tempo
- Simultaneidade de _passagem de mensagens_, onde os canais enviam mensagens entre threads
- Simultaneidade de _estado compartilhado_, onde vários threads têm acesso a alguma peça
  de dados
- O `Sync` e `Send` traits, que estendem as garantias de simultaneidade do Rust para
  tipos definidos pelo usuário, bem como tipos fornecidos pela biblioteca padrão
