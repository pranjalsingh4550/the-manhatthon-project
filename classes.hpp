#include<bits/stdc++.h>
#include <vector>

#define ull unsigned long

using namespace std;

extern int nodecount;
extern int tempcount;
extern bool inside_init;
extern FILE *graph;
extern int yylineno;
static FILE* tac = NULL;
class SymbolTable;
extern SymbolTable* top;
extern SymbolTable* globalSymTable;

enum ir_operation {
	UJUMP,
	CJUMP_IF_FALSE,	// CONDITIONAL JUMP
	CJUMP_IF_TRUE,	// CONDITIONAL JUMP
	LW,
	SW,
	LI,
	RETQ,	// RETURN
	MOV_REG,

	//only for 3AC
	ASSIGN,
	ADD,
	SUB,
	MUL,
	DIV,
	MOD,
	AND_log,
	OR_log,
	NOT_log,
	OR_bit,
	AND_bit,
	NOT_bit,
	EQ,
	NEQ,
	GT,
	GTE,
	LT,
	LTE,
	SHL,
	SHR,
	XOR,
	NEG,
	POW,
	FLOORDIV,

	ATTR,
	SUBSCRIPT,
	//
	ANDBW,	// bitwise and
	ORBW,	// BITWISE OR
	NOTBW,	// BITWISE NOT
	ORBL,	// BOOLEAN
	ANDBL,	// BOOLEAN
	NOTBL,	//BOOLEAN

	XORBW,
	SHRBW,
	SHLBW,

	CMPEQ,
	CMPNE,
	CMPGT,
	CMPGE,
	CMPLT,
	CMPLE,

	ADDI,
	SUBI,
	MULI,
	DIVI,
	FLOORI,
	MODI,
	EXPI,

	ADDF,
	SUBF,
	MULF,
	DIVF,
	FLOORF,
	MODF,
	EXPF,

	INT2FL,
	FL2INT,

	// function/stack stuff
	FUNCTION_CALL, //x86's callq: push rbp, mov rsp to rbp, etc
	FUNCTION_RETURN,

	ALLOC_HEAP,

	MARK_FALSE,
	STREQ,
	STRCMP,
	PTR,
	DEREF,
};

enum datatypes {
	TYPE_INT = 1,	// bool will be stored as 0/1
	TYPE_FLOAT = 2,
	TYPE_COMPLEX = 4,
	// reorder this later, so that instead of an if-block for a*b,
	// we use result.type = max (a.type, b.type)
	TYPE_STR = 0x10,
	TYPE_VOID = 0x20,
	TYPE_ERROR = 0x40,
	TYPE_IDENTIFIER = 0x80
};


#define ISINT(dtype) (dtype == 1)
#define ISFLOAT(dtype) (dtype == 2)
#define ISCOMPLEX(dtype) (dtype == 4)
#define ISNUM(dtype) (!(dtype >> 3))
#define ISID(dtype) (dtype & 0x80)
#define ISLITERAL(dtype) (dtype & 0x1f)
#define ARITHMETIC_OP_RESULT(op1, op2)	\
	( ISNUM (op1 | op2)? (op1 > op2 ? op1 : op2): 0)
// returns 0 on error

typedef struct {
	double real;
	double imag;
} complexLiteral;



class Node {
		public:
		int nodeid;
		int token;
		string production;
		string typestring = "";
		int lineno;
		vector<Node*> children;

		// for 3AC
		string addr;

		//children used for lists etc.
		
		enum datatypes type;
		enum ir_operation op;
		long int intVal;
		short int dimension = 0;
		double floatVal;
		string strVal;
		complexLiteral complexVal;
		
		bool isConstant = false;
		bool isLeaf = false;
		bool isdecl = false;	// true if the node can be the body of a production
		bool islval = false;
		
		Node (int tokenIn) {
			//none, but let the lexer pass the token value so that I don't have to include parser.tab.h here
			token = tokenIn;
			// nodeid = nodecount++;
			typestring = "";
			lineno = yylineno;
			isConstant = true;
			isLeaf = true;
		}
		Node (int tokenIn, const string typestr, const string label) {
			//for identifiers
			token = tokenIn;
			nodeid = nodecount++;
			typestring = typestr;
			production = label;
			lineno = yylineno;
			addr = label;
			isLeaf = true;
		}
		
