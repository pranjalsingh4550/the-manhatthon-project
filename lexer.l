%option noyywrap
%option yylineno
%option stack
%{
    #include<bits/stdc++.h> 
    using namespace std;
    #include<stdlib.h>
    #include "parser.tab.h"
    #include "classes.hpp"
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

%s parOpen squareOpen

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


"break"	{return BREAK;}
"continue"	{return CONTINUE;}
"return"	{return RETURN;}
"global"	{return GLOBAL;}

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

"." {return DOT;}

[1-9](_?[0-9])*|0	{
	//first create a string without the underscores
	string text = "";
	for (int i = 0; i < yyleng; i++) {
		if (yytext[i] != '_')
			text += yytext[i];
	}
	//use strtol - will set errno to ERANGE if overflow - if so, then throw error (for now)
	long int val = strtol(text.c_str(), NULL, 10);
	if (errno) {
		dprintf(stderr_dup, "Error at line %d:\nMagnitude of integer %s is too big\n", yylineno, yytext);
		exit(1);
	}
    // printf("\t\tLI t_%d, %ld\n",nodecount,val);
	yylval.node = new Node(NUMBER, val);
	yylval.node->production = strdup (yytext);
	return NUMBER;
}
{number}	{dprintf (stderr_dup, "leading zeros in decimal integer literals are not permitted\nError at line %d\n", yylineno);exit(1);}
0[oO](_?[0-7]+)+	{
	//same deal as normal ints, above, but need to get rid of underscores
	//first create a string without the underscores
	string text = "";
	for (int i = 2; i < yyleng; i++) {
		//skip first 2 chars - 0o
		if (yytext[i] != '_')
			text += yytext[i];
	}
	//use strtol - will set errno to ERANGE if overflow - if so, then throw error (for now)
	long int val = strtol(text.c_str(), NULL, 8);
	if (errno) {
		dprintf(stderr_dup, "Error at line %d:\nMagnitude of integer %s is too big\n", yylineno, yytext);
		exit(1);
	}
	yylval.node = new Node(NUMBER, val);
	yylval.node->production = strdup (yytext);
	yylval.node->typestring = "int";
	return NUMBER;
}
0[xX](_?[0-9a-fA-F]+)+	{
	//same deal
	//first create a string without the underscores
	string text = "";
	for (int i = 2; i < yyleng; i++) {
		if (yytext[i] != '_')
			text += yytext[i];
	}
	//use strtol - will set errno to ERANGE if overflow - if so, then throw error (for now)
	const long int val = strtol(text.c_str(), NULL, 16);
	if (errno) {
		dprintf(stderr_dup, "Error at line %d:\nMagnitude of integer %s is too big\n", yylineno, yytext);
		exit(1);
	}
	yylval.node = new Node(NUMBER, val);
	yylval.node->production = strdup (yytext);
	yylval.node->typestring = "int";
	return NUMBER;
}
0[bB](_?[01]+)+	{
	//first create a string without the underscores
	string text = "";
	for (int i = 2; i < yyleng; i++) {
		if (yytext[i] != '_')
			text += yytext[i];
	}
	//use strtol - will set errno to ERANGE if overflow - if so, then throw error (for now)
	long int val = strtol(text.c_str(), NULL, 2);
	if (errno) {
		dprintf(stderr_dup, "Error at line %d:\nError in getting value of integer %s\n", yylineno, yytext);
		exit(1);
	}
	yylval.node = new Node(NUMBER, val);
	yylval.node->production = strdup (yytext);
	yylval.node->typestring = "int";
	return NUMBER;
}

{floatnumber}   {
	//exponentfloat ({digitpart}|{pointfloat}){exponent}
	//exponent [eE][+-]?{digit}+
	//pointfloat ({digitpart}?{fraction})|{digitpart}"."
	//digitpart {digit}(_?{digit})*
	//digit  [0-9]
	//again, get rid of all underscores
	string text = "";
    string temp=yytext;
	for (int i = 0; i < yyleng; i++) {
		if (temp[i] != '_')
			text += temp[i];
	}
	//just use strtof
	double val = strtod(text.c_str(), NULL);
	if (errno) {
		dprintf(stderr_dup, "Error at line %d:\nError in getting value of float %s\n", yylineno, yytext);
		exit(1);

	}
	yylval.node = new Node(NUMBER, val);
	yylval.node->production = strdup (yytext);
	yylval.node->typestring = "float";
	return NUMBER;
}
{imagnumber}    {
	//imagnumber ({floatnumber}|{digitpart})[jJ]
	//again, remove underscore from premises (along with the j at the end)
	string text = "";
	for (int i = 0; i < yyleng - 1; i++) {
		if (yytext[i] != '_')
			text += yytext[i];
	}
	//just get float value
	complexLiteral val = {
		.real = 0.0,
		.imag = strtof(text.c_str(), NULL)
	};
	
	if (errno) {
		dprintf(stderr_dup, "Error at line %d:\nError in getting value of complex number %s\n", yylineno, yytext);
		exit(1);
	}
	yylval.node = new Node(NUMBER, val);
	yylval.node->typestring = "complex";
	yylval.node->production = strdup (yytext);
	return NUMBER;
}
(?x:(r|R)?(\"[^\"\\\n]*(\\(.|\n)[^\"\\\n]*)*\")|(\'[^\'\\\n]*(\\(.|\n)[^\'\\\n]*)*\'))   {
    string s;
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
    yylval.node=new Node(STRING, s);
	yylval.node->production = strdup (yytext);
    return STRING;
}

(?x:(r|R)?(\'\'\'[^\'\\]*(((\\(.|\n))|(\'){1,2}([^\'\\]|\\.))[^\'\\]*)*\'\'\')|(\"\"\"[^\"\\]*(((\\(.|\n))|(\"){1,2}([^\"\\]|\\.))[^\"\\]*)*\"\"\")) {
	string s;
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
    yylval.node=new Node(STRING, s);
	yylval.node->production = strdup (yytext);
    return STRING;
}

True	{yylval.node=new Node(TRUE, true); return TRUE;}
False	{yylval.node=new Node(FALSE, false); return FALSE;}
None	{yylval.node=new Node(0);return NONE;}
list    {yylval.node=new Node(LIST,"",yytext);return LIST;}
{NAME}	{yylval.node=new Node(NAME, "", yytext);return NAME;}
{ignore}
<parOpen,squareOpen><<EOF>>	{
	dprintf (stderr_dup, "Unopened bracket %c at line no: %d\n", brackettype, bracketline);
	exit(1);
} 
. {
	dprintf (stderr_dup, "Invalid token %c at line no: %d\n", yytext[0], yylineno);
	exit(1);
}
%%
