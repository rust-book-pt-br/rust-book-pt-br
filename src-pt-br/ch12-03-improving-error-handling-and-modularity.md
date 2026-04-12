## Refatoração para melhorar a modularidade e o tratamento de erros

Para melhorar nosso programa, vamos corrigir quatro problemas relacionados à
estrutura do código e à forma como ele lida com possíveis erros. Primeiro, a
função `main` agora executa duas tarefas: analisar argumentos e ler arquivos.
À medida que o programa crescer, o número de tarefas diferentes pelas quais
`main` é responsável tende a aumentar. Quando uma função acumula
responsabilidades, ela se torna mais difícil de entender, mais difícil de testar
e mais difícil de modificar sem quebrar alguma parte. O ideal é separar as
funcionalidades para que cada função fique responsável por uma única tarefa.

Esse problema também se conecta a um segundo ponto: embora `query` e
`file_path` sejam variáveis de configuração do programa, variáveis como
`contents` são usadas na lógica principal. Quanto maior `main` ficar, mais
variáveis precisaremos colocar em escopo; quanto mais variáveis houver em
escopo, mais difícil será acompanhar o propósito de cada uma. O ideal é
agrupar as variáveis de configuração em uma struct para deixar essa intenção
clara.

O terceiro problema é que usamos `expect` para imprimir uma mensagem de erro
quando a leitura do arquivo falha, mas a mensagem gerada apenas diz `Should
have been able to read the file`. Ler um arquivo pode falhar por várias
razões: o arquivo pode não existir ou talvez não tenhamos permissão para
abri-lo. No estado atual, independentemente do motivo, imprimiríamos a mesma
mensagem para tudo, o que não dá nenhuma informação útil ao usuário.

Por fim, também usamos `expect` para lidar com outro erro: se o usuário rodar
o programa sem argumentos suficientes, receberá um erro `index out of bounds`
gerado pelo próprio Rust, o que não explica claramente o problema. Seria
melhor se todo o código de tratamento de erros ficasse reunido em um só lugar,
de modo que futuras pessoas mantenedoras soubessem exatamente onde procurar se
essa lógica precisasse mudar. Além disso, manter esse tratamento concentrado em
um ponto também ajuda a garantir que as mensagens impressas sejam úteis para os
usuários finais.

Vamos resolver esses quatro problemas refatorando o projeto.

<!-- Old headings. Do not remove or links may break. -->

<a id="separation-of-concerns-for-binary-projects"></a>

### Separando Responsabilidades em Projetos Binários

O problema organizacional de concentrar muitas tarefas na função `main` é comum
em vários projetos binários. Por isso, muitos programadores Rust consideram
útil separar as diferentes responsabilidades de um programa binário quando
`main` começa a crescer. Esse processo costuma seguir estas etapas:

- Divida o programa em um arquivo _main.rs_ e um arquivo _lib.rs_, movendo a
  lógica principal para _lib.rs_.
- Enquanto a lógica de análise de linha de comando for pequena, ela pode
  continuar dentro de `main`.
- Quando essa lógica de análise começar a ficar mais complexa, extraia-a de
  `main` para outras funções ou tipos.

Depois desse processo, as responsabilidades restantes em `main` devem se
limitar a:

- Chamar a lógica de análise de linha de comando com os valores dos argumentos
- Configurar qualquer informação adicional necessária
- Chamar uma função `run` em _lib.rs_
- Tratar o erro caso `run` retorne um erro

Esse padrão trata de separação de responsabilidades: _main.rs_ cuida da
execução do programa, enquanto _lib.rs_ concentra toda a lógica da tarefa em
si. Como não é possível testar diretamente a função `main`, essa estrutura
permite testar toda a lógica do programa ao movê-la para fora dela. O código
que permanecer em `main` ficará pequeno o bastante para termos confiança nele
apenas lendo-o. Vamos retrabalhar o programa seguindo esse processo.

#### Extraindo o Analisador de Argumentos

Vamos extrair a funcionalidade de análise de argumentos para uma função que
`main` chamará. A Listagem 12-5 mostra o novo começo de `main`, que passa a
chamar uma nova função `parse_config`, a ser definida em _src/main.rs_.

