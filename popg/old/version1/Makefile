CC = cc

a1b2c3d4:
	@echo ""
	@echo "To make a copy of Simul8, do the following:"
	@echo ""
	@echo "For a machine:      type the command:    It will be named:"
	@echo "--------------      -----------------    -----------------"
	@echo ""
	@echo " Digital Alpha       make alpha          simul8.alpha"
	@echo " Linux               make linux          simul8.linux"
	@echo " Sun SPARC           make sun            simul8.sun"
	@echo " IBM RS6000          make rs6            simul8.rs6"
	@echo " DECstation          make ds             simul8.ds"
	@echo " other               make simul8         simul8"
	@echo ""
	@echo "(the last one may or may not work)"
	@echo ""

all: simul8

simul8: simul8.c
	$(CC) -g -DX simul8.c -lm -lX11 -o simul8

alpha:
	$(CC) -DX simul8.c -lm -lX11 -o simul8.alpha

linux: simul8.c
	$(CC) -g -DX simul8.c -lm -L/usr/X11/lib -lX11 -o simul8-linux

sun: simul8.c
	$(CC) -DX simul8.c -Bstatic -lm -lX11 -o simul8 \
	-I/usr/openwin/include -L/usr/openwin/lib

rs6: simul8.c
	$(CC) -g -DX simul8.c -lm -lX11 -bshared -o simul8.rs6

ds:
	$(CC) -DX simul8.c -lm -lX11 -o simul8.ds

clean: 
	rm -f simul8 *~ *.o

tags:
	etags simul8.c

