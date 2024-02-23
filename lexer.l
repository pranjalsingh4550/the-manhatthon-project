%option noyywrap
%option yylineno
%{
    #include<bits/stdc++.h>
    #include "parser.tab.h"
    using namespace std;
    stack<int> indent_stack;
    int ded=0;
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
    if(indent_stack.empty())
        indent_stack.push(0);
    if(ded>0){
        ded--;
        return DEDENT;
    }
"break"	{return BREAK;}
"continue"	{return CONTINUE;}
"return"	{return RETURN;}
"pass"	{return PASS;}
"raise"	{return RAISE;}
"assert"	{return ASSERT;}

"from"	{return FROM;}

"if"	{return IF;}
"else"	{return ELSE;}

"and"	{return AND;}
"or"	{return OR;}
"not"	{return NOT;}

"class" {return CLASS;}


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

";"	{return SEMI;}
":"	{return COLON;}
"="	{return EQUAL;}
","	{return COMMA;}

"+"	{return PLUS;}
"-"	{return MINUS;}
"*"	{return STAR;}
"/"	{return SLASH;}
"%"	{return PERCENT;}
"//"	{return DOUBLESLASH;}
"**"	{return DOUBLESTAR;}

"+="	{return PLUSEQUAL;}
"-="	{return MINEQUAL;}
"*="	{return STAREQUAL;}
"/="	{return SLASHEQUAL;}
"//="	{return DOUBLESLASHEQUAL;}
"%="	{return PERCENTEQUAL;}
"**="	{return DOUBLESTAREQUAL;}
"&="	{return AMPEREQUAL;}
"|="	{return VBAREQUAL;}
"^="	{return CIRCUMFLEXEQUAL;}
">>="	{return RIGHTSHIFTEQUAL;}
"<<="	{return LEFTSHIFTEQUAL;}




[1-9]{number}*|0	{return NUMBER;}
{number}	{cerr<<"leading zeros in decimal integer literals are not permitted"<<endl;exit(1);}
{string}	{return STRING;}
True	{return TRUE;}
False	{return FALSE;}
None	{return NONE;}

{NAME}	{return NAME;}
^[\t ]*\n
\n  {return NEWLINE;}
^[\t ]+	{
    if(indent_stack.top()==yyleng){return 0;}
    else if(indent_stack.top()<yyleng)
    {
        indent_stack.push(yyleng);
        return INDENT;
    }
    else
    {
        ded=1;
        indent_stack.pop();
        while(indent_stack.top()>yyleng)
        {
            ded++;
            indent_stack.pop();
        }
        if(indent_stack.top()!=yyleng)
        {
            cerr<<"Indentation Error"<<endl;
            exit(1);
        }
    }
    indent_stack.push(yyleng);return INDENT;}
{ignore}
. {return yytext[0];}
%%
