%define parse.lac full 
%define parse.error detailed
%{
    #include<bits/stdc++.h>
    #include<unistd.h>
    #include<fcntl.h>
	#include"classes.hpp"
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
	static Node* later;
	const char* edge_string;
	int stderr_dup, stderr_copy;
	bool inside_init = false;
	SymbolTable* top, *globalSymTable, *current_scope;
	Symbol::Symbol (string name, string typestring, int lineno, int flag, SymbolTable* cur_symboltable) {
		//
		name = name;
		typestring = typestring;
		lineno = (ull) lineno;
		if (flag == FUNCTION_ST || flag == MEMBER_FN_ST)
			isFunction = true;
		if (flag == CLASS_ST)
			isClass = true;
		// fill dimension in parser
		// if (typestring == "" || cur_symboltable->classes.find(typestring)==cur_symboltable->classes.end()) {
		// 	cerr << "Undeclared type in line " << lineno << endl; // mroe details
		// 	exit(1); // or call error
		// }
		if (typestring != "class")
			size = cur_symboltable->children[typestring]->size;
		else {
			if (typestring == "bool" || typestring == "float" || typestring == "int") {
				size = 8;
			} else if (typestring == "complex" || typestring == "str") {
				size = 16;
			}
		}
		offset = cur_symboltable->table_size;
		cur_symboltable->table_size += size;

	}
	void put(Node* n1, Node* n2){
		top->put(n1, n2);
	}
	void check(Node* n){
		// for literals, return directly
		if (!n) exit (printf ("line 59 Node is NULl"));
		if (n->typestring == "int") return;
		if (n->typestring == "bool") return;
		if (n->typestring == "str") return;
		if (n->typestring == "float") return;
		if (n->typestring == "complex") return;
		if (!n->isLeaf) return ;
		if(!top->has(n)){
			fprintf(stderr, "NameError: name %s is not defined\n", n->production.c_str());
			exit(1);
		}
	}
	bool check(Node* n1, Node* n2){
		if(n1->typestring != n2->typestring){
			return false;
		}
		return true;
	}
	int Funcsuite=0;
	int Classsuite=0;
	static Node* name;
	string return_type="None";
	static Node* params;
	// void merge(){
	// 	top_function = (FunctionTable*)top;
	// 	top_class = (ClassTable*)top;
	// 	top_global = (GlobalTable*)top;
	// }
	void newscope(string name){
		if(Funcsuite){
	// 		top_function= new FunctionTable(top);
	// 		top_function->inClass=Classsuite;
			if(Classsuite){
				top = new SymbolTable (top, MEMBER_FN_ST, name);
	// 			ClassTable* temp=(ClassTable*)top_function->parent;
	// 			temp->functions[name->production]=top_function;

			}
			else
				top = new SymbolTable (top, FUNCTION_ST, name);
			/*
			top_function->name=name->production;
			top_function->return_type=return_type;
			for(auto child:params->children){
				// top_function->symbols[child->production];
				top_function->arg_types.push_back(child->typestring);
			}
			top=top_function;
			*/
		}
		else if (Classsuite){
			top = new SymbolTable (top, CLASS_ST, name);
			/*
			top_class = new ClassTable(top);
			top_class->name=name->production;
			top=top_class;
			merge();
			*/
		}
		else{
			top = new SymbolTable(top);
	// 		merge();
		}
	}
	void endscope(){
		top = top->parent;
		// merge();	
	}
	// Symbol* lookup(string name){
	// 	SymbolTable* temp = top;
	// 	while(temp){
	// 		if(temp->contains(name)){
	// 			return temp->lookup(name);
	// 		}
	// 		temp = temp->parent;
	// 	}
	// 	return NULL;
	// }
	// void add_symbol(Node* name, int type){
	// 	if(top->contains(name->production)){
	// 		fprintf(stderr, "Error: Variable %s already declared\n", name->production.c_str());
	// 		exit(1);
	// 	}
	// 	top->add_symbol(name, (datatypes)type);
	// }
	// // void update(Node* name, int type){
	// // 	if(!top->contains(name->production)){
	// // 		add_symbol(name, (datatypes)type);
	// // 	}
	// // 	// top->update(name, type);
	// // }
#define TEMPDEBUG 1
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
%token <node> GLOBAL "global"

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



%token <node> NUMBER
%token <node> STRING
%token <node> TRUE "True"
%token <node> FALSE "False"
%token <node> NONE "None"

%type <node> start stmts stmt simple_stmt small_stmt expr_stmt test augassign return_stmt and_test not_test comparison expr xor_expr ans_expr shift_expr sum term factor power primary atom if_stmt while_stmt arglist suite basesuite funcdef classdef compound_stmt for_stmt testlist STRING_plus  typedarglist_comma typedarglist elif_block typedargument global_stmt

%start program


%%
program : {printf("now\n");}input | program INDENT

input: start 
	| NEWLINE input

start :{$$=new Node("Empty file");} | stmts[first] {$$= new Node("Start"); $$->addchild($first);}

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
	| global_stmt 
;

/* TO DO  dealing with global */

global_stmt: "global" NAME 
	| global_stmt "," NAME  { $$ = new Node ("Multiple Global"); $$->addchild($1); $$->addchild($3);}

expr_stmt: test ":" test { 
			put($1,$3);
			$$ = new Node ("Declaration");
			$$->addchild($1, "Name");
			$$->addchild($3, "Type");
	}
	| test ":" test "=" test {
			put($1,$3); 
			$$ = new Node ("Declaration");
			$$->op = MOV_REG;
			$$->addchild($1, "Name");
			$$->addchild($3, "Type");
			$$->addchild($5, "Value", $1);

	}		
	| test augassign test { 
			check($1);
			check($3);
			if(!check($1,$3)){
				fprintf(stderr, "Type Error: %s and %s are not of same type\n", $1->production.c_str(), $3->production.c_str());
				exit(1);
			}
			$$ = new Node ($2->production);
			$$->addchild($1);
			$$->addchild($3);
			$$->typestring = $1->typestring;
			$$->lineno = $1->lineno;
	}
	| test "=" test{
		check ($1);
		check($3);
		top->get($1)->typestring= $3->typestring;
	}
	| test {check($1);$$=$1;}

augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**="

return_stmt: "return" test {check($2);$1->addchild($2,"Data"); $$=$1;}
	| "return" {string temp = "Keyword\n"; temp += "( return )"; $$ = new Node(temp);}

test : and_test 
	| test "or" and_test { $$ = new Node ("or"); $$->addchild ($1); $$->addchild ($3);}

and_test : not_test
	| and_test "and" not_test { $$ = new Node ("and"); $$->addchild ($1); $$->addchild ($3);}
not_test : comparison
	| "not" not_test	{ $$ = new Node ("not"); $$->addchild ($2);}

comparison: expr  
	| expr "==" comparison	{ $$ = new Node ("=="); $$->addchild ($1); $$->addchild ($3);}
	| expr "!=" comparison	{ $$ = new Node ("!="); $$->addchild ($1); $$->addchild ($3);}
	| expr "<" comparison	{ $$ = new Node ("<"); $$->addchild ($1); $$->addchild ($3);}
	| expr "<=" comparison	{ $$ = new Node ("<="); $$->addchild ($1); $$->addchild ($3);}
	| expr ">" comparison	{ $$ = new Node (">"); $$->addchild ($1); $$->addchild ($3);}
	| expr ">=" comparison	{ $$ = new Node (">="); $$->addchild ($1); $$->addchild ($3);}
	| expr "is" comparison	{ $$ = new Node ("is"); $$->addchild ($1); $$->addchild ($3);}
	| expr "in" comparison	{ $$ = new Node ("in"); $$->addchild ($1); $$->addchild ($3);}
	| expr "not" "in" comparison	{ $$ = new Node ("not in"); $$->addchild ($1); $$->addchild ($4);}
	| expr "is" "not" comparison	{ $$ = new Node ("is not"); $$->addchild ($1); $$->addchild ($4);}


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

/* TO DO 
	Complete typechecking and attribute scope checking for each primary symbol expansion

*/

/*

	ALL CASES
	global()
	globalclass_ctor()
	globalclass_object.attr
	globalclass.class_instance.attribute.another_instance
	globalclass.class_instance.attribute.another_instance.member_fn()
	something[2].something_else

plan: SymbolTable* current maintains a  pointer to the top of the current production.
in primary->primary.NAME, if name is a class instance, we update current_scope to the class
on reading "my_cpp_map" "." "find", we set current_scope to find, anticipating an incoming "()"
current_scope is NULL everywhere else
	// or do we set it to top everywhere else?
every function that sets current_scope must check that someone frees it
helper functions:	SymbolTable.has() checks for variables in scope: stack variables and class attributes
			SymbolTable.has_children() checks for member functions/global functions and classes inside global namespace
*/


/* changes to be made later using :s
#define pp1 $1->production
#define pp3 $3->production
#define ll3 $3->lineno
#define tt1 $1->typestring
#define tt3 $3->typestring
*/

primary: atom {
	}
	| primary "." NAME {
		// primary:	leaf or compound or self
		// NAME:	member function or attribute
		// upon entry, primary.typestring is set to the corresponding value, whether "def", "class", "myclass", etc.
		// question: do we even need cur_symbol_whatever?

		SymbolTable* pscope = globalSymTable->find_class($1->typestring);

		if (!pscope) {
			if ($1->typestring!= "def")
				dprintf (stderr_copy, "Error at line %d: object of type %s does not have attribute %s\n", $3->lineno, $1->typestring, $3->production);
			else 
				dprintf (stderr_copy, "Error at line %d: object of type Function does not have attribute %s\n", $3->lineno, $3->production);
			exit(1);
		}
		SymbolTable* NAME_scope = pscope->find_member_fn($3->production);
		if (NAME_scope) {
			$$->typestring = "def";
		}
		NAME_scope = globalSymTable->find_class($3->typestring);
		if (NAME_scope) {
			$$->typestring = NAME_scope->name;
		}
		pscope->symbols.find($3->production);
		if (pscope->symbols.find($3->production) != pscope->symbols.end()) {
			$$->typestring = pscope->symbols.find($3->production)->second->name;
		}
		if ($1->production == "self") {
			// this is the only occurence of declarations of the sort a.b:type = *. all other attributes to self are pre-defined class instances
			// may also be a use in the rhs
			// as good as any pointer to any other class element
			// INCOMPLETE
		}
		else {
			dprintf (stderr_copy, "Error at line %d: Object of type %s does not have attribute %s\ncheck the grammar here\n", $3->lineno, $1->typestring, $3->production);
			exit(1);
		}
	}
	| primary "[" test "]" {
	}



/*

primary: atom {
	}
	| primary "." NAME 
		{
			// primary:	leaf or compound or self
			// NAME:	member function or attribute
			if ($1->isLeaf && !top->has($1)) {
				dprintf (stderr_copy, "Error undeclared object %s at line %d", $1->production, $3->lineno);
				exit (1);
			}

			if (current_scope == NULL) {
				// have not assumed $1 is a string.
				SymbolTable * search_result = globalSymTable->find_child($1->typestring);
				if (search_result && search_result->isClass)
					current_scope = search_result;
				else if (search_result) // it is a function. hardcoding because we've saved functions with typestring = "def"
					dprintf (stderr_copy, "Error at line %d: object of type function does not have attribute %s\n", $3->lineno, $1->typestring, $3->production);
				else
					dprintf (stderr_copy, "Error at line %d: object of type %s does not have attribute %s\n", $3->lineno, $1->typestring, $3->production);
				if (current_scope == NULL)
					exit(1);
			}

			// check if primary is a valid scope. assume current_scope is correctly maintained.
			if (current_scope) {
				if (inside_init && $1->production== "self") { // create this var
					top->put($3, NULL);
				} else if ($1->production == "self") {
					dprintf (stderr_copy, "Error at line %d: 'self' keyword cannot be used outside __init__() constructor declarations\n", $1->lineno);
					exit(1);
				}

				if (current_scope->has($3->production)) { // primitive attribute of primary
					current_scope = NULL;
					// fill the reference here
					$$->typestring = $3->typestring;
				} else if (current_scope->find_child($3->production)) { // is an attrribute class/method
					if (current_scope->isClass)
						current_scope = current_scope->find_child($3->production);
						// make the 3ac stuff
					else if (current_scope->find_child($3->production)->isFunction) {
						// prepare for function call
						current_scope = current_scope->find_child ($3->production);
					}
					else
						exit (printf ("shouldn't have reached this line\n"));
				}
				else {
					dprintf (stderr_copy, "Error at line %d: class %s not have attribute/method %s\n", $3->lineno, $1->typestring, $3->production);
					exit(1);
				}
			}
			else {
				dprintf (stderr_copy, "Error at line %d: reference to attribute %s of primitive object of type %s\n", $3->lineno, $3->production, $1->typestring);
				exit(1);
			}
		}
		/*
			if(primary is leaf and primary is not in current symboltable)error
			if(NAME is not in GlobalSymTable->classes[primary->typestring]) error

			update $$->typestring as GlobalSymTable->classes[primary->typestring]->typestring
		
		*

	| primary "[" test "]"
		{
			if ($1->isLeaf && !top->has($1)) {
				dprintf (stderr_copy, "Error undeclared object %s at line %d", $1->production, $3->lineno);
				exit (1);
			}
			if ($1->dimension == 0) {
				dprintf (stderr_copy, "Error at line %d: %s object is not subscriptable.\n",
						yylineno, $1->typestring);
				exit (1);
			}
			if ($3->typestring != "int") {
				dprintf (stderr_copy, "Error at line %d: index is not an integer\n",
						yylineno, $3->production);
				exit (1);
			}
			// if primary is out of bounds: run time error right?
			// reminder: in 3ac, check bounds
			$$->typestring = $1->typestring;
		}
				
		/*
			if(primary is leaf and primary is not in symboltable)error
			if(primary dimension is 0) error
			if(test->typestring is not int) error
			if (test is out of bounds) error
			update $$->typestring as primary->typestring
		
		*
	| primary "(" testlist ")" 
		/* 
			if primary is leaf and primary is not in symboltable)error
			if(primary is not a function) error
			if(primary->arg_types.size() != testlist->children.size()) error
			for i in range(primary->arg_types.size())
				if(primary->arg_types[i] != testlist->children[i]->typestring) error
			update $$->typestring as return type of function

			
		*
		{
			if ($1->isLeaf && !top->has($1)) {
				dprintf (stderr_copy, "Error at line %d: declared object %s",
					       	$3->lineno, $1->production); // is $3->lineno maintained?
				exit (1);
				// what about a.b(c)?
			}
			SymbolTable* thisscope = 
				globalSymTable->children[$1->typestring];
			if (thisscope == NULL)
			{
				// error
			}
			if (thisscope->isClass)


			// SymbolTable* thisfn = thisscope->find($1->production); // 
			$$->typestring = $3->typestring;
		}
	
	| primary "(" ")"
		/* 
			if primary is leaf and primary is not in symboltable)error
			if(primary is not a function) error
			if(primary->arg_types.size() != 0) error
			update $$->typestring as return type of function

		 */



/* TO DO 
	Pass the lineno, datatype from the lexer through node
*/
atom: NAME 
    | NUMBER 	
    | STRING_plus 
    | "True"
    | "False" 
    | "None" 
	| "[" testlist "]" {
		 $$ = $2;
		 string temp;
		 temp +="[  ] Contained\n";
		 temp += $2->production;
	 	$$->rename(temp);
	 }
	| "[" "]" { $$ = new Node ("Empty List"); $1=new Node("Delimeter\n[");$2=new Node("Delimeter\n]"); $$->addchild($1); $$->addchild($2);}

STRING_plus: STRING 
	| STRING_plus STRING { $$ = new Node ("Multi String"); $$->addchild($1); $$->addchild($2);}

if_stmt: "if" test ":" basesuite { $$ = new Node ("If Block"); $$->addchild($2, "If"); $$->addchild($4, "Then");}
	|  "if" test ":" basesuite elif_block {$$ = new Node ("If Else Block"); $$->addchild($2, "If"); $$->addchild($4, "Then"); $$->addchild($5, "Else"); }

elif_block:
	"else" ":" basesuite	{ $$ = $3;}
	| "elif" test ":" basesuite	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($4, "Then"); } /* ok????? fine */ 
	| "elif" test ":" basesuite elif_block	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($4, "Then"); $$->addchild ($5, "Else"); }

