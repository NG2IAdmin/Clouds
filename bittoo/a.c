#include <stdio.h>
#include<string.h>
#include<stdlib.h>

//char *str="22233",
//char finalStr[2014];
int n=0;

void COUNT();
void say(char,int,char*);



void say(char c , int count,char * finalStr)
{
 sprintf(finalStr,"%d%c",count,c);
 printf("%s",finalStr);
 }

void COUNT(char *str)
{	if(n>10)  return;
	//memset(finalStr, 0, 255);
	int count=1,i;
	char finalStr[100];
    //n++;
    char c;
	int start=0;
 //  while(n<2)
  //{	  
   for(i=0;str[i]!='\0';i++)
   {   
    	count=1;
        c = str[i];
        while(str[i+1]==str[i])
        { 
            count++; i++;
        }
        say(c , count,finalStr);
    }
	printf("\n");
	//strcpy(str,finalStr);
	n++;
  //}
	COUNT(finalStr);
}
 int main()
{	
	char *str="1";
    COUNT(str);
    return 0;
}
	