<Listing number="12-5" file-name="src/main.rs" caption="Extraindo de `main` uma função `parse_config`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-05/src/main.rs:here}}
```

</Listing>

Ainda continuamos coletando os argumentos de linha de comando em um vetor, mas,
em vez de atribuir dentro de `main` o valor no índice 1 à variável `query` e o
valor no índice 2 à variável `file_path`, passamos o vetor inteiro para
`parse_config`. Essa função passa a conter a lógica que determina qual
argumento vai para qual variável e devolve os valores a `main`. Continuamos
criando as variáveis `query` e `file_path` em `main`, mas `main` deixa de ser
responsável por determinar como argumentos e variáveis se correspondem.

Essa mudança pode parecer exagerada para um programa tão pequeno, mas estamos
refatorando em passos pequenos e incrementais. Depois de fazer essa alteração,
rode o programa novamente para verificar se a análise dos argumentos continua
funcionando. É uma boa prática validar o progresso com frequência, porque isso
ajuda a localizar a origem de problemas quando eles aparecem.

#### Agrupando Valores de Configuração

Podemos dar mais um passo pequeno para melhorar `parse_config`. No momento,
estamos retornando uma tupla, mas logo em seguida quebramos essa tupla de volta
em partes individuais. Isso é um sinal de que talvez ainda não tenhamos a
abstração certa.

Outro indício de que há espaço para melhoria é a própria palavra `config` em
`parse_config`, que sugere que os dois valores retornados estão relacionados e
fazem parte de uma única configuração. Hoje, não estamos transmitindo esse
significado na estrutura dos dados, exceto por agrupá-los em uma tupla. Em vez
disso, vamos colocar os dois valores em uma struct e dar a cada campo um nome
significativo. Isso tornará mais fácil para futuras pessoas mantenedoras
entenderem como os diferentes valores se relacionam e qual é o propósito de
cada um.

A Listagem 12-6 mostra as melhorias na função `parse_config`.

<Listing number="12-6" file-name="src/main.rs" caption="Refatorando `parse_config` para retornar uma instância da struct `Config`">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-06/src/main.rs:here}}
```

</Listing>

Adicionamos uma struct chamada `Config` com campos `query` e `file_path`. A
assinatura de `parse_config` agora indica que ela retorna um valor `Config`. No
corpo de `parse_config`, onde antes retornávamos fatias de string que
referenciavam valores `String` em `args`, agora definimos `Config` para conter
valores `String` com ownership próprio. A variável `args`, em `main`, é a dona
dos valores dos argumentos e apenas permite que `parse_config` os empreste. Se
`Config` tentasse tomar ownership desses valores diretamente de `args`,
violaríamos as regras de borrowing do Rust.

Há várias formas de lidar com esses dados `String`; o caminho mais simples,
embora um pouco ineficiente, é chamar `clone` nos valores. Isso fará uma cópia
completa dos dados para que a instância de `Config` tenha ownership deles, o
que consome mais tempo e memória do que armazenar uma referência para os dados
da string. Ainda assim, clonar também deixa o código muito mais simples, porque
não precisamos gerenciar o lifetime das referências; nessa situação, abrir mão
de um pouco de desempenho em troca de simplicidade é uma decisão razoável.

> ### As vantagens e desvantagens de usar `clone`
>
> Há uma tendência entre muitos Rustáceos de evitar usar `clone` para consertar
> problemas de ownership devido ao custo em tempo de execução. Em
> [Capítulo 13][ch13]<!-- ignore -->, você aprenderá como usar recursos mais eficientes
> métodos neste tipo de situação. Mas, por enquanto, não há problema em copiar alguns
> strings para continuar progredindo porque você fará apenas essas cópias
> uma vez e o caminho do arquivo e a string de consulta são muito pequenos. É melhor ter
> um programa funcional que é um pouco ineficiente do que tentar hiperotimizar o código
> na sua primeira passagem. À medida que você se torna mais experiente com Rust, será
> mais fácil começar com a solução mais eficiente, mas por enquanto, é
> perfeitamente aceitável ligar para `clone`.

Atualizamos `main` para armazenar a instância de `Config` retornada por
`parse_config` em uma variável chamada `config`. Também ajustamos o restante do
código, que antes usava as variáveis `query` e `file_path` separadamente, para
passar a usar os campos da struct `Config`.

Agora o código transmite com mais clareza que `query` e `file_path` estão
relacionados e que seu propósito é configurar a forma como o programa vai
funcionar. Qualquer parte do código que use esses valores sabe que deve
encontrá-los na instância `config`, em campos nomeados de acordo com sua
finalidade.

#### Criando um Construtor para `Config`

Até aqui, extraímos a lógica responsável por analisar os argumentos de linha de
comando de `main` e a colocamos em `parse_config`. Isso nos ajudou a perceber
que os valores `query` e `file_path` estavam relacionados e que essa relação
deveria ser expressa no código. Depois, adicionamos uma struct `Config` para
representar esse papel compartilhado e para poder devolver os valores usando
nomes de campos significativos.

