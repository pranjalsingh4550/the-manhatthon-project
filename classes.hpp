#include<bits/stdc++.h>
#include <vector>

#define ull unsigned long

using namespace std;

extern int nodecount;
extern int tempcount;
extern bool inside_init;
extern int yylineno;
static FILE* tac = NULL;
extern FILE* x86asm;
class SymbolTable;
extern SymbolTable* top;
extern SymbolTable* globalSymTable;
extern void generic_if (string);
extern void generic_else (void);
extern void generic_exit (void);

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
		int isGlobal = 0;
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
		string label="";
		string thisname = "";
		string return_type="None";
		vector<string> arg_types; // for function, but class also ig
		vector<int> arg_dimensions;
		SymbolTable* parent_class = NULL;
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
		unsigned num_temps = 0;
		map <int, int> temp_variable_offsets;
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
			#if 0
			printf ("finding class %s. number of children %ld, symbols %ld\n", 
					name.c_str(), this->children.size(), this->symbols.size());
#endif
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
		int put (Node* node, Node* type) {
#if TEMPDEBUG
			printf ("call to put source %s destination %s\n", type->production.c_str(), node->typestring.c_str());
#endif
			auto s= new Symbol();
			s->typestring = type->production;
			node->typestring = type->production;
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
			this->table_size += 8;
			this->size = this->size + 1;
			s->dimension = type->dimension;
			s->node= node;
			if(node->isLeaf){
				s->node->addr+="@"+(label==""?name:label);
			}
			return 1;
		}
		int put (Node* node, string type,int globalflag=0) {
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
			this->table_size += 8;
			s->dimension = 0;
			s->node= node;
			s->isGlobal = globalflag;
			if(node->isLeaf){
				s->node->addr+="@"+(label==""?name:label);
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

		void print_local_symbols (FILE* st) {
			auto itrs = this->symbols.begin();
			fprintf (st, "\n");
			if (this->isFunction) fprintf (st, "Function: %s\n", label.c_str());
			if (this->isClass) fprintf (st, "Class: %s\n", name.c_str());
			for (; itrs != this->symbols.end(); itrs++) {
				// symbols
				if (this->isGlobal) break;
					if(itrs->second->isGlobal)continue;
					if (itrs->second->name == "self") continue;
					fprintf(st, "%s,%s%s,%s,%d,%s,%d,%s\n", itrs->first.c_str(), 
							itrs->second->typestring.c_str(),
							itrs->second->dimension ? "[]" : "",
							"Identifier",
							itrs->second->lineno,
							this->isGlobal? "GLOBAL NAMESPACE" : 
								((this->isClass? "CLASS ": "FUNCTION ") + this->name).c_str(),
							(int)itrs->second->offset,
							(this->isFunction ? (itrs->second->name + "@" + this->label) : "None").c_str()
							);
			}
			return ;
		}
			
		void print_st (FILE* st) {
			fprintf (st, "\n");
			auto itrs = this->symbols.begin();

			if (this->isFunction) fprintf (st, "Function: %s\n", label.c_str());
			for (; itrs != this->symbols.end(); itrs++) {
				// symbols
					// if (this->isGlobal) break;
					// if(itrs->second->isGlobal)continue;
					fprintf(st, "%s,%s%s,%s,%d,%s,%d,%s\n", itrs->first.c_str(), 
							itrs->second->typestring.c_str(),
							itrs->second->dimension ? "[]" : "",
							"Identifier",
							itrs->second->lineno,
							this->isGlobal? "GLOBAL NAMESPACE" : 
								((this->isClass? "CLASS ": "FUNCTION ") + this->name).c_str(),
							(int)itrs->second->offset,
							(itrs->second->name + "@" + this->label).c_str()
							);
			}
			auto itrc = this->children.begin();
			for (; itrc!= this->children.end(); itrc++) {
				if (itrc->second->parent == NULL) // primitive types
					continue;
				if (itrc->second->isClass) {
					// classes and global functions names
					fprintf (st, "%s,%s,%s,%d,%s\n", itrc->first.c_str(), 
							itrc->second->isClass? "NA" : itrc->second->return_type.c_str(),
							itrc->second->isClass? "Class," : "Function",
							itrc->second->lineno,
							"GLOBAL NAMESPACE"
					);
					itrc->second->print_local_symbols(st);
				}
			}
			for (; itrc!= this->children.end(); itrc++) {
				if (itrc->second->parent == NULL) // primitive types
					continue;
				if (itrc->second->isFunction) {
					// classes and global functions names
					fprintf (st, "%s,%s,%s,%d,%s\n", itrc->first.c_str(), 
							itrc->second->isClass? "NA" : itrc->second->return_type.c_str(),
							itrc->second->isClass? "Class," : "Function",
							itrc->second->lineno,
							"GLOBAL NAMESPACE"
					);
					itrc->second->print_local_symbols(st);
				}
			}
			return ;
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
		
		void print_st (void) {
			printf( "\n");
			auto itrs = this->symbols.begin();
			for (; itrs != this->symbols.end(); itrs++) {
				// symbols
				if (this->isGlobal) break;
					printf( "%s,%s%s,%s,%d,%s,%d,%s\n", itrs->first.c_str(), 
							itrs->second->typestring.c_str(),
							itrs->second->dimension ? "[]" : "",
							"Identifier",
							itrs->second->lineno,
							this->isGlobal? "GLOBAL NAMESPACE" : 
								((this->isClass? "CLASS ": "FUNCTION ") + this->name).c_str(),
							(int)itrs->second->offset,
							(itrs->second->name + "@" + this->label).c_str()
							);
			}
			auto itrc = this->children.begin();
			for (; itrc!= this->children.end(); itrc++) {
				if (itrc->second->parent == NULL)
					continue;
				if (this->isGlobal)
					// classes and global functions names
					printf( "%s,%s,%s,%d,%s\n", itrc->first.c_str(), 
							itrc->second->isClass? "NA" : itrc->second->return_type.c_str(),
							itrc->second->isClass? "Class," : "Function",
							itrc->second->lineno,
							"GLOBAL NAMESPACE"
					);
				else if (this->isClass) 
					// class 
					printf( "%s,%s,%s,%d,CLASS %s\n", itrc->first.c_str(), 
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
				itrc->second->print_st();
			}
			for (itrc = this->ctor.begin(); itrc != this->ctor.end(); itrc++) {
				itrc->second->print_st();
			}
		}

		void declare_temp (int index) {
			/* zero-based indexing
			when using t_* somewhere in TAC, let the ST know that we've used it
			checks if the index exceeds the current max index 
			this->num_temps = max (num_temps, index+1);
			*/
			if (index + 1 > num_temps) {
				temp_variable_offsets[index] = table_size;
				num_temps = index + 1;
				table_size += 8;
				#if TEMPDEBUG
				printf ("temp count increased t%d will be stored at offset %d\n", table_size - 8);
				#endif
			}
		}
#define NUM_CALLEE_SAVED 5
#define NUM_CALLER_SAVED 8
#define ASMDEBUG 1
		void spill_caller_regs() {
			/* rbx r12 r13 r14 r15 -> push in opposite order. push/pop rbp at the ends
			don't mess with rsp meanwhile
			rbp is pushed upon entry and restored upon exit
		 */
			#if ASMDEBUG
			printf ("entry to caller_regs: rsp, rbp are %x %x\n", 0, 0);
			#endif

			// fprintf (x86asm, "subq $0x%lx, %%rsp\n", table_size); // not needed with new setup
			fprintf (x86asm, "\n\tpushq %%r15\n");
			fprintf (x86asm, "\tpushq %%r14\n");
			fprintf (x86asm, "\tpushq %%r13\n");
			fprintf (x86asm, "\tpushq %%r12\n");
			fprintf (x86asm, "\tpushq %%rbx\n");
			table_size += 8*NUM_CALLEE_SAVED;

		}
		void restore_caller_regs() {
			// pop above 6 in opposite order
			// restore rsp because it may have been changed during calls to other functions
			// finally, return
			// fprintf (x86asm, "\nmovq %%rbp, %%rsp\n"); done by caller
			// fprintf (x86asm, "subq $0x%lx, %%rsp\n", NUM_CALLER_SAVED*8 + arg_types.size()*8);
			fprintf (x86asm, "\tpopq %%rbx\n");
			fprintf (x86asm, "\tpopq %%r12\n");
			fprintf (x86asm, "\tpopq %%r13\n");
			fprintf (x86asm, "\tpopq %%r14\n");
			fprintf (x86asm, "\tpopq %%r15\n");
			fprintf (x86asm, "\taddq $0x%lx, %%rsp\n", this->arg_types.size()*8);
			// now rbp is the old rbp, as specified by the Dev* ABI
			// as per x86 retq, rsp must be the rsp at the time of entry
		}
		void save_own_regs () { // before calling another function
			// push in opposite order: rax, rcx, rdx, rdi, rsi, r8, r9, r10, r11
			// check later: is rsp explicitly saved?
			
			// fprintf (x86asm, "\nmovq %%rbp, %%rsp\n");
			// fprintf (x86asm, "addq 0x%lx, %%rsp\n", table_size + num_temps*8 + NUM_CALLEE_SAVED*8);
			// done by do_function_call()

			fprintf (x86asm, "\tpushq %%r11\n");
			fprintf (x86asm, "\tpushq %%r10\n");
			fprintf (x86asm, "\tpushq %%r9\n");
			fprintf (x86asm, "\tpushq %%r8\n");
			fprintf (x86asm, "\tpushq %%rsi\n");
			fprintf (x86asm, "\tpushq %%rdi\n");
			fprintf (x86asm, "\tpushq %%rdx\n");
			fprintf (x86asm, "\tpushq %%rcx\n");
			// fprintf (x86asm, "\tpushq %%rax\n\n");

		}
		void restore_own_regs () { // after the above function returns
			// fprintf (x86asm, "\nmovq %%rbp, %%rsp\n"); this is the callee's responsibility
			// fprintf (x86asm, "addq 0x%lx, %%rsp\n", table_size + num_temps*8 + 6*8 + 9*8);
			// fprintf (x86asm, "\tpopq %%rax\n");
			fprintf (x86asm, "\tpopq %%rcx\n");
			fprintf (x86asm, "\tpopq %%rdx\n");
			fprintf (x86asm, "\tpopq %%rdi\n");
			fprintf (x86asm, "\tpopq %%rsi\n");
			fprintf (x86asm, "\tpopq %%r8\n");
			fprintf (x86asm, "\tpopq %%r9\n");
			fprintf (x86asm, "\tpopq %%r10\n");
			fprintf (x86asm, "\tpopq %%r11\n");
			fprintf (x86asm, "\tmovq %%rbp, %%rsp\n\n"); // no reason, just being cautious

		}
		long int get_rbp_offset (string reg_name) {
			// get rbp offset for: local_var@scope_name | t_* temporaries | saved registers
			if (reg_name.find('@') != string::npos) { // '@' in string name - local variable, not global or temporary
			string var_name(reg_name.begin(),find(reg_name.begin(), reg_name.end(), '@'));
				return symbols[var_name]->offset+8;
			} else if (reg_name[0] == 't') {
				// temporary
				return temp_variable_offsets[stoi (reg_name.substr (1, reg_name.size()))]+8;
			}
			else {
				exit(88);
			}
			return -1;
		}
		void asm_load_value(int reg,string name){
			fprintf (x86asm, "\tmovq -%ld(%%rbp), %%r%d\n", get_rbp_offset(name), reg);
		}
		void asm_store_value(int reg,string name){
			fprintf (x86asm, "\tmovq %%r%d, -%ld(%%rbp)\n", reg, get_rbp_offset(name));
		}
		void asm_load_value_r12(string name) {
			fprintf (x86asm, "\tmovq -%ld(%%rbp), %%r12\n", get_rbp_offset(name));
		}
		void asm_load_value_r13(string name) {
			fprintf (x86asm, "\tmovq -%ld(%%rbp), %%r13\n", get_rbp_offset(name));
		}
		void asm_store_value_r13 (string name) {
			fprintf (x86asm, "\tmovq %%r13, -%ld(%%rbp)\n", get_rbp_offset(name));
		}

		void do_function_call (SymbolTable* callee, vector<Node *> args, string self_ptr) {
			// handles function call as well as return from child
			// self_ptr is empty if it isn't a class method
			fprintf (x86asm, "\n\t# begin procedure call routine\n");
			fprintf (x86asm, "\tmovq %%rbp, %%rsp\n");
			fprintf (x86asm, "\tsubq $%ld, %%rsp\n", table_size);
			// begin activation record at this address

			save_own_regs();
			// x86 callq fills return address at rsp[0]
			// fill args in rsp[-1], rsp[-2], etc.

			fprintf (x86asm, "\tsub $16, %%rsp\n"); // space for return address and rbp

			if (self_ptr != "") {
				fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rcx\n", get_rbp_offset(self_ptr));
				fprintf (x86asm, "\tpushq %%rcx\n");
			}

			for (auto arg: args) {
				// use rcx as the temp register
				if (arg->addr != "")
					fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rcx\n", get_rbp_offset(arg->addr));
				else
					exit(printf ("internal error: addr not initialised\n"));
				fprintf (x86asm, "\tpushq %%rcx\n");
			}

			// take rsp back to the empty slot
			fprintf (x86asm, "\taddq $%ld, %%rsp\n", 8 * (2 + args.size())
						);
			fprintf (x86asm, "\tcallq %s\n",
					callee->label.c_str()
					);
			restore_own_regs();
			// not obligated to restore rsp

			fprintf (x86asm, "\t# end procedure call routine\n");
			return;
		}

		void child_enter_function() {
			fprintf (x86asm, "\t# begin procedure entry routine\n");
			fprintf (x86asm, "\tpushq %%rbp\n");
			this->table_size += 8; // is this needed? because rbp is already shifted by 8
			fprintf (x86asm, "\tmovq %%rsp, %%rbp\n");
			if (this->arg_types.size())
				fprintf (x86asm, "\tsubq $%ld, %%rsp\t# space for arguments filled earlier\n", (this->arg_types.size()) * 8);
			spill_caller_regs();
			fprintf (x86asm, "\t# end procedure entry routine\n\n");

		}

		void child_return() {

			fprintf (x86asm, "\t# begin procedure call routine\n");
			fprintf (x86asm, "\tleaq -%ld(%%rbp), %%rsp\n", (this->arg_types.size() + NUM_CALLEE_SAVED) * 8);
			restore_caller_regs();
			fprintf (x86asm, "\tmovq %%rbp, %%rsp\n");
			fprintf (x86asm, "\tpopq %%rbp\n");\
			if(name=="main"){
				fprintf(x86asm,"\tmovq $0, %%rax\n");
			}
			fprintf (x86asm, "\tretq\n");
			fprintf (x86asm, "\t# end activation record management\n");

		}

		void systemV_ABI_call_begin () {
			
			fprintf (x86asm, "\n\t# begin System V ABI procedure call routine\n");
			fprintf (x86asm, "\tmovq %%rbp, %%rsp\n");
			fprintf (x86asm, "\tsubq $%ld, %%rsp\n", table_size);
			save_own_regs();
			fprintf (x86asm, "\tmovq %%rsp, %%rbx\n");
			fprintf (x86asm, "\tandq $8, %%rbx\n");
			fprintf (x86asm, "\tsubq %%rbx, %%rsp \t# aligning to 16B\n");

			// begin activation record at this address
		}
		void systemV_ABI_call_end() {
			// procedure calls preserve rbp and rsp
			restore_own_regs();
			fprintf (x86asm, "\taddq %%rbx, %%rsp # undoing 16B alignment if needed\n");
		}
		void call_malloc(int size) {
			this->systemV_ABI_call_begin();
			fprintf (x86asm, "\tmovq $%d, %%rdx\n", size);
			fprintf (x86asm, "\tcallq malloc\n");
			// return value in rax
			this->systemV_ABI_call_end();
			return;
		}
		void call_printf (Node* arg) {
			if (arg->typestring != "int" && arg->typestring != "str" && arg->typestring != "bool") {
				fprintf (stderr, "TypeError at line %d: cannot print value of type %s\n", (int) arg->lineno, arg->typestring.c_str());
				exit (103);
			}
			this->systemV_ABI_call_begin();
			// arg->addr += "@" + top->name;

			if (arg->typestring == "str") // pointer is stored in the stack at address
				fprintf (x86asm, "\tleaq string_format(%%rip), %%rdi\n");
			else if (arg->typestring == "int")
				fprintf (x86asm, "\tleaq integer_format(%%rip), %%rdi\n");
			else if (arg->typestring == "bool") {
				fprintf (x86asm, "\tleaq string_format(%%rip), %%rdi\n");

				generic_if (arg->addr);
				fprintf (x86asm, "\tmovq true_string(%%rip), %%rsi\n");
				generic_else ();
				fprintf (x86asm, "\tmovq false_string(%%rip), %%rsi\n");
				generic_exit();
			}

					
			fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rsi\n", this->get_rbp_offset(arg->addr));
			fprintf (x86asm, "\tcallq printf\n");
			this->systemV_ABI_call_end();
			return ;
			
		}
		void call_strcmp (string arg1, string arg2) {
			systemV_ABI_call_begin();
			fprintf (x86asm, "movq -%ld(%%rbp), %%rdi\n\tmovq -%ld(%%rbp), %%rsi\n", get_rbp_offset(arg1), get_rbp_offset(arg2));
			fprintf (x86asm, "\tcallq strcmp\n");
			systemV_ABI_call_end();
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
