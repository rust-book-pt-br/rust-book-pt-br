## Apêndice C: Traits Deriváveis

Em vários pontos do livro, discutimos o atributo `derive`, que você pode
aplicar a uma definição de struct ou enum. O atributo `derive` gera código que
implementa um trait com sua própria implementação padrão no tipo anotado com a
sintaxe `derive`.

Neste apêndice, oferecemos uma referência para todos os traits da biblioteca
padrão que você pode usar com `derive`. Cada seção cobre:

- Quais operadores e métodos derivar esse trait habilita
- O que a implementação do trait fornecida por `derive` faz
- O que implementar esse trait sinaliza sobre o tipo
- Em que condições você pode ou não pode implementar o trait
- Exemplos de operações que exigem esse trait

Se você quiser um comportamento diferente daquele fornecido pelo atributo
`derive`, consulte a [documentação da biblioteca padrão](../std/index.html)<!--
ignore --> de cada trait para saber como implementá-lo manualmente.

Os traits listados aqui são os únicos definidos pela biblioteca padrão que
podem ser implementados em seus tipos usando `derive`. Outros traits definidos
na biblioteca padrão não têm um comportamento padrão sensato, então cabe a você
implementá-los da forma que fizer sentido para aquilo que está tentando
construir.

Um exemplo de trait que não pode ser derivado é `Display`, responsável pela
formatação voltada a usuários finais. Você sempre deve considerar qual é a
forma adequada de exibir um tipo para uma pessoa usuária. Quais partes do tipo
essa pessoa deve poder ver? Quais partes seriam relevantes para ela? Qual
formato dos dados faz mais sentido nesse contexto? O compilador Rust não tem
essa percepção, então ele não pode fornecer para você um comportamento padrão
apropriado.

A lista de traits deriváveis fornecida neste apêndice não é exaustiva:
bibliotecas podem implementar `derive` para seus próprios traits, o que torna a
lista de traits que você pode usar com `derive` realmente aberta. Implementar
`derive` envolve usar uma macro procedural, assunto abordado na seção
[“Macros `derive` personalizadas”][custom-derive-macros]<!-- ignore --> do
Capítulo 20.

### `Debug` para saída voltada a programadores

O trait `Debug` habilita a formatação de depuração em format strings, indicada
ao adicionar `:?` dentro dos placeholders `{}`.

O trait `Debug` permite imprimir instâncias de um tipo para fins de depuração,
de modo que você e outras pessoas programadoras usando esse tipo possam
inspecionar uma instância em um ponto específico da execução do programa.

O trait `Debug` é exigido, por exemplo, no uso da macro `assert_eq!`. Essa
macro imprime os valores das instâncias passadas como argumentos caso a
asserção de igualdade falhe, para que programadores possam ver por que as duas
instâncias não eram iguais.

### `PartialEq` e `Eq` para comparações de igualdade

O trait `PartialEq` permite comparar instâncias de um tipo para verificar
igualdade e habilita o uso dos operadores `==` e `!=`.

Derivar `PartialEq` implementa o método `eq`. Quando `PartialEq` é derivado em
structs, duas instâncias são iguais somente se _todos_ os campos forem iguais,
e as instâncias não são iguais se _qualquer_ campo for diferente. Quando
derivado em enums, cada variante é igual a si mesma e diferente das demais
variantes.

O trait `PartialEq` é exigido, por exemplo, no uso da macro `assert_eq!`, que
precisa conseguir comparar duas instâncias de um tipo quanto à igualdade.

O trait `Eq` não possui métodos. Seu objetivo é sinalizar que, para todo valor
do tipo anotado, o valor é igual a si mesmo. O trait `Eq` só pode ser aplicado
a tipos que também implementam `PartialEq`, embora nem todo tipo que
implementa `PartialEq` possa implementar `Eq`. Um exemplo disso são os tipos de
números de ponto flutuante: a implementação desses números afirma que duas
instâncias do valor not-a-number (`NaN`) não são iguais entre si.

Um exemplo de quando `Eq` é necessário é em chaves de um `HashMap<K, V>`, para
que o `HashMap<K, V>` possa dizer se duas chaves são iguais.

### `PartialOrd` e `Ord` para comparações de ordenação

O trait `PartialOrd` permite comparar instâncias de um tipo para fins de
ordenação. Um tipo que implementa `PartialOrd` pode ser usado com os operadores
`<`, `>`, `<=` e `>=`. Você só pode aplicar `PartialOrd` a tipos que também
implementem `PartialEq`.

Derivar `PartialOrd` implementa o método `partial_cmp`, que retorna um
`Option<Ordering>` que será `None` quando os valores comparados não produzirem
uma ordenação. Um exemplo de valor que não produz ordenação, embora a maioria
dos valores desse tipo possa ser comparada, é o valor `NaN` de ponto
flutuante. Chamar `partial_cmp` com qualquer número de ponto flutuante e o
valor `NaN` retornará `None`.

Quando derivado em structs, `PartialOrd` compara duas instâncias comparando o
valor de cada campo na ordem em que os campos aparecem na definição da struct.
Quando derivado em enums, variantes declaradas antes na definição do enum são
consideradas menores do que variantes listadas depois.

