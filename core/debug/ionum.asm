global textBuffer
global newLineBool

section .bss
  textBuffer resb 8 ; Allocated numbers in the textBuffer, and just move along this for the individual characters
  raxTemp resb 8 ; Store temporary small numbers inside of e-dx registers inside here for now
  rdiTemp resb 8 ;
  rdxTemp resb 8 ;
  rcxTemp resb 8 ; Integer counter
  counterTemp resb 8 ; temporary storage for counter
  secondCounterTemp resb 8 ;
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
  mov [abs rcxTemp], rcx
  ret
;

; ==================
; retrieveStoredData()
; stores a string in memory and returns the memory address into rsi
; This is for data safety, and keeping relevant information while printing
; ==================
retrieveStoredData:
  mov rax ,[abs raxTemp]
  mov rdi ,[abs rdiTemp]
  mov rdx ,[abs rdxTemp]
  mov rcx ,[abs rcxTemp]
  ret
;

; ==================
; printInt()
; Prints a singular character into stdout
; rsi, the value you want to print as a char
; rdx, the length of the string
; =================
printChar:
  mov [abs counterTemp], rdx
  mov [abs secondCounterTemp], rsi

  mov rdx, 1
  mov rax, 1      ; Syscall number, rax = 1 to print
  mov rdi, 1      ; File descriptor 1 = stdout
  lea rsi, [abs textBuffer]
  syscall         ; Initiate the print

  mov rdx, [abs counterTemp]
  mov rsi, [abs secondCounterTemp]
  ret
;

; =================
; storeIntRemainder()
; Stores the remainder of the image in rsi
; Output goes on to the stack
storeIntRemainder:
  mov rax, rsi
  mov rcx, 10
  mov [abs counterTemp], rdx
  mov rdx, 0
  div rcx ; rdx now has the remainder
  mov r8, rdx
  mov rdx, [abs counterTemp]
  mov rsi, rax ; store the value for  the next loop
  ret

;===================
; printInt()
; rsi : the memory address of the string you want to print
; Gets the length of a string and outputs it into rdx
; prints an entire string into stdout
; ==================
global printInt

printInt:
  call storeStringAddr

  exitPrintLoop:
  mov rdx, 0

  strlen_loop:
    call storeIntRemainder
    push r8
    inc rdx
    cmp rsi, 0 ; when value / 10 becomes 0 we've reached the end
    jle allocateTextBuffer

    jmp strlen_loop
  
  allocateTextBuffer:
    mov rsi, 0;

    allocateBufferLoop:

    cmp rsi, rdx
    je exitBufferLoop

    pop rax ; will contain the smallest number
    add rax, 48 ; ascii chars are num + 48 i think
    mov [abs textBuffer], rax
    call printChar ; print each char individually
    inc rsi

    jmp allocateBufferLoop


  exitBufferLoop:
    cmp [abs skipNewLine], 1
    je finishloop

    ; write \n to stdout
    mov [abs newLine], 10
    mov rsi, [abs newLine]
    mov [abs textBuffer], rsi
    mov rdx, 1
    call printChar

    finishloop:
  
  call retrieveStoredData ; populated the regsiters with prev values
  ret

