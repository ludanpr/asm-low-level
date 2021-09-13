;----------------------------------------------------------------------------------
; Intel 64 NASM Assembly file: vidbuff1L.asm
; Assembler                  : NASM
; Description                : A simple program in assembly for Linux demonstrating
;                              string instruction operation by "faking" full-screen
;                              memory-mapped text I/O.
;----------------------------------------------------------------------------------

section .data
  EOL     equ 10                 ; Linux end-of-line character
  FILLCHR equ 32                 ; ASCII space character
  HBARCHR equ '-'                ; Use dash character if this won't display
  STRTROW equ 2                  ; Row where the graph begins

  ;---------------------------------------------
  ; A table of byte-length numbers
  ;---------------------------------------------
  Dataset db 9,71,17,52,55,18,29,36,18,68,77,63,58,44,0

  Message db "Data current as of 11/09/2021"
  MSGLEN  equ $-Message

  ;---------------------------------------------------------------------------
  ; This escape sequence will clear the console terminal and place the text
  ; cursor to the origin (1,1) on virtually all Linux consoles:
  ;---------------------------------------------------------------------------
  ClrHome db 27,"[2J",27,"[01;01H"
  CLRLEN  equ $-ClrHome

section .bss
  COLS equ 81                   ; Line length + 1 character for EOL
  ROWS equ 25                   ; Number of lines in display
  VidBuff resb COLS*ROWS

section .text
  global _start

;-----------------------------------------------------------
; ClearTerminal: This macro clears the Linux console terminal
; and sets the cursor position to 1,1, using a single predefined
; escape sequence.
;-----------------------------------------------------------
%macro ClearTerminal 0
  push rax
  push rbx
  push rcx
  push rdx

  mov rax,4                     ; sys_write syscall
  mov rbx,1                     ; File descriptor 1, stdout
  mov rcx,ClrHome               ; Pass offset of the error message
  mov rdx,CLRLEN

  int 80h

  pop rdx
  pop rcx
  pop rbx
  pop rax
%endmacro

;-----------------------------------------------------------
; Show: Display a text buffer to the Linux console.
;
; Sends the buffer VidBuff to the Linux console via sys_write.
; The number of bytes sent to the console is calculated by
; multiplying the COLS equate by the ROWS equate.
;
; IN      : NOTHING
; OUT     : NOTHING
; MODIFIES: NOTHING
;-----------------------------------------------------------
Show:
  push rax
  push rbx
  push rcx
  push rdx

  mov rax,4                     ; sys_write syscall
  mov rbx,1                     ; stdout fd
  mov rcx,VidBuff
  mov rdx,COLS*ROWS

  int 80h

  pop rdx
  pop rcx
  pop rbx
  pop rax
  ret

;-----------------------------------------------------------
; ClrVid: Clears a text buffer to spaces and replaces all
;         EOLs.
;
; Fills the buffer VidBuff with a predefined character (FILLCHR)
; and then places an EOL character at the end of every line,
; where a line ends every COLS bytes in VidBuff.
;
; IN      : NOTHING
; OUT     : NOTHING
; MODIFIES: VidBuff, DF
;-----------------------------------------------------------
ClrVid:
  push rax
  push rcx
  push rdi

  cld                           ; Clear DF, we're counting up-memory

  mov al,FILLCHR
  mov rdi,VidBuff               ; Destination for string instruction
  mov rcx,COLS*ROWS             ; Count of chars
  rep stosb                     ; Blast characters at the buffer (by in-CPU loop)

  ; Now insert EOL at every COLS bytes
  mov rdi,VidBuff
  dec rdi                       ; Start EOL position count at VidBuff char 0
  mov rcx,ROWS
PutEOL:
  lea rdi,[rdi+COLS]            ; add rdi,COLS
  mov byte [rdi],EOL
  loop PutEOL                   ; Loop back if still more lines

  pop rdi
  pop rcx
  pop rax
  ret

