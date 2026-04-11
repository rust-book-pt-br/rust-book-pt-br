<!-- Old headings. Do not remove or links may break. -->
<a id="developing-the-librarys-functionality-with-test-driven-development"></a>

## Adicionando Funcionalidade com Desenvolvimento Guiado por Testes

Agora que temos a lógica de busca em _src/lib.rs_, separada da função `main`,
fica muito mais fácil escrever testes para a funcionalidade principal do nosso
código. Podemos chamar funções diretamente com vários argumentos e verificar os
valores de retorno sem precisar invocar o binário a partir da linha de
comando.

Nesta seção, adicionaremos a lógica de busca ao programa `minigrep` usando o
processo de desenvolvimento guiado por testes, ou TDD, seguindo estes passos:

1. Escreva um teste que falhe e execute-o para se certificar de que ele falha
   pelo motivo esperado.
2. Escreva ou modifique apenas o suficiente de código para fazer o novo teste
   passar.
3. Refatore o código que acabou de adicionar ou alterar e certifique-se de que
   os testes continuam passando.
4. Repita a partir do passo 1!

Embora seja apenas uma entre muitas formas de escrever software, TDD pode ajudar
a orientar o design do código. Escrever o teste antes de escrever o código que
o faz passar ajuda a manter uma cobertura de testes alta ao longo de todo o
processo.

Vamos orientar por testes a implementação da funcionalidade que realmente fará
a busca da string de consulta no conteúdo do arquivo e produzirá uma lista das
linhas que correspondem. Adicionaremos essa funcionalidade em uma função
chamada `search`.

### Escrevendo um Teste que Falha

Em _src/lib.rs_, adicionaremos um módulo `tests` com uma função de teste, como
fizemos no [Capítulo 11][ch11-anatomy]<!-- ignore -->. A função de teste
especifica o comportamento que queremos que a função `search` tenha: ela
receberá uma consulta e o texto a ser pesquisado, e retornará apenas as linhas
do texto que contêm a consulta. A Listagem 12-15 mostra esse teste.

<Listing number="12-15" file-name="src/lib.rs" caption="Criando um teste que falha para a função `search`, para a funcionalidade que gostaríamos de ter">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-15/src/lib.rs:here}}
```

</Listing>

Esse teste procura pela string `"duct"`. O texto pesquisado tem três linhas, e
apenas uma delas contém `"duct"`; observe que a barra invertida após as aspas
de abertura diz a Rust para não colocar um caractere de nova linha no começo do
conteúdo desse literal de string. Verificamos que o valor retornado pela função
`search` contém apenas a linha que esperamos.

Se executarmos esse teste agora, ele falhará porque a macro `unimplemented!`
entra em pânico com a mensagem “not implemented”. Seguindo os princípios do
TDD, daremos um pequeno passo: adicionaremos código apenas suficiente para que
o teste deixe de entrar em pânico ao chamar a função, definindo `search` para
sempre retornar um vetor vazio, como na Listagem 12-16. Então, o teste deverá
compilar e falhar, porque um vetor vazio não corresponde a um vetor contendo a
linha `"safe, fast, productive."`.

<Listing number="12-16" file-name="src/lib.rs" caption="Definindo apenas o suficiente da função `search` para que chamá-la não gere pânico">

```rust,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-16/src/lib.rs:here}}
```

</Listing>

Agora, vamos discutir por que precisamos definir um lifetime explícito `'a` na
assinatura de `search` e usar esse lifetime no argumento `contents` e no valor
de retorno. Lembre-se de [Capítulo 10][ch10-lifetimes]<!-- ignore --> que os
parâmetros de lifetime especificam qual lifetime de argumento está conectado ao
lifetime do valor retornado. Neste caso, indicamos que o vetor retornado deve
conter fatias de string que referenciam partes do argumento `contents`, e não
do argumento `query`.

Em outras palavras, estamos dizendo a Rust que os dados retornados pela função
`search` viverão tanto quanto os dados passados para a função no argumento
`contents`. Isso é importante! Os dados referenciados _por_ uma fatia precisam
ser válidos para que a referência também seja válida; se o compilador assumir
que estamos criando fatias de string de `query`, em vez de `contents`, ele fará
a checagem de segurança de forma incorreta.

Se esquecermos as anotações de lifetime e tentarmos compilar essa função,
receberemos este erro:

```console
{{#include ../listings/ch12-an-io-project/output-only-02-missing-lifetimes/output.txt}}
```

Rust não consegue saber qual dos dois parâmetros é necessário para o valor de
saída, então precisamos dizer isso explicitamente. Observe que o texto de ajuda
sugere especificar o mesmo parâmetro de lifetime para todos os parâmetros e
para o tipo de saída, mas isso estaria incorreto! Como `contents` é o parâmetro
que contém todo o texto, e queremos retornar partes desse texto que
correspondam à busca, sabemos que `contents` é o único parâmetro que deve ser
conectado ao valor de retorno usando a sintaxe de lifetimes.

