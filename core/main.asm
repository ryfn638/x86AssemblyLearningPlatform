extern printStr
extern printInt
extern newLineBool

section .data
  msg db "Initialising Network", 0

section .text
global _start


_start:
  ; Small tutorial on how to print with printf ideally
  
  ; How to print a string, easy as!
  lea rsi, msg
  call printStr

  ; How to print an Integer, sweeeet
  mov rsi, 48
  call printInt

  mov rsi, 120
  call printInt


  mov eax, 60
  xor edi, edi
  syscall
