extern printf

section .text
global _start

_start:
  ; Small tutorial on how to print with printf ideally

  call printHello

  mov eax, 60
  xor edi, edi
  syscall
