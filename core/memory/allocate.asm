; ==============================
; Basic Memory Allocator Methods
; ==============================

section .bss
    staticPool resb 1024

global allocateStatic

; =======================
; allocateStatic()
; Returns the address of the 1024-byte static pool for network constants
; returns rax: address of staticPool
; =======================
allocateStatic:
    lea rax, [staticPool]
    ret


global allocateHeap

; ======================
; allocateHeap()
; Allocates memory via mmap syscall
; rdi: starting address (0 for kernel choice)
; rsi: length in bytes
; rdx: protection flags
; r10: mapping flags
; r8:  file descriptor (-1 for anonymous)
; r9:  offset (0 for anonymous)
; returns rax: virtual address of mapped region
; ======================
allocateHeap:
    mov rax, 9
    syscall
    ret

global freeHeap

; ======================
; freeHeap()
; Deallocates a mapped memory region via munmap
; rdi: address to unmap
; rsi: length in bytes
; ======================
freeHeap:
    mov rax, 11
    syscall
    ret

global allocateStack

; ======================
; allocateStack()
; Reserves space on the stack
; rbx: number of bytes to allocate
; ======================
allocateStack:
    sub rsp, rbx
    ret

global freeStack

; ======================
; freeStack()
; Releases stack space previously reserved by allocateStack
; rbx: number of bytes to free
; ======================
freeStack:
    add rsp, rbx
    ret
