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
	int tempcount=0;
	int forcount=0;
	FILE* graph = NULL;
	FILE* inputfile = NULL;
    extern int yylex();
    extern int yyparse();
    extern void debugprintf (const char *) ;
	// extern FILE *tac;
    extern int yylineno;
	extern char *yytext;
    int yyerror(const char *s);
	#define YYDEBUG 1
	static Node* later;
	const char* edge_string;
	int stderr_dup, stderr_copy;
	bool inside_init = false;
	bool list_init = false;
	string class_name_saved_for_init;
	SymbolTable* top, *globalSymTable, *current_scope, *currently_defining_class;
	string newtemp(){
		string temp = "t";
		temp += to_string(tempcount);
		tempcount++;
		return temp;
	}
	void resettemp(){
		tempcount=forcount;
	}
	SymbolTable *currently_defining_list;
	string currently_defining_identifier_typestring;
	vector <Node*> list_init_inputs;
	vector <Node *> function_call_args;
	vector <bool> function_call_args_dim;
	stack <string> jump_labels, jump_labels_upper;
	int label_count;
#define ISPRIMITIVE(nodep) (nodep->typestring == "int" || nodep->typestring == "bool" || nodep->typestring == "float" || nodep->production == "str")
#define TEMPDEBUG 0
	bool is_not_name (Node*);
	string static_section;
	string concatenating_string_plus;
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
	extern int check_number(Node* n) ;
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
	enum ir_operation current_op;
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
	int getwidth(Node*n){
		return find_class(n->typestring)->table_size;
	}
	void gen(Node*result, Node* leftop, Node* rightop,enum ir_operation op){
		if (tac == NULL) tac = stdout;
		string left= leftop ? top->getaddr(leftop) : "";
		string right= rightop ? top->getaddr(rightop) : "";
		string resultaddr = result ? top->getaddr(result) : "";
		switch(op){
			case ASSIGN: fprintf(tac, "\t%s = %s\n", left.c_str(), right.c_str()); return;
			case ATTR: {
				string s="\t";
				if(leftop->isLeaf){
					string obj= newtemp();
					s+=obj +" = &(" + left +")\n\t";
					left = obj;
				}
				string offset = newtemp();
				// t_1 = symtable($1->typestring, $3->production)
				s+= offset + " = symtable(" + leftop->typestring + ", " + rightop->production + ")\n\t"; 
				// t_2 = $1->addr + offset
				string ult = newtemp();
				s+=ult +" = (" + left + " + " + offset + ")\n";
				result->addr = "*"+ult;
				// cout<<"nice "<<addr<<endl;
				fprintf(tac, "\t%s", s.c_str());
				return;
			}
			case SW:	{
				fprintf (tac, "\t*%s = %s\n", resultaddr.c_str(), left.c_str()); return;
			}
			case SUBSCRIPT: {
				string s="\t";
				string offset = newtemp();
				
				s += offset + " =  "  +right + "*"+ to_string(getwidth(leftop)) + "\n\t";
				string ult = newtemp();
				s+=ult +" = (" + left + " + " + offset + ")\n";
				result->addr = "*"+ult;
				fprintf(tac, "%s", s.c_str()); 
				return;
			}
			default: break;
		}
		result->addr = newtemp();
		resultaddr = result->addr;
		switch(op){
			case ADD: fprintf(tac, "\t%s = %s + %s\n",resultaddr.c_str(), left.c_str(), right.c_str()); break;
			case SUB: fprintf(tac, "\t%s = %s - %s\n",resultaddr.c_str(), left.c_str(), right.c_str()); break;
			case MUL: fprintf(tac, "\t%s = %s * %s\n",resultaddr.c_str(), left.c_str(), right.c_str()); break;
			case DIV: fprintf(tac, "\t%s = %s / %s\n",resultaddr.c_str(), left.c_str(), right.c_str()); break;
			default: break;
		}
		return;
			
	}

	void gen(Node*leftop, Node* rightop, enum ir_operation op){
		
	}
	string get_next_label (string description) {
		string tmp = "label_" + to_string(label_count++) + "_" + (currently_defining_class ? currently_defining_class->name : top->name) ;
		if (description != "") tmp += "_" + description;
		jump_labels.push (tmp);
		return tmp;
	}
	string get_current_label () {
		string tmp = jump_labels.top();
		jump_labels.pop();
		return tmp;
	}
	string get_next_label_upper (string description) {
		string tmp = "label_" + to_string(label_count++) + "_" + (currently_defining_class ? currently_defining_class->name : top->name) ;
		if (description != "") tmp += "_" + description;
		jump_labels_upper.push (tmp);
		return tmp;
	}
	string get_current_label_upper () {
		string tmp = jump_labels_upper.top();
		jump_labels_upper.pop();
		return tmp;
	}
	string dev_helper(Node* n) {
		return top->getaddr (n);
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
	| stmts[first] {resettemp();} stmt[last] { resettemp();$$ = new Node ("Statements"); $$->addchild($first); $$->addchild($last);}

;

stmt:  simple_stmt 
	| compound_stmt 
;

simple_stmt: small_stmt ";" NEWLINE {$$=$1;resettemp();}
	| small_stmt NEWLINE {$$=$1;resettemp();}
	| small_stmt[first]";" {resettemp();} simple_stmt[last] {$$ = new Node ("Inline Statement"); $$->addchild($first);$$->addchild($last);}
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
		$id->addr= globalSymTable->getaddr($id);
		$$=$id;
	}
	
