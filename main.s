.section .data
    # COSTANTI INIZIALIZZATE
    init_zero:          .string "0,00,00\n"
    eseguito:           .string "Eseguito!\n"
    eseguito_len:       .long . - eseguito
    buff_size:          .long 9
.section .bss
    .lcomm buff, 9                  # Buffer di lettura
    descrittore:        .long 0
    descrittore_write:  .long 0
    INIT:       .byte 0
    RESET:      .byte 0
    RPM:        .long 0
    ALM:        .long 0
    MOD:        .long 0
    NUMB:       .long 0

# MACRO DI SEMPLIFICAZIONE DELLA SCRITTURA DEL CODICE

.macro azzera_registri  # MACRO PER AZZERARE I REGISTRI USATI NEL CORSO DEL PROGRAMMA
    xorl    %eax, %eax
    xorl    %ebx, %ebx
    xorl    %ecx, %ecx
    xorl    %esi, %esi
    xorl    %edi, %edi
.endm

.macro total_reset      # MACRO DI RESET DEI SECONDI E DELL'ALARME
    movl    $0, NUMB
    movl    $0, ALM
.endm

.section .text

        .global _start
        # VARIABILI GLOBALI
        .global      buff
        .global      buff_size
        .global      descrittore
        .global      descrittore_write

        .global      RPM
        .global      ALM
        .global      NUMB
        .global      MOD

_start:

    azzera_registri             # Azzera i registri da utilizzare

#######################################   APERTURA FILE   ########################################
    # PRELEVA I PARAMETRI PASSATI DA LINEA DI COMANDO
    popl    %ebx                # Preleva il nr. dei parametri
    popl    %ebx                # Preleva il nome del programma

    # OPEN FILE DI INPUT
        popl    %ebx                # Preleva il primo parametro: file di input
        movl    $0, %ecx            # PARAMETRO SOLO LETTURA
        call    OPEN                # Apre il file di input (EBX ne contiene il nome)
        movl    %eax, descrittore           # Salva il valore del descrittore in un'apposita variabile

        cmp     $0, %eax            # Se il file non è stato aperto
        jl      fine                # EXIT

    # OPEN FILE DI OUTPUT
        popl    %ebx                # Preleva il secondo parametro: file di output
        movl    $2, %ecx            # PARAMETRO SOLO SCRITTURA
        call    OPEN                # Apre il file di input (EBX ne contiene il nome)
        movl    %eax, descrittore_write     # Salva il valore del descrittore in un'apposita variabile

        cmp     $0, %eax            # Se il file non è stato aperto
        jl      fine                # EXIT

#######################################   ELABORAZIONE   #########################################
inizio:
    # CARICAMENTO DEI VALORI DAL FILE DI INPUT
        call    READ                # ESI contiene il puntatore alla stringa prelevata
        cmp     $0, %eax            # EOF:se ho letto tutto il file
        je      done                # EXIT



    # IDENTIFICO IL VALORE DI INIT
        call    DECODE              # Ritorna il valore nel registro EDX
        movl    %edx, INIT          # Salvo nell'appostiva variabile il suo valore
        cmp     $-1, INIT           # Se la funzione ha prodotto un messaggio di errore
        je      inizio              # Stampa NEL FILE un messaggio di errore

        cmp     $0, INIT            # Se INIT = 0, salva nel file la stringa init_zero ( = 0,00,00)
        je      write_file

    # IDENTIFICO IL VALORE DI RESET
    addl    $2, %esi            # Sposto il puntatore alla stringa di due posizioni
                # La prima per non considerare la virgola, la seconda
                # posizione invece mi farà puntare al valore da decodificare

        call    DECODE
        movl    %edx, RESET         # Salvo nell'appostiva variabile il suo valore
        cmp     $-1, RESET          # Se la funzione ha prodotto un messaggio di errore
        je      inizio              # Stampa NEL FILE un messaggio di errore

    # EVENTUALE RESET DEI SECONDI E DELL'ALLARME
    cmp     $1, RESET           # Se RESET = 1, azzero il contatore dei secondi e l'allarme
    jne     after_reset
    total_reset                 # Chiamata della macro che racchiude l'azzeramento delle variabili

after_reset:

    # IDENTIFICO IL VALORE DEGLI RPM
    xorl    %eax, %eax
    addl    $2, %esi            # Sposto il puntatore alla stringa di due posizioni

        movl    %esi, %eax          # La funzione atoi richiede un puntatore nel registro EAX
        call    atoi                # Il valore degli RPM viene dunque ritornato sempre in EAX
        cmp     $-1, %eax           # Se la funzione ha prodotto un errore: viene salvato nel file
        je      inizio              # un messaggio di errore e si riprende dalla riga successiva
                                    # nel file di input
        movl    %eax, RPM           # Salvo il valore degli RPM nell'apposita variabile

    # RILEVA LA MODALITA' DI FUNZIONAMENTO DEL MOTORE IN BASE AL VALORE DEGLI RPM
    movl    MOD, %eax           # Salvo preventivamente il precedente valore di MOD

        call    MOD_DETECT
        cmp     $-1, %eax           # Se la funzione ha prodotto un errore: viene salvato nel file
        je      inizio              # un messaggio e riprende dalla riga successiva nel file di input

    cmp     MOD, %eax           # Quando MOD cambia, vengono automaticamente resettati
    je      after_mod
    total_reset                 # il contatore dei secondi e l'eventuale allarme

after_mod:                      # Se MOD non cambia
    # RILEVA ALLARME
    cmp     $15, NUMB           # Se sono passati più di 15 secondi
    jl      continua
    cmp     $11, MOD            # e la modalità attiva è FUORI-GIRI
                                # ATTIVA ALLARME
    jne     continua            # Altrimenti continua

        # ATTIVA ALARME
        movb    $1, ALM

continua:
    # CODIFICA I VALORI E LI SALVA NEL FILE DI OUTPUT
    call    CODIFICA

    incl    NUMB                # Incremento il contatore dei secondi

    jmp     inizio              # PASSO ALLA RIGA SUCCESSIVA


write_file:                     # Scrive direttamente nel file la stringa "0,00,00"
    leal    init_zero, %edi     # Carica in EDI il puntatore alla stringa da scrivere sul file
    movl    $8, %edx            # Carica in EDX la dimensione della stringa
    call    WRITE               # Funzione WRITE
    total_reset
    jmp     inizio              # Riprende dalla riga successiva
##################################################################################################
done:
    movl    $4, %eax            # Stampa messaggio generico di operazione completata
    movl    $1, %ebx
    leal    eseguito, %ecx
    movl    eseguito_len, %edx
    int     $0x80

fine:
    movl    $1, %eax		# exit(
    movl    $0, %ebx		# 0
    int     $0x80   		# );