Agora, como o objetivo de `parse_config` é criar uma instância de `Config`,
podemos transformar `parse_config` em vez de uma função comum em uma função
chamada `new`, associada à struct `Config`. Essa mudança torna o código mais
idiomático. Criamos instâncias de tipos da biblioteca padrão, como `String`,
chamando `String::new`. Da mesma forma, ao transformar `parse_config` em uma
função `new` associada a `Config`, poderemos criar instâncias de `Config`
chamando `Config::new`. A Listagem 12-7 mostra as alterações necessárias.

<Listing number="12-7" file-name="src/main.rs" caption="Transformando `parse_config` em `Config::new`">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-07/src/main.rs:here}}
```

</Listing>

Atualizamos `main` para chamar `Config::new` onde antes chamávamos
`parse_config`. Mudamos o nome de `parse_config` para `new` e o movemos para
dentro de um bloco `impl`, o que associa essa função a `Config`. Tente
compilar o código novamente para ter certeza de que tudo continua funcionando.

### Corrigindo o Tratamento de Erros

Agora vamos trabalhar para melhorar o tratamento de erros. Lembre-se de que
tentar acessar os valores do vetor `args` nos índices 1 ou 2 fará o programa
entrar em pânico se o vetor tiver menos de três itens. Tente executar o
programa sem nenhum argumento; o resultado será algo assim:

```console
{{#include ../listings/ch12-an-io-project/listing-12-07/output.txt}}
```

A linha `index out of bounds: the len is 1 but the index is 1` é uma mensagem
de erro voltada para programadores. Ela não ajuda o usuário final a entender o
que deveria fazer. Vamos corrigir isso agora.

#### Melhorando a Mensagem de Erro

Na Listagem 12-8, adicionamos à função `new` uma verificação para confirmar se
a fatia é longa o bastante antes de acessarmos os índices 1 e 2. Se não for, o
programa entra em pânico e exibe uma mensagem de erro melhor.

<Listing number="12-8" file-name="src/main.rs" caption="Adicionando uma verificação da quantidade de argumentos">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-08/src/main.rs:here}}
```

</Listing>

Esse código é parecido com a [função `Guess::new` que escrevemos na Listagem
9-13][ch9-custom-types]<!-- ignore -->, em que chamávamos `panic!` quando o
argumento `value` estava fora do intervalo de valores válidos. Aqui, em vez de
verificar um intervalo de valores, verificamos se `args` tem pelo menos
`3` itens e então assumimos que o restante da função pode operar com essa
condição satisfeita. Se `args` tiver menos de três itens, essa condição será
verdadeira, e chamaremos a macro `panic!` para encerrar o programa
imediatamente.

Com essas poucas linhas extras em `new`, vamos executar novamente o programa
sem argumentos para ver como o erro aparece agora:

```console
{{#include ../listings/ch12-an-io-project/listing-12-08/output.txt}}
```

Essa saída é melhor: agora temos uma mensagem razoável. Ainda assim, ela também
traz informações extras que não queremos mostrar aos usuários. Talvez a
técnica que usamos na Listagem 9-13 não seja a melhor aqui: uma chamada a
`panic!` é mais apropriada para um problema de programação do que para um
problema de uso, [como discutimos no Capítulo 9][ch9-error-guidelines]<!--
ignore -->. Em vez disso, vamos usar a outra técnica apresentada no Capítulo 9:
[retornar um `Result`][ch9-result]<!-- ignore --> indicando sucesso ou erro.

<!-- Old headings. Do not remove or links may break. -->

<a id="returning-a-result-from-new-instead-of-calling-panic"></a>

#### Retornando um `Result` em vez de chamar `panic!`

Em vez de entrar em pânico, podemos retornar um valor `Result`, que conterá
uma instância de `Config` no caso de sucesso e descreverá o problema no caso
de erro. Também vamos mudar o nome da função de `new` para `build`, porque
muitos programadores esperam que funções chamadas `new` nunca falhem. Quando
`Config::build` se comunica com `main`, podemos usar o tipo `Result` para
sinalizar que houve um problema. Depois, podemos alterar `main` para converter
uma variante `Err` em uma mensagem mais prática para usuários, sem o texto
extra sobre `thread 'main'` e `RUST_BACKTRACE` que uma chamada a `panic!`
costuma produzir.

A Listagem 12-9 mostra as mudanças necessárias no tipo de retorno da função,
que agora se chama `Config::build`, e também no corpo dela para que passe a
retornar um `Result`. Observe que isso ainda não compilará até que também
atualizemos `main`, o que faremos na próxima listagem.

<Listing number="12-9" file-name="src/main.rs" caption="Retornando um `Result` de `Config::build`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-09/src/main.rs:here}}
```

</Listing>

Nossa função `build` retorna um `Result` com uma instância `Config` no caso de
sucesso e uma string literal no caso de erro. Nossos valores de erro serão
sempre literais de string, que têm lifetime `'static`.

Fizemos duas alterações no corpo da função: em vez de chamar `panic!` quando o
usuário não passa argumentos suficientes, agora retornamos um valor `Err`; além
disso, envolvemos o valor de retorno `Config` em `Ok`. Essas mudanças fazem a
função obedecer à nova assinatura de tipo.

Retornar um valor `Err` de `Config::build` permite que `main` trate o
`Result` devolvido por `build` e encerre o processo de maneira mais limpa em
caso de erro.

<!-- Old headings. Do not remove or links may break. -->

<a id="calling-confignew-and-handling-errors"></a>

#### Chamando `Config::build` e tratando erros

Para lidar com o caso de erro e imprimir uma mensagem amigável, precisamos
atualizar `main` para tratar o `Result` retornado por `Config::build`, como
mostra a Listagem 12-10. Também vamos assumir explicitamente a
responsabilidade de encerrar a ferramenta de linha de comando com um código de
erro diferente de zero, em vez de deixar isso a cargo de `panic!`. Um status
de saída diferente de zero é a convenção usada para sinalizar ao processo que
invocou nosso programa que ele terminou em estado de erro.

<Listing number="12-10" file-name="src/main.rs" caption="Encerrando com um código de erro se a construção de `Config` falhar">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-10/src/main.rs:here}}
```

</Listing>

Nesta listagem, usamos um método que ainda não explicamos em detalhes:
`unwrap_or_else`, definido em `Result<T, E>` na biblioteca padrão. Usar
`unwrap_or_else` nos permite definir um tratamento de erro personalizado sem
recorrer a `panic!`. Se `Result` for um valor `Ok`, o comportamento desse
método é parecido com `unwrap`: ele retorna o valor interno armazenado em
`Ok`. No entanto, se o valor for `Err`, esse método chama o código do closure
que definimos e passamos como argumento para `unwrap_or_else`.
Abordaremos closures com mais detalhes no [Capítulo 13][ch13]<!-- ignore -->.
Por enquanto, basta saber que `unwrap_or_else` passará ao closure, no argumento
`err` entre barras verticais, o valor interno de `Err`, que neste caso é a
string estática `"not enough arguments"` adicionada na Listagem 12-9. O código
do closure pode então usar o valor `err` quando for executado.

Adicionamos uma nova linha `use` para trazer `process` da biblioteca padrão
para o escopo. O código dentro do closure executado em caso de erro tem apenas
duas linhas: imprimimos o valor `err` e depois chamamos `process::exit`. A
função `process::exit` encerra o programa imediatamente e devolve o número
passado como código de status de saída. Isso é semelhante ao tratamento com
`panic!` que usamos na Listagem 12-8, mas agora não recebemos toda aquela
saída extra. Vamos testar:

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

<Listing number="12-11" file-name="src/main.rs" caption="Extraindo uma função `run` com o restante da lógica do programa">

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

<Listing number="12-12" file-name="src/main.rs" caption="Fazendo a função `run` retornar `Result`">

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

### Dividindo o código em uma crate de biblioteca

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

<Listing number="12-13" file-name="src/lib.rs" caption="Definindo a função `search` em *src/lib.rs*">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-13/src/lib.rs}}
```

</Listing>

Usamos a palavra-chave `pub` na definição da função para designar `search`
como parte da API pública da nossa biblioteca. Agora temos uma crate de biblioteca que
podemos usar da nossa crate binária e que podemos testar!

Agora precisamos trazer o código definido em _src/lib.rs_ para o escopo do
binary crate em _src/main.rs_ e chame-o, conforme mostrado na Listagem 12-14.

<Listing number="12-14" file-name="src/main.rs" caption="Usando em *src/main.rs* a função `search` do crate de biblioteca `minigrep`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-14/src/main.rs:here}}
```

</Listing>

Adicionamos uma linha `use minigrep::search` para trazer a função `search` de
a crate da biblioteca no escopo da crate binária. Então, na função `run`,
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