expr_stmt: primary[id] ":" typeclass[type] {
		if (!$id->isdecl) {
			dprintf (stderr_copy, "Error at line %d: invalid L-value in declaration\n", yylineno);
			exit (34);
		}
		if ($id->isLeaf) {
			if (top->symbols.find($id->production) != top->symbols.end()) {
				dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			$$ = new Node ("Declaration");
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$1->typestring = $type->typestring;
			$1->dimension = $type->dimension;
			put ($id, $type);
		} else { // mind the indent
			if (!Classsuite	|| !currently_defining_class) {
				dprintf (stderr_copy, "Error at line %d: self object cannot be used outside class scope\n",
						$id->lineno);
				exit (57);
			} else if (!inside_init) {
				dprintf (stderr_copy, "Error at line %d: class attributes cannot be declard outside the constructor\n",
						$id->lineno);
				exit (57);
			} else if (currently_defining_class->symbols.find($id->production) != currently_defining_class->symbols.end()) {
				dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			currently_defining_class->put ($id, $type);
			$$ = new Node ("Declaration");
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$1->typestring = $type->typestring;
			$1->dimension = $type->dimension;
		}
	}
	| primary[id] ":" typeclass[type] decl_set_curr_id "=" test[value] {
		if ($id->isLeaf) {
			if (is_not_name ($id)) {
				dprintf (stderr_copy, "Error: assignment to non-identifier at line %d\n", $id->lineno);
				exit(97);
			}
			if (top->local($id)) {
				dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			if($value->typestring !=$type->production){
				dprintf(stderr_copy, "TypeError at line %d: Types on both side do not match\n",$id->lineno);
				exit(88);
			}
			if ($value->typestring == "") {
				dprintf (stderr_copy, "Error at line %d: Invalid value on RHS of unknown type\n",
						$id->lineno);
#if TEMPDEBUG
				printf ("empty typestring: production is %s token %d\n", $value->production.c_str(), $value->token);
#endif
				exit (96);
			}
			/*
				if($id is not lvalue) error
				if($id is already in current scope)error
				if($type is not declared in GlobalSymTable->classes)error
				if($value is a leaf && $value is not a constant ) check if $value is in scope or not
				if($type and $value are not type compatible) error ( only int<->float and int <-> bool type mismatch are allowed give error otherwise)
				
				add $id to curent scope with type $type and node $id (put($id,$type));
			*/
			$$ = new Node ("Declaration");
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$$->addchild($value, "Value");
			$1->typestring = $type->typestring;
			$1->dimension = $type->dimension;
			put ($id, $type);
			// cout<<"Dimension of type" <<$type->dimension<<endl;
			gen ($$,$id, $value, ASSIGN);
			// cout<<"Dimension "<<$id->dimension<<endl;

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
				dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			currently_defining_class->put ($id, $type);
			$$ = new Node ("Declaration");
			$$->addchild($id, "Name");
			$$->addchild($type, "Type");
			$1->typestring = $type->typestring;
			$1->dimension = $type->dimension;

			gen ($$,$id, $value, ASSIGN);
		}
	} 
	| primary[id] augassign[operation] test[value] { 
			/*
				if($id is not lvalue) error
				if($id is not in current scope)error
				if($id and $value are not type compatible)error
				if($value is a leaf && $value is not a constant ) check if $value is in scope or not
			*/
			// added during merging - check integrity later
			if ($id->typestring == "" && !$id->isLeaf) {
				dprintf (stderr_copy, "Error at line %d: class attribute %s has not been defined\n",
						(int)$id->lineno, $id->production.c_str());
				exit (40);
			}
			if ($id->typestring == "def" || $id->typestring == "class" || $id->islval == false) {
				dprintf (stderr_copy, "Error at line %d: assignment must be to an identifier or class attribute\n",
						(int) $id->lineno);
				exit (33);
			}
			if (!top->has($value) && ($value->typestring == "")) {
				dprintf (stderr_copy, "Error at line %d: Invalid value on RHS of unknown type\n", $value->lineno);
				exit (94);
			} else if (top->has($value))
				$value->typestring = top->get($value->production)->typestring;
			check($id);
			check($value);
			if(!check($id,$value)){
				fprintf(stderr, "Type Error: %s and %s are not of same type\n", $id->production.c_str(), $value->production.c_str());
				exit(1);
			}
			$$ = new Node ($operation->production);
			$$->addchild($id);
			$$->addchild($value);
			gen($id,$id,$value,$operation->op);
	}
	| primary[id] "=" test[value] {
			/*
				if($id is not lvalue) error
				if($id is not in current scope)error
				if($id and $value are not type compatible)error
				if($value is a leaf && $value is not a constant ) check if $value is in scope or not

			*/
			if ($id->typestring == "" && !$id->isLeaf) {
				dprintf (stderr_copy, "Error at line %d: class attribute %s has not been defined\n",
						(int)$id->lineno, $id->production.c_str());
				exit (40);
			}
			if ($id->typestring == "def" || $id->typestring == "class" || $id->islval == false) {
				dprintf (stderr_copy, "Error at line %d: assignment must be to an identifier or class attribute\n",
						(int) $id->lineno);
				exit (33);
			}
			$$ = new Node ("=");
			$$->addchild($id);
			$$->addchild($value);
			// these 3 lines copied during merging: check consistency
			check ($id);
			check($value);

			if(!check($id,$value)){
				fprintf(stderr, "Type Error: %s and %s are not of same type\n", $id->production.c_str(), $value->production.c_str());
				exit(1);
			}
			gen($$,$id,$value,ASSIGN);
	}
	| test {
		if ($1->isLeaf) {
			if (!top->has($1->production) && $1->token==NAME){
				dprintf (stderr_copy, "NameError at line %d: identifier %s has not been declared\n",
						$1->lineno, $1->production.c_str()); exit(42);
			}
#if TEMPDEBUG
			else{
			 printf ("valid identifier %s\n", $1->production.c_str());
			}
#endif	
		}
		$$ = $1;
	}

decl_set_curr_id: {
		currently_defining_identifier_typestring = $<node>0->production;
		if ($<node>0->dimension == 0) currently_defining_identifier_typestring = "";
#if TEMPDEBUG
		cout << "line 541 set currently definining list type to " << currently_defining_identifier_typestring << endl;
#endif
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

augassign: "+=" {$$ = new Node ("+="); $$->op = ADD;}
		| "-=" {$$ = new Node ("-="); $$->op = SUB;}
		| "*=" {$$ = new Node ("*="); $$->op = MUL;}
		| "/=" {$$ = new Node ("/="); $$->op = DIV;}
		| DOUBLESLASHEQUAL {$$ = new Node ("//="); $$->op = DIV;}
		| "%=" {$$ = new Node ("%="); ;}
		| "&=" {$$ = new Node ("&="); }
		| "|=" {$$ = new Node ("|="); }
		| "^=" {$$ = new Node ("^="); }
		| ">>=" {$$ = new Node (">>=");}
		| "<<=" {$$ = new Node ("<<="); }
		| "**=" {$$ = new Node ("**="); }

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

comparison: expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}
	| expr "==" comparison	{
		$$ = new Node ("==");
		$$->addchild ($1);
		$$->addchild ($3);
		if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
			exit(1);
		}
		if (($1->typestring == "str" && $3->typestring != "str")
		||  ($1->typestring != "str" && $3->typestring == "str")) {
			dprintf(stderr_copy, "TypeError at line %d: incompatible types for == comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
			exit(1);
		}
		if ($1->typestring == "str" && $3->typestring == "str") {
			// call strcmp
			if ($1->isLeaf && $3->isLeaf && $1->production == "__name__" && $3->strVal == "\\\"__main__\\\"") {
				// pass
			} else {
				cout <<  $1->production << $3->strVal << endl;
				dprintf (1, "havent implemented\n");
				exit(77);
			}
		}

		else if (!check_number($1)) {
			dprintf(stderr_copy, "TypeError at line %d: first operand for == comparison has type %s\n", $2->lineno, $1->typestring.c_str());
			exit(1);
		}
		else if (!check_number($3)) {
			dprintf(stderr_copy, "TypeError at line %d: second operand for == comparison has type %s\n", $2->lineno, $3->typestring.c_str());
			exit(1);
		}
		$$->typestring = "bool";
		
		//to do: gen
}
	| expr "!=" comparison	{
	$$ = new Node ("!=");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for != comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for != comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for != comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$->typestring = "bool";
	
	//to do: gen
}
	| expr "<" comparison	{
	$$ = new Node ("<");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for < comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for < comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for < comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$->typestring = "bool";
	
	//to do: gen
}
	| expr "<=" comparison	{
	$$ = new Node ("<=");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for <= comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for <= comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for <= comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$->typestring = "bool";
	
	//to do: gen
}
	| expr ">" comparison	{
	$$ = new Node (">");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for > comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for > comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for > comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$->typestring = "bool";
	
	//to do: gen
}
	| expr ">=" comparison	{
	$$ = new Node (">=");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for >= comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for >= comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for >=T comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$->typestring = "bool";
	
	//to do: gen
}


expr: xor_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}
	| expr "|" xor_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (!check_number($1)
	||  ($1->typestring != "int"
	 &&  $1->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for | has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)
	||  ($3->typestring != "int"
	 &&  $3->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for | has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("Bitwise OR\n|");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "int"
	||  $3->typestring == "int" ) {
		$$->typestring = "int";
	} else {
		$$->typestring = "bool";
	}
	//to do: gen
}
xor_expr: ans_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}
	| xor_expr "^" ans_expr	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (!check_number($1)
	||  ($1->typestring != "int"
	 &&  $1->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for ^ has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)
	||  ($3->typestring != "int"
	 &&  $3->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for ^ has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("Bitwise XOR\n^");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "int"
	||  $3->typestring == "int" ) {
		$$->typestring = "int";
	} else {
		$$->typestring = "bool";
	}
	//to do: gen
}

ans_expr: shift_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}
	| ans_expr "&" shift_expr	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (!check_number($1)
	||  ($1->typestring != "int"
	 &&  $1->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for & has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)
	||  ($3->typestring != "int"
	 &&  $3->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for & has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node("Bitwise AND\n&");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "int"
	||  $3->typestring == "int" ) {
		$$->typestring = "int";
	} else {
		$$->typestring = "bool";
	}
	//to do: gen
}
shift_expr: sum {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
} 
	| shift_expr "<<" sum	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (!check_number($1)
	||  ($1->typestring != "int"
	 &&  $1->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for & has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)
	||  ($3->typestring != "int"
	 &&  $3->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for & has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("Left Shift\n<<");
	$$->addchild ($1);
	$$->addchild ($3);
	$$->typestring = "int"; //always
	//to do: gen
}
	| shift_expr ">>" sum	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	if (!check_number($1)
	||  ($1->typestring != "int"
	 &&  $1->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for & has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	if (!check_number($3)
	||	($3->typestring != "int"
	 &&  $3->typestring != "bool")) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for & has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("Right Shift\n>>");
	$$->addchild ($1);
	$$->addchild ($3);
	$$->typestring = "int"; //always
	//to do: gen
}

sum : sum "+" term  { 
		$$ = new Node ("+"); 
		$$->addchild ($1); $$->addchild($3);
		// $$->typestring = $1->typestring;
		if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
			exit(1);
		}
		
		if (!check_number($1)) {
			 dprintf(stderr_copy, "TypeError at line %d: Invalid type of first summand for addition, type is %s\n",$2->lineno, $1->typestring.c_str());
			 exit(69);
		}
		if (!check_number($3)) {
			 dprintf(stderr_copy, "TypeError at line %d: Invalid type of second summand for addition, type is %s\n",$2->lineno, $3->typestring.c_str());
			 exit(69);
		}
		if ($1->typestring == "complex" || $3->typestring == "complex") {
			$$->typestring = "complex";
		} else if ($1->typestring == "float" || $3->typestring == "float"){
			$$->typestring = "float";
		} else { //i.e. ints/bools + ints/bools => always int
			$$->typestring = "int";
		}
		gen($$,$1, $3, ADD);
}
	| sum "-" term	{
		$$ = new Node ("-"); 
		$$->addchild ($1); 
		$$->addchild($3);
		
		if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
			exit(1);
		}
		
		if (!check_number($1)) {
			 dprintf(stderr_copy, "TypeError at line %d: Invalid type of first summand for addition, type is %s\n",$2->lineno, $1->typestring.c_str());
			 exit(69);
		}
		if (!check_number($3)) {
			 dprintf(stderr_copy, "TypeError at line %d: Invalid type of second summand for addition, type is %s\n",$2->lineno, $3->typestring.c_str());
			 exit(69);
		}
		if ($1->typestring == "complex" || $3->typestring == "complex") {
			$$->typestring = "complex";
		} else if ($1->typestring == "float" || $3->typestring == "float"){
			$$->typestring = "float";
		} else { //i.e. ints/bools + ints/bools => always int
			$$->typestring = "int";
		}
		gen($$, $1, $3, SUB);
}
	| term {
	if ($1->typestring == "")	{
		dprintf(stderr_copy, "NameError at line %d: undefined variable, caught at sum: term production\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}

term: term "*" factor	{
	$$ = new Node ("*");
	$$->addchild ($1);
	$$->addchild($3);
	
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	
	if (!check_number($1)) {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of first summand for addition, type is %s\n",$2->lineno, $1->typestring.c_str());
		 exit(69);
	}
	if (!check_number($3)) {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of second summand for addition, type is %s\n",$2->lineno, $3->typestring.c_str());
		 exit(69);
	}
	if ($1->typestring == "complex" || $3->typestring == "complex") {
		$$->typestring = "complex";
	} else if ($1->typestring == "float" || $3->typestring == "float"){
		$$->typestring = "float";
	} else { //i.e. ints/bools + ints/bools => always int
		$$->typestring = "int";
	}
	gen($$,$1, $3, MUL);
}
	| term "/" factor	{
	$$ = new Node ("/");
	$$->addchild ($1);
	$$->addchild($3);
	
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	
	if (!check_number($1)) {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of dividend for division, type is %s\n",$2->lineno, $1->typestring.c_str());
		 exit(69);
	}
	if (!check_number($3)) {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of divisor for division, type is %s\n",$2->lineno, $3->typestring.c_str());
		 exit(69);
	}
	if ($1->typestring == "complex" || $3->typestring == "complex") {
		$$->typestring = "complex";
	} else { //all other cases: float
		$$->typestring = "float";
	}
	gen($$,$1, $3, DIV);
}
	| term "%" factor	{
		//modulo not defined for complex num
	$$ = new Node ("%");
	$$->addchild ($1);
	$$->addchild($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	
	if (!check_number($1) || $1->typestring == "complex") {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of first argument for modulo, type is %s\n",$2->lineno, $1->typestring.c_str());
		 exit(69);
	}
	if (!check_number($3) || $3->typestring == "complex") {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of second argument for modulo, type is %s\n",$2->lineno, $3->typestring.c_str());
		 exit(69);
	}
	
	if ($1->typestring == "float" || $3->typestring == "float") {
		$$->typestring = "float";
	} else {
		$$->typestring = "int";
	}
	
	//to add: gen
}
	| term DOUBLESLASH factor {
	$$ = new Node ("//");
	$$->addchild ($1);
	$$->addchild($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
		exit(1);
	}
	
	if (!check_number($1) || $1->typestring == "complex") {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of first argument for floor division, type is %s\n",$2->lineno, $1->typestring.c_str());
		 exit(69);
	}
	if (!check_number($3) || $3->typestring == "complex") {
		 dprintf(stderr_copy, "TypeError at line %d: Invalid type of second argument for floor division, type is %s\n",$2->lineno, $3->typestring.c_str());
		 exit(69);
	}
	
	if ($1->typestring == "float" || $3->typestring == "float") {
		$$->typestring = "float";
	} else {
		$$->typestring = "int";
	}
	
	//to add: gen
}
	| factor {
	if ($1->typestring == "")	{
		dprintf(stderr_copy, "NameError at line %d: undefined variable, caught at term: factor production\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}
factor: "+" factor	{
	$$ = new Node ("+");
	$$->addchild($2);
	if ($2->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $2->lineno);
		exit(1);
	}
	if (!check_number($2)) {
		dprintf(stderr_copy, "TypeError at line %d: Invalid type for setting positive, type is %s\n",$2->lineno, $2->typestring.c_str());
		exit(1);
	}
	
	$$->typestring = $2->typestring;
	//to add: gen
}
	| "-" factor	{
	$$ = new Node ("-");
	$$->addchild($2);
	if ($2->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $2->lineno);
		exit(1);
	}
	if (!check_number($2)) {
		dprintf(stderr_copy, "TypeError at line %d: Invalid type for setting negative, type is %s\n",$2->lineno, $2->typestring.c_str());
		exit(1);
	}
	
	$$->typestring = $2->typestring;
	//to add: gen
}
	| "~" factor	{
	$$ = new Node ("~");
	$$->addchild($2);
	if ($2->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $2->lineno);
		exit(1);
	}
	if (!check_number($2) || $2->typestring != "int" && $2->typestring != "bool") {
		dprintf(stderr_copy, "TypeError at line %d: Invalid type for unary not, type is %s\n",$2->lineno, $2->typestring.c_str());
		exit(1);
	}
	
	$$->typestring = "int"; //always
}
	| power {
	if ($1->typestring == "")	{
		dprintf(stderr_copy, "NameError at line %d: undefined variable, caught at factor: power production\n", $1->lineno);
		exit(1);
	}
	$$ = $1;
}
power: primary {
	current_scope = NULL;
	$$ = $1;
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: undefined variable, caught at power: primary production\n", $1->lineno);
		exit(1);
	}
}
	| primary "**" factor	{
	$$ = new Node ("**");
	$$->addchild($1);
	$$->addchild($3);
	current_scope = NULL;
	if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $1->lineno);
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier undefined\n", $3->lineno);
			exit(1);
		}
		
		if (!check_number($1)) {
			 dprintf(stderr_copy, "TypeError at line %d: Invalid type of first summand for addition, type is %s\n",$2->lineno, $1->typestring.c_str());
			 exit(69);
		}
		if (!check_number($3)) {
			 dprintf(stderr_copy, "TypeError at line %d: Invalid type of second summand for addition, type is %s\n",$2->lineno, $3->typestring.c_str());
			 exit(69);
		}
		if ($1->typestring == "complex" || $3->typestring == "complex") {
			$$->typestring = "complex";
		} else if ($1->typestring == "float" || $3->typestring == "float"){
			$$->typestring = "float";
		} else { //i.e. ints/bools + ints/bools => always int
			$$->typestring = "int";
		}
		
		//to add: gen
}

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
		Node * handle;
		$$ = $1;
		$$->islval = true;
		$$->isdecl = true;
		if (top->has($1->production)){
			$$->typestring = top->get($1)->typestring;
			$$->dimension = top->get($1)->dimension;
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
			dprintf (stderr_copy, "Error at line %d: %s is undefined\n", (int)$3->lineno,$1->production.c_str());
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
			current_scope = current_scope->find_member_fn($3->production);
			$$->addr = $1->typestring +"_" + $3->production;
			 // the only case in which current_scope is truly global
		}
		else{
			$$->typestring = current_scope->gettype($3->production);
			gen($$,$1,$3,ATTR);
		}
		$$->production = $3->production;
		if (!$$->isdecl && $$->typestring == "") {
			dprintf (stderr_copy, "Error at line %d: Class %s does not have attribute %s\n",
					(int) $3->lineno, $1->typestring.c_str(), $3->production.c_str());
			exit (84);
		}
		$$->lineno = $1->lineno;

		/*
			$ new temp 
			$$->addr = newtemp();
			$1->addr = top->getaddr($1);
			$3->addr = current_scope->getaddr($3);
		*/


	}

	| primary "[" test "]"
		{
			$$->isdecl = false;
			$$->islval = true;
			if ($1->isLeaf && !top->has($1)) {
				dprintf (stderr_copy, "Error undeclared object %s at line %d", $1->production.c_str(), $3->lineno);
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
			if($3->isConstant){
				if($3->intVal > $1->dimension){
					dprintf (stderr_copy, "Error at line %d: index out of bounds\n",
						yylineno);
					exit (1);
				}
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
		$$->typestring = $1->typestring;
		$$->islval = true;
		$$->isdecl = false;
		$$->dimension = $1->dimension - 1;

		gen($$, $1, $3, SUBSCRIPT);

		}
	| primary "(" testlist ")" {
		/*
			for i in range(primary->arg_types.size())
				if(primary->arg_types[i] != testlist->children[i]->typestring) error
			update $$->typestring as return type of function
		*/
		$$ = new Node (0, "", "");
		$$->islval = false;
		$$->isdecl = false;
		if ($1->isLeaf) {
			if (top->find_member_fn ($1->production)) {
				current_scope = top->find_member_fn($1->production);
				$$->typestring = current_scope->return_type;
				$$->addr = "call "+ $1->addr + ", "+ to_string(current_scope->arg_types.size());
#if TEMPDEBUG
				printf ("valid call to function %s in line %d\n", $1->production.c_str(), $1->lineno);
#endif
				// fill 3ac for function call
			} else if (globalSymTable->ctor.find($1->production) != globalSymTable->ctor.end()) { // call to constructor
				current_scope = globalSymTable->ctor.find ($1->production)->second;
#if TEMPDEBUG
				printf ("line %d valid call to constructor %s\n", $1->lineno, $1->production.c_str());
#endif
				$$->typestring = $1->production;
			} else if (globalSymTable->children.find($1->production) != globalSymTable->children.end()) {
				current_scope = globalSymTable->children.find ($1->production)->second;
				$$->typestring = current_scope->return_type;
			} else {
				dprintf (stderr_copy, "Error at line %d: Call to undefined function %s.\n", $1->lineno, $1->production.c_str());
				exit(44);
			}
		} else { // now we expect typestring to be set to def, symboltable to be available in current_scope
			if ($1->typestring != "def") {
				dprintf (stderr_copy, "TypeError at line %d: Function call to object of type %s.\n", $2->lineno, $1->typestring.c_str());
				exit(45);
			} else { // valid function call
#if TEMPDEBUG
				printf ("valid function call to function %s\n",
						current_scope ? current_scope->name.c_str() : "" );
#endif
			}
		}
		printf("typestring = %s\n", $$->typestring.c_str());
		$$->lineno = $1->lineno;
		
		// check function_call_args
		int iter;
		if (function_call_args.size() != current_scope->arg_types.size()) {
			dprintf (stderr_copy, "Error at line %d: Function call expected %d arguments, received %d\n",
					(int)$1->lineno, current_scope->arg_types.size(), function_call_args.size());
			exit (60);
		}
#define VALID_PAIR(type1, type2)	\
		(function_call_args[iter]->typestring == type1 && current_scope->arg_types[iter] == type2)

		for (iter = 0; iter< current_scope->arg_types.size(); iter ++) { 
			cout << "twdfdvwfere\n";
			cout << function_call_args[iter]->typestring << current_scope->arg_types[iter] << function_call_args_dim[iter] << current_scope->arg_dimensions[iter]<<endl;
			if (function_call_args[iter]->typestring == (current_scope->arg_types)[iter]
					&& function_call_args_dim[iter] == (current_scope->arg_dimensions)[iter])
				continue;
			if (VALID_PAIR( "int", "bool") || VALID_PAIR( "int", "float") ||VALID_PAIR( "bool", "int") || VALID_PAIR( "int", "bool")
					&& function_call_args_dim[iter] == current_scope->arg_dimensions[iter])
				continue;
			if (function_call_args[iter]->typestring != current_scope->arg_types[iter])
				dprintf (stderr_copy, "TypeError at line %d: expected %dth argument to be %s, received incompatible type %s\n",
						(int) $1->lineno, iter, current_scope->arg_types[iter].c_str(), function_call_args[iter]->typestring.c_str());
			else
				dprintf (stderr_copy, "TypeError at line %d: expected %dth argument to be of type %s, received incompatible type %s\n",
						(int) $1->lineno,
						(current_scope->arg_types[iter] +(current_scope->arg_dimensions[iter] ? "[]" : "")).c_str(),
						(current_scope->arg_types[iter] +(function_call_args_dim[iter]? "[]" : "")).c_str()
						);
			exit(80);
		}
		function_call_args.clear();
		function_call_args_dim.clear();
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
			if(is_not_name($1)){
				dprintf (stderr_copy, "Error at line %d: invalid function call\n", $1->lineno);
				exit(1);
			}
			if (top->find_member_fn ($1->production)) {
				// $1->typestring = "def";
				$$->typestring = top->find_member_fn($1->production)->return_type;
				$$->addr = "call "+ $1->addr;
				current_scope = top->find_member_fn($1->production);

#if TEMPDEBUG
				printf("typestring = %s\n", $$->typestring.c_str());
				printf ("valid call to function %s in line %d\n", $1->production.c_str(), $1->lineno);
#endif
				// fill 3ac for function call
			} else if (globalSymTable->ctor.find($1->production) != globalSymTable->ctor.end()) { // call to constructor
#if TEMPDEBUG
				printf ("line %d valid call to constructor %s\n", $1->lineno, $1->production.c_str());
#endif
				$$->typestring = $1->production;
#if TEMPDEBUG
				cout<<"return type of constructor "<<$$->typestring<<endl;
#endif
			} else if (globalSymTable->children.find($1->production) != globalSymTable->children.end()) {
				current_scope = globalSymTable->children.find ($1->production)->second;
				$$->typestring = current_scope->return_type;
			} else if (globalSymTable->find_member_fn ($1->production)) {
				current_scope = globalSymTable->find_member_fn($1->production);
				$$->typestring = current_scope->return_type;
			} else {
				dprintf (stderr_copy, "Error at line %d: Call to undefined function %s.\n", $1->lineno, $1->production.c_str());
				exit(44);
			}
		} else { // now we expect typestring to be set to def, symboltable to be available in current_scope
			if ($1->typestring != "def") {
				dprintf (stderr_copy, "TypeError at line %d: Function call to object of type %s.\n", $2->lineno, $1->typestring.c_str());
				exit(45);
			} // valid function call
#if TEMPDEBUG
			printf ("valid function call to function %s\n",
			current_scope ? current_scope->name.c_str() : "" );
#endif
		}
		$$->islval = false;
		$$->isdecl = false;
		$$->typestring = ($$->typestring != "" ?  $$->typestring: current_scope->return_type);
		// printf("typestring = %s\n", $$->typestring.c_str());
		$$->lineno = $1->lineno;
		if (0 != current_scope->arg_types.size()) {
			dprintf (stderr_copy, "Error at line %d: Function call expected %d arguments, received %d\n",
					(int)$1->lineno, current_scope->arg_types.size(), 0);
			exit (60);
		}
		function_call_args.clear();
		function_call_args_dim.clear();
		current_scope = NULL;
	}





/* TO DO 
	Pass the lineno, datatype from the lexer through node
*/
atom: NAME 
    | NUMBER
    | STRING_plus {
		$$ = $1;
		$$->production = concatenating_string_plus;
		concatenating_string_plus = "\0";
		$$->typestring = "str";

		static_section += "\t<string literal> l_" + to_string ($$->nodeid) + "\t: \"" + $$->production + "\"\n" ;
	}
	|"(" test ")"{$$=$2;}
    | "True"
    | "False" 
    | "None" 
	| "[" list_start testlist "]" {
		 $$ = $3;
		 string temp;
		 temp +="[  ] Contained\n";
		 temp += $3->production;
	 	$$->rename(temp);
		list_init = false;
		// lists are the ONLY way to increase the refcounts of objects, so we cannot store lists of pointers to possibly stack objects. Copy the damn thing.
		if (find_class (currently_defining_identifier_typestring) == NULL || find_class(currently_defining_identifier_typestring)->table_size > 8)
			{ dprintf (stderr_copy, "HAVENT IMPLEMENTED LISTS OF NON-PRIMITIVES\n"); exit (55); }
		// Node* $$ = new Node (0, "", "");
		$$->addr= newtemp();
		int thissize = find_class (currently_defining_identifier_typestring)->table_size;
		fprintf (tac, "\t%s = ALLOC_HEAP (%lu)\n", dev_helper($$).c_str(), list_init_inputs.size() * thissize);
		for(auto itrv:list_init_inputs){
			// 3ac to copy list to temp
			if (ISPRIMITIVE (itrv)) 
				gen ($$, itrv, (Node*) NULL, SW);
				fprintf(tac, "\t%s= %s + %d\n", dev_helper($$).c_str(), dev_helper($$).c_str(), thissize);
			}
			else{}
		}
		fprintf(tac, "\t%s = %s - %lu\n", dev_helper($$).c_str(), dev_helper($$).c_str(), list_init_inputs.size() * thissize);
		$$->typestring = currently_defining_identifier_typestring;
		$$->isLeaf = false;
		$$->dimension = list_init_inputs.size();
		list_init_inputs.clear();
		function_call_args.clear();
		function_call_args_dim.clear();
	}
	/* Empty list not needed */
