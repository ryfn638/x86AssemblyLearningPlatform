; ======================
; Memory Writing Programs
; ======================
extern printStr
extern printInt

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

; For finding a weight at neuron i and layer j it is essentially
; networkWeights + [weightLayerOffset * j] + neuronCount * i
section .bss
    networkNeurons resq 1 ; all of the neurons in the network
    neuronLayerOffset resq 1 ; Start offset for neurons in a singualr layer

    networkWeights resq 1 ; array of the networkWeights
    weightLayerOffset resq 1 ; start offset for weights in a singular layer

    networkBias resq 1 ; 
    biasLayerOffset resq 1 ; Bias per layer

    networkShapePtr resq 1 ; The amount of neurons per layer at j is [networkShapePtr + 4*j];
    totalLayers resb 4
;

reallocateWeights:

; mov into rdi the element being reallocated with a new size
; mov into rsi the length of the new mapped area
; rax is the output address of the new allocation
; shouldnt require deallocation for now, since we're moreos just appending
reallocateElement:
  syscall
  ret

; When this is called, rax is essentially the amount of neurons in the new layer
reallocateArena:
  mov rsi, [networkShapePtr + rcx] ; move into rsi the amount of neurons in this layer
  rsi equ currentNeuronCount
  cmp rcx, 1
  jl skipWeights ; weights 

  ; weight allocation is slightly different
  mov rdi, [networkWeights] ; rdi is the start address, s
  imul rsi, [networkShapePtr + rcx - 1] ; prevNeuronCount * currentNeuronCount
  imul rsi, 4
  call reallocateElement
  mov [weightLayerOffset + rcx - 1], rsi
  mov [networkWeights], rax ; the address should be the same, but it may change
  
  skipWeights:
  mov rdi, [networkNeurons] ; rdi is the start address, s
  imul currentNeuronCount, 4
  call reallocateElement
  mov [networkNeurons], rax ; the address should be the same, but it may change

  mov rdi, [networkBias] ; rdi is the start address, s
  imul currentNeuronCount, 4
  call reallocateElement
  mov [networkBias], rax ; the address should be the same, but it may change
  
  ret
;

; rax is the number of neuron in the layer
; rcx is the layer
; rsi is the total running count of nodes
createLayer:
    inc rcx
    call InitAllPointers

    mov [networkShapePtr + rcx], rax
    imul rax, 4

    mov [neuronLayerOffset + rcx], rax 
    mov [biasLayerOffset + rbx], rax
    
    call ReallocateArena
    ret

; initPointer, allocates a heap for a pointer
initPointer:
  mov rdi, 0
  mov rsi, rcx; rcx is the tally of layers
  mov rdx, 3,
  mov r10, 34
  syscall

  ret
; 
;
; Initialises all of the initial pointers
InitAllPointers:
  call initPointer
  mov networkNeurons, rax ; all of the neurons in the network

  call initPointer
  mov neuronLayerOffset, rax ; Start offset for neurons in a singualr layer

  call initPointer
  mov networkWeights, rax ; array of the networkWeights

  call initPointer
  mov weightLayerOffset, rax ; start offset for weights in a singular layer
  
  call initPointer
  mov networkBias , rax; 

  call initPointer
  mov biasLayerOffset, rax ; Bias per layer

  call initPointer
  mov networkShapePtr, rax ; The amo

  ret


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
global networkInit
networkInit:
    mov rbx, 0
    mov rcx, 0

    ; Allocate an initial heap and then reallocate more with each new layer
    ; Previous approach is technically more efficient, but god this is so much easier to work with
    call InitAllPointers

    ; Input Layer - 3600 bytes
    mov rax, 900
    call createLayer

    ; Hidden Layer 1 - 512 bytes
    mov rax, 128
    call createLayer

    ; Hidden Layer 2 - 256 bytes
    mov rax, 64
    call createLayer

    ; Output Layer - 40 bytes
    mov rax, 10
    call createLayer

    imul rcx, 4 ; just so things wrap up a little clearner
    mov [totalLayers], rcx
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
    layerOffset equ rcx

    mov rdx, 0
    neuronOffset equ rdx

    mov r8, 0
    weightOffset equ r8

    writeLayerLoop:
      mov neuronOffset, 0
        writeNeuronLoop:
            mov weightOffset, 0
            cmp layerOffset, 1
            jge writeWeightLoop

            add neuronOffset, 4
            cmp neuronOffset, [neuronLayerOffset + layerOffset]
            jl writeNeuronLoop

        add layerOffset, 4
        cmp layerOffset, [totalLayers]
        jl writeLayerLoop
    ret

; ============================================
; writeWeightLoop()
; Writes one neuron's weights into the arena
; ebx: number of weights (incoming connections)
; ============================================
writeWeightLoop:
    call generateRandomNums             ; xmm0 = random weight

    mov r9, [networkShapePtr + layerOffset - 4] ; Get the number of neurons in the previous layer
    imul r9, neuronOffset ; multiply the number of neurons 
    shr r9, 2 ; shift right twice, basically divide by 4
    add r9, [weightLayerOffset + layerOffset] ; add on the offset to the layer
    movss [networkWeights + r9], xmm0

    inc weightOffset
    cmp weightOffset, ebx
    jl writeWeightLoop
    ret
