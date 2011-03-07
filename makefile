SOURCE = src/file_functions.c src/fram.xc src/main.xc
FLAGS = -Wall -g -O2 -I.. -Isrc -report -target=XK-1

ifeq "$(OS)" "Windows_NT"
DELETE = del
else
DELETE = rm -f
endif

basic.xe: ${SOURCE}
	xcc ${FLAGS} ${SOURCE} -o bin/fram.xe

clean:
	$(DELETE) bin\*.xe
