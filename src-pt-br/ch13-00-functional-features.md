# Recursos de Linguagens Funcionais: Iteradores e Closures

O design de Rust foi inspirado por muitas linguagens e técnicas existentes, e
uma influência importante é a _programação funcional_. Programar em estilo
funcional costuma incluir usar funções como valores, passando-as como
argumentos, retornando-as de outras funções, atribuindo-as a variáveis para
execução posterior, e assim por diante.

Neste capítulo, não vamos discutir o que programação funcional é ou deixa de
ser; em vez disso, vamos explorar alguns recursos de Rust que se assemelham a
recursos presentes em muitas linguagens frequentemente chamadas de funcionais.

Mais especificamente, veremos:

- _Closures_, uma construção semelhante a função que você pode armazenar em uma
  variável
- _Iteradores_, uma forma de processar uma série de elementos
- Como usar closures e iteradores para melhorar o projeto de E/S do Capítulo
  12
- O desempenho de closures e iteradores. Spoiler: eles são mais rápidos do que
  você talvez imagine!

Já cobrimos outros recursos de Rust, como casamento de padrões e enums, que
também foram influenciados pelo estilo funcional. Como dominar closures e
iteradores é uma parte importante de escrever código Rust idiomático e rápido,
dedicaremos este capítulo inteiro a eles.
