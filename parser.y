%{
    #include<bits/stdc++.h>
	#include"classes.h"
    using namespace std; 
	int nodecount=0;
	FILE* graph = fopen ("ast.dot", "w+"); 
    extern int yylex();
    extern int yyparse();
    extern void debugprintf (const char *) ;
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	extern void maketree (char* production, int count);
	#define YYDEBUG 1
%}

%union {
	class Node* node;

}

%token <node> NEWLINE NAME INDENT DEDENT
%token <node> RARROW "->"
%token <node> CLASS "class"
%token <node> DEF "def"
%token <node> WHILE "while"
%token <node> FOR "for"

%token <node> BREAK "break"
%token <node> CONTINUE "continue"
%token <node> RETURN "return"
%token <node> PASS "pass"	

%token <node> FROM "from"

%token <node> IF "if"
%token <node> ELSE "else"
%token <node> ELIF "elif"

%token <node> AND "and"
%token <node> OR "or"
%token <node> NOT  "not"

%token <node> SEMI ";"
%token <node> EQUAL "="
%token <node> COLON ":"
%token <node> COMMA ","
%token <node> LSQB "["
%token <node> RSQB "]"
%token <node> DOT "."
%token <node> EQEQUAL "=="
%token <node> NOTEQUAL "!="
%token <node> LESS "<"
%token <node> LESSEQUAL "<="
%token <node> GREATER ">"
%token <node> GREATEREQUAL ">="
%token <node> IS "is"
%token <node> IN "in"
%token <node> VBAR "|"
%token <node> CIRCUMFLEX "^"
%token <node> AMPER "&"
%token <node> LEFTSHIFT "<<"
%token <node> RIGHTSHIFT ">>"
%token <node> PLUS "+"
%token <node> MINUS "-"
%token <node> STAR "*"
%token <node> SLASH "/"
%token <node> PERCENT "%"
%token <node> DOUBLESLASH "//"
%token <node> TILDE "~"
%token <node> DOUBLESTAR "**"

%token <node> PLUSEQUAL "+="
%token <node> MINEQUAL "-="
%token <node> STAREQUAL "*="
%token <node> SLASHEQUAL "/="
%token <node> PERCENTEQUAL "%="
%token <node> DOUBLESLASHEQUAL "//="
%token <node> AMPEREQUAL "&="
%token <node> VBAREQUAL "|="
%token <node> CIRCUMFLEXEQUAL "^="
%token <node> LEFTSHIFTEQUAL "<<="
%token <node> RIGHTSHIFTEQUAL ">>="
%token <node> DOUBLESTAREQUAL "**="


%token <node> LPAR "("
%token <node> RPAR ")"
%token <node> BACKSLASH_LINEJOINING "\\"




%token <node> NUMBER
%token <node> STRING
%token <node> TRUE "True"
%token <node> FALSE "False"
%token <node> NONE "None"

%token <node> ENDMARKER

%type <node> stmts stmt simple_stmt small_stmt expr_stmt annassign test augassign return_stmt or_test and_test not_test comparison compare_op_bitwise_or_pair eq_bitwise_or noteq_bitwise_or lt_bitwise_or lte_bitwise_or gt_bitwise_or gte_bitwise_or is_bitwise_or in_bitwise_or notin_bitwise_or isnot_bitwise_or expr xor_expr ans_expr shift_expr sum term factor power primary atom if_stmt if_block_left_factored while_stmt arglist suite funcdef classdef compound_stmt for_stmt exprlist testlist STRING_plus trailer



%start input


%%
input: start|NEWLINE input

start : ENDMARKER|
	stmts ENDMARKER 

stmts : 
	stmt {$$=$1;}
	| stmts stmt { $$ = new Node ("stmts"); $$->addchild($1); $$->addchild($2);}

;

stmt:  simple_stmt { $$ = $1;}
	| compound_stmt { $$ = $1;}
;

simple_stmt: small_stmt ";"  NEWLINE   {$3=new Node("NEWLINE");$$ = new Node ("SEMI"); $$->addchild($1);$$->addchild($3);}
	| small_stmt[left] NEWLINE[right] {$2=new Node("NEWLINE");$$ = new Node ("Small_stmt_NEWLINE"); $$->addchild($left);$$->addchild($right);}
	| small_stmt ";" simple_stmt {$$ = new Node ("SEMI"); $$->addchild($1);$$->addchild($3);}
;