list_start :
	{	list_init = true;
	}
STRING_plus: STRING {
		string tmp = $1->production;
		int len_str = tmp.size();
		if (tmp.substr (0, 3) == "\"\"\"" || tmp.substr (0, 3) == "'''")
			$1->production = tmp.substr (3, len_str - 6);
		else
			$1->production = tmp.substr (1, len_str - 2);
		if (concatenating_string_plus == "\0")
			concatenating_string_plus = $1->production;
	}
	| STRING_plus STRING {
		string tmp2 = $2->production;
		int len_str2 = tmp2.size();
		if (tmp2.substr (0, 3) == "\"\"\"" || tmp2.substr (0, 3) == "'''")
			$2->production = tmp2.substr (3, len_str2 - 6);
		else
			$2->production = tmp2.substr (1, len_str2 - 2);
		concatenating_string_plus = concatenating_string_plus + $2->production;
		 $$ = new Node ("Multi String"); $$->addchild($1); $$->addchild($2);}

if_stmt: "if" test new_jump_to_end insert_jump_if_false ":" suite[ifsuite] insert_end_jump_label jump_target_false_lower upper_jump_target_reached { $$ = new Node ("If Block"); $$->addchild($2, "If"); $$->addchild($ifsuite, "Then");
		 }
	|  "if" test new_jump_to_end insert_jump_if_false ":" suite[ifsuite] insert_end_jump_label jump_target_false_lower elif_block[elifsuite] {$$ = new Node ("If Else Block"); $$->addchild($2, "If"); $$->addchild($ifsuite, "Then"); $$->addchild($elifsuite, "Else"); }