while_stmt: "while" test ":" basesuite {$$ = new Node ("While"); $$->addchild($2, "Condition"); $$->addchild($4, "Do");}



arglist: test
	| arglist "," test { $$ = new Node ("Multiple terms"); $$->addchild($1); $$->addchild($3);}



typedarglist:  typedargument {/*top->arguments push*/}
	| test {/*this pointer in case inClass==1 otherwise error*/}
	| typedarglist "," typedargument { $$ = new Node ("Multiple Terms"); $$->addchild($1); $$->addchild($3);}

typedarglist_comma: typedarglist | typedarglist ","

typedargument: test ":" test { $$ = new Node ("Typed Parameter"); $$->addchild($1,"Name"); $$->addchild($3,"Type");}
	| test ":" test "=" test { $$ = new Node ("Typed Parameter"); $$->addchild($1,"name"); $$->addchild($3,"Type"); $$->addchild($5,"Default");}

suite:  simple_stmt[first] 
	| NEWLINE  INDENT  stmts[third] DEDENT 

basesuite: {newscope("dummy");} simple_stmt[first] {endscope();}
	| {newscope("dummy");}NEWLINE  INDENT  stmts[third] DEDENT {endscope();}
/* when using multiple mid-rule actions avoid using $1, $2, $3 as its more rigid to code changes*/
/* use common non terminal (like functionstart here) to use mid-rule actions if getting reduce reduce error( which occurs if two rules have the same prefix till the code segment and the lookahead symbol after the code is also same)  */


