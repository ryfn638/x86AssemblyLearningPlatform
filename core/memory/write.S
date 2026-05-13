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
