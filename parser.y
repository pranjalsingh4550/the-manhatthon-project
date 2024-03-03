%define parse.lac full 
%define parse.error detailed
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
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	#define YYDEBUG 1
	static Node* later;
	const char* edge_string;
	int stderr_dup;
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
%token <node> LBRACE "{"
%token <node> RBRACE "}"



%token <node> NUMBER
%token <node> STRING
%token <node> TRUE "True"
%token <node> FALSE "False"
%token <node> NONE "None"

%type <node> start stmts stmt simple_stmt small_stmt expr_stmt test augassign return_stmt or_test and_test not_test comparison expr xor_expr ans_expr shift_expr sum term factor power primary atom if_stmt while_stmt arglist suite funcdef classdef compound_stmt for_stmt exprlist testlist STRING_plus trailer typedarglist_comma typedarglist elif_block typedargument argument 

%start program


%%
program : input | program INDENT

input: start 
	| NEWLINE input

start :{$$=new Node("Empty file");} | stmts {$$= new Node("Start"); $$->addchild($1);}

stmts : 
	stmt
	| stmt stmts { $$ = new Node ("Statements"); $$->addchild($1); $$->addchild($2);}

;

stmt:  simple_stmt 
	| compound_stmt 
;

simple_stmt: small_stmt ";" NEWLINE
	| small_stmt NEWLINE
	| small_stmt ";" simple_stmt {$$ = new Node ("Inline Statement"); $$->addchild($1);$$->addchild($3);}
;




small_stmt: expr_stmt
	| return_stmt
	| "break" 
	| "continue" 
	| "pass" 
;
expr_stmt: test ":" test { 
			$$ = new Node ("Declaration");
			$$->addchild($1, "Name");
			$$->addchild($3, "Type");	
	}
	| test ":" test "=" test {
			$$ = new Node ("Declaration");
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
	| test

test: or_test "if" or_test "else" test {
		$$ = new Node ("Inline If Else");
		$$->addchild($1,"Value");
		$$->addchild($3,"if");
		$$->addchild($5,"else");
	}
	| or_test
augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**="


return_stmt: "return" test {$1->addchild($2,"Data"); $$=$1;}
	| "return" {string temp = "Keyword\n"; temp += "( return )"; $$ = new Node(temp);}

or_test : and_test 
	| or_test "or" and_test { $$ = new Node ("or"); $$->addchild ($1); $$->addchild ($3);}

and_test : not_test
	| and_test "and" not_test { $$ = new Node ("and"); $$->addchild ($1); $$->addchild ($3);}
not_test : comparison
	| "not" not_test	{ $$ = new Node ("not"); $$->addchild ($2);}

comparison: expr  
	| comparison "==" expr	{ $$ = new Node ("=="); $$->addchild ($1); $$->addchild ($3);}
	| comparison "!=" expr	{ $$ = new Node ("!="); $$->addchild ($1); $$->addchild ($3);}
	| comparison "<" expr	{ $$ = new Node ("<"); $$->addchild ($1); $$->addchild ($3);}
	| comparison "<=" expr	{ $$ = new Node ("<="); $$->addchild ($1); $$->addchild ($3);}
	| comparison ">" expr	{ $$ = new Node (">"); $$->addchild ($1); $$->addchild ($3);}
	| comparison ">=" expr	{ $$ = new Node (">="); $$->addchild ($1); $$->addchild ($3);}
	| comparison "is" expr	{ $$ = new Node ("is"); $$->addchild ($1); $$->addchild ($3);}
	| comparison "in" expr	{ $$ = new Node ("in"); $$->addchild ($1); $$->addchild ($3);}
	| comparison "not" "in" expr	{ $$ = new Node ("not in"); $$->addchild ($1); $$->addchild ($4);}
	| comparison "is" "not" expr	{ $$ = new Node ("is not"); $$->addchild ($1); $$->addchild ($4);}


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

factor: "+" factor	{ $$ = new Node ("+"); $$->addchild($2);}
	| "-" factor	{ $$ = new Node ("-"); $$->addchild($2);}
	| "~" factor	{ $$ = new Node ("~"); $$->addchild($2);}
	| power

power: primary
	| primary "**" factor	{ $$ = new Node ("**"); $$->addchild($1); $$->addchild($3); }

primary: atom 
	| primary trailer {$$=$2;  $$->addchild($1,"Primary");  if (later) $$->addchild(later,edge_string);}


atom: NAME 
    | NUMBER 	
    | STRING_plus 
    | "True"
    | "False" 
    | "None" 
	| "(" testlist ")" {
		 $$ = $2;
		 string temp;
		 temp +="(  ) Contained\n";
		 temp += $2->production;
	 $$->rename(temp);
	 }
	
	| "[" testlist "]" {
		 $$ = $2;
		 string temp;
		 temp +="[  ] Contained\n";
		 temp += $2->production;
	 $$->rename(temp);
	 }
	| "{" testlist "}" {
		 $$ = $2;
		 string temp;
		 temp +="{  } Contained\n";
		 temp += $2->production;
	 $$->rename(temp);
	 }
	| "("")" { $$ = new Node ("Empty Tuple"); $1=new Node("Delimeter\n(");$2=new Node("Delimeter\n)"); $$->addchild($1); $$->addchild($2);}
	| "[" "]" { $$ = new Node ("Empty List"); $1=new Node("Delimeter\n[");$2=new Node("Delimeter\n]"); $$->addchild($1); $$->addchild($2);}

STRING_plus: STRING 
	| STRING_plus STRING { $$ = new Node ("Multi String"); $$->addchild($1); $$->addchild($2);}

trailer: "." NAME {$$=new Node(".");later = $2;edge_string = "Refers";}
	| "[" testlist "]" {$$=new Node("Subscript");later = $2;edge_string = "Indices";}
	| "(" testlist ")" {$$=new Node("Function/Method call");later = $2; edge_string = "Arguments";}
	| "(" ")" {$$=new Node("Function/Method call"); later = NULL;}

if_stmt: "if" test ":" suite { $$ = new Node ("If Block"); $$->addchild($2, "If"); $$->addchild($4, "Then");}
	|  "if" test ":" suite elif_block {$$ = new Node ("If Else Block"); $$->addchild($2, "If"); $$->addchild($4, "Then"); $$->addchild($5, "Else"); }

elif_block:
	"else" ":" suite	{ $$ = $3;}
	| "elif" test ":" suite	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($4, "Then"); } /* ok????? fine */ 
	| "elif" test ":" suite elif_block	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($4, "Then"); $$->addchild ($5, "Else"); }

