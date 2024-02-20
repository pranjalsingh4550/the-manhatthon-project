%{
    #include<bits/stdc++.h>
    using namespace std;    
%}

%token KEYWORD OPERATOR DELIMITER IDENTIFIER CONSTANT STRING_LITERAL NEWLINE

%start statements

%%
statements : statements statement
           | statement
;

statement: compound_stmt | simple_stmt
;

simple_stmt:
    | assignment
    | type_alias
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
    | nonlocal_stmt
;
compound_stmt:
    | function_def
    | if_stmt
    | class_def
    | with_stmt
    | for_stmt
    | try_stmt
    | while_stmt
    | match_stmt
;
%%