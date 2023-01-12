all: reve.asm
	nasm -f elf64 reve.asm -o reve.o
	ld  reve.o -o reve

debug: reve.asm
	nasm -f elf64 -g -F dwarf -o reve.o reve.asm
	ld reve.o -o reve