while_stmt: "while" test ":" suite {$$ = new Node ("While"); $$->addchild($2, "Condition"); $$->addchild($4, "Do");}



arglist: argument
	| arglist "," argument { $$ = new Node ("Multiple terms"); $$->addchild($1); $$->addchild($3);}


argument: test
	| test "=" test { $$ = new Node ("="); $$->addchild($1,"Name"); $$->addchild($3,"Default");}

typedarglist:  typedargument
	| argument
	| typedarglist "," argument  { $$ = new Node ("Multiple Terms"); $$->addchild($1); $$->addchild($3);}
	| typedarglist "," typedargument { $$ = new Node ("Multiple Terms"); $$->addchild($1); $$->addchild($3);}

typedarglist_comma: typedarglist | typedarglist ","

typedargument: test ":" test { $$ = new Node ("Typed Parameter"); $$->addchild($1,"Name"); $$->addchild($3,"Type");}
	| test ":" test "=" test { $$ = new Node ("Typed Parameter"); $$->addchild($1,"name"); $$->addchild($3,"Type"); $$->addchild($5,"Default");}

suite: simple_stmt { $$ = $1;}
	| NEWLINE  INDENT  stmts DEDENT {$$=$3;} 

funcdef: "def" NAME "(" typedarglist_comma ")" "->" test ":" suite { $$ = new Node ("Function Defn"); $$->addchild($2, "Name"); $$->addchild($4,"Parameters"); $$->addchild($7, "Return type"); $$->addchild($9, "Body");}
	| "def" NAME "(" ")" "->" test ":" suite { $$ = new Node ("Function Defn"); $$->addchild($2, "Name"); $$->addchild($6, "Return type"); $$->addchild($8, "Body");}
	| "def" NAME "(" typedarglist_comma ")" ":" suite { $$ = new Node ("Function Defn"); $$->addchild($2, "Name"); $$->addchild($4,"Parameters"); $$->addchild($7, "Body");}
	| "def" NAME "(" ")" ":" suite {$$ = new Node ("Function Defn"); $$->addchild($2, "Name");$$->addchild($6, "Body");}


classdef: "class" NAME ":"  suite { $$ = new Node ("Class"); $$->addchild($2, "Name"); $$->addchild($4, "Contains");}
	| "class" NAME "(" typedarglist_comma ")" ":" suite { $$ = new Node ("Class"); $$->addchild($2, "Name"); $$->addchild($4, "Inherits"); $$->addchild($7,"Contains");}
	| "class" NAME "(" ")" ":" suite { $$ = new Node ("Class"); $$->addchild($2, "Name"); $$->addchild($6, "Contains");}


compound_stmt: 
	if_stmt
	| while_stmt
	| for_stmt
	| funcdef
	| classdef

