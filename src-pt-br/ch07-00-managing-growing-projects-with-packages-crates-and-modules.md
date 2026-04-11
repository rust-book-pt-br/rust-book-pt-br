<!-- Old headings. Do not remove or links may break. -->

<a id="managing-growing-projects-with-packages-crates-and-modules"></a>

# Pacotes, crates e módulos

À medida que você escreve programas maiores, a organização do seu código se torna cada vez mais
importante. Ao agrupar funcionalidades relacionadas e separar o código por
recursos, você deixa mais claro onde encontrar a implementação de um determinado
recurso e onde fazer alterações no seu funcionamento.

Os programas que escrevemos até agora estavam em um único módulo, em um único arquivo.
À medida que um projeto cresce, você deve organizar o código dividindo-o em vários módulos
e depois em vários arquivos. Um pacote pode conter vários crates binários e,
opcionalmente, um crate de biblioteca. À medida que um pacote cresce, você pode extrair partes em
crates separados, que se tornam dependências externas. Este capítulo cobre todas
essas técnicas. Para projetos muito grandes compostos por vários pacotes
inter-relacionados que evoluem juntos, o Cargo fornece workspaces, que abordaremos em
[“Cargo Workspaces”][workspaces]<!-- ignore --> no Capítulo 14.

Também discutiremos o encapsulamento de detalhes de implementação, o que permite reutilizar
código em um nível mais alto: depois de implementar uma operação, outro código pode
chamá-la por meio da sua interface pública sem precisar saber como a
implementação funciona. A maneira como você escreve o código define quais partes são públicas para
outro código usar e quais partes são detalhes de implementação privados que você
se reserva o direito de alterar. Esta é outra forma de limitar a quantidade de detalhes
que você precisa manter na cabeça.

Um conceito relacionado é escopo: o contexto aninhado no qual o código é escrito tem um
conjunto de nomes definidos como “no escopo”. Ao ler, escrever e
ao compilar código, programadores e compiladores precisam saber se um determinado
nome em um local específico refere-se a uma variável, função, struct, enum, módulo,
constante ou outro item e o que esse item significa. Você pode criar escopos e
alterar quais nomes estão dentro ou fora do escopo. Você não pode ter dois itens com o
mesmo nome no mesmo escopo; ferramentas estão disponíveis para resolver conflitos de nomes.

Rust possui vários recursos que permitem gerenciar a organização do seu código,
incluindo quais detalhes são expostos, quais detalhes são privados
e quais nomes estão em cada escopo dos seus programas. Esses recursos, às vezes
referidos coletivamente como _sistema de módulos_, incluem:

* **Pacotes**: um recurso do Cargo que permite criar, testar e compartilhar crates
* **Crates**: uma árvore de módulos que produz uma biblioteca ou executável
* **Módulos e `use`**: permitem controlar a organização, o escopo e a privacidade dos
caminhos
* **Caminhos**: uma forma de nomear um item, como uma estrutura, função ou módulo

Neste capítulo, abordaremos todos esses recursos, discutiremos como eles interagem e
explicaremos como usá-los para gerenciar o escopo. Ao final, você deverá ter uma boa
compreensão do sistema de módulos e ser capaz de trabalhar com escopos como um profissional!

[workspaces]: ch14-03-cargo-workspaces.html
