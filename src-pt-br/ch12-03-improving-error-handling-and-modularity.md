## Refatoração para melhorar a modularidade e o tratamento de erros

Para melhorar nosso programa, resolveremos quatro problemas que têm a ver com o
a estrutura do programa e como ele lida com possíveis erros. Primeiro, nosso `main`
A função agora executa duas tarefas: analisa argumentos e lê arquivos. Como nosso
programa crescer, o número de tarefas separadas que a função `main` manipula
aumentar. À medida que uma função ganha responsabilidades, torna-se mais difícil
raciocinar, mais difícil de testar e mais difícil de mudar sem quebrar um de seus
peças. É melhor separar as funcionalidades para que cada função seja responsável
para uma tarefa.

Esta questão também está ligada ao segundo problema: Embora `query` e `file_path`
são variáveis ​​de configuração para o nosso programa, variáveis ​​como `contents` são usadas
para executar a lógica do programa. Quanto mais longo `main` se torna, mais variáveis
precisaremos trazer para o escopo; quanto mais variáveis ​​tivermos no escopo, mais difícil
será acompanhar o propósito de cada um. O melhor é agrupar
variáveis ​​de configuração em uma estrutura para deixar seu propósito claro.

O terceiro problema é que usamos `expect` para imprimir uma mensagem de erro quando
a leitura do arquivo falha, mas a mensagem de erro apenas imprime `Deveria ter sido
capaz de ler o arquivo`. A leitura de um arquivo pode falhar de diversas maneiras: Por
por exemplo, o arquivo pode estar faltando ou talvez não tenhamos permissão para abri-lo.
Neste momento, independentemente da situação, imprimiríamos a mesma mensagem de erro para
tudo, o que não daria nenhuma informação ao usuário!

Quarto, usamos `expect` para lidar com um erro e se o usuário executar nosso programa
sem especificar argumentos suficientes, eles receberão um erro `index out of bounds`
de Rust que não explica claramente o problema. Seria melhor se todos os
código de tratamento de erros estavam em um só lugar para que os futuros mantenedores tivessem apenas um
local para consultar o código se a lógica de tratamento de erros precisasse ser alterada. Tendo
todo o código de tratamento de erros em um só lugar também garantirá que estamos imprimindo
mensagens que serão significativas para nossos usuários finais.

Vamos resolver esses quatro problemas refatorando nosso projeto.

<!-- Old headings. Do not remove or links may break. -->

<a id="separation-of-concerns-for-binary-projects"></a>

### Separando Preocupações em Projetos Binários

O problema organizacional de alocar responsabilidade por múltiplas tarefas para
a função `main` é comum a muitos projetos binários. Como resultado, muitos Rust
os programadores acham útil dividir as preocupações separadas de um binário
programa quando a função `main` começa a ficar grande. Este processo tem o
seguintes etapas:

- Divida seu programa em um arquivo _main.rs_ e um arquivo _lib.rs_ e mova seu
lógica do programa para _lib.rs_.
- Contanto que sua lógica de análise de linha de comando seja pequena, ela poderá permanecer em
a função `main`.
- Quando a lógica de análise da linha de comando começar a ficar complicada, extraia-a
da função `main` para outras funções ou tipos.

As responsabilidades que permanecem na função `main` após este processo
deve ser limitado ao seguinte:

- Chamando a lógica de análise da linha de comando com os valores dos argumentos
- Configurando qualquer outra configuração
- Chamando uma função `run` em _lib.rs_
- Tratamento do erro se `run` retornar um erro

Este padrão trata da separação de interesses: _main.rs_ lida com a execução do
programa e _lib.rs_ lida com toda a lógica da tarefa em questão. Porque você
não é possível testar a função `main` diretamente, esta estrutura permite testar todas
a lógica do seu programa removendo-o da função `main`. O código que
permanece na função `main` será pequeno o suficiente para verificar sua correção
lendo-o. Vamos retrabalhar nosso programa seguindo este processo.

#### Extraindo o analisador de argumentos

Extrairemos a funcionalidade para analisar argumentos em uma função que
`main` ligará. A Listagem 12-5 mostra o novo início da função `main` que
chama uma nova função `parse_config`, que definiremos em _src/main.rs_.

