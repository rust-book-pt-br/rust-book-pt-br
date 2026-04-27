## Características de Linguagens Orientadas a Objetos

Não há consenso na comunidade de programação sobre quais recursos uma linguagem
precisa ter para ser considerada orientada a objetos. Rust é influenciado por
muitos paradigmas de programação, incluindo OOP; por exemplo, exploramos os
recursos vindos da programação funcional no Capítulo 13. Pode-se argumentar
que linguagens OOP compartilham certas características comuns, a saber:
objetos, encapsulamento e herança. Vamos ver o que cada uma dessas
características significa e se Rust oferece suporte a ela.

### Objetos Contêm Dados e Comportamento

O livro _Design Patterns: Elements of Reusable Object-Oriented Software_, de
Erich Gamma, Richard Helm, Ralph Johnson e John Vlissides (Addison-Wesley,
1994), coloquialmente conhecido como o livro da _Gang of Four_, é um catálogo
de padrões de projeto orientados a objetos. Ele define OOP desta forma:

> Programas orientados a objetos são compostos de objetos. Um **objeto**
> empacota tanto dados quanto os procedimentos que operam sobre esses dados. Os
> procedimentos normalmente são chamados de **métodos** ou **operações**.

Usando essa definição, Rust é orientado a objetos: structs e enums têm dados, e
blocos `impl` fornecem métodos para structs e enums. Mesmo que structs e enums
com métodos não sejam _chamados_ de objetos, eles fornecem a mesma
funcionalidade segundo a definição de objetos da Gang of Four.

### Encapsulamento Que Oculta Detalhes de Implementação

Outro aspecto comumente associado a OOP é a ideia de _encapsulamento_, que
significa que os detalhes de implementação de um objeto não são acessíveis ao
código que usa esse objeto. Portanto, a única forma de interagir com um objeto
é por meio de sua API pública; o código que usa o objeto não deve conseguir
alcançar as partes internas do objeto e alterar dados ou comportamento
diretamente. Isso permite que o programador altere e refatore os detalhes
internos de um objeto sem precisar alterar o código que usa esse objeto.

Discutimos como controlar o encapsulamento no Capítulo 7: podemos usar a
palavra-chave `pub` para decidir quais módulos, tipos, funções e métodos em
nosso código devem ser públicos, e por padrão todo o resto é privado. Por
exemplo, podemos definir uma struct `AveragedCollection` que tenha um campo
contendo um vetor de valores `i32`. A struct também pode ter um campo contendo
a média dos valores no vetor, o que significa que a média não precisa ser
calculada sob demanda sempre que alguém precisar dela. Em outras palavras,
`AveragedCollection` armazenará em cache a média calculada para nós. A Listagem
18-1 mostra a definição da struct `AveragedCollection`.

<Listing number="18-1" file-name="src/lib.rs" caption="Uma struct `AveragedCollection` que mantém uma lista de inteiros e a média dos itens da coleção">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-01/src/lib.rs}}
```

</Listing>

A struct é marcada como `pub` para que outro código possa usá-la, mas os campos
dentro da struct permanecem privados. Isso é importante neste caso porque
queremos garantir que, sempre que um valor for adicionado ou removido da lista,
a média também seja atualizada. Fazemos isso implementando os métodos `add`,
`remove` e `average` na struct, como mostrado na Listagem 18-2.

<Listing number="18-2" file-name="src/lib.rs" caption="Implementações dos métodos públicos `add`, `remove` e `average` em `AveragedCollection`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-02/src/lib.rs:here}}
```

</Listing>

Os métodos públicos `add`, `remove` e `average` são as únicas formas de acessar
ou modificar dados em uma instância de `AveragedCollection`. Quando um item é
adicionado a `list` usando o método `add` ou removido usando o método `remove`,
as implementações de cada método chamam o método privado `update_average`, que
também cuida de atualizar o campo `average`.

Deixamos os campos `list` e `average` privados para que não haja como código
externo adicionar ou remover itens diretamente do campo `list`; caso contrário,
o campo `average` poderia ficar fora de sincronia quando `list` mudasse. O
método `average` retorna o valor no campo `average`, permitindo que código
externo leia a média, mas não a modifique.

