; Description: A sandbox for running assembly experiments
; NOTE: to be used with a debugger
section .data
msg: db "This is a message!", 10

section .text

  global _start

_start:
  nop
  mov eax,0FFFFFFFFH
  mov ebx,02DH
  dec ebx                       ; Decrement EBX by one
  inc eax                       ; Increment EAX by one

  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Syscall to terminate the program

section .bss