<Listing number="12-5" file-name="src/main.rs" caption="Extracting a `parse_config` function from `main`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-05/src/main.rs:here}}
```

</Listing>

Ainda estamos coletando os argumentos da linha de comando em um vetor, mas em vez de
atribuindo o valor do argumento no índice 1 à variável `query` e o
valor do argumento no índice 2 para a variável `file_path` dentro de `main`
função, passamos o vetor inteiro para a função `parse_config`. O
A função `parse_config` mantém a lógica que determina qual argumento
entra em qual variável e passa os valores de volta para `main`. Nós ainda criamos
as variáveis ​​`query` e `file_path` em `main`, mas `main` não tem mais o
responsabilidade de determinar como os argumentos e variáveis ​​da linha de comando
corresponder.

Esse retrabalho pode parecer um exagero para nosso pequeno programa, mas estamos refatorando
em passos pequenos e incrementais. Após fazer esta alteração, execute o programa novamente para
verifique se a análise do argumento ainda funciona. É bom verificar seu progresso
frequentemente, para ajudar a identificar a causa dos problemas quando eles ocorrem.

#### Agrupando valores de configuração

Podemos dar mais um pequeno passo para melhorar ainda mais a função `parse_config`.
No momento, estamos retornando uma tupla, mas imediatamente a quebramos
tupla em partes individuais novamente. Este é um sinal de que talvez não tenhamos
a abstração correta ainda.

Outro indicador que mostra que há espaço para melhorias é a parte `config`
de `parse_config`, o que implica que os dois valores que retornamos estão relacionados e
ambos fazem parte de um valor de configuração. No momento não estamos transmitindo isso
significado na estrutura dos dados, a não ser agrupando os dois valores em
uma tupla; em vez disso, colocaremos os dois valores em uma estrutura e forneceremos cada um dos
struct coloca um nome significativo nos campos. Isso tornará mais fácil para o futuro
mantenedores deste código para entender como os diferentes valores se relacionam com cada
outro e qual é o seu propósito.

A Listagem 12-6 mostra as melhorias na função `parse_config`.

<Listing number="12-6" file-name="src/main.rs" caption="Refactoring `parse_config` to return an instance of a `Config` struct">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-06/src/main.rs:here}}
```

</Listing>

Adicionamos uma estrutura chamada `Config` definida para ter campos chamados `query` e
`file_path`. A assinatura de `parse_config` agora indica que ele retorna um
`Config` valor. No corpo de `parse_config`, onde costumávamos retornar
fatias de string que fazem referência a valores `String` em `args`, agora definimos `Config`
para conter valores `String` próprios. A variável `args` em `main` é a proprietária de
os valores do argumento e só está permitindo a função `parse_config` emprestar
eles, o que significa que violaríamos as regras de empréstimo de Rust se `Config` tentasse pegar
propriedade dos valores em `args`.

Existem várias maneiras de gerenciar os dados `String`; o mais fácil,
embora um tanto ineficiente, o caminho é chamar o método `clone` nos valores.
Isso fará uma cópia completa dos dados para a instância `Config` possuir, que
leva mais tempo e memória do que armazenar uma referência aos dados da string.
No entanto, clonar os dados também torna nosso código muito simples porque
não precisa gerenciar a vida útil das referências; nesta circunstância,
abrir mão de um pouco de desempenho para ganhar simplicidade é uma troca que vale a pena.

> ### As vantagens e desvantagens de usar `clone`
>
> Há uma tendência entre muitos Rustáceos de evitar usar `clone` para consertar
> problemas de propriedade devido ao seu custo de tempo de execução. Em
> [Capítulo 13][ch13]<!-- ignore -->, você aprenderá como usar recursos mais eficientes
> métodos neste tipo de situação. Mas, por enquanto, não há problema em copiar alguns
> strings para continuar progredindo porque você fará apenas essas cópias
> uma vez e o caminho do arquivo e a string de consulta são muito pequenos. É melhor ter
> um programa funcional que é um pouco ineficiente do que tentar hiperotimizar o código
> na sua primeira passagem. À medida que você se torna mais experiente com Rust, será
> mais fácil começar com a solução mais eficiente, mas por enquanto, é
> perfeitamente aceitável ligar para `clone`.

Atualizamos `main` para que coloque a instância de `Config` retornada por
`parse_config` em uma variável chamada `config` e atualizamos o código que
anteriormente usava as variáveis ​​`query` e `file_path` separadas para que agora
usa os campos na estrutura `Config`.