O trait `PartialOrd` é necessário, por exemplo, para o método `gen_range` do
crate `rand`, que gera um valor aleatório no intervalo especificado por uma
expressão de range.

O trait `Ord` permite saber que, para quaisquer dois valores do tipo anotado,
existirá uma ordenação válida. O trait `Ord` implementa o método `cmp`, que
retorna um `Ordering` em vez de `Option<Ordering>`, porque uma ordenação válida
sempre será possível. Você só pode aplicar o trait `Ord` a tipos que também
implementem `PartialOrd` e `Eq` e, por consequência, `PartialEq`. Quando
derivado em structs e enums, `cmp` se comporta da mesma forma que a
implementação derivada de `partial_cmp` com `PartialOrd`.

Um exemplo de quando `Ord` é necessário é ao armazenar valores em um
`BTreeSet<T>`, uma estrutura de dados que guarda dados com base na ordem de
classificação dos valores.

### `Clone` e `Copy` para duplicar valores

O trait `Clone` permite criar explicitamente uma cópia profunda de um valor, e
o processo de duplicação pode envolver execução de código arbitrário e cópia de
dados no heap. Veja a seção [“Variáveis e dados interagindo com
Clone”][variables-and-data-interacting-with-clone]<!-- ignore --> do Capítulo
4 para mais informações sobre `Clone`.

Derivar `Clone` implementa o método `clone`, que, quando implementado para o
tipo inteiro, chama `clone` em cada uma das partes do tipo. Isso significa que
todos os campos ou valores do tipo também precisam implementar `Clone` para que
ele possa ser derivado.

Um exemplo de quando `Clone` é necessário é ao chamar o método `to_vec` em uma
slice. A slice não é dona das instâncias do tipo que contém, mas o vetor
retornado por `to_vec` precisará ser dono dessas instâncias, então `to_vec`
chama `clone` em cada item. Assim, o tipo armazenado na slice precisa
implementar `Clone`.

O trait `Copy` permite duplicar um valor apenas copiando os bits armazenados na
stack; nenhum código arbitrário é necessário. Veja a seção [“Dados apenas na
stack: Copy”][stack-only-data-copy]<!-- ignore --> do Capítulo 4 para mais
informações sobre `Copy`.

O trait `Copy` não define métodos justamente para impedir que programadores
sobrecarreguem métodos e violem a suposição de que nenhum código arbitrário
está sendo executado. Dessa forma, todos podem assumir que copiar um valor será
muito rápido.

Você pode derivar `Copy` em qualquer tipo cujas partes todas implementem
`Copy`. Um tipo que implementa `Copy` também deve implementar `Clone`, porque
um tipo que implementa `Copy` tem uma implementação trivial de `Clone` que
realiza a mesma tarefa que `Copy`.

O trait `Copy` raramente é exigido; tipos que implementam `Copy` têm
otimizações disponíveis, o que significa que você não precisa chamar `clone`, e
isso deixa o código mais conciso.

Tudo o que é possível fazer com `Copy` também pode ser feito com `Clone`, mas o
código pode ficar mais lento ou precisar usar `clone` em mais lugares.

### `Hash` para mapear um valor para outro valor de tamanho fixo

O trait `Hash` permite pegar uma instância de um tipo de tamanho arbitrário e
mapeá-la para um valor de tamanho fixo usando uma função hash. Derivar `Hash`
implementa o método `hash`. A implementação derivada do método `hash` combina o
resultado de chamar `hash` em cada uma das partes do tipo, o que significa que
todos os campos ou valores também precisam implementar `Hash` para que `Hash`
possa ser derivado.

Um exemplo de quando `Hash` é necessário é no armazenamento de chaves em um
`HashMap<K, V>`, para guardar dados de maneira eficiente.

### `Default` para valores padrão

O trait `Default` permite criar um valor padrão para um tipo. Derivar `Default`
implementa a função `default`. A implementação derivada de `default` chama
`default` em cada parte do tipo, o que significa que todos os campos ou valores
do tipo também precisam implementar `Default` para que esse trait possa ser
derivado.

A função `Default::default` é comumente usada em combinação com a sintaxe de
atualização de struct discutida na seção [“Criando instâncias a partir de
outras instâncias com a sintaxe de atualização de
struct”][creating-instances-from-other-instances-with-struct-update-syntax]<!--
ignore --> do Capítulo 5. Você pode personalizar alguns campos de uma struct e
então definir e usar um valor padrão para o restante dos campos usando
`..Default::default()`.

O trait `Default` é necessário quando você usa, por exemplo, o método
`unwrap_or_default` em instâncias de `Option<T>`. Se o `Option<T>` for `None`,
o método `unwrap_or_default` retornará o resultado de `Default::default` para o
tipo `T` armazenado no `Option<T>`.

[creating-instances-from-other-instances-with-struct-update-syntax]: ch05-01-defining-structs.html#creating-instances-from-other-instances-with-struct-update-syntax
[stack-only-data-copy]: ch04-01-what-is-ownership.html#stack-only-data-copy
[variables-and-data-interacting-with-clone]: ch04-01-what-is-ownership.html#variables-and-data-interacting-with-clone
[custom-derive-macros]: ch20-05-macros.html#custom-derive-macros
