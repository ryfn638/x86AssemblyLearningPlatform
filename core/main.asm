extern printf
extern newLineBool

section .data
  msg db "Ligma Balls", 0

section .text
global _start


_start:
  ; Small tutorial on how to print with printf ideally
  
  lea rsi, msg
  call printf

  mov eax, 60
  xor edi, edi
  syscall
