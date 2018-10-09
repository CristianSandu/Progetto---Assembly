# per convertire i caratteri in numero si utilizza la formula ricorsiva
#
# 10*(10*(10*d    + d   ) + d   ) + d
#             N-1    N-2     N-3     N-4
#
.section .data
	error:		.ascii	"Attenzione, valori non decimali rilevati\n"
	error_len:	.long 	. - error
	car:		.byte 0   	# la variabile car e' dichiarata di tipo byte

.section .text
.global atoi

.type atoi, @function		# dichiarazione della funzione atoi
			# la funzione converte una stringa di caratteri
			# il cui indirizzo si trova in eax e delimitata dal carattere di invio (newline),
			# in un numero che viene restituito nel registro EAX
			# Inoltre controlla che vengano inseriti solo caratteri
			# corrispondenti a caratteri decimali
atoi:
	pushl 	%ebx			# salvo il valore corrente di ebx sullo stack
	pushl 	%ecx      		# salvo il valore corrente di ecx sullo stack
	pushl 	%edx      		# salvo il valore corrente di edx sullo stack

	movl 	%eax, %ecx
	xorl 	%eax, %eax
	xorl 	%edx, %edx
inizio:
	movl	$0, car
	xorl 	%ebx, %ebx
	mov 	(%ecx,%edx), %bl
	cmp 	$10, %bl 		# vedo se si è arrivati al carattere 10 di a capo
	je    	fine
	movb 	%bl, car

	cmp 	$48, car
	jl 		err
	cmp 	$57, car
	jg 		err

	subb  	$48, car  		# converte il codice ASCII della cifra nel numero corrisp.

	movl  	$10, %ebx
	pushl 	%edx			# salvo nello stack il valore di edx perchè verrà modificato dalla mull
	mull  	%ebx      		# eax = eax * 10
	popl 	%edx
	# sto trascurando i 32 bit piu' significativi del risultato
	# della moltiplicazione che sono in edx
	# quindi il numero introdotto deve essere minore di 2^32

	xorl  	%ebx, %ebx
	movb  	car, %bl   		# copio car che va ad occupare il byte meno
			 				# significativo di ebx
	addl  	%ebx, %eax   	# eax = eax + ebx
	# NOTA: non si puo' fare direttamente eax=eax+car perche'
	# eax e' a 32 bit mentre car e' a 8 bit
	incl  	%edx
	jmp   	inizio

err:
	movl  	$4, %eax  		# solito blocco di istruzioni per la stampa
	movl  	descrittore_write, %ebx	# stampa il messaggio di errore direttamente nel file di output
	leal  	error, %ecx
	movl  	error_len, %edx
	int   	$0x80

	movl	$-1, %eax		# in caso di errore ritorno il valore -1

fine:
	# ripristino dei registri salvati sullo stack
	# l'ordine delle pop deve essere inverso delle push
	popl 	%edx			# ripristino il valore di edx all'inizio della chiamata
	popl 	%ecx       		# ripristino il valore di ecx all'inizio della chiamata
	popl 	%ebx       		# ripristino il valore di ebx all'inizio della chiamata

	ret             		# fine della funzione atoi
			# l'esecuzione riprende dall'istruzione sucessiva
			# alla call che ha invocato atoi
