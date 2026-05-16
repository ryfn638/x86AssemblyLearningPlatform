; ======================
; Memory Writing Programs
; ======================


; ======================
; consts_init
; Initialises all the constant values for the sim, such as batch size and learning rate.
; ======================
section .data
    batchSize dq 32
    learningRate dd 0.0001


; ==========================
; RNG State Constants
; ==========================

section .data
    maxInt dd 0x7FFFFFFF
    half dd 0.5
    
section .bss
    rngState resd 1 ; 32 bit current value

; ========================
; Node and Weight Size Pointer memory addresses
; ======================== 
section .bss
    nodeSize resq 1 ; 8 Bytes for 64 bit address
    weightSize resq 1; Weights Address

; =======================
; Network Shape Pointer memory address
; =======================
section .bss
    networkShape resq 1 ; Network Dimensions
    networkOffset resq 1 ; Network Offsets for easy calculation
    networkLayers resq 1 ; Number of layers in the network

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

    mov r12, rax
    shl r12 ; 
    ; Heap is now allocated we dont need rcx ore
    mov [nodeSize], r12 ; ArenaSize is now our pointer

    mov [networkLayers] resq rcx ; Assign the total number of layers in the network
    ; =============================
    ; Network shape heap allocation
    ; =============================

    mov rsi, rcx
    mul rsi, 4 ; rcx is the number of layers, * 4 makes a 4 byte array for each layer
    call allocate_heap
    mov [networkShape] resq rax ; networkShape now contains an empty array of size 4 (4 bytes each)
    mov [networkOffset] resq rax ; Network Dimensions are the same premise, empty array of size 4 with 4 bytes each, sweet as. and its dynamic to different models, umazing

    ; Allocating the contents of networkShape


    mul rcx, 4 ; rcx is 12 at this point here

    mov rbx, 0
    assignLoop: ; Assigning the Network structure loop
        pop rsi
        mov [networkShape + rcx], rsi
        
        mov rbp, rbx ; rbp is the previous dimension
        mov rbx, rsi ; rbx is the current dimension
        
        mov r12, rbp ; move rbp to r12 and then multiply the two
        mul r12, rbx

        add r13, r12 ; Increment the results on
        mov rcl
        mov [networkOffset + rcx], r13
        
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
    mov eax, 1664525
    mov ecx, 1013904223
    
    mul eax, rngState
    add eax, ecx

    inc rngState ; Update the generation seed

    and eax, 0xFFFFFFFF
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
        
    mov rcx, 0 ; Initialise rcx with a zero value
    layerIndex equ rcx ; Alias for rcx for readability

    mov rdx, 0
    neuronIndex equ rdx ; Neuron index alias
 
    mov r8, 0
    weightIndex equ r8


    ; We're going to have to do our very first assembly nested loop how exciting
    layerLoop:
        ; Looping over all the hidden layers, might abstract a method to loop over all the weights that belong to a neuron
        mov eax, layerIndex
        inc eax
        imul eax, 4
        mov ebx, [networkShape + eax]
        neuronLoop:
            
            ; Abstract a method to loop over all of the weights inside of an array
            mov weightIndex, 0
            call weight_loop
            
            inc neuronIndex

            cmp neuronIndex, [networkShape + layerIndex * 4] ; Compare it with the amount of neurons on our hidden layer
            jl neuronLoop
        
        cmp layerIndex, [networkLayers]
        jl layerLoop ; Loop over the layers until all have been iterated through
    ret
;

weight_loop:
    
    ; Adjust individual weights
   
    inc weightIndex

    call generate_random_nums
    ;xmm0 now contains a pseudo random num
    
    mov r9, [networkOffset + layerIndex] ; The offset for the different neurons
    mov [networkPtr + r9 + 4*weightIndex + 8], xmm0 ; Move the random weight into position    
 
    mov [networkPtr + r9 + 4], 0 ; networkPtr + r9 is the neuron, next 4 bytes are the bias
    ; compare with if the neuron has finished iterating over weights
    
    cmp weightIndex, ebx
    jl weight_loop