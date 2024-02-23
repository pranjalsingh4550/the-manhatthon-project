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

%token BREAK "break"
%token CONTINUE "continue"
%token RETURN "return"
%token PASS "pass"
%token ASSERT "assert"
%token RAISE "raise"

%token FROM "from"

%token IF "if"
%token ELSE "else"

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




%token<ival> NUMBER
%token<sval> STRING
%token TRUE "True"
%token FALSE "False"
%token NONE "None"


%start stmts


%%
stmts : | stmts stmt 

;

stmt:  simple_stmt 
	| compound_stmt 
;

simple_stmt: small_stmt semi NEWLINE   
            | small_stmt ";" simple_stmt 
;


semi: | ";" 
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

annassign: ":"  test maybe_rhs
maybe_rhs :
    | "=" test 

test: or_test "if" or_test "else" test  
	| or_test 
augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**=" 

raise_stmt: "raise" | "raise" test maybe_from_test

maybe_from_test: | "from" test

/* global_stmt: "global"  arglist

nonlocal_stmt: "nonlocal"  arglist */

assert_stmt: "assert" test 

return_stmt: "return" maybe_test 

maybe_test : | test 



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

classdef: "class" NAME ":" suite
	| "class" NAME "(" arglist ")" ":" suite
	| "class" NAME "(" ")" ":" suite

;

arglist: test | arglist "," test 

suite: simple_stmt 
	| NEWLINE INDENT stmts DEDENT	

compound_stmt: 
	/* if_stmt { debugprintf ("if_stmt\n"); }
	| while_stmt { debugprintf ("while_stmt\n"); }
	| for_stmt { debugprintf ("for_stmt\n"); }
	| funcdef { debugprintf ("funcdef\n"); } */
	classdef 
	 /* | async_stmt { debugprintf ("async_stmt\n"); }  */
%%

int main(){
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