		Node (int tokenIn, long int value) {
			token = tokenIn;
			// nodeid = nodecount++;
			typestring = "int";
			lineno = yylineno;
			type = TYPE_INT;
			addr = to_string(value);
			isConstant = true;
			intVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, double value) {
			token = tokenIn;
			// nodeid = nodecount++;
			typestring = "float";
			addr=to_string(value);
			lineno = yylineno;
			type = TYPE_FLOAT;
			isConstant = true;
			floatVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, complexLiteral value) {
			token = tokenIn;
			// nodeid = nodecount++;
			typestring = "complex";
			lineno = yylineno;
			addr=to_string(value.real)+" + "+to_string(value.imag)+"i";
			type = TYPE_COMPLEX;
			isConstant = true;
			complexVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, string value) {
			//for string literals
			token = tokenIn;
			// nodeid = nodecount++;
			typestring = "str";
			lineno = yylineno;
			type = TYPE_STR;
			addr=value;
			isConstant = true;
			strVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, bool value) {
			token = tokenIn;
			// nodeid = nodecount++;
			typestring = "bool";
			lineno = yylineno;
			type = TYPE_INT;
			addr = value ? "1" : "0";
			isConstant = true;
			intVal = value;
			isLeaf = true;
			
		}
		
		Node (const string name) {
			//keywords
			nodeid = nodecount++;
			production = name;
			lineno = yylineno;
		}

		void rename(const string label) {
			production = label;
		}
		void addchild (Node* child) {
			children.push_back(child);
		}
		void addchild (Node *child, const string label) {
			children.push_back(child);
		}
		// overloaded ops below: add actions of the form leftchild OP child
		void addchild (Node* child, Node* leftchild) {
			children.push_back(child);
			// gen(leftchild, child, this->op);
		}
		void addchild (Node *child, const char* label, Node *leftchild) {
			children.push_back(child);
			// gen(leftchild, child, this->op);
		}
		void printnode () {
			cout << "Node id: " << nodeid << " Production: " << production << endl;
			for (auto child: children) {
				child->printnode();
			}
		}
		void gen (string left, string right, enum ir_operation op) {
			// should ir_operations be a map <str, int>? ??????
			switch(op){
				case ASSIGN	: fprintf(tac, "%s = %s\n", left.c_str(), right.c_str()); break;
				case ADD	: fprintf(tac, "%s = %s + %s\n", addr.c_str(), left.c_str(), right.c_str()); break;
				case SUB	: fprintf(tac, "%s = %s - %s\n", addr.c_str(), left.c_str(), right.c_str()); break;
				case MUL	: fprintf(tac, "%s = %s * %s\n", addr.c_str(), left.c_str(), right.c_str()); break;
				case DIV	: fprintf(tac, "%s = %s / %s\n", addr.c_str(), left.c_str(), right.c_str()); break;
			}
	};
};

struct str_struct {
	char* beginning;
	int length;
	int allocated_length; // probably won't be used but aligns the struct to 16B
};

#define FUNCTION_ST 1
#define CLASS_ST 2
#define MEMBER_FN_ST 3
#define CTOR_ST	4

class SymbolTable;

class Symbol {
	public:
		string name;
		string typestring;
		int lineno;
		bool isFunction = false;
		bool isClass = false;
		ull size = 0;
		ull offset=0;
		int dimension=0;
		Node* node;
		SymbolTable *nested_table;
		Symbol(){
			size = 0;
			name = "class";
			typestring = "";
		}
		Symbol (string , string , int , int , SymbolTable* );

		void print_row (FILE* st) {
			fprintf (st, "%s\t%s\t%s\t%d\n", this->name.c_str(), this->typestring.c_str(), "Identifier", (int) this->lineno);
		}

};

class SymbolTable {
	public:
		SymbolTable *parent;
		map<string, Symbol*> symbols;
		bool isFunction; // we don't need get/set helpers
		bool isClass;
		int isGlobal;
		int lineno;
		string name;
		string label=name;
		string thisname = "";
		string return_type="None";
		vector<string> arg_types; // for function, but class also ig
		vector<bool> arg_dimensions;
		bool fn_inside_class;

