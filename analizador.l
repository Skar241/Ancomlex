%{

/**********************************************************************
*		Analizador lexico  sintactico de un lenguaje definido en clase
*		Elaborado por: 
*			Diaz Ramirez Oscar Antonio
*			Partida Bañuelos Valentin
*
*
*		inicio: 10/09/2015 20:00    fin: 1/12/2015 03:19
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
        char tipo;
        char valInicial [16];
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

typedef struct num{
	char tipoN;
	double valorN;
}numero;


atm atomos = NULL;

int lin=1;  //contador de lineas
int linErr;/// variable que se encarga de decir en que linea esta el error
char c;// variable de atomo actual
int onError = 0;//Bandera de errores
FILE *ast;
FILE *tsm;
FILE *compilado; 

/*************************** Encabezado de Funciones ************************/
void fillList(tokenList *cabeza,char cl, double val);
int addSimbol(tablaS *root,char sim[], int pos);
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
char TPP();
char N();
numero B();
numero J();
void L(char l);
void P();
void Z();
void PP();
void M();
void H();
void I();
char R(char hasOmie);
void G();
void FP();
void A();
int O();
char E();
char EP();
char T();
char TP();
char F();
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
realCe ({decimal}|{realSe})(E|e)(-|\+)?{decimal}
real ({realSe}|{realCe})
salto \n
opAsig :=
opRel (>(=|<)?|<=?|=)
opAri [+\-*/]
error [^ 	]
%option noyywrap
/*"*/

%%

{cadenas} {fillList(&root,6,addString(&tablaStr,yytext,0));
		   addAtomo(&atomos,'y',lin);
		  }

{comenta} {;}

{identif} {fillList(&root,1,addSimbol(&tablaSim,yytext,0));
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

///******************* Zona de push y Add ************************///

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

//Recibe apuntador, simbolo, posicion(estimada), tipo de dato
//Produce tabla de simbolos y retorna posicion en la tabla del elemento
int addSimbol(tablaS *root,char sim[], int pos){
	if(*root==NULL){
		tablaS nuevo;
		nuevo = malloc(sizeof(SBtable));
		strcpy(nuevo->simbolo,sim);
		nuevo->pos=pos;
		nuevo->sig=NULL;
		*root=nuevo;
		return pos;
	}
	else if(!strcmp((*root)->simbolo,sim)) return pos;
	else return addSimbol(&((*root)->sig),sim,pos+1);
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

//Recibe un apuntador, clase, valor; Produce lista de tokens
void fillList(tokenList *cabeza,char cl, double val){
	if(*cabeza == NULL){
    	tokenList nuevo;
    	nuevo=malloc(sizeof(tnodo));
    	nuevo->clase=cl;
    	nuevo->valor=val;
    	nuevo->sig=*cabeza;
    	*cabeza=nuevo;
    }
    else
    	fillList(&((*cabeza)->sig),cl,val);
}

///******************* Fin de push y Add *************************///

///*****************  Zona de pop y consulta  ********************///

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

char getIdentificador(tablaS root,int posicion,char identificador[16]){
	if(root == NULL)
		return 0;
	else{
		if(root->pos==posicion){
			strcpy(identificador,root->simbolo);
			return 1;
		}
		else
			return getIdentificador(root->sig,posicion,identificador);
	}
}

char getTipoIdentificador(tablaS root,char identificador[16]){
	if(root == NULL)
		return 0;
	else{
		if(!strcmp(root->simbolo,identificador)){
			return root->tipo;
		}
		else
			return getTipoIdentificador(root->sig,identificador);
	}
}

//Retorna el token en el tope de la pila
//Recibe una bandera 0 si la lista de tokens está vacia, 1 en caso contrario
double popToken(tokenList *root,char *flg){
	if((*root)->clase == 9){
		*flg = 1;
		return 0;
	}
	else{
		*flg = 0;
		double tmp = (*root)->valor;
		*root = (*root)->sig;
		return tmp;
	}
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

///****************   Fin de zona de pop    **********************///

///**************   Zona de print y printf  **********************///

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

//Recibe tabla de simbolos, imprime en .tsm(archivo de simbolos)
//No produce nada
void printSimbolos(tablaS root,FILE *tsm){
	if(root==NULL)
		return;
	else{
		fprintf(tsm,"  %d            %s        %d      %s\n",root->pos,root->simbolo,root->tipo,root->valInicial);
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

//Recibe lista de token, imprime en pantalla y en .tks(archivo de tokens)
//No produce nada
void printTokens(tokenList root,FILE *tks){
	if(root==NULL)
		return;
	else{
		switch (root->clase){
			case 8:
				fprintf(tks,"   %d     %e  \n",root->clase,root->valor);
				//printf("(%d,%f)\n",root->clase,root->valor);
				break;
			default:
				fprintf(tks,"   %d     %d  \n",root->clase,(int)root->valor);
				//printf("(%d,%d)\n",root->clase,(int)root->valor);
		}
		printTokens(root->sig,tks);
	}
}

///***************    Fin de zona de print  **********************///

///***************    Funciones auxiliares  **********************///
//Recibe caracter y una cadena
//Produce 0 si no esta el caracter en esa cadena y 1 si lo encuentra
char comparacionAtm(char atomo,char *atomos){
	char i=0;
	while(atomos[i]!='\0'){
		if(atomo == atomos[i])
			return i+1;
		i++;
	}
	return 0;
}

//REcibe mensaje y escribe en la linea donde se detecto el error, aumenta la bandera de errores
void Error(char *msj){
	printf("%s en linea %d\n",msj,linErr);
	onError++;
}

void asignaValorInicial(tablaS *root,char identificador[],numero num){
	if(*root == NULL)
		printf("\n %s no esta definido",identificador);
	else{
		if(!strcmp((*root)->simbolo,identificador) && strlen((*root)->valInicial)==0){
			(*root)->tipo = num.tipoN;
			if(num.tipoN == 2){//entero
				sprintf((*root)->valInicial,"%d",(int)num.valorN);
				fprintf(compilado," %d",(int)num.valorN);
			}
			else{
				sprintf((*root)->valInicial,"%e",num.valorN);
				fprintf(compilado," %e",num.valorN);
			}
		}
		else if(!strcmp((*root)->simbolo,identificador) && strlen((*root)->valInicial)>0){
			onError++;
			printf("\nError, %s ha sido previamente inicializada",identificador);
		}
		else
			asignaValorInicial(&((*root)->sig),identificador,num);
	}
}

///***************   fin funciones auxiliares  **********************///

///*******************   Simbolos de accion   ***********************///

void ATV(char tipo, char identificador[], numero *num){
	switch(tipo){
		case 2: case 4: case 5:
			if(num->tipoN != 2 && num->tipoN != 4 && num->tipoN != 5){
				num->tipoN = 2;
				printf("\nCuidado se asigna un real a '%s' se castea a int por defecto",identificador);
			}
		
		case 10:
			asignaValorInicial(&tablaSim,identificador,*num);
			break;
		default:
			onError++;
			printf("\n Error tipos de datos incompatibles en %s",identificador);
	}
}

void escribe(char text[]){
	fprintf(compilado," %s",text);
}

numero determina(char tipo,double valor){
	numero nuevo;
	nuevo.valorN = valor;
	nuevo.tipoN = tipo;
	return nuevo;
}

char determinaTipo(char h1,char h2){
	if(h1==10 || h2==10)
		return 10;
	else
		return 2;
}

char escribeIdentYDetTipo(){
	char a[16];
	char flg;
	if(getIdentificador(tablaSim,(int)popToken(&root,&flg),a))
		fprintf(compilado," %s",a);
	return getTipoIdentificador(tablaSim,a);
}

void comparaAsignacion(char h1,char h2){
	switch(h1){
		case 2: case 4: case 5:
			if(h2 == 10)
				printf("\nCuidado, se hace asignacion de real a entero\n");
	}
}

void comparaOperacion(char h1,char h2,int h3){
	char opRel [6][3] = {">",">=","<","<=","=","><"};
	if(!h1 || !h2)
		printf("\n Posible conflicto de operadores en la relacion %s",opRel[h3]);
}
//0 hasta, 1 mientras
void printOperadorRel(int pos,char hasOmie){
	switch(pos){
		case 0:
			if(hasOmie)
				escribe(" >");
			else
				escribe(" <=");
			break;
		case 1:
			if(hasOmie)
				escribe(" >=");
			else
				escribe(" <=");
			break;
		case 2:
			if(hasOmie)
				escribe(" <");
			else
				escribe(" >=");
			break;
		case 3:
			if(hasOmie)
				escribe(" <=");
			else
				escribe(" >=");
			break;
		case 4:
			escribe(" ==");
			break;
		case 5:
			escribe(" !=");
			break;
		default:
			printf("Operador no corecto");
			onError++;
	}
}
void writeTSM(){
	fprintf(tsm," posicion    simbolo     tipo   valor Inicial\n");
	printSimbolos(tablaSim,tsm);
}

///******************  Fin simbolos de accion   *********************///

/////////////////////////////////////////////////////// Funciones de Produciones /////////////////////////////////
// Funcion Parser, se encarga de mandar a llamar el no terminal inicial de la gramatica
void Parser(){
	c = avanzaString(&atomos);
	S();
	if(c == '@')
		printf("\nCompilacion Terminada\n");
	else
		printf("\nCompilacion Terminada con Error\n");
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
	writeTSM();
	P();
	return;
}

void D(){
	char t,a [16],flg;
	int pos;
	numero b;
	t = TPP();
	if(c == 'a'){
		c = avanzaString(&atomos);
		pos = (int)popToken(&root,&flg);
			if(flg==1){
				printf("\n Error lista de tokens vacia");
			}
			else{
				getIdentificador(tablaSim,pos,a);
			}

	}
	else{
		Error("No se ha detectado identificador");
		strcpy(a," ");
	}
	escribe(a);
	b = B();
	ATV(t,a,&b);
	L(t);
	return;
}

void DP(){
	if(comparacionAtm(c,"srlce")){
		D();
		DP();
	}
	else if(comparacionAtm(c,".mhida")){escribe("\n");}
	else{
		Error("No se puede continuar con la Compilacion");
	}
	return;
}

char TPP(){
	char n=0,e,s,r;
	char flg;
	if(comparacionAtm(c,"cle")){
		n = N();
		if(c == 'e'){
			c = avanzaString(&atomos);
			e = (char) popToken(&root,&flg);
			escribe("int");
		}
		else{
			//Error("No se ha encontrado tipo de dato");
			e = 0;
		}
	}
	else if(flg = comparacionAtm(c,"sr")){
		c = avanzaString(&atomos);
		if(flg == 1 ){
			s = (char) popToken(&root,&flg);
			escribe("char");
			return s;
		}
		else{
			r = (char) popToken(&root,&flg);
			escribe("double");
			return r;
		}
	}
	else
		Error("No se ha encontrado tipo de dato");
	return n+e;
}

char N(){
	char val=0,flg;
	if(flg = comparacionAtm(c,"cl")){
		c = avanzaString(&atomos);
		if(flg == 1){
			escribe("short");
			val = 2;
		}
		else{
			escribe("long");
			val = 3;
		}

		popToken(&root,&flg);
	}
	else if(c == 'e'){}
	else
		Error("No se ha encontrado tipo de dato");
	return val;
}


numero B(){
	char flg;
	numero tmp;
	tmp.tipoN = 2;
	tmp.valorN = 0;
	if(c == '='){
		c = avanzaString(&atomos);
		escribe("=");
		popToken(&root,&flg);
		tmp = J();
	}
	else if(comparacionAtm(c,",.")){}
	else{
		Error("No se ha encontrado = ");
		tmp = J();
	}
	return tmp;
}

numero J(){
	char flg;
	numero tmp;
	tmp.tipoN=2;
	tmp.valorN=0;
	if(flg = comparacionAtm(c,"xz")){
		c = avanzaString(&atomos);
		if(flg == 1)
			tmp = determina(2,popToken(&root,&flg));
		else
			tmp = determina(10,popToken(&root,&flg));
	}
	else
		Error("No se ha encontrado constante");
	return tmp;
}

void L(char l){
	char flg,a[16];
	numero tmp;
	if(c == ','){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe(",");
		if(c == 'a'){
			c = avanzaString(&atomos);
			getIdentificador(tablaSim,(int)popToken(&root,&flg),a);
			escribe(a);
		}
		else{
			Error("No se ha encontrado identificador");
			strcpy(a," ");
		}
		tmp = B();
		ATV(l,a,&tmp);
		L(l);
	}
	else if(c == '.'){
		c =avanzaString(&atomos);
		popToken(&root,&flg);
		escribe(";\n");
	}
	else if(c == 'a'){
		c = avanzaString(&atomos);
		getIdentificador(tablaSim,(int)popToken(&root,&flg),a);
		escribe(a);
		Error("No se ha encontrado ,");
		tmp = B();
		ATV(l,a,&tmp);
		L(l);
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
	char flg;
	switch(c){
		case '.':
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" ;\n");
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
	else if(comparacionAtm(c,"@ftnbg")){
		escribe("\n");
	}
	else
		Error("No se ha encontrado palabra reservada o .");
	return;
}

void M(){
	char flg;
	if(c == 'm'){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe(" while");
		if(c == '('){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" (");
		}
		else
			Error("No se ha encontrado (");
		
		if(R(1))
			Error("No se ha ingresado correctamente alguna relacion");
		
		if(c == ')'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" ){\n");
		}
		else
			Error("No se ha encontrado )");
		
		P();
		if(c == 'f'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" }\n");
		}
		else
			Error("No se ha encontrado _finmientras");
	}
	else
		Error("No se ha encontrado _mientras");
	return;
}

void H(){
	char flg;
	if(c == 'h'){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe(" do{\n");
		P();
		if(c == 't'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe("\n}while");
		}
		else
			Error("No se ha encontrado _hasta");
		if(c == '('){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" (");
		}
		else
			Error("Falta (");
		R(0);
		if(c == ')'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" )");
		}
		else
			Error("Falta )");
		if(c == '.'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(";\n");
		}
		else
			Error("falta .");
	}
	else
		Error("No se ha encontrado _haz");
	return;
}

void I(){
	char flg;
	if(c == 'i'){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe("\nif");
		if(c == '('){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe("(");
		}
		else
			Error("Falta (");
		
		if(R(1))
			Error("No se ha ingresado correctamente alguna relacion");

		if(c == ')'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" ){\n");
		}
		else 
			Error("Falta )");
		P();
		G();
	}
	return;
}

void G(){
	char flg;
	if(c == 'n'){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe("\n}\nelse {\n");
		P();
		if(c == 'b'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe("\n}\n");
		}
		else
			Error("Falta _finsi");
	}
	else if(c == 'b'){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe("\n}\n");
	}
	else
		Error("No se ha encontrado _sino");
	return;
}

void FP(){
	char flg;
	if(c == 'd'){
		c = avanzaString(&atomos);
		popToken(&root,&flg);
		escribe("for(");
		A();
		if(c == 't'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
		}
		else
			Error("No a detectado _hasta");
		if(c == '('){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
		}
		else
			Error("No a detectado (");
		if(R(0))
			error("No se ha ingresado bien alguna relacion");
		if(c == ')'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" ;");
		}
		else
			Error("No a detectado )");
		if(c == 'p'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
		}
		else
			Error("No a detectado _incremento");
		if(c == '('){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
		}
		else
			Error("No a detectado (");
		E();
		if(c == ')'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe(" ){\n");
		}
		else
			Error("No a detectado )");
		P();
		if(c == 'g'){
			c = avanzaString(&atomos);
			popToken(&root,&flg);
			escribe("\n}\n");
		}
		else
			Error("No a detectado _findesde");
	}
	else
		Error("No se a detectado _desde");
	return;
}

