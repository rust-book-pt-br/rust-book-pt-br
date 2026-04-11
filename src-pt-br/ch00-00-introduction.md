# Introdução

> Nota: Esta edição do livro é a mesma de [The Rust Programming
> Language][nsprust], disponível em formato impresso e ebook pela [No Starch
> Press][nsp].

[nsprust]: https://nostarch.com/rust-programming-language-3rd-edition
[nsp]: https://nostarch.com/

Boas-vindas a _A Linguagem de Programação Rust_, um livro introdutório sobre
Rust. A linguagem de programação Rust ajuda você a escrever software mais
rápido e mais confiável. Ergonomia de alto nível e controle de baixo nível
costumam entrar em conflito no design de linguagens de programação; Rust
desafia esse conflito. Ao equilibrar grande capacidade técnica com uma ótima
experiência para desenvolvedores, Rust oferece a opção de controlar detalhes de
baixo nível, como o uso de memória, sem toda a dificuldade tradicionalmente
associada a esse tipo de controle.

## Para quem Rust é indicado

Rust é ideal para muita gente por vários motivos. Vamos olhar para alguns dos
grupos mais importantes.

### Equipes de desenvolvimento

Rust tem se mostrado uma ferramenta produtiva para colaboração entre grandes
equipes com níveis variados de conhecimento em programação de sistemas. Código
de baixo nível é propenso a vários bugs sutis que, na maioria das outras
linguagens, só podem ser detectados com testes extensivos e revisão de código
cuidadosa feita por pessoas experientes. Em Rust, o compilador atua como uma
espécie de guardião ao se recusar a compilar código com esses bugs difíceis de
encontrar, inclusive bugs de concorrência. Trabalhando junto com o compilador,
a equipe pode dedicar seu tempo à lógica do programa em vez de sair caçando
bugs.

Rust também traz ferramentas modernas para desenvolvedores ao mundo da
programação de sistemas:

- O Cargo, gerenciador de dependências e ferramenta de build incluídos,
  torna simples e consistente adicionar, compilar e gerenciar dependências em
  todo o ecossistema Rust.
- A ferramenta de formatação `rustfmt` garante um estilo de código consistente
  entre diferentes pessoas desenvolvedoras.
- O Rust Language Server viabiliza integração com ambientes de desenvolvimento
  integrados (IDEs), oferecendo autocompletar e mensagens de erro inline.

Ao usar essas e outras ferramentas do ecossistema Rust, pessoas
desenvolvedoras podem ser produtivas mesmo escrevendo código em nível de
sistema.

### Estudantes

Rust também é para estudantes e para pessoas interessadas em aprender conceitos
de sistemas. Usando Rust, muita gente aprendeu sobre tópicos como
desenvolvimento de sistemas operacionais. A comunidade é bastante acolhedora e
fica feliz em responder às dúvidas de estudantes. Por meio de esforços como
este livro, as equipes do Rust querem tornar conceitos de sistemas mais
acessíveis a mais pessoas, especialmente quem está começando a programar.

### Empresas

Centenas de empresas, grandes e pequenas, usam Rust em produção para diversas
tarefas, incluindo ferramentas de linha de comando, serviços web, tooling de
DevOps, dispositivos embarcados, análise e transcodificação de áudio e vídeo,
criptomoedas, bioinformática, motores de busca, aplicações de Internet das
Coisas, aprendizado de máquina e até partes importantes do navegador Firefox.

### Pessoas desenvolvedoras de código aberto

Rust é para quem quer construir a linguagem de programação Rust, sua
comunidade, ferramentas para desenvolvedores e bibliotecas. Adoraríamos contar
com a sua contribuição para a linguagem Rust.

### Pessoas que valorizam velocidade e estabilidade

