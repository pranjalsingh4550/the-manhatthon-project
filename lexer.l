%option noyywrap
%option yylineno
%{
    #include<bits/stdc++.h> 
    #include "parser.tab.h"
    #include "classes.h"
    extern int nodecount;
    extern FILE* graph;
    using namespace std;
    stack<string> indent_stack;
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
digit [0-9]
digitpart {digit}(_?{digit})*
fraction "."{digitpart}
pointfloat ({digitpart}?{fraction})|{digitpart}"."
exponent [eE][+-]?{digit}+
exponentfloat ({digitpart}|{pointfloat}){exponent}
floatnumber ({pointfloat}|{exponentfloat})


imagnumber ({floatnumber}|{digitpart})[jJ]

/*end <<EOF>>|<<INITIAL>>\n */

dunder "__name__"|"__main__"|"__init__"
emptyline ^[ \t\f]*\n
string (\"[^\"\\\n]*(\\[^\n][^\"\\\n]*)*\")|(\'[^\'\\\n]*(\\[^\n][^\'\\\n]*)*\')
/*   "  sdafasdf asdf \t asdfasdf"  */
/* string (\"    [^\"\\\n]*      (\\.[^\"\\\n]*)*   \")   |       (\'[^\'\\\n]*(\\.[^\'\\\n]*)*\') */
triple_string (\'\'\'[^\'\\]*(((\\.)|(\'){1,2}([^\'\\]|\\.))[^\'\\]*)*\'\'\')|(\"\"\"[^\"\\]*(((\\.)|(\"){1,2}([^\"\\]|\\.))[^\"\\]*)*\"\"\")
ignore [ \f\t]|{comments}
ignore2	\n[ \f\t]*{comments}?


%%
    { 
	// fprintf (stderr, "YYLEX call %d %d %d\n", newline, indent, ded);
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

{ignore2}+/\n	{ }
\\[ \f\t]*\n
\n[ \t\f]*   {
    newline=1;
    string s=yytext+1;
    // cerr<<"Non-empty line: line no: "<<yylineno << " whitespace length excluding preceding newline"<< len << endl;
    if(indent_stack.top()==s){
    	/* cerr << "Line " << yylineno << " at same indent level\n" ;*/ ;
    } else if(indent_stack.top().size()<s.size())
    {
        for(int i=0;i<indent_stack.top().size();i++)
        {
            if(indent_stack.top()[i]!=s[i])
            {
                cout<<"Indentation/Tab Error at line no:"<<yylineno<<endl;
                /*cerr<<"Indentation Error"<<endl;*/ ;
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
                cout<<"Indentation/Tab Error at line no: "<<yylineno<<endl;
                exit(1);
            }
        }
        ded=0;
        while(indent_stack.top().size()>s.size())
        {
            ded++;
            indent_stack.pop();
        }
        if(indent_stack.top().size()!=s.size())
        {
           cerr<<"Indentation/Tab Error at line no: "<<yylineno<<endl; ;
            exit(1);
        }
    }
    return yylex();
}

"break"	{yylval.node=new Node(yytext);return BREAK;}
"continue"	{yylval.node=new Node(yytext);return CONTINUE;}
"return"	{yylval.node=new Node(yytext);return RETURN;}
"pass"	{yylval.node=new Node(yytext);return PASS;}

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

"+"	{yylval.node=new Node(0,yytext);return PLUS;}
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
    return LPAR;
}
")"	{
    return RPAR;
}
"[" {
    return LSQB;
}
"]" {
    return RSQB;
}
"." {return DOT;}

[1-9]{number}*|0	{yylval.node=new Node(yytext);return NUMBER;}
{number}	{cerr<<"leading zeros in decimal integer literals are not permitted"<<endl;exit(1);}
0[oO](_?[0-7]+)+	{yylval.node=new Node(yytext);return NUMBER;}
0[xX](_?[0-9a-fA-F]+)+	{yylval.node=new Node(yytext);return NUMBER;}
0[bB](_?[01]+)+	{yylval.node=new Node(yytext);return NUMBER;}



{floatnumber}	{yylval.node=new Node(yytext);return NUMBER;}






{imagnumber}	{yylval.node=new Node(yytext);return NUMBER;}



{string}	{ //yylval.node=new Node(yytext);return STRING
                char temp[yyleng+3];
                /// yytext[yyleng-1] = 0;
                yytext[yyleng-1] = '\\';
                sprintf(temp,"\\\"%s\"",yytext+1);
                yylval.node=new Node(temp);return STRING;
            }




{triple_string} {
            char temp[yyleng+7];
            char c=yytext[0];
            yytext[yyleng-3] = '\0';
            sprintf(temp,"\\%c\\%c\\%c%s\\%c\\%c\\%c",c,c,c,yytext+3,c,c,c);
            yylval.node=new Node(temp);return STRING;
            }
True	{yylval.node = new Node(yytext);return TRUE;}
False	{yylval.node = new Node(yytext);return FALSE;}
None	{yylval.node = new Node(yytext);return NONE;}
{NAME}	{yylval.node=new Node(yytext);return NAME;}
{ignore}
 /*<INITIAL><<EOF>> {BEGIN(end);return ENDMARKER;} */
. {cerr<<"Invalid character"<<endl;exit(1);}
%%
