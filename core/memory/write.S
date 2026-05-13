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

    mov rbx, 0
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
        nodeSize resq 1 ; 8 Bytes for 64 bit address
        weightSize resq 1; Weights Address

    mov [nodeSize], rax ; ArenaSize is now our pointer


    ; The heap here is essentially out array
    mov rsi, rcx
    mul rsi, 4 ; rcx is the number of layers, * 4 makes a 4 byte array for each layer
    call allocate_heap
    section .bss
        networkShape resq 1

    mov [networkShape] resq rax ; networkShape now contains an empty array of size 4 (4 bytes each)

    mov rcx, rsi ; dont need rax, anymore find to make it hold rcx for now
    add rcx, networkShape
    

    mov rbx, 0
    assignLoop: ; Assigning the Network structure loop
        pop rsi
        mov [rcx], rsi

        mov rbp, rbx ; rbp is the previous dimension
        mov rbx, rsi ; rbx is the current dimension
        
        mov r12, rbp ; move rbp to r12 and then multiply the two
        mul r12, rbx

        add r13, r12 ; Increment the results on
        
        
        sub rcx, 4
        jnz assignLoop
    
    ; r13 is the output for the number of total weights
    
    ; Freely allocate the weight now yippee
    mov [weightSize], r13;

    ret
;

; ============================================
; generate_random_nums()
; Generates Random numbers to assign to the weights
; xmm0 is the output register
; ============================================

generate_random_nums:

    section .section .data
        maxInt dd 0x7FFFFFFF
        half dd 0.5
        
    section .bss
        rngState resd 1 ; 32 bit current value


    mov eax, 1664525
    mov ecx 1013904223
    
    mul eax, rngState
    add eax, ecx

    inc rngState ; Update the generation seed

    and eax 0xFFFFFFFF
    cvtsi2ss xmm0, eax
    divss xmm0, [maxInt]
    subss xmm0, [half]
    ret
;


; Next we need to define the actual method of filling up the weightSpace
; TODO: Make the Memory Arena Before writing our actual values
write_default_weights:
    ; TODO:
    ; Write the default values for the weights on the network using the generate_random_nums bit
    ; xmm registers can hold up to 4 floating points allegedly
    ; so maybe what we can do is generate 4 numbers at once, but we'll see later down the line.

    ret