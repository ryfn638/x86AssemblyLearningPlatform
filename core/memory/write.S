; ======================
; Memory Writing Programs
; ======================


; ======================
; consts_init
; Initialises all the constant values for the sim, such as batch size and learning rate.
; ======================
global consts_init
consts_init:
    section .data
        batchSize dq 32
        learningRate dd 0.0001

    ret

;

; Initialising the network structure
; Input Size in this case will be a constant 30x30 pixel grid
;
; Structure we're going to go with, for basic 30x30 number recognition
; 900 nodes - input
; 128 nodes - hidden
; 64 nodes - hidden 2
; 10 nodes - output
; rax is the amount of bytes needed 
; N
network_init:

    ; Network Memory Allocation


    ; ===================
    ; NETWORK STRUCTURE, FEEL FREE TO MODIFY
    ; ===================

    mov rcx, 0 
    ; Input Layer - 3600 Bytes
    mov rax, 900
    push rax
    mul rax, 4
    mov rsi, rax
    inc rcx

    ; Hidden Layer 1 - 512 Bytes
    mov rax, 128
    push rax
    mul rax, 4
    add rsi, rax
    inc rcx

    ; Hidden Layer two - 256
    mov rax, 64
    push rax ; Caching the network shape in the stack
    mul rax, 4
    add rsi, rax
    inc rcx

    ; Output Layer - 40 Bytes
    mov rax, 10
    push rax
    mul rax, 4
    add rsi, rax

    ; Configuring Heap allocation
    mov rdx, 3
    mov r10, 34    
    call allocate_heap
    ; Heap is now allocated we dont need rcx ore

    section .bss
        arenaSize resq 1 ; 8 Bytes for 64 bit address

    mov [arenaSize], rax ; ArenaSize is now our pointer

    ; The heap here is essentially out array
    mov rsi, rcx
    mul rsi, 4 ; rcx is the number of layers, * 4 makes a 4 byte array for each layer
    call allocate_heap

    section .bss
        networkShape resq 1

    mov [networkShape] resq rax ; networkShape now contains an empty array of size 4 (4 bytes each)

    mov rcx, rsi ; dont need rax, anymore find to make it hold rcx for now
    add rcx, networkShape

    pop rsi ; Move the value at the top of the stack onto rsi, which is the output layer dimension
    mov [rcx], rsi 

    sub rcx, 4
    pop rsi
    mov [rcx], rsi
    
    sub rcx, 4
    pop rsi
    mov [rcx], rsi

    sub rcx, 4
    pop rsi

    assignLoop:
        pop rsi
        mov [rcx], rsi
        
        sub rcx, 4
        jnz assignLoop

