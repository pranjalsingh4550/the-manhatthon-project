%option noyywrap
%option yylineno
%{
    #include<bits/stdc++.h> 
    #include "parser.tab.h"
    using namespace std;
    stack<int> indent_stack;
    int ded=0;
    int newline=0;
    int indent=0;
%}

keyword "False"|"await"|"else"|"None"|"break"|"except"|"in"|"raise"|"True"|"class"|"finally"|"is"|"return"|"and"|"continue"|"for"|"lambda"|"try"|"as"|"def"|"from"|"nonlocal"|"while"|"assert"|"del"|"global"|"not"|"with"|"async"|"elif"|"if"|"or"|"yield"
operator "+"|"-"|"*"|"**"|"/"|"//"|"%"|"@"|"<<"|">>"|"&"|"|"|"^"|"~"|"<"|">"|"<="|">="|"=="|"!="
delimiter "("|")"|"["|"]"|"{"|"}"|","|":"|"."|";"|"@"|"="|"->"|"+="|"-="|"*="|"/="|"//="|"%="|"@="|"&="|"|="|"^="|">>="|"<<="|"**="
literal \"[^\"]*\"|'[^']*'
comments #[^\r\n]*
NAME [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+
dunder "__name__"|"__main__"|"__init__"
emptyline ^[ \t\f]*\n
string '[^'\\]*(?:\\.[^'\\]*)*'
ignore [ \f\t]|{comments}

%%
    {
        if(indent_stack.empty())
        indent_stack.push(0);
        if(newline==1){
            newline=0;
            return NEWLINE;
        }
        if(indent==1){
            indent=0;
            return INDENT;
        }
        if(ded>0){
            ded--;
            return DEDENT;
        }
    }
{emptyline}+ 
\n{ignore}*/\n {printf("Comment\n");return yylex();}
\n[ \t\f]*   {
    newline=1;
    int len=yyleng-1;
    if(indent_stack.top()==len){}
    else if(indent_stack.top()<len)
    {
        indent_stack.push(yyleng);
        indent=1;
    }
    else
    {
        ded=1;
        indent_stack.pop();
        while(indent_stack.top()>len)
        {
            ded++;
            indent_stack.pop();
        }
        if(indent_stack.top()!=len)
        {
            cerr<<"Indentation Error"<<endl;
            exit(1);
        }
    }
    return yylex();
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
"elif"	{return ELIF;}

"and"	{return AND;}
"or"	{return OR;}
"not"	{return NOT;}

"class" {return CLASS;}
"def"	{return DEF;}
"while"	{return WHILE;}
"for"	{return FOR;}

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
"->"	{return FUNCRETTYPE;}
"("	{return LPAR;}
")"	{return RPAR;}
"[" {return LSQB;}
"]" {return RSQB;}
"." {return DOT;}




[1-9]{number}*|0	{return NUMBER;}
{number}	{cerr<<"leading zeros in decimal integer literals are not permitted"<<endl;exit(1);}
{string}	{return STRING;}
True	{return TRUE;}
False	{return FALSE;}
None	{return NONE;}
{NAME}	{return NAME;}
{ignore}
. {return yytext[0];}
%%
