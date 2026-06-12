; ==================================
; Back Propagation Algorithm Section
; ==================================

; Configured learning rate
section .data
    learningRate dd 0.0003

create_backprop_arena:  
    mov rsi, nodeSize
    div rsi, 2 ; nodeSize contains twice the size at the moment for both the nodes and biases, we just want bias
    add rsi, weightSize
    mov rdx, 3 ; Read and write permissions
    mov r10, 34 ; Private
    call allocate_heap

    ; Storage for the back propogation heap, need to make heap too much for stack
    mov [backPropStorage], rsi ; rbp is our storage for our arena
    mov [backPropPtr], rax ; r12 is our pointer to the arena memory
    ret




; ==================================
; calculate_all_gradients()
; ==================================
; updates all weights with updated vaulues based on back propagation
calculate_all_gradients:

    assignLayerIndex equ rax 
    mov rax, [networkLayers]

    assignNeuronIndex equ rdx 
    mov rdx, [networkShape + layerIndex * 4]

    assignweightIndex equ r11
    mov r11, [networkShape + r9 + 4]

    call assignLayerLoop

    assignLayerLoop:
        ; Looping over all the hidden layers, might abstract a method to loop over all the weights that belong to a neuron
        assignNeuronLoop:
            mov weightIndex, 0
            call assignWeightLoop
            
            mov rcx, [networkShape + layerIndex * 4]
            cmp neuronIndex, [networkShape + layerIndex * 4] ; Compare it with the amount of neurons on our hidden layer
            dec neuronIndex
            jl assignNeuronLoop

        dec assignLayerIndex
        cmp assignLayerIndex, 0
        jl assignLayerLoop ; Loop over the layers until all have been iterated through
    ret

; params
; rcx is the layer being worked on
; neuronIndex, neuron Index in the list
; weightIndex, weight index
assignWeightLoop:
    ; Adjust individual weights
    call sum_previous ; initialises the previous weights loop, xmm2 contains the culmulative sum
    mov [networkPtr + 8*neuronIndex + rcx], xmm2

    cmp weightIndex, 0
    dec weightIndex

    jl weight_loop

; ==================================
; calulate_layer_gradient()
; Calculates the gradients for a singular layer;
; rcx is the target weight
; rdx is the layer pointer
; assume a pointer TrainingData that points to a real training value
; ==================================
calculate_layer_gradient:
    call sum_previous

    ; calculates a singular gradient for a weight
    call cost_derivative
    call neuron_derivative
    call relu_derivative

    ret
;

; Cost derivative function
; returns output to xmm0
cost_derivative:
    ; (2 * (found - real))
    call locate_result
    ret
;

; Neuron Derivative
; returns to xmm0 and multiplies it by the weight (in xmm2)
neuron_derivative:
    mulss xmm0, xmm2
    ret

; extension of relu_deriv_zero
relu_deriv_zero:
    movss xmm0 [zero] ; set xmm0 to 0 if it is below zero leave it if not
    ret

; relu_derivative
; params xmm1
; outputs to xmm0
relu_derivative:
    xorps xmm1, xmm1
    ucomiss xmm0, xmm1
    jbe relu_deriv_zero
    ret

; ==================================
; stashes the result of a back propogation value for easy access inside of a memory arena
; params
; xmm1 the value being stored in the arena
; rax the layer index
; rdx the neuron index
; ==================================
stash_result:
    movss r8, [networkOffset + rax*4] ; Pointer to start of neuron list
    movss [backPropPtr + r8 + rdx], xmm1 ; store xmm1 in the arena
    ret ;
;



; ==================================
; locate_result()
; returns a value from the backpropagation arena
; params
; rax the layer index
; rdx the neuron index
; returns, uses r8
; xmm0
locate_result:
    movss r8, [networkOffset + rax*4] ; pointer to start of neuron list
    movss xmm0, [backPropPtr + r8 + rdx] ; store arena pointer location into xmm0
    ret
;

; ==================================
; find_training()
; Finds the training data value for a specific training index
; params
; rax the pointer to the training data
; rcx the training data index
; returns
; xmm1 the training data in float form
; ==================================
find_training:
    movss xmm1 [rax + rcx*4] ; treat training data like a list going down, same as network
    ret
;

; ==================================
; sum_previous()
; Sums all of the previously calculated gradients and returns the result into xmm0
; params
; rax : layerIndex, the layer of the weight
; rdx : neuronIndex, the neuron the weight is connected to
; r11 : weightIndex, weight index of the neuron
; returns the result into xmm0 for new updates
; ==================================
sum_previous:
    layerIndex equ rax 
    inc layerindex ; neurons are connected starting at next layer.

    neuronIndex equ rdx 
    weightIndex equ r11
    
    movss xmm2, 0
    culmSum equ xmm2

    layerLoop:
        ; Looping over all the hidden layers, might abstract a method to loop over all the weights that belong to a neuron
        inc r9
        imul r9, 4
        mov ebx, [networkShape + r9]
        neuronLoop:
            mov weightIndex, 0
            call weight_loop
            
            cmp neuronIndex, [networkShape + layerIndex * 4] ; Compare it with the amount of neurons on our hidden layer
            inc neuronIndex
            jl neuronLoop
        
        cmp layerIndex, [networkLayers]
        jl layerLoop ; Loop over the layers until all have been iterated through
    ret
;

weight_loop:
   
    ; Adjust individual weights
    call locate_result ; xmm0 now contains the param value

    mov r9, [networkOffset + layerIndex*4] ; first neuron of the layer

    movss xmm1, [networkPtr + r9 + neuronIndex*4 + weightIndex*4]
    mulss xmm0, xmm1
    addss culmSum, xmm0 ; xmm0 does weight * param 

    cmp weightIndex, [networkShape + r9 + 4]
    inc weightIndex

    jl weight_loop

    ret