		int redef =0;
		// not using atm // map <string, SymbolTable*> classes; // if global
		// not using atm // map <string, SymbolTable*> member_functions; // for a class
		// not using atm // map <string, SymbolTable*> functions;
		map <string, SymbolTable*> children;	// contains member functions, classes&global functions for the global namespace
							// use children[name]->is{Class|Function} to check what it is
		map <string, SymbolTable*> ctor;	// contains all constructors
		int size = 0;
		unsigned long table_size = 0;
		bool has_children (string name) {
			if (children.find(name) != children.end()) {
				return false;
			}
			if (parent != NULL) {
				return parent->has_children(name);
			}
			return false;
		}
		SymbolTable* find_class (string name) { // returns SymbolTable* if name is a class, NULL otherwise
			printf ("finding class %s. number of children %ld, symbols %ld\n", 
					name.c_str(), this->children.size(), this->symbols.size());
			if (this->children.find(name) == this->children.end())
				return NULL; // NOT FOUND
			else if (this->children.find(name)->second->isFunction)
				return NULL;
			else
				return this->children.find(name)->second; // see comments above
		}
		SymbolTable* find_member_fn (string name) { // returns SymbolTable* if name is a class, NULL otherwise
			if (this->children.find(name) == this->children.end())
				return NULL; // NOT FOUND
			else if (this->children.find(name)->second->isClass)
				return NULL;
			else
				return this->children.find(name)->second; // see comments above
		}
		bool has (string name) {
			if (this->symbols.find(name) != this->symbols.end()) {
				return true;
			}
			if (parent != NULL) {
				return parent->has(name);
			}
			return false;
		}

		bool has(Node* node){ // has symbol. doesn';t check for classes/function
			return has(node->production);
		}
		bool local(Node* node) {
			if (this->symbols.find(node->production) != this->symbols.end()) {
				return true;
			}
			return false;
		}
		/*
		SymbolTable* has_suite(Node *node) {
			if (this->isClass && this->member_functions.find(


			if (this->classes.find(node->production) or parent scopes have productipon) // search recursively
				return 2;
			if (this->funco

		  */
		int put (Node* node, Node* type) {
#if TEMPDEBUG
			printf ("call to put source %s destination %s\n", type->production.c_str(), node->typestring.c_str());
#endif
			auto s= new Symbol();
			s->typestring = type->production; node->typestring = type->production;
			s->lineno = node->lineno;
			s->isFunction = 0;
			s->isClass = 0;
			s->name = node->production;
			this->symbols[node->production] = s;
			int width;
			if (globalSymTable->children.find (type->production) != globalSymTable->children.end()
					&& globalSymTable->children.find(type->production)->second->isClass)
				width = globalSymTable->children.find(type->production)->second->table_size;
			else
				printf ("Should not be here; someone forgot to check args to put()\n");
			s->offset = table_size;
			this->table_size += width;
			this->size = this->size + 1;
			s->dimension = type->dimension;
			s->node= node;
			if(node->isLeaf){
				s->node->addr+="_"+name;
			}
			return 1;
		}
		int put (Node* node, string type) {
#if TEMPDEBUG
			printf ("call to put source %s destination %s\n", type.c_str(), node->typestring.c_str());
#endif
			auto s= new Symbol();
			s->typestring = type; node->typestring = type;
			s->lineno = node->lineno;
			s->isFunction = 0;
			s->isClass = 0;
			s->name = node->production;
			this->symbols[node->production] = s;
			this->size = this->size + 1;
			int width;
			if (globalSymTable->children.find (type) != globalSymTable->children.end()
					&& globalSymTable->children.find(type)->second->isClass)
				width = globalSymTable->children.find(type)->second->table_size;
			else
				printf ("Should not be here; someone forgot to check args to put()\n");
			s->offset = table_size;
			this->table_size += width;
			s->dimension = 0;
			s->node= node;
			if(node->isLeaf){
				s->node->addr+="_"+name;
			}
			return 1;
		}
		Symbol* get (string name) {
			if(symbols.find(name) != symbols.end()) {
				return symbols[name];
			}
			if (parent != NULL) {
				return parent->get(name);
			}
			return NULL;
		}
		Symbol* get (Node* node) {
			return get(node->production);
		}
		Node* getnode (string name) {
			Symbol* s = get(name);
			if (s != NULL) {
				return s->node;
			}
			return NULL;
		}
		string getaddr(Node* node) {
			Symbol* s = get(node);
			if (s != NULL) {
				return s->node->addr;
			}
			return node->addr;
		}
		int putFunc(Node* node, Node* type, vector<Node*> args) {
			int ref=0;
			if(this->children.find(node->production) != this->children.end()) {
				ref=this->children[node->production]->redef+1;
				return 4;
			}
			SymbolTable *f = new SymbolTable(this, MEMBER_FN_ST, node->production); // node->production?
			f->name = node->production;
			f->return_type = type->production;
			for (auto arg: args) {
				f->arg_types.push_back(arg->production);
			}
			f->redef=ref;
			this->children[node->production] = f;
			return 1;
		}
		SymbolTable(SymbolTable *p) { // NOT THE DEFAULT CONSTRUCTOR: USE THE ONE IN parser.y
			parent = p;
			isFunction = false;
			isClass = false;
			isGlobal = true;
			lineno = 0;
			this->fn_inside_class = false;
			this->name = "global";
			// int, float complex bool str 
			children["class"] = new SymbolTable ("class", CLASS_ST, "class", 0);
			children["int"] = new SymbolTable ("class", CLASS_ST, "int", 8);
			children["float"] = new SymbolTable ("class", CLASS_ST, "float", 8);
			children["complex"] = new SymbolTable ("class", CLASS_ST, "complex", 16);
			children["bool"] = new SymbolTable ("class", CLASS_ST, "bool", 8);
			children["str"] = new SymbolTable ("class", CLASS_ST, "str", sizeof(struct str_struct));
			symbols["__name__"] = new Symbol ("__name__", "str", 0, 0, this);
			size = 0;
#if TEMPDEBUG
			printf ("Call to st ctor. now parent's size is %ld, number of children in parent is %ld\n", this->symbols.size(), this->children.size());
#endif
		}
		SymbolTable (SymbolTable* p, int flags, string name) {
			if (flags > 4 || flags < 1) {
				cerr << "Bad flags\n"; exit(6);
			}
			parent = p;
			this->name = name;
			if (isFunction = (flags == FUNCTION_ST))
				parent->children[name] = this;
			if (isClass = (flags == CLASS_ST))
				parent->children[name] = this;
			if (isFunction = (flags == CTOR_ST))
				parent->ctor[name] = this;
			isGlobal = false;
			lineno = 0;
			if (fn_inside_class = (flags == MEMBER_FN_ST))
				parent->children[name] = this;
#if TEMPDEBUG
			printf ("Call to st ctor %s. now parent's size is %ld, number of children in parent is %ld\n", name.c_str(), p->symbols.size(), p->children.size());
#endif
		}
		SymbolTable (string p, int flags, string name, int size) { // for primitives: int, char, bool, etc. may use later for print, range, len
			if (flags != CLASS_ST) {
				cerr << "Bad flags\n"; exit(6);
			}
			parent = NULL;
			this->name = name;
			this->table_size = size;
			isFunction= 0;
			isClass = (flags == CLASS_ST);
			isGlobal = true;
			lineno = 0;
			fn_inside_class = false;
		}
		string gettype (string name) {
			Symbol *s = this->get(name);
			if (s != NULL) {
				return s->typestring;
			}
			return "";
		}

