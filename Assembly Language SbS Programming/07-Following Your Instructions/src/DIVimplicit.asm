; Description: A sandbox for running assembly experiments
; NOTE: to be used with a debugger
section .data
section .text

  global _start

_start:
  nop
  mov bl,5                      ; Divisor
  mov al,251                    ; Dividend (implicit)
  div bl                        ; Result goes to AL (remainder goes to AH)
  xor bl,bl
  xor ax,ax

  mov cx,7                      ; Divisor
  mov ax,983                    ; Dividend (implicit)
  div cx                        ; Result goes to AX (remainder goes do DX)
  xor ax,ax
  xor dx,dx

  mov ebx,1321                  ; Divisor
  mov eax,1000000               ; Dividend (implicit)
  div ebx                       ; Result goes to EAX (remainder goes to EDX)
  xor eax,eax
  xor ebx,ebx
  xor cx,cx
  xor edx,edx

  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Syscall to terminate the program

section .bss
