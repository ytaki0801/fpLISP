# fpLISP in Common Lisp

You can execute fpLISP codes by using a Commin Lisp processor like [SBCL](http://www.sbcl.org/) or [ECL](https://common-lisp.net/project/ecl/), as the following:

```
$ cat ../samples/12-sublis.fplisp 
((lambda (assoc sublis al L)
   (sublis al L assoc))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (k vs)
      (if (eq vs '()) '()
          (if (eq (car (car vs)) k)
              (car vs)
              ((u u) k (cdr vs)))))))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (al L assoc)
      (if (eq L '()) '()
          (cons
            (if (atom (car L))
                ((lambda (r)
                   (if (eq r '())
                       (car L) (cdr r)))
                 (assoc (car L) al))
                ((u u) al (car L) assoc))
            ((u u) al (cdr L) assoc))))))
 '((X . John) (Y . Mary))
 '((Jim aka X) likes Y))

$ sbcl --script fpLISP.lisp < ../samples/12-sublis.fplisp 
((Jim aka John) likes Mary)
$ ecl --shell fpLISP.lisp < ../samples/12-sublis.fplisp 
((Jim aka John) likes Mary)
```

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
