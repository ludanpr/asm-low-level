; File: uppercaser1.asm
;
; Reads a file stream and converts all characters to uppercase
;
section .bss
  Buff resb 1

section .data

section .text
  global _start

_start:
  nop

Read:
  mov eax,3                     ; sys_read call specifier
  mov ebx,0                     ; standard input
  mov ecx,Buff
  mov edx,1                     ; Read 1 character from stdin
  int 80h                       ; Call sys_read

  cmp eax,0                     ; if EOF
  je Exit

  cmp byte [Buff],61h           ; lowercase 'a'
  jb Write                      ; if below 'a' in ASCII chart
  cmp byte [Buff],7Ah           ; lowercase 'z'
  ja Write                      ; if above 'z' in ASCII chart

  sub byte [Buff],20h           ; Transform to uppercase

Write:
  mov eax,4                     ; sys_write call specifier
  mov ebx,1                     ; standard output
  mov ecx,Buff
  mov edx,1                     ; number of characters to write
  int 80h
  jmp Read

Exit:
  mov eax,1                     ; Exit Syscall specifier
  mov ebx,0                     ; return code
  int 80h
