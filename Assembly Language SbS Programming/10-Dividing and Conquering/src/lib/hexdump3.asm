; x86 assembly file: hexdump3.asm
; Assembler        : NASM
; Description      : A Simple hex dump utility for Linux.
;

section .bss
  BUFFLEN equ 10
  Buff resb BUFFLEN

section .data

section .text
  ; Import procedures
  extern clear_line
  extern dump_char
  extern print_line

  global _start

_start:
  nop
  nop
  xor esi,esi                   ; Total characters counter

  ; Read buffer from stdin
read:
  mov eax,3                     ; Specify sys_read syscall
  mov ebx,0                     ; stdin file descriptor
  mov ecx,Buff
  mov edx,BUFFLEN
  int 80h

  mov ebp,eax                   ; Copy read byte count
  cmp eax,0                     ; If 0, EOF
  je done

  xor ecx,ecx                   ; Buffer pointer

  ; Convert buffer binary values to hex digits
scan:
  xor eax,eax
  mov al,byte [Buff+ecx]
  mov edx,esi                   ; Argument to dump_char, offset into dump line
  and edx,0000000Fh             ; Optimized EDX modulus 16
  call dump_char

  inc ecx
  inc esi
  cmp ecx,ebp
  jae read

  ; See if we're at the end of a block of 16 and need to display a line
  test esi,0000000Fh            ; Test ESI modulus 16
  jnz scan                      ; Loop back to SCAN if ZF is not 1, that is, ESI modulus 16 is not 0
  call print_line
  call clear_line
  jmp scan

done:
  call print_line               ; Print leftover
  mov eax,1                     ; Specify Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80h
