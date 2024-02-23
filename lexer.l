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

ignore \f

%%

{keyword}	{ do_token ('k');	}
{operator}	{ do_token ('o');	}
{delimiter}	{ do_token ('d'); 	}
{comments}	{ do_token ('c');	}
{identifier}	{ do_token ('i'); 	}
{number}	{ do_token ('n');	}

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

YYSTYPE do_token (char t) {
#ifdef DEV_DEBUG
	printf ("token %s length %d\t", yytext, yyleng);
	switch (t) {
		case 'o': {
			printf ("operator\n");
			break;
		}
		case 'd': {
			printf ("delimiter\n");
			break;
		}
		case 'c': {
			printf ("comment\n");
			break;
		}
		case 'i': {
			printf ("identifier\n");
			break;
		}
		case 'k': {
			printf ("keyword\n");
			break;
		}
		case 'n': {
			printf ("number\n");
			break;
		}
		default:
			  printf ("error\n");
	}
#endif
	//process here
	switch (t) {
		case 'o': {
			// process printf ("operator\n");
			break;
		}
		case 'd': {
			// process printf ("delimiter\n");
			break;
		}
		case 'c': {
			// process printf ("comment\n");
			break;
		}
		case 'i': {
			// process printf ("identifier\n");
			break;
		}
		case 'k': {
			// process printf ("keyword\n");
			break;
		}
		case 'n': {
			// process printf ("number\n");
			break;
		}
		default:
			  printf ("error\n");
	}
	return 0;
}