small_stmt: expr_stmt { $$ = $1;}
	| return_stmt { $$ = $1;}
	| "break" {$$=$1;}
	| "continue" {$$=$1;}
	| "pass" {$$=$1;}
	/* | global_stmt
	| nonlocal_stmt */
;
expr_stmt: NAME annassign { 
			$$ = new Node ("expr_stmt");
			$$->addchild($1);
			$$->addchild($2);	
			 }
	| test augassign test { 
			$$ = new Node ("operation");
			$$->addchild($1);
			$$->addchild($3);
	}
	| test "=" test {
			$$ = new Node ("simple_assignment");
			$$->addchild($1);
			$$->addchild($3);
	}
	|	test

annassign: ":"  test "=" test {
			$$ = new Node ("Anotated_Assignment");
			$$->addchild($2);
			$$->addchild($4);
		}
	| ":" test {
			$$ = new Node ("Annotated_declaration");
			$$->addchild($2);
	}

test: or_test "if" or_test "else" test {
		$$ = new Node ("inline_if_else");
		$$->addchild($1);
		$$->addchild($3);
		$$->addchild($5);
	}
	| or_test { $$=$1;}
augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**="


/* global_stmt: "global"  arglist

nonlocal_stmt: "nonlocal"  arglist */


return_stmt: "return" test 
	| "return"

or_test : and_test  { $$=$1;}
	| or_test "or" and_test 

and_test : not_test { $$=$1;}
	| and_test "and" not_test 
not_test : comparison { $$=$1;} 
	| "not" not_test 

comparison: expr  { $$=$1;}
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

expr: xor_expr  { $$=$1;}
	| expr "|" xor_expr 

xor_expr: ans_expr { $$=$1;}
	| xor_expr "^" ans_expr 

ans_expr: shift_expr  { $$=$1;}
	| ans_expr "&" shift_expr 

shift_expr: sum  { $$=$1;	}
	| shift_expr "<<" sum  
	| shift_expr ">>" sum 

sum : sum "+" term  
	| sum "-" term 
	| term { $$=$1;}

term: term "*" factor 
	| term "/" factor  
	| term "%" factor 
	| term DOUBLESLASH factor 
	|factor  { $$=$1;}

factor: "+" factor 
	| "-" factor 
	| "~" factor 
	| power { $$=$1;}

power: primary	{$$=$1;}
	| primary "**" factor 

primary: atom {$$=$1;}
	| primary trailer 


atom: NAME {$$=$1;}
    | NUMBER {$$=$1;}
    | STRING_plus 
    | "True" 
    | "False" 
    | "None" 

STRING_plus: STRING 
	| STRING_plus STRING

trailer: "." NAME
	| "[" testlist "]"
	| "(" testlist ")"
	| "(" ")"

if_stmt: if_block_left_factored		{$$ = $1 ;}
	| if_block_left_factored "else" ":" suite	{ $$ = new Node ("if_else"); $$->addchild($1); $$->addchild($4);}

if_block_left_factored: "if" test ":" suite { $$ = new Node ("if"); $$->addchild($2); $$->addchild($4);}
	| if_block_left_factored "elif" test ":" suite { $$ = new Node ("if_elif"); $$->addchild($1); $$->addchild($3); $$->addchild($5);}


while_stmt: "while" test ":" suite


arglist:  test 
	| arglist "," test 

suite: simple_stmt { $$ = $1;}
	| NEWLINE  INDENT  stmts DEDENT {$$=$3;} 

funcdef: "def" NAME "(" arglist ")" "->" test ":" suite
	| "def" NAME "(" ")" "->" test ":" suite


classdef: "class" NAME ":"  suite
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
	if_stmt		{$$ = $1;}
	| while_stmt
	| for_stmt
	| funcdef
	| classdef

for_stmt: "for" exprlist "in" testlist ":" suite                                           
        | "for" exprlist "," "in" testlist ":" suite                                       
exprlist: xor_expr
        | exprlist "," xor_expr
testlist: arglist
        | arglist ",";
  

%%

int main(int argc, char* argv[]){
	fprintf(graph, "strict digraph ast {\n");
	yydebug = 1 ;
	yyparse();
	if (argv[1] && argv[1][0] == 'n')
		yydebug = 0;
	if (argc >2 && argv[2] && argv[2][0]) {
		graph = fopen (argv[2], "w+");
		fprintf (graph, "strict digraph ast {\n");
	}
	if (graph) {
		fprintf (graph, "}\n");
		fclose (graph);
	}
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
