;;;;
;;;; fpLISP.scm: fpLISP in Scheme
;;;;
;;;; This code is licensed under CC0.
;;;; https://creativecommons.org/publicdomain/zero/1.0/
;;;;

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
	((eq? f 'cons)
         ; 'cons' recognize #f or 'nil as empty list just in CDR
	 ; and #f as 'nil in CAR
	 (let ((fp_cdr (cadr v)) (fp_car (car v)))
	   (cons (if (eq? fp_car #f) 'nil fp_car)
		 (if (member fp_cdr `(,#f nil)) '() fp_cdr))))
	((eq? f 'car)  (car (car v)))
	((eq? f 'cdr)  (cdr (car v)))
	((eq? f 'eq)   (eq? (car v) (cadr v)))
	((eq? f 'atom) (not (pair? (car v))))
	((eq? f '+)    (+ (car v) (cadr v)))
	((eq? f '-)    (- (car v) (cadr v)))
	((eq? f '*)    (* (car v) (cadr v)))
	((eq? f '/)    (exact->inexact (/ (car v) (cadr v))))
	((eq? f '%)    (remainder (car v) (cadr v)))
	((eq? f 'lt)   (< (car v) (cadr v)))
	(else #f)))

;;;; List of built-in function names
(define fp_builtins '(cons car cdr eq atom + - * / % lt))

;;;; Look up value for a name
(define (fp_lookup t a)
  (cond ((eq? t 't) #t)
	((eq? t 'nil) #f)
	((or (member t fp_builtins) (number? t)) t)
	(else (cdr (assq t a)))))

;;;; Eval S-expression with local environment
(define (fp_eval e a)
  (cond ((pair? e)
	 (cond ((eq? (car e) 'quote) (cadr e))
	       ((eq? (car e) 'if)
		(if (fp_eval (cadr e) a)
		    (fp_eval (caddr e) a)
		    (fp_eval (cadddr e) a)))
	       ((eq? (car e) 'lambda) (append e `(,a)))
	       (else
		(fp_apply (fp_eval (car e) a)
			  (map (lambda (x) (fp_eval x a))
			       (cdr e))))))
	(else (fp_lookup e a))))

(display
 (let ((r (fp_eval (read) '())))
   (cond ((eq? r #t) 't)
	 ((eq? r #f) 'nil)
	 (else r))))
(newline)
