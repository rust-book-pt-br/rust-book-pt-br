# Escrevendo testes automatizados

Em seu ensaio de 1972, "The Humble Programmer", Edsger W. Dijkstra disse que
"o teste de programa pode ser uma maneira muito eficaz de mostrar a presença de
bugs, mas é irremediavelmente inadequado para mostrar sua ausência". Isso não
significa que não devamos tentar testar o máximo que pudermos!

_Correção_ em nossos programas é o grau em que nosso código faz o que
pretendemos que ele faça. O Rust foi projetado com alto grau de preocupação com
a correção dos programas, mas correção é algo complexo e difícil de provar. O
sistema de tipos do Rust assume grande parte desse fardo, mas não consegue
capturar todo tipo de incorreção. Por isso, o Rust inclui suporte para escrever
testes de software automatizados dentro da própria linguagem.

Como exemplo, digamos que escrevemos uma função chamada `adicionar_dois`, que
adiciona 2 a qualquer número passado a ela. A assinatura dessa função aceita um
inteiro como parâmetro e retorna um inteiro como resultado. Quando implementamos
e compilamos essa função, o Rust faz toda a verificação de tipos e de
empréstimos que você aprendeu até agora para garantir que, por exemplo, não
estamos passando um valor `String` ou uma referência inválida para essa função.
Mas o Rust não pode verificar se essa função fará exatamente o que
pretendemos, que é retornar o parâmetro mais 2 em vez de, digamos, o parâmetro
mais 10 ou menos 50! É aí que entram os testes.

Podemos escrever testes que afirmem, por exemplo, que, quando passamos `3` para
a função `adicionar_dois`, o valor retornado é `5`. Podemos executar esses
testes sempre que fizermos alterações no código para garantir que nenhum
comportamento correto já existente tenha sido alterado.

Testar é uma habilidade complexa: embora não possamos cobrir, em um único
capítulo, todos os detalhes sobre como escrever bons testes, discutiremos a
mecânica das ferramentas de teste do Rust. Falaremos sobre as anotações e
macros disponíveis ao escrever testes, o comportamento padrão e as opções
fornecidas para executá-los, além de como organizar testes de unidade e testes
de integração.
