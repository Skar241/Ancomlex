%{

#include <stdio.h>
#include <stdlib.h>

%}

cadenas \".+\"
comenta ¡.+!
identif [a-zA-Z]{1,16}

%option noyywrap

%%

{cadenas} {printf("cadena: %s\n",yytext);}
{comenta} {printf("comentarios: %s\n",yytext);}
{identif} {printf("Identificadores: %s\n",yytext);}
. ;

%%

main(int argc, char *argv[]){
	if((yyin = fopen(argv[1],"r"))== NULL)
		printf("No se puede abrir el archivo \n"); 
	else{
		yylex();
		
	}
}