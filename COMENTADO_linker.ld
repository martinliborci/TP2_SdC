SECTIONS
{
    /*      */
    . = 0x7c00;
    .text :
    {
        __start = .;
        *(.text)        /* Inserta todo el código fuente del archivo .text a partir de aquí         */
        . = 0x1FE;      /* mueve el puntero a 0x1FE dentro de .text. 
                           0x1FE == 510 bytes es donde comimienza la firma del MBR (Boot signature) */
        SHORT(0xAA55)   /* almacena estos dos bytes aquí: en las direcciones 0x1FE y 0x1FF en .text 
                           0x1FE (510 bytes) = 0x55
                           0x1FF (511 bytes) = 0xAA */

        /* Lo que sigue a partir de aquí sólo es necesario si se utiliza un proceso de arranque en 2 etapas. */
        *(.stage2)

        /* Number of sectors in stage 2. Used by the `int 13` to load it from disk.
         *
         * The value gets put into memory as the very last thing
         * in the `.stage` section if it exists.
         *
         * We must put it *before* the final `. = ALIGN(512)`,
         * or else it would fall out of the loaded memory.
         *
         * This must be absolute, or else it would get converted
         * to the actual address relative to this section (7c00 + ...)
         * and linking would fail with "Relocation truncated to fit"
         * because we are trying to put that into al for the int 13.
         */
        __stage2_nsectors = ABSOLUTE((. - __start) / 512); /* Número de sectores en la etapa 2. 
                            Usado por la interrupción del BIOS int 13 para cargarla desde el disco. 
                            El valor obtenido se guarda en la memoria como la última cosa almacenada 
                            en la sección .stage si existe. (Ver macro STAGE2 en common.h) */

        . = ALIGN(512);         /* La imagen generada del MBR debe tener un tamñano de 512 bytes exactamente */
        __end = .;              /* La imagen generada del MBR debe tener un tamñana de 512 bytes exactamente */
        __end_align_4k = ALIGN(4k); 
    }
}
