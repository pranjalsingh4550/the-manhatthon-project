%{
    #include<bits/stdc++.h>
    using namespace std;   
    extern int yylex();
    extern int yyparse(); 
    extern void debugprintf (const char *) ;
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	extern void maketree (char* production, int count);
	int nodecount = 0;
	#define YYDEBUG 1
%}

%union {
    int ival;
    char *sval;
	int node_num ;
}

%token NEWLINE NAME INDENT
%token SEMI ";"
%token EQUAL "="
%token COLON ":"
%token COMMA ","
%token CLASS "class"
%token FUNCRETTYPE "->"
%token DEF "def"
%token WHILE "while"
%token FOR "for"

%token BREAK "break"
%token CONTINUE "continue"
%token RETURN "return"
%token PASS "pass"
%token ASSERT "assert"
%token RAISE "raise"

%token FROM "from"

%token IF "if"
%token ELSE "else"
%token ELIF "elif"

%token AND "and"
%token OR "or"
%token NOT  "not"

%token EQEQUAL "=="
%token NOTEQUAL "!="
%token LESS "<"
%token LESSEQUAL "<="
%token GREATER ">"
%token GREATEREQUAL ">="
%token IS "is"
%token IN "in"
%token VBAR "|"
%token CIRCUMFLEX "^"
%token AMPER "&"
%token LEFTSHIFT "<<"
%token RIGHTSHIFT ">>"
%token PLUS "+"
%token MINUS "-"
%token STAR "*"
%token SLASH "/"
%token PERCENT "%"
%token DOUBLESLASH "//"
%token TILDE "~"
%token DOUBLESTAR "**"

%token PLUSEQUAL "+="
%token MINEQUAL "-="
%token STAREQUAL "*="
%token SLASHEQUAL "/="
%token PERCENTEQUAL "%="
%token DOUBLESLASHEQUAL "//="
%token AMPEREQUAL "&="
%token VBAREQUAL "|="
%token CIRCUMFLEXEQUAL "^="
%token LEFTSHIFTEQUAL "<<="
%token RIGHTSHIFTEQUAL ">>="
%token DOUBLESTAREQUAL "**="


%token LPAR "("
%token RPAR ")"
%token BACKSLASH_LINEJOINING "\\"




%token<ival> NUMBER
%token<sval> STRING
%token TRUE "True"
%token FALSE "False"
%token NONE "None"

%token<sval> COMMENT

%start stmts


%%
stmts : | stmts stmt 

;

stmt:  simple_stmt 
	| compound_stmt 
;

simple_stmt: small_stmt ";"  NEWLINE   
	| small_stmt NEWLINE
	| small_stmt comment_newline
	| small_stmt ";" simple_stmt 
	| small_stmt ":" comment_newline
	| comment_newline
;

comment_newline: COMMENT NEWLINE
;



small_stmt: expr_stmt 
	| return_stmt 
	|  raise_stmt 
	| "break"
	| "continue"
	| "pass"
	| assert_stmt
	/* | global_stmt
	| nonlocal_stmt */
;
expr_stmt: NAME  annassign
	| test augassign test 

annassign: ":"  test "=" test
| ":" test

test: or_test "if" or_test "else" test  
	| or_test 
augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**=" 

raise_stmt: "raise" | "raise" test maybe_from_test

maybe_from_test: | "from" test

/* global_stmt: "global"  arglist

nonlocal_stmt: "nonlocal"  arglist */

assert_stmt: "assert" test 

return_stmt: "return" test 
	| "return"

or_test : and_test  
	| or_test "or" and_test 

and_test : not_test 
	| and_test "and" not_test 
not_test : comparison  
	| "not" not_test 

comparison: expr  
	| comparison compare_op_bitwise_or_pair 

compare_op_bitwise_or_pair: eq_bitwise_or 
	| noteq_bitwise_or  
	| lt_bitwise_or 
	| lte_bitwise_or  
	| gt_bitwise_or  
	| gte_bitwise_or  
	| is_bitwise_or 
	| in_bitwise_or
	| notin_bitwise_or 
	| isnot_bitwise_or 

