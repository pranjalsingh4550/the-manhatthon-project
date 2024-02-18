#include <stdio.h>
extern int yylex();

int main(){
    yylex();
    printf("\n");
    return 0;
}