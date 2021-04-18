#
AS=nasm
ASFLAGS=-f elf -g -F stabs
LDFLAGS=-m elf_i386
EXEC=vidbuff1

$(EXEC): $(EXEC).o
	ld -o $@ $< $(LDFLAGS)

$(EXEC).o: $(EXEC).asm
	$(AS) $(ASFLAGS) -o $@ $<

PHONY: clean

clean:
	rm -fv $(EXEC)
	rm -fv *.o
