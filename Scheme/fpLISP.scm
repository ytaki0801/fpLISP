;;;;
;;;; fpLISP.scm: fpLISP in Scheme
;;;;
;;;; This code is licensed under CC0.
;;;; https://creativecommons.org/publicdomain/zero/1.0/
;;;;

;;;; Define predicates in the specification of fpLISP
(define (fp_eq x y)
  (let ((NIL `(,#f nil ())) (T `(,#t t)))
    (cond ((and (member x NIL) (member y NIL)) #t)
	  ((and (member x T)   (member y T)    #t))
	  (else (eq? x y)))))
(define (fp_atom x) (not (pair? x)))

;;;; Apply a function with arguments for a lambda expression
;;;; and built-in functions
(define (fp_apply f v)
  (cond ((pair? f)
	 (if (eq? (car f) 'lambda)
	     ; Eval body of a lambda expression in local env
	     ; made from variables, values and closure env
	     (let ((lvars (cadr f)) (lenvs (cadddr f)))
	       (fp_eval
		(caddr f)
		(cond ((null? lvars) lenvs)
		      ((pair? lvars)
		       (append (map cons lvars v) lenvs))
		      (else
		       (append `(,(cons lvars v)) lenvs)))))
	     #f))
	((eq? f 'cons) (cons (car v) (cadr v)))
	((eq? f 'car)  (car (car v)))
	((eq? f 'cdr)  (cdr (car v)))
	((eq? f 'eq)   (fp_eq (car v) (cadr v)))
	((eq? f 'atom) (fp_atom (car v)))
	((eq? f '+)    (+ (car v) (cadr v)))
	((eq? f '-)    (- (car v) (cadr v)))
	((eq? f '*)    (* (car v) (cadr v)))
	((eq? f '/)    (exact->inexact (/ (car v) (cadr v))))
	((eq? f '%)    (remainder (car v) (cadr v)))
	((eq? f 'lt)   (< (car v) (cadr v)))
	(else #f)))

;;;; List of built-in function and Boolean names
(define fp_builtins '(cons car cdr eq atom + - * / % lt t nil))

;;;; Look up value for a name
(define (fp_lookup t a)
  (cond ((or (member t fp_builtins) (number? t)) t)
	(else (cdr (assq t a)))))

;;;; Eval S-expression with local environment
(define (fp_eval e a)
  (cond ((pair? e)
	 (cond ((eq? (car e) 'quote) (cadr e))
	       ((eq? (car e) 'if)
		(if (fp_eq (fp_eval (cadr e) a) 'nil)
		    (fp_eval (cadddr e) a)
		    (fp_eval (caddr e) a)))
	       ((eq? (car e) 'lambda) (append e `(,a)))
	       (else
		(fp_apply (fp_eval (car e) a)
			  (map (lambda (x) (fp_eval x a))
			       (cdr e))))))
	(else (fp_lookup e a))))

;;;; Display S-expression by following the specification of fpLISP
(define (fp_strcons s)
  (fp_display (car s))
  (let ((sd (cdr s)))
    (cond ((fp_eq sd 'nil) (display ""))
          ((fp_atom sd) (display " . ") (fp_display sd))
	  (else (display " ") (fp_strcons sd)))))
(define (fp_display s)
  (cond ((fp_eq s 'nil) (display 'nil))
	((fp_eq s #t)   (display 't))
	((fp_eq s #f)   (display 'nil))
	((fp_atom s)    (display s))
	(else (display "(") (fp_strcons s) (display ")"))))

(fp_display (fp_eval (read) '()))
(newline)

