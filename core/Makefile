ASM = nasm
AFLAGS = -f elf64
LD = ld

OBJ = main.o debug/io.o memory/const.o debug/ionum.o

all: main

%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@

main: $(OBJ)
	$(LD) $(OBJ) -o main

clean:
	rm -f $(OBJ) main
