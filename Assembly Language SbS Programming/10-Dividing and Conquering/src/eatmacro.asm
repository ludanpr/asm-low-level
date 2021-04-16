 ; x86 Assembly file: eatmacro.asm
 ; Assembler        : NASM
 ; Description      : Use of scape sequences to do simple "full-screen" text output
 ;                    by using macros instead of procedures.
 ;
section .bss

section .data                   ; initialized
  SCREENWIDTH: equ 80
  PosTerm: db 27,"[01;01H"      ; <ESC>[<Y>;<X>H
  POSLEN: equ $-PosTerm
  ClearTerm: db 27,"[2J"        ; <ESC>[2J; clears display
  CLEARLEN: equ $-ClearTerm
  AdMsg: db "This is Linux assembly language programming!"
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
  Digits: db "0001020304050607080910111213141516171819"
          db "2021222324252627282930313233343536373839"
          db "4041424344454647484950515253545556575859"
          db "606162636465666768697071727374757677787980"

section .text

;------------------------------------------------------------
; ExitProg: Terminate program and return to Linux.
; Description: Calls sys_exit to terminate the program and
;              return control do Linux.
; Input:    -
; Returns:  -
; Modifies: -
;
%macro ExitProg 0
  mov eax,1                     ; Specify Exit syscall
  mov ebx,0                     ; Return 0 code
  int 80h
%endmacro

;------------------------------------------------------------
; WaitEnter: Wait for the user to press Enter at the console.
; Description: Calls sys_read to wait for the user to type a
;              newline at the console.
; Input:    -
; Returns:  -
; Modifies: -
;
%macro WaitEnter 0
  mov eax,3                     ; Specify sys_read
  mov ebx,0                     ; stdin file descriptor
  int 80h
%endmacro

;------------------------------------------------------------
; WriteStr: Send a string to the Linux console.
; Description: Displays a string to the Linux console through
;              a sys_write kernel call.
; Input: String address in %1, string length in %2
; Returns:  -
; Modifies: -
;
%macro WriteStr 2               ; %1 = String address, %2 = String length
  push eax
  push ebx
  mov eax,4                     ; Specify sys_write
  mov ebx,1                     ; stdout file descriptor
  mov ecx,%1
  mov edx,%2
  int 80h
  pop ebx
  pop eax
%endmacro

;------------------------------------------------------------
; ClrScr: Clear the Linux console.
; Description: Sends the predefined control string <ESC>[2J
;              to the console, which clears the full display.
; Input:    -
; Returns:  -
; Modifies: -
;
%macro ClrScr 0
  push eax
  push ebx
  push ecx
  push edx
  WriteStr ClearTerm,CLEARLEN
  pop edx
  pop ecx
  pop ebx
  pop eax
%endmacro

;------------------------------------------------------------
; GotoXY: Position the Linux Console cursor to an X,Y position.
; Description: Prepares a terminal control string for the X,Y
;              coordinates passed in AL and AH and calls sys_write
;              to position the console cursor to that X,Y position.
;              Writing text to the console after calling GotoXY
;              will begin display of text at that X,Y position.
; Input: X in %1, Y in %2
; Returns: -
; Modifies: PosTerm terminal control sequence string
;
%macro GotoXY 2
  pushad
  xor edx,edx
  xor ecx,ecx

  ; Poke Y digits
  mov dl,%2
  mov cx,word [Digits+edx*2]
  mov word [PosTerm+2],cx

  ; Poke X digits
  mov dl,%1
  mov cx,word [Digits+edx*2]
  mov word [PosTerm+5],cx

  WriteStr PosTerm,POSLEN
  popad
%endmacro

;------------------------------------------------------------
; WriteCtr: Send a string centered to an 80-char-wide Linux
;           console.
; Description: Displays a string to the Linux console centered
;              in an 80-column display. Calculates the X for
;              the passed-in string length, then calls GotoXY
;              and WriteStr to send the string to the console.
; Input: Y value in %1, String address in %2, String length in %3
; Returns: -
; Modifies: PosTerm terminal control sequence string.
;
%macro WriteCtr 3
  push ebx
  push edx
  mov edx,%3

  xor ebx,ebx
  mov bl,SCREENWIDTH
  sub bl,dl
  shr bl,1
  GotoXY bl,%1
  WriteStr %2,%3

  pop edx
  pop ebx
%endmacro


  global _start

_start:
  nop

  ClrScr
  WriteCtr 12,AdMsg,ADLEN       ; Ad message centered on the 80-wide console
  GotoXY 1,23                   ; Position cursor for prompt
  WriteStr Prompt,PROMPTLEN
  WaitEnter

  ExitProg
