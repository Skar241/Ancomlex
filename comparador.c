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
	if(comparacionAtm(c,"srlce"))
		printf("sí funciona\n");
}