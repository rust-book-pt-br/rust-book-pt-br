# Um projeto de E/S: construindo um programa de linha de comando

Este capítulo é uma recapitulação das muitas habilidades que você aprendeu até agora e uma
exploração de mais alguns recursos padrão da biblioteca. Vamos construir uma linha de comando
ferramenta que interage com arquivo e entrada/saída de linha de comando para praticar alguns dos
os conceitos de Rust que você tem agora em seu currículo.

A velocidade, segurança, saída binária única e suporte multiplataforma do Rust o tornam
uma linguagem ideal para criar ferramentas de linha de comando, então para o nosso projeto, vamos
faça nossa própria versão da ferramenta clássica de pesquisa de linha de comando `grep`
(**g**pesquise globalmente uma expressão **r**egular **e**x e **p**rint). No
caso de uso mais simples, `grep` pesquisa em um arquivo especificado por uma string especificada. Para
fizer isso, `grep` toma como argumentos um caminho de arquivo e uma string. Então, lê-se
o arquivo, encontra linhas nesse arquivo que contêm o argumento string e imprime
essas linhas.

Ao longo do caminho, mostraremos como fazer com que nossa ferramenta de linha de comando use o terminal
recursos que muitas outras ferramentas de linha de comando usam. Leremos o valor de um
variável de ambiente para permitir ao usuário configurar o comportamento de nossa ferramenta.
Também imprimiremos mensagens de erro no fluxo padrão do console de erros (`stderr`)
em vez da saída padrão (`stdout`) para que, por exemplo, o usuário possa
redirecione a saída bem-sucedida para um arquivo enquanto ainda vê mensagens de erro na tela.

Um membro da comunidade Rust, Andrew Gallant, já criou um ambiente totalmente
versão em destaque e muito rápida de `grep`, chamada `ripgrep`. Em comparação, nosso
versão será bastante simples, mas este capítulo lhe dará algumas das
conhecimento prévio que você precisa para entender um projeto do mundo real, como
`ripgrep`.

Nosso projeto `grep` combinará uma série de conceitos que você aprendeu até agora:

- Código de organização ([Capítulo 7][ch7]<!-- ignore -->)
- Usando vetores e strings ([Capítulo 8][ch8]<!-- ignore -->)
- Tratamento de erros ([Capítulo 9][ch9]<!-- ignore -->)
- Usando características e tempos de vida quando apropriado ([Capítulo 10][ch10]<!-- ignore -->)
- Testes de redação ([Capítulo 11][ch11]<!-- ignore -->)

Também apresentaremos brevemente encerramentos, iteradores e objetos de características, que
[Capítulo 13][ch13]<!-- ignore --> e [Capítulo 18][ch18]<!-- ignore --> irão
cobrir em detalhes.

[ch7]: ch07-00-managing-growing-projects-with-packages-crates-and-modules.html
[ch8]: ch08-00-common-collections.html
[ch9]: ch09-00-error-handling.html
[ch10]: ch10-00-generics.html
[ch11]: ch11-00-testing.html
[ch13]: ch13-00-functional-features.html
[ch18]: ch18-00-oop.html
