#include<stdio.h>
#include<string.h>
int main()
{
int arr1[26],arr2[26],t,i,l,m;
char ch1[1000],ch2[1000];


scanf("%d",&t);
while(t--)
{
for(i=0;i<26;i++)
{
arr1[i]=0;
arr2[i]=0;	
}

scanf("%s %s",ch1,ch2);
//printf("%s %s \n",ch1,ch2);
l=strlen(ch1);
//printf("l %d",l);
m=strlen(ch2);
if(l!=m){
printf("enter strings are not matched");
continue;}
for(i=0;i<l;i++)
{
arr1[ch1[i]-'a']++;	
}
for(i=0;i<m;i++)
{
arr1[ch2[i]-'a']--;	
}	
int flag=0;	
for(i=0;i<26;i++)
{
if(arr1[i]!=0){flag=1;break;
	}
}
if(flag==0)
printf("enter strings are anagram");
else
printf("strings are not matched");	
}
return 0;
}