Rust é para quem deseja velocidade e estabilidade em uma linguagem. Por
velocidade, queremos dizer tanto a rapidez com que o código Rust pode executar
quanto a velocidade com que Rust permite escrever programas. As verificações do
compilador Rust garantem estabilidade durante a adição de recursos e a
refatoração. Isso contrasta com o código legado frágil em linguagens sem essas
verificações, que desenvolvedores costumam ter receio de modificar. Ao buscar
abstrações de custo zero, isto é, recursos de nível mais alto que compilam
para código de baixo nível tão rápido quanto código escrito manualmente, Rust
se esforça para fazer com que código seguro também seja código rápido.

A linguagem Rust espera dar suporte a muitos outros perfis de usuário também;
os mencionados aqui são apenas alguns dos grupos mais importantes. No geral, a
maior ambição do Rust é eliminar os trade-offs que programadores aceitaram por
décadas, oferecendo segurança _e_ produtividade, velocidade _e_ ergonomia.
Experimente Rust e veja se as escolhas da linguagem funcionam para você.

## Para quem este livro é indicado

Este livro presume que você já escreveu código em outra linguagem de
programação, mas não faz suposições sobre qual seja. Tentamos tornar o material
amplamente acessível para pessoas com os mais diversos históricos de
programação. Não gastamos muito tempo explicando o que _é_ programação ou como
pensar sobre ela. Se você é totalmente iniciante em programação, será melhor
atendido por um livro que ofereça especificamente uma introdução à programação.

## Como usar este livro

Em geral, este livro presume que você o está lendo em sequência, do começo ao
fim. Capítulos posteriores se baseiam em conceitos apresentados antes, e os
capítulos iniciais podem não se aprofundar em certos assuntos porque voltarão a
eles em mais detalhes depois.

Você encontrará dois tipos de capítulos neste livro: capítulos conceituais e
capítulos de projeto. Nos capítulos conceituais, você aprenderá sobre algum
aspecto do Rust. Nos capítulos de projeto, construiremos pequenos programas
juntos, aplicando o que você aprendeu até aquele ponto. Os Capítulos 2, 12 e
21 são capítulos de projeto; os demais são capítulos conceituais.

O **Capítulo 1** explica como instalar Rust, como escrever um programa “Hello,
world!” e como usar o Cargo, o gerenciador de pacotes e ferramenta de build do
Rust. O **Capítulo 2** é uma introdução prática à escrita de um programa em
Rust, fazendo você construir um jogo de adivinhação. Ali, cobrimos conceitos
em alto nível, e capítulos posteriores darão detalhes adicionais. Se você quer
colocar a mão na massa logo de início, o Capítulo 2 é o lugar certo. Se você é
um tipo de aprendiz especialmente meticuloso e prefere entender cada detalhe
antes de avançar, talvez queira pular o Capítulo 2 e ir direto ao **Capítulo
3**, que cobre recursos do Rust parecidos com os de outras linguagens de
programação; depois, você pode voltar ao Capítulo 2 quando quiser trabalhar em
um projeto que aplique os detalhes aprendidos.

No **Capítulo 4**, você aprenderá sobre o sistema de ownership do Rust. O
**Capítulo 5** discute structs e métodos. O **Capítulo 6** cobre enums,
expressões `match` e as construções de fluxo de controle `if let` e
`let...else`. Você usará structs e enums para criar tipos personalizados.

No **Capítulo 7**, você aprenderá sobre o sistema de módulos do Rust e sobre as
regras de privacidade para organizar seu código e sua interface pública de
programação de aplicações (API). O **Capítulo 8** discute algumas estruturas de
dados de coleção comuns fornecidas pela biblioteca padrão: vetores, strings e
hash maps. O **Capítulo 9** explora a filosofia e as técnicas de tratamento de
erros em Rust.

