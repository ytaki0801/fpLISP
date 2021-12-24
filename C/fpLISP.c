// PureLISP.c: fpLISP in C
//
// (C) 2021 TAKIZAWA Yozo
// This code is Licensed under CC0.
// https://creativecommons.org/publicdomain/zero/1.0/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <ctype.h>

#define SSTR_MAX 4096

typedef uintptr_t value_t;
enum NODE_TAG { NODE_STRG, NODE_CONS };

typedef struct _node_t_ {
  value_t value;
  enum NODE_TAG tag;
} _node_t, *node_t;

// Basic functions for conscel operations:
// cons, car, cdr, eq, atom

node_t node(value_t value, enum NODE_TAG tag)
{
  node_t n = (node_t)malloc(sizeof(_node_t));
  n->value = value; n->tag = tag;
  return (n);
}

typedef struct _cons_t_ {
  node_t x, y;
} _cons_t, *cons_t;

#define str_to_node(s)  (node((value_t)(s), NODE_STRG))
#define node_to_str(s)  ((char *)(s->value))

#define n_strg(s)  (s->tag == NODE_STRG)
#define n_cons(s)  (s->tag == NODE_CONS)

int eq(node_t s1, node_t s2);
#define atom(s)   (eq(s, NULL) || n_strg(s))

node_t car(node_t s) {
  if (s == NULL || atom(s)) return NULL;
  else return ((cons_t)(s->value))->x;
}

node_t cdr(node_t s) {
  if (s == NULL || atom(s)) return NULL;
  else return ((cons_t)(s->value))->y;
}

node_t cons(node_t x, node_t y)
{
  cons_t c = (cons_t)malloc(sizeof(_cons_t));
  c->x = x; c->y = y;
  node_t n = node((value_t)c, NODE_CONS);
  return (n);
}

int eq(node_t s1, node_t s2)
{
  if (s1 == NULL && s2 == NULL) return (1);
  else if (s1 == NULL && (!n_cons(s2) && !strcmp(node_to_str(s2), "nil")))
    return (1);
  else if (s2 == NULL && (!n_cons(s1) && !strcmp(node_to_str(s1), "nil")))
    return (1);
  else if (s1 == NULL || s2 == NULL) return (0);
  else if (n_cons(s1) || n_cons(s2)) return (0);
  else return (!strcmp(node_to_str(s1), node_to_str(s2)));
}

// S-expression input: fp_lex and fp_syn

int fp_lex(const char *s, char* sl[])
{
  char sf[SSTR_MAX * 3];
  int i, j = 0;
  for (i = 0; i < strlen(s); i++) {
    switch (s[i]) {
      case '(':
      case ')':
      case '\'': sf[j++] = ' '; sf[j++] = s[i]; sf[j++] = ' '; break;
      case '\n': j++; break;
      default: sf[j++] = s[i];
    }
  }
  sf[j] = '\0';

  char *t;
  int len = 0;
  for (t = strtok(sf, " "); t != NULL; t = strtok(NULL, " ")) sl[len++] = t;
  sl[len] = NULL;

  return (len);
}

node_t fp_syn(char *s[], int *pos)
{
  char *t = s[*pos];
  *pos = *pos - 1;

  if (t[0] == ')') {
    if (*pos <= 0) return NULL;
    node_t r = NULL;
    while (s[*pos][0] != '(') {
      if (s[*pos][0] == '.') {
        *pos = *pos - 1;
        r = cons(fp_syn(s, pos), car(r));
      } else
        r = cons(fp_syn(s, pos), r);
    }
    *pos = *pos - 1;
    if (*pos != -1 && s[*pos][0] == '\'') {
      *pos = *pos - 1;
      return cons(str_to_node("quote"), cons(r, NULL));
    } else
      return (r);
  } else {
    char *tr = malloc((strlen(t) + 1) * sizeof(*tr));
    sprintf(tr, "%s", t);
    node_t tn = str_to_node(tr);
    if (*pos != -1 && s[*pos][0] == '\'') {
      *pos = *pos - 1;
      return cons(str_to_node("quote"), cons(tn, NULL));
    } else
      return (tn);
  }
}

// S-expression output: fp_string

char fp_eval_retval[SSTR_MAX];
void fp_string(node_t s);

void fp_strcons(node_t s)
{
  fp_string(car(s));
  node_t sd = cdr(s);
  if (eq(sd, NULL)) {
  } else if (n_strg(sd)) {
    strcat(fp_eval_retval, " . ");
    strcat(fp_eval_retval, node_to_str(sd));
  } else {
    strcat(fp_eval_retval, " ");
    fp_strcons(sd);
  }
}