Como encapsulamos os detalhes de implementação da struct `AveragedCollection`,
podemos alterar facilmente aspectos como a estrutura de dados no futuro. Por
exemplo, poderíamos usar um `HashSet<i32>` em vez de um `Vec<i32>` para o campo
`list`. Desde que as assinaturas dos métodos públicos `add`, `remove` e
`average` permanecessem iguais, o código que usa `AveragedCollection` não
precisaria mudar. Se tornássemos `list` público, isso não seria necessariamente
verdade: `HashSet<i32>` e `Vec<i32>` têm métodos diferentes para adicionar e
remover itens, então o código externo provavelmente teria que mudar se estivesse
modificando `list` diretamente.

Se encapsulamento é um aspecto obrigatório para que uma linguagem seja
considerada orientada a objetos, então Rust atende a esse requisito. A opção de
usar `pub` ou não em diferentes partes do código permite encapsular detalhes de
implementação.

### Herança Como Sistema de Tipos e Compartilhamento de Código

_Herança_ é um mecanismo pelo qual um objeto pode herdar elementos da definição
de outro objeto, obtendo assim os dados e o comportamento do objeto pai sem que
você precise defini-los novamente.

Se uma linguagem precisa ter herança para ser orientada a objetos, então Rust
não é uma linguagem desse tipo. Não há como definir uma struct que herde os
campos e as implementações de métodos da struct pai sem usar uma macro.

No entanto, se você está acostumado a ter herança na sua caixa de ferramentas
de programação, pode usar outras soluções em Rust, dependendo do motivo pelo
qual você recorreria à herança em primeiro lugar.

Você escolheria herança por dois motivos principais. Um deles é reutilização de
código: você pode implementar um comportamento específico para um tipo, e a
herança permite reutilizar essa implementação para outro tipo. É possível fazer
isso de forma limitada em código Rust usando implementações padrão de métodos
de traits, como você viu na Listagem 10-14 quando adicionamos uma implementação
padrão do método `summarize` na trait `Summary`. Qualquer tipo que implemente a
trait `Summary` teria o método `summarize` disponível sem código adicional.
Isso é semelhante a uma classe pai ter uma implementação de um método e uma
classe filha que herda também ter essa implementação. Também podemos sobrescrever
a implementação padrão do método `summarize` ao implementar a trait `Summary`,
o que é semelhante a uma classe filha sobrescrever a implementação de um método
herdado de uma classe pai.

O outro motivo para usar herança está relacionado ao sistema de tipos: permitir
que um tipo filho seja usado nos mesmos lugares que o tipo pai. Isso também é
chamado de _polimorfismo_, que significa que você pode substituir múltiplos
objetos uns pelos outros em tempo de execução se eles compartilharem certas
características.

> ### Polimorfismo
>
> Para muitas pessoas, polimorfismo é sinônimo de herança. Mas, na verdade, é
> um conceito mais geral que se refere a código que pode trabalhar com dados de
> múltiplos tipos. Com herança, esses tipos geralmente são subclasses.
>
> Rust, por sua vez, usa genéricos para abstrair sobre diferentes tipos
> possíveis e trait bounds para impor restrições sobre o que esses tipos devem
> fornecer. Isso às vezes é chamado de _polimorfismo paramétrico limitado_.

Rust escolheu um conjunto diferente de trade-offs ao não oferecer herança.
Herança frequentemente corre o risco de compartilhar mais código do que o
necessário. Subclasses nem sempre deveriam compartilhar todas as características
de sua classe pai, mas farão isso com herança. Isso pode tornar o design de um
programa menos flexível. Também introduz a possibilidade de chamar métodos em
subclasses que não fazem sentido ou que causam erros porque os métodos não se
aplicam à subclasse. Além disso, algumas linguagens permitem apenas _herança
única_ (ou seja, uma subclasse só pode herdar de uma classe), restringindo
ainda mais a flexibilidade do design de um programa.

Por esses motivos, Rust adota a abordagem diferente de usar objetos trait em
vez de herança para obter polimorfismo em tempo de execução. Vamos ver como
objetos trait funcionam.
