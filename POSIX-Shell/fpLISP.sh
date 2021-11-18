#!/bin/sh
#
# fpLISP.sh: fpLISP in POSIX-conformant Shell
#
# This code is licensed under CC0.
# https://creativecommons.org/publicdomain/zero/1.0/
#

IFS=''
LF="$(printf \\012)"

# Basic functions for conscell operations:
# cons, car, cdr, atom, eq

cons () {
  eval CAR"$CNUM"="$1"
  eval CDR"$CNUM"="$2"
  CONSR="${CNUM}".conscell
  CNUM="$((CNUM+1))"
}

car () { eval CARR="\$CAR${1%%.*}"; }
cdr () { eval CDRR="\$CDR${1%%.*}"; }

atom () {
  case "$1" in (*.conscell)
    ATOMR=nil
  ;;(*)
    ATOMR=t
  ;;esac
}

eq () {
  atom "$1"
  case "$ATOMR" in (nil)
    EQR=nil
  ;;(*)
    atom "$2"
    case "$ATOM" in (nil)
      EQR=nil
    ;;(*)
      case "$1" in ("$2")
        EQR=t
      ;;(*)
        EQR=nil
      ;;esac
    ;;esac
  ;;esac
}


# S-expreesion output: fp_display

fp_strcons () {
  car "$1" && fp_display "$CARR"
  cdr "$1"
  eq "$CDRR" nil
  case "$EQR" in (t)
    printf ''
  ;;(*)
    atom "$CDRR"
    case "$ATOMR" in (t)
      printf ' . %s' "$CDRR"
    ;;(*)
      printf " " && fp_strcons "$CDRR"
    ;;esac
  ;;esac
}

fp_display () {
  fp_null "$1"
  case "$FPNULLR" in (t)
    printf "()"
  ;;(*)
    atom "$1"
    case "$ATOMR" in (t)
      fp_isinteger "$1"
      case "$FPISINTEGERR" in ("$1")
        printf "%d" "$1"
      ;;(*)
        printf "$1"
      ;;esac
    ;;(*)
      printf "("
      fp_strcons "$1"
      printf ")"
    ;;esac
  ;;esac
}


# S-expression lexical analysis: fp_lex

replace_all_posix() {
  set -- "$1" "$2" "$3" "$4" ""
  until [ _"$2" = _"${2#*"$3"}" ] && eval "$1=\$5\$2"; do
    set -- "$1" "${2#*"$3"}" "$3" "$4" "$5${2%%"$3"*}$4"
  done
}

fp_lex0 () {
  replace_all_posix sl0INI " $1 " "$LF" ""
  replace_all_posix sl0LPS "$sl0INI" "(" " ( "
  replace_all_posix sl0RPS "$sl0LPS" ")" " ) "
  replace_all_posix sl0RET "$sl0RPS" "'" " ' "
}

fp_lex1 () {
  sl1HEAD="${1%% *}"
  sl1REST="${1#* }"

  case "$sl1HEAD" in (''|' ') :
  ;;(*)
    eval "TOKEN$TNUM=\$sl1HEAD"
    TNUM="$((TNUM+1))"
  ;;esac

  case "$sl1REST" in (''|' ') :
  ;;(*) fp_lex1 "$sl1REST"
  ;;esac
}

fp_lex () { fp_lex0 "$1" && fp_lex1 "$sl0RET"; }


# S-expression syntax analysis: fp_syn

