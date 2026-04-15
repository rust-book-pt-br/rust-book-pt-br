## Para `panic!` ou não para `panic!`

Então, como decidir quando você deve chamar `panic!` e quando deve retornar
`Result`? Quando o código entra em panic, não há como se recuperar. Você até
poderia chamar `panic!` para qualquer situação de erro, exista ou não uma forma
possível de recuperação, mas aí estaria tomando a decisão de que uma situação é
irrecuperável em nome do código chamador. Quando você escolhe retornar um valor
`Result`, oferece opções ao código chamador. O código chamador pode optar por
tentar se recuperar de uma maneira adequada ao seu contexto ou decidir que um
valor `Err`, naquele caso, é irrecuperável e então chamar `panic!`,
transformando o erro recuperável em irrecuperável. Por isso, retornar `Result`
costuma ser a melhor escolha padrão ao definir uma função que pode falhar.

Em situações como exemplos, código de protótipo e testes, é mais apropriado
escrever código que entra em panic em vez de retornar `Result`. Vamos explorar
o porquê e, depois, discutir situações em que o compilador não consegue saber
que uma falha é impossível, mas você, como humano, consegue. O capítulo termina
com algumas diretrizes gerais sobre como decidir se deve entrar em panic em
código de biblioteca.

### Exemplos, Código de Protótipo e Testes

Quando você está escrevendo um exemplo para ilustrar algum conceito, incluir
também um código robusto de tratamento de erros pode tornar o exemplo menos
claro. Em exemplos, entende-se que uma chamada a um método como `unwrap`, que
pode entrar em panic, serve como marcador do modo como sua aplicação deverá
tratar erros, o que pode variar de acordo com o restante do código.

Da mesma forma, os métodos `unwrap` e `expect` são muito úteis quando você está
prototipando e ainda não está pronto para decidir como tratar erros. Eles
deixam marcadores claros no código para o momento em que você estiver pronto
para tornar o programa mais robusto.

Se uma chamada de método falhar em um teste, você vai querer que o teste inteiro
falhe, mesmo que aquele método não seja a funcionalidade que está sendo
testada. Como `panic!` é a forma de um teste ser marcado como falho, chamar
`unwrap` ou `expect` é exatamente o comportamento desejado.

<!-- Old headings. Do not remove or links may break. -->

<a id="cases-in-which-you-have-more-information-than-the-compiler"></a>

### Quando Você Tem Mais Informações que o Compilador

Também pode ser apropriado chamar `expect` quando você tiver alguma outra lógica
que garanta que o `Result` terá um valor `Ok`, mas essa lógica não seja algo
que o compilador consiga entender. Você ainda terá um valor `Result` que
precisa tratar: a operação que você está chamando ainda tem a possibilidade de
falhar em termos gerais, mesmo que isso seja logicamente impossível no seu caso
específico. Se você puder garantir, inspecionando o código manualmente, que
nunca terá uma variante `Err`, é perfeitamente aceitável chamar `expect` e
documentar, no texto do argumento, por que você acredita que nunca haverá uma
variante `Err`. Veja um exemplo:

```rust
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-08-unwrap-that-cant-fail/src/main.rs:here}}
```

Estamos criando uma instância de `IpAddr` fazendo o parse de uma string fixa no
código. Podemos ver que `127.0.0.1` é um endereço IP válido, então é
aceitável usar `expect` aqui. No entanto, ter uma string válida e hardcoded não
altera o tipo de retorno do método `parse`: continuamos recebendo um valor
`Result`, e o compilador continua exigindo que o tratemos como se a variante
`Err` fosse uma possibilidade, porque ele não é inteligente o bastante para
perceber que essa string é sempre um endereço IP válido. Se a string do
endereço IP viesse de uma pessoa usuária em vez de estar hardcoded no programa
e, portanto, _pudesse_ falhar, com certeza quereríamos tratar o `Result` de
forma mais robusta. Mencionar a suposição de que esse endereço IP está fixo no
código nos lembrará de substituir `expect` por um tratamento de erro melhor se,
no futuro, precisarmos obter o endereço IP de outra fonte.

### Diretrizes para Tratamento de Erros

É recomendável que seu código entre em panic quando houver a possibilidade de
ele acabar em um estado ruim. Nesse contexto, um _estado ruim_ é quando alguma
suposição, garantia, contrato ou invariante foi quebrado, como quando valores
inválidos, contraditórios ou ausentes são passados para o seu código, somado a
uma ou mais das condições a seguir:

- O estado ruim é algo inesperado, em oposição a algo que provavelmente
  acontecerá de vez em quando, como uma pessoa usuária digitando dados no
  formato errado.
