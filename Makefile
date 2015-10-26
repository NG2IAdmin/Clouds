CC=gcc
CFLAGS=-lm -ljpeg -std=c99 -O3
HEMANTDIR=hemant/
ABHISHEKDIR=Abhishek/
BINDIR=bin/

all: iojpegparts combinefun

iojpegparts: $(HEMANTDIR)iojpegparts.c checkbin
	$(CC) $(HEMANTDIR)iojpegparts.c -o $(BINDIR)iojpegparts $(CFLAGS)

checkbin:
	mkdir -p $(BINDIR)

combinefun: $(ABHISHEKDIR)combinefun.c checkbin
	$(CC) $(ABHISHEKDIR)combinefun.c -o $(BINDIR)combinefun $(CFLAGS)
