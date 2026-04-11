## Características das linguagens orientadas a objetos

Não há consenso na comunidade de programação sobre o que caracteriza uma
linguagem como orientada a objetos. Rust é influenciado por muitos
paradigmas de programação, incluindo OOP; por exemplo, exploramos os recursos
que vieram da programação funcional no Capítulo 13. Indiscutivelmente, linguagens OOP
compartilham certas características comuns - ou seja, objetos, encapsulamento e
herança. Vejamos o que cada uma dessas características significa e se
Rust suporta isso.

### Objetos contêm dados e comportamento

O livro _Design Patterns: Elements of Reusable Object-Oriented Software_ de
Erich Gamma, Richard Helm, Ralph Johnson e John Vlissides (Addison-Wesley,
1994), coloquialmente referido como livro _The Gang of Four_, é um catálogo de
padrões de projeto orientados a objetos. Ele define OOP desta forma:

> Os programas orientados a objetos são compostos de objetos. Um **objeto** empacota ambos
> dados e os procedimentos que operam nesses dados. Os procedimentos são
> normalmente chamados de **métodos** ou **operações**.

Usando esta definição, Rust é orientado a objetos: structs e enums possuem dados,
e os blocos `impl` fornecem métodos em structs e enums. Mesmo que structs e
enums com métodos não sejam chamados de objetos, eles fornecem a mesma
funcionalidade, de acordo com a definição de objetos da Gangue dos Quatro.

### Encapsulamento que oculta detalhes de implementação

Outro aspecto comumente associado à OOP é a ideia de _encapsulamento_,
o que significa que os detalhes de implementação de um objeto não são acessíveis ao
código que usa esse objeto. Portanto, a única maneira de interagir com um objeto é
por meio de sua API pública; o código que usa o objeto não deve ser capaz de acessar
as partes internas do objeto nem alterar dados ou comportamento diretamente. Isso permite que o
programador altere e refatore os componentes internos de um objeto sem a necessidade de
alterar o código que usa o objeto.

Discutimos como controlar o encapsulamento no Capítulo 7: Podemos usar o `pub`
palavra-chave para decidir quais módulos, tipos, funções e métodos em nosso código
deve ser público e, por padrão, todo o resto é privado. Por exemplo, nós
pode definir uma estrutura ` AveragedCollection`que possui um campo contendo um vetor
de valores ` i32`. A estrutura também pode ter um campo que contém a média de
os valores no vetor, o que significa que a média não precisa ser calculada
demanda sempre que alguém precisar. Em outras palavras, ` AveragedCollection`irá
armazenar em cache a média calculada para nós. A Listagem 18-1 tem a definição do
Estrutura ` AveragedCollection`.

<Listing number="18-1" file-name="src/lib.rs" caption="Uma struct `AveragedCollection` que mantém uma lista de inteiros e a média dos itens da coleção">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-01/src/lib.rs}}
```

</Listing>

A estrutura é marcada como `pub` para que outro código possa usá-la, mas os campos dentro
a estrutura permanece privada. Isto é importante neste caso porque queremos
garantir que sempre que um valor for adicionado ou removido da lista, a média seja
também atualizado. Fazemos isso implementando os métodos `add`, ` remove`e ` average`
na estrutura, conforme mostrado na Listagem 18-2.

<Listing number="18-2" file-name="src/lib.rs" caption="Implementações dos métodos públicos `add`, `remove` e `average` em `AveragedCollection`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-02/src/lib.rs:here}}
```

</Listing>

Os métodos públicos `add`, ` remove`e ` average`são as únicas formas de acessar
ou modificar dados em uma instância do ` AveragedCollection`. Quando um item é adicionado a
` list `usando o método` add `ou removido usando o método` remove `, o
implementações de cada uma chamam o método` update_average `privado que lida com
atualizando também o campo` average`.

Deixamos os campos `list` e `average` privados para que não haja como
código externo para adicionar ou remover itens diretamente do campo `list`;
caso contrário, o campo ` average`poderá ficar fora de sincronia quando o ` list`
mudanças. O método ` average`retorna o valor no campo ` average`,
permitindo que código externo leia o ` average`, mas não o modifique.

