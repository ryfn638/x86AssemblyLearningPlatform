; ======================
; Memory Writing Programs
; ======================

section .data
    batchSize   dq 32
    ; learningRate is defined in backprop.S

section .data
    maxInt dd 0x7FFFFFFF
    half   dd 0.5

section .bss
    rngState resd 1

section .bss
    nodeSize   resq 1
    weightSize resq 1

section .bss
    networkShape  resq 1
    networkOffset resq 1
    networkLayers resq 1

; =======================
; networkInit()
; Initialises the network structure and allocates heap memory for nodes,
; weights, shape, and offset arrays.
;
; Network topology (30x30 input → digit classifier):
;   900 nodes  - input
;   128 nodes  - hidden 1
;    64 nodes  - hidden 2
;    10 nodes  - output
;
; rax: total byte count needed for nodes
; =======================
networkInit:
    mov rbx, 0
    mov rcx, 0

    ; Input Layer - 3600 bytes
    mov rax, 900
    push rax
    imul rax, 4
    mov rsi, rax
    inc rcx

    ; Hidden Layer 1 - 512 bytes
    mov rax, 128
    push rax
    imul rax, 4
    add rsi, rax
    inc rcx

    ; Hidden Layer 2 - 256 bytes
    mov rax, 64
    push rax
    imul rax, 4
    add rsi, rax
    inc rcx

    ; Output Layer - 40 bytes
    mov rax, 10
    push rax
    imul rax, 4
    add rsi, rax
    inc rcx

    ; Allocate node storage
    mov rdx, 3
    mov r10, 34
    call allocateHeap

    mov r12, rax
    mov [nodeSize], r12
    mov [networkLayers], rcx

    ; Allocate networkShape array (one dword per layer)
    mov rsi, rcx
    imul rsi, 4
    call allocateHeap
    mov [networkShape], rax

    ; Allocate networkOffset array (separate allocation, same size)
    mov rsi, rcx
    imul rsi, 4
    call allocateHeap
    mov [networkOffset], rax

    ; Populate networkShape and networkOffset by popping layer sizes off the stack.
    ; rcx holds the layer count; convert to a byte offset for the last element.
    imul rcx, 4     ; rcx = byte offset of last entry

    mov rbx, 0      ; rbx tracks the previous layer size for weight-count products
    assignLoop:
        pop rsi                         ; layer size (popped in reverse: 10, 64, 128, 900)
        mov [networkShape + rcx], rsi

        mov rbp, rbx                    ; rbp = previous layer size
        mov rbx, rsi                    ; rbx = current layer size
        mov r12, rbp
        imul r12, rbx                   ; r12 = prev * curr connection count

        add r13, r12                    ; accumulate total weight count
        mov [networkOffset + rcx], r13

        sub rcx, 4
        jnz assignLoop

    mov [weightSize], r13
    ret

; ============================================
; generateRandomNums()
; LCG random float in [-0.5, 0.5] for weight initialisation
; returns xmm0
; ============================================
generateRandomNums:
    mov eax, 1664525
    imul eax, [rngState]
    mov ecx, 1013904223
    add eax, ecx

    inc dword [rngState]

    and eax, 0x7FFFFFFF
    cvtsi2ss xmm0, eax
    divss xmm0, [maxInt]
    subss xmm0, [half]
    ret

; ============================================
; writeDefaultWeights()
; Fills all network weights with values from generateRandomNums
; ============================================
writeDefaultWeights:
    mov rcx, 0
    layerIndex equ rcx

    mov rdx, 0
    neuronIndex equ rdx

    mov r8, 0
    weightIndex equ r8

    writeLayerLoop:
        mov eax, ecx
        inc eax
        imul eax, 4
        mov ebx, [networkShape + eax]   ; neuron count of the next layer

        mov neuronIndex, 0
        writeNeuronLoop:
            mov weightIndex, 0
            call writeWeightLoop

            inc neuronIndex
            cmp neuronIndex, [networkShape + layerIndex * 4]
            jl writeNeuronLoop

        inc layerIndex
        cmp layerIndex, [networkLayers]
        jl writeLayerLoop
    ret

; ============================================
; writeWeightLoop()
; Writes one neuron's weights into the arena
; ebx: number of weights (incoming connections)
; ============================================
writeWeightLoop:
    call generateRandomNums             ; xmm0 = random weight

    mov r9, [networkOffset + layerIndex * 4]
    movss [networkPtr + r9 + weightIndex*4 + 8], xmm0
    mov dword [networkPtr + r9 + 4], 0  ; zero bias

    inc weightIndex
    cmp weightIndex, ebx
    jl writeWeightLoop
    ret
