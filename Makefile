CC=gcc
CFLAGS=-lm -ljpeg -std=c99 -O3
HEMANTDIR=hemant/
ABHISHEKDIR=abhishek/
BINDIR=bin/

iojpegparts: $(HEMANTDIR)iojpegparts.c
	$(CC) $(HEMANTDIR)iojpegparts.c -o $(BINDIR)iojpegparts $(CFLAGS)
