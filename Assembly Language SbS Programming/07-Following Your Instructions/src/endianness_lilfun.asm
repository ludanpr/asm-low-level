; Description: A sandbox for running assembly experiments
; NOTE: to be used with a debugger
section .data
  number dw 0x12A
section .text

  global _start

_start:
  nop
  mov eax,"WXYZ"                ; as a string, 'W' is interpreted as the lsb
  mov ebx,"1234"                ; as a string, '1' is interpreted as the lsb
  mov ecx,0x31323334            ; a number, 0x34 is interpreted as the lsb

  and eax,0x00                  ; zero out to reuse it
  and ebx,0x00
  and ecx,0x00

  mov ax,0x067FE                ; 16-bit
  mov bx,ax                     ; 16-bit
  mov cl,bh                     ; 8-bit: move higher 8 bits of BX (0x67) to lower 8 bits of CX
  mov ch,bl                     ; 8-bit: move lower 8 bits of BX (0xFE) to higher 8 bits of CX
  xchg cl,ch                    ; exchanges values of CL and CH

  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Syscall to terminate program

section .bss
