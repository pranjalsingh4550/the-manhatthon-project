#include<bits/stdc++.h>
using namespace std;

extern int nodecount;
extern FILE *graph;
class Node {
		public:
		int nodeid;
		string production;
		vector<struct Node*> children;
		// Node operator=(const Node& other) {
		// 	nodeid = other.nodeid;
		// 	production = other.production;
		// 	children = other.children;
		// 	return *this;
		// }
		Node(int x,const char *y){
			nodeid = x;
			production = y;
		}
		Node (const char *label) {
			nodeid = nodecount ++;
			production = label;
			if (graph)
				fprintf (graph, "\tnode%d [label=\"%s\"];\n", nodeid, label);
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
		void printnode () {
			cout << "Node id: " << nodeid << " Production: " << production << endl;
			for (auto child: children) {
				child->printnode();
			}
		}
	};