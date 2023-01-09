all: reve.asm
	nasm -f elf64 reve.asm -o reve.o
	ld  reve.o -o reve
