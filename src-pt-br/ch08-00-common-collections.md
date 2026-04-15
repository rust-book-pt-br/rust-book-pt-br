# Coleções comuns

A biblioteca padrão de Rust inclui várias estruturas de dados muito úteis
chamadas _coleções_. A maioria dos outros tipos de dados representa um valor
específico, mas coleções podem conter vários valores. Diferentemente dos tipos
internos array e tupla, os dados para os quais essas coleções apontam são
armazenados no heap, o que significa que a quantidade de dados não precisa ser
conhecida em tempo de compilação e pode crescer ou encolher à medida que o
programa é executado. Cada tipo de coleção tem capacidades e custos diferentes,
e escolher a coleção adequada para cada situação é uma habilidade que você vai
desenvolver com o tempo. Neste capítulo, discutiremos três coleções muito
usadas em programas Rust:

- Um _vetor_ permite armazenar uma quantidade variável de valores lado a lado.
- Uma _string_ é uma coleção de caracteres. Já mencionamos o tipo `String`,
  mas neste capítulo vamos estudá-lo com mais profundidade.
- Um _hash map_ permite associar um valor a uma chave específica. Ele é uma
  implementação particular de uma estrutura de dados mais geral chamada
  _mapa_.

Para conhecer os outros tipos de coleção oferecidos pela biblioteca padrão, veja
[a documentação][collections].

Vamos discutir como criar e atualizar vetores, strings e hash maps, além do que
torna cada um deles especial.

[collections]: ../std/collections/index.html