- O seu código, depois desse ponto, precisa confiar no fato de _não_ estar
  nesse estado ruim, em vez de checar o problema a cada etapa.
- Não existe uma boa forma de codificar essa informação nos tipos que você usa.
  Veremos um exemplo do que isso significa em [“Encoding States and Behavior as
  Types”][encoding]<!-- ignore --> no Capítulo 18.

Se alguém chamar seu código e passar valores que não fazem sentido, o melhor é
retornar um erro, se possível, para que a pessoa usuária da biblioteca possa
decidir o que deseja fazer naquele caso. No entanto, quando continuar possa ser
inseguro ou prejudicial, a melhor escolha pode ser chamar `panic!` e alertar
quem estiver usando sua biblioteca de que há um bug no código chamador, para
que ele possa ser corrigido durante o desenvolvimento. Do mesmo modo, `panic!`
costuma ser apropriado quando você chama código externo, fora do seu controle,
e ele retorna um estado inválido que você não tem como corrigir.

No entanto, quando a falha é esperada, é mais apropriado retornar um `Result`
do que chamar `panic!`. Exemplos disso incluem um parser recebendo dados mal
formados ou uma requisição HTTP retornando um status que indique que você
atingiu um limite de taxa. Nesses casos, retornar `Result` indica que a falha
é uma possibilidade esperada e que o código chamador precisa decidir como
tratá-la.

Quando seu código executa uma operação que pode colocar uma pessoa usuária em
risco se for chamada com valores inválidos, ele deve primeiro verificar se os
valores são válidos e entrar em panic se não forem. Isso acontece
principalmente por razões de segurança: tentar operar com dados inválidos pode
expor o código a vulnerabilidades. Essa é a principal razão pela qual a
biblioteca padrão chama `panic!` se você tentar acessar memória fora dos
limites: tentar acessar memória que não pertence à estrutura de dados atual é
um problema de segurança comum. Funções frequentemente têm _contratos_: seu
comportamento só é garantido se as entradas atenderem a determinados
requisitos. Entrar em panic quando o contrato é violado faz sentido porque uma
violação de contrato sempre indica um bug do lado do chamador, e não é um tipo
de erro que você queira que o código chamador tenha de tratar explicitamente.
Na prática, não existe uma forma razoável de o código chamador se recuperar; os
_programadores_ que o escrevem é que precisam corrigir o código. Contratos de
uma função, especialmente quando sua violação causar um panic, devem ser
explicados na documentação da API dessa função.

No entanto, ter muitas verificações de erro em todas as funções seria verboso e
cansativo. Felizmente, você pode usar o sistema de tipos do Rust, e portanto a
verificação de tipos feita pelo compilador, para que muitas dessas checagens
sejam feitas por você. Se a sua função recebe um tipo específico como
parâmetro, você pode seguir com a lógica do código sabendo que o compilador já
garantiu a validade desse valor. Por exemplo, se você tem um tipo em vez de um
`Option`, o programa espera ter _alguma coisa_ em vez de _nada_. Assim, o seu
código não precisa tratar dois casos, `Some` e `None`: ele só terá o caso em
que há definitivamente um valor. Código que tente passar “nada” para a sua
função simplesmente nem compilará, então a sua função não precisa verificar
esse caso em tempo de execução. Outro exemplo é usar um tipo inteiro sem sinal,
como `u32`, o que garante que o parâmetro nunca seja negativo.

<!-- Old headings. Do not remove or links may break. -->

<a id="creating-custom-types-for-validation"></a>

### Tipos Personalizados para Validação

Vamos levar um passo adiante a ideia de usar o sistema de tipos do Rust para
garantir que temos um valor válido e ver como criar um tipo personalizado para
validação. Lembre-se do jogo de adivinhação do Capítulo 2, no qual nosso código
pedia que a pessoa usuária adivinhasse um número entre 1 e 100. Nunca
validamos se o palpite da pessoa usuária estava entre esses números antes de
compará-lo com o número secreto; apenas validamos que o palpite era positivo.
Nesse caso, as consequências não eram tão graves: a saída “Muito alto” ou
“Muito baixo” ainda estaria correta. Mas seria uma melhoria útil orientar a
pessoa usuária para palpites válidos e ter um comportamento diferente quando o
palpite estiver fora do intervalo, em vez de quando a pessoa digitar, por
exemplo, letras.