Agora nosso código transmite mais claramente que `query` e `file_path` estão relacionados e
que seu objetivo é configurar como o programa funcionará. Qualquer código que
usa esses valores sabe encontrá-los na instância `config` nos campos
nomeados de acordo com seu propósito.

#### Criando um construtor para `Config`

Até agora, extraímos a lógica responsável por analisar a linha de comando
argumentos de `main` e colocou-os na função `parse_config`. Fazendo isso
nos ajudou a ver que os valores `query` e `file_path` estavam relacionados e que
relacionamento deve ser transmitido em nosso código. Em seguida, adicionamos uma estrutura `Config` a
nomeie o propósito relacionado de `query` e `file_path` e para poder retornar o
nomes de valores como nomes de campos struct da função `parse_config`.

Então, agora que o objetivo da função `parse_config` é criar um `Config`
por exemplo, podemos mudar `parse_config` de uma função simples para uma função
chamado `new` que está associado à estrutura `Config`. Fazendo essa mudança
tornará o código mais idiomático. Podemos criar instâncias de tipos no
biblioteca padrão, como `String`, chamando `String::new`. Da mesma forma, por
mudando `parse_config` para uma função `new` associada a `Config`, vamos
ser capaz de criar instâncias de `Config` chamando `Config::new`. Listagem 12-7
mostra as mudanças que precisamos fazer.

