; Description: A sandbox for running assembly experiments
; NOTE: to be used with a debugger
section .data
section .text

  global _start

_start:
  nop
  mov eax,42
  mov ebx,42
  neg eax                       ; Negates its operand (in two's complement)
  neg eax
  neg ebx
  add eax,ebx

  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Syscall to terminate the program

section .bss
