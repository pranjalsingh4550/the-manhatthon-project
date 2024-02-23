%{
    #include<bits/stdc++.h>
    using namespace std;
    extern int yylex();
    extern int yyparse();
    extern char* yytext;
    extern int yyerror(const char *s);
%}

%union{
    int num;
}

%token <num> NUMBER
%start lines
%%
lines: {cout<<"what "<<yytext<<endl;} | lines line {cout<<yytext<<endl;} 
    ;
line : "let" NUMBER '\n' {cout<<"nice"<<endl;}
| '\n'
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