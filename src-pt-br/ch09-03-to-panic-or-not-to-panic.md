## Para `panic!` ou não para `panic!`

Então, como você decide quando deve ligar para `panic!` e quando deve retornar
`Result`? Quando o código entra em pânico, não há como se recuperar. Você poderia ligar para `panic!`
para qualquer situação de erro, haja ou não uma forma possível de recuperação, mas
então você está tomando a decisão de que uma situação é irrecuperável em nome de
o código de chamada. Quando você escolhe retornar um valor `Result`, você fornece o
opções de código de chamada. O código de chamada pode optar por tentar a recuperação em um
maneira apropriada para sua situação, ou pode decidir que um `Err`
valor neste caso é irrecuperável, então ele pode chamar `panic!` e transformar seu
erro recuperável em um erro irrecuperável. Portanto, retornar `Result` é um
boa escolha padrão quando você está definindo uma função que pode falhar.

Em situações como exemplos, código de protótipo e testes, é mais
apropriado escrever código que entre em pânico em vez de retornar `Result`. Vamos
explore o porquê e depois discuta situações em que o compilador não consegue dizer isso
o fracasso é impossível, mas você, como humano, pode. O capítulo terminará com
algumas diretrizes gerais sobre como decidir se deve entrar em pânico no código da biblioteca.

### Exemplos, código de protótipo e testes

Quando você está escrevendo um exemplo para ilustrar algum conceito, incluindo também
um código robusto de tratamento de erros pode tornar o exemplo menos claro. Nos exemplos, é
entendi que uma chamada para um método como `unwrap` que poderia entrar em pânico é entendida como um
espaço reservado para a maneira como você deseja que seu aplicativo lide com erros, o que pode
diferem com base no que o resto do seu código está fazendo.

Da mesma forma, os métodos `unwrap` e `expect` são muito úteis quando você está
prototipagem e você ainda não está pronto para decidir como lidar com erros. Eles vão embora
limpe marcadores em seu código para quando você estiver pronto para tornar seu programa mais
robusto.

Se uma chamada de método falhar em um teste, você desejará que todo o teste falhe, mesmo que
esse método não é a funcionalidade em teste. Porque `panic!` é como um teste
está marcado como uma falha, chamar `unwrap` ou `expect` é exatamente o que deveria
acontecer.

<!-- Old headings. Do not remove or links may break. -->

<a id="cases-in-which-you-have-more-information-than-the-compiler"></a>

### Quando você tem mais informações que o compilador

Também seria apropriado chamar `expect` quando você tiver alguma outra lógica
isso garante que `Result` terá um valor `Ok`, mas a lógica não é
algo que o compilador entende. Você ainda terá um valor `Result` que você
precisa lidar: Qualquer operação que você esteja chamando ainda tem a possibilidade de
falhando em geral, mesmo que seja logicamente impossível em seu particular
situação. Se você puder garantir, inspecionando manualmente o código, que nunca
tiver uma variante `Err`, é perfeitamente aceitável chamar `expect` e documentar
a razão pela qual você acha que nunca terá uma variante `Err` no texto do argumento.
Aqui está um exemplo:

```rust
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-08-unwrap-that-cant-fail/src/main.rs:here}}
```

Estamos criando uma instância `IpAddr` analisando uma string codificada. Podemos ver
que `127.0.0.1` é um endereço IP válido, então é aceitável usar `expect`
aqui. No entanto, ter uma string válida e codificada não altera o tipo de retorno
do método `parse`: ainda obtemos um valor `Result` e o compilador irá
ainda nos faça lidar com `Result` como se a variante `Err` fosse uma possibilidade
porque o compilador não é inteligente o suficiente para ver que esta string é sempre um
endereço IP válido. Se a string do endereço IP veio de um usuário em vez de ser
codificado no programa e, portanto, _tinha_ uma possibilidade de falha,
definitivamente gostaríamos de lidar com `Result` de uma forma mais robusta.
Mencionar a suposição de que este endereço IP está codificado nos levará a
altere `expect` para um melhor código de tratamento de erros se, no futuro, precisarmos obter
o endereço IP de alguma outra fonte.

### Diretrizes para tratamento de erros

É aconselhável deixar seu código em pânico quando for possível que ele possa
acabar em um estado ruim. Neste contexto, um _estado ruim_ é quando alguma suposição,
garantia, contrato ou invariante foi quebrado, como quando valores inválidos,
valores contraditórios ou valores ausentes são passados ​​para o seu código - mais um ou
mais do seguinte:

- O mau estado é algo inesperado, em oposição a algo que
provavelmente acontecerá ocasionalmente, como um usuário inserindo dados de forma errada
formatar.
- Seu código após este ponto precisa confiar em não estar neste estado ruim,
em vez de verificar o problema em cada etapa.
- Não há uma boa maneira de codificar essas informações nos tipos que você usa. Bem
trabalharemos com um exemplo do que queremos dizer em [“Encoding States and Behavior as
Tipos”][encoding]<!-- ignore --> no Capítulo 18.

Se alguém chamar seu código e passar valores que não fazem sentido, é
é melhor retornar um erro, se possível, para que o usuário da biblioteca possa decidir
o que eles querem fazer nesse caso. Contudo, nos casos em que a continuação possa ser
inseguro ou prejudicial, a melhor escolha pode ser ligar para `panic!` e alertar o
pessoa que usa sua biblioteca para o bug em seu código para que possa corrigi-lo
durante o desenvolvimento. Da mesma forma, `panic!` geralmente é apropriado se você estiver ligando
código externo que está fora de seu controle e retorna um estado inválido que você
não tem como consertar.

No entanto, quando a falha é esperada, é mais apropriado retornar um `Result`
do que fazer uma chamada `panic!`. Os exemplos incluem um analisador sendo malformado
dados ou uma solicitação HTTP retornando um status que indica que você atingiu uma taxa
limite. Nestes casos, retornar `Result` indica que a falha é um
possibilidade esperada de que o código de chamada deva decidir como lidar.

Quando seu código executa uma operação que pode colocar um usuário em risco se for
chamado usando valores inválidos, seu código deve primeiro verificar se os valores são válidos
e entre em pânico se os valores não forem válidos. Isso ocorre principalmente por razões de segurança:
A tentativa de operar com dados inválidos pode expor seu código a vulnerabilidades.
Esta é a principal razão pela qual a biblioteca padrão chamará `panic!` se você tentar
um acesso à memória fora dos limites: Tentando acessar a memória que não pertence a
a estrutura de dados atual é um problema de segurança comum. As funções geralmente têm
_contratos_: Seu comportamento só é garantido se os insumos atenderem
requisitos. Entrar em pânico quando o contrato é violado faz sentido porque um
violação de contrato sempre indica um bug do lado do chamador e não é um tipo de
erro que você deseja que o código de chamada manipule explicitamente. Na verdade, há
nenhuma maneira razoável de chamar o código para recuperação; a chamada que os _programadores_ precisam
para corrigir o código. Contratos para uma função, especialmente quando uma violação ocorrerá
causar pânico, deve ser explicado na documentação da API da função.

No entanto, ter muitas verificações de erros em todas as suas funções seria detalhado
e irritante. Felizmente, você pode usar o sistema de tipos do Rust (e, portanto, o tipo
verificação feita pelo compilador) para fazer muitas das verificações para você. Se o seu
função tem um tipo específico como parâmetro, você pode prosseguir com o seu código
lógica sabendo que o compilador já garantiu que você tem um código válido
valor. Por exemplo, se você tiver um tipo em vez de `Option`, seu programa
espera ter _algo_ em vez de _nada_. Seu código então não tem
para lidar com dois casos para as variantes `Some` e `None`: terá apenas um
caso para definitivamente ter um valor. Código tentando passar nada para o seu
a função nem mesmo compila, então sua função não precisa verificar isso
caso em tempo de execução. Outro exemplo é usar um tipo inteiro sem sinal, como
`u32`, o que garante que o parâmetro nunca seja negativo.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-custom-types-for-validation"></a>

### Tipos personalizados para validação

Vamos aproveitar a ideia de usar o sistema de tipos do Rust para garantir que tenhamos um valor válido
valorize um passo adiante e veja como criar um tipo personalizado para validação.
Lembre-se do jogo de adivinhação do Capítulo 2, no qual nosso código pedia ao usuário que adivinhasse
um número entre 1 e 100. Nunca validamos se a estimativa do usuário era
entre esses números antes de compará-los com nosso número secreto; nós apenas
validou que o palpite era positivo. Neste caso, as consequências não foram
muito terrível: nossa saída de “Muito alto” ou “Muito baixo” ainda estaria correta. Mas isso
seria um aprimoramento útil para orientar o usuário em direção a suposições válidas e ter
comportamento diferente quando o usuário adivinha um número que está fora do intervalo versus
quando o usuário digita, por exemplo, letras.

