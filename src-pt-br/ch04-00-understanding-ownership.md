# Entendendo Ownership

Ownership é o recurso mais característico do Rust e tem implicações profundas
em todo o restante da linguagem. É ele que permite ao Rust oferecer garantias
de segurança de memória sem precisar de um garbage collector, por isso é
importante entender como ownership funciona. Neste capítulo, falaremos sobre
ownership e também sobre recursos relacionados: empréstimos, slices e a forma
como o Rust organiza dados na memória.
