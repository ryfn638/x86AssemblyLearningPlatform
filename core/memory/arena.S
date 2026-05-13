
; Arena Allocator here


; Arena allocator is essentially just making a big block
create_arena:
    ; Create a memory arena, each memory arena is the size of an entire batch
    ; We're just going with a batch size of 1, So we can just use a singular batch
    ; and update it later
    
    ; TODO
    ; Probably offer some kind of memory structure rather than how we currently have it
    ; Make a method to easily access specific batches of the network, but thats for a lter date when we area going to be using more than 1 batch
    
    
    ; ======================
    ; allocate_heap()
    ; allocates memory to the heap, this is for dynamic memory in our arena
    ; rax: 9 - Linux mmap (const)
    ; rdi startingAddress
    ; rsi Length
    ; rdx protection flags
    ; r10 mapping flags
    ; r8 file descriptor
    ; r9 Offset (usually 0)
    ; Returns come from rax which is the virtual address
    
    mov rsi, nodeSize
    mul rsi, weightSize
    mov rdx, 3 ; Read and write permissions
    mov r10, 34 ; Private
    call allocate_heap

    ; rax is now the address of our memory map
    mov rbp, rsi ; rbp is our storage for our arena
    mov r12, rax ; r12 is our pointer to the arena memory
    ret

free_arena:
    mov rdi, r12
    mov rsi, rdp
    
    call free_heap
    ;; Now our heap is deallocated (allegedly)

    ret