# Ninety-Nine Problems derived from [L-99](https://www.ic.unicamp.br/~meidanis/courses/mc336/2006s2/funcional/L-99_Ninety-Nine_Lisp_Problems.html)

These codes are mostly derived from L-99 sample codes, some are written from scratch. fpLISP has no global environment so the codes have the following coding style:
```lisp:fpLISP
((lambda (DEFINED_FUNCTION)
   (DEFINED_FUNCTION Values_of_the_Arguments))
 (...))
```
And many `let`- and `list`-equivalent codes are used by `lambda` as the following:
```lisp:fpLISP
(let ((A1 V1) (A2 V2) ... (An Vn)) ...)
=> ((lambda (A1 A2 ... An) ...) V1 V2 ... Vn)

(list V1 V2 ... Vn)
=> ((lambda x x) V1 V2 ... Vn)
```

* P01: Find the last box of a list.
* P02: Find the last but one box of a list.
* P03: Find the K'th element of a list.
* P04: Find the number of elements of a list.
* P05: Reverse a list.
* P06: Find out whether a list is a palindrome.
* P07: Flatten a nested list structure.
* P08: Eliminate consecutive duplicates of list elements.
* P09: Pack consecutive duplicates of list elements into sublists.
* P10: Run-length encoding of a list.
* P11: Modified run-length encoding.
* P12: Decode a run-length encoded list.
* P13: Run-length encoding of a list (direct solution).
* P14: Duplicate the elements of a list.

## License

(C) 2021 TAKIZAWA Yozo

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

