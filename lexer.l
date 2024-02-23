%option noyywrap
%option yylineno
%{
    #include<bits/stdc++.h>
    #include "parser.tab.h"
    using namespace std;
#ifndef YYSTYPE
#define YYSTYPE long
#endif
#define DEV_DEBUG
extern YYSTYPE do_token (char);
%}

keyword "False"|"await"|"else"|"None"|"break"|"except"|"in"|"raise"|"True"|"class"|"finally"|"is"|"return"|"and"|"continue"|"for"|"lambda"|"try"|"as"|"def"|"from"|"nonlocal"|"while"|"assert"|"del"|"global"|"not"|"with"|"async"|"elif"|"if"|"or"|"yield"
operator "+"|"-"|"*"|"**"|"/"|"//"|"%"|"@"|"<<"|">>"|"&"|"|"|"^"|"~"|"<"|">"|"<="|">="|"=="|"!="
delimiter "("|")"|"["|"]"|"{"|"}"|","|":"|"."|";"|"@"|"="|"->"|"+="|"-="|"*="|"/="|"//="|"%="|"@="|"&="|"|="|"^="|">>="|"<<="|"**="
literal \"[^\"]*\"|'[^']*'
comments #[^\r\n]*
NAME [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+
dunder "__name__"|"__main__"|"__init__"

string '[^'\\]*(?:\\.[^'\\]*)*'
ignore [ \f]

%%
"break"	{return BREAK;}
"continue"	{return CONTINUE;}
"return"	{return RETURN;}

"if"	{return IF;}
"else"	{return ELSE;}

"and"	{return AND;}
"or"	{return OR;}
"not"	{return NOT;}

"==" 	{return EQEQUAL;}
"!=" 	{return NOTEQUAL;}
"<"  	{return LESS;}
">"		{return GREATER;}
"<=" 	{return LESSEQUAL;}
">=" 	{return GREATEREQUAL;}
"is" 	{return IS;}
"in" 	{return IN;}

"|"	{return VBAR;}
"^"	{return CIRCUMFLEX;}
"&"	{return AMPER;}
"<<"	{return LEFTSHIFT;}
">>"	{return RIGHTSHIFT;}

"+"	{return PLUS;}
"-"	{return MINUS;}
"*"	{return STAR;}
"/"	{return SLASH;}
"%"	{return PERCENT;}
"//"	{return DOUBLESLASH;}
"**"	{return DOUBLESTAR;}

[1-9]{number}*|0	{return NUMBER;}
{number}	{cerr<<"leading zeros in decimal integer literals are not permitted"<<endl;exit(1);}
{string}	{return STRING;}
True	{return TRUE;}
False	{return FALSE;}
None	{return NONE;}

{NAME}	{return NAME;}
";"	{return SEMI;}
":"	{return COLON;}
"="	{return EQUAL;}
\t	{return INDENT;}
\n	{return NEWLINE;}
{ignore}
. {return yytext[0];}
%%
