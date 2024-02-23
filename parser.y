%{
    #include<bits/stdc++.h>
    using namespace std;   
    extern int yylex();
    extern int yyparse(); 
    extern int yylineno;
    int yyerror(const char *s);
%}

%union {
    int ival;
    char *sval;
}

%token NEWLINE NAME INDENT DEDENT
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



%start statements


%%
statements : statements statement| statement 
;

statement: simple_stmts
;

simple_stmts: simple_stmt semi NEWLINE
            | simple_stmt ";" simple_stmts
;


semi: | ";"
;

simple_stmt: assignment
;

assignment: NAME ":"  expression maybe_rhs 

maybe_rhs : | "="  expression 

expression: disjunction "if" disjunction "else" expression | disjunction

disjunction : conjunction | disjunction "or" conjunction

conjunction : inversion | conjunction "and" inversion

inversion : comparison | "not" inversion

comparison: bitwise_or | comparison compare_op_bitwise_or_pair

compare_op_bitwise_or_pair: eq_bitwise_or | noteq_bitwise_or | lt_bitwise_or | lte_bitwise_or | gt_bitwise_or | gte_bitwise_or | is_bitwise_or | in_bitwise_or | notin_bitwise_or| isnot_bitwise_or

eq_bitwise_or: "==" bitwise_or
noteq_bitwise_or: "!=" bitwise_or
lt_bitwise_or: "<" bitwise_or
lte_bitwise_or: "<=" bitwise_or
gt_bitwise_or: ">" bitwise_or
gte_bitwise_or: ">=" bitwise_or
is_bitwise_or: "is" bitwise_or
in_bitwise_or: "in" bitwise_or
notin_bitwise_or: "not" "in" bitwise_or
isnot_bitwise_or: "is" "not" bitwise_or

bitwise_or: bitwise_xor | bitwise_or "|" bitwise_xor

bitwise_xor: bitwise_and | bitwise_xor "^" bitwise_and

bitwise_and: shift_expr | bitwise_and "&" shift_expr

shift_expr: sum | shift_expr "<<" sum | shift_expr ">>" sum

sum : sum "+" term | sum "-" term | term

term: term "*" factor | term "/" factor | term "%" factor | term "//" factor |factor 

factor: "+" factor | "-" factor | "~" factor | power

power: primary | primary "**" factor

primary: atom

atom : NAME
    | NUMBER
    | STRING
    | "True"
    | "False"
    | "None"

 /* block: NEWLINE INDENT statements DEDENT | simple_stmts */
%%

int main(){
    yyparse();
    return 0;
}

int yyerror(const char *s){
    cout<<"Error: "<<s<<"at line number: "<<yylineno<<endl;
    return 0;
}