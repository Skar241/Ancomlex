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
        char simbolo[17];
        int pos;
        char tipo[13];
        struct Stable *sig;
        }SBtable;
typedef SBtable *tablaS; 

tablaS tablaSim = NULL;

typedef struct Ctable{
        char *string;
        int pos;
        struct Ctable *sig;
        }STtable;
typedef STtable *tablaC; 

tablaC tablaStr = NULL;

int lin=1;

void fillList(tokenList *cabeza,char cl, double val);
int addSimbol(tablaS *root,char sim[], int pos, char tipo[]);
int addString(tablaC *root,char string[], int pos);
void printTokens(tokenList root,FILE *tks);
char posPalRes(char string[]);
void printSimbolos(tablaS root,FILE *tsm);
void printStrings(tablaC root,FILE *tsr);
int posOpRel(char *string);

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
opAsig :=
opRel (>(=|<)?|<=?|=)
opAri [+\-*/]
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
{opAsig} {fillList(&root,2,0);}
{opAri} {fillList(&root,4,yytext[0]);}
{opRel} {fillList(&root,3,posOpRel(yytext));}
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

int posOpRel(char *string){
	switch (string[0]){
		case '>':
			switch (string[1]){
				case '=':
					return 2;
				case '<':
					return 5;
				default:
					return 0;
			}
		case '<':
			switch (string[1]){
				case '=':
					return 3;
				default:
					return 1;
			}
		default:
			return 4;
	}
}

int addString(tablaC *root,char string[], int pos){
	if(*root==NULL){
		tablaC nuevo;
		nuevo = malloc(sizeof(STtable));
		nuevo->string=malloc(strlen(string)+1);
		strcpy(nuevo->string,string);
		nuevo->pos=pos;
		nuevo->sig=NULL;
		*root=nuevo;
		return pos;
	}
	else return addString(&((*root)->sig),string,pos+1);
}

//Recibe lista de token, no produce nada, solo imprime
void printTokens(tokenList root,FILE *tks){
	if(root==NULL)
		return;
	else{
		printTokens(root->sig,tks);
		switch (root->clase){
			case 8:
				fprintf(tks,"   %d     %f  \n",root->clase,root->valor);
				printf("(%d,%f)\n",root->clase,root->valor);
				break;
			default:
				fprintf(tks,"   %d     %d  \n",root->clase,(int)root->valor);
				printf("(%d,%d)\n",root->clase,(int)root->valor);
		}
		
	}
}

void printSimbolos(tablaS root,FILE *tsm){
	if(root==NULL)
		return;
	else{
		fprintf(tsm,"  %d       %s         \n",root->pos,root->simbolo);
		printSimbolos(root->sig,tsm);
	}
}
void printStrings(tablaC root,FILE *tsr){
	if(root==NULL)
		return;
	else{
		fprintf(tsr,"    %d      %s        \n",root->pos,root->string);
		printStrings(root->sig,tsr);
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

		char arch1[strlen(argv[1])+5];
		char arch2[strlen(argv[1])+5];
		char arch3[strlen(argv[1])+5];

		strcpy(arch1,argv[1]);
		strcpy(arch2,argv[1]);
		strcpy(arch3,argv[1]);

		strcat(arch1,".tks");
		strcat(arch2,".tsm");
		strcat(arch3,".tsr");

		FILE *tks = fopen(arch1,"w");
		FILE *tsm = fopen(arch2,"w");
		FILE *tsr = fopen(arch3,"w");

		fprintf(tks," clase valor\n");
		fprintf(tsm," posicion    simbolo     tipo\n");
		fprintf(tsr," posicion    cadena\n");

		printf("\n <<< -------- Lista de tokens -------- >>>\n");
		printf("(clase,valor)\n");
		printTokens(root,tks);
		printSimbolos(tablaSim,tsm);
		printStrings(tablaStr,tsr);

		fclose(tks);
		fclose(tsm);
		fclose(tsr);		
	}
}