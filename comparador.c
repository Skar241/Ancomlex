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

void S(){
	if(comparacionAtm(c,"srlce")){
		D();
		DP();
		P();
	}
	else{
		Error();
	}
	return;
}

void D(){
	if(comparacionAtm(c,"srlce")){
		TPP();
		if(c == 'a')
			c = avanzaString(&atomos);
		else
			Error();
		B();
		L();
	}
	else{
		Error();
	}
	return;
}

void DP(){
	if(comparacionAtm(c,"srlce")){
		D();
		DP();
	}
	else if(comparacionAtm(c,".mhida")){}
	else 
		Error();
	return;
}

void TPP(){
	if(comparacionAtm(c,"cle")){
		N();
		if(c == 'e')
			c = avanzaString(&atomos);
		else
			Error();
	}
	else if(comparacionAtm(c,"sr"))
		c = avanzaString(&atomos);
	else
		Error();
	return;
}

void N(){
	if(comparacionAtm(c,"cl"))
		c = avanzaString(&atomos);
	else if(c == 'e'){}
	else
		Error();
	return;
}


void B(){
	if(c == '='){
		c = avanzaString(&atomos);
		J();
	}
	else if(comparacionAtm(c,",.")){}
	else
		Error();
	return;
}

void J(){
	if(comparacionAtm(c,"xyz"))
		c = avanzaString(&atomos);
	else
		Error();
	return;
}

void L(){
	if(c == ','){
		c = avanzaString(&atomos);
		if(c == 'a')
			c = avanzaString(&atomos);
		else
			Error();
		B();
		L();
	}
	else if(c == '.')
		c =avanzaString(&atomos);
	else 
		Error();
	return;
}

void P(){
	if(comparacionAtm(c,".mhida")){
		Z();
		PP();
	}
	else
		Error();
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
			Error();
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
		Error();
	return;
}


