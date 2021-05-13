	.equ CODE_SEG, 8
	.equ DATA_SEG, gdt_data - gdt_start

	/*Se empieza en modo real, con instrucciones de 16 bits*/
	.code16
	
		/*Se deben inhabilitar las interrupciones, porque no se usan en modo real*/
		cli 	

		/* Se carga la GDT */
		lgdt gdt_descriptor			

		/*Se entra a modo protegido, se debe poner en 1 el primer bit de CR0 (PE=1)*/
	    mov %cr0, %eax
	    orl $0x1, %eax
	    mov %eax, %cr0

	    /*Se salta a un codigo con istrucciones de 32 bits, para estar completamente en modo protegido*/
	    ljmp $CODE_SEG, $protected_mode
	    /*CODE_SEG tiene un valor de 8, porque el primer descriptor de la GDT es nulo y no se usa*/

	    /*Estructura de GDT*/
	    /* Un SO real necesitaría al menos 2 segmentos mas, de dato y de codigo, perteneciente al usuario*/

		gdt_start:
		gdt_null:
			/*El primer elemento de GDT siempre es nulo*/
		    .long 0x0
		    .long 0x0
		gdt_code:
			/* Segmento de codigo, donde es imposible escribir (esto se define en los atributos)*/ 							
		    .word 0xffff			/*limite = FFFF*/		     		
		    .word 0x0 				/*base = 0*/		
		    .byte 0x0
		    .byte 0b10011010
		    .byte 0b11001111
		    .byte 0x0
		gdt_data:
			/* Segmento de datos, donde es imposible ejecutar (esto se define en los atributos)*/ 
		    .word 0xffff
		    .word 0x0
		    .byte 0x0
		    .byte 0b10010010
		    .byte 0b11001111
		    .byte 0x0
		gdt_end:
		gdt_descriptor:
			/*Este es el descriptor de la DGT. La primer palabra es el tamaño,
			* la segunda parte es el limite*/
		    .word gdt_end - gdt_start
		    .long gdt_start
		vga_current_line:
    		.long 0
		
	.code32
		protected_mode:
		   
		    /*Aqui se actualiza la caché de todos los registros de segmentos*/
		    /*Fijarse que solo falta CS, es porque se actualiza en el salto*/

		    mov $DATA_SEG, %ax
		    mov %ax, %ds
		    mov %ax, %es
		    mov %ax, %fs
		    mov %ax, %gs
		    mov %ax, %ss

		   /*direccion de la pila. Es decir, el stack pointer va a appuntar a 0x7000 */
		    mov $0X7000, %ebp
		    mov %ebp, %esp
		
			/*Para imprimir mensaje siempre con VGA!*/

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
		    /* color. */
		    mov $0x3232CE, %ah
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
		message:
    		.asciz "Ejemplo en modo protegido - Liborci-Reyes"


