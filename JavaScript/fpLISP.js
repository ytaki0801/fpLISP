//
// fpLISP.js: A LISP interpreter orienting functional programming and Pure LISP
//
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
  var t = s.pop();
  if (t == ")") {
    var r = null;
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
  var sa_r = fp_string(car(s));
  var sd = cdr(s);
  if (eq(sd, null)) {
    return sa_r;
  } else if (atom(sd)) {
    return sa_r + " . " + sd;
  } else {
    return sa_r + " " + fp_strcons(sd);
  }
}

function fp_string(s) {
  if      (eq(s, null))  return "()";
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
  else if (atom(x))
    return cons(cons(x, y), null);
  else
    return null;
}

function fp_assq(x, y) {
  if (fp_null(y)) return null;
  else if (eq(caar(y), x)) return cdar(y);
  else return fp_assq(x, cdr(y));
}

function fp_len(x) {
  if (fp_null(x)) return 0;
  else return 1 + fp_len(cdr(x));
}

const fp_builtins = [
  "cons", "car", "cdr", "eq", "atom", "+", "-", "*", "/"
];

function fp_lookup(t, a) {
  if      (eq(t, "t"))   return true;
  else if (eq(t, "nil")) return false;
  else if (fp_builtins.includes(t) || !isNaN(t)) return t;
  else {
    r = fp_assq(t, a);
    if (fp_null(r)) return fp_assq(t, GENV);
    else return r;
  }
}

function fp_eargs(v, a) {
  if (fp_null(v)) return null;
  else return cons(fp_eval(car(v), a), fp_eargs(cdr(v), a));
}

function fp_eval(e, a) {
  if (atom(e)) return fp_lookup(e, a);
  else if (eq(car(e), "quote")) return cadr(e);
  else if (eq(car(e), "if")) {
    if (fp_eval(cadr(e), a))
      return fp_eval(caddr(e), a);
    else
      return fp_eval(cadddr(e), a);
  }
  else if (eq(car(e), "lambda"))
    return cons(car(e), cons(cadr(e), cons(caddr(e), cons(a, null))));
  else
    return fp_apply(fp_eval(car(e), a), fp_eargs(cdr(e), a));
}

function fp_apply(f, v) {
  if (atom(f)) {
    if      (eq(f, "cons")) return cons(car(v), cadr(v));
    else if (eq(f, "car"))  return car(car(v));
    else if (eq(f, "cdr"))  return cdr(car(v));
    else if (eq(f, "eq"))   return eq(car(v), cadr(v));
    else if (eq(f, "atom")) return atom(car(v));
    else if (eq(f, "+")) return String(Number(car(v)) + Number(cadr(v)));
    else if (eq(f, "-")) return String(Number(car(v)) - Number(cadr(v)));
    else if (eq(f, "*")) return String(Number(car(v)) * Number(cadr(v)));
    else if (eq(f, "/")) return String(Number(car(v)) / Number(cadr(v)));
  } else {
    lvars = cadr(f);
    lbody = caddr(f);
    lenvs = cadddr(f);
    if (atom(lvars))
      if (fp_null(lvars)) return fp_eval(lbody, lenvs);
      else return fp_eval(lbody, fp_append(cons(cons(lvars, v), null), lenvs));
    else
      return fp_eval(lbody, fp_append(fp_pair(lvars, v), lenvs));
  }
}


// REP (no Loop): fp_rep
GENV = fp_read("()");
function fp_rep(e) { return fp_string(fp_eval(fp_read(e), fp_read("()"))); }

// Script file execution in Node.js
if (process.argv.length == 3) {
  src = require("fs").readFileSync(process.argv[2]).toString();
  console.log(fp_rep(src));
}

