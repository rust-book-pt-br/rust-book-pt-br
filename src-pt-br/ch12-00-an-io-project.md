# Um projeto de E/S: construindo um programa de linha de comando

Este capítulo recapitula muitas das habilidades que você aprendeu até agora e
explora mais alguns recursos da biblioteca padrão. Vamos construir uma
ferramenta de linha de comando que interage com arquivos e com a entrada e
saída da linha de comando para praticar alguns dos conceitos de Rust que você
já domina.

A velocidade, a segurança, a geração de um único binário e o suporte
multiplataforma de Rust fazem dela uma linguagem ideal para criar ferramentas
de linha de comando. Para o nosso projeto, vamos fazer nossa própria versão da
clássica ferramenta de busca `grep` (**g**lobalmente buscar uma **r**egular
**e**xpression e **p**rintar). No caso de uso mais simples, `grep` procura em
um arquivo específico por uma string específica. Para isso, `grep` recebe como
argumentos um caminho de arquivo e uma string. Em seguida, ele lê o arquivo,
encontra as linhas que contêm a string informada e imprime essas linhas.

Ao longo do caminho, vamos mostrar como fazer nossa ferramenta de linha de
comando usar recursos do terminal que muitas outras ferramentas também usam.
Leremos o valor de uma variável de ambiente para permitir que o usuário
configure o comportamento da ferramenta. Também imprimiremos mensagens de erro
no fluxo de erro padrão (`stderr`) em vez da saída padrão (`stdout`) para que,
por exemplo, o usuário possa redirecionar a saída bem-sucedida para um arquivo
e ainda assim continuar vendo as mensagens de erro na tela.

Um membro da comunidade Rust, Andrew Gallant, já criou uma versão completa e
muito rápida do `grep`, chamada `ripgrep`. Em comparação, nossa versão será
bem simples, mas este capítulo vai lhe dar parte da base necessária para
entender um projeto do mundo real como o `ripgrep`.

Nosso projeto `grep` vai combinar vários conceitos que você aprendeu até aqui:

- Organização de código ([Capítulo 7][ch7]<!-- ignore -->)
- Uso de vetores e strings ([Capítulo 8][ch8]<!-- ignore -->)
- Tratamento de erros ([Capítulo 9][ch9]<!-- ignore -->)
- Uso de traits e lifetimes quando apropriado ([Capítulo 10][ch10]<!-- ignore -->)
- Escrita de testes ([Capítulo 11][ch11]<!-- ignore -->)

Também apresentaremos brevemente closures, iteradores e objetos trait, que os
[Capítulos 13][ch13]<!-- ignore --> e [18][ch18]<!-- ignore --> abordarão em
detalhe.

[ch7]: ch07-00-managing-growing-projects-with-packages-crates-and-modules.html
[ch8]: ch08-00-common-collections.html
[ch9]: ch09-00-error-handling.html
[ch10]: ch10-00-generics.html
[ch11]: ch11-00-testing.html
[ch13]: ch13-00-functional-features.html
[ch18]: ch18-00-oop.html
