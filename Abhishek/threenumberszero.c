#include<stdio.h>


int  main()
{
int i,t,n,k,j,element;
scanf("%d",&t);
while(t--)
{
scanf("%d",&n);

int arr[n];
for(i=0;i<n;i++)
{
scanf("%d",&arr[i]);
  }
  	for(i=0;i<n;i++)
  	{
	 for(j=n-1;j>=i+1;j--)
    {
   element=arr[i]+arr[j];
   element=-element;
    for(k=i+1;k<j;k++)
	{
		   
		   if(element==arr[k] )
		   {printf("%d, %d, %d\n",arr[i],arr[j],arr[k]);
	 }
	   }
		}
		 }
 }
 return 0;
}