O **Capítulo 10** se aprofunda em genéricos, traits e lifetimes, que dão a
você o poder de definir código aplicável a múltiplos tipos. O **Capítulo 11**
é inteiramente dedicado a testes, que, mesmo com as garantias de segurança do
Rust, ainda são necessários para assegurar que a lógica do programa está
correta. No **Capítulo 12**, construiremos nossa própria implementação de um
subconjunto da funcionalidade do utilitário de linha de comando `grep`, que
busca texto dentro de arquivos. Para isso, usaremos muitos dos conceitos
discutidos nos capítulos anteriores.

O **Capítulo 13** explora closures e iteradores, recursos do Rust vindos de
linguagens de programação funcionais. No **Capítulo 14**, examinaremos o Cargo
em mais profundidade e falaremos sobre boas práticas para compartilhar suas
bibliotecas com outras pessoas. O **Capítulo 15** discute smart pointers
fornecidos pela biblioteca padrão e os traits que habilitam sua
funcionalidade.

No **Capítulo 16**, veremos diferentes modelos de programação concorrente e
falaremos sobre como Rust ajuda você a programar com múltiplas threads sem
medo. No **Capítulo 17**, daremos continuidade a isso explorando a sintaxe
async e await do Rust, junto com tasks, futures e streams, e o modelo de
concorrência leve que eles possibilitam.

O **Capítulo 18** observa como os idioms do Rust se comparam a princípios de
programação orientada a objetos com os quais você talvez já esteja
familiarizado. O **Capítulo 19** é uma referência sobre padrões e pattern
matching, formas poderosas de expressar ideias em programas Rust. O
**Capítulo 20** reúne uma variedade de tópicos avançados de interesse,
incluindo Rust inseguro, macros e mais detalhes sobre lifetimes, traits,
tipos, funções e closures.

No **Capítulo 21**, concluiremos um projeto no qual implementaremos um servidor
web multithread de baixo nível!

Por fim, alguns apêndices contêm informações úteis sobre a linguagem em um
formato mais voltado a referência. O **Apêndice A** cobre as palavras-chave do
Rust, o **Apêndice B** cobre operadores e símbolos, o **Apêndice C** cobre
traits deriváveis fornecidos pela biblioteca padrão, o **Apêndice D** cobre
algumas ferramentas úteis de desenvolvimento, e o **Apêndice E** explica as
edições do Rust. No **Apêndice F**, você encontra traduções do livro, e no
**Apêndice G** veremos como o Rust é feito e o que é o Rust nightly.

Não existe jeito errado de ler este livro: se quiser pular adiante, vá em
frente! Talvez você precise voltar a capítulos anteriores se encontrar alguma
confusão. Mas faça o que funcionar melhor para você.

<span id="ferris"></span>

Uma parte importante do processo de aprender Rust é aprender a ler as mensagens
de erro exibidas pelo compilador: elas vão guiar você até um código que
funciona. Por isso, forneceremos muitos exemplos que não compilam, junto com a
mensagem de erro que o compilador mostrará em cada situação. Saiba que, se
você digitar e executar um exemplo aleatório, ele pode não compilar! Leia
sempre o texto ao redor para ver se o exemplo que você está tentando executar
foi pensado para gerar erro. O Ferris também ajudará a diferenciar código que
não foi feito para funcionar:

| Ferris                                                                                                           | Significado                                         |
| ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| <img src="img/ferris/does_not_compile.svg" class="ferris-explain" alt="Ferris com um ponto de interrogação"/>   | Este código não compila!                            |
| <img src="img/ferris/panics.svg" class="ferris-explain" alt="Ferris levantando as mãos"/>                       | Este código entra em pânico!                        |
| <img src="img/ferris/not_desired_behavior.svg" class="ferris-explain" alt="Ferris com uma garra levantada, dando de ombros"/> | Este código não produz o comportamento desejado. |

Na maioria das situações, vamos conduzir você até a versão correta de qualquer
código que não compile.

## Código-fonte

Os arquivos-fonte a partir dos quais este livro é gerado podem ser encontrados
no [GitHub][book].

[book]: https://github.com/rust-book-pt-br/rust-book-pt-br/tree/main/src-pt-br
