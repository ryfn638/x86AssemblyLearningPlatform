section .bss
  buffer resb 256 ; Text Buffer
  tempLength resb 16 ; Temporary buffer for storing values inside of rsi, can store a 64 bit integer
  tempStr resb 16 ; Temporary buffer for storing value inside of rdx, can store 64 bits
  eaxTemp resb 4 ; Store temporary small numbers inside of e-dx registers inside here for now
  ebxTemp resb 4 ;
  ecxTemp resb 4 ;
  edxTemp resb 4 ;
  newLineBool resb 1 ; Flag for if the string has a \n or not
; ==================
; storeString()
; stores a string in memory and returns the memory address into rsi
; This is for data safety, and keeping relevant information while printing
; ==================
storeStringAddr:
  mov [tempStr], rsi ; Safekeep rsi for a moment
  mov [tempLength], rdx
  mov [eaxTemp], eax
  mov [ebxTemp], ebx
  mov [ecxTemp], ecx
  mov [edxTemp], edx
  lea rsi, [buffer] ; textBuffer address
;

; ==================
; retrieveStoredData()
; stores a string in memory and returns the memory address into rsi
; This is for data safety, and keeping relevant information while printing
; ==================
retrieveStoredData:
  mov rsi ,[tempStr]
  mov rdx ,[tempLength]
  mov eax ,[eaxTemp]
  mov ebx ,[ebxTemp]
  mov ecx ,[ecxTemp]
  mov edx ,[edxTemp]
;

; ==================
; maxLengthReached()
; Loads the error code into the table and restarts loop to print error
; ==================
maxLengthReached:
  mov rsi, [error_table + 0] ; error code 0 (MAX STRING LENGTH)
  call exitPrintLoop

; ==================
; printChar()
; Prints a singular character into stdout
; rsi, the value you want to print as a char
; rdx, the length of the string
; =================
printChar:
    mov eax, 4      ; Syscall number 4 = sys_write
    mov ebx, 1      ; File descriptor 1 = stdout
    mov ecx, rsi    ; Pointer to the string in memory
    mov edx, rdx    ; Number of bytes to print
    int 0x80        ; Call the Linux kernel
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

  .strlen_loop:   
    cmp byte [rsi + rdx], 0 ; compare until 0 byte to signify end
    je .printStdout
    inc rdx

    cmp rdx, 257
    jge maxLengthReached
    jmp.strlen_loop

    cmp [newLineBool], 0
    jle finishloop

    ; write \n to stdout
    mov rsi, 10
    mov rdx, 1
    call printChar

    finishloop:
  
  call retrieveStoredData ; populated the regsiters with prev values
  ret

