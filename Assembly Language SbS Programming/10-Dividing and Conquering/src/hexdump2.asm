; x86 assembly file: hexdump2.asm
; Assembler        : NASM
; Description      : A simple hex dump utility for Linux.
;

section .bss
  BUFFLEN equ 10
  Buff resb BUFFLEN

section .data
  ; Following is two parts of a single data structure, implementing the text
  ; line of a hex dump utility. The first part displays 16 bytes in hex separated
  ; by spaces. Immediately following is a 16-character line delimited by vertical
  ; bar characters. The two parts are ajacent.
  DumpLine: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DUMPLEN equ $-DumpLine
  ASCLine: db "|................|",10
  ASCLEN equ $-ASCLine
  FULLLEN equ $-DumpLine

  ; The hex digits table used to convert numeric values to their hex equivalents.
  HexDigits: db "0123456789ABCDEF"

  ; This table is used for ASCII character translation. All printable characters
  ; are translated to themselves; The highest 128 characters are translated to
  ; ASCII period (2Eh); The non-printable characters in the lowest 128 are also
  ; translated to ASCII period.
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

;----------------------------------------------------------------
; clear_line: Clear a hex dump line string to 16 0 values.
; Description: The hex dump line string is cleared to binary 0
;              by calling dump_char 16 times, passing it 0 each
;              time.
; Input:    -
; Returns:  -
; Modifies: -
;
clear_line:
  pushad                        ; Save all caller's GP resgisters
  mov edx,15                    ; Upper bound of '0' pokes
.poke:
  mov eax,0                     ; Tell dump_char to poke a '0'
  call dump_char
  sub edx,1                     ; Using SUB (DEC doesn't affect CF)
  jae .poke                     ; Jump if CF=0, that is, EDX >= 0
  popad                         ; Restore caller's GP registers
  ret

;----------------------------------------------------------------
; dump_char: "Poke" a value into the hex dump line string.
; Description: The value passed in EAX will be put in both the
;              hex dump portion and in the ASCII portion, at the
;              position passed in EDX, represented by a space where
;              it is not a printable character.
; Input: Pass the 8-bit value to be poked in EAX.
;        Pass the value's position in the line (0-15) in EDX
; Returns: -
; Modifies: EAX, ASCLine, DumpLine
;
dump_char:
  push ebx
  push edi

  ; Insert input character into the ASCII portion of the dump line
  mov bl,byte [DotXlat+eax]
  mov byte [ASCLine+edx+1],bl

  ; Insert hex equivalent of input character in the hex portion
  mov ebx,eax                   ; Save copy of input character
  lea edi,[edx*2+edx]           ; Save effective address of offset into DumpLine

  ; Lookup low nybble character and insert it into the DumpLine string
  and eax,0000000Fh             ; Mask out all but low nybble
  mov al,byte [HexDigits+eax]   ; Lookup hex character
  mov byte [DumpLine+edi+2],al

  ; Look up high nybble character and insert it into the DumpLine string
  and ebx,000000F0h
  shr ebx,4
  mov bl,byte [HexDigits+ebx]
  mov byte [DumpLine+edi+1],bl

  pop edi
  pop ebx
  ret

;----------------------------------------------------------------
; print_line: Displays DumpLine to stdout.
; Description: The hex dump line string DumpLine is displayed to
;              stdout sys_write. All GP registers are preserved.
; Inputs:    -
; Returns:  -
; Modifies: -
;
print_line:
  pushad
  mov eax,4                     ; Specify sys_write syscall
  mov ebx,1                     ; stdout file descriptor
  mov ecx,DumpLine
  mov edx,FULLLEN
  int 80h
  popad
  ret

;----------------------------------------------------------------
; load_buffer: Fills a buffer with data from stdin via sys_read.
; Description: Loads a buffer full of data (BUFFLEN bytes) from
;              stdin using sys_read and places it in Buff. Buffer
;              offset counter ECX is zeroed, because we're starting
;              in on a new buffer full of data. Caller must test
;              value in EBP: if EBP contains zero on return, we hit
;              EOF on stdin. Return value < 0 indicates an error.
; Inputs: -
; Returns: Number of bytes read, in EBP
; Modifies: ECX, EBP, Buff
;
load_buffer:
  push eax
  push ebx
  push edx

  mov eax,3                     ; Specify sys_read syscall
  mov ebx,0                     ; stdin file descriptor
  mov ecx,Buff
  mov edx,BUFFLEN
  int 80h

  mov ebp,eax
  xor ecx,ecx

  pop edx
  pop ebx
  pop eax
  ret


  global _start
;-----------------------------
; Main program
;-----------------------------
_start:
  nop
  nop

  ; Initialization
  xor esi,esi                   ; Total byte counter (characters processed)
  call load_buffer
  cmp ebp,0                     ; EOF reached if zero, error encountered if < 0
  jbe exit

  ; Convert binary byte values to hex digits
scan:
  xor eax,eax
  mov al,byte [Buff+ecx]
  mov edx,esi                   ; Total processed count into EDX
  and edx,0000000Fh             ; Optimized EDX modulus 16
  call dump_char

  inc esi                       ; Increment total characters processed counter
  inc ecx                       ; Increment buffer pointer
  cmp ecx,ebp
  jb .mod_test

  call load_buffer
  cmp ebp,0
  jbe done

  ; Test if we are at the end of a block of 16 and need to display a line
.mod_test:
  test esi,0000000Fh            ; Optimized ESI modulus 16 test. If AND ESI,0000000FH is zero, print line
  jnz scan                      ; Loop to SCAN if ZF is not 1, that is, ESI modulus 16 is not 0
  call print_line
  call clear_line
  jmp scan

done:
  call print_line
exit:
  mov eax,1                     ; Exit syscall
  mov ebx,ebp                   ; Return status code
  int 80h
