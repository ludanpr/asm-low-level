;-----------------------------------------------------------
; x86 Assembly file: showargs1.asm
; Description      : A simple program in Linux assembly,
;                    demonstrating the way to access command
;                    line arguments on the stack.
;-----------------------------------------------------------

section .data
  ErrMsg db "Terminated with error.",10
  ERRLEN equ $-ErrMsg

section .bss
  ;---------------------------------------------------------
  ; This program handles up to MAXARGS command-line arguments.
  ; In essence, we store pointers to the arguments in a 0-based
  ; array, with the first argument pointer at array element 0,
  ; the second at array element 1, etc. Access the arguments and
  ; their lengths this way:
  ;
  ;      Arg strings:          [ArgPtrs + <index reg>*4]
  ;      Arg string lengths:   [ArgLens + <index reg>*4]
  ;
  ; Note that when the argument lengths are computed, an EOL
  ; character (10h) is stored into each  string  where  the
  ; terminating null was originally. This makes it easy to print
  ; out an argument using sys_write.
  ;---------------------------------------------------------

  MAXARGS   equ 10              ; Maximum number of arguments supported
  ArgCount: resd 1              ; Number of arguments passed to program
  ArgPtrs:  resd MAXARGS        ; Table of pointers to arguments
  ArgLens:  resd MAXARGS        ; Table of argument's lengths

section .text

  global _start

_start:
  nop

  ;-----------------------------------------------
  ; Get the command line argument count off the
  ; stack and validate it
  ;-----------------------------------------------
  pop ecx                       ; Top Of Stack contains the argument count
  cmp ecx,MAXARGS
  ja Error
  mov dword [ArgCount],ecx      ; Save argument count in memory variable

  ;-----------------------------------------------
  ; Pop arguments into ArgPtrs
  ;-----------------------------------------------
  xor edx,edx                   ; Loop counter
SaveArgs:
  pop dword [ArgPtrs+edx*4]
  inc edx
  cmp edx,ecx
  jb SaveArgs

  ;-----------------------------------------------
  ; Calculate arguments' lengths
  ;-----------------------------------------------
  xor eax,eax                   ; Searching for 0, so clear AL
  xor ebx,ebx                   ; Pointer table offset
ScanOne:
  mov ecx,0000ffffh             ; Limit search to 65535 bytes maximum
  mov edi,dword [ArgPtrs+ebx*4] ; String to search
  mov edx,edi                   ; Copy starting address into EDX

  cld                           ; Clear DF
  repne scasb                   ; Search for null (0) character in string at EDI
  jnz Error                     ; REPNE SCASB ended without finding AL

  mov byte [edi-1],10           ; Store EOL where the null used to be
  sub edi,edx                   ; Subtract position of 0-byte from start address
  mov dword [ArgLens+ebx*4],edi ; Put length of argument into table

  inc ebx                       ; Next table position
  cmp ebx,[ArgCount]            ; Compare EBX with value in ArgCount
  jb ScanOne

  ;-----------------------------------------------
  ; Display all command-line arguments to stdout
  ;-----------------------------------------------
  xor esi,esi                   ; Table addressing start
Showem:
  mov eax,4                     ; sys_write syscall
  mov ebx,1                     ; stdout file descriptor
  mov ecx,[ArgPtrs+esi*4]
  mov edx,[ArgLens+esi*4]
  int 80h

  inc esi
  cmp esi,[ArgCount]
  jb Showem

  jmp Exit

Error:
  mov eax,4
  mov ebx,2                     ; stderr file descriptor
  mov ecx,ErrMsg
  mov edx,ERRLEN
  int 80h

Exit:
  mov eax,1                     ; Exit syscall
  mov ebx,0                     ; 0 return value
  int 80h
