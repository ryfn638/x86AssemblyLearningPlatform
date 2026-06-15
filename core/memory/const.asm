global error_table
; Error Table Messages
section .data
  ERR_MAX_STR_LEN db "Character Limit Reached", 10, 0
  ERR_MAX_STR_LEN_S equ $ - ERR_MAX_STR_LEN

  ERR_NULL_PTR db "Referencing Null Pointer", 10, 0
  ERR_NULL_PTR_S equ $ - ERR_NULL_PTR

error_table:
  dq ERR_MAX_STR_LEN ; 0
  dq ERR_NULL_PTR    ; 1
