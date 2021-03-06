//
// fpLISP.js: fpLISP in JavaScript
//
// (C) 2021 TAKIZAWA Yozo
// This code is licensed under CC0.
// https://creativecommons.org/publicdomain/zero/1.0/
//


// Basic functions for conscell operations:
// cons, car, cdr, eq, atom
function cons(x, y) { return Object.freeze([x, y]); }
function car(s) { return s[0]; }
function cdr(s) { return s[1]; }
function eq(s1, s2) {
  if ((s1 === false && s2 === null) || (s1 === null && s2 === false))
    return true;
  else if ((s1 === false && s2 === "nil") || (s1 === "nil" && s2 === false))
    return true;
  else if ((s1 === null && s2 === "nil") || (s1 === "nil" && s2 === null))
    return true;
  else
    return s1 === s2;
}
function atom(s) {
  return typeof s == "string" || eq(s, null) || eq(s, true) || eq(s, false);
}


// S-expression input: fp_read

function fp_lex(s) {
  s = s.replace(/(\(|\)|\'|\,)/g, " $1 ");
  return s.split(/\s+/).filter(x => x != "");
}

function fp_syn(s) {
  function quote(x, s) {
    if (s.length != 0 && s.slice(-1)[0] == "\'") {
      s.pop();
      return cons("quote", cons(x, null));
    } else {
      return x
    }
  }
  let t = s.pop();
  if (t == ")") {
    let r = null;
    while (s.slice(-1)[0] != "(") {
      if (s.slice(-1)[0] == ".") {
        s.pop();
        r = cons(fp_syn(s), car(r));
      } else {
        r = cons(fp_syn(s), r);
      }
    }
    s.pop();
    return quote(r, s);
  } else {
    return quote(t, s);
  }
}

function fp_read(s) { return fp_syn(fp_lex(s)); }


// S-expression output: fp_string

function fp_strcons(s) {
  let sa_r = fp_string(car(s));
  let sd = cdr(s);
  if (fp_null(sd)) {
    return sa_r;
  } else if (atom(sd)) {
    return sa_r + " . " + sd;
  } else {
    return sa_r + " " + fp_strcons(sd);
  }
}

function fp_string(s) {
  if      (eq(s, null))  return "nil";
  else if (eq(s, true))  return "t";
  else if (eq(s, false)) return "nil";
  else if (atom(s))
    return s;
  else
    return "(" + fp_strcons(s) + ")";
}


// The evaluator: fp_eval and utility functions

function caar(x) { return car(car(x)); }
function cadr(x) { return car(cdr(x)); }
function cdar(x) { return cdr(car(x)); }
function cadar(x) { return car(cdr(car(x))); }
function caddr(x) { return car(cdr(cdr(x))); }
function cadddr(x) { return car(cdr(cdr(cdr(x)))); }

function fp_null(x) { return eq(x, null); }

function fp_append(x, y) {
  if (fp_null(x)) return y;
  else return cons(car(x), fp_append(cdr(x), y));
}

function fp_pair(x, y) {
  if (fp_null(x) || fp_null(y)) return null;
  else if (!atom(x) && !atom(y))
    return cons(cons(car(x), car(y)), fp_pair(cdr(x), cdr(y)));
  else return null;
}

function fp_assq(x, y) {
  if (fp_null(y)) return null;
  else if (eq(caar(y), x)) return cdar(y);
  else return fp_assq(x, cdr(y));
}

const fp_builtins = {
  "cons" : (v) => cons(car(v), cadr(v)),
  "car"  : (v) => car(car(v)),
  "cdr"  : (v) => cdr(car(v)),
  "eq"   : (v) => eq(car(v), cadr(v)),
  "atom" : (v) => atom(car(v)),
  "+"    : (v) => String(Number(car(v)) + Number(cadr(v))),
  "-"    : (v) => String(Number(car(v)) - Number(cadr(v))),
  "*"    : (v) => String(Number(car(v)) * Number(cadr(v))),
  "/"    : (v) => String(Number(car(v)) / Number(cadr(v)) | 0),
  "%"    : (v) => String(Number(car(v)) % Number(cadr(v))),
  "lt"   : (v) => Number(car(v)) < Number(cadr(v))
};

function fp_apply(f, v) {
  if (atom(f)) {
    return fp_builtins[f](v);
  } else {
    const lvars = cadr(f);
    const lbody = caddr(f);
    let lenvs;
    if (fp_null(cdr(cdr(cdr(f))))) {
      lenvs = null;
    } else {
      lenvs = cadddr(f);
    }
    if (atom(lvars))
      if (fp_null(lvars)) return fp_eval(lbody, lenvs);
      else return fp_eval(lbody, fp_append(cons(cons(lvars, v), null), lenvs));
    else
      return fp_eval(lbody, fp_append(fp_pair(lvars, v), lenvs));
  }
}

function fp_lookup(t, a) {
  if      (eq(t, "t"))   return true;
  else if (eq(t, "nil")) return false;
  else if (Object.keys(fp_builtins).includes(t) || !isNaN(t)) return t;
  else return fp_assq(t, fp_append(a, envinit));
}

function fp_eargs(v, a) {
  if (fp_null(v)) return null;
  else return cons(fp_eval(car(v), a), fp_eargs(cdr(v), a));
}

function fp_eval(e, a) {
  if (atom(e)) return fp_lookup(e, a);
  else if (eq(car(e), "quote")) {
      return cadr(e);
  } else if (eq(car(e), "if")) {
    if (fp_eval(cadr(e), a))
      return fp_eval(caddr(e), a);
    else
      return fp_eval(cadddr(e), a);
  } else if (eq(car(e), "lambda"))
    return cons(car(e), cons(cadr(e), cons(caddr(e), cons(a, null))));
  else
    return fp_apply(fp_eval(car(e), a), fp_eargs(cdr(e), a));
}


// REP (no Loop): fp_rep
const ENVINIT = "(quote ( \
(unfold .                                              \
 (lambda a                                             \
   ((lambda (f seed i)                                 \
      (((lambda (u) (u u)) (lambda (u) (lambda (e r)   \
          (if (eq e nil) r                             \
              ((u u) (f (car e)) (cons (cdr e) r)))))) \
       (f seed) (if (eq i nil) nil (car i))))          \
    (car a) (car (cdr a)) (cdr (cdr a)))))             \
(fold .                                                \
 (lambda x                                             \
   ((lambda (f i0 a0 b0)                               \
      (((lambda (u) (u u)) (lambda (u) (lambda (i a b) \
          (if (eq a nil) i                             \
          (if (eq b nil)                               \
              ((u u) (f i (car a)) (cdr a) b)          \
              ((u u) (f i (car a) (car b))             \
                     (cdr a) (cdr b)))))))             \
       i0 a0 (if (eq b0 nil) nil (car b0))))           \
    (car x) (car (cdr x)) (car (cdr (cdr x)))          \
    (cdr (cdr (cdr x))))))                             \
(unfold-stream .                                         \
 (lambda (f seed)                                        \
   (((lambda (u) (u u)) (lambda (u) (lambda (e)          \
       (cons (car e) (lambda () ((u u) (f (cdr e)))))))) \
    (f seed))))                                          \
(take-stream .                                           \
 (lambda (s k)                                           \
   (((lambda (u) (u u)) (lambda (u) (lambda (s k)        \
       (if (eq k 0) nil                                  \
           (cons (car s) ((u u) ((cdr s)) (- k 1)))))))  \
    s k)))                                               \
))";
const envinit = fp_eval(fp_read(ENVINIT), null);
function fp_rep(e) { return fp_string(fp_eval(fp_read(e), fp_read("()"))); }

