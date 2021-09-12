;-----------------------------------------------------------------------------
; x86 NASM Assembly file: vidbuff1.asm
; Assembler             : NASM
; Description           : A simple program in assembly for Linux demonstrating
;                         string instruction operation by "faking" full-screen
;                         memory-mapped text I/O.
;

section .data
  EOL     equ 10                ; Linux end-of-line
  FILLCHR equ 32                ; ASCII space
  HBARCHR equ '-'               ; Use dash char if this won't display
  STRTROW equ 2                 ; Row where graph begins

  Dataset db 9,71,17,52,55,18,29,36,18,68,77,63,58,44,0
  Message db "Data current as of 01/01/2021"
  MSGLEN equ $-Message

  ; This escape sequence will clear the console terminal and place the
  ; text cursor to the origin (1, 1) on virtually all Linux consoles:
  ClrHome db 27,"[2J",27,"[01;01H"
  CLRLEN equ $-ClrHome

section .bss
  COLS equ 81                   ; Line length plus 1 char for EOL
  ROWS equ 25                   ; Number of lines in display
  VIDBUFFLEN equ COLS*ROWS
  VidBuff resb VIDBUFFLEN

section .text

  global _start

;-----------------------------------------------------------
; ClearTerminal: This macro clears the Linux console terminal
; and sets the cursor position to 1,1, using a single predefined
; escape sequence.
;
%macro ClearTerminal 0
  pushad
  mov eax,4                     ; specify sys_write
  mov ebx,1                     ; specify stdout file descriptor
  mov ecx,ClrHome
  mov edx,CLRLEN
  int 80h
  popad
%endmacro

;-----------------------------------------------------------
; Show: Display a text buffer to the Linux console.
; Description: Sends the buffer VidBuff to the Linux console
;              via sys_write.
;
Show:
  pushad
  mov eax,4                     ; specify sys_write
  mov ebx,1                     ; specify stdout file descriptor
  mov ecx,VidBuff
  mov edx,VIDBUFFLEN
  int 80h
  popad
  ret

