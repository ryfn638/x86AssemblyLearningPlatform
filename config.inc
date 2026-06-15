; config.inc

; System Call Numbers
SYS_WRITE   equ 1
SYS_EXIT    equ 60

; File Descriptors
STDOUT      equ 1

; Macro for clean exit
%macro EXIT 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
%endmacro
