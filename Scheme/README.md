# fpLISP in Scheme

You can execute fpLISP codes by using a Scheme language processor like [Gauche](http://practical-scheme.net/gauche/), [GNU Guile](https://www.gnu.org/software/guile/), [Chibi-Scheme](http://synthcode.com/wiki/chibi-scheme), [SCM](https://people.csail.mit.edu/jaffer/SCM.html) or [MIT/GNU Scheme](https://www.gnu.org/software/mit-scheme/) as the following:

```
$ cat ../samples/12-sublis.fplisp 
((lambda (assoc sublis al L)
   (sublis al L assoc))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (k vs)
      (if (eq vs nil) nil
          (if (eq (car (car vs)) k)
              (car vs)
              ((u u) k (cdr vs)))))))
 ((lambda (u) (u u))
  (lambda (u)
    (lambda (al L assoc)
      (if (eq L nil) nil
          (cons
            (if (atom (car L))
                ((lambda (r)
                   (if (eq r nil)
                       (car L) (cdr r)))
                 (assoc (car L) al))
                ((u u) al (car L) assoc))
            ((u u) al (cdr L) assoc))))))
 (quote ((X . John) (Y . Mary)))
 (quote ((Jim aka X) likes Y)))

$ cat ../samples/12-sublis.fplisp | gosh fpLISP.scm
((Jim aka John) likes Mary)
$ cat ../samples/12-sublis.fplisp | guile fpLISP.scm
((Jim aka John) likes Mary)
$ cat ../samples/12-sublis.fplisp | chibi-scheme -m chibi fpLISP.scm
((Jim aka John) likes Mary)
```

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
