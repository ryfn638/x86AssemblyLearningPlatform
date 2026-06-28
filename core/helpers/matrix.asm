; Matrix Multiplication helpers for the network
; treating existing network structure
; ptr is currently
; but i think it should be two different array pointer lists
; [n, b, w1, w2, w3, w4, w5]
; n11, n21 , n31, n41 -> nij where i is the neuron in the network, and j is the layer
; Then rather than needing to refer to an external shape, we can determine layer swith
; [n_neuron, nij, ni+1j] and so on, it makes sense for n_neuron to be coupled
; Matrix Pointers for operations
section .bss
 matrixA resb 8
 matrixB resb 8

section .text

global multiplyMatrix

