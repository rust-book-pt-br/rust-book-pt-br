# Padrões e correspondência

Os padrões são uma sintaxe especial em Rust para fazer correspondência com a estrutura de
tipos, complexos e simples. Usar padrões em conjunto com expressões `match`
e outras construções oferece mais controle sobre o fluxo de controle do
programa. Um padrão consiste em alguma combinação dos seguintes elementos:

- Literais
- Arrays, enums, structs ou tuplas desestruturados
- Variáveis
- Curingas
- Marcadores

Alguns exemplos de padrões incluem `x`, `(a, 3)` e `Some(Color::Red)`. Nos
contextos em que os padrões são válidos, esses componentes descrevem a forma de
dados. Nosso programa então compara os valores com os padrões para determinar se
ele tem o formato correto dos dados para continuar executando um determinado trecho de código.

Para usar um padrão, nós o comparamos com algum valor. Se o padrão corresponder ao
valor, usamos as partes do valor em nosso código. Lembre-se das expressões `match` do
Capítulo 6, que usavam padrões, como o exemplo da máquina de classificação de moedas. Se o
valor se ajusta ao formato do padrão, podemos usar as partes nomeadas. Se isso
não, o código associado ao padrão não será executado.

Este capítulo é uma referência sobre tudo o que se relaciona a padrões. Vamos cobrir os
lugares válidos para usar padrões, a diferença entre padrões refutáveis e irrefutáveis
e os diferentes tipos de sintaxe de padrão que você pode encontrar. Ao
final do capítulo, você saberá como usar padrões para expressar muitos conceitos de
uma maneira clara.
