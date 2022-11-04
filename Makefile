AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=systemd
LDFILES=

ifeq ($(CC65_HOME),)
        CC = cl65
        AS = ca65
        LD = ld65
        AR = ar65
else
        CC = $(CC65_HOME)/bin/cl65
        AS = $(CC65_HOME)/bin/ca65
        LD = $(CC65_HOME)/bin/ld65
        AR = $(CC65_HOME)/bin/ar65
endif

all : srccode code
.PHONY : all

SOURCE=src/$(PROGRAM).asm

VERSION=$(shell cat VERSION)

code: $(SOURCE)
	$(AS) -I libs/usr/include/ $(CFLAGS)  $(SOURCE) $(LDFILES) -o $(PROGRAM).ld65
	$(LD) -tnone -o $(PROGRAM).rom  $(PROGRAM).ld65
	mkdir build/bin &&  mkdir build/usr/share/systemd/$(VERSION) -p  && cp $(PROGRAM).rom build/usr/share/systemd/$(VERSION)/$(PROGRAM).rom  && cp $(PROGRAM).rom build/usr/share/systemd/$(PROGRAM).rom 
	chmod +x dependencies/orix-sdk/bin/relocbin.py3
	$(CC) -o 1000 -ttelestrat src/commands/twilconf/main.c libs/lib8/twil.lib --start-addr \$800
	$(CC) -o 1256 -ttelestrat src/commands/twilconf/main.c libs/lib8/twil.lib --start-addr \$900
	# Reloc
	dependencies/orix-sdk/bin/relocbin.py3 -o build/bin/twiconf -2 1000 1256

	$(CC) -o 1000 -ttelestrat src/commands/loader/main.c libs/lib8/twil.lib --start-addr \$800
	$(CC) -o 1256 -ttelestrat src/commands/loader/main.c libs/lib8/twil.lib --start-addr \$900
	dependencies/orix-sdk/bin/relocbin.py3 -o build/bin/twiconf -2 1000 1256

	#$(CC) -ttelestrat src/commands/twilconf/main.c libs/lib8/twil.lib -o build/bin/twiconf
	#$(CC) -ttelestrat src/commands/loader/main.c libs/lib8/twil.lib -o build/bin/twiload
	#cp etc/systemd/roms.cnf build/etc/systemd/


srccode: $(SOURCE)
	mkdir -p build/usr/src/$(PROGRAM)/
	mkdir -p build/usr/share/$(PROGRAM)/
	mkdir -p build/usr/share/$(PROGRAM)/roms/
	mkdir -p build/etc/$(PROGRAM)
	cp configure build/usr/src/$(PROGRAM)/
	cp Makefile build/usr/src/$(PROGRAM)/
	cp README.md build/usr/src/$(PROGRAM)/
	cp -adpR src/* build/usr/src/$(PROGRAM)/
