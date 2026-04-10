## Estendendo Cargo com comandos personalizados

Cargo foi projetado para que você possa estendê-lo com novos subcomandos sem precisar
para modificá-lo. Se um binário em seu `$PATH` for denominado `cargo-something`, você pode
execute-o como se fosse um subcomando Cargo executando ` cargo something`. Personalizado
comandos como este também são listados quando você executa ` cargo --list`. Ser capaz de
use ` cargo install`para instalar extensões e, em seguida, execute-as como o
as ferramentas Cargo integradas são um benefício superconveniente do design do Cargo!

## Resumo

Compartilhar código com Cargo e [crates.io](https://crates.io/)<!-- ignore --> é
parte do que torna o ecossistema Rust útil para muitas tarefas diferentes. Rust's
A biblioteca padrão é pequena e estável, mas crates é fácil de compartilhar, usar e
melhorar em um cronograma diferente daquele do idioma. Não tenha vergonha
compartilhar código útil para você em [crates.io](https://crates.io/)<!-- ignore
-->; é provável que também seja útil para outra pessoa!
