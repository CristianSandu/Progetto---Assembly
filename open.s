.section .data
    open_error:         .string "Attenzione! Non è stato possibile aprire il file!\n"
    open_len:           .long . - open_error
.section .bss
.section .text

    .global OPEN
    .type OPEN, @function
                            # RICHIEDE CHE IL REGISTRO EBX CONTENGA IL NOME DEL FILE DA APRIRE
                            # ECX INVECE DEVE CONTENERE IL VALORE DELLA MODALITA' DI APERTURA DEL FILE
                            # RESITUISCE IL DESCRITTORE DEL FILE APERTO NEL REGISTRO EAX

OPEN:
    # SALVATAGGIO SULLO STACK DEI REGISTRI CHE VERRANNO MODIFICATI DALLA FUNZIONE
    pushl   %edx

    # APERTURA DEI FILE
    movl    $5, %eax		# open(
            # ebx contiene il file da aprire
    		# ecx contiene il valore per la modalità lettura e/o scrittura
    int     $0x80		    # );

    # VERIFICA CHE IL FILE SIA STATO APERTO
    cmp     $0, %eax
    jl      stampa_errore_apertura  # Se la funzione non ha aperto il file -> stampa a video
                                    # un messaggio di errore ed esce dal programma (nel main)
    jmp     fine                    # Altrimenti ritorna il descrittore nel registro EAX

stampa_errore_apertura:             # MESSAGGIO DI ERRORE
    movl    $4, %eax
    movl    $1, %ebx
    leal    open_error, %ecx
    movl    open_len, %edx
    int     $0x80
    movl    $-1, %eax

fine:
    # RITORNA IL DESCRITTORE NEL REGISTRO EAX
    # RIPRISTINO DELLA SITUAZIONE ORIGINALE
    popl    %edx
ret
