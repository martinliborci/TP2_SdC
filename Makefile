CC=gcc
CFLAGS=-I.
NASM= nasm -f elf32

ASM: 	
	as -g -o main.o main.S
	ld --oformat binary -o main.img -T link.ld main.o
	# qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio
	qemu-system-i386 -drive 'file=main.img,format=raw' -serial mon:stdio -smp 2
