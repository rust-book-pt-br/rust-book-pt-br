# Enums e correspondência de padrões

Neste capítulo, veremos enumerações, também chamadas de _enums_.
Enums permitem definir um tipo enumerando suas possíveis variantes. Primeiro
definiremos e usaremos um enum para mostrar como um enum pode codificar significado junto com
dados. A seguir, exploraremos um enum particularmente útil, chamado `Option`, que
expressa que um valor pode ser algo ou nada. Então, veremos
como a correspondência de padrões na expressão `match` facilita a execução de diferentes
código para diferentes valores de um enum. Por fim, abordaremos como o `if let`
construct é outro idioma conveniente e conciso disponível para lidar com enums em
seu código.
