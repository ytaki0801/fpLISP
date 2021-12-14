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

(let ((*readtable* (copy-readtable nil)))
  (setf (readtable-case *readtable*) :preserve)
  (princ (fp_eval (read) nil)) (terpri))

