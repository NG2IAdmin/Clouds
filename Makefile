CC=gcc
CFLAGS=-lm -ljpeg -std=c99 -O3
HEMANTDIR=hemant/
ABHISHEKDIR=Abhishek/
BINDIR=bin/

all: iojpegparts combinefun

iojpegparts: $(HEMANTDIR)iojpegparts.c
	$(CC) $(HEMANTDIR)iojpegparts.c -o $(BINDIR)iojpegparts $(CFLAGS)

combinefun: $(ABHISHEKDIR)combinefun.c
	$(CC) $(ABHISHEKDIR)combinefun.c -o $(BINDIR)combinefun $(CFLAGS)
