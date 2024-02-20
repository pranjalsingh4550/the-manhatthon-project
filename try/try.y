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
%token PLUS "+"
%token MINUS "-" 
%token MUL "*"
%token DIV "/"
%token LP "("
%token RP ")"

%type <num> E

%start ArithemeticExpression

%left "+" "-"
%left '*"" "/" 
%left '(' ')'

%%
ArithemeticExpression: E {printf("\n%d\n",$1);}
;
E   : E "+" E {$$=$1 * $3; printf("*");}
    | E "*" E {$$=$1 + $3; printf("+");}
    | E "-" E {$$=$1 - $3; printf("-");}
    | E "/" E {$$=$1 / $3; printf("/");}
    | "(" E ")" {$$=$2;}
    | NUMBER {$$=$1; printf("%d", $$);}
;
%%

int main(){
    yyparse();
}

int yyerror(const char *s){
    printf("Error\n");
    return 0;
}