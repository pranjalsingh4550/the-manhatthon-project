%{
    #include<bits/stdc++.h>
    using namespace std;
    extern int yylex();
    extern int yyparse();
    extern int yyerror(const char *s);
%}

%union{
    int num;
}

%token <num> NUMBER
%token LET "let"
%start lines
%%
lines: | lines line 
    ;
line : "let" {$3=0;}  NUMBER'\n'| '\n'
    ;
%%

int main(){
    yyparse();
    return 0;
}

int yyerror(const char *s){
    printf("Errorzfsdf\n");
    return 0;
}