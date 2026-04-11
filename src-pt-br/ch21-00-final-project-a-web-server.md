# Projeto Final: Construindo um Servidor Web Multithread

Foi uma longa jornada, mas chegamos ao final do livro. Neste
capítulo, construiremos mais um projeto juntos para demonstrar alguns dos
conceitos que abordamos nos capítulos finais, bem como recapitular algumas
lições.

Para nosso projeto final, faremos um servidor web que diz “Olá!” e se parece com a
Figura 21-1 em um navegador.

Aqui está nosso plano para construir o servidor web:

1. Aprenda um pouco sobre TCP e HTTP.
2. Ouça conexões TCP em um soquete.
3. Analise um pequeno número de solicitações HTTP.
4. Crie uma resposta HTTP adequada.
5. Melhore o rendimento do nosso servidor com um thread pool.

<img alt="Captura de tela de um navegador acessando o endereço 127.0.0.1:8080 e exibindo uma página com o texto “Hello! Hi from Rust”" src="img/trpl21-01.png" class="center" style="width: 50%;" />

<span class="caption">Figura 21-1: Nosso projeto final compartilhado</span>

Antes de começarmos, devemos mencionar dois detalhes. Primeiro, o método que iremos
usar não será a melhor maneira de construir um servidor web com Rust. Membros da comunidade
publicaram uma série de crates prontos para produção disponíveis em
[crates.io](https://crates.io/) que fornecem servidores web e
implementações de thread pool semelhantes às que construiremos. Contudo, a nossa intenção neste
capítulo é ajudá-lo a aprender, não seguir o caminho mais fácil. Como Rust é uma
linguagem de programação de sistemas, podemos escolher o nível de abstração em que queremos
trabalhar e podemos ir para um nível mais baixo do que é possível ou prático em outras
linguagens.

Segundo, não usaremos async e await aqui. Construir um thread pool já é um desafio
grande o suficiente por si só, sem adicionar a construção de um runtime async!
No entanto, observaremos como async e await podem ser aplicáveis a alguns dos
mesmos problemas que veremos neste capítulo. Em última análise, como observamos em
Capítulo 17, muitos runtimes async usam thread pools para gerenciar seu trabalho.

Portanto, escreveremos o servidor HTTP básico e o thread pool manualmente para que
você possa aprender as ideias e técnicas gerais por trás dos crates que poderá usar
no futuro.
