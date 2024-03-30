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
	extern FILE *tac;
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	#define YYDEBUG 1
	static Node* later;
	const char* edge_string;
	int stderr_dup, stderr_copy;
	bool inside_init = false;
	string class_name_saved_for_init;
	SymbolTable* top, *globalSymTable, *current_scope, *currently_defining_class;
#define TEMPDEBUG 1
	bool is_not_name (Node*);
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
		if (typestring != "class" && name != "self")
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
		return ;
	}
	extern void check (Node* n) ;
	bool check(Node* n1, Node* n2){
		if(n1->typestring != n2->typestring){
			return false;
		}
		return true;
	}
	int Funcsuite=0;
	int Classsuite=0;
	int inLoop=0;
	static Node* name;
	string return_type="None";
	static Node* params;
	void newscope(string name){
	cout << "New scope " << name << endl;
		if(Funcsuite){
			if(Classsuite){
				top = new SymbolTable (top, MEMBER_FN_ST, name);

			}
			else
				top = new SymbolTable (top, FUNCTION_ST, name);
		}
		else if (Classsuite){
			top = new SymbolTable (top, CLASS_ST, name);
		}
		else{
			top = new SymbolTable(top);
		}
	}
	void endscope(){
		top = globalSymTable;
	}
	int gbl_decl =0; // not sure if these 2 will be used

	SymbolTable *find_class(string name) { // because all classes are declared in the global namespace
		if (globalSymTable->children.find(name) == globalSymTable->children.end())
			return NULL; // NOT FOUND
		else if (globalSymTable->children.find(name)->second->isFunction)
			return NULL;
		else
			return globalSymTable->children.find(name)->second; // see comments above
	}
	void verify_typestring (Node* n) {
		if (find_class (n->production) == NULL) {
			dprintf (stderr_copy, "Error at line %d: Declaration of identifier with unknown type %s\n",
					(int) n->lineno, n->production.c_str());
			exit(56);
		}
	}
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
%token <node> LIST "list"

%type <node> start stmts stmt simple_stmt small_stmt expr_stmt test augassign return_stmt and_test not_test comparison expr xor_expr ans_expr shift_expr sum term factor power primary atom if_stmt while_stmt arglist suite funcdef classdef compound_stmt for_stmt testlist STRING_plus  typedarglist_comma typedarglist elif_block typedargument global_stmt typeclass 

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
	| { 
		/*check if current scope isFunction or not by top->isFunction*/
		if(!Funcsuite){
			dprintf (stderr_copy, "Error at line %d: return is not inside a function\n", (int) yylineno);
			exit(57);
		}
	} return_stmt {$$=$2;}

	| "break" {
		/*check if current scope is loop or not by top->isLoop*/
		if(!inLoop){
			dprintf (stderr_copy, "Error at line %d: break is not inside a loop\n", (int) yylineno);
			exit(58);
		}
		$$=$1;
	} 
	| "continue"{
		/*check if current scope is loop or not by top->isLoop*/
		if(!inLoop){
			dprintf (stderr_copy, "Error at line %d: continue is not inside a loop\n", (int) yylineno);
			exit(59);
		}
		$$=$1;
	}
	| {gbl_decl=1;} global_stmt[gbl] {gbl_decl=0;$$=$gbl;}
;

/* TO DO  dealing with global */

global_stmt: "global" NAME[id] {
		/* if name in currentscope then error
			if name not in global scope then error

			$id->nodeid= GlobalSymTable->get(name)->nodeid;

		*/
		if(top->local($id)){
			dprintf (stderr_copy, "Error at line %d: %s is already declared in current scope\n", (int) $id->lineno, $id->production.c_str());
			exit(87);
		}
		if(!globalSymTable->local($id)){
			dprintf (stderr_copy, "Error at line %d: %s is not declared in global scope\n", (int) $id->lineno, $id->production.c_str());
			exit(87);
		}
		$id->nodeid= globalSymTable->get($id)->node->nodeid;
		$$=$id;
	} 
	| global_stmt "," NAME[id]  { $$ = new Node ("Multiple Global"); $$->addchild($1); $$->addchild($3);

		/* if name in currentscope then error
			if name not in global scope then error

			$id->nodeid= GlobalSymTable->get(name)->nodeid;

		*/
		if(top->local($id)){
			dprintf (stderr_copy, "Error at line %d: %s is already declared in current scope\n", (int) $id->lineno, $id->production.c_str());
			exit(87);
		}
		if(!globalSymTable->local($id)){
			dprintf (stderr_copy, "Error at line %d: %s is not declared in global scope\n", (int) $id->lineno, $id->production.c_str());
			exit(87);
		}
		$id->nodeid= globalSymTable->get($id)->node->nodeid;
		$$=$id;
	}
	
