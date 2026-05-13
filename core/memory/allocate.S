; ==============================
; Basic Memory Allcator Methods
; ==============================

global allocate_static

; =======================
; allocate_static()
; Allocates 1024 Bytes for constants during the simulation
; =======================

allocate_static:
    section .bss
        staticPool resb 1024 ; Reservevs 1024 Bytes for constants.
    ret


global allocate_heap

; ======================
; allocate_heap()
; allocates memory to the heap, this is for dynamic memory in our arena
; rax: 9 - Linux mmap (const)
; rdi startingAddress
; rsi Length
; rdx protection flags
; r10 mapping flags
; r8 file descriptor
; r9 Offset (usually 0)
; Returns come from rax which is the virtual address
allocate_heap:
    mov rax 9 ; Assign Linux mmap
    syscall
    ret

global free_heap


; ======================
; free_heap()
; rdi Address to unmap
; rsi length in bytes to free
; deallocates selected memory to the heap.
; ======================
free_heap:
    mov rax, 11
    syscall
    ret

global allocate_stack

; ======================
; allocate_stack()
; Allocates specific memory to the stack
;
; ======================
allocate_stack:
    sub rsp, 32

    ret