elif_block:
	"else" ":" suite upper_jump_target_reached 	{ $$ = $3;}
	| "elif" test ":" insert_jump_if_false suite[elifsuite]	jump_target_false_lower upper_jump_target_reached 
	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($elifsuite, "Then"); } /* ok????? fine */ 
	| "elif" test ":" insert_jump_if_false suite[elifsuite] insert_end_jump_label jump_target_false_lower elif_block[nextblock]	
	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($elifsuite, "Then"); $$->addchild ($nextblock, "Else"); }

while_stmt: "while" begin_loop_condition test[condition] ":" insert_jump_if_false suite[action] loop_end_jump_back jump_target_false_lower {$$ = new Node ("While"); $$->addchild($condition, "Condition"); $$->addchild($action, "Do");}

begin_loop_condition : {
		fprintf (tac, "\nLABEL: %s\n", get_next_label_upper("loop").c_str());
	}

loop_end_jump_back : {
		fprintf (tac, "\tUJUMP %s\n", get_current_label_upper().c_str());
	}

insert_jump_if_false : {
				fprintf (tac, "\tCJUMP_IF_FALSE (%s):\t%s\n", dev_helper($<node>-1).c_str(), get_next_label("").c_str());
	}
jump_target_false_lower : {
		fprintf (tac, "\nLABEL: %s\n", get_current_label().c_str());
	}

