# Gas, Linux (64-bit)

.data
array: .long 3, 2, 6, 4, 1, 18, 5
count: .long 7

.text
.global _start
_start:

movslq count(%rip), %rcx
dec %rcx

outer_loop:
  push %rcx
  leaq array(%rip), %rsi

inner_loop:
  movl (%rsi), %eax
  cmpl %eax, 4(%rsi)
  jg next_step
  xchgl 4(%rsi), %eax
  movl %eax, (%rsi)

next_step:
  addq $4, %rsi
  loop inner_loop
  popq %rcx
  loop outer_loop

movq $60, %rax
xorq %rdi, %rdi
syscall
.end
