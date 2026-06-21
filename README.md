# AssemblyLearn
## Overview
A pure x86-64 NASM assembly project for learning low-level programming, built as a warmup toward OS development.
This is practice-oriented — don't expect perfect assembly usage.

## Structure
```
core/
  main.asm          - entry point
  debug/
    io.asm          - string printing (printStr)
    ionum.asm       - integer printing (printInt)
  memory/
    arena.asm       - memory arena management
    allocate.asm    - allocation helpers
    write.asm       - memory write utilities
    const.asm       - constants
  helpers/
    mathMul.asm     - matrix/math multiplication
    backprop.asm    - neural network back propagation
```

## Building
```bash
cd core
make        # build
make clean  # remove objects and binary
```

## Debug Utilities
```nasm
; print a null-terminated string
lea rsi, myString
call printStr

; print an integer
mov rsi, 42
call printInt
```
