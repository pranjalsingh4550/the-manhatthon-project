%{
    #include<bits/stdc++.h>
    using namespace std;   
    extern int yylex();
    extern int yyparse(); 
    extern void debugprintf (const char *) ;
    extern int yylineno;
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
stmts : {cout<<"empty input"<<endl;} |stmts stmt { debugprintf ( "stmts stmt\n"); }
;

stmt: simple_stmt { debugprintf ( "simple_stmt\n"); }
	| compound_stmt { debugprintf ( "compund_stmt\n"); }
;

simple_stmt: small_stmt semi NEWLINE   { debugprintf ( "small_stmt semi NEWLINE  \n"); }
            | small_stmt ";" simple_stmt { debugprintf ( "small_stmt ; simple_stmts\n"); }
;


semi: | ";" { debugprintf ( ";\n"); }
;

small_stmt: expr_stmt { debugprintf ( "expr_stmt\n"); }
	| return_stmt { debugprintf ( "return_stmt\n"); }
	| raise_stmt { debugprintf ( "raise_stmt\n"); }
	| "break"
	| "continue"
	| "pass"
	| assert_stmt
	/* | global_stmt
	| nonlocal_stmt */
;
expr_stmt: NAME annassign ":"  test maybe_rhs  { debugprintf ( "NAME :  test maybe_rhs \n"); }
	| test augassign test { debugprintf ( "test annassign\n"); }

annassign: ":"  test maybe_rhs
maybe_rhs :
    | "=" test  { debugprintf ( "= test \n"); }

test: or_test "if" or_test "else" test  { debugprintf ( "or_test if or_test else test \n"); }
	| or_test { debugprintf ( "or_test\n"); }
augassign: "+=" | "-=" | "*=" | "/=" | "//=" | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**=" { debugprintf ( "augassign\n"); }

raise_stmt: "raise" | "raise" test maybe_from_test

maybe_from_test: | "from" test { debugprintf ( "from test\n"); }

/* global_stmt: "global"  arglist

nonlocal_stmt: "nonlocal"  arglist */

assert_stmt: "assert" test { debugprintf ( "assert_stmt\n"); }

return_stmt: "return" maybe_test { debugprintf ( "return maybe_test\n"); }

maybe_test : | test { debugprintf ( "test\n"); 	}



or_test : and_test  { debugprintf ( "and_test \n"); }
	| or_test "or" and_test { debugprintf ( "or_test or and_test\n"); }

and_test : not_test  { debugprintf ( "not_test \n"); }
	| and_test "and" not_test { debugprintf ( "and_test and not_test\n"); }

not_test : comparison  { debugprintf ( "comparison \n"); }
	| "not" not_test { debugprintf ( "not not_test\n"); }

comparison: expr  { debugprintf ( "expr \n"); }
	| comparison compare_op_bitwise_or_pair { debugprintf ( "comparison compare_op_bitwise_or_pair\n"); }

compare_op_bitwise_or_pair: eq_bitwise_or  { debugprintf ( "compare_op_bitwise_or_pair: eq_bitwise_or \n"); }
	| noteq_bitwise_or  { debugprintf ( "noteq_bitwise_or \n"); }
	| lt_bitwise_or  { debugprintf ( "lt_bitwise_or \n"); }
	| lte_bitwise_or  { debugprintf ( "lte_bitwise_or \n"); }
	| gt_bitwise_or  { debugprintf ( "gt_bitwise_or \n"); }
	| gte_bitwise_or  { debugprintf ( "gte_bitwise_or \n"); }
	| is_bitwise_or  { debugprintf ( "is_bitwise_or \n"); }
	| in_bitwise_or  { debugprintf ( "in_bitwise_or \n"); }
	| notin_bitwise_or { debugprintf ( "notin_bitwise_or\n"); }
	| isnot_bitwise_or { debugprintf ( "isnot_bitwise_or\n"); }

eq_bitwise_or: "==" expr { debugprintf ( "== expr\n"); }
noteq_bitwise_or: "!=" expr { debugprintf ( "!= expr\n"); }
lt_bitwise_or: "<" expr { debugprintf ( "< expr\n"); }
lte_bitwise_or: "<=" expr { debugprintf ( "<= expr\n"); }
gt_bitwise_or: ">" expr { debugprintf ( "> expr\n"); }
gte_bitwise_or: ">=" expr { debugprintf ( ">= expr\n"); }
is_bitwise_or: "is" expr { debugprintf ( "is expr\n"); }
in_bitwise_or: "in" expr { debugprintf ( "in expr\n"); }
notin_bitwise_or: "not" "in" expr { debugprintf ( "not in expr\n"); }
isnot_bitwise_or: "is" "not" expr { debugprintf ( "is not expr\n"); }

expr: xor_expr  { debugprintf ( "xor_expr \n"); }
	| expr "|" xor_expr { debugprintf ( "expr | xor_expr\n"); }

xor_expr: ans_expr  { debugprintf ( "ans_expr \n"); }
	| xor_expr "^" ans_expr { debugprintf ( "xor_expr ^ ans_expr\n"); }

ans_expr: shift_expr  { debugprintf ( "shift_expr \n"); }
	| ans_expr "&" shift_expr { debugprintf ( "ans_expr & shift_expr\n"); }

shift_expr: sum  { debugprintf ( "sum \n"); }
	| shift_expr "<<" sum  { debugprintf ( "shift_expr << sum \n"); }
	| shift_expr ">>" sum { debugprintf ( "shift_expr >> sum\n"); }

sum : sum "+" term  { debugprintf ( "sum + term\n"); }
	| sum "-" term { debugprintf ( "sum - term\n"); }
	| term { debugprintf ( "term\n"); }

term: term "*" factor  { debugprintf ( "term * factor \n"); }
	| term "/" factor  { debugprintf ( "term / factor \n"); }
	| term "%" factor { debugprintf ( "term % factor\n"); }
	| term "//" factor { debugprintf ( "term // factor\n"); }
	|factor  { debugprintf ( "factor \n"); }

factor: "+" factor { debugprintf ( "+ factor\n"); }
	| "-" factor { debugprintf ( "- factor\n"); }
	| "~" factor { debugprintf ( "~ factor\n"); }
	| power { debugprintf ( "power\n"); }

power: primary { debugprintf ( "primary\n"); }
	| primary "**" factor { debugprintf ( "primary ** factor\n"); }

primary: atom { debugprintf ( "atom\n"); }


atom : NAME { debugprintf ( "NAME\n"); }
    | NUMBER { debugprintf ( "NUMBER\n"); }
    | STRING { debugprintf ( "STRING\n"); }
    | "True" { debugprintf ( "True\n"); }
    | "False" { debugprintf ( "False\n"); }
    | "None" { debugprintf ( "None\n"); }

classdef: "class" NAME ":" suite
	| "class" NAME "(" arglist ")" ":" suite
	| "class" NAME "(" ")" ":" suite

;

arglist: test | arglist "," test { debugprintf ( "test\n"); }

suite: simple_stmt { debugprintf ("simple_stmt\n"); }
	| NEWLINE INDENT stmts DEDENT	{debugprintf ("NEWLINE INDENT stmts DEDENT\n");}

compound_stmt: 
	/* if_stmt { debugprintf ("if_stmt\n"); }
	| while_stmt { debugprintf ("while_stmt\n"); }
	| for_stmt { debugprintf ("for_stmt\n"); }
	| funcdef { debugprintf ("funcdef\n"); } */
	classdef { debugprintf ("classdef\n"); } 
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