; x86 assembly file: textlib.asm
; Assembler        : NASM
; Description      : A linkable library of text-oriented procedures and tables.
;

section .bss
  BUFFLEN equ 10
  Buff resb BUFFLEN

section .data
  ; Following are the two parts of a single useful data structure, implementing the
  ; test line of a hex dump utility. They are adjacent.
  DumpLine: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DUMPLEN equ $-DumpLine
  ASCLine: db "|................|",10
  ASCLEN equ $-ASCLine
  FULLLEN equ $-DumpLine

  HexDigits: db "0123456789ABCDEF"

  ; This table allows for generation of text equivalents for binary numbers.
  ; Index into the table by the nybble using a scale of 4:
  ; [BinDigits+ecx*4]
  BinDigits:
    db "0000","0001","0010","0011"
    db "0100","0101","0110","0111"
    db "1000","1001","1010","1011"
    db "1100","1101","1110","1111"

  ; This table is used for ASCII characters translation, into the ASCII portion of the
  ; hex dump line, via XLAT or ordinary memory lookup. All printable chracters are
  ; translated as themselves. The highest 128 chracters are translated as ASCII period
  ; (2Eh). The non-printable characters in the lowest 128 are also translated as ASCII
  ; period, as is character 127.
  DotXlat:
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
    db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

section .text
  global clear_line, dump_char, new_lines, print_line ; Exported procedures
  global DumpLine, HexDigits, BinDigits               ; Exported data items

;----------------------------------------------------------------
; clear_line: Clear a hex dump line string to 16 0 values.
; Description: The hex dump line string is cleared to binary 0.
; Inputs:   -
; Returns:  -
; Modifies: -
;
clear_line:
  push edx
  mov edx,15
.poke:
  mov eax,0                     ; Tell dump_char to "poke" a '0'
  call dump_char
  sub edx,1                     ; Using SUB (NOTE that DEC doesn't affect CF)
  jae .poke                     ; Loop if EDX >= 0
  pop edx
  ret

;----------------------------------------------------------------
; dump_char: "Poke" a value into the hex dump line string.
; Description: The value passed in EAX will be placed in both the
;              hex dump portion and in the ASCII portion, at the
;              position passed in EDX, represented by a space where
;              it is not a printable character.
; Inputs: Pass the 8-bit value to be poked in EAX.
;         Pass the value's position in the line (0-15) in EDX
; Returns: -
; Modifies: EAX
;
dump_char:
  push ebx
  push edi

  ; First, insert the input character into the ASCII portion of the dump line
  mov bl,byte [DotXlat+eax]     ; Translate ASCII character
  mov byte [ASCLine+edx+1],bl

  mov ebx,eax                   ; Copy input character
  lea edi,[edx*2+edx]           ; Offset into dump line

  ; Insert hex equivalent of input character into hex portion of the dump line
  ; Low nybble
  and eax,0000000Fh             ; Mask to get lower nybble
  mov al,byte [HexDigits+eax]   ; Get hex equivalent
  mov byte [DumpLine+edi+2],al

  ; High nybble
  and ebx,000000F0h
  shr ebx,4
  mov bl,byte [HexDigits+ebx]   ; Get hex equivalent
  mov byte[DumpLine+edi+1],bl

  pop edi
  pop ebx
  ret

;----------------------------------------------------------------
; new_lines: Sends between 1 and 15 newlines to the Linux console.
; Description: The number of newline characters (0Ah) specified in
;              EDX is sent to stdout.
; Inputs: Pass the number of newlines send, from 1 to 15, in EDX
; Returns:  -
; Modifies: -
;
new_lines:
  pushad
  cmp edx,15
  ja .exit
  mov eax,4                     ; Specify sys_write
  mov ebx,1                     ; stdout file descriptor
  mov ecx,EOLs
  int 80h
.exit:
  popad
  ret
EOLs: db 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10

;----------------------------------------------------------------
; print_line: Displays the hex dump line string.
; Description: The hex dump line string is displayed to stdout.
; Inputs:   -
; Returns:  -
; Modifies: -
;
print_line:
  pushad
  mov eax,4                     ; Specify sys_write syscall
  mov ebx,1                     ; stout file descriptor
  mov ecx,DumpLine
  mov edx,FULLLEN
  int 80h
  popad
  ret
