#sc_xkcam makefile
OBJECTS=xkcam_main.o xkcam_grabber.o xkcam_I2C.o xkcam_profiles.o xkcam_IO.o sccb.o
TARGET=../bin/sc_xkcam.xe
FLAGS = -Wall -O2 -target=XC-5

.SUFFIXES: .xc .S .c

ifeq "$(OS)" "Windows_NT"
DELETE = del
else
DELETE = rm -f
endif

.xc.o:
	xcc -c $(FLAGS) $*.xc
.c.o:
	xcc -c $(FLAGS) $*.c

$(TARGET): $(OBJECTS)
	xcc $(FLAGS) -o $(TARGET) $(OBJECTS)

clean:
	$(DELETE) *.o ..\bin\*.xe
