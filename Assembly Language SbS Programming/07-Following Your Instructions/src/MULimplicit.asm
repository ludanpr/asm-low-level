; Description: A sandbox for running assembly experiments
; NOTE: to be used with a debugger
section .data
section .text

  global _start

_start:
  nop
  mov bl,45
  mov al,71                     ; Implicit operand (factor 2)
  mul bl                        ; Result goes to implicit operand (product) AX
  xor bl,bl
  xor ax,ax

  mov bx,1001
  mov ax,10001                  ; Implicit operand (factor 2)
  mul bx                        ; Result goes to implicit operand (product) DX + AX
  xor ax,ax

  mov ecx,1000001
  mov eax,1000001               ; Implicit operand (factor 2)
  mul ecx                       ; Result goes to implicit operand (product) EDX + EAX (EDX << 32) + EAX

  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Syscall to terminate the program

section .bss
