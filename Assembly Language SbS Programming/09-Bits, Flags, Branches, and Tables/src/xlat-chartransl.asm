; File: xlat-chartransl.asm
;
; Description: Demonstrates the use of translation table.
; Assembler: NASM
;
section .data
  StatMsg: db "*** Processing...",10
  StatLen: equ $-StatMsg
  DoneMsg: db "*** ...done.",10
  DoneLen: equ $-DoneMsg

; The following rules applies to UpCase table
;   * All lowercase ASCII characters are translated to uppercase.
;   * All printable ASCII characters less than 127 that are not lowercase  are
;     translated to themselves. (Not necessary "left alone", but translated to
;     the same characters).
;   * All "high" characters values from 127 through 255 are translated to the
;     ASCII space character (32, or 0x20).
;   * All non-printable ASCII characters (0-31, plus 127) are translated to spaces
;     except values 9 and 10 (horizontal tab and EOL).
;   * Character values 9 and 10 are translated to themselves.
UpCase:
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
  db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
  db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
  db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
  db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
  db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

Custom:
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
  db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
  db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
  db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
  db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
  db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
  db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

section .bss
  READLEN equ 1024
  ReadBuffer: resb READLEN

section .text
  global _start

_start:
  nop

  mov eax,4                     ; sys_write kernel service specifier
  mov ebx,1                     ; stdout file descriptor
  mov ecx,StatMsg
  mov edx,StatLen
  int 80h

read:
  mov eax,3                     ; sys_read kernel service specifier
  mov ebx,0                     ; stdin file descriptor
  mov ecx,ReadBuffer
  mov edx,READLEN
  int 80h
  mov ebp,eax                   ; safe copy sys_read return value (number of bytes read)
  cmp eax,0                     ; If 0, reached EOF
  je done

  ; Set up registers for translation step
  mov ebx,UpCase
  mov edx,ReadBuffer
  mov ecx,ebp                   ; Number of bytes read in ReadBuffer

  ; Translation step (NOTE: the commented out instructions give the same
  ; funcionality as XLAT)
translate:
  ;xor eax,eax                    ; Clear 24 highest bits
  mov al,byte [edx+ecx-1]          ; From end to start of ReadBuffer
  ;mov al,byte [UpCase+eax]       ; Get translated character in AL from look up (translation) table
  xlat
  mov byte [edx+ecx-1],al
  dec ecx
  jnz translate

write:
  mov eax,4                      ; sys_write kernel service specifier
  mov ebx,1                      ; stdout specifier
  mov ecx,ReadBuffer
  mov edx,ebp
  int 80h
  jmp read

done:
  mov eax,4
  mov ebx,1                      ; stdout file descriptor
  mov ecx,DoneMsg
  mov edx,DoneLen
  int 80h

  mov eax,1                      ; Exit syscall
  mov ebx,0                      ; 0 return code
  int 80h
