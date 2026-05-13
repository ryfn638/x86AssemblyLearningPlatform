; ==============================
; Basic Memory Allcator Methods
; ==============================

global allocate_static

; =======================
; allocate_static()
; Allocates 1024 Bytes for constants during the simulation
; rbx The number of bytes to allocate, This is used for network params
; =======================

allocate_static:
    section .bss
        staticPool resb rbx ; Reservevs 1024 Bytes for constants.
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
;

global allocate_stack

; ======================
; allocate_stack()
; Allocates specific memory to the stack
; rbx number of bytes memory to allocate on the stack
; ======================
allocate_stack:
    sub rsp, rbx
    ret

;

global free_stack
; ======================
; free_stack
; Frees Local memory from the stack
; rbx, The numberof bytes that are being deallocated from the stack
; ======================
free_stack:
    add rsp, rbx
    ret

: