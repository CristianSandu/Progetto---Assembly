.section .data
.section .bss
    tmp:    .long 0     # Variabile temporanea

.macro stampa_zero  # MACRO DI SALVATAGGIO DEL VALORE 0 IN ASCII NEL FILE DI OUTPUT
    movl    $48, tmp            # 0 (ascii) = 48 (intero)
    movl    $tmp, %edi
    movl    $1, %edx            # dimensione 1
    call    WRITE               # Funzione di scrittura (riceve in edi il puntatore al valore da scrivere)
.endm
.macro stampa_uno   # MACRO DI SALVATAGGIO DEL VALORE 1 IN ASCII NEL FILE DI OUTPUT
    movl    $49, tmp            # 1 (ascii) = 49 (intero)
    movl    $tmp, %edi
    movl    $1, %edx            # dim 1
    call    WRITE
.endm
.macro stampa_virgola # MACRO DI SALVATAGGIO DELLA VIRGOLA IN ASCII NEL FILE DI OUTPUT
    movl    $44, tmp            # , (ascii) = 44 (intero)
    movl    $tmp, %edi
    movl    $1, %edx            # dim 1
    call    WRITE
.endm

.section .text
    .global CODIFICA
    .type CODIFICA, @function   # LA FUNZIONE CODIFICA RICEVE IN INGRESSO LE VARIABILI GLOBALI ALM, MOD e NUMB
                                # NE CODIFICA IL CORRISPONDENTE VALORE IN ASCII E LO SCRIVE SUL FILE DI OUTPUT
                                # NOTA: Anche il "descrittore_write" è una variabile globale
CODIFICA:
    # SALVATAGGIO SULLO STACK DEI REGISTRI INUTILIZZATI
    pushl   %eax
    pushl   %ebx
    pushl   %ecx
    pushl   %edx
    pushl   %esi
    pushl   %edi

# CODIFICA E SCRITTURA DI ALLARME (ALM)
    cmp     $1, ALM             # Se allarme = 1
    je      allarme_49          #   scrivi 1 nel file;
    jne     allarme_48          #   altrimenti scrivi 0;
dopo_allarme:

    stampa_virgola

# CODIFICA E SCRITTURA DELLA MODALITA' DI FUNZIONAMENTO (MOD)
    cmp     $1, MOD             # Se MOD = 1 (sotto-giri)
    je      sotto_giri          #   scrivi 01;
    cmp     $10, MOD            # Se MOD = 10 (ottimale)
    je      ottimale            #   scrivi 10;
    cmp     $11, MOD            # Se MOD = 11 (fuori-giri)
    je      fuori_giri          #   scrivi 11;
dopo_mod:

    stampa_virgola

# CODIFICA E SCRITTURA DEI SECONDI (NUMB)
    cmp     $10, NUMB           # Se NUMB è < 10 (composto solo da una cifra)
    jl      aggiungi_zero       #   aggiunge uno zero
dopo_zero:                      # Altrimenti
    movl    NUMB, %eax          #   scrive il valore ascii di NUMB nel file di output tramite
    call    ITOA                #   la funzione ITOA, che ne riceve il valore nel registro eax
    jmp     fine


aggiungi_zero:
    stampa_zero
    jmp     dopo_zero       # Ritorna al passo successivo
allarme_48:
    stampa_zero
    jmp     dopo_allarme    # Ritorna al passo successivo
allarme_49:
    stampa_uno
    jmp     dopo_allarme    # Ritorna al passo successivo
sotto_giri:
    stampa_zero
    stampa_uno
    jmp     dopo_mod        # Ritorna al passo successivo
ottimale:
    stampa_uno
    stampa_zero
    jmp     dopo_mod        # Ritorna al passo successivo
fuori_giri:
    stampa_uno
    stampa_uno
    jmp     dopo_mod        # Ritorna al passo successivo

fine:
    # RIPRISTINO DELLA SITUAZIONE ORIGINALE
    popl    %edi
    popl    %esi
    popl    %edx
    popl    %ecx
    popl    %ebx
    popl    %eax
ret
