# Compilador

Compilador de un lenguaje definido en clase, genera otro codigo traducido
a lenguaje C.

Elaborado por:
	Díaz Ramírez Oscar Antonio
	Partida Bañuelos Valentin

	inicio: 10/09/2015 20:00    fin: 1/12/2015 03:19
		
	Escrito en Sublime Text 3
		
	Compilacion:
		flex analizador.l
		gcc lex.yy.c -o analizador -lfl
		./analizador archivo
			