for_stmt: "for" exprlist "in" testlist ":" suite "else" ":" suite { $$ = new Node ("For block"); $$->addchild($2); $$->addchild($4); $$->addchild($6); $$->addchild($9);}                        
        | "for" exprlist "in" testlist ":" suite  { $$ = new Node ("For Block"); $$->addchild($2,"Iterator"); $$->addchild($4,"Object"); $$->addchild($6,"Body");}                                    
exprlist: expr
        | expr ","
		| expr "," exprlist { $$ = new Node ("Mutiple terms"); $$->addchild($1); $$->addchild($3);}
testlist: arglist
        | arglist ","
;

%%



int main(int argc, char** argv){
	yydebug = 0;
	int input_fd = -1;
	stderr_dup = -1;
	int stderr_redirect = -1;
	int stderr_copy = -1;
	int stderr_pipe[2];
	int pread, pwr;
	int verbosity = 0; // 1 for shift, 2 for reduce, 1|2 for both
	char *outputfile = (char *) malloc (128);
	sprintf (outputfile, "ast.dot");

	char verbositym[] = "\t-verbose shift\tList all shift operations\n\t-verbose reduce\tList all reduce operations\n\t-verbose sr\tList shift and reduce operations\n\t-verbose all\tCopy the entire debugger log\n\t-verbose srla\tPrint shift, reduce and lookahead logs\n";

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
		else if (strcmp(argv[i], "-output") == 0) { // outpur file name, default ast.dot
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
		else if (strcmp(argv[i], "-verbose") == 0) {
			fprintf (stderr, "Printing parser logs to stderr\n.debuglog will be overwritten.\n");
			yydebug = 1;
			// set the verbosity variable, 3 for now;
			if (argv[i+1] == NULL) {
				fprintf (stderr, "Specify the verbosity level\n%s", verbositym);
				return 1;
			} else if (strcmp (argv[i+1], "shift") == 0) verbosity = 1;
			else if (strcmp (argv[i+1], "reduce") == 0) verbosity = 2;
			else if (strcmp (argv[i+1], "all") == 0) verbosity = 4;
			else if (strcmp (argv[i+1], "sr") == 0) verbosity = 3;
			else if (strcmp (argv[i+1], "srla") == 0) verbosity = 11;
			else {
				fprintf (stderr, "Specify the verbosity level\n%s", verbositym);
				return 1;
			}
			stderr_copy = dup(2); // use later
			close(2);
			stderr_dup = creat (".debuglog", S_IRUSR|S_IWUSR);
			// printf ("stderr dup is %d\n", stderr_dup);
			if (stderr_dup - 2)
				return 1;
		}
		else if (strcmp (argv[i], "-help") == 0) {
			printf ("This is a basic python compiler made by Dev*\nCommand-line options:\n\t-input:\t\tInput file (default - standart input console. Use Ctrl-D for EOF)\n\t-output:\tOutput file (default: ast.dot; overwritten if exists)\n\t-verbose:\tPrint debugging information to stderr\n\t-help:\t\tPrint this summary\nVerbosity flags: (no default value)\n%s", verbositym );
			return 0;
		}
	}
	if (verbosity == 0) {
		stderr_dup = dup (2);
	}
	
	graph = fopen (outputfile, "w+");
	fprintf (graph, "strict digraph ast {\n");

	yyparse();
	if (graph) {
		fprintf (graph, "}\n");
		fclose (graph);
	}
	
	char *line = NULL;
	size_t n = 0;
	FILE* logs;
	if (verbosity) {
		close (stderr_dup);
		logs = fopen (".debuglog", "r");
		int count = 0;

		while (getline (&line, &n, logs) > 0) {
			if (line[0] == 'S' && line[1] == 'h' && (verbosity & 1))
				dprintf (stderr_copy, "%s", line);
			if (strncmp (line, "Reducing", 7) == 0 && (verbosity & 2))
				dprintf	(stderr_copy, "%s", line);
			if (strncmp (line, "-> $$ =", 7) == 0 && (verbosity & 2))
				dprintf	(stderr_copy, "%s", line);
			if ((verbosity & 4))
				dprintf (stderr_copy, "%s", line);
			if ((strncmp (line, "Next token", 10) == 0) && (verbosity & 8))
				dprintf (stderr_copy, "%s", line);

			line = NULL; n = 0;
		}
		dprintf (stderr_copy, "Deleting .debuglog\n");
		unlink (".debuglog");
		fclose (logs);
	}
    return 0;
}




int yyerror(const char *s){
    // cerr<<"Error: "<<s<<" at line number: "<<yylineno<<endl;
    dprintf (stderr_dup, "Error %s at line number %d.\n", s, yylineno);
    return 0;
}
