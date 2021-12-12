SRC = fpLISP.c
OBJ = fpLISP-$(shell uname -m)-$(shell uname -s)

${OBJ}: ${SRC}
	cc -static -o $@ ${SRC}

clean:
	rm -f ${OBJ}

