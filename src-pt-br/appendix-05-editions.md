## Apêndice E: Edições

No Capítulo 1, você viu que `cargo new` adiciona um pouco de metadados ao seu
Arquivo _Cargo.toml_ sobre uma edição. Este apêndice fala sobre o que isso significa!

A linguagem e o compilador Rust têm um ciclo de lançamento de seis semanas, o que significa que os usuários obtêm
um stream constante de novos recursos. Outras linguagens de programação lançam maiores
muda com menos frequência; Rust lança atualizações menores com mais frequência. Depois de um
enquanto todas essas pequenas mudanças se somam. Mas de lançamento em lançamento, pode ser
difícil olhar para trás e dizer: “Uau, entre Rust 1.10 e Rust 1.31, Rust tem
mudou muito!”

A cada três anos ou mais, a equipe Rust produz uma nova _edição_ do Rust. Cada
edição reúne os recursos que chegaram em um pacote claro com
documentação e ferramentas totalmente atualizadas. Novas edições são enviadas como parte do costume
processo de lançamento de seis semanas.

As edições servem a propósitos diferentes para pessoas diferentes:

- Para usuários ativos do Rust, uma nova edição reúne alterações incrementais em
  um pacote fácil de entender.
- Para não usuários, uma nova edição sinaliza que alguns avanços importantes foram
  pousou, o que pode fazer com que Rust valha a pena dar uma olhada.
- Para aqueles que estão desenvolvendo o Rust, uma nova edição fornece um ponto de encontro para o
  projeto como um todo.

No momento em que este artigo foi escrito, quatro edições do Rust estavam disponíveis: Rust 2015, Rust
2018, Rust 2021 e Rust 2024. Este livro foi escrito usando a edição Rust 2024
expressões idiomáticas.

A chave `edition` em _Cargo.toml_ indica qual edição o compilador deve
use para o seu código. Se a chave não existir, Rust usa `2015` como edição
valor por motivos de compatibilidade com versões anteriores.

Cada projeto pode optar por uma edição diferente da edição padrão de 2015.
As edições podem conter alterações incompatíveis, como incluir uma nova palavra-chave que
entra em conflito com identificadores no código. No entanto, a menos que você opte por esses
alterações, seu código continuará a ser compilado mesmo quando você atualizar o Rust
versão do compilador que você usa.

Todas as versões do compilador Rust suportam qualquer edição que existia antes dessa
lançamento do compilador, e eles podem vincular crates de qualquer edição suportada
juntos. As alterações de edição afetam apenas a maneira como o compilador analisa inicialmente
código. Portanto, se você estiver usando Rust 2015 e uma de suas dependências usar
Rust 2018, seu projeto será compilado e poderá usar essa dependência. O
situação oposta, onde seu projeto usa Rust 2018 e uma dependência usa
Rust 2015 também funciona.

Para ser claro: a maioria dos recursos estará disponível em todas as edições. Desenvolvedores usando
qualquer edição Rust continuará a ver melhorias à medida que novos lançamentos estáveis são
feito. Contudo, em alguns casos, principalmente quando novas palavras-chave são adicionadas, algumas novas
os recursos podem estar disponíveis apenas em edições posteriores. Você precisará mudar
edições se você quiser aproveitar esses recursos.

Para obter mais detalhes, consulte [_Guia da edição Rust_][edition-guide]. Este é um
livro completo que enumera as diferenças entre as edições e explica como
para atualizar automaticamente seu código para uma nova edição via `cargo fix`.

[edition-guide]: https://doc.rust-lang.org/stable/edition-guide