eq_bitwise_or: "==" expr 
noteq_bitwise_or: "!=" expr 
lt_bitwise_or: "<" expr 
lte_bitwise_or: "<=" expr 
gt_bitwise_or: ">" expr 
gte_bitwise_or: ">=" expr 
is_bitwise_or: "is" expr 
in_bitwise_or: "in" expr 
notin_bitwise_or: "not" "in" expr
isnot_bitwise_or: "is" "not" expr 

expr: xor_expr  
	| expr "|" xor_expr 

xor_expr: ans_expr 
	| xor_expr "^" ans_expr 

ans_expr: shift_expr  
	| ans_expr "&" shift_expr 

shift_expr: sum  
	| shift_expr "<<" sum  
	| shift_expr ">>" sum 

sum : sum "+" term  
	| sum "-" term 
	| term 

term: term "*" factor 
	| term "/" factor  
	| term "%" factor 
	| term DOUBLESLASH factor 
	|factor  

factor: "+" factor 
	| "-" factor 
	| "~" factor 
	| power 

power: primary
	| primary "**" factor 

primary: atom


atom : NAME 
    | NUMBER 
    | STRING 
    | "True" 
    | "False" 
    | "None" 

if_stmt: if_block_left_factored
	| if_block_left_factored "else" ":" suite
	| if_block_left_factored elif_block "else" ":" suite

if_block_left_factored: "if" test ":" suite

elif_block: "elif" test ":" suite
	| elif_block "elif" test ":" suite

while_stmt: "while" test ":" suite


arglist: test | arglist "," test 

suite: simple_stmt 
	| NEWLINE INDENT stmts DEDENT

funcdef: "def" NAME "(" arglist ")" "->" test ":" suite
	| "def" NAME "(" ")" "->" test ":" suite


classdef: "class" NAME ":" suite
	| "class" NAME "(" arglist ")" ":" suite
	| "class" NAME "(" ")" ":" suite
/* TODO: comments between : and suite */
 
/* LOOK HERE!
func_class_prototype:
	  NAME "(" arglist ")"
	| NAME "(" ")"
	/* factoring to avoid conflicts 

funcdef: "def" func_class_prototype "->" test : suite
classdef: "class" func_class_prototype ":" suite
	| "class" NAME ":" suite
*/

compound_stmt: 
	if_stmt
	| while_stmt
	/* | for_stmt { debugprintf ("for_stmt\n"); } */
	| funcdef
	classdef

/* TODO: ADD COMMENTS INSIDE COMPOUND STATEMENT ? */

%%

int main(int argc, char* argv[]){
	yydebug = 1 ;
	if (argv[1] && argv[1][0] == 'n')
		yydebug = 0;
    yyparse();
    return 0;
}

int yyerror(const char *s){
    cout<<"Error: "<<s<<" at line number: "<<yylineno<<endl;
    return 0;
}

void debugprintf ( const char *msg) {
	fprintf (stderr, msg, 44);
	return ;
}

// usage - initialise an array of size count
void maketree (char* production, int count, int n[]) {
	char * cur = production;
	FILE* out = stdout;
	int ctr;
	fprintf (out,"// NEW PRODUCTION %d %s\n// ", count, production);
	for (ctr = 0; ctr < count; ctr ++ ) {
		while (*cur == ' ') cur++ ; // move to first non-space character
		if (*cur == '\n') break ;
		fprintf (out, "child node %d:\t",ctr);
		while (*cur != ' ' && *cur != '\n') {
			fprintf (out, "%c", *cur);
			cur ++;
		}
		fprintf (out, "\n// node_%d", n[ctr]);
		fprintf (out, "nodecount -> node_%d\n", n[ctr]);
	}
	fprintf (out,"// END OF PRODUCTION %d %s\n", count, production);
	
	return ;
}
