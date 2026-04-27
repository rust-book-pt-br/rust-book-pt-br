# Padrões e Matching

Padrões são uma sintaxe especial em Rust para fazer matching contra a estrutura
de tipos, tanto complexos quanto simples. Usar padrões em conjunto com
expressões `match` e outras construções oferece mais controle sobre o fluxo de
controle do programa. Um padrão consiste em alguma combinação dos seguintes
elementos:

- Literais
- Arrays, enums, structs ou tuplas com desestruturação
- Variáveis
- Curingas
- Marcadores

Alguns exemplos de padrões incluem `x`, `(a, 3)` e `Some(Color::Red)`. Nos
contextos em que os padrões são válidos, esses componentes descrevem a forma
dos dados. Nosso programa então compara valores com os padrões para determinar
se eles têm a forma correta de dados para continuar executando um determinado
trecho de código.

Para usar um padrão, nós o comparamos com algum valor. Se o padrão corresponder
ao valor, usamos as partes do valor em nosso código. Lembre-se das expressões
`match` do Capítulo 6 que usavam padrões, como o exemplo da máquina de
classificação de moedas. Se o valor se ajusta à forma do padrão, podemos usar
as partes nomeadas. Se não, o código associado ao padrão não será executado.

Este capítulo é uma referência sobre tudo que se relaciona a padrões. Vamos
cobrir os lugares válidos para usar padrões, a diferença entre padrões
refutáveis e irrefutáveis e os diferentes tipos de sintaxe de padrão que você
pode encontrar. Ao final do capítulo, você saberá como usar padrões para
expressar muitos conceitos de uma maneira clara.
