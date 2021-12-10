# fpLISP: A minimum LISP interpreter for functional programming

This project is aimed to define a minimum specification of LISP interpreter implementations for fun, education or research of functional programming.

The following ebook in Japanese is written by referring fpLISP:

『[簡易LISP処理系で体験する関数型プログラミング](http://bit.ly/fpLISP-book)』([Zenn Books](https://zenn.dev/books))

## Current Language Specification

It is mostly a subset of Scheme except built-in function naming convention and lack of global environment. The latter means that just one nested S-expression is supposed to be run.

* Special forms
	* `lambda` with lexical scope and Lisp-1
	* `if` as conditional operator
        * `quote`
* Built-in functions for list and number processing
	* `cons` `car` `cdr` `atom` for lists
	* `+` `-` `*` `/` `%` for numbers
	* `lt` as < for numbers
	* `eq` as = for both lists and numbers
* Boolean values
	* `t` as true
	* `nil` as false and empty set

See each language dierctory for reference implementations.

## Sample codes

* Append two lists
```
((lambda (func a b) (func (func a nil) b))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (x y)
      (if (eq x nil) y
          ((u u) (cdr x) (cons (car x) y))))))
 (quote (x y z)) (quote (a b c)))

=> (x y z a b c)
```

* Generate Fibonacci sequence until 21th
```
(((lambda (u) (u u))
  (lambda (u)
    (lambda (n a b)
      (if (lt n 0) nil
          (cons a ((u u) (- n 1) b (+ a b)))))))
 21 0 1)

=> (0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)
```

See `samples` directory for more sample codes.

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

