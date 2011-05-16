# Copyright (c) 2011, XMOS Ltd., All rights reserved
# This software is freely distributable under a derivative of the
# University of Illinois/NCSA Open Source License posted in
# LICENSE.txt and at <http://github.xcore.com/>

SOURCE = src/file_functions.c src/fram.xc src/main.xc
FLAGS = -Wall -g -O2 -DFM25V10 -I.. -Isrc -report -target=XK-1 

ifeq "$(OS)" "Windows_NT"
DELETE = del
else
DELETE = rm -f
endif

basic.xe: ${SOURCE}
	xcc ${FLAGS} ${SOURCE} -o bin/fram.xe

clean:
	$(DELETE) bin\*.xe