Uma maneira de fazer isso seria analisar a estimativa como `i32` em vez de apenas como
`u32` para permitir números potencialmente negativos e, em seguida, adicione uma verificação para o
número estando dentro do intervalo, assim:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-09-guess-out-of-range/src/main.rs:here}}
```

</Listing>

A expressão `if` verifica se nosso valor está fora do intervalo e informa ao usuário
sobre o problema e chama `continue` para iniciar a próxima iteração do loop
e peça outro palpite. Após a expressão `if`, podemos prosseguir com o
comparações entre `guess` e o número secreto sabendo que `guess` é
entre 1 e 100.

Contudo, esta não é uma solução ideal: se fosse absolutamente crítico que o
o programa operava apenas com valores entre 1 e 100 e tinha muitas funções
com este requisito, ter uma verificação como esta em todas as funções seria
tedioso (e pode afetar o desempenho).

Em vez disso, podemos criar um novo tipo em um módulo dedicado e colocar as validações
em uma função para criar uma instância do tipo em vez de repetir o
validações em todos os lugares. Dessa forma, é seguro para as funções usarem o novo tipo
em suas assinaturas e usam com confiança os valores que recebem. Listagem 9-13
mostra uma maneira de definir um tipo `Guess` que criará apenas uma instância de
`Guess` se a função `new` receber um valor entre 1 e 100.

<Listing number="9-13" caption="A `Guess` type that will only continue with values between 1 and 100" file-name="src/guessing_game.rs">

```rust
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-13/src/guessing_game.rs}}
```

</Listing>

Observe que este código em *src/guessing_game.rs* depende da adição de um módulo
declaração `mod guessing_game;` em *src/lib.rs* que não mostramos aqui.
Dentro do arquivo deste novo módulo, definimos uma estrutura chamada `Guess` que possui um
campo chamado `value` que contém `i32`. É aqui que o número estará
armazenado.

Então, implementamos uma função associada chamada `new` em `Guess` que cria
instâncias de valores `Guess`. A função `new` é definida para ter um
parâmetro chamado `value` do tipo `i32` e para retornar um `Guess`. O código no
o corpo da função `new` testa `value` para garantir que está entre 1 e 100.
Se `value` não passar neste teste, fazemos uma chamada `panic!`, que alertará
o programador que está escrevendo o código de chamada que tem um bug que precisa
corrigir, porque criar um `Guess` com um `value` fora deste intervalo seria
violar o contrato no qual `Guess::new` está confiando. As condições em que
`Guess::new` pode entrar em pânico deve ser discutido em sua API voltada ao público
documentação; abordaremos convenções de documentação indicando a possibilidade
de um `panic!` na documentação da API que você cria no Capítulo 14. Se
`value` passa no teste, criamos um novo `Guess` com seu campo `value` definido
para o parâmetro `value` e retorne `Guess`.

A seguir, implementamos um método chamado `value` que pega emprestado `self`, não possui nenhum
outros parâmetros e retorna um `i32`. Este tipo de método às vezes é chamado
um _getter_ porque seu objetivo é obter alguns dados de seus campos e retornar
isto. Este método público é necessário porque o campo `value` do `Guess`
struct é privado. É importante que o campo `value` seja privado para que
código usando a estrutura `Guess` não tem permissão para definir `value` diretamente: Código
fora do módulo `guessing_game` _deve_ usar a função `Guess::new` para
crie uma instância de `Guess`, garantindo assim que não há como
`Guess` para ter um `value` que não foi verificado pelas condições do
`Guess::new` função.

Uma função que possui um parâmetro ou retorna apenas números entre 1 e 100 poderia
em seguida, declare em sua assinatura que recebe ou retorna um `Guess` em vez de um
`i32` e não precisaria fazer nenhuma verificação adicional em seu corpo.

## Resumo

Os recursos de tratamento de erros do Rust foram projetados para ajudá-lo a escrever um código mais robusto.
A macro `panic!` sinaliza que seu programa está em um estado que não pode ser controlado e
permite que você diga ao processo para parar em vez de tentar prosseguir com dados inválidos ou
valores incorretos. O `Result` enum usa o sistema de tipos do Rust para indicar que
as operações podem falhar de uma forma que seu código possa se recuperar. Você pode usar
`Result` para informar ao código que chama seu código que ele precisa para lidar com potenciais
sucesso ou fracasso também. Usando `panic!` e `Result` no apropriado
situações tornarão seu código mais confiável diante de problemas inevitáveis.

Agora que você viu maneiras úteis de a biblioteca padrão usar genéricos com
os enums `Option` e `Result`, falaremos sobre como os genéricos funcionam e como você
pode usá-los em seu código.

[encoding]: ch18-03-oo-design-patterns.html#encoding-states-and-behavior-as-types