;-----------------------------------------------------------
; ClrVid: Clears a text buffer to spaces and replaces all EOLs.
; Description: Fills the buffer VidBuff with a predefined
;              character (FILLCHR) and then places an EOL
;              character at the end of every line, where a
;              line ends every COLS bytes in VidBuff.
;
ClrVid:
  push eax
  push ecx
  push edi

  cld                           ; clears Direction Flag (we're counting up-memory)
  mov al,FILLCHR
  mov edi,VidBuff
  mov ecx,VIDBUFFLEN
  rep stosb                     ; Blast chars at the destination buffer

  ; Insert EOL character after each line of VidBuff
  mov edi,VidBuff
  dec edi
  mov ecx,ROWS
PutEOL:
  ;add edi,COLS
  lea edi,[edi+COLS]
  mov byte [edi],EOL
  loop PutEOL                   ; if still more lines

  pop edi
  pop ecx
  pop eax
  ret

;-----------------------------------------------------------
; WrtLn: Writes a string to a text buffer at a 1-based X,Y
;        position.
; Description: Uses REP MOVSB to copy a string from address
;              in ESI to an X,Y location in the next buffer
;              VidBuff.
;
; Input: * Address of the string in ESI
;        * 1-based X position (row number) is passed in EBX
;        * 1-based Y position (column number) is passed in EAX
;        * Length of the string in chars is passed in ECX
;
WrtLn:
  push eax
  push ebx
  push ecx
  push edi

  cld                           ; clears Direction Flag (we-re writing up-memory)
  mov edi,VidBuff
  dec eax                       ; Adjust Y value down by one for address calculation
  dec ebx                       ; Adjust X value down by one for address calculation
  mov ah,COLS                   ; Screen width
  mul ah                        ; Do 8-bit mult AL*AH to AX
  ;add edi,eax
  ;add edi,ebx
  lea edi,[edi+eax]             ; Y offset into VidBuff
  lea edi,[edi+ebx]             ; X offset into VidBuff
  rep movsb                     ; Blast the string into the buffer

  pop edi
  pop ecx
  pop ebx
  pop eax
  ret

;-----------------------------------------------------------
; WrtHB: Generates a horizontal line bar at X,Y in text buffer
; Description: Writes a horizontal bar to the video buffer VidBuff,
;              at the 1-based X,Y values passed in EBX,EAX. The bar
;              is "made of" the character in the equate HBARCHR.
;
; Input: * 1-based X position (row number) is passed in EBX
;        * 1-based Y position (column number) is passed in EAX
;        * Length of the bar in characters is passed in ECX
;
WrtHB:
  push eax
  push ebx
  push ecx
  push edi

  cld                           ; clears Direction Flag (we're writing up-memory)
  mov edi,VidBuff
  dec eax                       ; Adjust Y value down by one for address calculation
  dec ebx                       ; Adjust X value down by one for address calculation
  mov ah,COLS
  mul ah                        ; 8-bit multiply AH*AL to AX
  ;add edi,eax
  ;add edi,ebx
  lea edi,[edi+eax]             ; Y offset into VidBuff
  lea edi,[edi+ebx]             ; X offset into VidBuff
  mov al,HBARCHR
  rep stosb                     ; Blast bar char into VidBuff

  pop edi
  pop ecx
  pop ebx
  pop eax
  ret

;-----------------------------------------------------------
; Ruler: Generates a "1234567890"-style ruler at X,Y in text
;        buffer.
; Description: Writes a ruler to the video buffer VidBuff, at
;              the 1-based X,Y position passed int EBX,EAX.
;              The ruler consists of a repeating sequence of
;              the digits 1 through 0. The ruler will wrap to
;              subsequent lines and overwrite whatever EOL
;              characters fall within its lenght, if it will
;              not fit entirely on the line where it begins.
;              Note that the Show procedure must be called
;              after Ruler to display the ruler on the console.
;
; Input: * 1-based Y position (row number) is passed in EBX
;        * 1-based X position (column number) is passed in EAX
;        * Length of the ruler in characters is passed in ECX
;
Ruler:
  push eax
  push ebx
  push ecx
  push edi

  mov edi,VidBuff
  dec eax                       ; Adjust Y value down by one for address calculation
  dec ebx                       ; Adjust X value down by one for address calculation
  mov ah,COLS
  mul ah                        ; 8-bit multiply AL*AH to AX
  ;add edi,eax
  ;add edi,ebx
  lea edi,[edi+eax]             ; Y offset into VidBuff
  lea edi,[edi+ebx]             ; X offset into VidBuff

  mov al,'1'                    ; Start ruler with digit 1
DoChar:
  stosb
  add al,'1'
  aaa                           ; Adjust AX to make this a BCD addition
  add al,'0'                    ; Make sure we have binary 3 in AL's high nybble
  loop DoChar                   ; until ECX = 0

  pop edi
  pop ecx
  pop ebx
  pop eax
  ret

;-----------------------------------------------------------
; MAIN PROGRAM
;

_start:
  nop

  ClearTerminal
  call ClrVid                   ; Init/clear video buffer

  ; Top Ruler
  mov eax,1                     ; Y position
  mov ebx,1                     ; X position
  mov ecx,COLS-1                ; Ruler length
  call Ruler

  ; Graph the data
  mov esi,Dataset
  mov ebx,1                     ; Start all bars at left margin (X=1)
  mov ebp,0                     ; Dataset element index starts at 0
.blast:
  mov eax,ebp                   ; Add dataset number to element index
  add eax,STRTROW               ; Bias row value by row number of first bar
  mov cl,byte [esi+ebp]
  cmp ecx,0
  je .rule2                     ; if pulled 0 from dataset, done

  call WrtHB
  inc ebp
  jmp .blast

  ; Bottom ruler
.rule2:
  mov eax,ebp                   ; Use dataset counter to set ruler row
  add eax,STRTROW               ; Bias down by the row number of the first bar
  mov ebx,1                     ; X position to BL
  mov ecx,COLS-1                ; Ruler length
  call Ruler

  ; Informative message centered on the last line
  mov esi,Message
  mov ecx,MSGLEN
  mov eax,4                     ; specify sys_write
  mov ebx,COLS                  ; screen width
  sub ebx,ecx
  shr ebx,1
  mov eax,24                    ; Message row to line 24
  call WrtLn

  call Show

Exit:
  mov eax,1                     ; specify exit syscall
  mov ebx,0                     ; return 0 status code
  int 80h