void fp_string(node_t s)
{
  if (s == NULL) {
    strcat(fp_eval_retval, "nil");
  } else if (n_strg(s)) {
    strcat(fp_eval_retval, node_to_str(s));
  } else {
    strcat(fp_eval_retval, "(");
    fp_strcons(s);
    strcat(fp_eval_retval, ")");
  }
}

// The evaluator: fp_eval and utility functions

node_t fp_eval(node_t e, node_t a);

#define FP_T    (str_to_node("t"))
#define FP_NIL  (str_to_node("nil"))
#define FP_CONS (str_to_node("cons"))
#define FP_CAR  (str_to_node("car"))
#define FP_CDR  (str_to_node("cdr"))
#define FP_EQ   (str_to_node("eq"))
#define FP_ATOM (str_to_node("atom"))
#define FP_ADD  (str_to_node("+"))
#define FP_SUB  (str_to_node("-"))
#define FP_MUL  (str_to_node("*"))
#define FP_DIV  (str_to_node("/"))
#define FP_MOD  (str_to_node("%"))
#define FP_LTN  (str_to_node("lt"))

node_t caar(node_t x) { return car(car(x)); }
node_t cadr(node_t x) { return car(cdr(x)); }
node_t cdar(node_t x) { return cdr(car(x)); }
node_t cadar(node_t x) { return car(cdr(car(x))); }
node_t caddr(node_t x) { return car(cdr(cdr(x))); }
node_t cadddr(node_t x) { return car(cdr(cdr(cdr(x)))); }

node_t fp_null(node_t x)
{
  if (eq(x, NULL)) return FP_T; else return NULL;
}

node_t fp_append(node_t x, node_t y)
{
  if (fp_null(x)) return y;
  else return cons(car(x), fp_append(cdr(x), y));
}

node_t fp_pair(node_t x, node_t y)
{
  if (fp_null(x) || fp_null(y)) return NULL;
  else if (!atom(x) && !atom(y))
    return cons(cons(car(x), car(y)), fp_pair(cdr(x), cdr(y)));
  else return NULL;
}

node_t fp_assq(node_t k, node_t v)
{
  if (fp_null(v)) return NULL;
  else if (eq(k, caar(v))) return cdar(v);
  else return fp_assq(k, cdr(v));
}

node_t fp_cond(node_t c, node_t a)
{
  if (fp_null(c)) return NULL;
  else if (eq(fp_eval(caar(c), a), FP_T))
    return cadar(c);
  else
    return fp_cond(cdr(c), a);
}

int fp_isinteger(node_t t)
{
  const char *str = node_to_str(t);
  int i;
  for (i = 0; i < strlen(str); i++)
    if (!isdigit(str[i]) && str[i] != '-') break;
  return i == strlen(str) ? 1 : 0;
}

node_t fp_lookup(node_t t, node_t a)
{
  if      (eq(t, FP_T))   return FP_T;
  else if (eq(t, FP_NIL)) return FP_NIL;
  else if (eq(t, FP_CONS) || eq(t, FP_CAR)  || eq(t, FP_CDR)
        || eq(t, FP_EQ)   || eq(t, FP_ATOM) || eq(t, FP_ADD)
        || eq(t, FP_SUB)  || eq(t, FP_MUL)  || eq(t, FP_DIV)
        || eq(t, FP_MOD)  || eq(t, FP_LTN)  || fp_isinteger(t))
    return t;
  else
    return fp_assq(t, a);
}

node_t fp_bool2node(int e)
{
  if (e) return FP_T; else return NULL;
}

#define node_to_int(s) (atoi((char *)(s->value)))
node_t int_to_node(int n)
{
    char *s = malloc(sizeof(1024) * sizeof(*s));
    sprintf(s, "%d", n);
    return node((value_t)(s), NODE_STRG);
}

node_t fp_apply(node_t f, node_t v)
{
  if      (eq(f, FP_CONS)) return cons(car(v), cadr(v));
  else if (eq(f, FP_CAR))  return car(car(v));
  else if (eq(f, FP_CDR))  return cdr(car(v));
  else if (eq(f, FP_EQ))   return fp_bool2node(eq(car(v), cadr(v)));
  else if (eq(f, FP_ATOM)) return fp_bool2node(atom(car(v)));
  else if (eq(f, FP_ADD))
          return int_to_node(node_to_int(car(v)) + node_to_int(cadr(v))); 
  else if (eq(f, FP_SUB))
          return int_to_node(node_to_int(car(v)) - node_to_int(cadr(v))); 
  else if (eq(f, FP_MUL))
          return int_to_node(node_to_int(car(v)) * node_to_int(cadr(v))); 
  else if (eq(f, FP_DIV))
          return int_to_node(node_to_int(car(v)) / node_to_int(cadr(v))); 
  else if (eq(f, FP_MOD))
          return int_to_node(node_to_int(car(v)) % node_to_int(cadr(v))); 
  else if (eq(f, FP_LTN))
          return fp_bool2node(node_to_int(car(v)) < node_to_int(cadr(v))); 
  else return NULL;
}
 
