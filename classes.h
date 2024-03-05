#include<bits/stdc++.h>
#include <vector>

using namespace std;

extern int nodecount;
extern FILE *graph;

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
	INT,	// bool will be stored as 0/1
	FLOAT,
	STR,
	COMPLEX,
	// reorder this later, so that instead of an if-block for a*b,
	// we use result.type = max (a.type, b.type)
};

class Node;

class Node {
		public:
		int nodeid;
		string production;
		vector<struct Node*> children;
		enum datatypes type;
		enum ir_operation op;

		Node(int x,const char *y){
			nodeid = nodecount++;
			production = y;
		}
		Node(string s){
			nodeid = nodecount++;
			production = s;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, s.c_str());
		}
		Node (const char *label) {
			nodeid = nodecount++;
			production = label;
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


