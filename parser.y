%{
    #include<bits/stdc++.h>
    using namespace std;
	FILE* graph = NULL;   
    extern int yylex();
    extern int yyparse();
    extern void debugprintf (const char *) ;
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	extern void maketree (char* production, int count);
	int nodecount = 0;
	struct Node {
		int nodeid;
		string production;
		vector<Node*> children;
		Node (int id, string prod) {
			nodeid = id;
			production = prod;
			if (graph)
				fprintf (graph, "\tnode%d [label=%s]", nodecount ++, prod.c_str());
		}
		void addchild (Node* child) {
			children.push_back(child);
			if (graph)
				fprintf (graph, "node%d -> node %d\n", this->nodeid, child->nodeid);
		}
		void printnode () {
			cout << "Node id: " << nodeid << " Production: " << production << endl;
			for (auto child: children) {
				child->printnode();
			}
		}
	};
	#define YYDEBUG 1
%}

%union {
	struct node* node;
}

%token <Node*> NEWLINE NAME INDENT DEDENT
%token <Node*> SEMI ";"
%token <Node*> EQUAL "="
%token <Node*> COLON ":"
%token <Node*> COMMA ","
%token <Node*> CLASS "class"
%token <Node*> FUNCRETTYPE "->"
%token <Node*> DEF "def"
%token <Node*> WHILE "while"
%token <Node*> FOR "for"

%token <Node*> BREAK "break"
%token <Node*> CONTINUE "continue"
%token <Node*> RETURN "return"
%token <Node*> PASS "pass"
%token <Node*> ASSERT "assert"
%token <Node*> RAISE "raise"

%token <Node*> FROM "from"

%token <Node*> IF "if"
%token <Node*> ELSE "else"
%token <Node*> ELIF "elif"

%token <Node*> AND "and"
%token <Node*> OR "or"
%token <Node*> NOT  "not"

%token <Node*> EQEQUAL "=="
%token <Node*> NOTEQUAL "!="
%token <Node*> LESS "<"
%token <Node*> LESSEQUAL "<="
%token <Node*> GREATER ">"
%token <Node*> GREATEREQUAL ">="
%token <Node*> IS "is"
%token <Node*> IN "in"
%token <Node*> VBAR "|"
%token <Node*> CIRCUMFLEX "^"
%token <Node*> AMPER "&"
%token <Node*> LEFTSHIFT "<<"
%token <Node*> RIGHTSHIFT ">>"
%token <Node*> PLUS "+"
%token <Node*> MINUS "-"
%token <Node*> STAR "*"
%token <Node*> SLASH "/"
%token <Node*> PERCENT "%"
%token <Node*> DOUBLESLASH "//"
%token <Node*> TILDE "~"
%token <Node*> DOUBLESTAR "**"

%token <Node*> PLUSEQUAL "+="
%token <Node*> MINEQUAL "-="
%token <Node*> STAREQUAL "*="
%token <Node*> SLASHEQUAL "/="
%token <Node*> PERCENTEQUAL "%="
%token <Node*> DOUBLESLASHEQUAL "//="
%token <Node*> AMPEREQUAL "&="
%token <Node*> VBAREQUAL "|="
%token <Node*> CIRCUMFLEXEQUAL "^="
%token <Node*> LEFTSHIFTEQUAL "<<="
%token <Node*> RIGHTSHIFTEQUAL ">>="
%token <Node*> DOUBLESTAREQUAL "**="


%token <Node*> LPAR "("
%token <Node*> RPAR ")"
%token <Node*> BACKSLASH_LINEJOINING "\\"




%token <Node*> NUMBER
%token <Node*> STRING
%token <Node*> TRUE "True"
%token <Node*> FALSE "False"
%token <Node*> NONE "None"


%start input


%%
input : |
	stmts

stmts : 
	stmt | stmts stmt 	

;

stmt:  simple_stmt 
	| compound_stmt 
;

simple_stmt: small_stmt ";"  NEWLINE   
	| small_stmt NEWLINE
	| small_stmt ";" simple_stmt 
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
	| NAME "=" test 

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


atom : NAME /*{ $$ = Node (nodecount ++, "name"); }*/
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
	| NEWLINE  INDENT  stmts DEDENT  {printf("nice\n\n\n");}

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
	if_stmt
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
	yydebug = 1 ;
	if (argv[1] && argv[1][0] == 'n')
		yydebug = 0;
	if (argv[2] && argv[2][0]) {
		graph = fopen (argv[2], "w+");
	}
	
    yyparse();
	fclose (graph);
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