		void print_st (FILE* st) {
			fprintf (st, "\n");
			auto itrs = this->symbols.begin();
			for (; itrs != this->symbols.end(); itrs++) {
				// symbols
				if (this->isGlobal) break;
					fprintf (st, "%s,%s%s,%s,%d,%s,%d\n", itrs->first.c_str(), 
							itrs->second->typestring.c_str(),
							itrs->second->dimension ? "[]" : "",
							"Identifier",
							itrs->second->lineno,
							this->isGlobal? "GLOBAL NAMESPACE" : 
								((this->isClass? "CLASS ": "FUNCTION ") + this->name).c_str(),
							(int)itrs->second->offset
							);
			}
			auto itrc = this->children.begin();
			for (; itrc!= this->children.end(); itrc++) {
				if (itrc->second->parent == NULL)
					continue;
				if (this->isGlobal)
					// classes and global functions names
					fprintf (st, "%s,%s,%s,%d,%s\n", itrc->first.c_str(), 
							itrc->second->isClass? "NA" : itrc->second->return_type.c_str(),
							itrc->second->isClass? "Class," : "Function",
							itrc->second->lineno,
							"GLOBAL NAMESPACE"
					);
				else if (this->isClass) 
					// class 
					fprintf (st, "%s,%s,%s,%d,CLASS %s\n", itrc->first.c_str(), 
							itrc->second->isClass? "NA" : itrc->second->return_type.c_str(),
							itrc->second->isClass? "Class," : "Class Method",
							itrc->second->lineno,
							this->name.c_str()
					);
			}
			itrc = this->children.begin();
			for (; itrc!= this->children.end(); itrc++) {
				if (itrc->second->parent == NULL)
					continue;
				itrc->second->print_st (st);
			}
			for (itrc = this->ctor.begin(); itrc != this->ctor.end(); itrc++) {
				itrc->second->print_st (st);
			}
		}
};
class instruction {
	public:
		enum ir_operation instr;
		Symbol* source1, source2, destination;
		bool operand_is_int;
		union {
			long literal2;
			double dliteral2;
		};
		union {
			long literal1;
			double dliteral1;
		};
#define IR_OPERAND1 (instr->operand_is_int ? instr->literal1: instr->dliteral1 )
#define IR_OPERAND2 (instr->operand_is_int ? instr->literal2: instr->dliteral2 )
		// not convinced about this setup yet
};
