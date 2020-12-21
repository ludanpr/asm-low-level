# Gas, Linux (32-bit)
# as --32 && ld -m elf_i386

.data
array: .long 3, 2, 6, 4, 1, 18, 5
count: .long 7

.text
.globl _start
_start:

mov count, %ecx
dec %ecx

outer_loop:
  push %ecx
  lea array, %esi

inner_loop:
  mov (%esi), %eax
  cmp %eax, 4(%esi)
  jg next_step
  xchg 4(%esi), %eax
  mov %eax, (%esi)

next_step:
  add $4, %esi
  loop inner_loop
  pop %ecx
  loop outer_loop

movl $1, %eax
movl $0, %ebx
int $0x80
.end
