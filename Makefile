all:
	echo ok

c:
	v -o c.c vnats_test.v

test:
	v test .

ctest:
	gcc -o a -lnats a.c
