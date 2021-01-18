; Executable name: eatsyscall
; Version:         1.0
; Description:     A simple assembly app for Linux, using NASM,
;                  demonstrating the use of Linux INT 80H syscalls
;                  to display text.
;
; Build with:
;   nasm -f elf -g -F stabs eatsyscall.asm
;   ld -m elf_i386 -o eatsyscall eatsyscall.o
;

SECTION .data                   ; Section containing initialized data

EatMsg: db "Eat at Joe's!", 10
EatLen: equ $-EatMsg

SECTION .bss                    ; Section containing uninitialized data
SECTION .text                   ; Section containing code

global _start                   ; Entry point for the linker

_start:
  nop                           ; This no-op keeps gdb happy
  mov eax,4                     ; Specify sys-write syscall
  mov ebx,1                     ; File-descriptor 1: stdout
  mov ecx,EatMsg                ; Pass offset of the message
  mov edx,EatLen                ; Pass length of message
  int 80H                       ; Make syscall to output text to stdout

  mov eax,1                     ; Specify Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80H                       ; Make syscall for termination of program
