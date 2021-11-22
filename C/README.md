# fpLISP in C

The C version of fpLISP is ISO C99 conformat so you can compile and run it not only by GCC on UNIX but also [TCC](https://bellard.org/tcc/) on Windows, like the following in Windows 10 Command Prompt.

```
>tcc fpLISP.c

>type ..\samples\FizzBuzz.fplisp
((lambda (and FB) (FB 50 '() and))
 (lambda (a b) (if a b nil))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (x r and)
      (if (eq x 0) r
          (if (and (eq (% x 3) 0) (eq (% x 5) 0))
              ((u u) (- x 1) (cons 'FizzBuzz r) and)
              (if (eq (% x 3) 0)
                  ((u u) (- x 1) (cons 'Fizz r) and)
                  (if (eq (% x 5) 0)
                      ((u u) (- x 1) (cons 'Buzz r) and)
                      ((u u) (- x 1) (cons x r) and)))))))))


>fpLISP < ..\samples\FizzBuzz.fplisp
(1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz 16 17 Fizz 19 Buzz Fizz 22 23 Fizz Buzz 26 Fizz 28 29 FizzBuzz 31 32 Fizz 34 Buzz Fizz 37 38 Fizz Buzz 41 Fizz 43 44 FizzBuzz 46 47 Fizz 49 Buzz)

>
```
Note that numbers are limited to integers, and EOF code is needed to evaluate after just one S-expression.

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