new_jump_to_end : {
			// jump to the end of the if-elif-else sequence
			// insert at the end of every suite, to jump to the end.
			get_next_label_upper("end_of_control_flow");
	}
insert_end_jump_label : {
		fprintf (tac, "\tUJUMP\t%s\n", jump_labels_upper.top().c_str());
	}
upper_jump_target_reached : {
		fprintf (tac, "\nLABEL:\t%s\n", get_current_label_upper().c_str());
	}

arglist: test[obj]
	{
		if (list_init) { // NUMBER, STRING, CLASS, BOOL, NONE
			// base of the list is a static region in memory but we don't know the length yet. so store in a vector for now
			list_init_inputs.push_back ($obj);
		}
		function_call_args.push_back ($obj);
		function_call_args_dim.push_back ((bool) $obj->dimension);
	}
	| arglist "," test[obj] { $$ = new Node ("Multiple terms"); $$->addchild($1); $$->addchild($3);
		if (list_init)
			list_init_inputs.push_back ($obj);
		function_call_args.push_back ($obj);
		function_call_args_dim.push_back ((bool) $obj->dimension);
	}



typedarglist:  typedargument {/*top->arguments push*/}
	| NAME {/*this pointer in case inClass==1 otherwise error*/
		if (!Classsuite) {
			dprintf (stderr_copy, "Error in line %d: Argument %s to function does not have a type hint\n", $1->lineno, $1->production.c_str());
			exit (77);
		}
		if (top->thisname != "") {
			dprintf (stderr_copy, "Error in line %d: Argument %s to function does not have a type hint. \"this\" pointer has been declared.\n", $1->lineno, $1->production.c_str());
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
			dprintf (stderr_copy, "Error at line %d: Unknown type hint %s to function parameters\n", $1->lineno, $3->production.c_str());
			exit (42);
		}
		if (top->symbols.find($1->production) != top->symbols.end()) {
			dprintf (stderr_copy, "Error at line %d: identifier %s redeclared in function scope\n", $1->lineno, $1->production.c_str());
			exit(49);
		}
		put ($1, $3);
		top->arg_types.push_back ($3->production);
		top->arg_dimensions.push_back ((bool) $3->dimension);
	}

