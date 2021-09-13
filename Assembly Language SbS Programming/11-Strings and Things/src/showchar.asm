;-----------------------------------------------------------
; x86 NASM assembly: showchar.asm
; Assembler        : NASM
; Description      : Shows a table containing 224 of the 256
;                    ASCII characters.
;-----------------------------------------------------------

section .bss
  COLS    equ 81                   ; Line length + 1 character EOL
  ROWS    equ 25                   ; Number of lines in display
  VidBuff resb COLS*ROWS

section .data
  EOL     equ 10                   ; Linux end-of-line character
  FILLCHR equ 32                   ; ASCII space
  CHRTROW equ 2                    ; Chart begins 2 lines from top of the display
  CHRTLEN equ 32                   ; Each chart line shows 32 characters

  ClrHome db 27,"[2J",27,"[01;01H"
  CLRLEN  db $-ClrHome

section .text
  global _start

;-----------------------------------------------------------
; ClearTerminal: This macro clears the Linux console terminal
;                and sets the cursor position to 1,1 (1-based),
;                using a single predefined escape sequence.
;-----------------------------------------------------------
%macro ClearTerminal 0
  pushad

  mov eax,4                     ; sys_write
  mov ebx,1                     ; stdout fd
  mov ecx,ClrHome
  mov edx,CLRLEN
  int 80h

  popad
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
  pushad

  mov eax,4                     ; sys_write
  mov ebx,1                     ; stdout fd
  mov ecx,VidBuff
  mov edx,COLS*ROWS
  int 80h

  popad
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
  push eax
  push ecx
  push edi

  cld                           ; clear DF

  mov al,FILLCHR
  mov edi,VidBuff
  mov ecx,COLS*ROWS
  rep stosb                     ; blast characters to buffer in EDI

  ; Now we insert EOL at every COLS bytes
  mov edi,VidBuff
  dec edi                       ; Adjust EDI so EOL goes to the last char in row
  mov ecx,ROWS                  ; number of operations
PutEOL:
  lea edi,[edi+COLS]
  mov byte [edi],EOL
  loop PutEOL

  pop edi
  pop ecx
  pop eax
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
  push eax
  push ebx
  push ecx
  push edi

  cld                           ; clear DF

  mov edi,VidBuff
  dec eax                       ; Adjust Y value down by 1 for address calculation
  dec ebx                       ; Adjust X value down by 1 for address calculation
  mov ah,COLS                   ; Assumes that Y position fits in 8-bit AL
  mul ah                        ; 8-bit multiply AL*AH to AX
  lea edi,[edi+eax]             ; Add Y offset into VidBuff
  lea edi,[edi+ebx]             ; Add X offset into VidBuff

  ; EDI now contains the address in the buffer where the ruler
  ; is to begin.
  mov al,'1'
DoChar:
  stosb
  add al,'1'
  aaa                           ; Adjust AX to make this a BCD addition
  add al,'0'                    ; Make sure we have binary 3 in AL's high nybble
  loop DoChar

  pop edi
  pop ecx
  pop ebx
  pop eax
  ret

;-----------------------------------------------------------
; MAIN
;-----------------------------------------------------------
_start:
  nop

  ClearTerminal
  call ClrVid

  ; Show a 32-character ruler above the table display:
  mov eax,1                     ; Start ruler at display position (1,1) (1-based)
  mov ebx,1
  mov ecx,32
  call Ruler

  ; Generate chart
  mov edi,VidBuff
  lea edi,[edi+COLS*CHRTROW]    ; Begin table display down CHRTROW lines
  mov ecx,224                   ; Show 256 character minus the first 32 control characters
  mov al,32                     ; Start with character 32

.DoLn:
  mov bl,CHRTLEN                ; Each line will consist of 32 characters
.DoChr:
  stosb                         ; blast character to EDI
  jcxz AllDone                  ; When the full set is printed, quit

  inc al                        ; next ASCII character
  dec bl
  loopnz .DoChr                 ; Go back and do another call until BL is zero

  lea edi,[edi+(COLS-CHRTLEN)]  ; Move EDI to start of the next line
  jmp .DoLn

AllDone:
  call Show                     ; Refresh the buffer to the console

Exit:
  mov eax,1                     ; Exit syscall
  mov ebx,0
  int 80h
