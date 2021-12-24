# fpLISP: A minimum LISP interpreter for functional programming

This project is aimed to define a minimum specification of LISP interpreter implementations for fun, education or research of functional programming. The following ebook in Japanese is written by referring fpLISP:

『[簡易LISP処理系で体験する関数型プログラミング](http://bit.ly/fpLISP-book)』([Zenn Books](https://zenn.dev/books))

## Current Language Specification

It is mostly a subset of Scheme except built-in function naming convention and lack of global environment. The latter means that just one nested S-expression is supposed to be run. See each language dierctory for reference implementations.

* S-expressions are accepted with parenthesis enclosing, space separating and dot notation for cdr of conscells in quoting lists and displaying values.
* Special forms
	* `lambda` with lexical scope and Lisp-1. Atom variable is supported to implement variable number of arguments. On the other hand, list variable with dot notation is not accepted.
	* `if` as conditional operator. The false-clause must be provided.
	* `quote`
* Built-in functions for list and number processing
	* `cons`, `car`, `cdr` and `atom` for lists
	* `+`, `-`, `*`, `/` as quotient and `%` for numbers
	* `lt` as < for numbers
	* `eq` as = for both lists and numbers
* Boolean values
	* `t` as true
	* `nil` as false and empty set
* Pre-defined functions for list processing (now only in POSIX-Shell and C)
	* `fold` similer to [Prelude.foldl in Haskell](http://zvon.org/other/haskell/Outputprelude/foldl_f.html)
	* `unfold` similer to [Data.Sequence.unfoldl in Haskell](https://hackage.haskell.org/package/containers-0.6.5.1/docs/Data-Sequence.html)

## Sample codes

fpLISP has `lambda` with lexical-scope, no global environment and no loop syntax so [fixed-point combinators](https://en.wikipedia.org/wiki/Fixed-point_combinator) will be used to recur. The following sample codes are using U combinators. See `samples` directory for more sample codes, including [Ninety-Nine Problems](https://www.ic.unicamp.br/~meidanis/courses/mc336/2006s2/funcional/L-99_Ninety-Nine_Lisp_Problems.html).

* Append two lists
```
((lambda (f a b) (f (f a nil) b))
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
((lambda (fibonacci)
   (fibonacci 21))
 (lambda (n)
   (((lambda (u) (u u))
     (lambda (u)
       (lambda (n a b)
         (if (lt n 0) nil
             (cons a ((u u) (- n 1) b (+ a b)))))))
    n 0 1)))

=> (0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)
```


## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

