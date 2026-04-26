# Ponteiros Inteligentes

Um _ponteiro_ é um conceito geral para uma variável que contém um endereço na
memória. Esse endereço se refere a, ou "aponta para", algum outro dado. O tipo
mais comum de ponteiro em Rust é a referência, sobre a qual você aprendeu no
Capítulo 4. Referências são indicadas pelo símbolo `&` e pegam emprestado o
valor para o qual apontam. Elas não têm nenhuma capacidade especial além de se
referirem a dados, e não têm custo adicional.

_Ponteiros inteligentes_ (_smart pointers_), por outro lado, são estruturas de
dados que agem como ponteiros, mas também têm metadados e capacidades
adicionais. O conceito de ponteiros inteligentes não é exclusivo de Rust:
ponteiros inteligentes surgiram em C++ e também existem em outras linguagens. A
biblioteca padrão de Rust define vários ponteiros inteligentes que oferecem
funcionalidades além daquelas fornecidas por referências. Para explorar o
conceito geral, veremos alguns exemplos diferentes de ponteiros inteligentes,
incluindo um tipo de ponteiro inteligente com _contagem de referências_
(_reference counting_). Esse ponteiro permite que dados tenham múltiplos donos,
mantendo registro da quantidade de donos e, quando nenhum dono resta, limpando
os dados.

Em Rust, com seus conceitos de ownership e borrowing, há uma diferença
adicional entre referências e ponteiros inteligentes: enquanto referências
apenas pegam dados emprestados, em muitos casos ponteiros inteligentes _têm
ownership_ dos dados para os quais apontam.

Ponteiros inteligentes normalmente são implementados usando structs. Diferente
de uma struct comum, ponteiros inteligentes implementam as traits `Deref` e
`Drop`. A trait `Deref` permite que uma instância da struct do ponteiro
inteligente se comporte como uma referência, para que você possa escrever código
que funcione tanto com referências quanto com ponteiros inteligentes. A trait
`Drop` permite personalizar o código executado quando uma instância do ponteiro
inteligente sai de escopo. Neste capítulo, discutiremos essas duas traits e
mostraremos por que elas são importantes para ponteiros inteligentes.

Como o padrão de ponteiro inteligente é um padrão de projeto geral usado com
frequência em Rust, este capítulo não cobrirá todos os ponteiros inteligentes
existentes. Muitas bibliotecas têm seus próprios ponteiros inteligentes, e você
pode até escrever os seus. Vamos cobrir os ponteiros inteligentes mais comuns
da biblioteca padrão:

- `Box<T>`, para alocar valores no heap
- `Rc<T>`, um tipo com contagem de referências que permite ownership múltiplo
- `Ref<T>` e `RefMut<T>`, acessados por meio de `RefCell<T>`, um tipo que
  aplica as regras de borrowing em tempo de execução, em vez de em tempo de
  compilação

Além disso, vamos cobrir o padrão de _mutabilidade interior_ (_interior
mutability_), no qual um tipo imutável expõe uma API para modificar um valor
interno. Também discutiremos ciclos de referências: como eles podem vazar
memória e como evitá-los.

Vamos mergulhar!
