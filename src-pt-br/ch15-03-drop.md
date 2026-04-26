## Executando Código na Limpeza com a Trait `Drop`

A segunda trait importante para o padrão de ponteiro inteligente é `Drop`, que
permite personalizar o que acontece quando um valor está prestes a sair de
escopo. Você pode fornecer uma implementação da trait `Drop` para qualquer
tipo, e esse código pode ser usado para liberar recursos como arquivos ou
conexões de rede.

Estamos introduzindo `Drop` no contexto de ponteiros inteligentes porque a
funcionalidade da trait `Drop` quase sempre é usada ao implementar um ponteiro
inteligente. Por exemplo, quando um `Box<T>` é descartado, ele desaloca o
espaço no heap para o qual o box aponta.

Em algumas linguagens, para alguns tipos, a pessoa programadora precisa chamar
código para liberar memória ou recursos toda vez que termina de usar uma
instância desses tipos. Exemplos incluem handles de arquivos, sockets e locks.
Se a pessoa esquecer, o sistema pode ficar sobrecarregado e travar. Em Rust,
você pode especificar que um determinado trecho de código seja executado sempre
que um valor sai de escopo, e o compilador inserirá esse código
automaticamente. Como resultado, você não precisa tomar cuidado para colocar
código de limpeza em todos os lugares de um programa em que uma instância de um
tipo específico deixa de ser usada; ainda assim, você não vazará recursos!

Você especifica o código a ser executado quando um valor sai de escopo
implementando a trait `Drop`. A trait `Drop` exige que você implemente um
método chamado `drop`, que recebe uma referência mutável para `self`. Para ver
quando Rust chama `drop`, vamos implementar `drop` com instruções `println!`
por enquanto.

A Listagem 15-14 mostra uma struct `CustomSmartPointer` cuja única
funcionalidade personalizada é imprimir `Dropping CustomSmartPointer!` quando a
instância sai de escopo, para mostrar quando Rust executa o método `drop`.

<Listing number="15-14" file-name="src/main.rs" caption="Uma struct `CustomSmartPointer` que implementa a trait `Drop`, onde colocaríamos nosso código de limpeza">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-14/src/main.rs}}
```

</Listing>

A trait `Drop` está incluída no prelude, então não precisamos trazê-la para o
escopo. Implementamos a trait `Drop` em `CustomSmartPointer` e fornecemos uma
implementação para o método `drop` que chama `println!`. O corpo do método
`drop` é onde você colocaria qualquer lógica que quisesse executar quando uma
instância do seu tipo sai de escopo. Estamos imprimindo algum texto aqui para
demonstrar visualmente quando Rust chamará `drop`.

Em `main`, criamos duas instâncias de `CustomSmartPointer` e então imprimimos
`CustomSmartPointers created`. No final de `main`, nossas instâncias de
`CustomSmartPointer` sairão de escopo, e Rust chamará o código que colocamos no
método `drop`, imprimindo nossa mensagem final. Observe que não precisamos
chamar o método `drop` explicitamente.

Quando executarmos esse programa, veremos a seguinte saída:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-14/output.txt}}
```

Rust chamou `drop` automaticamente para nós quando nossas instâncias saíram de
escopo, chamando o código que especificamos. Variáveis são descartadas na ordem
inversa à de sua criação, então `d` foi descartada antes de `c`. O propósito
desse exemplo é dar a você um guia visual de como o método `drop` funciona;
normalmente, você especificaria o código de limpeza que seu tipo precisa
executar em vez de uma mensagem impressa.

<!-- Old headings. Do not remove or links may break. -->

<a id="dropping-a-value-early-with-std-mem-drop"></a>

Infelizmente, não é simples desabilitar a funcionalidade automática de `drop`.
Desabilitar `drop` geralmente não é necessário; o ponto da trait `Drop` é que
isso seja cuidado automaticamente. Ocasionalmente, porém, talvez você queira
limpar um valor mais cedo. Um exemplo é ao usar ponteiros inteligentes que
gerenciam locks: talvez você queira forçar o método `drop` que libera o lock
para que outro código no mesmo escopo possa adquirir o lock. Rust não permite
chamar manualmente o método `drop` da trait `Drop`; em vez disso, você precisa
chamar a função `std::mem::drop`, fornecida pela biblioteca padrão, se quiser
forçar um valor a ser descartado antes do fim de seu escopo.

Tentar chamar manualmente o método `drop` da trait `Drop` modificando a função
`main` da Listagem 15-14 não funcionará, como mostrado na Listagem 15-15.

<Listing number="15-15" file-name="src/main.rs" caption="Tentando chamar manualmente o método `drop` da trait `Drop` para limpar cedo">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-15/src/main.rs:here}}
```

</Listing>

Quando tentarmos compilar esse código, receberemos este erro:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-15/output.txt}}
```

Essa mensagem de erro afirma que não temos permissão para chamar `drop`
explicitamente. A mensagem de erro usa o termo _destructor_, que é o termo
geral em programação para uma função que limpa uma instância. Um _destructor_ é
análogo a um _constructor_, que cria uma instância. A função `drop` em Rust é
um destrutor específico.

Rust não permite que chamemos `drop` explicitamente porque Rust ainda chamaria
`drop` automaticamente no valor ao final de `main`. Isso causaria um erro de
_double free_, porque Rust tentaria limpar o mesmo valor duas vezes.

Não podemos desabilitar a inserção automática de `drop` quando um valor sai de
escopo, e não podemos chamar o método `drop` explicitamente. Portanto, se
precisarmos forçar um valor a ser limpo mais cedo, usamos a função
`std::mem::drop`.

A função `std::mem::drop` é diferente do método `drop` na trait `Drop`. Nós a
chamamos passando como argumento o valor que queremos forçar a descartar. A
função está no prelude, então podemos modificar `main` na Listagem 15-15 para
chamar a função `drop`, como mostrado na Listagem 15-16.

<Listing number="15-16" file-name="src/main.rs" caption="Chamando `std::mem::drop` para descartar explicitamente um valor antes que ele saia de escopo">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-16/src/main.rs:here}}
```

</Listing>

Executar esse código imprimirá o seguinte:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-16/output.txt}}
```

O texto ``Dropping CustomSmartPointer with data `some data`!`` é impresso entre
o texto `CustomSmartPointer created` e `CustomSmartPointer dropped before the
end of main`, mostrando que o código do método `drop` é chamado para descartar
`c` naquele ponto.

Você pode usar o código especificado em uma implementação da trait `Drop` de
várias formas para tornar a limpeza conveniente e segura: por exemplo, poderia
usá-lo para criar seu próprio alocador de memória! Com a trait `Drop` e o
sistema de ownership de Rust, você não precisa se lembrar de limpar, porque
Rust faz isso automaticamente.

Você também não precisa se preocupar com problemas resultantes de limpar
acidentalmente valores ainda em uso: o sistema de ownership que garante que
referências sejam sempre válidas também garante que `drop` seja chamado apenas
uma vez quando o valor não está mais sendo usado.

Agora que examinamos `Box<T>` e algumas das características de ponteiros
inteligentes, vamos olhar para alguns outros ponteiros inteligentes definidos
na biblioteca padrão.
