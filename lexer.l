%option noyywrap
%option yylineno
%{
    #include<bits/stdc++.h>
    #include "parser.tab.h"
    using namespace std;
%}

keyword "False"|"await"|"else"|"None"|"break"|"except"|"in"|"raise"|"True"|"class"|"finally"|"is"|"return"|"and"|"continue"|"for"|"lambda"|"try"|"as"|"def"|"from"|"nonlocal"|"while"|"assert"|"del"|"global"|"not"|"with"|"async"|"elif"|"if"|"or"|"yield"
operator "+"|"-"|"*"|"**"|"/"|"//"|"%"|"@"|"<<"|">>"|"&"|"|"|"^"|"~"|"<"|">"|"<="|">="|"=="|"!="
delimiter "("|")"|"["|"]"|"{"|"}"|","|":"|"."|";"|"@"|"="|"->"|"+="|"-="|"*="|"/="|"//="|"%="|"@="|"&="|"|="|"^="|">>="|"<<="|"**="
literal \"[^\"]*\"|'[^']*'
comments #[^\r\n]*
NAME [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+
dunder "__name__"|"__main__"|"__init__"

ignore \f

%%
"break" {return BREAK;}
"continue" {return CONTINUE;}
"return" {return RETURN;}

"if" {return IF;}
"else" {return ELSE;}

"and" {return AND;}
"or" {return OR;}
"not" {return NOT;}

"=="  {return EQEQUAL;}



{NAME} {return NAME;}
";" {return SEMI;}
":" {return COLON;}
"=" {return EQUAL;}
\t {return INDENT;}
\n {return NEWLINE;}
{ignore}
. {return yytext[0];}
%%


