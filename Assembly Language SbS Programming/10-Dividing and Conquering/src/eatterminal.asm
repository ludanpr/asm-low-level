; x86 Assembly file: eatterminal.asm
; Assembler        : NASM
; Description      : Use of scape sequences to do simple "full-screen" text output.
;

section .bss

section .data
  SCREENWIDTH: equ 80
  PosTerm: db 27,"[01;01H"      ; <ESC>[<Y>;<X>H
  POSLEN: equ $-PosTerm
  ClearTerm: db 27,"[2J"        ; <ESC>[2J
  CLEARLEN: equ $-ClearTerm
  AdMsg: db "This is Linux assembly programming!"
  ADLEN: equ $-AdMsg
  Prompt: db "Press Enter: "
  PROMPTLEN: equ $-Prompt

  ; This table gives pairs of ASCII digits from 0-80. Rather than calculate ASCII
  ; digits to insert in the terminal control string, we look them up in the table
  ; and read back two digits at once to a 16-bit register like DX, which we  then
  ; poke into the terminal control string PosTerm at the appropriate place.
  ;
  ; If intended to work on a larger console than 80x80, you must  add  additional
  ; ASCII digit encoding to the end of Digits.
  ;
  ; The code shown here will only work up to 99x99.
  Digits:
    db "0001020304050607080910111213141516171819"
    db "2021222324252627282930313233343536373839"
    db "4041424344454647484950515253545556575859"
    db "606162636465666768697071727374757677787980"

section .text

;----------------------------------------------------------------
; clr_scr: Clear the Linux console.
; Description: Sends the predefined control string <ESC>[2J to the
;              console, which clears the full display.
; Input:    -
; Returns:  -
; Modifies: -
;
clr_scr:
  push eax
  push ebx
  push ecx
  push edx
  mov ecx,ClearTerm
  mov edx,CLEARLEN
  call write_str
  pop edx
  pop ecx
  pop ebx
  pop eax
  ret

;----------------------------------------------------------------
; gotoxy: Position the Linux Console cursor to an x,y position
; Description: Prepares a terminal control string for the x,y
;              coordinates passed in AL and AH and calls sys_write
;              to position the console cursor to that x,y position.
;              Writing text to the console after calling gotoxy will
;              begin display of text at the x,y position.
; Input: X in AH, Y in AL.
; Returns: -
; Modifies: PosTerm terminal control sequence string.
;
gotoxy:
  pushad
  xor ebx,ebx
  xor ecx,ecx

  mov bl,al                     ; Put y value into scale term EBX
  mov cx,word [Digits+ebx*2]    ; Fetch decimal digits to CX
  mov word [PosTerm+2],cx       ; Poke digits into control string
  mov bl,ah                     ; Put x value into scale term EBX
  mov cx,word [Digits+ebx*2]    ; Fetch decimal digits to CX
  mov word [PosTerm+5],cx       ; Poke digits into control string

  mov ecx,PosTerm
  mov edx,POSLEN
  call write_str

  popad
  ret

;----------------------------------------------------------------
; write_ctr: Send a string centered to an 80-char wide Linux console
; Description: Displays a string to the Linux console centered in an
;              80-column display. Calculates the x fot the passed-in
;              string length, then calls gotoxy and write_str to send
;              the string to the console.
; Input: y value in AL
;        String address in ECX
;        String length in EDX
; Returns: -
; Modifies: PosTerm terminal control sequence string.
;
write_ctr:
  push ebx
  xor ebx,ebx
  mov bl,SCREENWIDTH
  sub bl,dl                     ; Difference of screen width and string length
  shr bl,1                      ; Half diff is x value
  mov ah,bl                     ; gotoxy requires x value in AH
  call gotoxy
  call write_str
  pop ebx
  ret

;----------------------------------------------------------------
; write_str: Send a string to the Linux console.
; Description: Displays a string to the Linux console through a
;              sys_write kernel call.
; Input: String address in ECX
;        String length in EDX
; Returns:  -
; Modifies: -
;
write_str:
  push eax
  push ebx

  mov eax,4                     ; Specify sys_write syscall
  mov ebx,1                     ; stdout file descriptor
  int 80h

  pop ebx
  pop eax
  ret


  global _start

_start:
  nop

  call clr_scr

  mov al,12                     ; Specify line 12
  mov ecx,AdMsg
  mov edx,ADLEN
  call write_ctr

  ; Position cursor for Prompt
  mov ax,0117h                  ; x,y = 1, 23
  call gotoxy

  mov ecx,Prompt
  mov edx,PROMPTLEN
  call write_str

  ; Wait for the user to press enter
  mov eax,3                     ; Specify sys_read syscall
  mov ebx,0                     ; stdin file descriptor
  int 80h

exit:
  mov eax,1                     ; Specify Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80h
