AS=nasm
EXEC=sandbox
LDFLAGS=-m elf_i386
ASMFLAGS=-f elf -g -F stabs

$(EXEC): $(EXEC).o
	ld -o $@ $@.o $(LDFLAGS)

$(EXEC).o: $(EXEC).asm
	$(AS) $(ASMFLAGS) $(EXEC).asm

.PHONY:	clean

clean:
	rm -fv $(EXEC)
	rm -fv *.o
