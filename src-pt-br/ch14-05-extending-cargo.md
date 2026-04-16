## Estendendo Cargo com Comandos Personalizados

O Cargo foi projetado para que você possa estendê-lo com novos subcomandos sem
precisar modificá-lo. Se um binário no seu `$PATH` se chamar
`cargo-something`, você pode executá-lo como se fosse um subcomando do Cargo,
rodando `cargo something`. Comandos personalizados como esse também aparecem
quando você executa `cargo --list`. A possibilidade de usar `cargo install`
para instalar extensões e depois executá-las como se fossem ferramentas
nativas do Cargo é um benefício muito conveniente do design do Cargo!

## Resumo

Compartilhar código com Cargo e [crates.io](https://crates.io/)<!-- ignore -->
faz parte do que torna o ecossistema Rust útil para muitas tarefas diferentes.
A biblioteca padrão do Rust é pequena e estável, mas crates são fáceis de
compartilhar, usar e melhorar em um ritmo diferente do da linguagem. Não tenha
receio de compartilhar em [crates.io](https://crates.io/)<!-- ignore
--> código
que seja útil para você; é bem provável que também seja útil para outra pessoa!
