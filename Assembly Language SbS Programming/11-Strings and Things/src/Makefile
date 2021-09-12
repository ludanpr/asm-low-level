# -f elf64 for 64 bit mode and no LDFLAGS (64-bit by default on LD linker)
#
AS      = nasm
ASFLAGS = -f elf -g -F stabs
LDFLAGS = -m elf_i386
EXEC    = vidbuff1

$(EXEC): $(EXEC).o
	ld -o $@ $< $(LDFLAGS)

$(EXEC).o: $(EXEC).asm
	$(AS) $(ASFLAGS) -o $@ $<

PHONY: clean

clean:
	rm -fv $(EXEC)
	rm -fv *.o
