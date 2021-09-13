;-----------------------------------------------------------
; Using MOVSB with overlapping memory blocks.
;
; Examples of useful GDB's syntax for this example (break at `rep movsb`):
;
;   p *((char *) $edi)      # or $<useful-register>
;   p *((char *) $edi + 4)  # access char with offset
;   p ((char *) $edi)[4]    # same as above, but with array syntax
;   p ((char *) $edi)       # or $<useful-register>
;
;-----------------------------------------------------------
section .bss

section .data
  EditBuff db 'abcdefghijklm         ',10
  EBLEN    equ $-EditBuff       ; just for printing
  ENDPOS   equ 12
  INSRTPOS equ 5                ; position to insert a new value

section .text
  global _start

_start:
  nop

  std                           ; Set DF (down memory)

  mov ebx,EditBuff+INSRTPOS     ; Save address of insert point
  mov esi,EditBuff+ENDPOS       ; Start at end of text
  mov edi,EditBuff+ENDPOS+1
  mov ecx,ENDPOS-INSRTPOS+1     ; Number of characters to write
  rep movsb
  mov byte [ebx],' '            ; Write a space at insert point

  ; Show result
  mov eax,4                     ; sys_write
  mov ebx,1                     ; stdout fp
  mov ecx,EditBuff
  mov edx,EBLEN
  int 80h

Exit:
  mov eax,1                     ; Exit syscall
  mov ebx,0
  int 80h
