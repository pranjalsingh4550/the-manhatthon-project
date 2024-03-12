#include<bits/stdc++.h>
#include <vector>

#define ull unsigned long long

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
	INT = 1,	// bool will be stored as 0/1
	FLOAT = 2,
	COMPLEX = 3,
	// reorder this later, so that instead of an if-block for a*b,
	// we use result.type = max (a.type, b.type)
	STR = 0x10,
	VOID = 0x20,
	ERROR = 0x40,
	IDENTIFIER = 0x80
};


#define ISNUM(dtype) (dtype & 3)
#define ISID(dtype) (dtype & 0x80)
#define ISLITERAL(dtype) (dtype & 0x1f)
#define ARITHMETIC_OP_RESULT(op1, op2)	\
	((op1 > op2 ? op1 : op2) && ISNUM (op1 | op2))
// returns 0 on error


class Node {
		public:
		int nodeid;
		string production;
		string typestring;
		ull lineno;
		vector<Node*> children;
		enum datatypes type;
		enum ir_operation op;

		Node(int x,const char *y){
			nodeid = nodecount++;
			production = y;
			lineno= yylineno;
		}
		Node(string s){
			nodeid = nodecount++;
			production = s;
			lineno= yylineno;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, s.c_str());
		}
		Node (const char *label) {
			nodeid = nodecount++;
			production = label;
			lineno= yylineno;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label);
		}
		Node(string s, enum ir_operation node_op){
			nodeid = nodecount++;
			production = s;
			op = node_op;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, s.c_str());
		}
		Node (const char *label, enum ir_operation node_op) {
			nodeid = nodecount++;
			production = label;
			op = node_op;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label);
		}
		void rename(const char *label) {
			production = label;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label);
		}
		void rename(string label) {
			production = label;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label.c_str());
		}
		void addchild (Node* child) {
			children.push_back(child);
			if (graph)
				fprintf (graph, "\tnode%d -> node%d;\n", this->nodeid, child->nodeid);
		}
		void addchild (Node *child, const char* label) {
			children.push_back(child);
			if (graph)
				fprintf (graph, "\tnode%d -> node%d [label=\"%s\"];\n", this->nodeid, child->nodeid, label);
		}
		// overloaded ops below: add actions of the form leftchild OP child
		void addchild (Node* child, Node* leftchild) {
			children.push_back(child);
			if (graph)
				fprintf (graph, "\tnode%d -> node%d;\n", this->nodeid, child->nodeid);
			add_op(leftchild, child, this->op);
		}
		void addchild (Node *child, const char* label, Node *leftchild) {
			children.push_back(child);
			if (graph)
				fprintf (graph, "\tnode%d -> node%d [label=\"%s\"];\n", this->nodeid, child->nodeid, label);
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

class SymbolTable;
class FunctionTable;
class ClassTable;
class Symbol {
	public:
		string name;
		string typestring;
		ull lineno;
		int isFunction;
		int isClass;
		ull size;
		ull offset=0;
		int dimension=0;
		SymbolTable *nested_table;
};



class SymbolTable {
	public:
		SymbolTable *parent;
		map<string, Symbol*> symbols;
		int isFunction;
		int isClass;
		int isGlobal;
		SymbolTable (SymbolTable *p) {
			parent = p;
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
		string gettype (string name) {
			Symbol *s = get(name);
			if (s != NULL) {
				return s->typestring;
			}
			return "";
		}
	};

class FunctionTable: public SymbolTable {
	public:
		string name;
		ull lineno;
		string return_type;
		vector<string> arg_types;
		int inClass; // 1 if in class, 0 I
		FunctionTable (SymbolTable *p): SymbolTable(p) {
		}
	};

class ClassTable: public SymbolTable {
	public:
		string name;
		ClassTable (SymbolTable *p): SymbolTable(p) {
		}
		map<string, FunctionTable*> functions;
		int putFunc(Node* node, Node* type, vector<Node*> args) {
			FunctionTable *f = new FunctionTable(this);
			f->name = node->production;
			f->return_type = type->production;
			for (auto arg: args) {
				f->arg_types.push_back(arg->production);
			}
			functions[node->production] = f;
			return 1;
		}
	};


class GlobalTable: public SymbolTable {
	public:
		GlobalTable (): SymbolTable(NULL) {
		}
		map<string, ClassTable*> classes;

	};

class MergedTable: public FunctionTable, public ClassTable, public GlobalTable{
	public:
		
	};