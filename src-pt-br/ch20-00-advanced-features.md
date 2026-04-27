# Recursos Avançados

Até agora, você aprendeu as partes mais comumente usadas da linguagem de
programação Rust. Antes de fazermos mais um projeto, no Capítulo 21, veremos
alguns aspectos da linguagem que você pode encontrar de vez em quando, mas
talvez não use todos os dias. Você pode usar este capítulo como referência
quando se deparar com algo desconhecido. Os recursos abordados aqui são úteis
em situações muito específicas. Embora você possa não recorrer a eles com
frequência, queremos ter certeza de que você tenha uma compreensão de todos os
recursos que Rust tem a oferecer.

Neste capítulo, abordaremos:

- Unsafe Rust: como abrir mão de algumas das garantias de Rust e assumir a
  responsabilidade de manter manualmente essas garantias
- Traits avançadas: tipos associados, parâmetros de tipo padrão, sintaxe
  totalmente qualificada, supertraits e o padrão newtype em relação a traits
- Tipos avançados: mais sobre o padrão newtype, aliases de tipo, tipo never,
  e tipos de tamanho dinâmico
- Funções avançadas e closures: ponteiros de função e retorno de closures
- Macros: maneiras de definir código que define mais código em tempo de compilação

É uma bela variedade de recursos de Rust, com algo para todos! Vamos mergulhar!
