# Escrevendo Testes Automatizados

Em seu ensaio de 1972, “The Humble Programmer”, Edsger W. Dijkstra disse que
“testar programas pode ser uma forma muito eficaz de mostrar a presença de
bugs, mas é irremediavelmente inadequado para mostrar sua ausência”. Isso não
significa que não devamos tentar testar o máximo possível!

A _correção_ dos nossos programas é a medida de quanto nosso código faz aquilo
que pretendemos que ele faça. Rust foi projetada com uma grande preocupação
com a correção dos programas, mas correção é algo complexo e difícil de provar.
O sistema de tipos de Rust assume uma parte enorme desse fardo, mas ele não
consegue detectar tudo. Por isso, Rust inclui suporte à escrita de testes
automatizados de software.

Suponha que escrevamos uma função `add_two` que soma 2 a qualquer número
recebido. A assinatura dessa função aceita um inteiro como parâmetro e retorna
um inteiro como resultado. Quando implementamos e compilamos essa função, Rust
faz toda a verificação de tipos e de empréstimos que você aprendeu até aqui
para garantir, por exemplo, que não estamos passando um valor `String` nem uma
referência inválida para essa função. Mas Rust _não_ consegue verificar se
essa função faz exatamente o que queremos, isto é, retornar o parâmetro mais 2
em vez de, por exemplo, o parâmetro mais 10 ou menos 50! É aí que entram os
testes.

Podemos escrever testes que verifiquem, por exemplo, que ao passar `3` para a
função `add_two`, o valor retornado é `5`. Podemos executar esses testes sempre
que fizermos alterações no código para garantir que um comportamento que já
estava correto não mudou.

Testar é uma habilidade complexa: embora não possamos cobrir em um único
capítulo todos os detalhes de como escrever bons testes, neste capítulo vamos
discutir a mecânica dos recursos de teste de Rust. Falaremos sobre as
anotações e macros disponíveis ao escrever testes, o comportamento padrão e as
opções fornecidas para executá-los, e como organizar testes em testes
unitários e testes de integração.
