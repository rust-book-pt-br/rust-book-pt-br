<!-- Old headings. Do not remove or links may break. -->

<a id="managing-growing-projects-with-packages-crates-and-modules"></a>

# Pacotes, caixas e módulos

À medida que você escreve programas grandes, a organização do seu código se tornará cada vez mais
importante. Agrupando funcionalidades relacionadas e separando o código com
recursos, você esclarecerá onde encontrar o código que implementa um determinado
recurso e onde ir para alterar o funcionamento de um recurso.

Os programas que escrevemos até agora estavam em um módulo em um arquivo. Como um
projeto crescer, você deve organizar o código dividindo-o em vários módulos
e depois vários arquivos. Um pacote pode conter vários binários crates e
opcionalmente, uma biblioteca crate. À medida que um pacote cresce, você pode extrair partes em
crates separados que se tornam dependências externas. Este capítulo cobre todos
essas técnicas. Para projetos muito grandes que compreendem um conjunto de atividades inter-relacionadas
pacotes que evoluem juntos, o Cargo fornece o workspaces, que abordaremos em
[“Áreas de trabalho Cargo”][workspaces]<!-- ignore --> no Capítulo 14.

Também discutiremos o encapsulamento de detalhes de implementação, o que permite reutilizar
código em um nível superior: depois de implementar uma operação, outro código pode
chame seu código por meio de sua interface pública sem precisar saber como o
obras de implementação. A maneira como você escreve o código define quais partes são públicas para
outro código a ser usado e quais partes são detalhes de implementação privados que você
reserve-se o direito de alterar. Esta é outra maneira de limitar a quantidade de detalhes
você tem que manter em sua cabeça.

Um conceito relacionado é escopo: o contexto aninhado no qual o código é escrito tem um
conjunto de nomes definidos como “no escopo”. Ao ler, escrever e
ao compilar código, programadores e compiladores precisam saber se um determinado
nome em um local específico refere-se a uma variável, função, struct, enum, módulo,
constante ou outro item e o que esse item significa. Você pode criar escopos e
alterar quais nomes estão dentro ou fora do escopo. Você não pode ter dois itens com o
mesmo nome no mesmo escopo; ferramentas estão disponíveis para resolver conflitos de nomes.

Rust possui vários recursos que permitem gerenciar o seu código
organização, incluindo quais detalhes são expostos, quais detalhes são privados,
e quais nomes estão em cada escopo de seus programas. Essas características, às vezes
referidos coletivamente como _sistema de módulo_, incluem:

* **Pacotes**: um recurso do Cargo que permite criar, testar e compartilhar o crates
* **Crates**: uma árvore de módulos que produz uma biblioteca ou executável
* **Módulos e uso**: permitem controlar a organização, o escopo e a privacidade de
caminhos
* **Caminhos**: uma forma de nomear um item, como uma estrutura, função ou módulo

Neste capítulo, abordaremos todos esses recursos, discutiremos como eles interagem e
explicar como usá-los para gerenciar o escopo. No final, você deverá ter uma sólida
compreensão do sistema de módulos e ser capaz de trabalhar com osciloscópios como um profissional!

[workspaces]: ch14-03-cargo-workspaces.html