fp_quote () {
  case "$SYNPOS" in (-[0-9]*)
    FPQUOTER="$1"
  ;;(*)
    eval "squox=\$TOKEN$SYNPOS"
    case "$squox" in (\')
      SYNPOS="$((SYNPOS-1))"
      cons "$1" nil
      cons quote "$CONSR"
      FPQUOTER="$CONSR"
    ;;(*)
      FPQUOTER="$1"
    ;;esac
  ;;esac
}

fp_syn0 () {
  eval "ss0t=\$TOKEN$SYNPOS"
  case "$ss0t" in ("(")
    SYNPOS="$((SYNPOS-1))"
    FPSYN0R="$1"
  ;;(.)
    SYNPOS="$((SYNPOS-1))"
    fp_syn
    car "$1"
    cons "$FPSYNR" "$CARR"
    fp_syn0 "$CONSR"
  ;;(*)
    fp_syn
    cons "$FPSYNR" "$1"
    fp_syn0 "$CONSR"
  ;;esac
}

fp_syn () {
  eval "ssyt=\$TOKEN$SYNPOS"
  SYNPOS="$((SYNPOS-1))"
  case "$ssyt" in (")")
    fp_syn0 nil
    fp_quote "$FPSYN0R"
    FPSYNR="$FPQUOTER"
  ;;(*)
    fp_quote "$ssyt"
    FPSYNR="$FPQUOTER"
  ;;esac
}

fp_read () {
  TNUM=0
  fp_lex "$1"
  SYNPOS="$((TNUM-1))"
  fp_syn
  FPREADR="$FPSYNR"
}


# Stack implementation for recursive calls

stackpush () {
  eval STACK"$STACKNUM"="$1"
  STACKNUM="$((STACKNUM+1))"
}

stackpop ()
{
  STACKNUM="$((STACKNUM-1))"
  eval STACKPOPR="\$STACK$STACKNUM"
}


# The evaluator: fp_eval and utility functions

caar ()
{
  eval CAAR_CARR="\$CAR${1%%.*}"
  eval CAARR="\$CAR${CAAR_CARR%%.*}"
}

cadr ()
{
  eval CADR_CDRR="\$CDR${1%%.*}"
  eval CADRR="\$CAR${CADR_CDRR%%.*}"
}

cdar ()
{
  eval CDAR_CARR="\$CAR${1%%.*}"
  eval CDARR="\$CDR${CDAR_CARR%%.*}"
}

cadar ()
{
  eval CADAR_CARR="\$CAR${1%%.*}"
  eval CADAR_CDARR="\$CDR${CADAR_CARR%%.*}"
  eval CADARR="\$CAR${CADAR_CDARR%%.*}"
}

caddr ()
{
  eval CADDR_CDRR="\$CDR${1%%.*}"
  eval CADDR_CDDRR="\$CDR${CADDR_CDRR%%.*}"
  eval CADDRR="\$CAR${CADDR_CDDRR%%.*}"
}

cadddr ()
{
  eval CADDDR_CDRR="\$CDR${1%%.*}"
  eval CADDDR_CDDRR="\$CDR${CADDDR_CDRR%%.*}"
  eval CADDDR_CDDDRR="\$CDR${CADDDR_CDDRR%%.*}"
  eval CADDDRR="\$CAR${CADDDR_CDDDRR%%.*}"
}

fp_null () { eq "$1" nil && FPNULLR="$EQR"; }

fp_append () {
  fp_null "$1"
  case "$FPNULLR" in (t)
    FPAPPENDR="$2"
  ;;(*)
    cdr "$1"
    fp_append "$CDRR" "$2"
    car "$1"
    cons "$CARR" "$FPAPPENDR"
    FPAPPENDR="$CONSR"
  ;;esac
}

fp_pair () {
  fp_null "$1"
  stackpush "$FPNULLR"
  fp_null "$2"
  stackpop
  case "$STACKPOPR $FPNULLR" in (t" "*|*" "t)
    FPPAIRR=nil
  ;;(*)
    atom "$1"
    stackpush "$ATOMR"
    atom "$2"
    stackpop
    case "$STACKPOPR $ATOMR" in (nil" "nil)
      cdr "$1"
      stackpush "$CDRR"
      cdr "$2"
      stackpop
      fp_pair "$STACKPOPR" "$CDRR"
      car "$1"
      stackpush "$CARR"
      car "$2"
      stackpop
      cons "$STACKPOPR" "$CARR"
      cons "$CONSR" "$FPPAIRR"
      FPPAIRR="$CONSR"
    ;;(*)
      atom "$1"
      case "$ATOMR" in (t)
        cons "$1" "$2"
        cons "$CONSR" nil
        FPPAIRR="$CONSR"
      ;;(*)
        FPPAIRR=nil
      ;;esac
    ;;esac
  ;;esac
}

fp_assq () {
  fp_null "$2"
  case "$FPNULLR" in (t)
    FPASSQR=nil
  ;;(*)
    caar "$2"
    eq "$CAARR" "$1"
    case "$EQR" in (t)
      cdar "$2"
      FPASSQR="$CDARR"
    ;;(*)
      cdr "$2"
      fp_assq "$1" "$CDRR"
    ;;esac
  ;;esac
}

fp_builtins () {
  case "$1" in (t|nil)
    FPBUILTINSR="$1"
  ;;(cons|car|cdr|eq|atom)
    FPBUILTINSR="$1"
  ;;(+|-|"*"|/|%|lt)
    FPBUILTINSR="$1"
  ;;(*)
    FPBUILTINSR=notbuiltins
  ;;esac
}

fp_isinteger () {
  case "${1#[+-]}" in (''|*[!0-9]*)
    FPISINTEGERR=notinteger
  ;;(*)
    FPISINTEGERR="$1"
  ;;esac
}

fp_lookup () {
  fp_builtins "$1"
  case "$FPBUILTINSR" in ("$1")
    FPLOOKUPR="$1"
    return
  ;;esac
  fp_isinteger "$1"
  case "$FPISINTEGERR" in ("$1")
    FPLOOKUPR="$1"
    return
  ;;esac
  fp_assq "$1" "$2"
  fp_null "$FPASSQR"
  case "$FPNULLR" in (t)
    FPLOOKUPR=nil
    return
  ;;esac
  FPLOOKUPR="$FPASSQR"
}

fp_evals () {
  fp_null "$1"
  case "$FPNULLR" in (t)
    FPEVALSR=nil
  ;;(*)
    car "$1" && fp_eval "$CARR" "$2"
    stackpush "$FPEVALR"
    cdr "$1" && fp_evals "$CDRR" "$2"
    stackpop && FPEVALR="$STACKPOPR"
    cons "$FPEVALR" "$FPEVALSR"
    FPEVALSR="$CONSR"
  ;;esac
}

fp_eval () {
  FPEVALARG1="$1"
  FPEVALARG2="$2"

  while true
  do
    atom "$FPEVALARG1"
    case "$ATOMR" in (t)
      fp_lookup "$FPEVALARG1" "$FPEVALARG2"
      FPEVALR="$FPLOOKUPR"
      break
    ;;esac
    car "$FPEVALARG1"
    case "$CARR" in (quote)
      cadr "$FPEVALARG1"
      FPEVALR="$CADRR"
      break
    ;;(if)
      cadr "$FPEVALARG1"
      stackpush "$FPEVALARG2"
      stackpush "$FPEVALARG1"
      fp_eval "$CADRR" "$FPEVALARG2"
      stackpop && FPEVALARG1="$STACKPOPR"
      stackpop && FPEVALARG2="$STACKPOPR"
      case "$FPEVALR" in (t)
        caddr "$FPEVALARG1"
        stackpush "$FPEVALARG2"
        stackpush "$FPEVALARG1"
        fp_eval "$CADDRR" "$FPEVALARG2"
        stackpop && FPEVALARG1="$STACKPOPR"
        stackpop && FPEVALARG2="$STACKPOPR"
      ;;(*)
        stackpush "$FPEVALARG2"
        stackpush "$FPEVALARG1"
        cadddr "$FPEVALARG1"
        fp_eval "$CADDDRR" "$FPEVALARG2"
        stackpop && FPEVALARG1="$STACKPOPR"
        stackpop && FPEVALARG2="$STACKPOPR"
      ;;esac
      break
    ;;(lambda)
      stackpush "$CARR"
      cons "$FPEVALARG2" nil
      caddr "$FPEVALARG1"
      cons "$CADDRR" "$CONSR"
      cadr "$FPEVALARG1"
      cons "$CADRR" "$CONSR"
      stackpop && CARR="$STACKPOPR"
      cons "$CARR" "$CONSR"
      FPEVALR="$CONSR"
      break
    ;;(*)
      car "$FPEVALARG1"
      stackpush "$FPEVALARG1"
      stackpush "$FPEVALARG2"
      fp_eval "$CARR" "$FPEVALARG2"
      stackpop && FPEVALARG2="$STACKPOPR"
      stackpop && FPEVALARG1="$STACKPOPR"
      FPEVALEFUNC="$FPEVALR"

      stackpush "$FPEVALARG1"
      stackpush "$FPEVALARG2"
      stackpush "$FPEVALEFUNC"
      cdr "$FPEVALARG1"
      atom "$FPEVALEFUNC"
      case "$ATOMR" in (t)
        fp_evals "$CDRR" "$FPEVALARG2"
        FPEVALFVALS="$FPEVALSR"
      ;;(*)
        fp_evals "$CDRR" "$FPEVALARG2"
        FPEVALFVALS="$FPEVALSR"
      ;;esac
      stackpop && FPEVALEFUNC="$STACKPOPR"
      stackpop && FPEVALARG2="$STACKPOPR"
      stackpop && FPEVALARG1="$STACKPOPR"

      atom "$FPEVALEFUNC"
      case "$ATOMR" in (t)
        fp_apply "$FPEVALEFUNC" "$FPEVALFVALS"
        FPEVALR="$FPAPPLYR"
        break
      ;;(*)
        cadr   "$FPEVALEFUNC" && FPEVALLVARS="$CADRR"
        caddr  "$FPEVALEFUNC" && FPEVALLBODY="$CADDRR"
        cadddr "$FPEVALEFUNC" && FPEVALLENVS="$CADDDRR"
        FPEVALARG1="$FPEVALLBODY"

        fp_null "$FPEVALLVARS"
        case "$FPNULLR" in (t)
          FPEVALARG2="$FPEVALLENVS"
        ;;(*)
          atom "$FPEVALLVARS"
          case "$ATOMR" in (t)
            cons "$FPEVALLVARS" "$FPEVALFVALS"
            cons "$CONSR" nil
            fp_append "$CONSR" "$FPEVALLENVS"
            FPEVALARG2="$FPAPPENDR"
          ;;(*)
            fp_pair "$FPEVALLVARS" "$FPEVALFVALS"
            fp_append "$FPPAIRR" "$FPEVALLENVS"
            FPEVALARG2="$FPAPPENDR"
          ;;esac
        ;;esac
      ;;esac
    ;;esac

  done
}

fp_apply () {
  case "$1" in (cons)
    cadr "$2"
    car "$2"
    cons "$CARR" "$CADRR"
    FPAPPLYR="$CONSR"
  ;;(car)
    car "$2"
    car "$CARR"
    FPAPPLYR="$CARR"
  ;;(cdr)
    car "$2"
    cdr "$CARR"
    FPAPPLYR="$CDRR"
  ;;(eq)
    cadr "$2"
    car "$2"
    eq "$CARR" "$CADRR"
    FPAPPLYR="$EQR"
  ;;(atom)
    car "$2"
    atom "$CARR"
    FPAPPLYR="$ATOMR"
  ;;(+|-|"*"|/|%)
    cadr "$2"
    car "$2"
    FPAPPLYR="$(($CARR$1$CADRR))"
  ;;(lt)
    cadr "$2"
    car "$2"
    case "$(($CARR<$CADRR))" in (1)
      FPAPPLYR=t
    ;;(*)
      FPAPPLYR=nil
    ;;esac
  ;;esac
}


# REP (no Loop)

CNUM=0
STACKNUM=0

FPREADCODE=""
while read fprdcd
do
  case "$fprdcd" in ('')
    break
  ;;esac
  FPREADCODE="$FPREADCODE$fprdcd"
done

fp_read "$FPREADCODE"
fp_eval "$FPREADR" nil
fp_display "$FPEVALR" && printf "\n"