Outras linguagens de programação não exigem essa conexão entre argumentos e
valores de retorno na assinatura, mas isso ficará mais natural com o tempo.
Pode valer a pena comparar este exemplo com os exemplos da seção [“Validando
Referências com Lifetimes”][validating-references-with-lifetimes]<!-- ignore -->
no Capítulo 10.

### Escrevendo Código para Fazer o Teste Passar

No momento, nosso teste está falhando porque sempre retornamos um vetor vazio.
Para corrigir isso e implementar `search`, nosso programa precisa seguir estes
passos:

1. Iterar por cada linha do conteúdo.
2. Verificar se a linha contém a string de consulta.
3. Se contiver, adicioná-la à lista de valores que vamos retornar.
4. Se não contiver, não fazer nada.
5. Retornar a lista de resultados que correspondem.

Vamos percorrer cada etapa, começando pela iteração sobre as linhas.

#### Iterando sobre Linhas com o Método `lines`

Rust possui um método útil para lidar com a iteração linha a linha de strings,
convenientemente chamado `lines`, que funciona como mostrado na Listagem 12-17.
Observe que isso ainda não compilará.

<Listing number="12-17" file-name="src/lib.rs" caption="Iterando por cada linha em `contents`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-17/src/lib.rs:here}}
```

</Listing>

O método `lines` retorna um iterador. Falaremos sobre iteradores em profundidade
no [Capítulo 13][ch13-iterators]<!-- ignore -->. Mas lembre-se de que você já
viu esse modo de usar um iterador na [Listagem 3-5][ch3-iter]<!-- ignore -->,
em que usamos um laço `for` com um iterador para executar algum código em cada
item de uma coleção.

#### Procurando a Consulta em Cada Linha

Em seguida, verificaremos se a linha atual contém a nossa string de consulta.
Felizmente, strings têm um método útil chamado `contains` que faz isso por nós!
Adicione uma chamada a `contains` dentro da função `search`, como mostrado na
Listagem 12-18. Observe que isso ainda não compilará.

<Listing number="12-18" file-name="src/lib.rs" caption="Adicionando funcionalidade para verificar se a linha contém a string em `query`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-18/src/lib.rs:here}}
```

</Listing>

No momento, estamos construindo a funcionalidade aos poucos. Para fazer o
código compilar, precisamos devolver um valor do corpo da função, como
dissemos que faríamos na assinatura.

#### Armazenando as Linhas Correspondentes

Para concluir essa função, precisamos de uma maneira de armazenar as linhas
correspondentes que queremos retornar. Para isso, podemos criar um vetor
mutável antes do laço `for` e chamar `push` para armazenar `line` nesse vetor.
Depois do laço `for`, retornamos o vetor, como mostrado na Listagem 12-19.

<Listing number="12-19" file-name="src/lib.rs" caption="Armazenando as linhas correspondentes para que possamos retorná-las">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-19/src/lib.rs:here}}
```

</Listing>

Agora a função `search` deverá retornar apenas as linhas que contêm `query`, e
nosso teste deverá passar. Vamos executá-lo:

```console
{{#include ../listings/ch12-an-io-project/listing-12-19/output.txt}}
```

Nosso teste passou, então sabemos que isso funciona!

Neste ponto, poderíamos considerar oportunidades de refatoração da
implementação da função `search`, mantendo os testes passando para preservar a
mesma funcionalidade. O código da função `search` não está ruim, mas ainda não
aproveita alguns recursos úteis dos iteradores. Voltaremos a esse exemplo no
[Capítulo 13][ch13-iterators]<!-- ignore -->, quando explorarmos iteradores em
detalhe e virmos como melhorá-lo.

Agora o programa inteiro deve funcionar! Vamos experimentá-lo, primeiro com uma
palavra que deve retornar exatamente uma linha do poema de Emily Dickinson:
_frog_.

```console
{{#include ../listings/ch12-an-io-project/no-listing-02-using-search-in-run/output.txt}}
```

Muito bom! Agora vamos tentar uma palavra que corresponda a várias linhas, como
_body_:

```console
{{#include ../listings/ch12-an-io-project/output-only-03-multiple-matches/output.txt}}
```

E, por fim, vamos verificar se não obtemos nenhuma linha quando procuramos por
uma palavra que não aparece em nenhum lugar do poema, como
_monomorphization_:

```console
{{#include ../listings/ch12-an-io-project/output-only-04-no-matches/output.txt}}
```

Excelente! Construímos nossa própria versão reduzida de uma ferramenta
clássica e aprendemos bastante sobre como estruturar aplicações. Também
aprendemos um pouco sobre entrada e saída de arquivos, lifetimes, testes e
análise de argumentos de linha de comando.

Para completar este projeto, demonstraremos brevemente como trabalhar com
variáveis de ambiente e como imprimir em stderr, ambos recursos úteis ao
escrever programas de linha de comando.

[validating-references-with-lifetimes]: ch10-03-lifetime-syntax.html#validating-references-with-lifetimes
[ch11-anatomy]: ch11-01-writing-tests.html#the-anatomy-of-a-test-function
[ch10-lifetimes]: ch10-03-lifetime-syntax.html
[ch3-iter]: ch03-05-control-flow.html#looping-through-a-collection-with-for
[ch13-iterators]: ch13-02-iterators.html
