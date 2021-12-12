# fpLISP in fpLISP as a Meta-Circular Evaluator

This code is a fpLISP interpreter defined by fpLISP, as a Meta-Circular Evaluator, including sample fpLISP code FizzBuzz for the evaluator because fpLISP has no built-in standard input function. Please note that numbers in sample fpLISP code must be quoted because fpLISP has no built-in number check function, too.

```
$ head -16 fpLISP-FizzBuzz.fplisp 
((lambda (eval)
   (eval (quote
     (((lambda (u) (u u))
         (lambda (u)
           (lambda (x r)
             (if (eq x (quote 0)) r
             (if (eq (% x (quote 15)) (quote 0))
                 ((u u) (- x (quote 1)) (cons (quote FizzBuzz) r))
             (if (eq (% x (quote 3)) (quote 0))
                 ((u u) (- x (quote 1)) (cons (quote Fizz) r))
             (if (eq (% x (quote 5)) (quote 0))
                 ((u u) (- x (quote 1)) (cons (quote Buzz) r))
                 ((u u) (- x (quote 1)) (cons x r)))))))))
        (quote 50) nil)
     ) nil))
 (lambda (e a)
$ nodejs ../JavaScript/fpLISP.js fpLISP-FizzBuzz.fplisp 
(1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz 16 17 Fizz 19 Buzz Fizz 22 23 Fizz Buzz 26 Fizz 28 29 FizzBuzz 31 32 Fizz 34 Buzz Fizz 37 38 Fizz Buzz 41 Fizz 43 44 FizzBuzz 46 47 Fizz 49 Buzz)
$ gosh ../Scheme/fpLISP.scm < fpLISP-FizzBuzz.fplisp 
(1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz 16 17 Fizz 19 Buzz Fizz 22 23 Fizz Buzz 26 Fizz 28 29 FizzBuzz 31 32 Fizz 34 Buzz Fizz 37 38 Fizz Buzz 41 Fizz 43 44 FizzBuzz 46 47 Fizz 49 Buzz)
$ head -10 fpLISP-fibonacci.fplisp 
((lambda (eval)
   (eval (quote
     (((lambda (u) (u u))
       (lambda (u)
         (lambda (n a b)
           (if (lt n (quote 0)) nil
               (cons a ((u u) (- n (quote 1)) b (+ a b)))))))
      (quote 21) (quote 0) (quote 1))
     ) nil))
 (lambda (e a)
$ nodejs ../JavaScript/fpLISP.js fpLISP-fibonacci.fplisp 
(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)
$ gosh ../Scheme/fpLISP.scm < fpLISP-fibonacci.fplisp 
(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)
```

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
