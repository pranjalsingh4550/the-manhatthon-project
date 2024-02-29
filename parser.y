%{
    #include<bits/stdc++.h>
    #include<unistd.h>
    #include<fcntl.h>
	#include"classes.h"
	#include<fcntl.h>
	#include<sys/stat.h>
	#include<sys/types.h>
    using namespace std; 
	int nodecount=0;
	FILE* graph = NULL;
	FILE* inputfile = NULL;
    extern int yylex();
    extern int yyparse();
    extern void debugprintf (const char *) ;
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	#define YYDEBUG 1
	static Node* rightchild_to_be_added_later;
	const char* edge_string;
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


%type <node> stmts stmt simple_stmt small_stmt expr_stmt test augassign return_stmt or_test and_test not_test comparison compare_op_bitwise_or_pair eq_bitwise_or noteq_bitwise_or lt_bitwise_or lte_bitwise_or gt_bitwise_or gte_bitwise_or is_bitwise_or in_bitwise_or notin_bitwise_or isnot_bitwise_or expr xor_expr ans_expr shift_expr sum term factor power primary atom if_stmt while_stmt arglist suite funcdef classdef compound_stmt for_stmt exprlist testlist STRING_plus trailer typedarglist_comma typedarglist elif_block



%start input


%%
input: start 
	|NEWLINE input { /* assuming no production needed */ }

start :{new Node("Empty file");}| stmts 

stmts : 
	stmt
	| stmts NEWLINE stmt { $$ = new Node ("statements"); $$->addchild($1); $$->addchild($2);}

;

stmt:  simple_stmt 
	| compound_stmt 
;

simple_stmt: small_stmt ";"
	| small_stmt
	| small_stmt ";" simple_stmt {$$ = new Node ("inline statement"); $$->addchild($1);$$->addchild($3);}
;




small_stmt: expr_stmt
	| return_stmt
	| "break" 
	| "continue" 
	| "pass" 
;
expr_stmt: NAME ":" test { 
			$$ = new Node ("Declaration");
			$$->addchild($1, "Name");
			$$->addchild($2, "Type");	
			 }
	| NAME ":" test "=" test {
			$$ = new Node ("Declartion");
			$$->addchild($1, "Name");
			$$->addchild($3, "Type");
			$$->addchild($5, "Value");
	}		
	| test augassign test { 
			$$ = new Node ($2->production.c_str());
			$$->addchild($1);
			$$->addchild($3);
	}
	| test "=" test {
			$$ = new Node ("=");
			$$->addchild($1);
			$$->addchild($3);
	}
	|	test

test: or_test "if" or_test "else" test {
		$$ = new Node ("inline_if_else");
		$$->addchild($1);
		$$->addchild($3);
		$$->addchild($5);
	}
	| or_test
augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**="
/* augassign hs been handled */


return_stmt: "return" test {$1->addchild($2); $$=$1;}
	| "return"

or_test : and_test 
	| or_test "or" and_test { $$ = new Node ("or"); $$->addchild ($1); $$->addchild ($3);}

and_test : not_test
	| and_test "and" not_test { $$ = new Node ("and"); $$->addchild ($1); $$->addchild ($3);}
not_test : comparison
	| "not" not_test	{ $$ = new Node ("not"); $$->addchild ($2);}

comparison: expr  
	| comparison compare_op_bitwise_or_pair	{$$ = $2; $$->addchild ($1);	 $$->addchild (rightchild_to_be_added_later); }	

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

eq_bitwise_or: "==" expr {$$ = new Node("=="); rightchild_to_be_added_later = $2;}
noteq_bitwise_or: "!=" expr {$$ = new Node("!="); rightchild_to_be_added_later = $2;}
lt_bitwise_or: "<" expr {$$ = new Node("<");rightchild_to_be_added_later = $2;}
lte_bitwise_or: "<=" expr {$$ = new Node("<=");rightchild_to_be_added_later = $2;}
gt_bitwise_or: ">" expr {$$ = new Node(">");rightchild_to_be_added_later = $2;}
gte_bitwise_or: ">=" expr {$$ = new Node(">=");rightchild_to_be_added_later = $2;}
is_bitwise_or: "is" expr {$$ = new Node("is");rightchild_to_be_added_later = $2;}
in_bitwise_or: "in" expr {$$= new Node("in");rightchild_to_be_added_later = $2;}
notin_bitwise_or: "not" "in" expr {$$ = new Node("not in");rightchild_to_be_added_later = $2;}
isnot_bitwise_or: "is" "not" expr {$$ = new Node("is not");rightchild_to_be_added_later = $2;}

expr: xor_expr 
	| expr "|" xor_expr { $$ = new Node ("Bitwise OR\n|"); $$->addchild ($1); $$->addchild ($3);}

xor_expr: ans_expr
	| xor_expr "^" ans_expr	{ $$ = new Node ("Bitwise XOR\n^"); $$->addchild ($1); $$->addchild ($3);}

ans_expr: shift_expr 
	| ans_expr "&" shift_expr	{ $$ = new Node ("Bitwise AND\n&"); $$->addchild ($1); $$->addchild ($3);}

shift_expr: sum 
	| shift_expr "<<" sum	{ $$ = new Node ("Left Shift\n<<"); $$->addchild ($1); $$->addchild ($3);}
	| shift_expr ">>" sum	{ $$ = new Node ("Right Shift\n>>"); $$->addchild ($1); $$->addchild ($3);}

sum : sum "+" term  { $$ = new Node ("+"); $$->addchild ($1); $$->addchild($3); }
	| sum "-" term	{ $$ = new Node ("-"); $$->addchild ($1); $$->addchild($3); }
	| term

term: term "*" factor	{ $$ = new Node ("*"); $$->addchild ($1); $$->addchild($3); }
	| term "/" factor	{ $$ = new Node ("/"); $$->addchild ($1); $$->addchild($3); }
	| term "%" factor	{ $$ = new Node ("%"); $$->addchild ($1); $$->addchild($3); }
	| term DOUBLESLASH factor { $$ = new Node ("//"); $$->addchild ($1); $$->addchild($3); }
	|factor	

factor: "+" factor	{ $$ = new Node ("+"); $$->addchild($2); }
	| "-" factor	{ $$ = new Node ("-"); $$->addchild($2); }
	| "~" factor	{ $$ = new Node ("~"); $$->addchild($2); }
	| power

power: primary
	| primary "**" factor	{ $$ = new Node ("**"); $$->addchild($1); $$->addchild($3); }

primary: atom 
	| primary trailer {$$=$2;  $$->addchild($1,"Name");  if (rightchild_to_be_added_later) $$->addchild(rightchild_to_be_added_later,edge_string);}


atom: NAME 
    | NUMBER 	
    | STRING_plus 
    | "True"
    | "False" 
    | "None" 
	| "(" testlist ")" { $$ = $2; $$->rename("Tuple");}
	| "[" testlist "]" { $$ =$2, $$->rename("List"); }

STRING_plus: STRING 
	| STRING_plus STRING { $$ = new Node ("Multi String"); $$->addchild($1); $$->addchild($2);}

trailer: "." NAME {$$=new Node(".");rightchild_to_be_added_later = $2; }
	| "[" testlist "]" {$$=new Node("Subscript");rightchild_to_be_added_later = $2;edge_string = "indices";}
	| "(" testlist ")" {$$=new Node("Function/Method call");rightchild_to_be_added_later = $2; edge_string = "arguments";}
	| "(" ")" {$$=new Node("EMPTY CALL"); rightchild_to_be_added_later = NULL;}

if_stmt: "if" test ":" suite { $$ = new Node ("If block"); $$->addchild($2, "if"); $$->addchild($4, "then");}
	|  "if" test ":" suite elif_block {$$ = new Node ("If else block"); $$->addchild($2, "if"); $$->addchild($4, "then"); $$->addchild($5, "else"); }

elif_block:
	"else" ":" suite	{ $$ = $3; }
	| "elif" test ":" suite	{$$ = new Node ("if"); $$->addchild ($2, "if"); $$->addchild($4, "then"); } /* ok????? fine */ 
	| "elif" test ":" suite elif_block	{$$ = new Node ("if"); $$->addchild ($2, "if"); $$->addchild($4, "then"); $$->addchild ($5, "else"); }

while_stmt: "while" test ":" suite {$$ = new Node ("WHILE"); $$->addchild($2, "condition"); $$->addchild($4, "do");}


arglist:  test 
	| arglist "," test { $$ = new Node ("testlist"); $$->addchild($1); $$->addchild($3);}

typedarglist:  test ":" test { $$ = new Node ("argument"); $$->addchild($1); $$->addchild($3);}
	| typedarglist "," test ":" test {$$ = new Node ("typedarglist"); $$->addchild($1); $$->addchild($3); $$->addchild($5);}
	|	test ":" test "=" test { $$ = new Node ("argument_with_default"); $$->addchild($1); $$->addchild($3); $$->addchild($5);}
	|	typedarglist "," test ":" test "=" test {$$ = new Node ("typedarglist_with_default"); $$->addchild($1); $$->addchild($3); $$->addchild($5); $$->addchild($7);}

typedarglist_comma: typedarglist | typedarglist ","

suite: simple_stmt { $$ = $1;}
	| NEWLINE  INDENT  stmts DEDENT {$$=$3;} 

funcdef: "def" NAME "(" typedarglist_comma ")" "->" test ":" suite { $$ = new Node ("FUNC DEFN"); $$->addchild($2, "name"); $$->addchild($4, "arguments"); $$->addchild($7, "return type"); $$->addchild($9, "body");}
	| "def" NAME "(" ")" "->" test ":" suite { $$ = new Node ("FUNC DEFN"); $$->addchild($2, "name"); $$->addchild($6, "return type"); $$->addchild($8, "body");}
	| "def" NAME "(" typedarglist_comma ")" ":" suite { $$ = new Node ("FUNC DEFN"); $$->addchild($2, "name"); $$->addchild($4, "arguments"); $$->addchild($7, "body");}
	| "def" NAME "(" ")" ":" suite {$$ = new Node ("FUNC DEF"); $$->addchild($2, "name");$$->addchild($6, "body");}


classdef: "class" NAME ":"  suite { $$ = new Node ("CLASS DEFN"); $$->addchild($2, "name"); $$->addchild($4, "attributes");}
	| "class" NAME "(" typedarglist_comma ")" ":" suite { $$ = new Node ("CLASS DEFN"); $$->addchild($2, "name"); $$->addchild($4, "arguments"); $$->addchild($7,"attributes");}
	| "class" NAME "(" ")" ":" suite { $$ = new Node ("CLASS DEFN"); $$->addchild($2, "name"); $$->addchild($5, "attributes");}


compound_stmt: 
	if_stmt
	| while_stmt
	| for_stmt
	| funcdef
	| classdef

for_stmt: "for" exprlist "in" testlist ":" suite "else" ":" suite { $$ = new Node ("For block"); $$->addchild($2); $$->addchild($4); $$->addchild($6); $$->addchild($9);}                        
        | "for" exprlist "in" testlist ":" suite  { $$ = new Node ("For Block"); $$->addchild($2,"iterator"); $$->addchild($4,"object"); $$->addchild($6,"body");}                                    
exprlist: expr
        | expr ","
		| expr "," exprlist { $$ = new Node ("exprlist"); $$->addchild($1); $$->addchild($3);}
testlist: arglist
        | arglist ","
;

%%

int main(int argc, char** argv){
	yydebug = 0;
	int input_fd = -1;
	char *outputfile = (char *) malloc (128);
	sprintf (outputfile, "ast.dot");

	// command line options
	// now points to first command line option
	for(int i=1;i<argc;i++){
		if (strcmp (argv[i], "-input") == 0) { // input file - replace stdin with it
			if (argv[i+1] == NULL) {
				fprintf (stderr, "Missing argument: -input must be followed by input file. stdin if not specified\n");
				return 1;
			}
			input_fd = open (argv[i+1], O_RDONLY);
			if (input_fd < 0) {
				fprintf (stderr, "Invalid input file name: %s\n", argv[i+1]);
				return 1;
			}
			close(0);
			dup (input_fd);
			cout << "input file: " << argv[i+1] << endl;
		}
		if (strcmp(argv[i], "-output") == 0) { // outpur file name, default ast.dot
			if (argv[i+1] == NULL) {
				fprintf (stderr, "Missing argument: -output must be followed by output file name\n");
				return 1;
			}
			if (strlen (*(argv+1)) > 127) {
				fprintf (stderr, "Output file name too long. Max 128 characters\n");
				return 1;
			}
			sprintf (outputfile, "%s", argv[i+1]);
		}
		if (strcmp(argv[i], "-verbose") == 0) {
			printf ("Printing parser logs to stderr\n");
			yydebug = 1;
		}
		if (strcmp (argv[i], "-help") == 0) {
			printf ("This is a basic python compiler made by Dev*\nCommand-line options:\n\t-input:\t\tInput file (default - standart input console. Use Ctrl-D for EOF)\n\t-output:\tOutput file (default: ast.dot; overwritten if exists)\n\t-verbose:\tPrint debugging information to stderr\n\t-help:\t\tPrint this summary\n" );
			return 0;
		}
	}
	
	graph = fopen (outputfile, "w+");
	fprintf (graph, "strict digraph ast {\n");

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
