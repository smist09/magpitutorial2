tutorial2: tutorial2.o
	ld -o tutorial2 tutorial2.o
	
tutorial2.o: tutorial2.s
	as -g -o tutorial2.o tutorial2.s