suite:  simple_stmt[first] 
	| NEWLINE  INDENT  stmts[third] DEDENT 
/* when using multiple mid-rule actions avoid using $1, $2, $3 as its more rigid to code changes*/
/* use common non terminal (like functionstart here) to use mid-rule actions if getting reduce reduce error( which occurs if two rules have the same prefix till the code segment and the lookahead symbol after the code is also same)  */


funcdef: "def" NAME[id]  functionstart "(" typedarglist_comma[param] ")" "->" typeclass[ret] {
	top->return_type = $ret->production;
}":" suite[last] {
		Funcsuite=0;
		endscope(); inside_init = 0;
		$$ = new Node ("Function Defn");
		$$->addchild($id, "Name");
		$$->addchild($param,"Parameters");
		$$->addchild($ret, "Return type");
		$$->addchild($last, "Body");
		function_call_args_dim.clear();
		function_call_args.clear();
	}
	| "def" NAME[id] functionstart "(" ")" "->" typeclass[returntype] {
		top->return_type = $returntype->production;
	} ":" suite[last] {
	       	Funcsuite=0;
		endscope(); inside_init = 0;
	       	$$ = new Node ("Function Defn"); $$->addchild($id, "Name");
	       	$$->addchild($returntype, "Return type");
	       	$$->addchild($last, "Body");
			function_call_args_dim.clear();
			function_call_args.clear();
			
	}
	| "def" NAME[id] functionstart "(" typedarglist_comma[param] ")" ":" {
			top->return_type = "None";
		}
		suite[last] {
	       	Funcsuite=0;
		endscope(); inside_init = 0;
	       	$$ = new Node ("Function Defn");
	       	$$->addchild($id, "Name");
	       	$$->addchild($param,"Parameters");
	       	$$->addchild($last, "Body");
	}
	| "def" NAME[id] functionstart "(" ")" ":" {
			top->return_type = "None";
	}suite[last] {
	       	Funcsuite=0;
		endscope(); inside_init = 0;
		$$ = new Node ("Function Defn");
		$$->addchild($id, "Name");
		$$->addchild($last, "Body");
		function_call_args_dim.clear();
		function_call_args.clear();
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
		function_call_args.clear();
		function_call_args_dim.clear();
	}
