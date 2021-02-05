; File: hexdump1.asm
;
; Assembler: NASM
; Description: This program demonstrates the conversion of binary values to hexadecimal
;              strings.
; Usage: ./hexdump1 < <input file>
;
section .bss
  BUFFLEN equ 16
  Buff: resb BUFFLEN

section .data
  HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
  HEXLEN equ $-HexStr
  Digits: db "0123456789ABCDEF"

section .text
  global _start

_start:
  nop

  ; Read buffer from stdin
read:
  mov eax,3                     ; sys_read specifier
  mov ebx,0                     ; stdin file descriptor
  mov ecx,Buff                  ; Buffer to Read to
  mov edx,BUFFLEN
  int 80h
  mov ebp,eax                   ; Count of bytes read from stdin
  cmp eax,0                     ; EOF found if 0
  je done

  ; Set up for process buffer
  mov esi,Buff
  mov edi,HexStr                ; Line string
  xor ecx,ecx                   ; This will be line string pointer

scan:
  xor eax,eax

  ; Calculate offset into HexStr (ECX * 3)
  mov edx,ecx                   ; Copy character counter
  shl edx,1
  add edx,ecx

  ; Get a byte from buffer
  mov al,byte [esi+ecx]
  mov ebx,eax                   ; Duplicate byte into BL

  ; Look up low nybble character and insert it into the string
  and al,0Fh                    ; Mask out all but the low nybble
  mov al,byte [Digits+eax]      ; Look up equivalent character
  mov byte [HexStr+edx+2],al    ; Write LSB char digit to line string

  ; Loop up high nybble character and insert it into the string
  shr bl,4                      ; Shift highest nybble of BL to lower nybble of BL
  mov bl,byte [Digits+ebx]      ; Look up equivalent character
  mov byte [HexStr+edx+1],bl    ; Write MSB char digit to line string

  inc ecx                       ; Increment line string pointer
  cmp ecx,ebp                   ; Compare to number of bytes in the buffer
  jna scan

  ; Write to stdout
  mov eax,4                     ; sys_write speficier
  mov ebx,1                     ; stdout file descriptor
  mov ecx,HexStr
  mov edx,HEXLEN
  int 80h

  jmp read

done:
  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; 0 return code
  int 80h
