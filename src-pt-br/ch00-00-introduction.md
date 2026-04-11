# Introdução

Bem-vindo a “A Linguagem de Programação Rust”, um livro introdutório sobre Rust.

Rust é uma linguagem de programação que ajuda a escrever software mais rápido e confiável. 
A ergonomia de alto nível e o controle de baixo nível estão frequentemente em desacordo 
no design da linguagem de programação; Rust desafia isso. Ao equilibrar uma poderosa 
capacidade técnica e uma ótima experiência de desenvolvedor, Rust oferece a opção de 
controlar detalhes de baixo nível (como o uso de memória) sem todo o incômodo 
tradicionalmente associado a esse controle.

## Para Quem o Rust Serve

Rust é excelente para muitas pessoas por várias razões. Vamos discutir alguns dos grupos 
mais importantes.

### Equipes de Desenvolvedores

Rust está se mostrando uma ferramenta produtiva para a colaboração em grandes equipes 
de desenvolvedores com níveis variados de conhecimento de programação de sistemas. 
O código de baixo nível é propenso a uma variedade de erros sutis, que na maioria 
das outras linguagens só podem ser detectados por meio de testes extensivos e revisão 
cuidadosa do código por desenvolvedores experientes. Em Rust, o compilador desempenha 
um papel de guardião, recusando-se a compilar código com esses tipos de erros, incluindo 
erros de concorrência. Ao trabalhar junto com o compilador, a equipe pode dedicar mais 
tempo à lógica do programa, em vez de procurar bugs.

Rust também traz ferramentas de desenvolvimento contemporâneas para o mundo da 
programação de sistemas:

* Cargo, o gerenciador de dependências incluído e ferramenta de compilação, torna a adição, 
  compilação e gerenciamento de dependências indolor e consistente em todo o ecossistema Rust.
* O `rustfmt` garante um estilo de codificação consistente entre os desenvolvedores.
* O Rust Language Server (RLS) possibilita a integração de IDEs para preenchimento de código 
  e mensagens de erro em linha.  

Usando essas e outras ferramentas do ecossistema Rust, os desenvolvedores podem ser produtivos 
enquanto escrevem código em nível de sistema.

### Estudantes

Rust é para estudantes e pessoas interessadas em aprender sobre os conceitos de 
sistemas. Muitas pessoas aprenderam sobre tópicos como desenvolvimento de sistemas 
operacionais por meio de Rust. A comunidade fica feliz em responder às perguntas dos 
alunos. Por meio de esforços como este livro, as equipes do Rust desejam tornar 
os conceitos de sistemas mais acessíveis a mais pessoas, especialmente aquelas que 
estão começando a programar.

### Empresas

Rust é usado em produção por centenas de empresas, grandes e pequenas, para uma 
variedade de tarefas, como ferramentas de linha de comando, serviços na Web, 
ferramentas DevOps, dispositivos embarcados, análise e transcodificação de 
áudio e vídeo, criptomoedas, bioinformática, motores de busca, internet das coisas, 
aprendizado de máquina e até partes importantes do navegador Firefox.

### Desenvolvedores de Código Aberto

Rust é para pessoas que desejam criar a linguagem de programação Rust, a comunidade, 
as ferramentas de desenvolvimento e as bibliotecas Rust. Gostaríamos de contar com a sua
contribuição para a linguagem Rust.

### Pessoas que Valorizam a Velocidade e a Estabilidade

Por velocidade, entendemos tanto a velocidade dos programas que Rust permite criar quanto a 
velocidade com que Rust permite que você os escreva. As verificações do compilador 
do Rust garantem estabilidade por meio de adições e refatoração de recursos, em oposição 
ao código legado frágil (quebrável) em linguagens sem essas verificações, que os desenvolvedores 
têm medo de modificar. Ao buscar abstrações de custo zero, recursos de nível superior 
que se compilam para código de baixo nível tão rápido quanto o código escrito manualmente, 
Rust se esforça para tornar o código seguro e rápido ao mesmo tempo.

Esta não é uma lista completa de tudo o que a linguagem Rust espera apoiar, mas esses 
são alguns dos grupos mais importantes. No geral, a maior ambição de Rust é eliminar as trocas 
aceitas pelos programadores há décadas. Segurança *e* produtividade. 
Velocidade *e* ergonomia. Experimente Rust e veja se as opções funcionam para você.

## Para Quem é este Livro

Este livro pressupõe que você tenha escrito código em outra linguagem de programação, 
mas não faz nenhuma suposição sobre qual. Tentamos tornar o material amplamente acessível 
para pessoas com os mais diversos contextos de programação. Não passamos muito tempo 
falando sobre o que *é* programação nem sobre como pensar sobre programação; alguém novato 
em programação seria melhor atendido lendo um livro voltado especificamente para fornecer uma 
introdução à programação.

## Como Usar este Livro

Este livro geralmente supõe que você o esteja lendo do começo ao fim, ou seja, os 
capítulos posteriores se baseiam nos conceitos dos capítulos anteriores, e os capítulos 
anteriores podem não se aprofundar nos detalhes de um tópico, retomando-o em um 
capítulo posterior.

Existem dois tipos de capítulos neste livro: capítulos conceituais e capítulos de 
projetos. Nos capítulos conceituais, você aprenderá sobre um aspecto de Rust. Nos 
capítulos de projeto, criaremos pequenos programas juntos, aplicando o que aprendemos 
até agora. Os capítulos 2, 12 e 21 são capítulos de projetos; o restante é composto por capítulos conceituais.