Porque encapsulamos os detalhes de implementação da estrutura
`AveragedCollection `, podemos facilmente alterar aspectos, como a estrutura de dados,
no future. Por exemplo, poderíamos usar um` HashSet<i32> `em vez de um
` Vec<i32> `para o campo` list `. Contanto que as assinaturas do` add `,
Os métodos públicos` remove `e` average `permaneceram os mesmos, código usando
` AveragedCollection `não precisaria mudar. Se tornássemos o` list `público,
este não seria necessariamente o caso:` HashSet<i32> `e` Vec<i32> `têm
métodos diferentes para adicionar e remover itens, então o código externo seria
provavelmente terá que mudar se estiver modificando` list`diretamente.

Se o encapsulamento é um aspecto necessário para que uma linguagem seja considerada objeto
orientado, então Rust atende a esse requisito. A opção de usar `pub` ou não para
diferentes partes do código permitem o encapsulamento de detalhes de implementação.

### Herança como sistema de tipos e como compartilhamento de código

_Herança_ é um mecanismo pelo qual um objeto pode herdar elementos de
definição de outro objeto, obtendo assim os dados e o comportamento do objeto pai
sem que você precise defini-los novamente.

Se uma linguagem deve ter herança para ser orientada a objetos, então Rust não é
tal linguagem. Não há como definir uma estrutura que herde o pai
campos de struct e implementações de métodos sem usar uma macro.

Entretanto, se você está acostumado a ter herança em sua caixa de ferramentas de programação, você
você pode usar outras soluções em Rust, dependendo do motivo para procurar
herança em primeiro lugar.

Você escolheria a herança por dois motivos principais. Uma é para reutilização de código:
Você pode implementar um comportamento específico para um tipo, e a herança permite
para reutilizar essa implementação para um tipo diferente. Você pode fazer isso em um tempo limitado
maneira no código Rust usando implementações padrão do método trait, que você viu em
Listagem 10-14 quando adicionamos uma implementação padrão do método `summarize`
no ` Summary`trait. Qualquer tipo implementando o ` Summary`trait teria
o método ` summarize`disponível nele sem qualquer código adicional. Isto é
semelhante a uma classe pai tendo uma implementação de um método e um
herdar a classe filha também tendo a implementação do método. Nós podemos
também substituir a implementação padrão do método ` summarize`quando
implementar o ` Summary`trait, que é semelhante a uma classe filha substituindo o
implementação de um método herdado de uma classe pai.

A outra razão para usar herança está relacionada ao sistema de tipos: para habilitar um
tipo filho a ser usado nos mesmos locais que o tipo pai. Isto também é
chamado _polimorfismo_, o que significa que você pode substituir vários objetos por
entre si em tempo de execução se eles compartilharem certas características.

> ### Polimorfismo
>
> Para muitas pessoas, polimorfismo é sinônimo de herança. Mas é
> na verdade, um conceito mais geral que se refere ao código que pode trabalhar com dados de
> vários tipos. Para herança, esses tipos geralmente são subclasses.
>
> Em vez disso, Rust usa genéricos para abstrair diferentes tipos possíveis e
> Limites trait para impor restrições sobre o que esses tipos devem fornecer. Isto é
> às vezes chamado de _polimorfismo paramétrico limitado_.

Rust escolheu um conjunto diferente de compensações ao não oferecer herança.
A herança geralmente corre o risco de compartilhar mais código do que o necessário. Subclasses
nem sempre devem compartilhar todas as características de sua classe pai, mas o farão
com herança. Isso pode tornar o design de um programa menos flexível. Também
introduz a possibilidade de chamar métodos em subclasses que não fazem
sentido ou que causam erros porque os métodos não se aplicam à subclasse. Em
Além disso, algumas linguagens permitirão apenas _herança única_ (ou seja, uma
subclasse só pode herdar de uma classe), restringindo ainda mais a flexibilidade
do design de um programa.

Por essas razões, Rust adota uma abordagem diferente de uso de objetos trait
em vez de herança para obter polimorfismo em tempo de execução. Vejamos como
Os objetos trait funcionam.
