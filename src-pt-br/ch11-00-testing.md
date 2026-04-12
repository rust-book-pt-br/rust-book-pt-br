# Escrevendo testes automatizados

Em seu ensaio de 1972 “The Humble Programmer”, Edsger W. Dijkstra disse que “o programa
o teste pode ser uma forma muito eficaz de mostrar a presença de bugs, mas é
irremediavelmente inadequado para mostrar sua ausência.” Isso não significa que não deveríamos
tente testar o máximo que pudermos!

_Correção_ em nossos programas é o quanto nosso código faz o que pretendemos
que ele faça. O Rust foi projetado com um alto grau de preocupação com a
correção dos programas, mas correção é algo complexo e não é fácil de provar.
O sistema de tipos do Rust assume uma grande parte desse fardo, mas o sistema de tipos
não pode pegar tudo. Como tal, Rust inclui suporte para escrita automatizada
testes de software.

Digamos que escrevemos uma função `add_two` que adiciona 2 a qualquer número passado
isso. A assinatura dessa função aceita um inteiro como parâmetro e retorna um
inteiro como resultado. Quando implementamos e compilamos essa função, o Rust
faz toda a verificação de tipos e de empréstimos que você aprendeu até agora
para garantir que, por exemplo, não estamos passando um valor `String` ou uma
referência inválida para essa função. Mas o Rust _não_ consegue verificar se
essa função funcionará corretamente
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
