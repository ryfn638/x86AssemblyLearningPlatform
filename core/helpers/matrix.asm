; Matrix Multiplication helpers for the network
; Matrix operations, so I dont get aids doing this

global matrixA
global matrixAWidth
global matrixAHeight

global matrixB
global matrixBWidth
global matrixBHeight

section .bss
 matrixA resb 8
 matrixAWidth resb 8
 matrixAHeight resb 8

 matrixB resb 8
 matrixBWidth resb 8
 matrixBHeight resb 8

 outputMatrix resb 8 ; Pointer to the output matrix
 outputMatrixWidth resb 8 ; User doesnt define these, more for utility
 outputMatrixHeight resb 8 ; Same deal with this variable here

section .data
  ERR_WRONG_DIMENSIONS db "Matrices are different dimensions", 0

section .text

; Allocating the heap for the output matrix
global allocateOutputMatrix
allocateOutputMatrix:
  mov [abs outputMatrixWidth], [matrixBWidth]
  mov [abs outputMatrixHeight], [matrixAHeight]
  mov rdi, 0
  mov rsi, [abs outputMatrixWidth]
  imul rsi, [abs outputMatrixHeight]
  imul rsi, 4
  call allocateHeap
  mov outputMatrix, rax ; 
  ret


global multiplyMatrix
multiplyMatrix:
  cmp [abs matrixAWidth], [abs matrixBHeight]
  je validMultiplication

  lea rsi, ERR_WRONG_DIMENSIONS
  call printStr
  jmp end

  validMultiplication:
    ; nitty gritty multiplication matrix stuff
  call allocateOutputMatrix

  end:
  ret

global multiplyMatrix ; For backpropagation
sumMatrix:
  ret

global addMatrix ; For the biases
addMatrix:
  ret