funcdef: "def" NAME[name]  functionstart "(" typedarglist_comma[param] ")" "->" test[ret] ":" suite[last] {
		Funcsuite=0;
		$$ = new Node ("Function Defn");
		$$->addchild($name, "Name");
		$$->addchild($param,"Parameters");
		$$->addchild($ret, "Return type");
		$$->addchild($last, "Body");
	}
	| "def" NAME[name] functionstart "(" ")" "->" test[returntype] ":" suite[last] {
	       	Funcsuite=0;
	       	$$ = new Node ("Function Defn"); $$->addchild($name, "Name");
	       	$$->addchild($returntype, "Return type");
	       	$$->addchild($last, "Body");
	}
	| "def" NAME[name] functionstart "(" typedarglist_comma[param] ")" ":" suite[last] {
	       	Funcsuite=0;
	       	$$ = new Node ("Function Defn");
	       	$$->addchild($name, "Name");
	       	$$->addchild($param,"Parameters");
	       	$$->addchild($last, "Body");
	}
	| "def" NAME[name] functionstart "(" ")" ":" suite[last] {
	       	Funcsuite=0;
		$$ = new Node ("Function Defn");
		$$->addchild($name, "Name");
		$$->addchild($last, "Body");
	}

functionstart:  {
#if TEMPDEBUG
	printf("start function scope\n");
	printf("scope name= %s\n", $<node>0->production.c_str());
#endif
	Funcsuite = 1;
	if (Classsuite)
		newscope($<node>0->production);
	else 
		newscope($<node>0->production);
	}
