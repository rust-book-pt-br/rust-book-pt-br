# Coleções Comuns

A biblioteca padrão do Rust inclui uma série de estruturas de dados muito úteis chamadas
_coleções_. A maioria dos outros tipos de dados representa um valor específico, mas
coleções podem conter vários valores. Ao contrário do array e tupla integrados
tipos, os dados para os quais essas coleções apontam são armazenados no heap, que
significa que a quantidade de dados não precisa ser conhecida em tempo de compilação e pode crescer
ou encolher à medida que o programa é executado. Cada tipo de coleção tem diferentes
capacidades e custos, e escolher um apropriado para o seu atual
situação é uma habilidade que você desenvolverá com o tempo. Neste capítulo, discutiremos
três coleções que são usadas com frequência em programas Rust:

- Um _vetor_ permite armazenar um número variável de valores próximos uns dos outros.
- Uma _string_ é uma coleção de caracteres. Mencionamos o tipo `String`
anteriormente, mas neste capítulo falaremos sobre isso em profundidade.
- Um _hash map_ permite associar um valor a uma chave específica. É um
implementação específica da estrutura de dados mais geral chamada _mapa_.

Para aprender sobre os outros tipos de coleções fornecidas pela biblioteca padrão,
veja [a documentação][collections].

Discutiremos como criar e atualizar vetores, strings e mapas hash, também
como o que torna cada um especial.

[collections]: ../std/collections/index.html