void A(){
	char flg,t1,t2;
	if(c == 'a'){
		c = avanzaString(&atomos);
		t1 = escribeIdentYDetTipo();
		if(t1 == 0){
			printf("\n No se a encontrado indetificador");
			onError++;
		}
		else{
			if(c == '='){
				c = avanzaString(&atomos);
				popToken(&root,&flg);
				fprintf(compilado," =");
			}
			else
				Error("No se ha detectado :=");
			t2 = E();
			comparaAsignacion(t1,t2);
			if(c == '.'){
				c = avanzaString(&atomos);
				popToken(&root,&flg);
				escribe(" ;");
			}
			else
				Error("No a detectado .");
		}
	}
	return;
}

char R(char hasOmie){
	char e1,e2;
	int o;
	if(comparacionAtm(c,"(axz")){
		e1 = E();
		printOperadorRel(o = O(),hasOmie);		
		e2 = E();
		comparaOperacion(e1,e2,o);
		return 0;
	}
	return 1;
}

int O(){
	char flg;
	if(comparacionAtm(c,"jkquvw")){
		c = avanzaString(&atomos);
		return (int)popToken(&root,&flg);
	}
	else
		Error("No se ha encontrado Op. Rel.");
	return ' ';
}

char E(){
	char t=0,ep=0;
	if(comparacionAtm(c,"(axz")){
		T();
		EP();
	}
	else
		Error("No se encuentran operandos");
	return determinaTipo(t,ep);
}


