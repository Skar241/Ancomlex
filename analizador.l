%{

/**********************************************************************
*		Analizador lexico  sintactico de un lenguaje definido en clase
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

typedef struct STRING{
	char atom;
	int linea;
	struct STRING *sig;
	}STR;
typedef STR *atm;

atm atomos = NULL;

int lin=1;  //contador de lineas
int linErr;/// variable que se encarga de decir en que linea esta el error
char c;// variable de atomo actual
int onError = 0;//Bandera de errores
FILE *ast;

/*************************** Encabezado de Funciones ************************/
void fillList(tokenList *cabeza,char cl, double val);
int addSimbol(tablaS *root,char sim[], int pos, char tipo[]);
int addString(tablaC *root,char string[], int pos);
void addAtomo(atm *root,char atomo,int lin);
void printTokens(tokenList root,FILE *tks);
char posPalRes(char string[],char *sim);
void printSimbolos(tablaS root,FILE *tsm);
void printStrings(tablaC root,FILE *tsr);
char posOpRel(char *string,char *sim);
void printAtomos(atm atomos, FILE *ast);
char comparacionAtm(char atomo,char *atomos);
void Error(char *msj);
/**************************** Funciones del paser ****************************/
void Parser();
void S();
void D();
void DP();
void TPP();
void N();
void B();
void J();
void L();
void P();
void Z();
void PP();
void M();
void H();
void I();
char R();
void G();
void FP();
void A();
void O();
void E();
void EP();
void T();
void TP();
void F();
%}

/************ Expresiones regulares que definen el lenguaje ***************/
cadenas \"[^\n"]+\"
comenta ¡[^\n!]+!
identif [a-zA-Z]{1,16}
simEsp [\[\],\.\(\)]
tipo entero|real|simbolo|largo|corto
control si|sino|finsi|mientras|finmientras|haz|desde|hasta|incremento|findesde
palRes _({tipo}|{control})
decimal [0-9]+
realSe ([0-9]+\.|\.[0-9])[0-9]*
realCe ({decimal}|{realSe})E(-|\+)?{decimal}
real ({realSe}|{realCe})
salto \n
opAsig :=
opRel (>(=|<)?|<=?|=)
opAri [+\-*/]
error [^ 	]
%option noyywrap

%%

{cadenas} {fillList(&root,6,addString(&tablaStr,yytext,0));
		   addAtomo(&atomos,'y',lin);
		  }

{comenta} {;}

{identif} {fillList(&root,1,addSimbol(&tablaSim,yytext,0,"  "));
		   addAtomo(&atomos,'a',lin);
		   }

{simEsp} {fillList(&root,5,yytext[0]);
		  addAtomo(&atomos,yytext[0],lin);
}

{palRes} {char sim;
		  fillList(&root,0,posPalRes(yytext,&sim));
		  addAtomo(&atomos,sim,lin);
		 }

{decimal} {fillList(&root,7,atoi(yytext));
		   addAtomo(&atomos,'x',lin);
}

{real} {fillList(&root,8,atof(yytext));
		addAtomo(&atomos,'z',lin);
}

{opAsig} {fillList(&root,2,0);
		  addAtomo(&atomos,'=',lin);
}

{opAri} {fillList(&root,4,yytext[0]);
		 addAtomo(&atomos,yytext[0],lin);
}

{opRel} {char sim;
		 fillList(&root,3,posOpRel(yytext,&sim));
		 addAtomo(&atomos,sim,lin);
		}

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

