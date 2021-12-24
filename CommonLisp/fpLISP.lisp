;;;;
;;;; fpLISP.lisp: fpLISP in Common Lisp
;;;;
;;;; (C) 2021 TAKIZAWA Yozo
;;;; This code is licensed under CC0.
;;;; https://creativecommons.org/publicdomain/zero/1.0/
;;;;

;;;; Define built-in functions
(defparameter fp_builtins
  `((|cons| . cons) (|car| . car) (|cdr| . cdr)
    (|eq| . equalp) (|atom| . atom) (|lt| . <)
    (+ . +) (- . -) (* . *) (% . rem)
    (/ . ,(lambda (x y) (multiple-value-bind (q r) (truncate x y) q)))))

;;;; Apply a function with arguments for a lambda expression
;;;; and built-in functions
(defun fp_apply (f v)
  (cond ((atom f) (apply (cdr (assoc f fp_builtins)) v))
        (t (cond ((eq (car f) '|lambda|)
                  ; Eval body of a lambda expression in local env
                  ; made from variables, values and closure env
                  (let ((lvars (cadr f)))
                    (fp_eval
                       (caddr f)
                       (append (cond ((atom lvars) `(,(cons lvars v)))
                                     (t (mapcar 'cons lvars v)))
                               (cadddr f)))))
                 (t nil)))))

;;;; Look up value for a name
(defun fp_lookup (token a)
  (cond ((eq token '|t|) t) ((eq token '|nil|) nil)
        ((or (member token (mapcar 'car fp_builtins))
             (numberp token)) token)
        (t (cdr (assoc token a)))))

;;;; Eval S-expression with local environment
(defun fp_eval (e a)
  (cond ((atom e) (fp_lookup e a))
        ((or (eq (car e) '|quote|) (eq (car e) 'quote))
         (let ((r (cadr e))) (if (eq r '|nil|) nil r)))
        ((eq (car e) '|if|)
         (if (fp_eval (cadr e) a)
             (fp_eval (caddr e) a) (fp_eval (cadddr e) a)))
        ((eq (car e) '|lambda|) (append e `(,a)))
        (t (fp_apply (fp_eval (car e) a)
                     (mapcar (lambda (x) (fp_eval x a)) (cdr e))))))

(defparameter INITENV
 "((unfold . (lambda a
               ((lambda (f seed i)
                  (((lambda (u) (u u)) (lambda (u) (lambda (e r)
                      (if (eq e nil) r
                          ((u u) (f (car e)) (cons (cdr e) r))))))
                   (f seed) (if (eq i nil) nil (car i))))
                (car a) (car (cdr a)) (cdr (cdr a)))))
   (fold .   (lambda x
               ((lambda (f i0 a0 b0)
                  (((lambda (u) (u u)) (lambda (u) (lambda (i a b)
                      (if (eq a nil) i
                      (if (eq b nil)
                          ((u u) (f i (car a)) (cdr a) b)
                          ((u u) (f i (car a) (car b))
                                 (cdr a) (cdr b)))))))
                   i0 a0 (if (eq b0 nil) nil (car b0))))
                (car x) (car (cdr x)) (car (cdr (cdr x)))
                (cdr (cdr (cdr x)))))))")

(let ((*readtable* (copy-readtable nil)))
  (setf (readtable-case *readtable*) :preserve)
  (princ (fp_eval (read) (read-from-string INITENV))) (terpri))

