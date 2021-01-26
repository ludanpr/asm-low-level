
  ; Description: A sandbox for running assembly experiments
; NOTE: to be used with a debugger
section .data
  Snippet db "KANGAROO"

section .text
global _start

_start:
  nop
  mov ebx,Snippet
  mov eax,8
more:
  add byte [ebx],32             ; Add 32 to value in BX (Converts upper character to lower)
  inc ebx
  dec eax
  jnz more

  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Syscall to terminate the program

section .bss