//Funcion que se encarga de avanzar en el string, recibe lista de caracteres
//Produce el caracter primero en la fila
char avanzaString(atm *root){
	if((*root)->atom == '@'){
		linErr = (*root)->linea;
		fprintf(ast,"@\n");
		return '@';
	}
	else{
		char tmp = (*root)->atom;
		linErr = (*root)->linea;
		*root = (*root)->sig;
		atm tmoA = *root;
		printAtomos(tmoA,ast);
		return tmp;
	}
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

//Recibe apuntador a cadena de atomos, atomos, linea
//Produce lista de atomos
void addAtomo(atm *root,char atomo,int lin){
	if(*root==NULL){
		atm nuevo;
		nuevo = malloc(sizeof(STR));
		nuevo->atom = atomo;
		nuevo->linea = lin;
		*root = nuevo;
		return;
	}
	else
		addAtomo(&((*root)->sig),atomo,lin);
}

//Recibe operador relacional, retorna su posicion en la tabla
char posOpRel(char *string,char *sim){
	switch (string[0]){
		case '>':
			switch (string[1]){
				case '=':
					*sim = 'q';
					return 2;
				case '<':
					*sim = 'w';
					return 5;
				default:
					*sim = 'j';
					return 0;
			}
		case '<':
			switch (string[1]){
				case '=':
					*sim = 'u';
					return 3;
				default:
					*sim = 'k';
					return 1;
			}
		default:
			*sim = 'v';
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
				//printf("(%d,%f)\n",root->clase,root->valor);
				break;
			default:
				fprintf(tks,"   %d     %d  \n",root->clase,(int)root->valor);
				//printf("(%d,%d)\n",root->clase,(int)root->valor);
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
char posPalRes(char string[],char *sim){
	char palRes[][13]={"_corto","_desde","_entero","_finmientras",
					  "_finsi","_hasta","_haz","_incremento","_largo",
					  "_mientras","_real","_si","_simbolo","_sino"};
	char atomo[] = "cdefbthplmrisn";

	char flg;
	char i;
	
	if(!strcmp(string,"_findesde")){
		*sim = 'g';
		return 14;
	}

	if(string[1]<105)
		flg =0;
	else
		flg = 7;

	for(i=flg;i<14;i++){
		if(!strcmp(string,palRes[i])){
			*sim = atomo[i];
			return i;
		}
	}
}

//Recibe lista de atomos, y archivo
//Produce cadena de atomos en un archivo .ast
void printAtomos(atm atomos,FILE *ast){
	if(atomos->atom == '@'){
		fprintf(ast,"@\n");
		return;
	}
	else{
		fprintf(ast,"%c",atomos->atom);
		printAtomos(atomos->sig,ast);
		return;
	}
}

//Recibe caracter y una cadena
//Produce 0 si no esta el caracter en esa cadena y 1 si lo encuentra
char comparacionAtm(char atomo,char *atomos){
	char i=0;
	while(atomos[i]!='\0'){
		if(atomo == atomos[i])
			return 1;
		i++;
	}
	return 0;
}

//REcibe mensaje y escribe en la linea donde se detecto el error, aumenta la bandera de errores
void Error(char *msj){
	printf("%s en linea %d\n",msj,linErr);
	onError++;
}

/////////////////////////////////////////////////////// Funciones de Produciones /////////////////////////////////
// Funcion Parser, se encarga de mandar a llamar el no terminal inicial de la gramatica
void Parser(){
	c = avanzaString(&atomos);
	S();
	if(c == '@')
		printf("Compilacion Terminada\n");
	else
		printf("Compilacion Terminada con Error\n");
	if(onError)
		printf("Se detectaron %d errores en total\n",onError);
	else
		printf("No se detectaron errores\n");
}

//diferentes producciones de la gramatica, en algunas se omite evaluar el c.s. pues de lo contrario
//el compilador se detendria al primer error y no se autorecuperaria
void S(){
	D();
	DP();
	P();
	return;
}

void D(){
	TPP();
	if(c == 'a')
		c = avanzaString(&atomos);
	else
		Error("No se ha detectado identificador");
	B();
	L();
	return;
}

void DP(){
	if(comparacionAtm(c,"srlce")){
		D();
		DP();
	}
	else if(comparacionAtm(c,".mhida")){}
	else{
		Error("No se puede continuar con la Compilacion");
	}
	return;
}

void TPP(){
	if(comparacionAtm(c,"cle")){
		N();
		if(c == 'e')
			c = avanzaString(&atomos);
		else
			Error("No se ha encontrado tipo de dato");
	}
	else if(comparacionAtm(c,"sr"))
		c = avanzaString(&atomos);
	else
		Error("No se ha encontrado tipo de dato");
	return;
}

void N(){
	if(comparacionAtm(c,"cl"))
		c = avanzaString(&atomos);
	else if(c == 'e'){}
	else
		Error("No se ha encontrado tipo de dato");
	return;
}


void B(){
	if(c == '='){
		c = avanzaString(&atomos);
		J();
	}
	else if(comparacionAtm(c,",.")){}
	else{
		Error("No se ha encontrado = ");
		J();
	}
	return;
}

void J(){
	if(comparacionAtm(c,"xyz"))
		c = avanzaString(&atomos);
	else
		Error("No se ha encontrado constante");
	return;
}

void L(){
	if(c == ','){
		c = avanzaString(&atomos);
		if(c == 'a')
			c = avanzaString(&atomos);
		else
			Error("No se ha encontrado identificador");
		B();
		L();
	}
	else if(c == '.')
		c =avanzaString(&atomos);
	else if(c == 'a'){
		c = avanzaString(&atomos);
		Error("No se ha encontrado ,");
		B();
		L();
	}
	else
		Error("No se ha encontrado .");
	return;
}

void P(){
	if(comparacionAtm(c,".mhida")){
		Z();
		PP();
	}
	else
		Error("No se ha encontrado palabra reservada o .");
	return;
}

void Z(){
	switch(c){
		case '.':
			c = avanzaString(&atomos);
			break;
		case 'm':
			M();
			break;
		case 'h':
			H();
			break;
		case 'i':
			I();
			break;
		case 'd':
			FP();
			break;
		case 'a':
			A();
			break;
		default :
			Error("No se ha encontrado palabra reservada o .");
	}
	return;
}

void PP(){
	if(comparacionAtm(c,".mhida")){
		Z();
		PP();
	}
	else if(comparacionAtm(c,"@ftnbg")){}
	else
		Error("No se ha encontrado palabra reservada o .");
	return;
}

void M(){
	if(c == 'm'){
		c = avanzaString(&atomos);
		if(c == '(')
			c = avanzaString(&atomos);
		else
			Error("No se ha encontrado )");
		
		if(R())
			Error("No se ha ingresado correctamente alguna relacion");
		
		if(c == ')')
			c = avanzaString(&atomos);
		else
			Error("No se ha encontrado )");
		
		P();
		if(c == 'f')
			c = avanzaString(&atomos);
		else
			Error("No se ha encontrado _finmientras");
	}
	else
		Error("No se ha encontrado _mientras");
	return;
}

void H(){
	if(c == 'h'){
		c = avanzaString(&atomos);
		P();
		if(c == 't')
			c = avanzaString(&atomos);
		else
			Error("No se ha encontrado _hasta");
		if(c == '(')
			c = avanzaString(&atomos);
		else
			Error("Falta (");
		R(0);
		if(c == ')')
			c = avanzaString(&atomos);
		else
			Error("Falta )");
		if(c == '.')
			c = avanzaString(&atomos);
		else
			Error("falta .");
	}
	else
		Error("No se ha encontrado _haz");
	return;
}

void I(){
	if(c == 'i'){
		c = avanzaString(&atomos);
		if(c == '(')
			c = avanzaString(&atomos);
		else
			Error("Falta (");
		
		if(R())
			Error("No se ha ingresado correctamente alguna relacion");

		if(c == ')')
			c = avanzaString(&atomos);
		else 
			Error("Falta )");
		P();
		G();
	}
	return;
}

void G(){
	if(c == 'n'){
		c = avanzaString(&atomos);
		P();
		if(c == 'b')
			c = avanzaString(&atomos);
		else
			Error("Falta _finsi");
	}
	else if(c == 'b')
		c = avanzaString(&atomos);
	else
		Error("No se ha encontrado _sino");
	return;
}

void FP(){
	if(c == 'd'){
		c = avanzaString(&atomos);
		A();
		if(c == 't')
			c = avanzaString(&atomos);
		else
			Error("No a detectado _hasta");
		if(c == '(')
			c = avanzaString(&atomos);
		else
			Error("No a detectado (");
		E();
		if(c == ')')
			c = avanzaString(&atomos);
		else
			Error("No a detectado )");
		if(c == 'p')
			c = avanzaString(&atomos);
		else
			Error("No a detectado _incremento");
		if(c == '(')
			c = avanzaString(&atomos);
		else
			Error("No a detectado (");
		E();
		if(c == ')')
			c = avanzaString(&atomos);
		else
			Error("No a detectado )");
		P();
		if(c == 'g')
			c = avanzaString(&atomos);
		else
			Error("No a detectado _findesde");
	}
	else
		Error("No se a detectado _desde");
	return;
}

void A(){
	if(c == 'a'){
		c = avanzaString(&atomos);
		if(c == '=')
			c = avanzaString(&atomos);
		else
			Error("No se ha detectado :=");
		E();
		if(c == '.')
			c = avanzaString(&atomos);
		else
			Error("No a detectado .");
	}
	return;
}

char R(){
	if(comparacionAtm(c,"(axzy")){
		E();
		O();
		E();
		return 0;
	}
	return 1;
}

void O(){
	if(comparacionAtm(c,"jkquvw"))
		c = avanzaString(&atomos);
	else
		Error("No se ha encontrado Op. Rel.");
	return;
}

void E(){
	if(comparacionAtm(c,"(axzy")){
		T();
		EP();
	}
	return;
}


void EP(){
	if(comparacionAtm(c,"+-")){
		c = avanzaString(&atomos);
		T();
		EP();
	}
	else if(comparacionAtm(c,").jkquvw")){}
	else{
		T();
		EP();
	}
	return;
}

void T(){
	if(comparacionAtm(c,"(axzy")){
		F();
		TP();
	}
	return;
}

void TP(){
	if(comparacionAtm(c,"*/")){
		c = avanzaString(&atomos);
		F();
		TP();
	}
	else if(comparacionAtm(c,"+-).jkquvw")){}
	else{
		F();
		TP();
	}
	return;
}

void F(){
	if(c == '('){
		c = avanzaString(&atomos);
		E();
		if(c == ')')
			c = avanzaString(&atomos);
		else
			Error("Falta )");
	}
	else if(c == 'a')
		c = avanzaString(&atomos);
	else if(comparacionAtm(c,"xyz"))
		J();
	else
		Error("No se encontro operando");
	return;

}

/////////////////////////////////////////////////////// Fin de Produciones


//Recibe archivo a compilar, no produce nada
main(int argc, char *argv[]){
	if((yyin = fopen(argv[1],"r"))== NULL)
		printf("No se puede abrir el archivo \n"); 
	else{
		yylex();

		char arch1[strlen(argv[1])+5];
		char arch2[strlen(argv[1])+5];
		char arch3[strlen(argv[1])+5];
		char arch4[strlen(argv[1])+5];

		strcpy(arch1,argv[1]);
		strcpy(arch2,argv[1]);
		strcpy(arch3,argv[1]);
		strcpy(arch4,argv[1]);

		strcat(arch1,".tks");
		strcat(arch2,".tsm");
		strcat(arch3,".tsr");
		strcat(arch4,".ast");

		FILE *tks = fopen(arch1,"w");
		FILE *tsm = fopen(arch2,"w");
		FILE *tsr = fopen(arch3,"w");
		ast = fopen(arch4,"w");

		//inicio de archivos
		fprintf(tks," clase valor\n");
		fprintf(tsm," posicion    simbolo     tipo\n");
		fprintf(tsr," posicion    cadena\n");
		fprintf(ast," Cadena de atomos \n");

		/*printf("\n <<< -------- Lista de tokens -------- >>>\n");
		printf("(clase,valor)\n");*/
		printTokens(root,tks);
		printSimbolos(tablaSim,tsm);
		printStrings(tablaStr,tsr);

		addAtomo(&atomos,'@',lin);
		printAtomos(atomos,ast);
		Parser();


		fclose(tks);
		fclose(tsm);
		fclose(tsr);
		fclose(ast);		
	}
}