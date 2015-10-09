#include<stdio.h>
#include<stdlib.h>

struct node{
	int x;
	struct node * next;
};

void main(int argc,char * argv[]){
	struct node * root;
	struct node * current;
	int y,temp;
	root = malloc(sizeof(struct node));
	current = root;
	current->x=0;	
/*	printf("Enter the interger -: \n");
	scanf("%d",&y);
	current-> x = y;
	printf("Want to add more node in link list?(y or n)\n");
	scanf("%d",&y);
	if(y==1){
		while(y!=0){
			current->next = malloc(sizeof(struct node));
			printf("Enter the interger -:\n");
			scanf("%d",&y);
			current = current->next;
			current->x = y;
			printf("Want to add more node in link list?(y or n)\n");
			scanf("%d",&y);
		}
	}
	current->next=0;
	current = root;
	while(current->next != 0){
		printf("%d\n",current->x);
		current=current->next;
	}
	printf("%d\n",current->x);*/
	for(y=1;y<=50;y++){
		current->next=malloc(sizeof(struct node));
		current=current->next;
		current->x=y;
	}
	current->next=0;
	current = root;
	while(current->next != 0){
		printf("%p----->%d\n",current->next,current->x);
		current=current->next;
	}	
	printf("%p----->%d\n",current->next,current->x);
//--------------------------------------------------------------------------------------------------------------------------------------	
	current = root;
	while(current->next->next->next!=NULL){
		temp = current->next->next->x;
		current->next->next->x=current->x;
		current->x=temp;
		current=current->next->next->next;
	}
//--------------------------------------------------------------------------------------------------------------------------------------	
	printf("\n");
	current = root;	
	while(current->next != 0){
		printf("%p----->%d\n",current->next,current->x);
		current=current->next;
	}	
	printf("%p----->%d\n",current->next,current->x);
}
