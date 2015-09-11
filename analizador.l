%{

#include <stdio.h>
#include <stdlib.h>

%}

cadenas \".+\"
comenta ¡.+!

%option noyywrap

%%

{cadenas} {printf("cadena: %s\n",yytext);}
{comenta} {printf("comentarios: %s\n",yytext);}
. ;

%%

main(int argc, char *argv[]){
	if((yyin = fopen(argv[1],"r"))== NULL)
		printf("No se puede abrir el archivo \n"); 
	else{
		yylex();
		
	}
}