.section .data
.section .bss
.section .text
                            # LA FUNZIONE READ PRENDE IL DESCRITTORE DEL FILE IN CUI LEGGERE,
                            # DALLA VARIABILE GLOBALE "descrittore"
                            # RESTITUISCE IL PUNTATORE ALLA STRINGA I-ESIMA NEL REGISTRO ESI
                            # RESTITUISCE 0 IN EAX, NEL CASO DI EOF
    .global READ
    .type READ, @function

READ:
    # SALVATAGGIO SULLO STACK DEI REGISTRI CHE VERRANNO MODIFICATI DALLA FUNZIONE
    pushl   %ebx
    pushl   %ecx
    pushl   %edx

    xorl    %ebx, %ebx
    # LETTURA DAL FILE
	movl    descrittore, %ebx		   # file_descriptor,
	movl    $3, %eax		           # read(
	leal    buff, %ecx		           # *buf,
	movl    buff_size, %edx	           # bufsize
	int     $0x80		               # );

    # PASSAGGIO DEL PUNTATORE ALLA STRINGA TRAMITE REGISTRO ESI (SOURCE INDEX)
    movl    %ecx, %esi

    # RIPRISTINO DELLA SITUAZIONE ORIGINALE
    popl    %edx
    popl    %ecx
    popl    %ebx
ret
