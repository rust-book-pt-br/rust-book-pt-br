<!-- Old headings. Do not remove or links may break. -->

<a id="extensible-concurrency-with-the-sync-and-send-traits"></a>
<a id="extensible-concurrency-with-the-send-and-sync-traits"></a>

## Simultaneidade extensível com `Send` e `Sync`

Curiosamente, quase todos os recursos de simultaneidade dos quais falamos até agora
este capítulo faz parte da biblioteca padrão, não da linguagem. Seu
as opções para lidar com a simultaneidade não estão limitadas ao idioma ou ao
biblioteca padrão; você pode escrever seus próprios recursos de simultaneidade ou usá-los
escrito por outros.

No entanto, entre os principais conceitos de simultaneidade incorporados na linguagem
em vez da biblioteca padrão estão `std::marker` traits `Send` e `Sync`.

<!-- Old headings. Do not remove or links may break. -->

<a id="allowing-transference-of-ownership-between-threads-with-send"></a>

### Transferindo ownership entre threads

O marcador `Send` trait indica que ownership de valores do tipo
implementação de `Send` pode ser transferida entre threads. Quase todos os tipos de Rust
implementa `Send`, mas há algumas exceções, incluindo ` Rc<T>`: Este
não é possível implementar ` Send`porque se você clonou um valor ` Rc<T>`e tentou
transferir ownership do clone para outro thread, ambos threads podem atualizar
a contagem de referência ao mesmo tempo. Por esta razão, ` Rc<T>`é implementado
para uso em situações de thread único em que você não deseja pagar o
Penalidade de desempenho seguro do thread.

Portanto, o sistema de tipos de Rust e os limites de trait garantem que você nunca poderá
enviar acidentalmente um valor `Rc<T>` através do threads de forma insegura. Quando tentamos fazer
isso na Listagem 16-14, obtivemos o erro de que a trait `Send` não está
implementada para `Rc<Mutex<i32>>`. Quando mudamos para `Arc<T>`, que
implementa `Send`, o código passou a compilar.

Qualquer tipo composto inteiramente de tipos `Send` é automaticamente marcado como `Send` como
bem. Quase todos os tipos primitivos são `Send`, exceto os ponteiros brutos, que
discutiremos no Capítulo 20.

<!-- Old headings. Do not remove or links may break. -->

<a id="allowing-access-from-multiple-threads-with-sync"></a>

### Acessando de vários threads

O marcador `Sync` trait indica que é seguro para o tipo que implementa
`Sync ` a ser referenciado a partir de vários threads. Em outras palavras, qualquer tipo`T `
implementa` Sync `se` &T `(uma referência imutável a` T `) implementa` Send `,
o que significa que a referência pode ser enviada com segurança para outro thread. Semelhante a` Send `,
todos os tipos primitivos implementam` Sync `, e tipos compostos inteiramente de tipos que
implementar` Sync `também implementar` Sync`.

O smart pointer `Rc<T>` também não implementa `Sync` pelos mesmos motivos
que não implementa `Send`. O tipo ` RefCell<T>`(do qual falamos
no Capítulo 15) e a família de tipos ` Cell<T>`relacionados não implementam
` Sync `. A implementação da verificação de borrowing que` RefCell<T> `faz em tempo de execução
não é seguro para thread. O smart pointer` Mutex<T> `implementa` Sync `e pode ser
usado para compartilhar acesso com vários threads, como você viu em [“Acesso compartilhado a
` Mutex<T>`”][shared-access]<!-- ignore -->.

### Implementar `Send` e `Sync` manualmente não é seguro

Como os tipos compostos inteiramente por outros tipos que implementam o `Send` e
`Sync ` traits também implementa automaticamente`Send ` e`Sync`, não precisamos
implemente esses traits manualmente. Como marcador traits, eles nem possuem
métodos a implementar. Eles são úteis apenas para impor invariantes relacionados a
simultaneidade.

A implementação manual desses traits envolve a implementação de código Rust inseguro.
Falaremos sobre o uso de código Rust inseguro no Capítulo 20; por enquanto, o importante
A informação é que a construção de novos tipos simultâneos não compostos de `Send` e
As peças `Sync` requerem uma reflexão cuidadosa para manter as garantias de segurança. [“O
Rustonomicon”][nomicon] tem mais informações sobre essas garantias e como
defendê-los.

## Resumo

Esta não é a última vez que você verá concorrência neste livro: O próximo capítulo
concentra-se na programação async, e o projeto no Capítulo 21 usará o
conceitos deste capítulo em uma situação mais realista do que os conceitos menores
exemplos discutidos aqui.

Como mencionado anteriormente, porque muito pouco de como o Rust lida com a simultaneidade é
parte da linguagem, muitas soluções de simultaneidade são implementadas como crates.
Eles evoluem mais rapidamente do que a biblioteca padrão, portanto, pesquise
online para o crates atual e de última geração para uso em multithread
situações.

A biblioteca padrão Rust fornece canais para passagem de mensagens e troca inteligente
tipos de ponteiro, como `Mutex<T>` e `Arc<T>`, que são seguros para uso em
contextos simultâneos. O sistema de tipos e o borrow checker garantem que o
o código que usa essas soluções não resultará em corridas de dados ou referências inválidas.
Depois de compilar seu código, você pode ter certeza de que ele será felizmente
executado em vários threads sem os tipos de bugs difíceis de rastrear comuns em
outras línguas. A programação simultânea não é mais um conceito a temer:
Vá em frente e faça seus programas simultâneos, sem medo!

[shared-access]: ch16-03-shared-state.html#shared-access-to-mutext
[nomicon]: ../nomicon/index.html
