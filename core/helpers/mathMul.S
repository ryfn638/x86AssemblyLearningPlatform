
; ======================
; Matrix Multiplication Functions
; ======================


THREAD_START_PTR equ 0
THREAD_END_PTR equ 64
THREAD_STACK equ 8

global forward_pass
; ========================
; forward_pass
; Performs a forward pass through the network, and updates the memory arena with all of the changes
; =======================
forward_pass:
    mov rcl, 1
    layerIndex equ rcl

    call neuron_forward_pass
;

section .data
    zero dd 0.0
neuron_forward_pass:
    ; for each neuron in the next layer, we make an allocation to the stack
    mov ebx, 0
 
    call init_neurons ; Initialises zeroed neuron positions inside of the stack
    call neuron_accumulation ; Accumulates all the neurons Inside of the stack
    call update_arena ; Updates the arena with all the recent changes to the stack
 
    inc layerIndex

    cmp layerIndex, [networkLayers]
    jl neuron_forward_pass

init_neurons:
    push 0 ; Initialise and empty stack pointer, this isnt important for now just setting up shape
    inc ebx

    mov rbx, rsp ; Cache the stack start point, for safe memory access
    ; For parallelisation across multiple cores, we simply jsut have to modify
    ; the actual size of network shape to be networkShape / num_cores (flat)
    ; As a base, then we redelegate with less cores
    cmp [networkShape + layerIndex * 4], ebx

    jl init_neurons 
;

; ====================================
; Neuron Accumulation
; Accumulates all the neurons and puts their newly updated values on to the stack
; Dynamic to the amount of variables on the stack
; ====================================
neuron_accumulation:

    ; For each neuron, we do n_prev * n_weightconnection
    ; and we keep the running tally inside of the stack
    mov r8, 0
    neuronIndex equ r8
    neuronLoop:
        
        ; Abstract a method to loop over all of the weights inside of an array
        mov weightIndex, 0
        call weight_loop

        mov edx, [networkOffset + neuronIndex*4] ; save into edx the offset index for the pointer

        cmp neuronIndex, [networkShape + layerIndex * 4] ; Compare it with the amount of neurons on our hidden layer
        jl neuronLoop

    add dword [ resp + offset] eax

; =========================
; Weight Loop
; Loops through all the weights and does the according allocation to the memory stack
weight_loop:
    
    ; Adjust individual weights
   
    inc weightIndex

    mov xmm0, [networkPtr + r9 + 4*weightIndex + 8] ; Put the current weight inside of xmm0
    mul xmm0, [networkPtr + edx];
    maxss xmm0, [zero] ; ReLU activation function (just easier and better than sigmoid for weights

    add dword [rsp + neuronIndex*4], xmm0 ; Adjust the stack accumulation

    cmp weightIndex, ebx
    jl weight_loop


; ============================
; Updating the memory arena with the stack changes
; ============================
update_arena:
    ; We update the next neurons with the information, dont have to make a special case for input layer
    call neuron_arena_update ; Calls the recursive arena update by iterating down the stack

neuron_arena_update:
    pop rcx ; pop the first stack entry
    mov [networkOffset + neuronIndex*4], rcx ; Update the arena
    cmp rbp, rsp ; Compare it with the amount of neurons on our hidden layer
    jl neuronLoop