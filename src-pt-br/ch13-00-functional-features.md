# Recursos funcionais de linguagem: iteradores e fechamentos

O design do Rust foi inspirado em muitas linguagens existentes e
técnicas, e uma influência significativa é a _programação funcional_.
A programação em um estilo funcional geralmente inclui o uso de funções como valores por
passando-os em argumentos, retornando-os de outras funções, atribuindo-os
para variáveis para execução posterior e assim por diante.

Neste capítulo, não debateremos a questão do que é programação funcional ou
não é, mas discutirá alguns recursos do Rust que são semelhantes a
recursos em muitos idiomas, muitas vezes chamados de funcionais.

More specifically, we’ll cover:

- _Closures_, uma construção semelhante a uma função que você pode armazenar em uma variável
- _Iteradores_, uma forma de processar uma série de elementos
- Como usar closures e iterators para melhorar o projeto de E/S no Capítulo 12
- O desempenho do closures e iterators (alerta de spoiler: eles são mais rápidos que
  você pode pensar!)

Já cobrimos alguns outros recursos do Rust, como correspondência de padrões e
enums, que também são influenciados pelo estilo funcional. Porque dominar
closures e iterators são uma parte importante da escrita rápida e idiomática, Rust
código, dedicaremos este capítulo inteiro a eles.
