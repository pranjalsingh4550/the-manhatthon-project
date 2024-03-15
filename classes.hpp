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
			typestring = "string";
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
		
// 		Node(int x,const char *y){
// 			nodeid = nodecount++;
// 			production = y;
// 			lineno= yylineno;
// 		}
// 		Node(string s){
// 			nodeid = nodecount++;
// 			production = s;
// 			lineno= yylineno;
// 			if (graph)
// 				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, s.c_str());
// 		}
// 		Node (const char *label) {
// 			nodeid = nodecount++;
// 			production = label;
// 			lineno= yylineno;
// 			if (graph)
// 				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label);
// 		}
// 		Node(string s, enum ir_operation node_op){
// 			nodeid = nodecount++;
// 			production = s;
// 			op = node_op;
// 			if (graph)
// 				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, s.c_str());
// 		}
// 		Node (const char *label, enum ir_operation node_op) {
// 			nodeid = nodecount++;
// 			production = label;
// 			op = node_op;
// 			if (graph)
// 				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label);
// 		}

		void rename(const string label) {
			production = label;
			// if (graph)
// 				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label.c_str());
		}
		void addchild (Node* child) {
			children.push_back(child);
			// if (graph)
// 				fprintf (graph, "\tnode%d -> node%d;\n", this->nodeid, child->nodeid);
		}
		void addchild (Node *child, const string label) {
			children.push_back(child);
			// if (graph)
// 				fprintf (graph, "\tnode%d -> node%d [label=\"%s\"];\n", this->nodeid, child->nodeid, label);
		}
		// overloaded ops below: add actions of the form leftchild OP child
		void addchild (Node* child, Node* leftchild) {
			children.push_back(child);
			// if (graph)
// 				fprintf (graph, "\tnode%d -> node%d;\n", this->nodeid, child->nodeid);
			add_op(leftchild, child, this->op);
		}
		void addchild (Node *child, const char* label, Node *leftchild) {
			children.push_back(child);
			// if (graph)
// 				fprintf (graph, "\tnode%d -> node%d [label=\"%s\"];\n", this->nodeid, child->nodeid, label);
			add_op(leftchild, child, this->op);
		}
		void printnode () {
			cout << "Node id: " << nodeid << " Production: " << production << endl;
			for (auto child: children) {
				child->printnode();
			}
		}
		void add_op (Node *leftoperand, Node *rightoperand, enum ir_operation op) {
			// should ir_operations be a map <str, int>?
			fprintf (stdout, "adding operation %d between nodes %d and %d\n", op, 
					leftoperand->nodeid, rightoperand->nodeid);

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
		Symbol(){}
		// Symbol(){
		// // emphy instance, to declare primitive types as "class"
		// 	size = 0;
		// 	name = "class";
		// 	typestring = "";
		// }
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
		string return_type;
		vector<string> arg_types; // for function, but class also ig
		bool fn_inside_class;
		map <string, SymbolTable*> classes; // if global
		map <string, SymbolTable*> member_functions; // for a class
		map <string, SymbolTable*> functions;
		int size;
		unsigned long table_size;

		bool has (string name) {
			if (symbols.find(name) != symbols.end()) {
				return true;
			}
			if (parent != NULL) {
				return parent->has(name);
			}
			return false;
		}
		
		bool has(Node* node){
			return has(node->production);
		}
		int put (Node* node, Node* type) {
			auto s= new Symbol();
			s->typestring = type->production;
			s->lineno = node->lineno;
			s->isFunction = 0;
			s->isClass = 0;
			symbols[node->production] = s;
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
			this->member_functions[node->production] = f;
			return 1;
		}
		SymbolTable(SymbolTable *p) {
			parent = p;
			isFunction = false;
			isClass = false;
			isGlobal = true;
			lineno = 0;
			this->fn_inside_class = false;
			this->name = "global";
			// int, float complex bool str 
			symbols["class"] = new Symbol ();
			symbols["int"] = new Symbol("int", "class", -1, 0, p);
			symbols["float"] = new Symbol("float", "class", -1, 0, p);
			symbols["complex"] = new Symbol("complex", "class", -1, 0, p);
			symbols["bool"] = new Symbol("bool", "class", -1, 0, p);
			symbols["str"] = new Symbol("str", "class", -1, 0, p);
			size = 0;
		}
		SymbolTable (SymbolTable *p, int flags, string name) {
			if (flags > 3 || flags < 1) {
				cerr << "Bad flags\n"; exit(6);
			}
			parent = p;
			if (isFunction = (flags == FUNCTION_ST))
				parent->functions[name] = this;
			if (isClass = (flags == CLASS_ST))
				parent->classes[name] = this;
			isGlobal = false;
			lineno = 0;
			if (fn_inside_class = (flags == MEMBER_FN_ST))
				parent->member_functions[name] = this;
		}
// 		string gettype (string name) {
// 			Symbol *s = get(name);
// 			if (s != NULL) {
// 				return s->typestring;
// 			}
// 			return "";
// 		}
};

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
		if (typestring == "" || cur_symboltable->classes.find(typestring)==cur_symboltable->classes.end()) {
			cerr << "Undeclared type in line " << lineno << endl; // mroe details
			exit(1); // or call error
		}
		if (typestring != "class")
			size = cur_symboltable->classes[typestring]->size;
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
