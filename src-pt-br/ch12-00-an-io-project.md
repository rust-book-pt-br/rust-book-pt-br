# Um projeto de E/S: Criando um Programa de Linha de Comando

Este capítulo é uma recapitulação de muitas das habilidades que você aprendeu
até agora, além de uma exploração de mais alguns recursos da biblioteca padrão.
Vamos construir uma ferramenta de linha de comando que interage com entrada e
saída de arquivos para praticar alguns dos conceitos de Rust que você já tem à
disposição.

A velocidade, a segurança, a geração de um único binário e o suporte
multiplataforma do Rust fazem dele uma linguagem ideal para a criação de
ferramentas de linha de comando. Assim, para nosso projeto, criaremos nossa
própria versão da ferramenta clássica de linha de comando `grep`
(**g**lobally search a **r**egular **e**xpression and **p**rint). No caso de
uso mais simples, o `grep` procura uma string específica em um arquivo
especificado. Para fazer isso, o `grep` recebe como argumentos um caminho de
arquivo e uma string. Em seguida, ele lê o arquivo, encontra as linhas que
contêm essa string e imprime essas linhas.

Ao longo do caminho, mostraremos como fazer nossa ferramenta de linha de
comando usar recursos do terminal que muitas outras ferramentas desse tipo
usam. Leremos o valor de uma variável de ambiente para permitir que o usuário
configure o comportamento da ferramenta. Também imprimiremos mensagens de erro
no fluxo de erro padrão (`stderr`) em vez de na saída padrão (`stdout`), para
que, por exemplo, o usuário possa redirecionar a saída bem-sucedida para um
arquivo enquanto continua vendo as mensagens de erro na tela.

Um membro da comunidade Rust, Andrew Gallant, já criou uma versão completa e
muito rápida do `grep`, chamada `ripgrep`. Em comparação, a nossa versão será
bastante simples, mas este capítulo dará a você parte do conhecimento básico de
que precisa para entender um projeto real como o `ripgrep`.

Nosso projeto `grep` combinará vários conceitos que você aprendeu até agora:

- Organizar código (usando o que você aprendeu sobre módulos, no Capítulo 7)
- Usar vetores e strings (coleções, no Capítulo 8)
- Tratar erros (Capítulo 9)
- Usar traits e lifetimes, quando apropriado (Capítulo 10)
- Escrever testes (Capítulo 11)

Também apresentaremos brevemente closures, iterators e trait objects, que os
Capítulos 13 e 18 abordarão em detalhes.
