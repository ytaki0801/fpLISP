# fpLISP in POSIX-conformant Shell

This is derived from [`PureLISP.sh`](https://github.com/ytaki0801/PureLISP.sh) to fit the fpLISP language specification. Please note that numbers are limited to integers and just one blank line is needed to evaluate just one nested S-expression.

It is POSIX conformat so you can execute fpLISP codes not only in Bash but also in dash, BusyBox ash, ksh and other POSIX shells, like the following on [busybox-w32](https://frippery.org/busybox/) in Windows 10 Command Prompt.
```
>type ..\samples\03-fibonacci.fplisp
(((lambda (u) (u u))
  (lambda (u)
    (lambda (n a b)
      (if (lt n 0) nil
          (cons a ((u u) (- n 1) b (+ a b)))))))
 21 0 1)


>busybox sh fpLISP.sh < ..\samples\fibonacci.fplisp
(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946)

>
```
You can also run the fpLISP.sh in [Termux](https://termux.com/) or [TermOne Plus](https://termoneplus.com/) on Android which has sh and curl by default, like the following.
```
$ curl -sO https://raw.githubusercontent.com/ytaki0801/fpLISP/master/POSIX-Shell/fpLISP.sh
$ sh fpLISP.sh
(cons 10 20)

(10 . 20)
$ curl -s https://raw.githubusercontent.com/ytaki0801/fpLISP/master/samples/13-pattern-matching.fplisp | sh fpLISP.sh
((X needs a . Y) (john needs a big cake) (a (big cake) is needed by john))
```

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

