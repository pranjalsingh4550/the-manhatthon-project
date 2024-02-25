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
	class Node {
		public:
		int nodeid;
		string production;
		vector<struct Node*> children;
		// Node operator=(const Node& other) {
		// 	nodeid = other.nodeid;
		// 	production = other.production;
		// 	children = other.children;
		// 	return *this;
		// }
		Node (const char *label) {
			nodeid = nodecount ++;
			production = label;
			if (graph)
				fprintf (graph, "\tnode%d [label=%s];\n", nodeid, label);
		}
		void addchild (Node* child) {
			children.push_back(child);
			if (graph)
				fprintf (graph, "\tnode%d -> node%d;\n", this->nodeid, child->nodeid);
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
	class Node* node;

}

%token <node> NEWLINE NAME INDENT DEDENT
%token <node> SEMI ";"
%token <node> EQUAL "="
%token <node> COLON ":"
%token <node> COMMA ","
%token <node> LSQB "["
%token <node> RSQB "]"
%token <node> DOT "."
%token <node> CLASS "class"
%token <node> FUNCRETTYPE "->"
%token <node> DEF "def"
%token <node> WHILE "while"
%token <node> FOR "for"

%token <node> BREAK "break"
%token <node> CONTINUE "continue"
%token <node> RETURN "return"
%token <node> PASS "pass"
%token <node> ASSERT "assert"
%token <node> RAISE "raise"

%token <node> FROM "from"

%token <node> IF "if"
%token <node> ELSE "else"
%token <node> ELIF "elif"

%token <node> AND "and"
%token <node> OR "or"
%token <node> NOT  "not"

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


%type <node> stmts stmt simple_stmt small_stmt expr_stmt annassign test augassign raise_stmt  assert_stmt return_stmt or_test and_test not_test comparison compare_op_bitwise_or_pair eq_bitwise_or noteq_bitwise_or lt_bitwise_or lte_bitwise_or gt_bitwise_or gte_bitwise_or is_bitwise_or in_bitwise_or notin_bitwise_or isnot_bitwise_or expr xor_expr ans_expr shift_expr sum term factor power primary atom if_stmt if_block_left_factored elif_block while_stmt arglist suite funcdef classdef compound_stmt for_stmt exprlist testlist STRING_plus trailer



%start input


%%
input : |
	stmts

stmts : 
	stmt
	| stmts stmt 	

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
	| test "=" test 

annassign: ":"  test "=" test
| ":" test

test: or_test "if" or_test "else" test  
	| or_test 
augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**="

raise_stmt: "raise" | "raise" test "from" test |"raise" test 


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

primary: atom | primary trailer 


atom: NAME 
    | NUMBER 
    | STRING_plus 
    | "True" 
    | "False" 
    | "None" 

STRING_plus: STRING 
	| STRING_plus STRING

trailer: "." NAME
	| "[" testlist "]"
	| "(" testlist ")"

if_stmt: if_block_left_factored		{$$ = new Node ("if"); }
	| if_block_left_factored "else" ":" suite	{ $$ = new Node ("if-else"); }
	| if_block_left_factored elif_block "else" ":" suite

if_block_left_factored: "if" test ":" suite

elif_block: "elif" test ":" suite
	| elif_block "elif" test ":" suite

while_stmt: "while" test ":" suite


arglist: test | arglist "," test 

suite: simple_stmt 
	| NEWLINE  INDENT  stmts DEDENT 

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
	yydebug = 1 ;
	if (argv[1] && argv[1][0] == 'n')
		yydebug = 0;
	if (argc >2 && argv[2] && argv[2][0]) {
		graph = fopen (argv[2], "w+");
		fprintf (graph, "strict digraph ast {\n");
	}
    yyparse();
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