char EP(){
	char t=0,ep=0,flg;
	if(flg = comparacionAtm(c,"+-")){
		c = avanzaString(&atomos);
		if(flg == 1)
			fprintf(compilado," +");
		else
			fprintf(compilado," -");
		popToken(&root,&flg);
		t = T();
		ep = EP();
	}
	else if(comparacionAtm(c,").jkquvw")){ return 0;}
	else{
		Error("No se encontro operador");
		t = T();
		ep = EP();
	}
	return determinaTipo(t,ep);
}

char T(){
	char f=0,tp=0;
	if(comparacionAtm(c,"(axz")){
		f = F();
		tp = TP();
	}
	else
		Error("No se encuentran operandos");
	return determinaTipo(f,tp);
}

char TP(){
	char f=0,tp=0,flg;
	if(flg = comparacionAtm(c,"*/")){
		c = avanzaString(&atomos);
		if(flg == 1)
			fprintf(compilado," *");
		else
			fprintf(compilado," /");
		popToken(&root,&flg);
		f = F();
		tp = TP();
	}
	else if(comparacionAtm(c,"+-).jkquvw")){return 0;}
	else{
		Error("No se detecta operador");
		f = F();
		tp = TP();
	}
	return determinaTipo(f,tp);
}

char F(){
	char a[16];
	char tipo=0;
	char flg;
	numero tmp;
	if(c == '('){
		fprintf(compilado," (");
		popToken(&root,&flg);
		c = avanzaString(&atomos);
		tipo = E();
		if(c == ')'){
			c = avanzaString(&atomos);
			fprintf(compilado," )");
			popToken(&root,&flg);
		}
		else
			Error("Falta )");
	}
	else if(c == 'a'){
		c = avanzaString(&atomos);
		tipo = escribeIdentYDetTipo();
	}
	else if(flg = comparacionAtm(c,"xz")){
		tmp=J();
		if(flg == 1)
			fprintf(compilado," %d",(int)tmp.valorN);
		else
			fprintf(compilado," %e",tmp.valorN);
		tipo = tmp.tipoN;
	}
	else
		Error("No se encontro operando");
	return tipo;

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
		char arch5[strlen(argv[1])+5];

		strcpy(arch1,argv[1]);
		strcpy(arch2,argv[1]);
		strcpy(arch3,argv[1]);
		strcpy(arch4,argv[1]);
		strcpy(arch5,argv[1]);

		strcat(arch1,".tks");
		strcat(arch2,".tsm");
		strcat(arch3,".tsr");
		strcat(arch4,".ast");
		strcat(arch5,".c");

		FILE *tks = fopen(arch1,"w");
		tsm = fopen(arch2,"w");
		FILE *tsr = fopen(arch3,"w");
		ast = fopen(arch4,"w");
		compilado = fopen(arch5,"w");

		//inicio de archivos
		fprintf(tks," clase valor\n");
		
		fprintf(tsr," posicion    cadena\n");
		fprintf(ast," Cadena de atomos \n");
		fprintf(compilado,"\nmain(){\n");

		/*printf("\n <<< -------- Lista de tokens -------- >>>\n");
		printf("(clase,valor)\n");*/
		printTokens(root,tks);
		printStrings(tablaStr,tsr);


		addAtomo(&atomos,'@',lin);
		printAtomos(atomos,ast);
		Parser();

		fprintf(compilado,"\n}\n");
		fclose(tks);
		fclose(tsm);
		fclose(tsr);
		fclose(ast);		
	}

}