#include <stdio.h>
#include <stdlib.h>

/**********VARIABILI GLOBALI************/
FILE *fd_input, *fd_output;
char buff[9], *s, init_zero[]="0,00,00\n";
int RPM, ALM, NUMB, MOD;

/*********FIRME DELLE FUNZIONI**********/
int DECODE(char *dec);
int MOD_DETECT(int RPM);
void CODIFICA();

/*************** MAIN ******************/
int main (int argc,char **argv){

    int INIT = 0, RESET = 0;
    char tmp;

    //apertura file di lettura
    fd_input = fopen(argv[1], "r");

    if(fd_input == NULL){ //controllo apertura file
        perror("Errore di apertura del file\n");
        return(-1);
    }

    //apertura file di scrittura
    fd_output = fopen(argv[2], "w");

    if(fd_input == NULL){ //controllo apertura file
        perror("Errore di apertura del file\n");
        return(-1);
    }
    //READ = legge la riga e la mette nella stringa buffers
    inizio:
    while (fgets(buff, 9, fd_input)!=NULL) {
        s = buff;
        /* ==============  IDENTIFICO IL VALORE DI INIT   ============== */
        INIT = DECODE(s);

        if(INIT == 0)
            goto write;         //scrive direttamente la stringa init_zero nel file
        else if(INIT == -1)
            continue;           //salta alla riga successiva del file di input

        /* ==============  IDENTIFICO IL VALORE DI RESET  ============== */
        RESET = DECODE(++s);

        if (RESET == 1) {
            NUMB = 0;             //resetto i secondi e l'allarme
            ALM = 0;
        }else if(RESET == -1)
            continue;           //salta alla riga successiva del file di input

        /* ============== IDENTIFICO IL VALORE DEGLI RPM  ============== */
        s+=3; //incremento del puntatore per considerare gli rpm
        RPM = atoi(s);

        if(MOD != MOD_DETECT(RPM)){
            NUMB = 0;             //resetto i secondi e l'allarme
            ALM = 0;
        }
        MOD = MOD_DETECT(RPM);    //aggiorno il valore di MOD

        if(MOD == -1)
            continue;           //salta alla riga successiva del file di input

        if (NUMB >= 15 && MOD == 11)
            ALM = 1; //attiva l'allarme

        // CODIFICA I VALORI E LI SCRIVE NEL FILE DI OUTPUT
        CODIFICA();
        tmp= fgetc(fd_input);//scarto il carattere di invio della stringa
	
	NUMB++; //incrementa i secondi
    }

    // CHIUSURA DEI FILE
    fclose(fd_input);
    fclose(fd_output);

    printf("Eseguito!\n");
    return 0;
    write:
        fprintf(fd_output, "%s", init_zero);
        tmp = fgetc(fd_input);
        goto inizio;
}

/***** METODI DELLE FUNZIONI ******/
int DECODE(char *s){
    int counter = 0;

start:  switch (*s++) {
            case '0':
                return 0;
            case '1':
                return 1;
            case ',':
                if (counter < 1){
                    counter++;
                    goto start;
                }
            default:
                fprintf(fd_output, "%s", "Errore!\n");
                return -1;
        }
}

int MOD_DETECT(int RPM){

    if (RPM < 2000) {
        return 1;
    }else if (RPM >= 2000 && RPM <= 4000) {
        return 10;
    }else if (RPM > 4000 && RPM <= 6500) {
        return 11;
    }else
        return -1;
}

void CODIFICA(){

    /* ============== SCRIVO ALM SUL FILE  ============== */
    if(ALM == 0)
        fputc('0', fd_output);
    else if (ALM == 1)
        fputc('1', fd_output);

    fputc(',', fd_output);//scrivo una virgola

    /* ============== SCRIVO MOD SUL FILE  ============== */
    if (MOD == 1) {
        fputc('0', fd_output); fputc('1', fd_output);
    }else if (MOD == 10){
        fputc('1', fd_output); fputc('0', fd_output);
    }else if (MOD == 11) {
        fputc('1', fd_output); fputc('1', fd_output);
    }

    fputc(',', fd_output);//scrivo una virgola

    /* ============== SCRIVO NUMB SUL FILE  ============== */
    if (NUMB < 10)
        fputc('0', fd_output);
    fprintf(fd_output, "%d", NUMB);

    fputc('\n', fd_output);; //scrivo il carattere di a capo a fine riga
}
