# Projeto Final: Construindo um Servidor Web Multithread

Foi uma longa jornada, mas chegamos ao final do livro. Neste
capítulo, construiremos mais um projeto juntos para demonstrar algumas das
conceitos que abordamos nos capítulos finais, bem como recapitular alguns
lições.

Para nosso projeto final, faremos um web server que diz “Olá!” e parece
Figura 21-1 em um navegador da web.

Aqui está nosso plano para construir o web server:

1. Aprenda um pouco sobre TCP e HTTP.
2. Ouça conexões TCP em um soquete.
3. Analise um pequeno número de solicitações HTTP.
4. Crie uma resposta HTTP adequada.
5. Melhore o rendimento do nosso servidor com um pool thread.

<img alt="Captura de tela de um navegador acessando o endereço 127.0.0.1:8080 e exibindo uma página com o texto “Hello! Hi from Rust”" src="img/trpl21-01.png" class="center" style="width: 50%;" />

<span class="caption">Figura 21-1: Nosso projeto final compartilhado</span>

Antes de começarmos, devemos mencionar dois detalhes. Primeiro, o método que iremos
usar não será a melhor maneira de construir um web server com Rust. Membros da comunidade
publicaram uma série de crates prontos para produção disponíveis em
[crates.io](https://crates.io/) que fornecem web server e
Implementações de pool thread do que construiremos. Contudo, a nossa intenção neste
capítulo é para ajudá-lo a aprender, não para seguir o caminho mais fácil. Como Rust é um
linguagem de programação de sistemas, podemos escolher o nível de abstração que queremos
trabalhar e pode ir para um nível mais baixo do que é possível ou prático em outros
línguas.

Segundo, não usaremos async e await aqui. Construir um pool thread é uma tarefa
desafio grande o suficiente por si só, sem adicionar a construção de um tempo de execução async!
No entanto, observaremos como async e await podem ser aplicáveis a alguns dos
mesmos problemas que veremos neste capítulo. Em última análise, como observamos em
Capítulo 17, muitos tempos de execução async usam pools thread para gerenciar seu trabalho.

Portanto, escreveremos o servidor HTTP básico e o pool thread manualmente para que
você pode aprender as idéias e técnicas gerais por trás do crates que você pode usar
no future.
