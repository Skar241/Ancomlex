%{

#include <stdio.h>
#include <stdlib.h>

typedef struct snodo{
        char clase;
        double valor;
        struct snodo *sig;
        }tnodo;
typedef tnodo *tokenList; 

tokenList root = NULL;

void fillList(tokenList *cabeza,char cl, double val);
void printTokens(tokenList root);
char posPalRes(char string[]);

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

{cadenas} {printf("cadena: %s\n",yytext);
		   //fillList(&root,1,1);
		  }
{comenta} {printf("comentarios: %s\n",yytext);}
{identif} {printf("Identificadores: %s\n",yytext);}
{simEsp} {printf("Simbolos especiales: %s\n",yytext);}
{palRes} {printf("Palabras reservadas: %s\n",yytext);
		  //fillList(&root,0,posPalRes(yytext));
		 }
. ;

%%

// Lista de tokens

//Recibe un apuntador, clase, valor; Produce lista de tokens
void fillList(tokenList *cabeza,char cl, double val){
     tokenList nuevo;
     nuevo=malloc(sizeof(tnodo));
     nuevo->clase=cl;
     nuevo->valor=val;
     nuevo->sig=*cabeza;
     *cabeza=nuevo;
     }

//Recibe lista de token, no produce nada, solo imprime
void printTokens(tokenList root){
	if(root==NULL)
		return;
	else{
		printTokens(root->sig);
		//printf("(%d,%d)\n",root->clase,root->valor);
	}
}

char posPalRes(char string[]){
	char palRes[][12]={"_corto","_desde","_entero","_finmientras",
					  "_finsi","_hasta","_haz","_incremento","_largo",
					  "_mientras","_real","_si","_simbolo","_sino"};
	char i=0;
	for(i=0;i<14;i++){
		if(!strcmp(string,palRes[i]))
			return i;
	}
}

main(int argc, char *argv[]){
	if((yyin = fopen(argv[1],"r"))== NULL)
		printf("No se puede abrir el archivo \n"); 
	else{
		yylex();
		printTokens(root);
		int a = 'c';
		double b = 'c';
		double c = 2.9e2;

		printf("-- %d %d --\n",a,(int)b);
		printf("-- %e %d --\n",c,(int)c);
		printf("-- %e %e --\n",atof("2.4E4"),atof("2E-4"));
		
	}
}