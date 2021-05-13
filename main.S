	.equ CODE_SEG, 8
	.equ DATA_SEG, gdt_data - gdt_start


	.code16
		cli 

		lgdt gdt_descriptor

	    mov %cr0, %eax
	    orl $0x1, %eax
	    mov %eax, %cr0

	    ljmp $CODE_SEG, $protected_mode

		gdt_start:
		gdt_null:
		    .long 0x0
		    .long 0x0
		gdt_code:
		    .word 0xffff
		    .word 0x0
		    .byte 0x0
		    .byte 0b10011010
		    .byte 0b11001111
		    .byte 0x0
		gdt_data:
		    .word 0xffff
		    .word 0x0
		    .byte 0x0
		    .byte 0b10010010
		    .byte 0b11001111
		    .byte 0x0
		gdt_end:
		gdt_descriptor:
		    .word gdt_end - gdt_start
		    .long gdt_start
		vga_current_line:
    		.long 0
		
	.code32
		protected_mode:
		   
		    
		    mov $DATA_SEG, %ax
		    mov %ax, %ds
		    mov %ax, %es
		    mov %ax, %fs
		    mov %ax, %gs
		    mov %ax, %ss
		   
		    mov $0X7000, %ebp
		    mov %ebp, %esp
		
		/*Para imprimir mensaje siempre con VGA!*/

			push %eax
		    push %ebx
		    push %ecx
		    push %edx

		    mov $message, %ecx
		    mov vga_current_line, %eax
		    mov $0, %edx
		    /* Number of horizontal lines. */
		    mov $25, %ebx
		    div %ebx
		    mov %edx, %eax
		    /* 160 == 80 * 2 == line width * bytes per character on screen */
		    mov $160, %edx
		    mul %edx
		    /* 0xb8000 == magic video memory address which shows on the screen. */
		    lea 0xb8000(%eax), %edx
		    /* White on black. */
		    mov $0x0f, %ah
		loop:
		    mov (%ecx), %al
		    cmp $0, %al
		    je end
		    mov %ax, (%edx)
		    add $1, %ecx
		    add $2, %edx
		    jmp loop
		end:
		    incl vga_current_line
        pop %edx
	    pop %ecx
	    pop %ebx
	    pop %eax

    	message:
    		.asciz "Ejemplo en modo protegido - Liborci-Reyes"