;-----------------------------------------------------------
; WrtLn: Writes a string to a text buffer at a 1-based X,Y
;        position.
;
; Uses REP MOVSB to copy a string from the address in RSI to
; an X,Y location in the text buffer VidBuff.
;
; IN      : RSI - the address of the string
;           RBX - The 1-based X position (row #)
;           RAX - The 1-based Y position (col #)
;           RCX - The length of the string in characters
; OUT     : NOTHING
; MODIFIES: VidBuff, RDI, DF
;-----------------------------------------------------------
WrtLn:
  push rax
  push rbx
  push rcx
  push rdi

  cld                           ; Clear DF for up-memory write

  mov rdi,VidBuff
  dec rax                       ; Adjust Y value down by 1 for address calculation
  dec rbx                       ; Adjust X value down by 1 for address calculation
  mov ah,COLS                   ; Assumes Y position fits in 8-bit AL
  mul ah                        ; 8-bit multiply AL*AH to AX
  lea rdi,[rdi+rax]             ; Add Y offset into VidBuff to RDI
  lea rdi,[rdi+rbx]             ; Add X offset into VidBuff to RDI
  rep movsb                     ; Blast the string into the buffer

  pop rdi
  pop rcx
  pop rbx
  pop rax
  ret

;-----------------------------------------------------------
; WrtHB: Generates a horizontal line bar at X,Y in text buffer.
;
; Writes a horizontal bar to the video buffer VidBuff, at
; the 1-based X,Y values passed in RBX,RAX. The bar is "made of"
; the character in the equate HBARCHR. The default is character
; 196.
;
; IN      : RAX - the 1-based Y position (row #)
;           RBX - the 1-based X position (col #)
;           RCX - the length of the bar in chars
; OUT     : NOTHING
; MODIFIES: VidBuff, DF
;-----------------------------------------------------------
WrtHB:
  push rax
  push rbx
  push rcx
  push rdi

  cld                           ; Clear DF for up-memory write

  mov rdi,VidBuff
  dec rax                       ; Adjust Y value down by 1 for address calculation
  dec rbx                       ; Adjust X value down by 1 for address calculation
  mov ah,COLS                   ; Assumes Y position fits in 8-bit AL
  mul ah                        ; 8-bit multiply AL*AH to AX
  lea rdi,[rdi+rax]             ; Add Y offset into VidBuff to RDI
  lea rdi,[rdi+rbx]             ; Add X offset into VidBuff to RDI
  mov al,HBARCHR
  rep stosb                     ; Blast the bar char into the buffer

  pop rdi
  pop rcx
  pop rbx
  pop rax
  ret

;-----------------------------------------------------------
; Ruler: Generates a "1234567890"-style ruler at X,Y in text
;        buffer.
;
; Writes a ruler to the video buffer VidBuff, at the 1-based
; X,Y position passed RBX,RAX. The ruler consists of a repeating
; sequence of the digits 1 through 0. The ruler will wrap to
; subsequent lines and overwrite whatever EOL characters fall
; within its length, if it will not fit entirely on the line
; where it begins. Note that the `Show` procedure must be called
; after Ruler to display the ruler on the console.
;
; IN      : RAX - the 1-based Y position (row #)
;           RBX - the 1-based X position (col #)
;           RCX - the length of the ruler in chars
; OUT     : NOTHING
; MODIFIES: VidBuff
;-----------------------------------------------------------
Ruler:
  push rax
  push rbx
  push rcx
  push rdi
  push rbp

  mov rdi,VidBuff
  dec rax                       ; Adjust Y value down by 1 for address calculation
  dec rbx                       ; Adjust X value down by 1 for address calculation
  mov ah,COLS                   ; Assumes that Y position fits into 8-bit AL
  mul ah                        ; 8-bit multiply AH*AL in AX
  lea rdi,[rdi+rax]             ; Add Y offset into VidBuff to RDI
  lea rdi,[rdi+rbx]             ; Add X offset into VidBuff to RDI

  ; RDI now contains the memory address in the buffer where the
  ; ruler is to begin. Now we display the ruler, starting at that
  ; position
  mov rbp,Rler
  xor rbx,rbx
DoChar:
  mov al,byte [rbp+rbx]
  stosb
  inc rbx
  and rbx,RLERLEN-1             ; effect of increment modulo RLERLEN (only powers of 2)
  loop DoChar

  pop rbp
  pop rdi
  pop rcx
  pop rbx
  pop rax
  ret
Rler    db "0123456789ABCDEF"
RLERLEN equ $-Rler

;-----------------------------------------------------------
; MAIN
;-----------------------------------------------------------
_start:
  nop

  ClearTerminal
  call ClrVid

  ; Top ruler
  mov rax,1                     ; Load Y position to AL
  mov rbx,1                     ; Load X position to BL
  mov rcx,COLS-1                ; Load ruler length
  call Ruler

  ; Dataset
  mov rsi,Dataset
  mov rbx,1                     ; Start all bars at left margin (X = 1)
  mov rbp,0                     ; Dataset elemento index starts at zero
.blast:
  mov rax,rbp                   ; Add dataset number to element index
  add rax,STRTROW               ; Bias row value by row number of first bar
  mov cl, byte [rsi+rbp]        ; dataset value
  cmp rcx,0                     ; Se if we pulled a zero from the dataset
  je .rule2                     ; If we pulled a zero, we're done

  call WrtHB                    ; Graph the data as a horizontal bar
  inc rbp                       ; Increment the dataset element index
  jmp .blast

  ; Bottom ruler
.rule2:
  mov rax,rbp                   ; Use the dataset counter to set the ruler row
  add rax,STRTROW               ; Bias down by the row number of the first bar
  mov rbx,1                     ; Load X position into BL
  mov rcx,COLS-1                ; Load ruler length
  call Ruler

  ; Message
  mov rsi,Message
  mov rcx,MSGLEN
  mov ebx,COLS                  ; Screen width
  sub rbx,rcx                   ; Calculate difference of message length and screen length
  shr rbx,1                     ; Divide difference by 2 for X value
  mov rax,24                    ; Set message row to Line 24
  call WrtLn

  ; Having written all to the buffer, send the buffer to the console
  call Show

Exit:
  mov rax,1                     ; Exit syscall
  mov rbx,0                     ; return code
  int 80h
