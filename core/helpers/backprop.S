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
calculate_all_gradients:
    ; calculate all of the weight gradients and update them in the arena
    ; factor in the learning rate
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

; returns a zero to xmm0 if invalid cost derivative
relu_deriv_zero:
    movss xmm0 [zero] ; set xmm0 to 0 if it is below zero leave it if not
    ret

; Derivative of the relu function
; returns output to xmm0 
relu_derivative:
    xorps xmm1, xmm1
    ucomiss xmm0, xmm1
    jbe relu_deriv_zero
    ret



; ==================================
; stashes the result of a back propogation value for easy access inside of a memory arena
; returns none
; takes params
; 
; ==================================
stash_result:
    ; stashes the result of the back propogation inside of the memory arena
;



; ==================================
; locate_result()
; returns a pointer from a previous result in rxa;
; params
; rxa = a pointer for the found back propogated value
locate_result:
    ; fetches a previously iterated back propogated value

;


; ==================================
; find_training()
; Finds the training data value for a specific training index
; rxc = The index of the training data we are searching
; ==================================
find_training:
    ; find a training data value for a specific index

;


; ==================================
; sum_previous()
; Sums all of the previously calculated gradients and returns the result into xmm0
; params
; returns the result into xmm0 for new updates
; ==================================
sum_previous:
    ; sums all the previous back propogated numbers
;


