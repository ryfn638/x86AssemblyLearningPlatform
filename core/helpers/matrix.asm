; Matrix Multiplication helpers for the network
; Matrix operations, so I dont get aids doing this

global matrixA
global matrixAWidth
global matrixAHeight

global matrixB
global matrixBWidth
global matrixBHeight

global outputMatrix
global outputMatrixWidth
global outputMatrixHeight

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

 matrixBRowIndex resb 8
 matrixBColumnIndex resb 8

 matrixARowIndex resb 8
 matrixAColumnIndex resb 8


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
;

; Uses rax, xmm0 and xmm1
global multiplyMatrix
multiplyMatrix:
  cmp [abs matrixAWidth], [abs matrixBHeight]
  je validMultiplication

  lea rsi, ERR_WRONG_DIMENSIONS
  call printStr
  jmp end

  call allocateOutputMatrix

  mov [matrixAColumnIndex], 0
  mov [matrixARowIndex], 0
  mov [matrixBColumnIndex], 0
  mov [matrixBRowIndex], 0

  ;; Uses rax and rcx, Please cache these before using this function
  calculateOutputMatrix:
  matrixBLoop:
    matrixBRowLoop:
      ; check if the index is at the end of the column index
      cmp [matrixBColumnIndex], [matrixBWidth]
      je end

      mov rax, [abs matrixBRowIndex]
      imul rax, [abs matrixBWidth]
      add rax, [abs matrixBColumnIndex]
      mov xmm0, [matrixB + rax]
      call matrixARowLoop
      inc [abs matrixBRowIndex]

      cmp [matrixBRowIndex], [matrixBHeight] ; restart with an incremented loop
      jl matrixBRowLoop ; passes by this if equal
      mov [abs matrixBRowIndex], 0
      inc [abs matrixBColumnIndex]
      je matrixBRowLoop
    matrixARowLoop:
      ; Loads xmm1 with the output currently saved in the output matrix
      mov rcx, [abs matrixARowIndex]
      imul rcx, [abs outputMatrixWidth]
      add rcx, [abs matrixBColumnIndex]
      mov xmm1, [outputMatrix + rcx] ; load the value in the output to xmm1
      
      ; Gathers the value in matrix A
      mov rax, [abs matrixARowIndex]
      imul rax, [abs matrixAWidth]
      add rax, [abs matrixBRowIndex] ; bRowIndex = aColumnIndex basically

      ; matrixB value * matrixA value
      mulss xmm0, [matrixA + rax]
      addss xmm0, xmm1
      mov [outputMatrix + rcx], xmm0

      inc [abs matrixARowindex]
      cmp [abs matrixARowIndex], [abs matrixAWidth]
      jl matrixARowIndex
      
      ret
  mov [columnIndex], 0
  mov [rowIndex], 0

  end:
  ret

global multiplyMatrix ; For backpropagation
sumMatrix:
  ret

global addMatrix ; For the biases
addMatrix:
  ret

