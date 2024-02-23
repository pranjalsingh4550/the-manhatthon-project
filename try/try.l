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
"let"|"go" { return 0;}
\n { return yytext[0];}
. {return yytext[0];}
%%

int yywrap(){
    return 1;
}