Além disso, o Capítulo 2 é uma introdução prática ao Rust como linguagem. Abordaremos 
conceitos em alto nível, e os capítulos posteriores entrarão em mais detalhes. Se você é o tipo 
de pessoa que gosta de sujar as mãos imediatamente, o Capítulo 2 é ótimo para isso. Se 
você é realmente esse tipo de pessoa, pode até pular o Capítulo 3, que abrange recursos 
muito semelhantes a outras linguagens de programação, e vá direto ao Capítulo 4 para 
aprender sobre o sistema de ownership do Rust. Por outro lado, se você é um 
aluno particularmente meticuloso, que prefere aprender todos os detalhes antes de passar 
para o próximo, pule o Capítulo 2 e vá direto para o Capítulo 3.

O Capítulo 5 discute structs e métodos, e o Capítulo 6 aborda enums, expressões 
`match` e a construção de controle de fluxo `if let`. Structs e enums são as maneiras 
de criar tipos personalizados no Rust.

No Capítulo 7, você aprenderá sobre o sistema de módulos e as regras de privacidade do Rust para 
organizar seu código e sua API pública. O Capítulo 8 discute algumas estruturas comuns de 
dados de coleção fornecidas pela biblioteca padrão: vetores, sequências de caracteres e mapas 
de hash. O Capítulo 9 trata da filosofia e das técnicas de manipulação de erros em Rust.

O Capítulo 10 analisa *generics* (genéricos), *traits* e *lifetimes*, que permitem definir código que se aplica a vários tipos. 
O Capítulo 11 trata de testes, que continuam sendo necessários mesmo com as garantias de segurança 
do Rust, para assegurar que a lógica do seu programa esteja correta. No Capítulo 12, construiremos um 
subconjunto da funcionalidade da ferramenta de linha de comando `grep` que pesquisa texto nos 
arquivos e usaremos muitos dos conceitos discutidos nos capítulos anteriores.

O Capítulo 13 explora *closures* (fechamentos) e iteradores: recursos Rust provenientes 
de linguagens de programação funcionais. No Capítulo 14, exploraremos mais sobre o Cargo 
e falaremos sobre as práticas recomendadas para compartilhar suas bibliotecas com outras 
pessoas. O Capítulo 15 discute os *smart pointers* (ponteiros inteligentes) fornecidos 
pela biblioteca padrão e as *traits* que permitem sua funcionalidade.

No Capítulo 16, abordaremos diferentes modelos de programação concorrente e como 
Rust ajuda você a programar, sem medo, usando várias threads. O Capítulo 17 explora a sintaxe de 
async e await do Rust, junto com tasks, futures e streams, bem como o modelo de concorrência leve que eles permitem.

O Capítulo 18 analisa como as expressões idiomáticas do Rust se comparam aos princípios de Programação Orientada a Objetos com os quais 
você talvez já esteja familiarizado. O Capítulo 19 
é uma referência sobre *patterns* (padrões) e *pattern matching* (correspondência 
de padrões), que são maneiras poderosas de expressar ideias em programas Rust. O Capítulo 20 
é um conjunto variado de tópicos avançados nos quais você pode estar interessado, incluindo *unsafe Rust* 
(Rust inseguro) e mais sobre *lifetimes*, *traits*, tipos, funções e *closures* (fechamentos).

No Capítulo 21, concluiremos um projeto em que implementaremos um servidor web multithread 
de baixo nível!

Finalmente, existem alguns apêndices. Eles contêm informações úteis sobre a linguagem em 
um formato mais próximo de uma referência.

No final, não há uma maneira errada de ler o livro: se você quiser pular, vá em frente! 
Você pode ter que voltar atrás se achar as coisas confusas. Faça o que funciona para você.

Uma parte importante do processo de aprendizado de Rust é aprender a ler as mensagens de erro 
fornecidas pelo compilador. Por isso, mostraremos muito código que não compila, junto com a 
mensagem de erro que o compilador mostrará nessa situação. Dessa forma, se você escolher um 
exemplo aleatório, ele pode não ser compilado! Leia o texto ao redor para garantir que você 
não tenha escolhido um dos exemplos em andamento.

| Ferris                                                                             | Significado                                          |
|------------------------------------------------------------------------------------|------------------------------------------------------|
| <img width="120" src="img/ferris/does_not_compile.svg" class="ferris-explain"/>    | Este código não compila!                             |
| <img width="120" src="img/ferris/panics.svg" class="ferris-explain"/>              | Este código _panics_!                                |
| <img width="120" src="img/ferris/unsafe.svg" class="ferris-explain"/>              | Este bloco de código contém código inseguro (`unsafe`).|
| <img width="120" src="img/ferris/not_desired_behavior.svg" class="ferris-explain"/>| Este código não produz o comportamento esperado.     |

Na maioria das vezes, você será apresentado à versão correta de qualquer código que não compile.

## Contribuindo para o Livro

Este livro é de código aberto. Se você encontrar um erro, não hesite em registrar um problema 
ou enviar um *pull request* [pt_br on GitHub]. Por favor, consulte 
[CONTRIBUTING.md] para mais detalhes.

Para contribuições em língua inglesa, veja [on GitHub] e [CONTRIBUTING-en-us.md], respectivamente.

[on GitHub]: https://github.com/rust-lang/book
[CONTRIBUTING-en-us.md]: https://github.com/rust-lang/book/blob/main/CONTRIBUTING.md

[pt_br on GitHub]: https://github.com/rust-book-pt-br/rust-book-pt-br
[CONTRIBUTING.md]: https://github.com/rust-book-pt-br/rust-book-pt-br/blob/main/CONTRIBUTING.md
