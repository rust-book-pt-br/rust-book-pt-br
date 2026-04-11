## Controle de Fluxo Conciso com `if let` e `let...else`

A sintaxe `if let` permite combinar `if` e `let` em uma forma menos verbosa de
tratar valores que casam com um padrão enquanto ignora os demais. Considere o
programa da Listagem 6-6, que faz `match` em um valor `Option<u8>` na variável
`config_max`, mas só quer executar código se o valor for a variante `Some`.

```rust
let config_max = Some(3u8);
match config_max {
    Some(max) => println!("O máximo configurado é {max}"),
    _ => (),
}
```

<span class="caption">Listagem 6-6: Um `match` que só se importa em executar
código quando o valor é `Some`</span>

Se o valor for `Some`, imprimimos o valor contido nessa variante associando-o à
variável `max` no padrão. Não queremos fazer nada com o valor `None`. Para
satisfazer a expressão `match`, temos de adicionar `_ => ()` depois de tratar
apenas uma variante, o que acaba sendo um código repetitivo incômodo.

Em vez disso, poderíamos escrever isso de forma mais curta com `if let`. O
código a seguir se comporta da mesma maneira que o `match` da Listagem 6-6:

```rust
# let config_max = Some(3u8);
if let Some(max) = config_max {
    println!("O máximo configurado é {max}");
}
```

A sintaxe `if let` recebe um padrão e uma expressão separados por um sinal de
igual. Ela funciona da mesma forma que um `match`: a expressão seria fornecida
ao `match`, e o padrão seria o primeiro braço. Neste caso, o padrão é
`Some(max)`, e `max` fica associado ao valor dentro de `Some`. Em seguida,
podemos usar `max` no corpo do bloco `if let`, do mesmo modo que faríamos no
braço correspondente do `match`. O código dentro do `if let` só é executado se
o valor casar com o padrão.

Usar `if let` significa menos digitação, menos indentação e menos código
repetitivo.
Em compensação, você perde a verificação exaustiva garantida por `match`, que
assegura que nenhum caso foi esquecido. Escolher entre `match` e `if let`
depende do que você está fazendo em uma situação específica e se ganhar
concisão é uma troca aceitável pela perda dessa verificação exaustiva.

Em outras palavras, você pode pensar em `if let` como um atalho sintático para
um
`match` que executa código quando o valor casa com um único padrão e ignora
todos os demais.

Também podemos incluir um `else` em um `if let`. O bloco de código do `else` é
o mesmo bloco que iria no caso `_` da expressão `match` equivalente. Lembre-se
da definição da enum `Moeda` na Listagem 6-4, em que a variante `Quarter`
também armazenava um valor `Estado`. Se quiséssemos contar todas as moedas que
não fossem _quarters_, ao mesmo tempo em que anunciamos o estado dos
_quarters_, poderíamos fazer isso com uma expressão `match`, assim:

```rust
# #[derive(Debug)]
# enum Estado {
#    Alabama,
#    Alaska,
# }
#
# enum Moeda {
#    Penny,
#    Nickel,
#    Dime,
#    Quarter(Estado),
# }
# let moeda = Moeda::Penny;
let mut contagem = 0;
match moeda {
    Moeda::Quarter(estado) => println!("Quarter do estado {:?}!", estado),
    _ => contagem += 1,
}
```

Ou poderíamos usar `if let` com `else`, desta forma:

```rust
# #[derive(Debug)]
# enum Estado {
#    Alabama,
#    Alaska,
# }
#
# enum Moeda {
#    Penny,
#    Nickel,
#    Dime,
#    Quarter(Estado),
# }
# let moeda = Moeda::Penny;
let mut contagem = 0;
if let Moeda::Quarter(estado) = moeda {
    println!("Quarter do estado {:?}!", estado);
} else {
    contagem += 1;
}
```

## Permanecendo no "Caminho Feliz" com `let...else`

Um padrão comum é realizar algum cálculo quando um valor está presente e, caso
contrário, retornar um valor padrão. Continuando com nosso exemplo das moedas
com um valor `Estado`, se quiséssemos dizer algo engraçado dependendo de quão
antigo o estado do _quarter_ é, poderíamos introduzir um método em `Estado`
para verificar a idade do estado, assim:

```rust
#[derive(Debug)] // Para podermos inspecionar o estado em instantes
enum Estado {
    Alabama,
    Alaska,
    // --snip--
}

impl Estado {
    fn existia_em(&self, ano: u16) -> bool {
        match self {
            Estado::Alabama => ano >= 1819,
            Estado::Alaska => ano >= 1959,
            // -- snip --
        }
    }
}
```

Então poderíamos usar `if let` para fazer `match` no tipo de moeda,
introduzindo uma variável `estado` dentro do corpo da condição, como na
Listagem 6-7:

