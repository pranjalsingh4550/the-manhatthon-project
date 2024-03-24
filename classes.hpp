#include<bits/stdc++.h>
#include <vector>

#define ull unsigned long

using namespace std;

extern int nodecount;
extern FILE *graph;
extern int yylineno;


enum ir_operation {
	UJUMP,
	CJUMP,	// CONDITIONAL JUMP
	LW,
	SW,
	RETQ,	// RETURN
	MOV_REG,

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
	NEWSTACK, //x86's callq: push rbp, mov rsp to rbp, etc
	FUNCTION_RETURN
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
		ull lineno;
		vector<Node*> children;
		//children used for lists etc.
		
		enum datatypes type;
		enum ir_operation op;
		bool isConstant = false;
		long int intVal;
		short int dimension = 0;
		double floatVal;
		string strVal;
		complexLiteral complexVal;
		
		bool isLeaf = false;
		
		Node (int tokenIn) {
			//none, but let the lexer pass the token value so that I don't have to include parser.tab.h here
			token = tokenIn;
			nodeid = nodecount++;
			typestring = "none";
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
			isLeaf = true;
		}
		
		Node (int tokenIn, long int value) {
			token = tokenIn;
			nodeid = nodecount++;
			typestring = "int";
			lineno = yylineno;
			type = TYPE_INT;
			isConstant = true;
			intVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, double value) {
			token = tokenIn;
			nodeid = nodecount++;
			typestring = "float";
			lineno = yylineno;
			type = TYPE_FLOAT;
			isConstant = true;
			floatVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, complexLiteral value) {
			token = tokenIn;
			nodeid = nodecount++;
			typestring = "complex";
			lineno = yylineno;
			type = TYPE_COMPLEX;
			isConstant = true;
			complexVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, string value) {
			//for string literals
			token = tokenIn;
			nodeid = nodecount++;
			typestring = "str";
			lineno = yylineno;
			type = TYPE_STR;
			isConstant = true;
			strVal = value;
			isLeaf = true;
		}
		
		Node (int tokenIn, bool value) {
			token = tokenIn;
			nodeid = nodecount++;
			typestring = "bool";
			lineno = yylineno;
			type = TYPE_INT;
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
			add_op(leftchild, child, this->op);
		}
		void addchild (Node *child, const char* label, Node *leftchild) {
			children.push_back(child);
			add_op(leftchild, child, this->op);
		}
		void printnode () {
			cout << "Node id: " << nodeid << " Production: " << production << endl;
			for (auto child: children) {
				child->printnode();
			}
		}
		void add_op (Node *leftoperand, Node *rightoperand, enum ir_operation op) {
			// should ir_operations be a map <str, int>? ??????
			fprintf (stdout, "adding operation %d between nodes %d and %d\n", op, 
					leftoperand->nodeid, rightoperand->nodeid);
				switch (op) {
					case 5: printf ("\t\tMOV_REG t_%d , t_%d\n", leftoperand->nodeid, rightoperand->nodeid);
				}

			return ;
		}
	};

#define FUNCTION_ST 1
#define CLASS_ST 2
#define MEMBER_FN_ST 3

class SymbolTable;

class Symbol {
	public:
		string name;
		string typestring;
		ull lineno;
		bool isFunction = false;
		bool isClass = false;
		ull size = 0;
		ull offset=0;
		int dimension=0;
		SymbolTable *nested_table;
		Symbol(){
			size = 0;
			name = "class";
			typestring = "";
		}
		Symbol (string , string , int , int , SymbolTable* );

};

class SymbolTable {
	public:
		SymbolTable *parent;
		map<string, Symbol*> symbols;
		bool isFunction; // we don't need get/set helpers
		bool isClass;
		int isGlobal;
		ull lineno;
		string name;
		string return_type="None";
		vector<string> arg_types; // for function, but class also ig
		bool fn_inside_class;
		// not using atm // map <string, SymbolTable*> classes; // if global
		// not using atm // map <string, SymbolTable*> member_functions; // for a class
		// not using atm // map <string, SymbolTable*> functions;
		map <string, SymbolTable*> children;	// contains member functions, classes&global functions for the global namespace
							// use children[name]->is{Class|Function} to check what it is
		int size;
		unsigned long table_size;
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
			printf ("finding class %s. number of children %d, symbols %d\n", 
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
			if (symbols.find(name) != symbols.end()) {
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
		/*
		SymbolTable* has_suite(Node *node) {
			if (this->isClass && this->member_functions.find(


			if (this->classes.find(node->production) or parent scopes have productipon) // search recursively
				return 2;
			if (this->funco

		  */
		int put (Node* node, Node* type) {
			printf ("call to put source %s destination %s\n", type->production.c_str(), node->typestring.c_str());
			auto s= new Symbol();
			s->typestring = type->production; node->typestring = type->production;
			s->lineno = node->lineno;
			s->isFunction = 0;
			s->isClass = 0;
			// this->symbols[node->production] = s;
			this->symbols.insert({node->production, s});
			cout << "checking::" << node->typestring << endl;
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
		int putFunc(Node* node, Node* type, vector<Node*> args) {
			if (this->isClass == false) {
				cerr << "Adding member function to non-class symbol table!\n";
				return 5;
			}
			SymbolTable *f = new SymbolTable(this, MEMBER_FN_ST, node->production); // node->production?
			f->name = node->production;
			f->return_type = type->production;
			for (auto arg: args) {
				f->arg_types.push_back(arg->production);
			}
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
			symbols["class"] = new Symbol ();
			symbols["int"] = new Symbol("int", "class", -1, 0, this);
			symbols["float"] = new Symbol("float", "class", -1, 0, this);
			symbols["complex"] = new Symbol("complex", "class", -1, 0, this);
			symbols["bool"] = new Symbol("bool", "class", -1, 0, this);
			symbols["str"] = new Symbol("str", "class", -1, 0, this);
			size = 0;
		}
		SymbolTable (SymbolTable *p, int flags, string name) {
			if (flags > 3 || flags < 1) {
				cerr << "Bad flags\n"; exit(6);
			}
			parent = p;
			if (isFunction = (flags == FUNCTION_ST))
				parent->children[name] = this;
			if (isClass = (flags == CLASS_ST))
				parent->children[name] = this;
			isGlobal = false;
			lineno = 0;
			if (fn_inside_class = (flags == MEMBER_FN_ST))
				parent->children[name] = this;
		}
		string gettype (string name) {
			Symbol *s = get(name);
			if (s != NULL) {
				return s->typestring;
			}
			return "";
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
