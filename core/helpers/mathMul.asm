; ======================
; Forward Pass
; ======================

THREAD_START_PTR equ 0
THREAD_END_PTR   equ 64
THREAD_STACK     equ 8

section .data
    zero dd 0.0

global forwardPass

; ========================
; forwardPass()
; Runs a full forward pass through the network and updates the arena
; =======================
forwardPass:
    mov rcx, 1
    layerIndex equ rcx

    call neuronForwardPass

; ========================
; neuronForwardPass()
; Processes one layer at a time; loops until all layers are done
; ========================
neuronForwardPass:
    mov ebx, 0

    call initNeurons        ; push zeroed slots for the current layer's neurons
    call neuronAccumulation ; accumulate weighted inputs into those slots
    call updateArena        ; flush stack values back to the arena

    inc layerIndex
    cmp layerIndex, [networkLayers]
    jl neuronForwardPass
    ret

; ========================
; initNeurons()
; Pushes one zero per neuron in the current layer onto the stack.
; Returns rbx = rsp after all pushes (stack base for this layer's slots).
; ========================
initNeurons:
    mov ebx, 0
    initNeuronLoop:
        push qword 0
        inc ebx
        cmp ebx, [networkShape + layerIndex * 4]
        jl initNeuronLoop

    mov rbx, rsp    ; cache stack pointer so updateArena knows the range
    ret

; ====================================
; neuronAccumulation()
; For each neuron in the current layer, accumulates the weighted sum of
; all inputs from the previous layer into the stack slot.
; ====================================
neuronAccumulation:
    mov r8, 0
    neuronIndex equ r8

    mov r9, 0
    weightIndex equ r9

    forwardNeuronLoop:
        mov edx, [networkOffset + neuronIndex*4]    ; byte offset for this neuron's weights

        mov weightIndex, 0
        call forwardWeightLoop

        inc neuronIndex
        cmp neuronIndex, [networkShape + layerIndex * 4]
        jl forwardNeuronLoop
    ret

; =========================
; forwardWeightLoop()
; Multiplies each incoming weight by the previous layer's neuron value
; and accumulates the result (with ReLU) into the stack slot.
; ebx: incoming connection count for the current neuron
; =========================
forwardWeightLoop:
    movss xmm0, [networkPtr + r9 + weightIndex*4 + 8]  ; weight
    mulss xmm0, [networkPtr + edx]                      ; * previous neuron value
    maxss xmm0, [zero]                                  ; ReLU

    movss xmm1, [rsp + neuronIndex*4]
    addss xmm1, xmm0
    movss [rsp + neuronIndex*4], xmm1

    inc weightIndex
    cmp weightIndex, ebx
    jl forwardWeightLoop
    ret

; ============================
; updateArena()
; Copies the accumulated neuron values from the stack back into the arena.
; rbx: stack pointer saved by initNeurons (marks the bottom of layer slots)
; ============================
updateArena:
    call neuronArenaUpdate

neuronArenaUpdate:
    pop rcx                                     ; pop next neuron value (8-byte slot)
    mov r10, [networkOffset + layerIndex*4]
    movss [networkPtr + r10 + neuronIndex*4], xmm0
    cmp rbx, rsp                                ; stop when stack is restored to pre-layer state
    jg neuronArenaUpdate
    ret
