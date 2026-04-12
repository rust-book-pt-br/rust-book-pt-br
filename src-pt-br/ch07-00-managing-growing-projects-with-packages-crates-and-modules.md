<!-- Old headings. Do not remove or links may break. -->

<a id="managing-growing-projects-with-packages-crates-and-modules"></a>

# Pacotes, Crates e Módulos

À medida que você escreve programas maiores, organizar o código se torna cada
vez mais importante. Ao agrupar funcionalidades relacionadas e separar o código
por responsabilidades bem definidas, fica mais claro onde encontrar a
implementação de um recurso e onde alterá-la quando necessário.

Até agora, os programas que escrevemos estavam em um único módulo, em um único
arquivo. Conforme um projeto cresce, é natural dividir o código em vários
módulos e, depois, em vários arquivos. Um pacote pode conter vários crates
binários e, opcionalmente, um crate de biblioteca. À medida que um pacote
evolui, você também pode extrair partes dele para crates separados, que passam
a ser dependências externas. Este capítulo cobre todas essas técnicas. Para
projetos muito grandes, formados por um conjunto de pacotes relacionados que
evoluem juntos, o Cargo oferece workspaces, que veremos em [“Cargo
Workspaces”][workspaces]<!-- ignore --> no Capítulo 14.

Também vamos discutir como encapsular detalhes de implementação, o que permite
reutilizar código em um nível mais alto: depois que você implementa uma
operação, outro código pode chamá-la por meio de sua interface pública sem
precisar saber como a implementação funciona internamente. A forma como você
escreve o código define quais partes são públicas e podem ser usadas por outros
trechos, e quais partes permanecem privadas como detalhes de implementação que
você se reserva o direito de alterar. Essa é outra maneira de limitar a
quantidade de detalhes que você precisa manter na cabeça ao mesmo tempo.

Um conceito relacionado é o de escopo: o contexto aninhado em que o código é
escrito define um conjunto de nomes que estão “em escopo”. Ao ler, escrever e
compilar código, tanto programadores quanto compiladores precisam saber se um
nome em um ponto específico se refere a uma variável, função, struct, enum,
módulo, constante ou outro item, e qual é o significado desse item. Você pode
criar novos escopos e alterar quais nomes estão ou não disponíveis em cada um
deles. E não é possível ter dois itens com o mesmo nome no mesmo escopo; para
isso, existem ferramentas para resolver conflitos de nomes.

O Rust oferece vários recursos para gerenciar a organização do código,
incluindo quais detalhes são expostos, quais permanecem privados e quais nomes
estão disponíveis em cada escopo do programa. Esses recursos, às vezes
chamados em conjunto de _sistema de módulos_, incluem:

* **Packages**: um recurso do Cargo que permite compilar, testar e compartilhar
  crates
* **Crates**: uma árvore de módulos que produz uma biblioteca ou um executável
* **Modules and use**: permitem controlar a organização, o escopo e a
  privacidade dos caminhos
* **Paths**: uma forma de nomear um item, como uma struct, função ou módulo

Neste capítulo, vamos passar por todos esses recursos, discutir como eles se
relacionam e mostrar como usá-los para gerenciar escopo. Ao final, você deve
ter uma base sólida sobre o sistema de módulos e se sentir confortável para
trabalhar com escopos em Rust.

[workspaces]: ch14-03-cargo-workspaces.html
