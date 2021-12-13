SRC = fpLISP.c
OBJ = fpLISP-$(shell uname -m)-$(shell uname -s)

${OBJ}: ${SRC}
ifeq ($(shell uname -s), Darwin)
	cc -static-libsan -o $@ ${SRC}
else
	cc -static -o $@ ${SRC}
endif

clean:
	rm -f ${OBJ}

