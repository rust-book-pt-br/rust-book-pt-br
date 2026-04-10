# Padrões e correspondência

Os padrões são uma sintaxe especial em Rust para correspondência com a estrutura de
tipos, complexos e simples. Usando padrões em conjunto com `match`
expressões e outras construções oferecem mais controle sobre o programa
fluxo de controle. Um padrão consiste em alguma combinação do seguinte:

- Literals
- Destructured arrays, enums, structs, or tuples
- Variables
- Wildcards
- Placeholders

Alguns padrões de exemplo incluem `x`, ` (a, 3)`e ` Some(Color::Red)`. No
contextos em que os padrões são válidos, esses componentes descrevem a forma de
dados. Nosso programa então compara os valores com os padrões para determinar se
ele tem o formato correto dos dados para continuar executando um determinado trecho de código.

Para usar um padrão, nós o comparamos com algum valor. Se o padrão corresponder ao
valor, usamos as partes de valor em nosso código. Lembre-se das expressões `match` em
Capítulo 6 que usou padrões, como o exemplo da máquina de classificação de moedas. Se o
valor se ajusta ao formato do padrão, podemos usar as peças nomeadas. Se isso
não, o código associado ao padrão não será executado.

Este capítulo é uma referência sobre todas as coisas relacionadas a padrões. Nós vamos cobrir o
lugares válidos para usar padrões, a diferença entre refutável e irrefutável
padrões e os diferentes tipos de sintaxe de padrão que você pode ver. Pelo
No final do capítulo, você saberá como usar padrões para expressar muitos conceitos em
uma maneira clara.
