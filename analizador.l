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

typedef struct Stable{
        char simbolo[13];
        int pos;
        char tipo[13];
        struct Stable *sig;
        }SBtable;
typedef SBtable *tablaS; 

tablaS tablaSim = NULL;

typedef struct Ctable{
        char string[17];
        int pos;
        struct Ctable *sig;
        }STtable;
typedef STtable *tablaC; 

tablaC tablaStr = NULL;

int lin=1;

void fillList(tokenList *cabeza,char cl, double val);
int addSimbol(tablaS *root,char sim[], int pos, char tipo[]);
int addString(tablaC *root,char string[], int pos);
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
real ({realSe}|{realCe})
salto \n
error [^ ]
%option noyywrap

%%

{cadenas} {fillList(&root,6,addString(&tablaStr,yytext,0));}
{comenta} {;}
{identif} {fillList(&root,1,addSimbol(&tablaSim,yytext,0,"  "));}
{simEsp} {fillList(&root,5,yytext[0]);}
{palRes} {fillList(&root,0,posPalRes(yytext));}
{decimal} {fillList(&root,7,atoi(yytext));}
{real} {fillList(&root,8,atof(yytext));}
{salto} {lin++;}
{error} {printf("Error en linea: %d %s no esta definida\n",lin,yytext);}

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

int addSimbol(tablaS *root,char sim[], int pos, char tipo[]){
	if(*root==NULL){
		tablaS nuevo;
		nuevo = malloc(sizeof(SBtable));
		strcpy(nuevo->simbolo,sim);
		nuevo->pos=pos;
		strcpy(nuevo->tipo,tipo);
		nuevo->sig=NULL;
		*root=nuevo;
		return pos;
	}
	else if(!strcmp((*root)->simbolo,sim)) return pos;
	else return addSimbol(&((*root)->sig),sim,pos+1,tipo);
}

int addString(tablaC *root,char string[], int pos){
	if(*root==NULL){
		tablaC nuevo;
		nuevo = malloc(sizeof(STtable));
		strcpy(nuevo->string,string);
		nuevo->pos=pos;
		nuevo->sig=NULL;
		*root=nuevo;
		return pos;
	}
	else return addString(&((*root)->sig),string,pos+1);
}

//Recibe lista de token, no produce nada, solo imprime
void printTokens(tokenList root){
	if(root==NULL)
		return;
	else{
		printTokens(root->sig);
		switch (root->clase){
			case 8:
				printf("(%d,%f)\n",root->clase,root->valor);
				break;
			default:
				printf("(%d,%d)\n",root->clase,(int)root->valor);
		}
		
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
	}
}