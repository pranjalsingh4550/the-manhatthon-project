%{
    #include<bits/stdc++.h>
    using namespace std;    
%}

%union {
    int ival;
    char *sval;
}

%token NEWLINE NAME

 

%token SEMI ";"
%token EQUAL "="
%token COLON ":"
%start statements

%

%%
statements : statements statement
           | statement
;

statement: simple_stmts | 
    /* compound_stmt */
;

simple_stmts: simple_stmt semi NEWLINE
            | simple_stmts ";" simple_stmt semi NEWLINE
;

semi: | ";"
;

simple_stmt:
    | assignment
    /* | type_alias
    | star_expressions 
    | return_stmt
    | import_stmt
    | raise_stmt
    | del_stmt
    | yield_stmt
    | assert_stmt
    | "break" 
    | "continue" 
    | global_stmt
    | nonlocal_stmt */
;
/* compound_stmt: */
    /* | function_def
    | if_stmt
    | class_def
    | with_stmt
    | for_stmt
    | try_stmt
    | while_stmt
    | match_stmt */
;

assignment: NAME ":" maybe_rhs | 

maybe_rhs : | "=" expression

expression: NAME
%%