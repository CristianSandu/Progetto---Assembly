EXE= ESEGUIBILE_ELABORATO
AS= as
LD= ld
FLAGS= -gstabs --32
OBJ= main.o open.o read.o write.o decodifica.o codifica.o atoi.o itoa.o mod_detect.o
$(EXE): $(OBJ)
	$(LD) -m elf_i386 -o $(EXE) $(OBJ)
main.o: main.s
	$(AS) $(FLAGS) -o main.o main.s
open.o: open.s
	$(AS) $(FLAGS) -o open.o open.s
read.o: read.s
	$(AS) $(FLAGS) -o read.o read.s
write.o: write.s
	$(AS) $(FLAGS) -o write.o write.s
decodifica.o: decodifica.s
	$(AS) $(FLAGS) -o decodifica.o decodifica.s
codifica.o: codifica.s
	$(AS) $(FLAGS) -o codifica.o codifica.s
atoi.o: atoi.s
	$(AS) $(FLAGS) -o atoi.o atoi.s
itoa.o: itoa.s
	$(AS) $(FLAGS) -o itoa.o itoa.s
mod_detect.o: mod_detect.s
	$(AS) $(FLAGS) -o mod_detect.o mod_detect.s
clean:
	rm -f *.o $(EXE) core
clean_o:							# ELIMINA SOLO I FILE OGGETTO
	rm -f *.o core