expr_stmt: /* NAME[id] ":" declare typeclass[type] {
			/*
				if($id is already in current scope)error
				if($type is not declared in GlobalSymTable->classes)error

				add $id to curent scope with type $type and node $id (put($id,$type));
			*
			// if (top->symbols.find($id->production) != top->symbols.end()) {
			// 	dprintf (stderr_copy, "Redeclaration error at line %ld: identifier %s redeclared\n",
			// 			$id->lineno, $id->production.c_str());
			// 	exit(87);
			// }
			// decl=0; //reseting list[int]
			// $$ = new Node ("Declaration");
			// $$->addchild($id, "Name");
			// $$->addchild($type, "Type");
			// $$->typestring = $type->typestring;
			// put ($id, $type);
	}
*/
/*
	|"self" "." NAME[id] ":" declare typeclass[type] {
		if (!Classsuite	|| !currently_defining_class) {
			dprintf (stderr_copy, "Error at line %d: self object cannot be used outside class scope\n",
					(int) $id->lineno);
			exit (57);
		} else if (!inside_init) {
			dprintf (stderr_copy, "Error at line %d: class attributes cannot be declard outside the constructor\n",
					(int) $id->lineno);
			exit (57);
		} else if (currently_defining_class->symbols.find($id->production) != currently_defining_class->symbols.end()) {
			dprintf (stderr_copy, "Redeclaration error at line %ld: identifier %s redeclared\n",
					$id->lineno, $id->production.c_str());
			exit(87);
		}
		currently_defining_class->put ($id, $type);
		$$ = new Node ("Declaration");
		$$->addchild($id, "Name");
		$$->addchild($type, "Type");
		$$->typestring = $type->typestring;
	}
	*/
	 primary[id] ":" typeclass[type] {
		if ($id->isLeaf) {

			if (top->symbols.find($id->production) != top->symbols.end()) {
				dprintf (stderr_copy, "Redeclaration error at line %ld: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			$$ = new Node ("Declaration");
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$$->typestring = $type->typestring;
			put ($id, $type);
		} else { // mind the indent
		if (!$id->isdecl) {
			dprintf (stderr_copy, "Error at line %d: invalid L-value in declaration\n", (int) yylineno);
			exit (34);
		}
		if (!Classsuite	|| !currently_defining_class) {
			dprintf (stderr_copy, "Error at line %d: self object cannot be used outside class scope\n",
					(int) $id->lineno);
			exit (57);
		} else if (!inside_init) {
			dprintf (stderr_copy, "Error at line %d: class attributes cannot be declard outside the constructor\n",
					(int) $id->lineno);
			exit (57);
		} else if (currently_defining_class->symbols.find($id->production) != currently_defining_class->symbols.end()) {
			dprintf (stderr_copy, "Redeclaration error at line %ld: identifier %s redeclared\n",
					$id->lineno, $id->production.c_str());
			exit(87);
		}
		currently_defining_class->put ($id, $type);
		$$ = new Node ("Declaration");
		$$->addchild($id, "Name");
		$$->addchild($type, "Type");
		$$->typestring = $type->typestring;
		}
	}
	| primary[id] ":" typeclass[type] "=" test[value] {
		if ($id->isLeaf) {
			if (is_not_name ($id)) {
				dprintf (stderr_copy, "Error: assignment to non-identifier at line %d\n", $id->lineno);
				exit(97);
			}
			if ($value->typestring == "") {
				dprintf (stderr_copy, "Error at line %ld: Invalid value on RHS of unknown type\n",
						$id->lineno);
#if TEMPDEBUG
				printf ("empty typestring: production is %s token %d\n", $value->production.c_str(), $value->token);
#endif
				exit (96);
			}
			if (top->has($id)) {
				dprintf (stderr_copy, "Redeclaration error at line %ld: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			/*
				if($id is not lvalue) error
				if($id is already in current scope)error
				if($type is not declared in GlobalSymTable->classes)error
				if($type and $value are not type compatible) error ( only int<->float and int <-> bool type mismatch are allowed give error otherwise)
				if($value is a leaf && $value is not a constant ) check if $value is in scope or not
				
				add $id to curent scope with type $type and node $id (put($id,$type));
			*/
			$$ = new Node ("Declaration");
			$$->op = MOV_REG;
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$$->addchild($value, "Value", $id);
			$$->typestring = $type->typestring;
			put ($id, $type);
		} else { // mind the indent
			if (!$id->isdecl) {
				dprintf (stderr_copy, "Error at line %d: invalid L-value in declaration\n", (int) yylineno);
				exit (34);
			}
			if (!Classsuite	|| !currently_defining_class) {
				dprintf (stderr_copy, "Error at line %d: self object cannot be used outside class scope\n",
						(int) $id->lineno);
				exit (57);
			} else if (!inside_init) {
				dprintf (stderr_copy, "Error at line %d: class attributes cannot be declard outside the constructor\n",
						(int) $id->lineno);
				exit (57);
			} else if (currently_defining_class->symbols.find($id->production) != currently_defining_class->symbols.end()) {
				dprintf (stderr_copy, "Redeclaration error at line %ld: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			currently_defining_class->put ($id, $type);
			$$ = new Node ("Declaration");
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$$->typestring = $type->typestring;
		}
	} 
	| primary augassign test { 
			/*
				if($1 is not lvalue) error
				if($1 is not in current scope)error
				if($1 and $3 are not type compatible)error
				if($3 is a leaf && $3 is not a constant ) check if $3 is in scope or not
			*/
			// added during merging - check integrity later
			if ($1->typestring == "" && !$1->isLeaf) {
				dprintf (stderr_copy, "Error at line %d: class attribute %s has not been defined\n",
						(int)$1->lineno, $1->production.c_str());
				exit (40);
			}
			if ($1->typestring == "def" || $1->typestring == "class" || $1->islval == false) {
				dprintf (stderr_copy, "Error at line %d: assignment must be to an identifier or class attribute\n",
						(int) $1->lineno);
				exit (33);
			}
			if (!top->has($3) && ($3->typestring == "")) {
				dprintf (stderr_copy, "Error at line %ld: Invalid value on RHS of unknown type\n", $3->lineno);
				exit (94);
			} else if (top->has($3))
				$3->typestring = top->get($3->production)->typestring;
			check($1);
			check($3);
			if(!check($1,$3)){
				fprintf(stderr, "Type Error: %s and %s are not of same type\n", $1->production.c_str(), $3->production.c_str());
				exit(1);
			}

			$$ = new Node ($2->production);
			$$->addchild($1);
			$$->addchild($3);
	}
	| primary "=" test{
			/*
				if($1 is not lvalue) error
				if($1 is not in current scope)error
				if($1 and $3 are not type compatible)error
				if($3 is a leaf && $3 is not a constant ) check if $3 is in scope or not

			*/
			if ($1->typestring == "" && !$1->isLeaf) {
				dprintf (stderr_copy, "Error at line %d: class attribute %s has not been defined\n",
						(int)$1->lineno, $1->production.c_str());
				exit (40);
			}
			if ($1->typestring == "def" || $1->typestring == "class" || $1->islval == false) {
				dprintf (stderr_copy, "Error at line %d: assignment must be to an identifier or class attribute\n",
						(int) $1->lineno);
				exit (33);
			}
			$$ = new Node ("=");
			$$->addchild($1);
			$$->addchild($3);
			// these 3 lines copied during merging: check consistency
			check ($1);
			check($3);
			if ($1->isLeaf)
				top->get($1)->typestring= $3->typestring;
			$$->add_op ($3, $3, MOV_REG);
	}
	| test {
		if ($1->isLeaf) {
			if (!top->has($1->production) && $1->token==NAME){
				dprintf (stderr_copy, "NameError at line %ld: identifier %s has not been declared\n",
						$1->lineno, $1->production.c_str()); exit(42);
			}
			else printf ("valid identifier %s\n", $1->production.c_str());
		}
		$$ = $1;
	}


typeclass: NAME {
		verify_typestring ($1);
		$$ = $1;
	}
	| "list" "[" NAME "]" {
		$$ = $3;
		$$->dimension = 1;
		verify_typestring ($3);
	}

augassign: "+=" | "-=" | "*=" | "/=" | DOUBLESLASHEQUAL | "%=" | "&=" | "|=" | "^=" | ">>=" | "<<=" | "**="

return_stmt: "return" test {
		/*
			if(Funcsuite==0) error
			if($2 is not in current scope) error
			if ($2 is not type compatible with return type) error
		*/
			$1->addchild($2,"Data"); $$=$1;	
	}
	| "return" {
		/*
			if(Funcsuitex==0) error
			if(return type is not None) error
		*/
		string temp = "Keyword\n"; temp += "( return )"; $$ = new Node(temp);}

// for each operation check if the operands are in current scope or not
// check type compatibility
//udate type of result

test : and_test {
	}
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
power: primary { current_scope = NULL; $$ = $1; }
	| primary "**" factor	{ $$ = new Node ("**"); $$->addchild($1); $$->addchild($3); current_scope = NULL;}

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

When evaluating an expression of the form a.b.c.d.e, current_scope points to the scope of primary in primary.name: a, then a.b, then a.b.c, etc.
currently_defining_class is a pointer to the class currently being defined. defined because top does not change inside class suite.

on entry to primary "." NAME: if primary is a leaf, nothing is set.
	else: primary->typestring is set to the correct value. current_scope points to the SymbolTable in which we need to search for primary->typestring
*/


primary: atom {
		// set typestring if available, so we know if it's a declaration or a use
		$$ = $1;
		$$->islval = true;
		$$->isdecl = true;
		if (top->has($1->production))
			$$->typestring = top->get($1)->typestring;
		if ($1->production == top->thisname) {
			$$->isdecl = false;
		}
		current_scope = NULL;
	}
	| primary "." NAME {
		$$ = new Node (0, "", $3->typestring);
		$$->isLeaf = false;
		if (inside_init && $1->isLeaf && $1->production == top->thisname) {
			$$->isdecl = true;	$$->islval = true;
		} else {
			$$->isdecl = false; $$->islval = true;
		}

		string this_ptr = top->thisname;
		// CHECKING PRIMARY
		if ($1->isLeaf) { // set typestring
			if (top->get ($1))
				$1->typestring = top->gettype($1->production);
			else if ($1->production == top->thisname) {
				if (!Classsuite || !currently_defining_class) {
					dprintf (stderr_copy, "Error at line %d: self pointer cannot be used outside class scope\n", (int)$1->lineno);
					exit(63);
				}
				$1->typestring = currently_defining_class->name;
			}
			else {
				dprintf (stderr_copy, "Error at line %d: Identifier %s not declared in this scope\n",
						(int) $1->lineno, $1->production.c_str());
				exit (65);
			}
		}
		if ($1->typestring == "") {
			dprintf (stderr_copy, "Error at line %d: object of unknown type referenced\n", (int)$3->lineno);
			exit(55);
		}
		current_scope = find_class($1->typestring);
		if (current_scope == NULL || $1->typestring == "class" || $1->typestring == "def") {
			dprintf (stderr_copy, "Error at line %d: Object has invalid type, or is a function or class name\n", (int) $3->lineno);
			exit (56);
		}
		if ($3->production == current_scope->thisname) {
			dprintf (stderr_copy, "Error at line %d: self pointer %s cannot be referenced outside function scope\n", (int)$3->lineno, current_scope->thisname.c_str());
			exit(68);
		}
		if (current_scope->find_member_fn ($3->production)) {
			$$->typestring = "def"; $$->islval = false;
			current_scope = current_scope->find_member_fn($3->production); // the only case in which current_scope is truly global
		}
		else
			$$->typestring = current_scope->gettype($3->production);
		$$->production = $3->production;
		if (!$$->isdecl && $$->typestring == "") {
			dprintf (stderr_copy, "Error at line %d: Class %s does not have attribute %s\n",
					(int) $3->lineno, $1->typestring.c_str(), $3->production.c_str());
			exit (84);
		}
		$$->lineno = $1->lineno;
	}

	| primary "[" test "]"
		{
			$$->isdecl = false;
			$$->islval = true;
			if ($1->isLeaf && !top->has($1)) {
				dprintf (stderr_copy, "Error undeclared object %s at line %ld", $1->production.c_str(), $3->lineno);
				exit (1);
			}
			if ($1->dimension == 0) {
				dprintf (stderr_copy, "Error at line %d: %s object is not subscriptable.\n",
						yylineno, $1->typestring.c_str());
				exit (1);
			}
			if ($3->typestring != "int") {
				dprintf (stderr_copy, "Error at line %d: index is not an integer\n",
						yylineno);
				exit (1);
			}
			// if primary is out of bounds: run time error right?
			// reminder: in 3ac, check bounds
			$$ = new Node (0, $1->typestring, "");
			if ($3->typestring != "int") {
				dprintf (stderr_copy, "Error at line %d: array subscript cannot be of type %s, must be int\n",
						yylineno, $3->typestring.c_str());
				exit (74);
			}
		current_scope = NULL;
		$$->lineno = $1->lineno;
		}
	| primary "(" testlist ")" {
		/*
			if primary is leaf and primary is not in symboltable)error
			if(primary is not a function) error
			if(primary->arg_types.size() != testlist->children.size()) error
			for i in range(primary->arg_types.size())
				if(primary->arg_types[i] != testlist->children[i]->typestring) error
			update $$->typestring as return type of function
			if primary is constant then error
			if primary is not in current scope then error
			if primary is not a function then error

			check if testlist is compatible with function parameters or not

			update $result type as the return type of function
		*/
		$$ = new Node (0, "", "");
		$$->islval = false;
		$$->isdecl = false;
		if ($1->isLeaf) {
			if (top->find_member_fn ($1->production)) {
				current_scope = top->find_member_fn($1->production);
				$1->typestring = "def";
				printf ("valid call to function %s in line %ld\n", $1->production.c_str(), $1->lineno);
				// fill 3ac for function call
			} else if (globalSymTable->ctor.find($1->production) != globalSymTable->ctor.end()) { // call to constructor
				current_scope = globalSymTable->ctor.find ($1->production)->second;
				printf ("line %ld valid call to constructor %s\n", $1->lineno, $1->production.c_str());
				$$->typestring = $1->production;
			} else if (globalSymTable->children.find($1->production) != globalSymTable->children.end()) {
				current_scope = globalSymTable->children.find ($1->production)->second;
				$$->typestring = current_scope->return_type;
			} else {
				dprintf (stderr_copy, "Error at line %ld: Call to undefined function %s.\n", $1->lineno, $1->production.c_str());
				exit(44);
			}
		} else { // now we expect typestring to be set to def, symboltable to be available in current_scope
			if ($1->typestring != "def") {
				dprintf (stderr_copy, "TypeError at line %ld: Function call to object of type %s.\n", $2->lineno, $1->typestring.c_str());
				exit(45);
			} else { // valid function call
				printf ("valid function call to function %s\n",
						current_scope ? current_scope->name.c_str() : "" );
			}
		}
		$$->lineno = $1->lineno;
	}
	| primary "(" ")" {
		/*
			if primary is constant then error
			if primary is not in current scope then error
			if primary is not a function then error

			update $result type as the return type of function
		*/
		$$ = new Node (0, "", "");
		if ($1->isLeaf) {
			if (top->find_member_fn ($1->production)) {
				$1->typestring = "def";
				printf ("valid call to function %s in line %ld\n", $1->production.c_str(), $1->lineno);
				// fill 3ac for function call
			} else if (globalSymTable->ctor.find($1->production) != globalSymTable->ctor.end()) { // call to constructor
				printf ("line %ld valid call to constructor %s\n", $1->lineno, $1->production.c_str());
				$$->typestring = $1->production;
			} else if (globalSymTable->children.find($1->production) != globalSymTable->children.end()) {
				current_scope = globalSymTable->children.find ($1->production)->second;
				$$->typestring = current_scope->return_type;
			} else {
				dprintf (stderr_copy, "Error at line %ld: Call to undefined function %s.\n", $1->lineno, $1->production.c_str());
				exit(44);
			}
		} else { // now we expect typestring to be set to def, symboltable to be available in current_scope
			if ($1->typestring != "def") {
				dprintf (stderr_copy, "TypeError at line %ld: Function call to object of type %s.\n", $2->lineno, $1->typestring.c_str());
				exit(45);
			} else { // valid function call
				printf ("valid function call to function %s\n",
						current_scope ? current_scope->name.c_str() : "" );
			}
		}
		$$->islval = false;
		$$->isdecl = false;
		current_scope = NULL;
		$$->lineno = $1->lineno;
	}





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
	/* Empty list not needed */
STRING_plus: STRING 
	| STRING_plus STRING {
		/*
			update value as signle string
		*/
		 $$ = new Node ("Multi String"); $$->addchild($1); $$->addchild($2);}

if_stmt: "if" test ":" suite { $$ = new Node ("If Block"); $$->addchild($2, "If"); $$->addchild($4, "Then");}
	|  "if" test ":" suite elif_block {$$ = new Node ("If Else Block"); $$->addchild($2, "If"); $$->addchild($4, "Then"); $$->addchild($5, "Else"); }

elif_block:
	"else" ":" suite	{ $$ = $3;}
	| "elif" test ":" suite	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($4, "Then"); } /* ok????? fine */ 
	| "elif" test ":" suite elif_block	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($4, "Then"); $$->addchild ($5, "Else"); }

while_stmt: "while" test ":" suite {$$ = new Node ("While"); $$->addchild($2, "Condition"); $$->addchild($4, "Do");}



arglist: test
	| arglist "," test { $$ = new Node ("Multiple terms"); $$->addchild($1); $$->addchild($3);}



typedarglist:  typedargument {/*top->arguments push*/}
	| NAME {/*this pointer in case inClass==1 otherwise error*/
		if (!Classsuite) {
			dprintf (stderr_copy, "Error in line %ld: Argument %s to function does not have a type hint\n", $1->lineno, $1->production.c_str());
			exit (77);
		}
		if (top->thisname != "") {
			dprintf (stderr_copy, "Error in line %ld: Argument %s to function does not have a type hint. \"this\" pointer has been declared.\n", $1->lineno, $1->production.c_str());
			exit (76);
		}
		top->thisname=$1->production;
		top->put($1, currently_defining_class->name);
	}
	| typedarglist "," typedargument { $$ = new Node ("Multiple Terms"); $$->addchild($1); $$->addchild($3);}

typedarglist_comma: typedarglist | typedarglist ","

typedargument: NAME ":" typeclass { $$ = new Node ("Typed Parameter"); $$->addchild($1,"Name"); $$->addchild($3,"Type");
		if (is_not_name($3)) {
			dprintf (stderr_copy, "Error at line %d: type hints must be L-values\n", yylineno);
			exit(45);
		}
		if (is_not_name($1)) {
			dprintf (stderr_copy, "Error at line %d: function arguments must be L-values\n", yylineno);
			exit(45);
		}
		if (find_class ($3->production) == NULL) {
			dprintf (stderr_copy, "Error at line %ld: Unknown type hint %s to function parameters\n", $1->lineno, $3->production.c_str());
			exit (42);
		}
		if (top->symbols.find($1->production) != top->symbols.end()) {
			dprintf (stderr_copy, "Error at line %ld: identifier %s redeclared in function scope\n", $1->lineno, $1->production.c_str());
			exit(49);
		}
		put ($1, $3);
	}

suite:  simple_stmt[first] 
	| NEWLINE  INDENT  stmts[third] DEDENT 
/* when using multiple mid-rule actions avoid using $1, $2, $3 as its more rigid to code changes*/
/* use common non terminal (like functionstart here) to use mid-rule actions if getting reduce reduce error( which occurs if two rules have the same prefix till the code segment and the lookahead symbol after the code is also same)  */


funcdef: "def" NAME[id]  functionstart "(" typedarglist_comma[param] ")" "->" typeclass[ret] ":" suite[last] {
		Funcsuite=0;
		endscope(); inside_init = 0;
		$$ = new Node ("Function Defn");
		$$->addchild($id, "Name");
		$$->addchild($param,"Parameters");
		$$->addchild($ret, "Return type");
		$$->addchild($last, "Body");
	}
	| "def" NAME[id] functionstart "(" ")" "->" typeclass[returntype] ":" suite[last] {
	       	Funcsuite=0;
		endscope(); inside_init = 0;
	       	$$ = new Node ("Function Defn"); $$->addchild($id, "Name");
	       	$$->addchild($returntype, "Return type");
	       	$$->addchild($last, "Body");
	}
	| "def" NAME[id] functionstart "(" typedarglist_comma[param] ")" ":" suite[last] {
	       	Funcsuite=0;
		endscope(); inside_init = 0;
	       	$$ = new Node ("Function Defn");
	       	$$->addchild($id, "Name");
	       	$$->addchild($param,"Parameters");
	       	$$->addchild($last, "Body");
	}
	| "def" NAME[id] functionstart "(" ")" ":" suite[last] {
	       	Funcsuite=0;
		endscope(); inside_init = 0;
		$$ = new Node ("Function Defn");
		$$->addchild($id, "Name");
		$$->addchild($last, "Body");
	}

functionstart:  {
#if TEMPDEBUG
		printf("start function scope\n");
		printf("scope name= %s\n", $<node>0->production.c_str());
		if (Classsuite)
			printf ("class name in method def: %s\n", currently_defining_class->name.c_str());
#endif
		// if inside_init or classsuite = 0, add functions to globalSymTable
		// else add to currently_defining_class
		if (Classsuite && $<node>0->production == "__init__"){
			inside_init = 1;
		}
		Funcsuite = 1;

		if (inside_init)
			top = new SymbolTable (globalSymTable, CTOR_ST, currently_defining_class->name);
		else
			top = new SymbolTable (
					currently_defining_class? currently_defining_class : top,
					Classsuite?MEMBER_FN_ST:FUNCTION_ST,
					$<node>0->production);
		top->lineno = $<node>0->lineno;
	}
;
classdef: "class" NAME classstart ":"  suite[last] {
		  Classsuite=0;
		  $$ = new Node ("Class");
		  $$->addchild($2, "Name");
		  $$->addchild($last, "Contains");
		  inside_init = 0; // endscope();
		currently_defining_class = NULL;
	 }
	| "class" NAME classstart "(" NAME[parent] ")" ":" suite[last] {
	       	Classsuite=0;
	       	$$ = new Node ("Class");
	       	$$->addchild($2, "Name");
	       	$$->addchild($parent, "Inherits");
	       	$$->addchild($last,"Contains");
		inside_init = 0; // endscope();
		currently_defining_class = NULL;
	}
	| "class" NAME classstart "(" ")" ":" suite[last] {
	       	Classsuite=0;
	       	$$ = new Node ("Class");
	       	$$->addchild($2, "Name");
	       	$$->addchild($last, "Contains");
		inside_init = 0; // endscope();
		currently_defining_class = NULL;
	}

classstart:	{
#if TEMPDEBUG
	printf ("start class scope");
	printf ("scope name %s\n", $<node>0->production.c_str());
#endif
	if (currently_defining_class || Classsuite) {
		dprintf (stderr_copy, "Error: Nested declaration of classes\n");
		exit(43);
	}
	Classsuite = 1;
	currently_defining_class = new SymbolTable (top, CLASS_ST, $<node>0->production);
	// top = top->parent;
	currently_defining_class->lineno = $<node>0->lineno;
}

compound_stmt: 
	if_stmt
	| while_stmt
	| for_stmt
	| funcdef
	| classdef

for_stmt: "for" expr "in" test ":" suite "else" ":" suite { $$ = new Node ("For block"); $$->addchild($2); $$->addchild($4); $$->addchild($6); $$->addchild($9);}                        
        | "for" expr "in" test ":" suite  { $$ = new Node ("For Block"); $$->addchild($2,"Iterator"); $$->addchild($4,"Object"); $$->addchild($6,"Body");}                                    

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
	current_scope = NULL;
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
		stderr_copy = 2;
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
			if (strncmp (line, "Error syntax error", 13) == 0)
				dprintf (stderr_copy, "Error reported by Bison: %s\n", line);

			line = NULL; n = 0;
		}
		dprintf (stderr_copy, "Deleting .debuglog\n");
		unlink (".debuglog");
		fclose (logs);
	}
	FILE* stdump = fopen ("symbol_table.csv", "w+");
	fprintf (stdump, "LEXEME\tTYPE\tTOKEN\t\tLINE\tPARENT SCOPE\n");
	globalSymTable->print_st(stdump);
	fclose (stdump);
    return 0;
}


bool is_not_name (Node* ncheck) {
#if TEMPDEBUG
	// printf ("checking if %s is a leaf %s leaf-%d token-%d\n", ncheck->production.c_str(), ncheck->typestring.c_str(), ncheck->isLeaf, ncheck->token);
#endif
	return !(ncheck->isLeaf && ncheck->token == NAME);
}


int yyerror(const char *s){
    dprintf (stderr_dup, "Error %s at line number %d.\n", s, yylineno);
    return 0;
}
void check(Node* n){
	// for literals, return directly
	if (Classsuite && !n->isLeaf && n->token == NAME) return; //self.*
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
