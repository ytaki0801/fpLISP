# fpLISP in POSIX-conformant Shell

This is derived from [`PureLISP.sh`](https://github.com/ytaki0801/PureLISP.sh) to fit the fpLISP language specification. It is POSIX conformat so you can execute fpLISP codes not only in Bash but also in dash, BusyBox ash, ksh and other POSIX shells, like the following on [busybox-w32](https://frippery.org/busybox/) in Windows 10 Command Prompt.
```
>type ..\samples\fibonacci.fplisp
((lambda (rev fib)
   (rev (fib 21 0 1 '()) '()))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (x y)
      (if (eq x '()) y
           ((u u) (cdr x) (cons (car x) y))))))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (n a b r)
      (if (eq n 0) (cons a r)
           ((u u) (- n 1) b (+ a b) (cons a r)))))))


>busybox sh fpLISP.sh < ..\samples\fibonacci.fplisp
(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)
>
```
Note that numbers are limited to integers, and just one blank line is needed to evaluate just one S-expression.

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

