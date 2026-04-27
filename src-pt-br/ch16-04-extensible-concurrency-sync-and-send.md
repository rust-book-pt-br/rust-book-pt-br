<!-- Old headings. Do not remove or links may break. -->

<a id="extensible-concurrency-with-the-sync-and-send-traits"></a>
<a id="extensible-concurrency-with-the-send-and-sync-traits"></a>

## Concorrência Extensível com `Send` e `Sync`

Curiosamente, quase todos os recursos de concorrência dos quais falamos até agora
neste capítulo fazem parte da biblioteca padrão, não da linguagem. Suas
opções para lidar com concorrência não estão limitadas à linguagem nem à
biblioteca padrão; você pode escrever seus próprios recursos de concorrência ou
usar aqueles escritos por outras pessoas.

No entanto, entre os principais conceitos de concorrência incorporados à linguagem,
em vez de à biblioteca padrão, estão as traits `Send` e `Sync` de `std::marker`.

<!-- Old headings. Do not remove or links may break. -->

<a id="allowing-transference-of-ownership-between-threads-with-send"></a>

### Transferindo Ownership Entre Threads

A trait marcadora `Send` indica que o ownership de valores do tipo que
implementa `Send` pode ser transferido entre threads. Quase todos os tipos de Rust
implementam `Send`, mas há algumas exceções, incluindo `Rc<T>`: ele
não pode implementar `Send` porque, se você clonasse um valor `Rc<T>` e tentasse
transferir o ownership do clone para outra thread, ambas as threads poderiam atualizar
a contagem de referências ao mesmo tempo. Por essa razão, `Rc<T>` é implementado
para uso em situações single-threaded, em que você não quer pagar a penalidade
de desempenho da thread safety.

Portanto, o sistema de tipos de Rust e os trait bounds garantem que você nunca
possa enviar acidentalmente um valor `Rc<T>` entre threads de forma insegura.
Quando tentamos fazer isso na Listagem 16-14, obtivemos o erro de que a trait
`Send` não está implementada para `Rc<Mutex<i32>>`. Quando mudamos para `Arc<T>`, que
implementa `Send`, o código passou a compilar.

Qualquer tipo composto inteiramente por tipos `Send` também é automaticamente marcado como `Send`.
Quase todos os tipos primitivos são `Send`, exceto os ponteiros brutos, que
discutiremos no Capítulo 20.

<!-- Old headings. Do not remove or links may break. -->

<a id="allowing-access-from-multiple-threads-with-sync"></a>

### Acessando a Partir de Múltiplas Threads

A trait marcadora `Sync` indica que é seguro que o tipo que implementa
`Sync` seja referenciado a partir de múltiplas threads. Em outras palavras,
qualquer tipo `T` implementa `Sync` se `&T` (uma referência imutável a `T`)
implementa `Send`, o que significa que a referência pode ser enviada com
segurança para outra thread. Assim como `Send`, todos os tipos primitivos
implementam `Sync`, e tipos compostos inteiramente por tipos que implementam
`Sync` também implementam `Sync`.

O smart pointer `Rc<T>` também não implementa `Sync` pelos mesmos motivos
pelos quais não implementa `Send`. O tipo `RefCell<T>` (do qual falamos
no Capítulo 15) e a família de tipos `Cell<T>` relacionada não implementam
`Sync`. A implementação de verificação de borrowing que `RefCell<T>` faz em
tempo de execução não é thread-safe. O smart pointer `Mutex<T>` implementa
`Sync` e pode ser usado para compartilhar acesso com múltiplas threads, como
você viu em [“Acesso Compartilhado a `Mutex<T>`”][shared-access]<!-- ignore
-->.

### Implementar `Send` e `Sync` Manualmente é Unsafe

Como os tipos compostos inteiramente por outros tipos que implementam as traits `Send` e
`Sync` também implementam automaticamente `Send` e `Sync`, não precisamos
implementar essas traits manualmente. Como traits marcadoras, elas nem sequer possuem
métodos a implementar. Elas são úteis apenas para impor invariantes relacionados à
concorrência.

A implementação manual dessas traits envolve implementar código Rust unsafe.
Falaremos sobre o uso de código Rust unsafe no Capítulo 20; por enquanto, a
informação importante é que construir novos tipos concorrentes que não sejam
compostos por partes `Send` e `Sync` requer reflexão cuidadosa para preservar
as garantias de segurança. [“O Rustonomicon”][nomicon] tem mais informações
sobre essas garantias e sobre como preservá-las.

## Resumo

Esta não é a última vez que você verá concorrência neste livro: o próximo capítulo
se concentra em programação async, e o projeto do Capítulo 21 usará os
conceitos deste capítulo em uma situação mais realista do que os exemplos menores
discutidos aqui.

Como mencionado anteriormente, como muito pouco da forma como Rust lida com
concorrência faz parte da linguagem, muitas soluções de concorrência são
implementadas como crates. Elas evoluem mais rapidamente do que a biblioteca
padrão, portanto pesquise online pelos crates atuais e de ponta para usar em
situações multithreaded.

A biblioteca padrão do Rust fornece canais para passagem de mensagens e tipos de
smart pointer, como `Mutex<T>` e `Arc<T>`, que são seguros para uso em
contextos concorrentes. O sistema de tipos e o borrow checker garantem que o
código que usa essas soluções não resultará em corridas de dados nem em referências inválidas.
Depois de compilar seu código, você pode ter certeza de que ele rodará
tranquilamente em múltiplas threads sem os tipos de bugs difíceis de rastrear
comuns em outras linguagens. Programação concorrente não é mais um conceito a temer:
vá em frente e faça seus programas concorrentes, sem medo!

[shared-access]: ch16-03-shared-state.html#shared-access-to-mutext
[nomicon]: ../nomicon/index.html
