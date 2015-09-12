%{

#include <stdio.h>
#include <stdlib.h>

%}

cadenas \".+\"
comenta ¡.+!
identif [a-zA-Z]{1,16}
simEsp [\[\],\.\(\)]
tipo entero|real|simbolo|largo|corto
palRes _{tipo}
decimal (-|\+)?[0-9]+
realSe ([0-9]+\.|\.[0-9])[0-9]*
realCe ({decimal}|{realSe})E{decimal}
%option noyywrap

%%

{cadenas} {printf("cadena: %s\n",yytext);}
{comenta} {printf("comentarios: %s\n",yytext);}
{identif} {printf("Identificadores: %s\n",yytext);}
{simEsp} {printf("Simbolos especiales: %s\n",yytext);}
{palRes} {printf("Palabras reservadas: %s\n",yytext);}
. ;

%%

main(int argc, char *argv[]){
	if((yyin = fopen(argv[1],"r"))== NULL)
		printf("No se puede abrir el archivo \n"); 
	else{
		yylex();
		
	}
}