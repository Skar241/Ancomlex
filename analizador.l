%{

/**********************************************************************
*		Analizador lexico de un lenguaje definido en clase
*		Elaborado por: 
*			Diaz Ramirez Oscar Antonio
*
*
*		inicio: 10/09/2015 20:00    fin: 15/09/2015 17:30
*		Escrito en Sublime Text 3
*		Compilacion:
*			flex analizador.l
*			gcc lex.yy.c -o analizador -lfl
*			./analizador archivo
*			
//**********************************************************************/
#include <stdio.h>
#include <stdlib.h>

//Definicion de la lista de tokens
typedef struct snodo{
        char clase;
        double valor;
        struct snodo *sig;
        }tnodo;
typedef tnodo *tokenList; 

tokenList root = NULL;

//Definicion de la tabla de simbolos
typedef struct Stable{
        char simbolo[17];
        int pos;
        char tipo[13];
        struct Stable *sig;
        }SBtable;
typedef SBtable *tablaS; 

tablaS tablaSim = NULL;

//Definicion de la tabla de cadenas
typedef struct Ctable{
        char *string;
        int pos;
        struct Ctable *sig;
        }STtable;
typedef STtable *tablaC; 

tablaC tablaStr = NULL;

int lin=1;  //contador de lineas

/*************************** Encabezado de Funciones ************************/
void fillList(tokenList *cabeza,char cl, double val);
int addSimbol(tablaS *root,char sim[], int pos, char tipo[]);
int addString(tablaC *root,char string[], int pos);
void printTokens(tokenList root,FILE *tks);
char posPalRes(char string[]);
void printSimbolos(tablaS root,FILE *tsm);
void printStrings(tablaC root,FILE *tsr);
char posOpRel(char *string);

%}

/************ Expresiones regulares que definen el lenguaje ***************/
cadenas \"[^\n"]+\"
comenta ¡[^\n!]+!
identif [a-zA-Z]{1,16}
simEsp [\[\],\.\(\)]
tipo entero|real|simbolo|largo|corto
control si|sino|finsi|mientras|finmientras|haz|desde|hasta|incremento
palRes _({tipo}|{control})
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
{error} {printf("\nError en linea: %d %s no esta definida\n",lin,yytext);}

%%


//Recibe un apuntador, clase, valor; Produce lista de tokens
void fillList(tokenList *cabeza,char cl, double val){
     tokenList nuevo;
     nuevo=malloc(sizeof(tnodo));
     nuevo->clase=cl;
     nuevo->valor=val;
     nuevo->sig=*cabeza;
     *cabeza=nuevo;
     }

//Recibe apuntador, simbolo, posicion(estimada), tipo de dato
//Produce tabla de simbolos y retorna posicion en la tabla del elemento
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

//Recibe operador relacional, retorna su posicion en la tabla
char posOpRel(char *string){
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

//Recibe apuntador, cadena y posicion(estimada)
//Produce tabla de cadenas y retorna la posicion en la tabla de cadenas
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

//Recibe lista de token, imprime en pantalla y en .tks(archivo de tokens)
//No produce nada
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

//Recibe tabla de simbolos, imprime en .tsm(archivo de simbolos)
//No produce nada
void printSimbolos(tablaS root,FILE *tsm){
	if(root==NULL)
		return;
	else{
		fprintf(tsm,"  %d       %s         \n",root->pos,root->simbolo);
		printSimbolos(root->sig,tsm);
	}
}

//Recibe tabla de cadenas, imprime en .tsr(archivo de cadenas)
//No produce nada
void printStrings(tablaC root,FILE *tsr){
	if(root==NULL)
		return;
	else{
		fprintf(tsr,"    %d      %s        \n",root->pos,root->string);
		printStrings(root->sig,tsr);
	}
}

//Recibe palabra reservada, produce su posicion en la tabla
char posPalRes(char string[]){
	char palRes[][13]={"_corto","_desde","_entero","_finmientras",
					  "_finsi","_hasta","_haz","_incremento","_largo",
					  "_mientras","_real","_si","_simbolo","_sino"};
	char flg;
	char i;
	
	if(string[1]<105)
		flg =0;
	else
		flg = 7;

	for(i=flg;i<14;i++){
		if(!strcmp(string,palRes[i]))
			return i;
	}
}

//Recibe archivo a compilar, no produce nada
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

		//inicio de archivos
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