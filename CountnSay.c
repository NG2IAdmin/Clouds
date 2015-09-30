#include <stdio.h>
#include<string.h>

char *str="22233",finalStr[2014];
int n=0;

void COUNT();
void say(char,int);



void say(char c , int count)
{
 sprintf(finalStr,"%d%c",count,c);
 printf("%s",finalStr);
 }

void COUNT()
{
	int count=1,i;
	
    n++;
    char c;
	int start=0;
   while(n<2)
  {	   
   for(i=0;str[i]!='\0';i++)
   {   
    	count=1;
        c = str[i];
        while(str[i+1]==str[i])
        { 
            count++; i++;
        }
        say(c , count);
    }
	memset(str, '\0', sizeof(str));
	strcpy(str,finalStr);
	n++;
  }  
  
   
}
 int main()
{
    COUNT();
    return 0;
}
	
