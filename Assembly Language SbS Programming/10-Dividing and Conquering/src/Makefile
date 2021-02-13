AS=nasm
ASFLAGS=-g -f elf -F stabs
LDFLAGS=-m elf_i386
EXEC=hexdump2

$(EXEC): $(EXEC).o
	ld $< -o $@ $(LDFLAGS)

$(EXEC).o: $(EXEC).asm
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: clean

clean:
	rm -fv $(EXEC)
	rm -fv *.o
