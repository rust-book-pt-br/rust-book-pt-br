## Apêndice E: Edições

No Capítulo 1, você viu que `cargo new` adiciona um pouco de metadado ao
arquivo _Cargo.toml_ sobre uma edição. Este apêndice explica o que isso quer
dizer!

A linguagem e o compilador Rust têm um ciclo de lançamento de seis semanas, o
que significa que as pessoas usuárias recebem um fluxo constante de novos
recursos. Outras linguagens de programação lançam mudanças maiores com menos
frequência; Rust prefere atualizações menores em intervalos mais curtos. Com o
tempo, todas essas pequenas mudanças se acumulam. Mas, de uma versão para
outra, pode ser difícil olhar para trás e dizer: “Nossa, entre Rust 1.10 e
Rust 1.31, Rust mudou bastante!”

A cada três anos mais ou menos, a equipe do Rust produz uma nova _edição_ do
Rust. Cada edição reúne os recursos já lançados em um pacote claro, com
documentação e ferramentas totalmente atualizadas. As novas edições chegam
como parte do processo normal de lançamento a cada seis semanas.

As edições servem a propósitos diferentes para pessoas diferentes:

- Para quem usa Rust ativamente, uma nova edição reúne mudanças incrementais
  em um pacote fácil de entender.
- Para quem ainda não usa Rust, uma nova edição sinaliza que avanços
  importantes aconteceram, o que pode fazer a linguagem valer uma nova chance.
- Para quem desenvolve o próprio Rust, uma nova edição oferece um ponto de
  convergência para o projeto como um todo.

No momento em que este texto foi escrito, há quatro edições do Rust
disponíveis: Rust 2015, Rust 2018, Rust 2021 e Rust 2024. Este livro foi
escrito usando os idioms da edição Rust 2024.

A chave `edition` no arquivo _Cargo.toml_ indica qual edição o compilador deve
usar para o seu código. Se essa chave não existir, Rust usa `2015` como valor
da edição por razões de compatibilidade retroativa.

Cada projeto pode optar por usar uma edição diferente da edição padrão de
2015. Edições podem conter mudanças incompatíveis, como a introdução de uma
nova palavra-chave que conflita com identificadores no código. Ainda assim, a
menos que você opte por essas mudanças, seu código continuará compilando mesmo
que você atualize a versão do compilador Rust que utiliza.

Todas as versões do compilador Rust oferecem suporte a qualquer edição que
existia antes do lançamento daquele compilador, e elas podem ligar entre si
crates de qualquer edição suportada. As mudanças de edição afetam apenas a
forma como o compilador faz o parsing inicial do código. Portanto, se você
estiver usando Rust 2015 e uma de suas dependências usar Rust 2018, seu
projeto compilará e poderá usar essa dependência. A situação inversa, em que o
seu projeto usa Rust 2018 e uma dependência usa Rust 2015, também funciona.

Para deixar claro: a maior parte dos recursos estará disponível em todas as
edições. Pessoas desenvolvedoras usando qualquer edição do Rust continuarão a
receber melhorias à medida que novas versões estáveis forem lançadas. No
entanto, em alguns casos, principalmente quando novas palavras-chave são
adicionadas, alguns recursos novos podem ficar disponíveis apenas em edições
mais recentes. Você precisará mudar de edição se quiser aproveitar esse tipo
de recurso.

Para mais detalhes, veja [_The Rust Edition Guide_][edition-guide]. Trata-se
de um livro completo que enumera as diferenças entre as edições e explica como
atualizar seu código automaticamente para uma nova edição via `cargo fix`.

[edition-guide]: https://doc.rust-lang.org/stable/edition-guide
