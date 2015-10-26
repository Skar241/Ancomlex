int atomos;
char avanzaString(int *ar){
	return 'a';
}

char c = 'e';

char comparacionAtm(char atomo,char *atomos){
	char i=0;
	while(atomos[i]!='\0'){
		if(atomo == atomos[i])
			return 1;
		i++;
	}
	return 0;
}

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
void R();
void G();
void FP();
void A();
void O();
void E();
void EP();
void T();
void TP();
void F();

void Error(char *msj){
	printf("%s\n",msj);
}

main(){}

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
		D();
		DP();
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
		Error("No se ha encontrado contante");
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
	else if(comparacionAtm(c,"┤ftnbg")){}
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
			Error("No se ha encontrado (");
		R(0);
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
		R(0);
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
			Error("No se ha detectado =");
		E();
		if(c == '.')
			c = avanzaString(&atomos);
		else
			Error("No a detectado .");
	}
}

void R(){
	E();
	O();
	E();
	return;
}

void O(){
	if(comparacionAtm(c,"jkquvw"))
		c = avanzaString(&atomos);
	else
		Error("No se ha encontrado Op. Rel.");
	return;
}

void E(){
	T();
	EP();
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
	F();
	TP();
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
		Error("No se encontraron operandos");
	return;

}

