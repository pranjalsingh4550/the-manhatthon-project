%option noyywrap
%option yylineno
%option stack
%{
    #include<bits/stdc++.h> 
    #include "parser.tab.h"
    #include "classes.hpp"
    extern int nodecount;
    extern FILE* graph;
    using namespace std;
    stack<string> indent_stack;
    int ded=0;
    int newline=0;
    int indent=0;
    int bracketline=0;
    extern int stderr_dup;
    char brackettype;
%}
comments #[^\r\n]*
NAME [a-zA-Z_][a-zA-Z0-9_]*



number [0-9]+
digit [0-9]
digitpart {digit}(_?{digit})*
fraction "."{digitpart}
pointfloat ({digitpart}?{fraction})|{digitpart}"."
exponent [eE][+-]?{digit}+
exponentfloat ({digitpart}|{pointfloat}){exponent}
floatnumber ({pointfloat}|{exponentfloat})


imagnumber ({floatnumber}|{digitpart})[jJ]

ignore [ \r\f\t]|{comments}
ignore2	\n[ \f\t]*{comments}?

%s parOpen squareOpen curlyOpen

%%
    { 
        if(indent_stack.empty())
		indent_stack.push("");
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

^[ \f\t]+{comments}?$
^[ \f\t]+/. {return INDENT;}
{ignore2}/\n 
\\\n[ \t\f]*
    /*\\ {
	    cerr << "Syntax error: no characters on same line after line continuation character at line no: " << yylineno << endl;
	    exit(1);
    }  
    Error overkill!!! let . handle it like python does
     */
<parOpen,squareOpen>\n[ \t\f]*
\n[ \t\f]* {
    newline=1;
    string s=yytext+1;
    if(indent_stack.top()==s){
    }
    else if(indent_stack.top().size()<s.size())
    {
        for(int i=0;i<indent_stack.top().size();i++)
        {
            if(indent_stack.top()[i]!=s[i])
            {
                dprintf (stderr_dup, "Inconsistent use of tabs and spaces in indentation at line %d\n", yylineno);
                exit(1);
            }
        }
        indent_stack.push(s);
        indent=1;
    }
    else
    {
        for(int i=0;i<s.size();i++)
        {
            if(indent_stack.top()[i]!=s[i])
            {
                dprintf (stderr_dup, "Inconsistent use of tabs and spaces in indentation at line %d\n", yylineno);
                exit(1);
            }
        }
        ded=0;
        while(indent_stack.top().size()>s.size())
        {
            ded++;
            indent_stack.pop();
        }
        if(indent_stack.top()!=s)
        {
           dprintf (stderr_dup, "Unindent amount does not match previous indent at line %d\n", yylineno) ;
            exit(1);
        }
    }
    return yylex();
}


"break"	{string temp="Keyword\n( ";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return BREAK;}
"continue"	{string temp="Keyword\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return CONTINUE;}
"return"	{yylval.node=new Node(yytext);return RETURN;}
"pass"	{string temp="Keyword\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return PASS;}

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

"+="	{yylval.node=new Node(0,yytext);return PLUSEQUAL;}
"-="	{yylval.node=new Node(0,yytext);return MINEQUAL;}
"*="	{yylval.node=new Node(0,yytext);return STAREQUAL;}
"/="	{yylval.node=new Node(0,yytext);return SLASHEQUAL;}
"//="	{yylval.node=new Node(0,yytext);return DOUBLESLASHEQUAL;}
"%="	{yylval.node=new Node(0,yytext);return PERCENTEQUAL;}
"**="	{yylval.node=new Node(0,yytext);return DOUBLESTAREQUAL;}
"&="	{yylval.node=new Node(0,yytext);return AMPEREQUAL;}
"|="	{yylval.node=new Node(0,yytext);return VBAREQUAL;}
"^="	{yylval.node=new Node(0,yytext);return CIRCUMFLEXEQUAL;}
">>="	{yylval.node=new Node(0,yytext);return RIGHTSHIFTEQUAL;}
"<<="	{yylval.node=new Node(0,yytext);return LEFTSHIFTEQUAL;}
"->"	{return RARROW;}
"("	{
    bracketline=yylineno;
    brackettype='(';
	yy_push_state(parOpen);
    return LPAR;
}

<parOpen>")"	{    
	yy_pop_state();
    return RPAR;
}
")"	{
    dprintf (stderr_dup, "Bracket Mismatch at line no: %d\n", bracketline);
    exit(1);
}
"[" {
    bracketline=yylineno;
    brackettype='[';
	yy_push_state(squareOpen);
    return LSQB;
}
<squareOpen>"]" {
	yy_pop_state();
    return RSQB;
}
"]" {
    dprintf (stderr_dup, "Bracket Mismatch at line no: %d\n", bracketline);
    exit(1);
}
"{" {
    bracketline=yylineno;
    brackettype='{';
    yy_push_state(curlyOpen);
    return LBRACE;
}
<curlyOpen>"}" {
    yy_pop_state();
    return RBRACE;
}
"}" {
    dprintf (stderr_dup, "Bracket Mismatch at line no: %d\n", bracketline);
    exit(1);
}

"." {return DOT;}

[1-9]{number}*|0	{string temp="Integer Literal\n( ";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NUMBER;}
{number}	{dprintf (stderr_dup, "leading zeros in decimal integer literals are not permitted\nError at line %d\n", yylineno);exit(1);}
0[oO](_?[0-7]+)+	{string temp="Integer Literal\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NUMBER;}
0[xX](_?[0-9a-fA-F]+)+	{string temp="Integer Literal\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NUMBER;}
0[bB](_?[01]+)+	{string temp="Integer Literal\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NUMBER;}

{floatnumber}   {string temp="Floating point Literal\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NUMBER;}
{imagnumber}    {string temp="Imaginary Literal\n(";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NUMBER;}
(?x:(r|R)?(\"[^\"\\\n]*(\\(.|\n)[^\"\\\n]*)*\")|(\'[^\'\\\n]*(\\(.|\n)[^\'\\\n]*)*\'))   {
	string s="String Literal\n( ";
    for(int i=0;i<yyleng;i++)
    {
        switch(yytext[i])
        {
            case '\n': s.push_back('\\');s.push_back('n');break;
            case '\a': s.push_back('\\');s.push_back('a');break;
            case '\b': s.push_back('\\');s.push_back('b');break;
            case '\f': s.push_back('\\');s.push_back('f');break;
            case '\r': s.push_back('\\');s.push_back('r');break;
            case '\t': s.push_back('\\');s.push_back('t');break;
            case '\v': s.push_back('\\');s.push_back('v');break;
            case '\\': s.push_back('\\');s.push_back('\\');break;
            case '\'': s.push_back('\\');s.push_back('\'');break;
            case '\"': s.push_back('\\');s.push_back('\"');break;
            default: s.push_back(yytext[i]);
        }
    }
    s+=" )";
    yylval.node=new Node(s);return STRING;
}

(?x:(r|R)?(\'\'\'[^\'\\]*(((\\(.|\n))|(\'){1,2}([^\'\\]|\\.))[^\'\\]*)*\'\'\')|(\"\"\"[^\"\\]*(((\\(.|\n))|(\"){1,2}([^\"\\]|\\.))[^\"\\]*)*\"\"\")) {
	string s="String Literal\n( ";
    for(int i=0;i<yyleng;i++)
    {
        switch(yytext[i])
        {
            case '\n': s.push_back('\\');s.push_back('n');break;
            case '\a': s.push_back('\\');s.push_back('a');break;
            case '\b': s.push_back('\\');s.push_back('b');break;
            case '\f': s.push_back('\\');s.push_back('f');break;
            case '\r': s.push_back('\\');s.push_back('r');break;
            case '\t': s.push_back('\\');s.push_back('t');break;
            case '\v': s.push_back('\\');s.push_back('v');break;
            case '\\': s.push_back('\\');s.push_back('\\');break;
            case '\'': s.push_back('\\');s.push_back('\'');break;
            case '\"': s.push_back('\\');s.push_back('\"');break;
            default: s.push_back(yytext[i]);
        }
    }
    s+=" )";
    yylval.node=new Node(s);return STRING;
}

True	{string temp="Keyword\n( ";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return TRUE;}
False	{string temp="Keyword\n( ";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return FALSE;}
None	{string temp="Keyword\n( ";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NONE;}
{NAME}	{string temp="Identifier\n( ";temp+=yytext;temp+=" )";yylval.node=new Node(temp);return NAME;}
{ignore}
<parOpen,squareOpen><<EOF>>	{ dprintf (stderr_dup, "Unopened bracket %c at line no: %d\n", brackettype, bracketline);exit(1);} 
. { dprintf (stderr_dup, "Invalid token %c at line no: %d\n", yytext[0], yylineno); exit(1);}
%%
