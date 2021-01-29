AS=nasm
LDFLAGS=-m elf_i386
EXEC=uppercaser1
ASFLAGS=-f elf -g -F stabs

$(EXEC): $(EXEC).o
	ld -o $@ $< $(LDFLAGS)

$(EXEC).o: $(EXEC).asm
	$(AS) $(ASFLAGS) $<

.PHONY: clean

clean:
	rm -fv $(EXEC)
	rm -fv *.o