;
classdef: "class" NAME classstart ":"  suite[last] {
		  Classsuite=0;
		  $$ = new Node ("Class");
		  $$->addchild($2, "Name");
		  $$->addchild($last, "Contains");
	  }
	| "class" NAME classstart "(" NAME[parent] ")" ":" suite[last] {
	       	Classsuite=0;
	       	$$ = new Node ("Class");
	       	$$->addchild($2, "Name");
	       	$$->addchild($parent, "Inherits");
	       	$$->addchild($last,"Contains");
	}
	| "class" NAME classstart "(" ")" ":" suite[last] {
	       	Classsuite=0;
	       	$$ = new Node ("Class");
	       	$$->addchild($2, "Name");
	       	$$->addchild($last, "Contains");
	}

classstart:	{
#if TEMPDEBUG
	printf ("start class scope");
	printf ("scope name %s\n", $<node>0->production.c_str());
#endif
	newscope ($<node>0->production);
	Classsuite = 1;
}

compound_stmt: 
	if_stmt
	| while_stmt
	| for_stmt
	| funcdef
	| classdef

for_stmt: "for" expr "in" test ":" basesuite "else" ":" basesuite { $$ = new Node ("For block"); $$->addchild($2); $$->addchild($4); $$->addchild($6); $$->addchild($9);}                        
        | "for" expr "in" test ":" basesuite  { $$ = new Node ("For Block"); $$->addchild($2,"Iterator"); $$->addchild($4,"Object"); $$->addchild($6,"Body");}                                    

testlist: arglist
        | arglist ","
;

%%



int main(int argc, char** argv){
	yydebug = 0;
	int input_fd = -1;
	stderr_dup = -1;
	int stderr_redirect = -1;
	stderr_copy = -1;
	int stderr_pipe[2];
	int pread, pwr;
	int verbosity = 0; // 1 for shift, 2 for reduce, 1|2 for both
	char *outputfile = (char *) malloc (128);
	sprintf (outputfile, "ast.dot");

	char verbositym[] = "\t-verbose shift\tList all shift operations\n\t-verbose reduce\tList all reduce operations\n\t-verbose sr\tList shift and reduce operations\n\t-verbose all\tCopy the entire debugger log\n\t-verbose srla\tPrint shift, reduce and lookahead logs\n";

	// command line options
	// now points to first command line option

	/* printf("asdfasdf\n"); */
	top = new SymbolTable (NULL);
	globalSymTable = top;
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
		// inint stderr_dup;
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
    dprintf (stderr_dup, "Error %s at line number %d.\n", s, yylineno);
    return 0;
}
