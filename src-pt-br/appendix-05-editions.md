## Apêndice E: Edições

No Capítulo 1, você viu que `cargo new` adiciona alguns metadados ao seu
arquivo _Cargo.toml_ sobre uma edição. Este apêndice explica o que isso significa.

A linguagem e o compilador Rust têm um ciclo de lançamento de seis semanas, o que significa que os usuários obtêm
um fluxo constante de novos recursos. Outras linguagens de programação lançam mudanças
maiores com menos frequência; Rust lança atualizações menores com mais frequência. Depois de um
tempo, todas essas pequenas mudanças se acumulam. Mas, de lançamento em lançamento, pode ser
difícil olhar para trás e dizer: “Uau, entre Rust 1.10 e Rust 1.31, Rust
mudou muito!”

A cada três anos ou mais, a equipe Rust produz uma nova _edição_ do Rust. Cada
edição reúne os recursos que chegaram em um pacote claro, com
documentação e ferramentas totalmente atualizadas. Novas edições são lançadas como parte do
processo de lançamento de seis semanas.

As edições servem a propósitos diferentes para pessoas diferentes:

- Para usuários ativos do Rust, uma nova edição reúne alterações incrementais em
  um pacote fácil de entender.
- Para quem ainda não usa Rust, uma nova edição sinaliza que alguns avanços importantes foram
  alcançados, o que pode fazer com que Rust passe a valer uma olhada.
- Para quem está desenvolvendo Rust, uma nova edição fornece um ponto de encontro para o
  projeto como um todo.

No momento em que este texto foi escrito, quatro edições do Rust estavam disponíveis: Rust 2015, Rust
2018, Rust 2021 e Rust 2024. Este livro foi escrito usando as
convenções idiomáticas da edição Rust 2024.

A chave `edition` em _Cargo.toml_ indica qual edição o compilador deve
usar para o seu código. Se a chave não existir, Rust usa `2015` como edição
valor por motivos de compatibilidade com versões anteriores.

Cada projeto pode optar por uma edição diferente da edição padrão de 2015.
As edições podem conter alterações incompatíveis, como incluir uma nova palavra-chave que
entra em conflito com identificadores no código. No entanto, a menos que você opte por esses
alterações, seu código continuará a ser compilado mesmo quando você atualizar o Rust
versão do compilador que você usa.

Todas as versões do compilador Rust suportam qualquer edição que existia antes daquele
lançamento do compilador, e elas podem vincular crates de qualquer edição suportada
juntos. As alterações de edição afetam apenas a maneira como o compilador analisa inicialmente
o código. Portanto, se você estiver usando Rust 2015 e uma de suas dependências usar
Rust 2018, seu projeto será compilado e poderá usar essa dependência. O
a situação oposta, em que seu projeto usa Rust 2018 e uma dependência usa
Rust 2015 também funciona.

Para deixar claro: a maioria dos recursos estará disponível em todas as edições. Desenvolvedores usando
qualquer edição do Rust continuarão a ver melhorias à medida que novos lançamentos estáveis forem
feitos. Contudo, em alguns casos, principalmente quando novas palavras-chave são adicionadas, alguns novos
recursos podem estar disponíveis apenas em edições posteriores. Você precisará mudar
edições se você quiser aproveitar esses recursos.

Para obter mais detalhes, consulte o [_Guia de Edições do Rust_][edition-guide]. Esse é um
guia completo que enumera as diferenças entre as edições e explica como
atualizar automaticamente seu código para uma nova edição via `cargo fix`.

[edition-guide]: https://doc.rust-lang.org/stable/edition-guide