```rust
# #[derive(Debug)]
# enum Estado {
#     Alabama,
#     Alaska,
# }
#
# impl Estado {
#     fn existia_em(&self, ano: u16) -> bool {
#         match self {
#             Estado::Alabama => ano >= 1819,
#             Estado::Alaska => ano >= 1959,
#         }
#     }
# }
#
# enum Moeda {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter(Estado),
# }
#
fn descrever_quarter_do_estado(moeda: Moeda) -> Option<String> {
    if let Moeda::Quarter(estado) = moeda {
        if estado.existia_em(1900) {
            Some(format!("{estado:?} é bem antigo para os EUA!"))
        } else {
            Some(format!("{estado:?} é relativamente novo."))
        }
    } else {
        None
    }
}
```

<span class="caption">Listagem 6-7: Verificando se um estado existia em 1900
usando condicionais aninhadas em um `if let`</span>

Isso resolve o problema, mas desloca o trabalho para dentro do corpo do `if
let`, e, se o código a ser executado ficar mais complexo, pode ser difícil
acompanhar exatamente como os ramos de nível superior se relacionam. Também
podemos aproveitar o fato de que expressões produzem um valor, seja para obter
o `estado` a partir do `if let`, seja para retornar mais cedo, como na
Listagem 6-8. Você também poderia fazer algo parecido com `match`.

```rust
# #[derive(Debug)]
# enum Estado {
#     Alabama,
#     Alaska,
# }
#
# impl Estado {
#     fn existia_em(&self, ano: u16) -> bool {
#         match self {
#             Estado::Alabama => ano >= 1819,
#             Estado::Alaska => ano >= 1959,
#         }
#     }
# }
#
# enum Moeda {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter(Estado),
# }
#
fn descrever_quarter_do_estado(moeda: Moeda) -> Option<String> {
    let estado = if let Moeda::Quarter(estado) = moeda {
        estado
    } else {
        return None;
    };

    if estado.existia_em(1900) {
        Some(format!("{estado:?} é bem antigo para os EUA!"))
    } else {
        Some(format!("{estado:?} é relativamente novo."))
    }
}
```

<span class="caption">Listagem 6-8: Usando `if let` para produzir um valor ou
retornar cedo</span>

Essa versão também é um pouco incômoda de acompanhar. Um dos ramos do `if let`
produz um valor, e o outro retorna da função por completo.

Para tornar esse padrão comum mais agradável de expressar, Rust tem
`let...else`. A sintaxe `let...else` recebe um padrão no lado esquerdo e uma
expressão no lado direito, de forma muito parecida com `if let`, mas não tem
um ramo `if`, apenas um ramo `else`. Se o padrão casar, o valor do padrão será
associado no escopo externo. Se o padrão *não* casar, o fluxo do programa
seguirá para o braço `else`, que precisa retornar da função.

Na Listagem 6-9, você pode ver como a Listagem 6-8 fica ao usar `let...else`
no lugar de `if let`:

```rust
# #[derive(Debug)]
# enum Estado {
#     Alabama,
#     Alaska,
# }
#
# impl Estado {
#     fn existia_em(&self, ano: u16) -> bool {
#         match self {
#             Estado::Alabama => ano >= 1819,
#             Estado::Alaska => ano >= 1959,
#         }
#     }
# }
#
# enum Moeda {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter(Estado),
# }
#
fn descrever_quarter_do_estado(moeda: Moeda) -> Option<String> {
    let Moeda::Quarter(estado) = moeda else {
        return None;
    };

    if estado.existia_em(1900) {
        Some(format!("{estado:?} é bem antigo para os EUA!"))
    } else {
        Some(format!("{estado:?} é relativamente novo."))
    }
}
```

<span class="caption">Listagem 6-9: Usando `let...else` para deixar mais claro
o fluxo da função</span>

Repare que, dessa forma, o corpo principal da função permanece no "caminho
feliz", sem que dois ramos tenham fluxos de controle muito diferentes, como
acontecia no `if let`.

Se você estiver em uma situação em que a lógica do programa fica verbosa demais
para ser expressa com `match`, lembre-se de que `if let` e `let...else` também
fazem parte da sua caixa de ferramentas em Rust.

## Resumo

Agora já vimos como usar enums para criar tipos customizados que podem assumir
um dentre vários valores enumerados. Mostramos como o tipo `Option<T>`, da
biblioteca padrão, ajuda você a usar o sistema de tipos para evitar erros.
Quando valores de enums contêm dados, você pode usar `match` ou `if let` para
extrair e usar esses valores, dependendo de quantos casos precisa tratar.

Seus programas em Rust agora podem expressar conceitos do seu domínio usando
structs e enums. Criar tipos customizados para a sua API garante segurança de
tipos: o compilador vai assegurar que suas funções recebam apenas valores do
tipo esperado por cada uma delas.

Para fornecer aos seus usuários uma API bem organizada, simples de usar e que
exponha apenas o que eles realmente precisam, vamos agora voltar nossa atenção
para os módulos em Rust.
