class Node
{
public:
    int nodeid;
    string production;
    vector<Node *> children;
    Node(string prod)
    {
        nodeid = nodecount++;
        production = prod;
    }
    void addchild(Node *child)
    {
        children.push_back(child);
    }
    void printnode()
    {
        cout << "Node id: " << nodeid << " Production: " << production << endl;
        for (auto child : children)
        {
            child->printnode();
        }
    }
};
