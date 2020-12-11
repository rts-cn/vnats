all:
	echo ok

c:
	v -o c.c vnats_test.v

test:
	v test .
