%{
    #include<bits/stdc++.h>
    using namespace std;   
    extern int yylex();
    extern int yyparse(); 
    extern void debugprintf (const char *) ;
    extern int yylineno;
    int yyerror(const char *s);
%}

%union {
    int ival;
    char *sval;
}

%token NEWLINE NAME INDENT
%token SEMI ";"
%token EQUAL "="
%token COLON ":"

%token BREAK "break"
%token CONTINUE "continue"
%token RETURN "return"

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

%token<ival> NUMBER
%token<sval> STRING
%token TRUE "True"
%token FALSE "False"
%token NONE "None"

%token DOT "." 

%start statements


%%
statements : statements statement { debugprintf ( "statements statement\n"); }
	| statement { debugprintf ( "statement\n"); }
;

statement: simple_stmts { debugprintf ( "simple_stmts\n"); }
;

simple_stmts: simple_stmt semi NEWLINE   { debugprintf ( "simple_stmt semi NEWLINE  \n"); }
            | simple_stmt ";" simple_stmts { debugprintf ( "simple_stmt ; simple_stmts\n"); }
;


semi: | ";" { debugprintf ( ";\n"); }
;

simple_stmt:
    | assignment { debugprintf ( "assignment\n"); }

;

assignment: NAME ":"  expression maybe_rhs  { debugprintf ( "NAME :  expression maybe_rhs \n"); }

maybe_rhs :
    | "=" expression  { debugprintf ( "= expression \n"); }

expression: disjunction "if" disjunction "else" expression  { debugprintf ( "disjunction if disjunction else expression \n"); }
	| disjunction { debugprintf ( "disjunction\n"); }

disjunction : conjunction  { debugprintf ( "conjunction \n"); }
	| disjunction "or" conjunction { debugprintf ( "disjunction or conjunction\n"); }

conjunction : inversion  { debugprintf ( "inversion \n"); }
	| conjunction "and" inversion { debugprintf ( "conjunction and inversion\n"); }

inversion : comparison  { debugprintf ( "comparison \n"); }
	| "not" inversion { debugprintf ( "not inversion\n"); }

comparison: bitwise_or  { debugprintf ( "bitwise_or \n"); }
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

eq_bitwise_or: "==" bitwise_or { debugprintf ( "== bitwise_or\n"); }
noteq_bitwise_or: "!=" bitwise_or { debugprintf ( "!= bitwise_or\n"); }
lt_bitwise_or: "<" bitwise_or { debugprintf ( "< bitwise_or\n"); }
lte_bitwise_or: "<=" bitwise_or { debugprintf ( "<= bitwise_or\n"); }
gt_bitwise_or: ">" bitwise_or { debugprintf ( "> bitwise_or\n"); }
gte_bitwise_or: ">=" bitwise_or { debugprintf ( ">= bitwise_or\n"); }
is_bitwise_or: "is" bitwise_or { debugprintf ( "is bitwise_or\n"); }
in_bitwise_or: "in" bitwise_or { debugprintf ( "in bitwise_or\n"); }
notin_bitwise_or: "not" "in" bitwise_or { debugprintf ( "not in bitwise_or\n"); }
isnot_bitwise_or: "is" "not" bitwise_or { debugprintf ( "is not bitwise_or\n"); }

bitwise_or: bitwise_xor  { debugprintf ( "bitwise_xor \n"); }
	| bitwise_or "|" bitwise_xor { debugprintf ( "bitwise_or | bitwise_xor\n"); }

bitwise_xor: bitwise_and  { debugprintf ( "bitwise_and \n"); }
	| bitwise_xor "^" bitwise_and { debugprintf ( "bitwise_xor ^ bitwise_and\n"); }

bitwise_and: shift_expr  { debugprintf ( "shift_expr \n"); }
	| bitwise_and "&" shift_expr { debugprintf ( "bitwise_and & shift_expr\n"); }

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

primary: primary "." NAME |atom { debugprintf ( "atom\n"); }

atom : NAME { debugprintf ( "NAME\n"); }
    | NUMBER { debugprintf ( "NUMBER\n"); }
    | STRING { debugprintf ( "STRING\n"); }
    | "True" { debugprintf ( "True\n"); }
    | "False" { debugprintf ( "False\n"); }
    | "None" { debugprintf ( "None\n"); }

 /* block: NEWLINE INDENT statements DEDENT | simple_stmts */
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
