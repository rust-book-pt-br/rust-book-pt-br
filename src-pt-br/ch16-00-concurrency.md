# Concorrência sem medo

Lidar com programação concorrente de forma segura e eficiente é outro dos
principais objetivos do Rust. _Programação concorrente_, em que diferentes
partes de um programa executam de forma independente, e _programação paralela_,
em que diferentes partes de um programa executam ao mesmo tempo, estão se
tornando cada vez mais importantes à medida que mais computadores aproveitam
seus múltiplos processadores. Historicamente, programar nesses contextos tem
sido difícil e propenso a erros. O Rust pretende mudar isso.

Inicialmente, a equipe do Rust pensava que garantir segurança de memória e
evitar problemas de concorrência eram dois desafios separados, a serem
resolvidos com métodos diferentes. Com o tempo, a equipe descobriu que os
sistemas de ownership e de tipos formam um conjunto poderoso de ferramentas
para ajudar a gerenciar problemas de segurança de memória _e_ de concorrência!
Ao aproveitar ownership e verificação de tipos, muitos erros de concorrência no
Rust se tornam erros de compilação em vez de erros de tempo de execução.
Portanto, em vez de fazer você gastar muito tempo tentando reproduzir as
circunstâncias exatas em que um bug de concorrência acontece em tempo de
execução, o código incorreto simplesmente se recusará a compilar e apresentará
um erro explicando o problema. Como resultado, você pode corrigir o código
enquanto ainda está trabalhando nele, em vez de só descobrir o problema depois
que ele tiver ido para produção. Chamamos esse aspecto do Rust de
_concorrência sem medo_. A concorrência sem medo permite escrever código livre
de bugs sutis e fácil de refatorar sem introduzir novos bugs.

> Nota: Para simplificar, vamos nos referir a muitos dos problemas como
> _concorrentes_ em vez de ser mais precisos e dizer _concorrentes e/ou
> paralelos_. Neste capítulo, substitua mentalmente _concorrentes e/ou
> paralelos_ sempre que usarmos _concorrente_. No próximo capítulo, em que a
> distinção é mais importante, seremos mais específicos.

Muitas linguagens são dogmáticas quanto às soluções que oferecem para lidar com
problemas de concorrência. Por exemplo, Erlang tem uma funcionalidade elegante
para concorrência por passagem de mensagens, mas possui formas mais obscuras de
compartilhar estado entre threads. Apoiar apenas um subconjunto das soluções
possíveis é uma estratégia razoável para linguagens de alto nível, porque essas
linguagens prometem benefícios ao abrir mão de algum controle em troca de
abstrações. No entanto, espera-se que linguagens de baixo nível forneçam a
solução com melhor desempenho em qualquer situação e tenham menos abstrações
sobre o hardware. Por isso, o Rust oferece uma variedade de ferramentas para
modelar problemas da maneira que for apropriada para a sua situação e para as
suas necessidades.

Aqui estão os tópicos que abordaremos neste capítulo:

- Como criar threads para executar vários trechos de código ao mesmo tempo
- Concorrência por _passagem de mensagens_, em que canais enviam mensagens entre threads
- Concorrência de _estado compartilhado_, em que várias threads têm acesso a algum dado
- As traits `Sync` e `Send`, que estendem as garantias de concorrência do Rust
  a tipos definidos pelo usuário, bem como a tipos fornecidos pela biblioteca padrão
