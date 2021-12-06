;;;;
;;;; fpLISP.lisp: fpLISP in Common Lisp
;;;;
;;;; (C) 2021 TAKIZAWA Yozo
;;;; This code is licensed under CC0.
;;;; https://creativecommons.org/publicdomain/zero/1.0/
;;;;

;;;;
;;;; Simple lexical and syntax analysis for S-expression
;;;;

(defun fp_lex (ch wd wds)
  (cond ((eq ch #\Newline)
	 (let ((ch1 (read-char)))
	   (cond ((eq ch1 #\Newline)
		  (let ((r (cons (coerce (reverse wd) 'string) wds)))
		    (remove-if (lambda (x) (equal x "")) r)))
		 (t (fp_lex ch1 wd wds)))))
	((member ch '(#\  #\( #\) #\'))
	 (fp_lex (read-char) nil
		 (cons
                   (if (eq ch #\ ) "" (coerce `(,ch) 'string))
                   (cons (coerce (reverse wd) 'string) wds))))
	(t (fp_lex (read-char) (cons ch wd) wds))))

(defun fp_syn1 (s r)
  (cond ((equal (car s) "(") (cons r (fp_syn0 (cdr s))))
	((equal (car s) ".")
	 (let ((rr (fp_syn0 (cdr s))))
	   (fp_syn1 (cdr rr) (cons (car rr) (car r)))))
        (t (let ((rr (fp_syn0 s)))
	    (fp_syn1 (cdr rr) (cons (car rr) r))))))

(defun fp_syn0 (s)
  (cond ((equal (car s) ")") (fp_syn1 (cdr s) '()))
        (t s)))

(defun fp_syn (s)
  (let ((r (fp_syn0 s)))
    ; Change a single quotation outside parentheses to ("quote" ...)
    (cond ((equal (car (reverse r)) "'") (list "quote" (car r)))
	  (t (car (fp_syn0 s))))))

(defun fp_read () (fp_syn (fp_lex (read-char) nil nil)))

;;;;
;;;; Evaluator for fpLISP
;;;;

;;;; Define predicates in the specification of fpLISP
(defun fp_eq (x y)
  (let ((NILVAL `(,nil "nil" "NIL" ())) (TVAL `(,t "t" "T")))
    (cond ((and (member x NILVAL :test #'equal)
                (member y NILVAL :test #'equal)) t)
          ((and (member x TVAL :test #'equal)
                (member y TVAL :test #'equal) t))
          ((and (stringp x) (stringp y))
           (let ((xn (read-from-string x))
                 (yn (read-from-string y)))
             (equal xn yn)))
          (t (equal x y)))))

;;;; Apply a function with arguments for a lambda expression
;;;; and built-in functions
(defun fp_apply (f v)
  (cond ((atom f)
         (cond ((equal f "cons") (cons (car v) (cadr v)))
	       ((equal f "car")  (car (car v)))
	       ((equal f "cdr")  (cdr (car v)))
	       ((equal f "atom") (atom (car v)))
               ((equal f "eq")   (fp_eq (car v) (cadr v)))
               (t (let ((x (read-from-string (car v)))
                        (y (read-from-string (cadr v))))
                    (cond ((equal f "+")  (write-to-string (+ x y)))
	                  ((equal f "-")  (write-to-string (- x y)))
	                  ((equal f "*")  (write-to-string (* x y)))
                          ((equal f "/")  (write-to-string (float (/ x y))))
                          ((equal f "%")  (write-to-string (rem x y)))
                          ((equal f "lt") (< x y))
                          (t nil))))))
        (t (if (equal (car f) "lambda")
	       ; Eval body of a lambda expression in local env
	       ; made from variables, values and closure env
	       (let ((lvars (cadr f)))
	         (fp_eval
	  	  (caddr f)
  		  (append (cond ((null lvars) '())
			        ((atom lvars) `(,(cons lvars v)))
		                (t (mapcar 'cons lvars v)))
		          (cadddr f))))
	       nil))))

;;;; List of built-in function and Boolean names
(defvar fp_builtins
  '("cons" "car" "cdr" "eq" "atom" "+" "-" "*" "/" "%" "lt" "t" "nil"))

;;;; Look up value for a name
(defun fp_lookup (token a)
  (cond ((or (member token fp_builtins :test #'equal)
             (numberp (read-from-string token)))
         token)
	(t (cdr (assoc token a :test #'equal)))))

;;;; Change single quotations inside parentheses to ("quote" ...)
(defun fp_quote (args)
  (cond ((atom args) args)
        ((equal (car args) "'")
	 (cons (list "quote" (cadr args)) (fp_quote (cddr args))))
	(t (cons (car args) (fp_quote (cdr args))))))

;;;; Eval S-expression with local environment
(defun fp_eval (e a)
  (let ((efpq (fp_quote e)))
    (cond ((atom efpq) (fp_lookup efpq a))
        (t (cond ((equal (car efpq) "quote") (cadr efpq))
	         ((equal (car efpq) "if")
		  (if (fp_eq (fp_eval (cadr efpq) a) "nil")
		      (fp_eval (cadddr efpq) a)
		      (fp_eval (caddr efpq) a)))
	         ((equal (car efpq) "lambda") (append efpq `(,a)))
                 (t (fp_apply (fp_eval (car efpq) a)
			      (mapcar (lambda (x) (fp_eval x a))
			              (cdr efpq)))))))))

;;;; Display S-expression by following the specification of fpLISP
(defun fp_strcons (s)
  (fp_display (car s))
  (let ((sd (cdr s)))
    (cond ((fp_eq sd "nil") (princ ""))
	  ((atom sd) (princ " . ") (fp_display sd))
	  (t (princ " ") (fp_strcons sd)))))
(defun fp_display (s)
  (cond ((fp_eq s "nil") (princ "nil"))
	((fp_eq s t)     (princ "t"))
	((fp_eq s nil)   (princ "nil"))
	((atom s) (princ s))
	(t (princ "(") (fp_strcons s) (princ ")"))))

(fp_display (fp_eval (fp_read) '()))
(terpri)