<Listing number="12-7" file-name="src/main.rs" caption="Changing `parse_config` into `Config::new`">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-07/src/main.rs:here}}
```

</Listing>

Atualizamos `main` para onde estávamos ligando para `parse_config` para ligar
`Config::new`. Mudamos o nome de `parse_config` para `new` e o movemos
dentro de um bloco `impl`, que associa a função `new` a `Config`. Tentar
compilando este código novamente para ter certeza de que funciona.

### Corrigindo o tratamento de erros

Agora trabalharemos para corrigir nosso tratamento de erros. Lembre-se de que tentar acessar
os valores no vetor `args` no índice 1 ou índice 2 farão com que o programa
entre em pânico se o vetor contiver menos de três itens. Tente executar o programa
sem quaisquer argumentos; ficará assim:

```console
{{#include ../listings/ch12-an-io-project/listing-12-07/output.txt}}
```

A linha `index out of bounds: the len is 1 but the index is 1` é um erro
mensagem destinada a programadores. Isso não ajudará nossos usuários finais a entender o que
eles deveriam fazer em vez disso. Vamos consertar isso agora.

#### Melhorando a mensagem de erro

Na Listagem 12-8, adicionamos uma verificação na função `new` que verificará se o
a fatia é longa o suficiente antes de acessar o índice 1 e o índice 2. Se a fatia não for
por tempo suficiente, o programa entra em pânico e exibe uma mensagem de erro melhor.

<Listing number="12-8" file-name="src/main.rs" caption="Adding a check for the number of arguments">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-08/src/main.rs:here}}
```

</Listing>

Este código é semelhante à [função `Guess::new` que escrevemos na Listagem
9-13][ch9-custom-types]<!-- ignore -->, onde chamamos `panic!` quando o
O argumento `value` estava fora do intervalo de valores válidos. Em vez de verificar
um intervalo de valores aqui, estamos verificando se o comprimento de `args` é pelo menos
`3` e o resto da função podem operar sob a suposição de que este
condição foi atendida. Se `args` tiver menos de três itens, esta condição
será `true`, e chamamos a macro `panic!` para encerrar o programa imediatamente.

Com essas poucas linhas extras de código em `new`, vamos executar o programa sem qualquer
argumentos novamente para ver como está o erro agora:

```console
{{#include ../listings/ch12-an-io-project/listing-12-08/output.txt}}
```

Esta saída é melhor: agora temos uma mensagem de erro razoável. No entanto, nós também
temos informações estranhas que não queremos fornecer aos nossos usuários. Talvez o
técnica que usamos na Listagem 9.13 não é a melhor para usar aqui: uma chamada para
`panic!` é mais apropriado para um problema de programação do que um problema de uso,
[conforme discutido no Capítulo 9][ch9-error-guidelines]<!-- ignore -->. Em vez de,
usaremos a outra técnica que você aprendeu no Capítulo 9 - [retornando um
`Result`][ch9-result]<!-- ignore --> que indica sucesso ou erro.

<!-- Old headings. Do not remove or links may break. -->

<a id="returning-a-result-from-new-instead-of-calling-panic"></a>

#### Retornando um `Result` em vez de ligar para `panic!`

Em vez disso, podemos retornar um valor `Result` que conterá uma instância `Config` em
o caso de sucesso e descreverá o problema no caso de erro. Nós também estamos
vou mudar o nome da função de `new` para `build` porque muitos
os programadores esperam que as funções `new` nunca falhem. Quando `Config::build` é
comunicando com `main`, podemos usar o tipo `Result` para sinalizar que houve um
problema. Então, podemos alterar `main` para converter uma variante `Err` em uma variante mais
erro prático para nossos usuários sem o texto ao redor sobre `thread
'main'` and `RUST_BACKTRACE` that a call to `panic!` causa.

A Listagem 12-9 mostra as mudanças que precisamos fazer no valor de retorno do
função que estamos chamando agora `Config::build` e o corpo da função necessária
para retornar um `Result`. Observe que isso não será compilado até atualizarmos `main` como
bem, o que faremos na próxima listagem.

<Listing number="12-9" file-name="src/main.rs" caption="Returning a `Result` from `Config::build`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-09/src/main.rs:here}}
```

</Listing>

Nossa função `build` retorna um `Result` com uma instância `Config` no sucesso
case e uma string literal no caso de erro. Nossos valores de erro serão sempre
literais de string que têm o tempo de vida `'static`.

Fizemos duas alterações no corpo da função: Em vez de chamar `panic!`
quando o usuário não passa argumentos suficientes, agora retornamos um valor `Err` e
envolvemos o valor de retorno `Config` em `Ok`. Estas mudanças fazem com que
função está em conformidade com sua nova assinatura de tipo.

Retornar um valor `Err` de `Config::build` permite que a função `main`
manipule o valor `Result` retornado da função `build` e saia do
processar de forma mais limpa no caso de erro.

<!-- Old headings. Do not remove or links may break. -->

<a id="calling-confignew-and-handling-errors"></a>

#### Chamando `Config::build` e tratando erros

Para lidar com o caso de erro e imprimir uma mensagem amigável, precisamos atualizar
`main` para lidar com `Result` sendo retornado por `Config::build`, conforme mostrado em
Listagem 12-10. Também assumiremos a responsabilidade de sair da linha de comando
ferramenta com um código de erro diferente de zero longe de `panic!` e, em vez disso, implementá-la
mão. Um status de saída diferente de zero é uma convenção para sinalizar ao processo que
chamou nosso programa que o programa saiu com um estado de erro.

<Listing number="12-10" file-name="src/main.rs" caption="Exiting with an error code if building a `Config` fails">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-10/src/main.rs:here}}
```

</Listing>

Nesta listagem, usamos um método que ainda não abordamos em detalhes:
`unwrap_or_else`, que é definido em `Result<T, E>` pela biblioteca padrão.
Usar `unwrap_or_else` nos permite definir alguns erros personalizados e não `panic!`
manuseio. Se `Result` for um valor `Ok`, o comportamento deste método é semelhante
para `unwrap`: retorna o valor interno que `Ok` está agrupando. No entanto, se o
value for um valor `Err`, este método chama o código no encerramento, que é
uma função anônima que definimos e passamos como argumento para `unwrap_or_else`.
Abordaremos os fechamentos com mais detalhes no [Capítulo 13][ch13]<!-- ignore -->. Para
agora, você só precisa saber que `unwrap_or_else` passará o valor interno de
o `Err`, que neste caso é a string estática `"not enough arguments"`
que adicionamos na Listagem 12-9, ao nosso encerramento no argumento `err` que
aparece entre os tubos verticais. O código no encerramento pode então usar o
`err` valor quando é executado.

Adicionamos uma nova linha `use` para trazer `process` da biblioteca padrão para
escopo. O código no encerramento que será executado no caso de erro é de apenas dois
linhas: Imprimimos o valor `err` e depois chamamos `process::exit`. O
A função `process::exit` irá parar o programa imediatamente e retornar o
número que foi passado como código de status de saída. Isto é semelhante ao
Tratamento baseado em `panic!` que usamos na Listagem 12-8, mas não obtemos mais todos os
saída extra. Vamos tentar:

```console
{{#include ../listings/ch12-an-io-project/listing-12-10/output.txt}}
```

Ótimo! Esta saída é muito mais amigável para nossos usuários.

<!-- Old headings. Do not remove or links may break. -->

<a id="extracting-logic-from-the-main-function"></a>

### Extraindo Lógica de `main`

Agora que terminamos de refatorar a análise de configuração, vamos voltar para
a lógica do programa. Como afirmamos em [“Separando Preocupações em Binário
Projetos”](#separação-de-preocupações-para-projetos-binários)<!-- ignore -->, iremos
extraia uma função chamada `run` que conterá toda a lógica atualmente no
`main` função que não está envolvida na configuração ou manipulação
erros. Quando terminarmos, a função `main` será concisa e fácil de verificar
por inspeção, e seremos capazes de escrever testes para todas as outras lógicas.

A Listagem 12-11 mostra a pequena melhoria incremental da extração de um `run`
função.

<Listing number="12-11" file-name="src/main.rs" caption="Extracting a `run` function containing the rest of the program logic">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-11/src/main.rs:here}}
```

</Listing>

A função `run` agora contém toda a lógica restante de `main`, começando
da leitura do arquivo. A função `run` toma a instância `Config` como um
argumento.

<!-- Old headings. Do not remove or links may break. -->

<a id="returning-errors-from-the-run-function"></a>

#### Retornando erros de `run`

Com a lógica restante do programa separada na função `run`, podemos
melhorar o tratamento de erros, como fizemos com `Config::build` na Listagem 12-9.
Em vez de permitir que o programa entre em pânico chamando `expect`, o `run`
função retornará `Result<T, E>` quando algo der errado. Isso vai deixar
consolidaremos ainda mais a lógica em torno do tratamento de erros em `main` em um
maneira amigável. A Listagem 12-12 mostra as mudanças que precisamos fazer no
assinatura e corpo de `run`.

<Listing number="12-12" file-name="src/main.rs" caption="Changing the `run` function to return `Result`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-12/src/main.rs:here}}
```

</Listing>

Fizemos três mudanças significativas aqui. Primeiro, alteramos o tipo de retorno de
a função `run` para `Result<(), Box<dyn Error>>`. Esta função anteriormente
retornou o tipo de unidade, `()`, e mantemos isso como o valor retornado no
`Ok` caso.

Para o tipo de erro, usamos o objeto trait `Box<dyn Error>` (e trouxemos
`std::error::Error` no escopo com uma instrução `use` no topo). Nós vamos cobrir
objetos trait no [Capítulo 18][ch18]<!-- ignore -->. Por enquanto, apenas saiba que
`Box<dyn Error>` significa que a função retornará um tipo que implementa o
`Error` trait, mas não precisamos especificar que tipo específico o retorno
valor será. Isso nos dá flexibilidade para retornar valores de erro que podem ser de
diferentes tipos em diferentes casos de erro. A palavra-chave `dyn` é a abreviação de
_dinâmico_.

Segundo, removemos a chamada para `expect` em favor da operadora `?`, pois
falado no [Capítulo 9][ch9-question-mark]<!-- ignore -->. Em vez de
`panic!` em caso de erro, `?` retornará o valor do erro da função atual
para o chamador lidar.

Terceiro, a função `run` agora retorna um valor `Ok` no caso de sucesso.
Declaramos o tipo de sucesso da função `run` como `()` na assinatura,
o que significa que precisamos agrupar o valor do tipo de unidade no valor `Ok`. Esse
A sintaxe `Ok(())` pode parecer um pouco estranha no início. Mas usar `()` assim é
a maneira idiomática de indicar que estamos ligando para `run` por seus efeitos colaterais
apenas; ele não retorna um valor que precisamos.

Quando você executa este código, ele será compilado, mas exibirá um aviso:

```console
{{#include ../listings/ch12-an-io-project/listing-12-12/output.txt}}
```

Rust nos diz que nosso código ignorou o valor `Result` e o valor `Result`
pode indicar que ocorreu um erro. Mas não estamos verificando se
não houve um erro, e o compilador nos lembra que provavelmente pretendíamos
tem algum código de tratamento de erros aqui! Vamos corrigir esse problema agora.

#### Tratamento de erros retornados de `run` em `main`

Verificaremos se há erros e lidaremos com eles usando uma técnica semelhante à que usamos
com `Config::build` na Listagem 12-10, mas com uma pequena diferença:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/no-listing-01-handling-errors-in-main/src/main.rs:here}}
```

Usamos `if let` em vez de `unwrap_or_else` para verificar se `run` retorna um
`Err` e chamar `process::exit(1)` se isso acontecer. A função `run`
não retorna um valor que queremos `unwrap` da mesma forma que
`Config::build` retorna a instância `Config`. Porque `run` retorna `()` em
caso de sucesso, nos preocupamos apenas em detectar um erro, então não precisamos
`unwrap_or_else` para retornar o valor desembrulhado, que seria apenas `()`.

Os corpos das funções `if let` e `unwrap_or_else` são os mesmos em
ambos os casos: Imprimimos o erro e saímos.

### Dividindo o código em uma caixa de biblioteca

Nosso projeto `minigrep` está parecendo bom até agora! Agora vamos dividir o
arquivo _src/main.rs_ e coloque algum código no arquivo _src/lib.rs_. Dessa forma, nós
pode testar o código e ter um arquivo _src/main.rs_ com menos responsabilidades.

Vamos definir o código responsável pela pesquisa de texto em _src/lib.rs_ em vez
do que em _src/main.rs_, o que nos permitirá (ou qualquer outra pessoa usando nosso
`minigrep` biblioteca) chama a função de pesquisa em mais contextos do que o nosso
`minigrep` binário.

Primeiro, vamos definir a assinatura da função `search` em _src/lib.rs_ conforme mostrado em
Listagem 12-13, com um corpo que chama a macro `unimplemented!`. Nós vamos explicar
a assinatura com mais detalhes quando preenchermos a implementação.

<Listing number="12-13" file-name="src/lib.rs" caption="Defining the `search` function in *src/lib.rs*">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-13/src/lib.rs}}
```

</Listing>

Usamos a palavra-chave `pub` na definição da função para designar `search`
como parte da API pública da nossa biblioteca. Agora temos uma caixa de biblioteca que
podemos usar da nossa caixa binária e que podemos testar!

Agora precisamos trazer o código definido em _src/lib.rs_ para o escopo do
binary crate em _src/main.rs_ e chame-o, conforme mostrado na Listagem 12-14.

<Listing number="12-14" file-name="src/main.rs" caption="Using the `minigrep` library crate’s `search` function in *src/main.rs*">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-14/src/main.rs:here}}
```

</Listing>

Adicionamos uma linha `use minigrep::search` para trazer a função `search` de
a caixa da biblioteca no escopo da caixa binária. Então, na função `run`,
em vez de imprimir o conteúdo do arquivo, chamamos `search`
função e passe o valor `config.query` e `contents` como argumentos. Então,
`run` usará um loop `for` para imprimir cada linha retornada de `search` que
correspondeu à consulta. Este também é um bom momento para remover as chamadas `println!` em
a função `main` que exibia a consulta e o caminho do arquivo para que nosso
o programa imprime apenas os resultados da pesquisa (se nenhum erro ocorrer).

Observe que a função de pesquisa coletará todos os resultados em um vetor
ele retorna antes de qualquer impressão acontecer. Esta implementação poderá ser lenta
exibir resultados ao pesquisar arquivos grandes, porque os resultados não são impressos como
eles são encontrados; discutiremos uma possível maneira de corrigir isso usando iteradores em
Capítulo 13.

Uau! Foi muito trabalhoso, mas nos preparamos para o sucesso no
futuro. Agora é muito mais fácil lidar com erros e tornamos o código mais
modular. Quase todo o nosso trabalho será feito em _src/lib.rs_ daqui em diante.

Vamos aproveitar esta nova modularidade fazendo algo que
tem sido difícil com o código antigo, mas é fácil com o novo código: vamos
escreva alguns testes!

[ch13]: ch13-00-functional-features.html
[ch9-custom-types]: ch09-03-to-panic-or-not-to-panic.html#creating-custom-types-for-validation
[ch9-error-guidelines]: ch09-03-to-panic-or-not-to-panic.html#guidelines-for-error-handling
[ch9-result]: ch09-02-recoverable-errors-with-result.html
[ch18]: ch18-00-oop.html
[ch9-question-mark]: ch09-02-recoverable-errors-with-result.html#a-shortcut-for-propagating-errors-the--operator
