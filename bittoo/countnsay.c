#include <stdio.h>
#include <string.h>

void countnsay(char *arr,int limit){
	if(limit>10){
		return;
	}
	char arr1[300],final[500]="\0";
	char check = arr[0];
	int counter = 1,i = 1;
	while(arr[i]!='\0'){
		if(arr[i]==check){
			counter++;
			i++;
			if(arr[i+1]=='\0'){
				sprintf(arr1,"%d%c",counter,check);
				strcat(final,arr1);
			}
			continue;
		}
		sprintf(arr1,"%d%c",counter,check);
		strcat(final,arr1);
		counter=1;
		check = arr[i];
		i++;
	}
	sprintf(arr1,"%d%c",counter,check);
	strcat(final,arr1);
	printf("%s\n",final);
	limit++;
	countnsay(final,limit);
}

void main(int argc,char* argv){
	char arr[10] = "11";
	printf("%d\n%d\n",1,11);
	countnsay(arr,1);
}

