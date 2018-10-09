.section .data
    mod_error:      .string "  Superata soglia massima di RPM!\n"
    mod_len:        .long . - mod_error
.section .bss
.section .text
    .global MOD_DETECT
    .type MOD_DETECT, @function
                            # LA FUNZIONE MOD_DETECT PRENDE IN INGRESSO LA VARIABILE GLOBALE RPM
                            # E SALVA IN MOD IL RELATIVO STATO IN CUI SI TROVA IL SISTEMA
MOD_DETECT:
    # SALVATAGGIO SULLO STACK DEI REGISTRI CHE VERRANNO MODIFICATI
    pushl   %ebx
    pushl   %ecx
    pushl   %edx
    pushl   %esi
    pushl   %edi

    xorl    %ebx, %ebx      # Azzeramento di EBX

    cmpl    $2000, RPM              # Confronto gli RPM con la costante 2000
    jl      sotto_giri              #    se minore --> SOTTO-GIRI
    cmpl    $4000, RPM              # Altrimenti confronta con 4000
    jle     regime_ottimale         #    se minore o uguale --> OTTIMALE
    cmpl    $6500, RPM              # Altrimenti confronta col valore massimo 6500
    jle     fuori_giri              #    se minore o uguale --> FUORI-GIRI
    jmp     errore                  # Altrimenti --> FUORI SOGLIA MASSIMA

sotto_giri:
    movl    $01, MOD                # Assegno alla variabile MOD il valore 01 (sotto-giri)
    jmp     fine

regime_ottimale:
    movl    $10, MOD                # Assegno alla variabile MOD il valore 10 (ottimale)
    jmp     fine

fuori_giri:
    movl    $11, MOD                # Assegno alla variabile MOD il valore 11 (fuori-giri)
    jmp     fine

errore:                             # Stampo nel file di output un eventuale messaggio di errore
    movl    $4, %eax                # se è stata superata la soglia massima di RPM (6500)
    movl    descrittore_write, %ebx
    leal    mod_error, %ecx
    movl    mod_len, %edx
    int     $0x80
    movl    $-1, %eax

fine:
    # RIPRISTINO DELLA SITUAZIONE ORIGINALE
    popl    %edi
    popl    %esi
    popl    %edx
    popl    %ecx
    popl    %ebx
ret
