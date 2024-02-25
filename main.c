#include <stdio.h>
extern int yylex();

int main(){
	printf ("jhello\n");
	int ret = yylex();
    printf("\n");
    return ret; // for debugging
}