Uma maneira de fazer isso seria converter o palpite para `i32` em vez de apenas
`u32`, para permitir números potencialmente negativos, e então adicionar uma
checagem para ver se o número está no intervalo, assim:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-09-guess-out-of-range/src/main.rs:here}}
```

</Listing>

A expressão `if` verifica se o valor está fora do intervalo, informa a pessoa
usuária sobre o problema e chama `continue` para iniciar a próxima iteração do
loop e pedir outro palpite. Depois da expressão `if`, podemos seguir com as
comparações entre `guess` e o número secreto sabendo que `guess` está entre 1
e 100.

No entanto, essa não é uma solução ideal: se fosse absolutamente crítico que o
programa operasse apenas com valores entre 1 e 100 e tivesse muitas funções com
esse requisito, repetir uma checagem como essa em todas elas seria tedioso, e
talvez até afetasse o desempenho.

Em vez disso, podemos criar um novo tipo em um módulo dedicado e colocar as
validações em uma função que cria uma instância desse tipo, em vez de repetir
as validações em todo lugar. Dessa forma, as funções podem usar com segurança o
novo tipo em suas assinaturas e confiar nos valores que recebem. A Listagem
9-13 mostra uma forma de definir um tipo `Guess` que só cria uma instância de
`Guess` se a função `new` receber um valor entre 1 e 100.

<Listing number="9-13" caption="Um tipo `Guess` que só continuará com valores entre 1 e 100" file-name="src/guessing_game.rs">

```rust
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-13/src/guessing_game.rs}}
```

</Listing>

Observe que esse código em *src/guessing_game.rs* depende da adição de uma
declaração de módulo `mod guessing_game;` em *src/lib.rs*, que não mostramos
aqui. Dentro do arquivo desse novo módulo, definimos uma struct chamada
`Guess`, que tem um campo chamado `value` contendo um `i32`. É ali que o número
ficará armazenado.

Em seguida, implementamos em `Guess` uma função associada chamada `new`, que
cria instâncias de valores `Guess`. A função `new` recebe um parâmetro chamado
`value`, do tipo `i32`, e retorna um `Guess`. O código dentro de `new` testa
`value` para garantir que ele está entre 1 e 100. Se `value` não passar nesse
teste, fazemos uma chamada a `panic!`, o que alertará a pessoa programadora que
está escrevendo o código chamador de que existe um bug a corrigir, porque criar
um `Guess` com um `value` fora desse intervalo violaria o contrato do qual
`Guess::new` depende. As condições em que `Guess::new` pode entrar em panic
devem ser discutidas na documentação pública de sua API; veremos convenções de
documentação que indicam a possibilidade de `panic!` na documentação de API que
você escrever no Capítulo 14. Se `value` passar no teste, criamos um novo
`Guess` com seu campo `value` definido com base no parâmetro `value` e
retornamos esse `Guess`.

A seguir, implementamos um método chamado `value`, que toma emprestado `self`,
não recebe outros parâmetros e retorna um `i32`. Esse tipo de método às vezes é
chamado de _getter_, porque seu propósito é obter algum dado dos campos e
retorná-lo. Esse método público é necessário porque o campo `value` da struct
`Guess` é privado. É importante que `value` seja privado para que o código que
usa a struct `Guess` não possa defini-lo diretamente: código fora do módulo
`guessing_game` _deve_ usar a função `Guess::new` para criar uma instância de
`Guess`, garantindo assim que não exista maneira de um `Guess` ter um `value`
que não tenha sido validado pelas condições da função `Guess::new`.

Uma função que receba um parâmetro ou retorne apenas números entre 1 e 100 pode
então declarar em sua assinatura que recebe ou retorna um `Guess` em vez de um
`i32`, sem precisar fazer qualquer checagem adicional no corpo.

## Resumo

Os recursos de tratamento de erros do Rust foram projetados para ajudar você a
escrever código mais robusto. A macro `panic!` sinaliza que o programa está em
um estado com o qual não consegue lidar e permite que você mande o processo
parar, em vez de tentar continuar com dados inválidos ou incorretos. O enum
`Result` usa o sistema de tipos do Rust para indicar que certas operações podem
falhar de um modo do qual o seu código pode se recuperar. Você pode usar
`Result` para dizer ao código que chama o seu que ele também precisa lidar com
a possibilidade de sucesso ou falha. Usar `panic!` e `Result` nas situações
apropriadas tornará seu código mais confiável diante dos problemas inevitáveis.

Agora que você viu maneiras úteis pelas quais a biblioteca padrão usa genéricos
com os enums `Option` e `Result`, vamos falar sobre como genéricos funcionam e
como você pode usá-los no seu próprio código.

[encoding]: ch18-03-oo-design-patterns.html#encoding-states-and-behavior-as-types
