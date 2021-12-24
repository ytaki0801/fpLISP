;;;;
;;;; fpLISP.scm: fpLISP in Scheme
;;;;
;;;; (C) 2021 TAKIZAWA Yozo
;;;; This code is licensed under CC0.
;;;; https://creativecommons.org/publicdomain/zero/1.0/
;;;;

;;;; Define predicates in the specification of fpLISP
(define (fp_eq x y)
  (let ((NIL `(,#f nil ())) (T `(,#t t)))
    (cond ((and (member x NIL) (member y NIL)) #t)
          ((and (member x T)   (member y T)    #t))
          (else (eq? x y)))))

;;;; Define built-in functions
(define fp_builtins
  `((cons . ,cons) (car . ,car) (cdr . ,cdr) (+ . ,+) (- . ,-) (* . ,*)
    (eq . ,fp_eq) (atom . ,(lambda (x) (not (pair? x)))) (lt . ,<)
    (/ . ,(lambda (x y) (quotient x y))) (% . ,remainder)))
   
;;;; Apply a function with arguments for a lambda expression
;;;; and built-in functions
(define (fp_apply f v)
  (cond ((pair? f)
         (cond ((eq? (car f) 'lambda)
                ; Eval body of a lambda expression in local env
                ; made from variables, values and closure env
                (let ((lvars (cadr f))
                      (lenvs (if (null? (cdddr f)) '() (cadddr f))))
                  (fp_eval
                    (caddr f)
                    (append (cond ((pair? lvars) (map cons lvars v))
                                  (else `(,(cons lvars v))))
                            lenvs))))
               (else #f)))
        (else (apply (cdr (assq f fp_builtins)) v))))

;;;; Look up value for a name
(define (fp_lookup t a)
  (cond ((or (member t (map car fp_builtins))
             (number? t) (eq? t 't) (eq? t 'nil)) t)
        (else (cdr (assq t a)))))

;;;; Eval S-expression with local environment
(define (fp_eval e a)
  (cond ((pair? e)
         (cond ((eq? (car e) 'quote) (cadr e))
               ((eq? (car e) 'if)
                (if (fp_eq (fp_eval (cadr e) a) 'nil)
                    (fp_eval (cadddr e) a) (fp_eval (caddr e) a)))
               ((eq? (car e) 'lambda) (append e `(,a)))
               (else
                 (fp_apply (fp_eval (car e) a)
                           (map (lambda (x) (fp_eval x a)) (cdr e))))))
        (else (fp_lookup e a))))

;;;; Display S-expression by following the specification of fpLISP
(define (fp_strcons s)
  (fp_display (car s))
  (let ((sd (cdr s)))
    (cond ((fp_eq sd 'nil) (display ""))
          ((pair? sd) (display " ") (fp_strcons sd))
          (else (display " . ") (fp_display sd)))))
(define (fp_display s)
  (cond ((fp_eq s #t) (display 't)) ((fp_eq s #f) (display 'nil))
        ((pair? s) (display "(") (fp_strcons s) (display ")"))
        (else (display s))))

(define INITENV
  (quote (
    (unfold . (lambda a
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
                 (cdr (cdr (cdr x)))))))))

(fp_display (fp_eval (read) INITENV))
(newline)

