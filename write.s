.section .data
.section .bss
.section .text

    .global WRITE
    .type WRITE, @function

                            # RICEVE IL PUNTATORE DELLA STRINGA DA SCRIVERE NEL FILE OUTPUT
                            # NEL REGISTRO EDI
                            # RICEVE NEL REGISTRO EDX LA DIMENSIONE DELLA STRINGA
WRITE:
    # SALVATAGGIO SULLO STACK DEI REGISTRI CHE VERRANNO UTILIZZATI NELLA FUNZIONE
    pushl   %eax
    pushl   %ebx
    pushl   %ecx

    # SCRITTURA NEL FILE DI OUTPUT
    movl    descrittore_write, %ebx		# file_descriptor,
    movl    $4, %eax		# write(
    movl    %edi, %ecx      # *buf,
    	# edx contiene da dimensione del buffer da scrivere
    int     $0x80      		# );

    # RIPRISTINO DELLA SITUAZIONE ORIGINALE
    popl    %ecx
    popl    %ebx
    popl    %eax
ret
