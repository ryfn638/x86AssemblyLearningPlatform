global textBuffer
global newLineBool

section .bss
  raxTemp resb 8 ; Store temporary small numbers inside of e-dx registers inside here for now
  rdiTemp resb 8 ;
  rdxTemp resb 8 ;
  newLine resb 8 ; Store new line character to append to the end
  skipNewLine resb 1 ; Flag for if the string has a \n or now

section .text

; ==================
; storeString()
; stores a string in memory and returns the memory address into rsi
; This is for data safety, and keeping relevant information while printing
; ==================
storeStringAddr:
  mov [abs raxTemp], rax
  mov [abs rdiTemp], rdi
  mov [abs rdxTemp], rdx
  ret
;

; ==================
; retrieveStoredData()
; stores a string in memory and returns the memory address into rsi
; This is for data safety, and keeping relevant information while printing
; ==================
retrieveStoredData:
  mov rax, [abs raxTemp]
  mov rdi ,[abs rdiTemp]
  mov rdx ,[abs rdxTemp]
  ret
;

; ==================
; printChar()
; Prints a singular character into stdout
; rsi, the value you want to print as a char
; rdx, the length of the string
; =================
printChar:
  mov rax, 1      ; Syscall number, rax = 1 to print
  mov rdi, 1      ; File descriptor 1 = stdout
  syscall         ; Initiate the print

  ret
;

;===================
; printf()
; Gets the length of a string and outputs it into rdx
; prints an entire string into stdout
; ==================
global printf

printf:
  call storeStringAddr

  exitPrintLoop:
  mov rdx, 0

  strlen_loop:   
    cmp byte [rsi + rdx], 0 ; compare until 0 byte to signify end
    jle zeroFound

    inc rdx
    jmp strlen_loop

    zeroFound:
    call printChar

    cmp [abs skipNewLine], 1
    je finishloop

    ; write \n to stdout
    mov [abs newLine], 10
    lea rsi, [abs newLine]
    mov rdx, 1
    call printChar

    finishloop:
  
  call retrieveStoredData ; populated the regsiters with prev values
  ret