#define FP_QUOTE  (str_to_node("quote"))
#define FP_IF     (str_to_node("if"))
#define FP_LAMBDA (str_to_node("lambda"))

node_t fp_evals(node_t v, node_t a)
{
  if (fp_null(v)) return NULL;
  else return cons(fp_eval(car(v), a), fp_evals(cdr(v), a));
}

node_t fp_eval(node_t e, node_t a)
{
  while (1) {
    if (atom(e)) {
      return fp_lookup(e, a);
    } else if (eq(car(e), FP_QUOTE)) {
      node_t vals = cadr(e);
      return vals;
    } else if (eq(car(e), FP_IF)) {
      if (eq(fp_eval(cadr(e), a), FP_T))
        return fp_eval(caddr(e), a);
      else
        return fp_eval(cadddr(e), a);
    } else if (eq(car(e), FP_LAMBDA)) {
      node_t name = car(e);
      node_t vars = cadr(e);
      node_t body = caddr(e);
      return cons(name, cons(vars, cons(body, cons(a, NULL))));
    } else {
      node_t efunc = fp_eval(car(e), a);
      node_t fvals = fp_evals(cdr(e), a);
      if (atom(efunc)) return fp_apply(efunc, fvals);
      else {
        node_t lname = car(efunc);
        node_t lvars = cadr(efunc);
        node_t lbody = caddr(efunc);
        node_t lenvs = cadddr(efunc);
        node_t fenvs = a;
        e = lbody;
        if (fp_null(lvars))
          a = lenvs;
        else if (atom(lvars))
          a = fp_append(cons(cons(lvars, fvals), NULL), lenvs);
        else
          a = fp_append(fp_pair(lvars, fvals), lenvs);
      }
    }
  }
}

// eval_string

const char *INITENV = "(quote ("
"(unfold .                                              "
" (lambda a                                             "
"   ((lambda (f seed i)                                 "
"      (((lambda (u) (u u)) (lambda (u) (lambda (e r)   "
"          (if (eq e nil) r                             "
"              ((u u) (f (car e)) (cons (cdr e) r)))))) "
"       (f seed) (if (eq i nil) nil (car i))))          "
"    (car a) (car (cdr a)) (cdr (cdr a)))))             "
"(fold .                                                "
" (lambda x                                             "
"   ((lambda (f i0 a0 b0)                               "
"      (((lambda (u) (u u)) (lambda (u) (lambda (i a b) "
"          (if (eq a nil) i                             "
"          (if (eq b nil)                               "
"              ((u u) (f i (car a)) (cdr a) b)          "
"              ((u u) (f i (car a) (car b))             "
"                     (cdr a) (cdr b)))))))             "
"       i0 a0 (if (eq b0 nil) nil (car b0))))           "
"    (car x) (car (cdr x)) (car (cdr (cdr x)))          "
"    (cdr (cdr (cdr x))))))                             "
"))";

void fp_eval_string(char *s)
{
  char *lr_s_e[SSTR_MAX];;
  int fp_len_e = fp_lex(INITENV, lr_s_e) - 1;
  node_t rs_e = fp_syn(lr_s_e, &fp_len_e);
  node_t r_e = fp_eval(rs_e, NULL);

  char *lr_s[SSTR_MAX];;
  int fp_len = fp_lex(s, lr_s) - 1;
  node_t rs = fp_syn(lr_s, &fp_len);
  node_t r = fp_eval(rs, r_e);

  fp_eval_retval[0] = '\0';
  fp_string(r);
}

int main(int argc, char *argv[])
{
  char fp_src[SSTR_MAX], in[SSTR_MAX];

  fp_src[0] = '\0';
  while ((fgets(in, SSTR_MAX, stdin)) != NULL) {
    if (in[0] != '\n') {
      in[strlen(in)-1] = ' ';
      strcat(fp_src, in);
    }
  }

  if (strlen(fp_src)) {
    fp_eval_retval[0] = '\0';
    fp_eval_string(fp_src);
    printf("%s\n", fp_eval_retval);
  }

  return (0);
}