;
classdef: "class" NAME classstart ":"{
		function_call_args_dim.clear();
		function_call_args.clear();}  suite[last] {
	Classsuite=0;
	$$ = new Node ("Class");
	$$->addchild($2, "Name");
	$$->addchild($last, "Contains");
	inside_init = 0; // endscope();
	currently_defining_class = NULL;
}

classstart: /*empty*/ {
#if TEMPDEBUG
	printf ("start class scope");
	printf ("scope name %s\n", $<node>0->production.c_str()); //$0: the NAME before it on the stack (see classdef)
#endif
	if (currently_defining_class || Classsuite) {
		dprintf (stderr_copy, "Error: Nested declaration of classes\n");
		exit(43);
	}
	Classsuite = 1;
	currently_defining_class = new SymbolTable (top, CLASS_ST, $<node>0->production);
	// top = top->parent;
	currently_defining_class->lineno = $<node>0->lineno;
} | "(" ")" {
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
}| "(" NAME[parent] ")"	{
#if TEMPDEBUG
	printf ("start class scope");
	printf ("scope name %s\n", $<node>0->production.c_str());
#endif
	if (currently_defining_class || Classsuite) {
		dprintf (stderr_copy, "Error: Nested declaration of classes\n");
		exit(43);
	}
	printf("Checking parent class %s\n", $parent->production.c_str());
	//check if parent class exists/is a class
	SymbolTable *parent = find_class($parent->production);
	if (!parent) {
		dprintf(stderr_copy, "NameError: %s is not a class\n", $parent->production.c_str());
		exit(1);
	}
	Classsuite = 1;
	currently_defining_class = new SymbolTable (top, CLASS_ST, $<node>0->production);
	//just copy all members of parent class symbol table to new symbol table
	for (const auto &entry : parent->symbols) {
		currently_defining_class->symbols[entry.first] = entry.second;
	}
	
	for (const auto &entry : parent->children) {
		currently_defining_class->children[entry.first] = entry.second;
	}
	
	for (const auto &entry : parent->ctor) {
		currently_defining_class->ctor[entry.first] = entry.second;
	}
	currently_defining_class->table_size = parent->table_size;
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
	tac = stderr;
	label_count = 0;
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

	static_section = "Static Section:\n" ;
	concatenating_string_plus = "\0";
	
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
	if (static_section != "Static section:\n")
		cout << static_section << endl;
	if (jump_labels_upper.size() != 0 || jump_labels.size() != 0)
		printf ("Error stacks not empty\n");
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

int check_number(Node* n) {
	//return 1 if number, 0 if not
	if (n->dimension != 0) {
		dprintf(stderr_copy, "Error: found array where expected single type (see following message)\n");
		return 0;
	}
	if (n->typestring != "bool"
	 && n->typestring != "int"
	 && n->typestring != "float"
	 && n->typestring != "complex") {
	 	return 0;
	}
	return 1;
}
