section .bss
    networkPtr  resq 1
    networkSize resq 1

; ==================
; createArena()
; Allocates a contiguous memory arena covering nodes + weights for one batch
; ==================
createArena:
    mov rsi, nodeSize
    add rsi, weightSize
    mov rdx, 3          ; read/write permissions
    mov r10, 34         ; private anonymous mapping
    call allocateHeap

    mov [networkSize], rsi
    mov [networkPtr], rax
    ret

; ==================
; freeArena()
; Releases the network memory arena
; ==================
freeArena:
    mov rdi, [networkPtr]
    mov rsi, [networkSize]
    call freeHeap
    ret
