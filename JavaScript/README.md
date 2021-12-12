# fpLISP in JavaScript

You can execute fpLISP codes by using Web browser through the HTML file like [`pfLISP.html`](https://ytaki0801.github.io/fpLISP.html) and by using Node.js with a fpLISP code file like the following.
```
$ cat ../samples/07-append.fplisp
((lambda (f a b) (f (f a nil) b))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (x y)
      (if (eq x nil) y
          ((u u) (cdr x) (cons (car x) y))))))
 (quote (x y z)) (quote (a b c)))

$ node fpLISP.js ../samples/append.fplisp
(x y z a b c)
```

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

