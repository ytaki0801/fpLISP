# fpLISP: A minimum LISP interpreter for functional programming

This project is aimed to define a minimum specification of LISP interpreter implementations for fun, education or research of functional programming.

## Current Language Specification

It is mostly a subset of Scheme except built-in function naming convention and lack of global environment. It means that just one S-expression is supposed to be run.

* Special forms
	* `quote`: same as single quotation
	* `lambda`: with lexical scope and Lisp-1
	* `if`
* Built-in functions for lists
	* `cons` `car` `cdr` `eq` `atom`
* Built-in functions for numbers
	* `+` `-` `*` `/` `%` `lt`
* Boolean values
	* `t`: true
	* `nil`: false, also as empty set

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
 '(x y z) '(a b c))

=> (x y z a b c)
```

* Generate Fibonacci sequence until 21th
```
((lambda (rev fib)
   (rev (fib 21 0 1 nil) nil))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (x y)
      (if (eq x nil) y
           ((u u) (cdr x) (cons (car x) y))))))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (n a b r)
      (if (eq n 0) (cons a r)
           ((u u) (- n 1) b (+ a b) (cons a r)))))))

=> (0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)
```

See `samples` directory for more sample codes.

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

