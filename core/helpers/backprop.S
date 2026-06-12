; ==================================
; Back Propagation Algorithm
; ==================================

section .data
    learningRate dd 0.0003

section .bss
    backPropPtr     resq 1
    backPropStorage resq 1
    trainingData    resq 1

; ==================================
; createBackpropArena()
; Allocates a gradient storage arena (biases + weights)
; ==================================
createBackpropArena:
    mov rsi, nodeSize
    shr rsi, 1              ; half of nodeSize covers just the bias slots
    add rsi, weightSize
    mov rdx, 3
    mov r10, 34
    call allocateHeap

    mov [backPropStorage], rsi
    mov [backPropPtr], rax
    ret

; ==================================
; calculateAllGradients()
; Iterates backwards through all layers, neurons, and weights
; updating each weight via the chain rule.
; ==================================
calculateAllGradients:
    layerIndex  equ rax
    mov rax, [networkLayers]

    neuronIndex equ rdx
    mov rdx, [networkShape + rax*4]

    weightIndex equ r11
    mov r11, 0

    assignLayerLoop:
        assignNeuronLoop:
            mov weightIndex, 0
            call assignWeightLoop

            dec neuronIndex
            cmp neuronIndex, 0
            jg assignNeuronLoop

        mov rdx, [networkShape + layerIndex * 4]    ; reset neuronIndex for next layer
        dec layerIndex
        cmp layerIndex, 0
        jg assignLayerLoop
    ret

; ==================================
; assignWeightLoop()
; Applies one gradient update to a single weight.
; rcx: layer index
; neuronIndex (rdx), weightIndex (r11)
; ==================================
assignWeightLoop:
    call sumPrevious                                    ; xmm2 = accumulated gradient
    movss [networkPtr + neuronIndex*8 + rcx], xmm2

    dec weightIndex
    cmp weightIndex, 0
    jg assignWeightLoop
    ret

; ==================================
; calculateLayerGradient()
; Computes the full gradient for one weight via chain rule:
;   gradient = sumPrevious * costDerivative * neuronDerivative * reluDerivative
; rcx: target weight
; rdx: layer pointer
; ==================================
calculateLayerGradient:
    call sumPrevious
    call costDerivative
    call neuronDerivative
    call reluDerivative
    ret

; ==================================
; costDerivative()
; Computes 2 * (predicted - actual) into xmm0
; ==================================
costDerivative:
    call locateResult       ; xmm0 = predicted value
    call findTraining       ; xmm1 = actual value
    subss xmm0, xmm1
    addss xmm0, xmm0        ; * 2
    ret

; ==================================
; neuronDerivative()
; Multiplies the cost gradient by the weight value (xmm2)
; xmm0 in/out
; ==================================
neuronDerivative:
    mulss xmm0, xmm2
    ret

; ==================================
; reluDerivative()
; Zeroes xmm0 if the pre-activation value was <= 0 (ReLU backward pass)
; xmm0 in/out
; ==================================
reluDerivative:
    xorps xmm1, xmm1
    ucomiss xmm0, xmm1
    jbe reluDerivZero
    ret

reluDerivZero:
    movss xmm0, [zero]
    ret

; ==================================
; stashResult()
; Stores a backprop gradient into the arena
; xmm1: value to store
; rax:  layer index
; rdx:  neuron index
; ==================================
stashResult:
    mov r8, [networkOffset + rax*4]
    movss [backPropPtr + r8 + rdx*4], xmm1
    ret

; ==================================
; locateResult()
; Loads a backprop gradient from the arena
; rax:  layer index
; rdx:  neuron index
; returns xmm0
; ==================================
locateResult:
    mov r8, [networkOffset + rax*4]
    movss xmm0, [backPropPtr + r8 + rdx*4]
    ret

; ==================================
; findTraining()
; Loads a training label value
; rax: pointer to training data array
; rcx: index into that array
; returns xmm1
; ==================================
findTraining:
    movss xmm1, [rax + rcx*4]
    ret

; ==================================
; sumPrevious()
; Sums the downstream gradients for the weight being updated.
; rax (layerIndex), rdx (neuronIndex), r11 (weightIndex)
; returns xmm2 (cumulative sum)
; ==================================
sumPrevious:
    layerIndex  equ rax
    neuronIndex equ rdx
    weightIndex equ r11

    inc layerIndex              ; gradients flow from the next layer forward

    xorps xmm2, xmm2            ; culmSum = 0.0

    backpropLayerLoop:
        inc r9
        imul r9, 4
        mov ebx, [networkShape + r9]

        mov neuronIndex, 0
        backpropNeuronLoop:
            mov weightIndex, 0
            call backpropWeightLoop

            inc neuronIndex
            cmp neuronIndex, [networkShape + layerIndex * 4]
            jl backpropNeuronLoop

        inc layerIndex
        cmp layerIndex, [networkLayers]
        jl backpropLayerLoop
    ret

; ==================================
; backpropWeightLoop()
; Accumulates one weight's gradient contribution into xmm2
; ==================================
backpropWeightLoop:
    call locateResult                                       ; xmm0 = downstream gradient

    mov r9, [networkOffset + layerIndex*4]
    movss xmm1, [networkPtr + r9 + neuronIndex*4 + weightIndex*4]
    mulss xmm0, xmm1
    addss xmm2, xmm0

    inc weightIndex
    cmp weightIndex, [networkShape + r9 + 4]
    jl backpropWeightLoop
    ret
