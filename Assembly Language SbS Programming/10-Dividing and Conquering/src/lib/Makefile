AS=nasm
ASFLAGS=-g -f elf -F stabs
LDFLAGS=-m elf_i386
EXEC=hexdump3
LIBS=textlib

$(EXEC): $(LIBS).o $(EXEC).o
	ld -o $@ $@.o $< $(LDFLAGS)

$(EXEC).o: $(EXEC).asm
	$(AS) $(ASFLAGS) -o $@ $<

$(LIBS).o: $(LIBS).asm
	$(AS) $(ASFLAGS) -o $@ $<

.PHONY: clean

clean:
	rm -fv $(EXEC)
	rm -fv *.o
