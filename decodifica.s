.section .data
    error_message:      .string "E(O)RRORE: valori in input non riconosciuti\n"
    error_len:          .long . - error_message
.section .bss

.macro stampa_errore    # MACRO DI STAMPA DI UN MESSAGGIO DI ERRORE
    movl    $4, %eax
    movl    descrittore_write, %ebx
    leal    error_message, %ecx
    movl    error_len, %edx
    int     $0x80
.endm

.section .text

    .global DECODE
    .type DECODE, @function
                            # RICEVE IN ESI IL PUNTATORE ALLA STRINGA DA DECODIFICARE
                            # RITORNA IL VALORE NEL REGISTRO EDX
DECODE:
    # SALVATAGGIO SULLO STACK DEI REGISTRI NON UTILIZZATI COME PASSAGGIO PARAMETRI
    pushl   %eax
    pushl   %ebx
    pushl   %ecx
    pushl   %esi        # Salvo il valore contenuto nel registro esi (che potrebbe essere
                        # modificato nella funzione)

    xorl    %ecx, %ecx
confronta_zero:

    movb    (%esi), %bl     # Sposto nel registro bl (parte low di ebx) il valore puntato da esi
                            # NOTA: qui viene spostato un valore alla volta, in quanto INIT e RESET
                            # devono essere presi singolarmente
    cmp     $48, %bl            # if (*esi == 0)
    je      ritorna_zero        #   return 0;

    cmp     $49, %bl            # else if (*esi == 1)
    je      ritorna_uno         #   return 1;
    jmp     ritorna             # else
                                #   return confronta_zero(esi+1);

ritorna_zero:
    movl    $0, %edx
    jmp     fine

ritorna_uno:
    movl    $1, %edx
    jmp     fine

ritorna:
    # Se il valore contenuto in bl non è un valore di tipo binario, viene rieseguita la funzione
    # con il puntatore esi incrementato di una posizione
    testl   %ecx, %ecx      # verifico che la funzione non si ripeta più di una volta
    jnz     errore          # affinché non vada a prendere valori non desiderati

    inc     %esi            # incremento il puntatore alla stringa
    inc     %ecx            # incremento il contatore ecx per la verifica dei cicli
    jmp     confronta_zero  # salta all'inizio della funzione

errore:
    stampa_errore           # Se il ciclo è stato ripetuto più di due volte (il che significa
    movl    $-1, %edx       # che sono stati trovati due valori di seguitno non decimali),
    jmp     fine            # la funzione ritorna -1 come segnale di errore


fine:
    # RIPRISTINO DELLA SITUAZIONE ORIGINALE
    popl    %esi
    popl    %ecx
    popl    %ebx
    popl    %eax
ret
