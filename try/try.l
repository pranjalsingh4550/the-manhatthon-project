%{
    #include<bits/stdc++.h>
    #include "try.tab.h"
    extern int yylex();
    extern int yyparse();
    using namespace std;
%}

%%
[0-9]+ { yylval.num = atoi(yytext);return NUMBER;}
[ \t] ;
\n { return 0;}
. { cout<<"Error";}
%%

int yywrap(){
    return 1;
}