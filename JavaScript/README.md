# fpLISP in JavaScript

You can execute fpLISP codes by using Web browser through the HTML file `pfLISP.html' and by using Node.js to specify a fpLISP code file.
```
$ cat ../samples/append.fplisp
((lambda (func a b) (func (func a '()) b))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (x y)
      (if (eq x '()) y
          ((u u) (cdr x) (cons (car x) y))))))
 '(x y z) '(a b c))

$ node fpLISP.js ../samples/append.fplisp
(x y z a b c)
```

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

