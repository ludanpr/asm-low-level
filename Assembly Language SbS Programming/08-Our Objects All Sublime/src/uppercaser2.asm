; File: uppercaser2.asm
;
; Linux text file I/O (through redirection), force lower case characters
; to uppercase and write result to output file.
;
; Assembler: NASM (Linux)
; Usage: uppercase2 < <input file> > <output file>
;
section .bss
  BUFFLEN equ 1024
  Buff: resb BUFFLEN

section .data
  ReadError: db "An error occurred during sys_read",10
  ReadErrorLen: equ $-ReadError
  WriteError: db "An error occurred during sys_write",10
  WriteErrorLen:  equ $-WriteError

section .text
  global _start

_start:
  nop

  ; Read buffer from stdin
read:
  mov eax,3                     ; sys_read call specifier
  mov ebx,0                     ; stdin file descriptor
  mov ecx,Buff                  ; Offset of the buffer to read to
  mov edx,BUFFLEN               ; Number of bytes to read at one pass
  int 80h
  mov esi,eax                   ; Number of bytes read from stdin
  cmp eax,0                     ; compare return value from sys_read
  jb read_error                 ; if < 0, error
  je done                       ; if 0, EOF found

  ; Process buffer
  mov ecx,esi                   ; Number of bytes read
  mov ebp,Buff                  ; Address of buffer
  dec ebp                       ; Adjust count to offset (one less than Buff real address)

scan:
  cmp byte [ebp+ecx],61h        ; Test character against lowercase 'a'
  jb next                       ; jump if below
  cmp byte [ebp+ecx],7Ah        ; Test character against lowercase 'z'
  ja next                       ; jump if above

  sub byte [ebp+ecx],20h        ; Transform lowercase to uppercase
next:
  dec ecx
  jnz scan

  ; Write buffer
write:
  mov eax,4                     ; sys_write call specifier
  mov ebx,1                     ; stdout file descriptor
  mov ecx,Buff
  mov edx,esi                   ; Number of bytes of data in the buffer
  int 80h
  cmp eax,0                     ; compare return value from sys_write
  jb write_error                ; if < 0, error
  jmp read

read_error:
  mov eax,4
  mov ebx,2
  mov ecx,ReadError
  mov edx,ReadErrorLen
  int 80h
  jmp done

write_error:
  mov eax,4
  mov ebx,2
  mov ecx,WriteError
  mov edx,WriteErrorLen
  int 80h
  jmp done

done:
  mov eax,1                     ; Exit syscall specifier
  mov ebx,0                     ; 0 return code
  int 80h
