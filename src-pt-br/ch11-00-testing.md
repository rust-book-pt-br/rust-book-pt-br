# Escrevendo testes automatizados

Em seu ensaio de 1972 “The Humble Programmer”, Edsger W. Dijkstra disse que “o programa
o teste pode ser uma forma muito eficaz de mostrar a presença de bugs, mas é
irremediavelmente inadequado para mostrar sua ausência.” Isso não significa que não deveríamos
tente testar o máximo que pudermos!

_Correção_ em nossos programas é até que ponto nosso código faz o que
pretendo que isso aconteça. A ferrugem é projetada com um alto grau de preocupação com o
correcção dos programas, mas a correcção é complexa e não é fácil de provar.
O sistema de tipos do Rust assume uma grande parte desse fardo, mas o sistema de tipos
não pode pegar tudo. Como tal, Rust inclui suporte para escrita automatizada
testes de software.

Digamos que escrevemos uma função `add_two` que adiciona 2 a qualquer número passado
isto. A assinatura desta função aceita um número inteiro como parâmetro e retorna um
inteiro como resultado. Quando implementamos e compilamos essa função, Rust faz tudo
a verificação de tipo e verificação de empréstimo que você aprendeu até agora para garantir
que, por exemplo, não estamos passando um valor `String` ou uma referência inválida
para esta função. Mas Rust _não_ pode verificar se esta função funcionará com precisão
o que pretendemos, que é retornar o parâmetro mais 2 em vez de, digamos, o
parâmetro mais 10 ou o parâmetro menos 50! É aí que entram os testes.

Podemos escrever testes que afirmem, por exemplo, que quando passamos `3` para o
`add_two`, o valor retornado é `5`. Podemos executar esses testes sempre que
fazemos alterações em nosso código para garantir que qualquer comportamento correto existente não tenha
mudado.

Testar é uma habilidade complexa: embora não possamos cobrir todos os detalhes em um capítulo
sobre como escrever bons testes, neste capítulo discutiremos a mecânica de
Instalações de teste de Rust. Falaremos sobre as anotações e macros
disponível para você ao escrever seus testes, o comportamento padrão e as opções
fornecido para executar seus testes e como organizar testes em testes unitários e
testes de integração.
