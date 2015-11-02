CC=gcc
NCC=nvcc
CFLAGS=-lm -ljpeg -std=c99 -O3
NVCFLAGS=-lm -ljpeg
HEMANTDIR=hemant/
ABHISHEKDIR=Abhishek/
BINDIR=bin/

all: iojpegparts combinefun cudaexec

iojpegparts: $(HEMANTDIR)iojpegparts.c checkbin
	$(CC) $(HEMANTDIR)iojpegparts.c -o $(BINDIR)iojpegparts $(CFLAGS)

checkbin:
	mkdir -p $(BINDIR)

combinefun: $(ABHISHEKDIR)combinefun.c checkbin
	$(CC) $(ABHISHEKDIR)combinefun.c -o $(BINDIR)combinefun $(CFLAGS)

cudaexec: $(HEMANTDIR)iojpegCUDA.cu checkbin
	$(NCC) $(HEMANTDIR)iojpegCUDA.cu -o $(BINDIR)iojpegCUDA $(NVCFLAGS)
