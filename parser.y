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
	int basecount=0;
	int comparison_label_count = 0;
	FILE* inputfile = NULL;
	FILE* stdump = NULL;
	FILE* x86asm = NULL;
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
	SymbolTable* top, *globalSymTable, *current_scope, *saved_scope, *currently_defining_class;
	string newtemp(){
		string temp = "t";
		temp += to_string(tempcount);
		top->declare_temp(tempcount);
		tempcount++;
		return temp;
	}
	void resettemp(int f=0){
		tempcount=basecount;
		if(!f){
			fprintf(tac,"\n");
			fprintf(x86asm,"\n");
		}
	}
	SymbolTable *currently_defining_list;
	string currently_defining_identifier_typestring;
	vector <Node*> list_init_inputs;
	vector <Node *> function_call_args;
	vector <int> function_call_args_dim;
	Node* for_loop_iterator_node, *for_loop_range_second_arg, *for_loop_range_first_arg;
	int label_count;
	int str_count = 0;

	vector<Node*> function_params;

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
		cur_symboltable->table_size += 8;

	}
	SymbolTable* find_fn (string name) { // returns SymbolTable* if name is a class, NULL otherwise
			if(globalSymTable->children.find(name) == globalSymTable->children.end())
				return NULL;
			else if(globalSymTable->children.find(name)->second->isClass)
				return NULL;
			else
				return globalSymTable->children.find(name)->second;
		}
	void put(Node* n1, Node* n2){
		top->put(n1, n2);
		return ;
	}
	extern void check (Node* n) ;
	
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
	
	bool check_types(string t1, string t2) {
		if (t1 == "int") {
			if (t2 != "bool"
			&&  t2 != "float"
			&&  t2 != "int") {
				return false;
			}
		} else if (t1 == "float") {
			if (t2 != "float"
			&&  t2 != "int") {
				return false;
			}
		} else if (t1 == "bool") {
			if (t2 != "int"
			&&  t2 != "bool") {
				return false;
			}
		} else if (t1 != t2) {
			return false;
		}
		return true;
	}
	
	bool check_array(int len1, int len2) {
		//len1: dimension of lhs
		//len2: dimension of rhs
		if (len1 == 0) {
			//len1 not an array, so len2 can't be either
			if (len2 == 0) return true;
			return false;
		} else if (len1 < 0) {
			//len1 belongs to uninitialized array
			if (len2 > 0) return true; 
			 //problem: rhs cannot be an uninitialized array
			 //-> rhs must have actual length, can't be -1
			return false;
		} else {
			if (len2 == len1) return true; //same length -> A-OK
			return false; //not same length -> not ok
		}
	}
	
	int Funcsuite=0;
	int Classsuite=0;
	int inLoop=0;
	static Node* name;
	enum ir_operation current_op;
	string return_type="None";
	int returned=0;
	static Node* params;
	void newscope(string name){
	// cout << "New scope " << name << endl;
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

	SymbolTable* find_function (string name) {
		if (globalSymTable->children.find(name) == globalSymTable->children.end())
			return NULL;
		else return (globalSymTable->children.find(name)->second->isClass ? 
						NULL : globalSymTable->children.find(name)->second); 
	}
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
	int getwidth(string typestring) {
		return find_class(typestring)->table_size;
	}
	
	stack <string> jump_labels, jump_labels_upper;
	string get_next_label (string description) {
		string tmp =  "label"+to_string(label_count++)
		//  + "_" + (currently_defining_class ? currently_defining_class->name : top->name)
		 ;
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
		string tmp =  "label"+to_string(label_count++)
		//  + "_" + (currently_defining_class ? currently_defining_class->name : top->name) 
		;
		if (description != "") tmp += "_" + description;
		jump_labels_upper.push (tmp);
		return tmp;
	}
	string get_current_label_upper () {
		string tmp = jump_labels_upper.top();
		jump_labels_upper.pop();
		return tmp;
	}
	stack <string> jump_labels3, jump_labels_upper3;
	string get_next_label3 (string description) {
		string tmp = "label"+to_string(label_count++)
		//  + "_" + (currently_defining_class ? currently_defining_class->name : top->name) 
		;
		if (description != "") tmp += "_" + description;
		jump_labels3.push (tmp);
		return tmp;
	}
	string get_current_label3 () {
		string tmp = jump_labels3.top();
		jump_labels3.pop();
		return tmp;
	}
	string get_next_label_upper3 (string description) {
		string tmp = "label" +to_string(label_count++) 
		// + "_" + (currently_defining_class ? currently_defining_class->name : top->name) 
		;
		if (description != "") tmp += "_" + description;
		jump_labels_upper3.push (tmp);
		return tmp;
	}
	string get_current_label_upper3 () {
		string tmp = jump_labels_upper3.top();
		jump_labels_upper3.pop();
		return tmp;
	}
	
	void gen_ujump (string target) {
		fprintf (tac, "\tjmp %s\n", target.c_str());
		fprintf (x86asm, "\tjmp %s\n", target.c_str());
	}
	void gen_branch (Node* condition, string target) {
		fprintf (tac, "\tifFalse %s\tjmp %s\n", condition->addr.c_str(), target.c_str());
		fprintf (x86asm, "\tcmpq $0, -%ld(%%rbp)\n", top->get_rbp_offset(condition->addr));
		fprintf (x86asm, "\tje %s\n", target.c_str());
	}
	void gen(Node*result, Node* leftop, Node* rightop,enum ir_operation op){
		// fprintf(x86asm,"\t#  gen Started\n\n");
		if (tac == NULL) tac = stdout;
		string left= leftop ? top->getaddr(leftop) : "";
		string right= rightop ? top->getaddr(rightop) : "";
		string resultaddr = result ? top->getaddr(result) : "";
		//if not leafs, then addr contains the address corresponding to the field
		//so don't get addr from symbol table
		if (leftop && !leftop->isLeaf) left = leftop->addr;
		if (rightop && !rightop->isLeaf) right = rightop->addr;
		if (op != ASSIGN
		&&  result == leftop
		&&  result != NULL
		&& 	result->islval
		&&  !leftop->isLeaf /*NOT isLeaf -> addr is a temporary*/) {
			// dprintf(stderr_copy, "gen: augassign special case isLeaf: %d\n", leftop->isLeaf);
			//augmented assign case
			//result and leftop is an lval=true case AND is a temporary
			//-> need to work some pointer stuff out
			//here, we need to create a temporary that has the deref of 
			//leftop, use it in the calculation (which goes to the same
			//temp or a new temp) and then use the result temp in a SW
			
			//first, generate the deref:
			string s = "";
			string deref = newtemp();
			s += deref + " = *" + left;
			fprintf(tac, "\t%s\n", s.c_str());
			fprintf(x86asm, "\t# %s\n", s.c_str());
			top->asm_load_value(14,left);
			
			fprintf(x86asm, "\tmovq 0(%%r14), %%r15\n");

			top->asm_store_value(15,deref);
			//now deref has the temporary, so we use it in the calculation
			string old_addr = result->addr;
			leftop->addr = deref;
			result->islval = false;
			gen(result, leftop, rightop, op);
			
			//gen will have created the augassign and put the temporary in result->addr
			//so now just restore and create the saveword
			result->addr = old_addr;
			result->islval = true;
			fprintf (tac, "\t*%s = %s\n", old_addr.c_str(), right.c_str());
			fprintf(x86asm, "\t# *%s = %s\n", old_addr.c_str(), right.c_str());
			top->asm_load_value(14,right);
			top->asm_load_value(15,old_addr);
			fprintf(x86asm, "\tmovq %%r14, 0(%%r15)\n");

			//we're done!
			return;
		}
		if (op == ASSIGN
		 && leftop != NULL
		 && leftop->islval 
		 && !leftop->isLeaf /*NOT isLeaf: addr is a temporary*/) {
		 	// dprintf(stderr_copy, "gen: assign special case\n");
			//direct assign to left will not work, will need to assign to deref of left i.e. SW
			//this doesn't work for augmented assign, that is handled above
			#if TEMPDEBUG
			printf("special assign, leftaddr: %s, rightaddr: %s\n", leftop->addr.c_str(), rightop->addr.c_str());
			#endif
			fprintf (tac, "\t*%s = %s\n", left.c_str(), right.c_str());
			fprintf (x86asm, "\t# *%s = %s\n", left.c_str(), right.c_str());
			
			top->asm_load_value(14,right);
			top->asm_load_value(15,left);
			fprintf(x86asm, "\tmovq %%r14, 0(%%r15)\n");
		 	return;
		}
		switch(op){
			case ASSIGN: {
				if (leftop->typestring == rightop->typestring) {
					fprintf(tac, "\t%s = %s\n", left.c_str(), right.c_str());
					fprintf(x86asm, "\t# %s = %s\n", left.c_str(), right.c_str());
					
					top->asm_load_value_r13(right);
					top->asm_store_value_r13(left);
					return;
				}
				//add typecasting instr if needed
				if (leftop->typestring == "int") {
					if (rightop->typestring == "bool") {
						fprintf(tac, "\t%s = BOOL_TO_INT(%s)\n", left.c_str(), right.c_str());
					} else if (rightop->typestring == "float") {
						fprintf(tac, "\t%s = FLOAT_TO_INT(%s)\n", left.c_str(), right.c_str());
					}
				} else if (leftop->typestring == "bool") {
					if (rightop->typestring == "int") {
						fprintf(tac, "\t%s = INT_TO_BOOL(%s)\n", left.c_str(), right.c_str());
					}
				} else if (leftop->typestring == "float") {
					if (rightop->typestring == "int") {
						fprintf(tac, "\t%s = INT_TO_FLOAT(%s)\n", left.c_str(), right.c_str());
					}
				}
				return;
			}
			case ATTR: {
				string s="\t";
				if(leftop->isLeaf
				&& top->getnode(leftop->production)->isLeaf){
					string obj= newtemp();
					s+=obj +" = " + left +"\n\t";
					fprintf(x86asm, "\t# %s = %s\n",obj.c_str(),left.c_str());
					top->asm_load_value_r12(left);
					top->asm_store_value(12,obj);
					left = obj;
				}
				string offset = newtemp();
				// t_1 = symtable($1->typestring, $3->production)
#if 1

				int num_offset;
				SymbolTable* local_table = find_class(leftop->typestring);
				if (!local_table)
					exit(200);
				else if (local_table->symbols.find(rightop->production) == local_table->symbols.end())
					num_offset = local_table->table_size;
				else
					num_offset = local_table->symbols.find(rightop->production)->second->offset;
#endif
#if TEMPDEBUG
				printf("%s\n", rightop->production.c_str());
				printf("%d %p\n", (int) top->table_size, top->get(rightop->production));
				// t_2 = $1->addr + offset
#endif
				s+= offset + " = "+ to_string(num_offset)+" [ symtable(" + leftop->typestring + ", " + rightop->production + ") ]\n\t"; 
				fprintf(x86asm, "\t# %s = %d [ symtable(%s, %s) ]\n",offset.c_str(),num_offset, leftop->typestring.c_str(),rightop->production.c_str());
				fprintf(x86asm,"\tmovq $%ld, -%ld(%%rbp)\n",(long)num_offset,top->get_rbp_offset(offset));

				string ult = newtemp();
				s+=ult +" = " + left + " + " + offset ;
				fprintf(x86asm ,"\t# %s = %s + %s\n",ult.c_str(),left.c_str(),offset.c_str());
				top->asm_load_value_r12(left);
				top->asm_load_value_r13(offset);

				fprintf(x86asm,"\taddq %%r12, %%r13\n");

				top->asm_store_value_r13(ult);

// 				string nc = newtemp();
// 				s+=nc + " = *" + ult + "\n";
// 				result->addr = nc;
				result->addr = ult;
				// // cout<<"nice "<<addr<<endl;
				fprintf(tac, "%s\n", s.c_str());

				// fprintf (tac, "\t\t= %d\n", num_offset);
				return;
			}
			case SW:	{
				fprintf (tac, "\t*%s = %s\n", resultaddr.c_str(), left.c_str()); 
				fprintf (x86asm, "\t# *%s = %s\n", resultaddr.c_str(), left.c_str()); 
				top->asm_load_value(14,left);
				top->asm_store_value(15,resultaddr);
				fprintf(x86asm, "\tmovq %%r14, 0(%%r15)\n");
				return;
			}
			case SUBSCRIPT: {
				string s="\t";
				string offset = newtemp();
				
				s += offset + " =  "  +right + " * 8\n\t";
				fprintf(x86asm , "\t# %s = %s * 8\n",offset.c_str(),right.c_str());
				fprintf (x86asm, "\timulq $8, %%r12\n");
				string ult = newtemp();
				s+=ult +" = " + left + " + " + offset + "\n";
				fprintf(x86asm,"\t# %s = %s + %s\n",ult.c_str(),left.c_str(),offset.c_str());
				top->asm_load_value_r13(left);
				fprintf (x86asm, "\taddq %%r13, %%r12\n");

				top->asm_store_value(12,ult);
// 				string nc = newtemp();
// 				s+=nc + " = *" + ult + "\n";
// 				result->addr = nc;
				result->addr = ult;
				fprintf(tac, "%s", s.c_str());
				return;
			}
			case DEREF: {
				string s = "\t";
				string deref = newtemp();
				s += deref + " = *" + left + "\n";
				fprintf(x86asm,"\t# %s = *%s\n",deref.c_str(),left.c_str());
				top->asm_load_value(14,left);
				top->asm_load_value(15,deref);

				fprintf(x86asm, "\tmovq 0(%%r14), %%r15\n");

				top->asm_store_value(15,deref);

				result->addr = deref;
				fprintf(tac, "%s", s.c_str());
				return;
			}
			default: break;
		}
		result->addr = newtemp();
		resultaddr = result->addr;
		switch(op){
			case ADD:		fprintf(tac, "\t%s\t= %s + %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							fprintf(x86asm, "\t# %s\t= %s + %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12(left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\taddq %%r12, %%r13\n");
							top->asm_store_value_r13(resultaddr);
							break;
			case SUB:		fprintf(tac, "\t%s\t= %s - %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							fprintf(x86asm, "\t# %s\t= %s - %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tsubq %%r13, %%r12\n");
							top->asm_store_value(12,resultaddr);
							break;
			case MUL:		fprintf(tac, "\t%s\t= %s * %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							fprintf(x86asm, "\t# %s\t= %s * %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r13(right);
							fprintf (x86asm, "\timulq -%ld(%%rbp), %%r13\n", top->get_rbp_offset(left));
							top->asm_store_value_r13(resultaddr);
							break;
			case DIV:		fprintf(tac, "\t%s\t= %s / %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							fprintf(x86asm, "\t# %s\t= %s / %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rax\n", top->get_rbp_offset(left));
							fprintf (x86asm, "\tidivq -%ld(%%rbp)\n", top->get_rbp_offset(right));
							fprintf (x86asm, "\tmovq %%rax, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							break;
			case MOD:		fprintf(tac, "\t%s\t= %s %% %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							fprintf(x86asm, "\t# %s\t= %s %% %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rax\n", top->get_rbp_offset(left));
							fprintf (x86asm, "\tidivq -%ld(%%rbp)\n", top->get_rbp_offset(right));
							fprintf (x86asm, "\tmovq %%rdx, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							break;
			case AND_log:	fprintf(tac, "\t%s\t= %s and %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							// fprintf(x86asm, "\t# %s\t= %s and %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r13(right);
							fprintf (x86asm, "\timulq -%ld(%%rbp), %%r13\n", top->get_rbp_offset(left));
							top->asm_store_value_r13(resultaddr);
							break;
			case OR_log:	fprintf(tac, "\t%s\t= %s or %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\torq %%r12, %%r13\n");
							top->asm_store_value_r13(resultaddr);
							break;
			case NOT_log:	fprintf(tac, "\t%s\t= not %s\n",resultaddr.c_str(), left.c_str());
							generic_if (left);
							fprintf (x86asm, "\tmovq $0, %%r13\n");
							generic_else();
							fprintf (x86asm, "\tmovq $0xffffffff, %%r13\n");
							generic_exit();
							top->asm_store_value_r13(resultaddr);
							break;
			case LT:		fprintf(tac, "\t%s\t= %s < %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, %%r12\n");
							fprintf (x86asm, "\tjge comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\taddq $ffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case GT:		fprintf(tac, "\t%s\t= %s > %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, %%r12\n");
							fprintf (x86asm, "\tjle comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\taddq $ffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case LTE:		fprintf(tac, "\t%s\t= %s <= %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "- %%r13, %%r12\n");
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, %%r12\n");
							fprintf (x86asm, "\tjg comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\taddq $ffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case GTE:		fprintf(tac, "\t%s\t= %s >= %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "- %%r13, %%r12\n");
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, %%r12\n");
							fprintf (x86asm, "\tjl comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\taddq $ffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case EQ:		fprintf(tac, "\t%s\t= %s == %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, %%r12\n");
							fprintf (x86asm, "\tjne comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\taddq $ffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case NEQ:		fprintf(tac, "\t%s\t= %s != %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, %%r12\n");
							fprintf (x86asm, "\tje comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\taddq $ffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case OR_bit:	fprintf(tac, "\t%s\t= %s | %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\torq %%r12, %%r13\n");
							top->asm_store_value_r13(resultaddr);
							break;
			case AND_bit:	fprintf(tac, "\t%s\t= %s & %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tandq %%r12, %%r13\n");
							top->asm_store_value_r13(resultaddr);
							break;
			case NOT_bit:	fprintf(tac, "\t%s\t= ~%s\n",resultaddr.c_str(), left.c_str());
							top->asm_load_value_r13 (left);
							fprintf (x86asm, "\tnotq %%r13\n");
							top->asm_store_value_r13(resultaddr);
							break;
			case XOR:		fprintf(tac, "\t%s\t= %s ^ %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\txorq %%r13, %%r12\n");
							top->asm_store_value(12,resultaddr);
							break;
			case SHL:		fprintf(tac, "\t%s\t= %s << %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tsalq %%r13, %%r12\n");
							top->asm_store_value(12,resultaddr);
							break;
			case SHR:		fprintf(tac, "\t%s\t= %s >> %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "\tsarq %%r13, %%r12\n");
							top->asm_store_value(12,resultaddr);
							break;
			case POW:		{ fprintf(tac, "\t%s\t= %s ** %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
			                /* template
			                
			                
			                int power(int a (base), int b (exponent)) {
                                int k = 1;
                                if (b == 0) return 1;
                                while (b > 1) {
                                    if (b%2) {
                                        k *= a;
                                    }
                                    a *= a;
                                }
                                return k*a;
                            }
			                
			                
			                    r12, r13 have base, exponent
			                    
			                    mov $0x1, r14
                                cmp $0x0, r13 //is b 0?
                                jne loop //if b isn't 0 jump into the loop
                                mov $0x1, r12
                                j out
                            loop:
                                cmp $0x1, r13 //is b > 1?
                                je out //if it isn't, go to out
                                test $0x1, r13 //is b odd?
                                je mul //if b isn't odd, go to mul directly
                                imul r12, r14 // k*a
                            mul:
                                imul r12, r12 //a*a
                                sarq 1, r13 //b /= 2
                                j loop //back to start of loop

                            out:
                                imul r14, r12
                                mov r12, r13
                                store r13
			                */
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							// fprintf (x86asm, "- %%r13, %%r12\n");
				            fprintf(x86asm, "\tmovq $0x1, %%r14\n");
							fprintf(x86asm, "\tcmp $0, %%r13\n");							
							string loop = get_next_label("power_loop");
							fprintf(x86asm, "\tjne %s\n", loop.c_str());
							fprintf(x86asm, "\tmovq $0x1, %%r12\n");
							string out = get_next_label("power_out");
							fprintf(x86asm, "\tjmp %s\n", out.c_str());
							fprintf(x86asm, "%s:\n", loop.c_str());
							fprintf(x86asm, "\tcmp $0x1, %%r13\n");
							fprintf(x86asm, "\tje %s\n", out.c_str());
							fprintf(x86asm, "\ttest $0x1, %%r13\n");							
							string mul = get_next_label("power_mul");
							fprintf(x86asm, "\tje %s\n", mul.c_str());
							fprintf(x86asm, "\timulq %%r12, %%r14\n");
							fprintf(x86asm, "%s: \n", mul.c_str());
							fprintf(x86asm, "\timulq %%r12, %%r12\n");
							fprintf(x86asm, "\tsarq $0x1, %%r13\n");
							fprintf(x86asm, "\tjmp %s\n", loop.c_str());
							fprintf(x86asm, "%s:\n", out.c_str());
							fprintf(x86asm, "\timul %%r14, %%r12\n");						
							fprintf(x86asm, "\tmov %%r12, %%r13\n");
							top->asm_store_value_r13(resultaddr);
							//get rid of labels
							get_current_label(); //mul
							get_current_label(); //out
							get_current_label(); //loop
							break; }
			case NEG:		fprintf(tac, "\t%s\t= -%s\n",resultaddr.c_str(), left.c_str());
							top->asm_load_value_r12 (left);
							fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "\tcmpq %%r13, $0\n");
							fprintf (x86asm, "\tjne comparison_jump%d\n", comparison_label_count);
							fprintf (x86asm, "\tmovq $0xffff, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
							fprintf (x86asm, "comparison_jump%d:\n", comparison_label_count++);
							break;
			case FLOORDIV:	fprintf(tac, "\t%s\t= %s // %s\n",resultaddr.c_str(), left.c_str(), right.c_str());
							top->asm_load_value_r12 (left); top->asm_load_value_r13(right);
							fprintf (x86asm, "- %%r13, %%r12\n");
							top->asm_store_value_r13(resultaddr);
							break;
			case STREQ:		fprintf(tac, "\t%s\t= STREQ(%s, %s)\n", resultaddr.c_str(), left.c_str(), right.c_str()); break;
							top->call_strcmp (right, left);
							fprintf (x86asm, "\tmovq %%rax, -%ld(%%rbp)\n", top->get_rbp_offset(resultaddr));
			case STRCMP:	{
					fprintf(tac,"\tparam %s\n",right.c_str());
					fprintf(tac,"\tparam %s\n",left.c_str());
					fprintf(tac,"\t%s\t= call STRCMP 2\n",resultaddr.c_str());break;
					top->call_strcmp (right, left);

				// fprintf(tac, "\t%s\t= STRCMP(%s, %s)\n", resultaddr.c_str(), left.c_str(), right.c_str()); break; 
				}
			default: dprintf (stderr_copy,"Wrong op at line no : %d\n",yylineno);exit(1);
		}
		return;
			
	}
	
	string dev_helper(Node* n) {
		return top->getaddr (n);
	}
	void generic_if(string test) {
		string lbl2 = get_next_label_upper3("internal_false");
		string lbl = get_next_label3 ("internal");
		fprintf (x86asm, "\t movq -%lx(%%rbp), %%rax\n", top->get_rbp_offset(test));
		fprintf (x86asm, "\tcmpq $0, %%rax\n");
		fprintf (x86asm, "\tjmp	%s\n", lbl.c_str());
	}
	void generic_else() {
		fprintf (x86asm, "%s:\n", get_current_label3().c_str());
	}
	void generic_exit() {
		fprintf (x86asm, "%s:\n", get_current_label_upper3().c_str());
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
program : input | program INDENT

input: start 
	| NEWLINE input

start :{$$=new Node("Empty file");} | stmts[first] {$$= new Node("Start"); $$->addchild($first);}

stmts : 
	stmt {$$=$1;}
	| stmts[first] stmt[last] {$$ = new Node ("Statements"); $$->addchild($first); $$->addchild($last);}

;

stmt:  simple_stmt 
	| compound_stmt {resettemp();}
;

simple_stmt: small_stmt ";" NEWLINE {resettemp();}
	| small_stmt NEWLINE {resettemp();}
	| small_stmt[first]";" {resettemp();} simple_stmt[last] {$$ = new Node ("Inline Statement"); $$->addchild($first);$$->addchild($last);}
;




small_stmt: expr_stmt
	| { 
		/*check if current scope isFunction or not by top->isFunction*/
		if(!Funcsuite){
			dprintf (stderr_copy, "Error at line %d: return is not inside a function\n", (int) yylineno);
			exit(57);
		}
	} return_stmt[ret] {$$=$ret;returned=1;}

	| "break" {
		/*check if current scope is loop or not by top->isLoop*/
		if(!inLoop){
			dprintf (stderr_copy, "Error at line %d: break is not inside a loop\n", (int) yylineno);
			exit(58);
		}
		$$=$1;
		string tmp = jump_labels.top();
		gen_ujump (tmp);
	} 
	| "continue"{
		/*check if current scope is loop or not by top->isLoop*/
		if(!inLoop){
			dprintf (stderr_copy, "Error at line %d: continue is not inside a loop\n", (int) yylineno);
			exit(59);
		}
		$$=$1;
		string tmp = jump_labels_upper.top();
		gen_ujump (tmp);
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
		$id->addr= globalSymTable->get($id)->node->addr;
		top->put($id, globalSymTable->get($id)->node->typestring,1);
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
				if(!top->symbols[$id->production]->isGlobal){
					dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
							$id->lineno, $id->production.c_str());
					exit(87);
				}
				else{
					dprintf(stderr_copy,"annotated name '%s' can't be global\n",$id->production.c_str());
					exit(87);
				}
			}
			$id->typestring = $type->typestring;
			//no need to check dimension here because this is type declaration
			$id->dimension = $type->dimension;
			put($id, $type);
		} else { // mind the indent
			if (!Classsuite	|| !currently_defining_class) {
				dprintf (stderr_copy, "Error at line %d: self object cannot be used outside class scope\n",
						$id->lineno);
				exit (57);
			} else if (!inside_init) {
				dprintf (stderr_copy, "Error at line %d: class attributes cannot be declared outside the constructor\n",
						$id->lineno);
				exit (57);
			} else if (currently_defining_class->symbols.find($id->production) != currently_defining_class->symbols.end()) {
				dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
						$id->lineno, $id->production.c_str());
				exit(87);
			}
			currently_defining_class->put ($id, $type);
		}
		$id->typestring = $type->typestring;
		//no need to check dimension here because this is type declaration
		$id->dimension = $type->dimension;
		
		$$ = new Node ("Declaration");
		$$->addchild($id, "Name");
		$$->addchild($type, "Type");
	}
	| primary[id] ":" typeclass[type] decl_set_curr_id "=" test[value] {
	
		if ($value->typestring == "") {
			dprintf (stderr_copy, 
			"Error at line %d: Invalid value on RHS of unknown type\n",
			$id->lineno);
			#if TEMPDEBUG
			printf ("empty typestring: production is %s token %d\n", $value->production.c_str(), $value->token);
			#endif
			exit (96);
		}
	
		if (!check_types($value->typestring, $type->production)) {
			dprintf(stderr_copy, 
			"TypeError on line %d: %s and %s are incompatible\n", 
			$id->lineno, $type->production.c_str(), $value->typestring.c_str());
			exit(1);
		}
		if ($id->isLeaf) {
			if (is_not_name ($id)) {
				dprintf (stderr_copy, "Error: assignment to non-identifier at line %d\n", $id->lineno);
				exit(97);
			}
			if (top->local($id)) {
				if(!top->symbols[$id->production]->isGlobal){
					dprintf (stderr_copy, "Redeclaration error at line %d: identifier %s redeclared\n",
							$id->lineno, $id->production.c_str());
					exit(87);
				}
				else{
					dprintf(stderr_copy,"annotated name '%s' can't be global\n",$id->production.c_str());
					exit(87);
				}
			}
			if (check_array($type->dimension, $value->dimension)) {
				//edit dimension to value
				$id->dimension = $value->dimension;
				$type->dimension = $value->dimension; //bad fix for put doing $id->dimension = $type->dimension
			} else {
				dprintf(stderr_copy, 
				"TypeError on line %d: Uninitialized array on RHS or length mismatch\n",
				$5->lineno);
				exit(1);
			}
			put($id, $type); //will put the correct dimension in the symbol table

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
			
			//check type vs value dimension because id may not have a dimension yet
			if (check_array($type->dimension, $value->dimension)) {
				//edit dimension to value
				$id->dimension = $value->dimension;
				$type->dimension = $value->dimension; //bad fix for put doing $id->dimension = $type->dimension
			} else {
				dprintf(stderr_copy, 
				"TypeError on line %d: Uninitialized array on RHS or length mismatch\n",
				$5->lineno);
				exit(1);
			}
			//put handles typestrings of id, type
			currently_defining_class->put($id, $type);
			//generate the right address using the thisname addr and the production in $id
			auto thisname_entry = currently_defining_class->symbols.find(top->thisname);
			gen($id, thisname_entry->second->node, $id, ATTR);
		}
		gen ($$,$id, $value, ASSIGN);
		$$ = new Node ("Declaration");
		$$->addchild($id, "Name");
		$$->addchild($type, "Type");
		$$->addchild($value, "Value");
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
				dprintf (stderr_copy, 
				"Error at line %d: class attribute %s has not been defined\n",
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
			if (!check_types($id->typestring, $value->typestring)) {
				dprintf(stderr_copy, "TypeError on line %d: %s and %s are incompatible\n", $operation->lineno, $id->typestring.c_str(), $value->typestring.c_str());
				exit(1);
			}
			$$ = new Node ($operation->production);
			$$->addchild($id);
			$$->addchild($value);
			gen($$,$id,$value,$operation->op);
			fprintf(tac,"\t%s = %s\n", top->getaddr($id).c_str(), $$->addr.c_str());
	
	}
	| primary[id] "=" test[value] {
			/*
				if($id is not lvalue) error
				if($id is not in current scope)error
				if($id and $value are not type compatible)error
				if($value is a leaf && $value is not a constant ) check if $value is in scope or not

			*/
			#if TEMPDEBUG
			printf("1assignment: $id addr: %s $value addr: %s\n", $id->addr.c_str(), $value->addr.c_str());
			#endif
			
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
			if ($id->typestring == "") {
				dprintf (stderr_copy, "Error at line %d: identifier %s has not been declared in this scope\n",
						(int) $id->lineno, $id->production.c_str());
				exit(95);
			}
			if (!check_types($id->typestring, $value->typestring)) {
				dprintf(stderr_copy, "TypeError on line %d: %s and %s are incompatible\n", $id->lineno, $id->typestring.c_str(), $value->production.c_str());
				exit(1);
			}
			// these 3 lines copied during merging: check consistency
			check ($id);
			check($value);
			
			if (!check_types($id->typestring, $value->typestring)) {
				dprintf(stderr_copy, 
				"TypeError on line %d: %s and %s are incompatible\n", 
				$id->lineno, $id->typestring.c_str(), $value->typestring.c_str());
				exit(1);
			}
			
			if (check_array($id->dimension, $value->dimension)) {
				//edit dimension to value
				$id->dimension = $value->dimension;
				#if TEMPDEBUG
				top->print_st();
				#endif
				//update symbol table if any
				//FIX: object-wise symbol tables/dimensions for self.a : list[int] declaration without definition
				Node *t1 = $id; 
				Node *t2 = $value;
				Symbol *sym = top->get($id);
				if (sym) sym->dimension = $value->dimension;
			} else {
				dprintf(stderr_copy, 
				"TypeError on line %d: Uninitialized array on RHS or length mismatch\n",
				$2->lineno);
				exit(1);
			}
			
			#if TEMPDEBUG
			printf("2assignment: $id addr: %s $value addr: %s\n", $id->addr.c_str(), $value->addr.c_str());
			#endif
			
			$$ = new Node ("=");
			$$->addchild($id);
			$$->addchild($value);
			
			#if TEMPDEBUG
			printf("3assignment: $id addr: %s $value addr: %s\n", $id->addr.c_str(), $value->addr.c_str());
			#endif
			
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
		// cout << "line 541 set currently definining list type to " << currently_defining_identifier_typestring << endl;
#endif
	}


typeclass: NAME {
		verify_typestring ($1);
		$$ = $1;
	}
	| "list" "[" NAME "]" {
		verify_typestring ($3);
		$$ = $3;
		$$->dimension = -1;
	}
	| "None" {
		$$ = $1;
		$$->production = "None";
	}

augassign: "+=" {$$ = new Node ("+="); $$->op = ADD;}
		| "-=" {$$ = new Node ("-="); $$->op = SUB;}
		| "*=" {$$ = new Node ("*="); $$->op = MUL;}
		| "/=" {$$ = new Node ("/="); $$->op = DIV;}
		| DOUBLESLASHEQUAL {$$ = new Node ("//="); $$->op = DIV;}
		| "%=" {$$ = new Node ("%="); $$->op =MOD;}
		| "&=" {$$ = new Node ("&="); $$->op = AND_bit;}
		| "|=" {$$ = new Node ("|="); $$->op = OR_bit;}
		| "^=" {$$ = new Node ("^="); $$->op = XOR;}
		| ">>=" {$$ = new Node (">>=");$$->op = SHR;}
		| "<<=" {$$ = new Node ("<<="); $$->op = SHL;}
		| "**=" {$$ = new Node ("**="); $$->op = POW;}

return_stmt: "return" test {
			if($2->isConstant ){
				if(!check_types($2->typestring, top->return_type)){
					dprintf (stderr_copy, "Error at line %d: type %s does not match function return type %s\n", (int) $2->lineno, $2->typestring.c_str(), top->return_type.c_str());
					exit(57);
				}
			}
			else{
				if($2->isLeaf && !top->has($2)){
					#if TEMPDEBUG
					Node *temp = $2;
					printf("values: %d %d\n", $2->isLeaf, top->has($2));
					#endif
				
					dprintf (stderr_copy, "Error at line %d: %s was not declared\n", (int) $2->lineno, $2->production.c_str());
					exit(57);
				}
				if(!check_types($2->typestring, top->return_type)){
					dprintf (stderr_copy, "Error at line %d: type %s does not match function return type %s\n", (int) $2->lineno, $2->typestring.c_str(), top->return_type.c_str());
					exit(57);
				}
			}
			$1->addchild($2,"Data"); $$=$1;	
			fprintf(tac, "\tret %s\n", top->getaddr($2).c_str());
			fprintf (x86asm, "\n\tmovq -%ld(%%rbp), %%rax\n", top->get_rbp_offset(top->getaddr($2)));
	}
	| "return" {
			if(top->return_type != "None"){
				dprintf (stderr_copy, "Error at line %d: non-void return for a void function\n", (int) $1->lineno);
				exit(57);
			}
		string temp = "Keyword\n"; temp += "( return )"; $$ = new Node(temp);
	}

// for each operation check if the operands are in current scope or not
// check type compatibility
//udate type of result

test: and_test
	| test "or" and_test {
	//assuming: only ints/bools in test
	if (!check_number($1) 
	||  !check_number($3)
	||  ($1->typestring == "float")
	||  ($1->typestring == "complex")
	||  ($3->typestring == "float")
	||  ($3->typestring == "complex")) {
		dprintf(stderr_copy, "TypeError on line %d: logical operator and doesn't support types %s and %s", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("or");
	$$->addchild ($1);
	$$->addchild ($3);
	$$->typestring = "bool";
	
	gen($$,$1,$3,OR_log);

	//to do: gen
}

and_test: not_test
	| and_test "and" not_test {
	//assuming: only ints/bools in test
	if (!check_number($1) 
	||  !check_number($3)
	||  ($1->typestring == "float")
	||  ($1->typestring == "complex")
	||  ($3->typestring == "float")
	||  ($3->typestring == "complex")) {
		dprintf(stderr_copy, "TypeError on line %d: logical operator and doesn't support types %s and %s", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("and");
	$$->addchild ($1);
	$$->addchild ($3);
	$$->typestring = "bool";
	
	gen($$,$1,$3,AND_log);
}
not_test: comparison
	| "not" not_test	{
	if (!check_number($2)
	||  ($1->typestring == "float")
	||  ($1->typestring == "complex")) {
		dprintf(stderr_copy, "TypeError on line %d: logical operator and doesn't support types %s and %s", $2->lineno, $1->typestring.c_str(), $2->typestring.c_str());
		exit(1);
	}
	$$ = new Node ("not");
	$$->addchild ($2);
	$$->typestring = "bool";
	
	gen($$,$2,NULL,NOT_log);
}

comparison: expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	$$ = $1;
}
	| expr "==" comparison	{
		$$ = new Node ("==");
		$$->addchild ($1);
		$$->addchild ($3);
		if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
			exit(1);
		}
		if (($1->typestring == "str" && $3->typestring != "str")
		||  ($1->typestring != "str" && $3->typestring == "str")) {
			dprintf(stderr_copy, "TypeError at line %d: incompatible types for == comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
			exit(1);
		}
		if ($1->typestring == "str") {
				$$->typestring = "bool";
				if($1->production=="__name__" && $3->production=="__main__"){
					return 0;
				}
				gen($$,$1,$3,STRCMP);
				gen($$,$$,NULL,NOT_log);
				// string temp =newtemp();
				// fprintf(tac,"\t%s = not %s\n",temp.c_str(),$$->addr.c_str());
				// $$->addr = temp;
				//if $$->addr not equal to 0 
		}

		else if (!check_number($1)) {
			dprintf(stderr_copy, "TypeError at line %d: first operand for == comparison has type %s\n", $2->lineno, $1->typestring.c_str());
			exit(1);
		}
		else if (!check_number($3)) {
			dprintf(stderr_copy, "TypeError at line %d: second operand for == comparison has type %s\n", $2->lineno, $3->typestring.c_str());
			exit(1);
		}
		// if ($1->typestring == "str")
		// 	gen ($$, $1, $3, STREQ);
		else{
			gen($$,$1,$3,EQ);
		}
		$$->typestring = "bool";
}
	| expr "!=" comparison	{
	$$ = new Node ("!=");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for != comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if ($1->typestring == "str" ) {
			// call strcmp
			$$->typestring = "bool";
			gen($$,$1,$3,STRCMP);
			// gen($$,$$,NULL,NOT_log);
			// gen($$,$$,NULL,NOT_log);

		}
	else if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for != comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	else if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for != comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	else gen($$,$1,$3,NEQ);
	$$->typestring = "bool";
	
}
	| expr "<" comparison	{
	$$ = new Node ("<");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for < comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if($1->typestring == "str" && $3->typestring == "str") {
		$$->typestring = "bool";
		gen($$,$1,$3,STRCMP);
		Node *dummy = new Node("0");
		dummy->addr="0";
		gen($$,$$,dummy,LT);
		// call strcmp
		// if ($1->isLeaf && $3->isLeaf && $1->production == "__name__" && $3->strVal == "\\\"__main__\\\"") {
		// 	// pass
		// }
	}
	else if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for < comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	else if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for < comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	else gen($$,$1,$3,LT);
	$$->typestring = "bool";
	
}
	| expr "<=" comparison	{
	$$ = new Node ("<=");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for <= comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if($1->typestring =="str"){
		$$->typestring = "bool";
		gen($$,$1,$3,STRCMP);
		Node *dummy = new Node("0");
		dummy->addr="0";
		gen($$,$$,dummy,LTE);
	}
	else if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for <= comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	else if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for <= comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	else gen($$,$1,$3,LTE);
	$$->typestring = "bool";
	
}
	| expr ">" comparison	{
	$$ = new Node (">");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for > comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if($1->typestring == "str"){
		$$->typestring = "bool";
		gen($$,$1,$3,STRCMP);
		Node *dummy = new Node("0");
		dummy->addr="0";
		gen($$,$$,dummy,GT);
	}
	else if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for > comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	else if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for > comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	else gen($$,$1,$3,GT);
	$$->typestring = "bool";
}
	| expr ">=" comparison	{
	$$ = new Node (">=");
	$$->addchild ($1);
	$$->addchild ($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
		exit(1);
	}
	if (($1->typestring == "str" && $3->typestring != "str")
	||  ($1->typestring != "str" && $3->typestring == "str")) {
		dprintf(stderr_copy, "TypeError at line %d: incompatible types for >= comparison: %s and %s\n", $2->lineno, $1->typestring.c_str(), $3->typestring.c_str());
		exit(1);
	}
	if($1->typestring == "str"){
		$$->typestring = "bool";
		gen($$,$1,$3,STRCMP);
		Node *dummy = new Node("0");
		dummy->addr="0";
		gen($$,$$,dummy,GTE);
	}
	else if (!check_number($1)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for >= comparison has type %s\n", $2->lineno, $1->typestring.c_str());
		exit(1);
	}
	else if (!check_number($3)) {
		dprintf(stderr_copy, "TypeError at line %d: first operand for >=T comparison has type %s\n", $2->lineno, $3->typestring.c_str());
		exit(1);
	}
	else gen($$,$1,$3,GTE);
	$$->typestring = "bool";
	
}


expr: xor_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	$$ = $1;
}
	| expr "|" xor_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	gen($$,$1,$3,OR_bit);
}
xor_expr: ans_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	$$ = $1;
}
	| xor_expr "^" ans_expr	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	gen($$,$1,$3,XOR);
}

ans_expr: shift_expr {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	$$ = $1;
}
	| ans_expr "&" shift_expr	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	gen($$,$1,$3,AND_bit);
}
shift_expr: sum {
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	$$ = $1;
} 
	| shift_expr "<<" sum	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	
	gen($$,$1, $3, SHL);
}
	| shift_expr ">>" sum	{
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	
	gen($$,$1, $3, SHR);
}

sum : sum "+" term  { 
		$$ = new Node ("+"); 
		$$->addchild ($1); $$->addchild($3);
		// $$->typestring = $1->typestring;
		if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
			exit(1);
		}
		if ($3->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	
	gen($$,$1, $3, MOD);
}
	| term DOUBLESLASH factor {
	$$ = new Node ("//");
	$$->addchild ($1);
	$$->addchild($3);
	if ($1->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
		exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
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
	
	gen($$,$1, $3, FLOORDIV);
}
	| factor {
	if ($1->typestring == "")	{
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n",$1->lineno, $1->production.c_str());
		exit(1);
	}
	$$ = $1;
}
factor: "+" factor	{
	$$ = new Node ("+");
	$$->addchild($2);
	if ($2->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $2->lineno, $2->production.c_str());
		exit(1);
	}
	if (!check_number($2)) {
		dprintf(stderr_copy, "TypeError at line %d: Invalid type for setting positive, type is %s\n",$2->lineno, $2->typestring.c_str());
		exit(1);
	}
	
	$$->typestring = $2->typestring;
	//no gen needed for this
}
	| "-" factor	{
	$$ = new Node ("-");
	$$->addchild($2);
	if ($2->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $2->lineno, $2->production.c_str());
		exit(1);
	}
	if (!check_number($2)) {
		dprintf(stderr_copy, "TypeError at line %d: negative incompatible with type %s\n",$2->lineno, $2->typestring.c_str());
		exit(1);
	}
	
	$$->typestring = $2->typestring;
	
	gen($$,$2,NULL,NEG);

}
	| "~" factor	{
	$$ = new Node ("~");
	$$->addchild($2);
	if ($2->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $2->lineno, $2->production.c_str());
		exit(1);
	}
	if (!check_number($2) || $2->typestring != "int" && $2->typestring != "bool") {
		dprintf(stderr_copy, "TypeError at line %d: Invalid type for unary not, type is %s\n",$2->lineno, $2->typestring.c_str());
		exit(1);
	}
	
	$$->typestring = "int"; //always
	
	gen($$,$2,NULL,NOT_bit);
}
	| power {
	if ($1->typestring == "")	{
		dprintf(stderr_copy, 
		"NameError at line %d: undefined variable %s\n", 
		$1->lineno, $1->production.c_str());
		if ($1->isLeaf) dprintf (stderr_copy, "Name of variable: %s\n", $1->production.c_str());
		exit(1);
	}
	$$ = $1;
}
power: primary {
    Node *t1 = $1;
    //doesn't conflict with testlist anymore
	current_scope = NULL;
	if ($1->typestring == "") {
		dprintf(stderr_copy, 
		"NameError at line %d: undefined variable [%s]\n", 
		$1->lineno, $1->production.c_str());
		if ($1->isLeaf) dprintf (stderr_copy, "Name of variable: %s\n", $1->production.c_str());
		exit(1);
	}
	if ($1->islval) {
		//if it's reached here, it's no longer valid as an lval
		//so check if any temporaries need to be generated (for
		//cases of assignment to attributes/subscripts)
		//if islval is true and addr is a temporary, addr holds
		//an address/pointer -> all that needs to be done is to
		//dereference it
		// dprintf(stderr_copy, "Production being lvalified: %s addr: %s\n", $1->production.c_str(), $1->addr.c_str());
		$1->islval = false;
		if (!$1->isLeaf /*NOT isLeaf: addr is a temporary*/) {
			// dprintf(stderr_copy, "Leaf indicator\n");
			gen($1, $1, NULL, DEREF);
		}
	}
	$$ = $1;
}
	| primary "**" factor	{
	#if TEMPDEBUG
	printf("in factor, primary: %s factor: %s\n", $1->production.c_str(), $3->production.c_str());
	Node *temp1 = $1;
	Node *temp2 = $2;
	#endif
	
	
	if ($1->typestring == "") {
			dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $1->lineno, $1->production.c_str());
			if ($1->isLeaf) dprintf (stderr_copy, "Name of variable: %s\n", $1->production.c_str());
			exit(1);
	}
	if ($3->typestring == "") {
		dprintf(stderr_copy, "NameError at line %d: identifier %s undefined\n", $3->lineno, $3->production.c_str());
		if ($1->isLeaf) dprintf (stderr_copy, "Name of variable: %s\n", $1->production.c_str());
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
	$$ = new Node ("**");
	if ($1->typestring == "complex" || $3->typestring == "complex") {
		$$->typestring = "complex";
	} else if ($1->typestring == "float" || $3->typestring == "float"){
		$$->typestring = "float";
	} else { //i.e. ints/bools + ints/bools => always int
		$$->typestring = "int";
	}
	//edit $1's lval status and generate temporaries if needed
	if ($1->islval) {
		$1->islval = false;
		if (!$1->isLeaf /*NOT isLeaf: addr is a temporary*/) {
			gen($1, $1, NULL, DEREF);
		}
	}
	$$->addchild($1);
	$$->addchild($3);
	current_scope = NULL;
	gen($$,$1, $3, POW);
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

//these two: see later [in primary ( testlist )]
save_current_scope: /*empty*/ {
    #if TEMPDEBUG
    printf("saving current scope, addr is %p\n", current_scope);
    #endif
    saved_scope = current_scope;
    current_scope = NULL;
}

load_current_scope: /*empty*/ {
    #if TEMPDEBUG
    printf("loading current scope, addr is %p\n", saved_scope);
    #endif
    current_scope = saved_scope;
}

//whenever islval is true, if addr is a temporary, then it is a pointer
primary: atom {
		// // set typestring if available, so we know if it's a declaration or a use
		// cout<<$1->isLeaf<<endl;
		$$ = $1;
		$$->isdecl = true;
		if (top->has($1->production)){
			$$->typestring = top->get($1)->typestring;
			$$->dimension = top->get($1)->dimension;
		if ($1->production == top->thisname) {
			//obv cannot declare type of self (it's already defined)
			$$->isdecl = false;
		}
		current_scope = NULL;
		}
	}
	| primary "." NAME {
		$$ = new Node (0, "", $3->typestring);
		$$->isLeaf = false;
		$$->islval = true;
		Node *tt = $$, *t1 = $1, *t3 = $3;
		if (inside_init 
		&& $1->isLeaf 
		&& $1->production == top->thisname) {
			$$->isdecl = true;
		} else {
			$$->isdecl = false;
		}
		#if TEMPDEBUG
		printf("Test print, lineno: %d, inside primary.name, production: %s.%s\n", 
		$3->lineno, $1->production.c_str(), $3->production.c_str());
		printf("Isdecl: %d\n", $$->isdecl);
		printf("Factors: %d %d %s\n", inside_init, $1->isLeaf, top->thisname.c_str());
		#endif
		string this_ptr = top->thisname;
		// CHECKING PRIMARY

		if ($1->isLeaf) { // set typestring
			if (top->get($1)){
				$1->typestring = top->gettype($1->production);
			}
			else if ($1->production == top->thisname) {
				if (!Classsuite || !currently_defining_class) {
					dprintf (stderr_copy, 
					"Error at line %d: self pointer cannot be used outside class scope\n", 
					(int)$1->lineno);
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
			dprintf (stderr_copy, 
			"Error at line %d: %s is undefined\n", 
			(int)$3->lineno,$1->production.c_str());
			exit(55);
		}
		
		current_scope = find_class($1->typestring);
		
		if (current_scope == NULL || $1->typestring == "class" || $1->typestring == "def") {
			dprintf (stderr_copy, 
			"Error at line %d: Object has invalid type, or is a function or class name\n", 
			(int) $3->lineno);
			exit (56);
		}
		
		if ($3->production == current_scope->thisname) {
			dprintf (stderr_copy, 
			"Error at line %d: self pointer %s cannot be referenced outside function scope\n", 
			(int)$3->lineno, current_scope->thisname.c_str());
			exit(68);
		}

		if (current_scope->find_member_fn($3->production)) {
			//method case, handle separately
			$$->typestring = "def";
			$$->islval = false;
			current_scope = current_scope->find_member_fn($3->production);
			$$->production = $1->typestring +"." + $3->production;
			//store addr of object passed as implicit paramater in method call
			$$->addr = $1->addr;
			// the only case in which current_scope is truly global
			//also, push current object ($1) as argument
			function_call_args.push_back($1);
		    function_call_args_dim.push_back($1->dimension);
			
		} else if ($$->isdecl) {
			//this only happens in a self.something case so we just
			//set the overall production to the last term, it'll get
			//put later on
			$$->lineno = $3->lineno;
			$$->production = $3->production;
			#if TEMPDEBUG
				printf("self something: %s\n", $3->production.c_str());
				current_scope->print_st();
			#endif
			//check if the name has been put into the table already
			//if not, leave it for now (this has been handled in 
			//the assignment productions)
			//if it is in the table, just use that address and then
			//set isdecl to false
			
			auto entry = current_scope->symbols.find(($3->production));
			if (entry != current_scope->symbols.end()) {
				//i.e. already declared
				//get addr of thisname from symbol table
				auto thisname_entry = current_scope->symbols.find(top->thisname);
				$1->addr = thisname_entry->second->node->addr;
				#if TEMPDEBUG
				printf("thisname addr: %s\n", $1->addr.c_str());
				#endif
				//remove isdecl
				$$->isdecl = false;
				$$->typestring = entry->second->typestring;
				//call genattr
				gen($$,$1,$3,ATTR);
			}
		} else {
			//a.b case
			
			auto entry = current_scope->symbols.find(($3->production));
			if (entry == current_scope->symbols.end()) {
				//no prior declaration/definition found -> error
				dprintf (stderr_copy, 
				"Error at line %d: %s is not a member of class %s\n", 
				(int)$3->lineno, $3->production.c_str(), $1->typestring.c_str());
				exit(23);
			}
			//here: then we found a definition -> generate the temporary and set the typestrings/dimension
			$$->typestring = entry->second->typestring;
			$$->dimension = entry->second->dimension;
			$$->lineno = $3->lineno;
			$$->production = $3->production; 
			//should NOT be having any puts if it is already declared
			gen($$,$1,$3,ATTR);
			#if TEMPDEBUG
				printf("a.b something: %s\n", $3->production.c_str());
				printf("typestring: %s addr: %s\n", $$->typestring.c_str(), $$->addr.c_str());
			#endif
		}
		/*
			$ new temp 
			$$->addr = newtemp();
			$1->addr = top->getaddr($1);
			$3->addr = current_scope->getaddr($3);
		*/


	}

	| primary "[" test "]"
		{
		// dprintf(stderr_copy, "Subindex indicator, primary: %s, test: %s\n", $1->production.c_str(), $3->production.c_str());
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
			if($1->dimension != -1 && $3->intVal > $1->dimension){
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
		$$->isLeaf = false; //should deref this to assign to/from it
		$$->dimension = 0; //indexed, and we're only dealing with 1D arrays

		gen($$, $1, $3, SUBSCRIPT);

		}
	| primary "(" save_current_scope testlist load_current_scope  ")" {
	    //we are expecting current_scope not to be null for member functions here!!!
	    //so, use isLeaf to check if this is a member fn
	    //note: save_current_scope saves current_scope to saved_scope and
	    //then sets current_scope to NULL to prevent interference 
		/*
			for i in range(primary->arg_types.size())
				if(primary->arg_types[i] != testlist->children[i]->typestring) error
			update $$->typestring as return type of function
		*/
		#if TEMPDEBUG
		printf("entering primary %s ( testlist )\n", $1->production.c_str());
		#endif
		bool isConstructor = false;
		bool isMemberFn = false;
		$$ = new Node (0, "", "");
		$$->islval = false;
		$$->isdecl = false;
		$$->isLeaf = false;
		
		$<node>3 = $4; //redefine so I don't have to ctrl-f change stuff
		Node *tt = $$, *t1 = $1, *t3 = $<node>3;
		if ($1->isLeaf && !($1->production == "print" || $1->production == "len" || $1->production == "range")) {
			//i.e. not a member function or a builtin
			if (find_fn ($1->production)) {
				//if is a defined function
				current_scope = find_fn($1->production);
				$$->typestring = current_scope->return_type;
				// top->do_function_call (current_scope, function_call_args);
				#if TEMPDEBUG
				printf ("valid call to function %s in line %d, return type: %s\n", $1->production.c_str(), $1->lineno, $$->typestring.c_str());
				#endif
			} else if (globalSymTable->ctor.find($1->production) != globalSymTable->ctor.end()) {
				// call to constructor
				isConstructor = true;
				current_scope = globalSymTable->ctor.find($1->production)->second;
				// $1->production+=".ctor";
				current_scope->label = $1->production+".ctor";
				#if TEMPDEBUG
				printf ("line %d valid call to constructor %s\n", $1->lineno, $1->production.c_str());
				#endif
				$$->typestring = $1->production;

			} else if (globalSymTable->children.find($1->production) != globalSymTable->children.end()) {
				//CONFIRM: this will never be used because it is already checked by find_fn
				current_scope = globalSymTable->children.find ($1->production)->second;
				$$->typestring = current_scope->return_type;
			} else {
				dprintf (stderr_copy, "Error at line %d: Call to undefined function %s.\n", $1->lineno, $1->production.c_str());
				exit(44);
			}
		} else if (!($1->production == "print" || $1->production == "len" || $1->production == "range" )) {
		    //i.e. this is a member function
            // now we expect typestring to be set to def, symboltable to be available in current_scope
            isMemberFn = true;
            $$->typestring = current_scope->return_type;
			if ($1->typestring != "def") {
				dprintf (stderr_copy, "TypeError at line %d: Function call to object of type %s.\n", $2->lineno, $1->typestring.c_str());
				exit(45);
			}// valid function call
            #if TEMPDEBUG
            printf ("valid function call to function %s\n",
                    current_scope ? current_scope->name.c_str() : "" );
            #endif
		}
		// printf("typestring = %s\n", $$->typestring.c_str());
		$$->lineno = $1->lineno;

		// check function_call_args
		int iter;
		
		if ($1->production == "range" && $1->isLeaf) { //builtin range
			if ((function_call_args.size() > 2 || function_call_args.size() < 1)) {
				dprintf (stderr_copy, "Error at line %d: range() expects one or two arguments, received %d\n",
						(int)$1->lineno, (int)function_call_args.size());
				exit (59);
			} else if (function_call_args[0]->typestring != "int" && function_call_args[0]->typestring != "bool" && function_call_args[0]->typestring != "float") {
				dprintf (stderr_copy, "TypeError at line %d: first argument to range() is of incompatible type %s\n", (int)$1->lineno , $1->typestring.c_str());
				exit (58);
			} else if (function_call_args_dim[0] != 0) {
				dprintf (stderr_copy, "TypeError at line %d: first argument to range() is of incompatible type %s[]\n", (int)$1->lineno , $1->typestring.c_str());
				exit (58);
			} else if (function_call_args.size() == 2 && function_call_args[1]->typestring != "int" && function_call_args[1]->typestring != "bool" && function_call_args[1]->typestring != "float") {
				dprintf (stderr_copy, "TypeError at line %d: second argument to range() is of incompatible type %s\n", (int)$1->lineno , $1->typestring.c_str());
				exit (58);
			} else if (function_call_args.size() == 2 && function_call_args_dim[1] != 0) {
				dprintf (stderr_copy, "TypeError at line %d: second argument to range() is of incompatible type %s[]\n", (int)$1->lineno , $1->typestring.c_str());
				exit (58);
			}
			$$->typestring = "";
		} else if ($1->production == "print" && $1->isLeaf) { //builtin print
			if (function_call_args.size() != 1) {
				dprintf (stderr_copy, "Error at line %d: print() expects one argument, received %d\n",
						(int)$1->lineno, (int)function_call_args.size());
				exit (59);
			} else if (function_call_args[0]->typestring != "int" && function_call_args[0]->typestring != "bool" && function_call_args[0]->typestring != "str" && 
					function_call_args[0]->typestring != "float" &&  function_call_args[0]->typestring != "complex") {
				dprintf (stderr_copy, "Error at line %d: print() received argument of non-primitive type %s\n",
						(int) $1->lineno, (function_call_args[0]->typestring + (function_call_args_dim[0]? "[]" : "")).c_str());
				exit (83);
			}

			$$->typestring = "None";
			// top->call_printf (function_call_args[0]);

		} else if ($1->production == "len" && $1->isLeaf) { //builtin len
			if (function_call_args.size() != 1) {
				dprintf (stderr_copy, "Error at line %d: len() expects one argument, received %d\n",
						(int)$1->lineno, (int)function_call_args.size());
				exit (59);
			} else if (function_call_args_dim[0] == 0 && function_call_args[0]->typestring != "str") {
				dprintf (stderr_copy, "TypeError at line %d: argument to len() neither a string nor a list\n",
						(int) $1->lineno);
				exit (49);
			} else if (function_call_args_dim[0] == -1) {
			    dprintf (stderr_copy, "Error at line %d: argument to len() is an uninitialized list\n",
						(int) $1->lineno);
				exit (49);
			}
			$$->typestring = "int";
		} else { //i.e. user defined function: not len, range or print
			if (function_call_args.size() != current_scope->arg_types.size()) {
				dprintf (stderr_copy, "Error at line %d: Function call expected %d arguments, received %d\n",
					(int)$1->lineno, (int)current_scope->arg_types.size(),(int) function_call_args.size());
				exit (60);
			}
            //skip 1st argument if this is a member function to avoid throwing error
            //due to derived class using base class method call
			for (iter = (isMemberFn ? 1 : 0); iter< current_scope->arg_types.size(); iter ++) { 
				if (function_call_args[iter]->typestring == (current_scope->arg_types)[iter]
				 && check_array(function_call_args_dim[iter], (current_scope->arg_dimensions)[iter] )) {
					continue;
				}
				
				if (    
					(
						(function_call_args[iter]->typestring == "int" 
					  && current_scope->arg_types[iter] == "bool")
					|| 	(function_call_args[iter]->typestring == "int" 
					  && current_scope->arg_types[iter] == "float")
					|| 	(function_call_args[iter]->typestring == "bool" 
					  && current_scope->arg_types[iter] == "int")
					|| 	(function_call_args[iter]->typestring == "int" 
					  && current_scope->arg_types[iter] == "bool")
					) 
				&& check_array(function_call_args_dim[iter], (current_scope->arg_dimensions)[iter])) {
					continue;
				}
				if (function_call_args[iter]->typestring != current_scope->arg_types[iter]) {
					dprintf (stderr_copy,
					"TypeError at line %d: expected argument %d to be %s, received incompatible type %s\n",
					(int) $1->lineno, 
					iter+1,
					current_scope->arg_types[iter].c_str(), 
					function_call_args[iter]->typestring.c_str());
					exit(80);
				} else if (!!function_call_args_dim[iter] != !!current_scope->arg_dimensions[iter]) {
					//one is array, other is not
					dprintf(stderr_copy,
					"TypeError at line %d: expected argument %d to be of type %s, received incompatible type %s\n",
					(int) $1->lineno, 
					iter+1,
					(current_scope->arg_types[iter] +(current_scope->arg_dimensions[iter] ? "[]" : "")).c_str(),
					(current_scope->arg_types[iter] +(function_call_args_dim[iter]? "[]" : "")).c_str());
					exit(80);
				}
			}
		}

		//if we haven't exited until now, everything is fine
		// reversing push params as per format
		reverse(function_call_args.begin(), function_call_args.end());
		// fill 3ac for function call
		//we reversed function_call_args -> make sure we are accessing the right arg
		int len = (current_scope?  current_scope->arg_types.size(): -1);
		if (len == -1) {
			if ($1->production == "print") {
				len = 1;
				if (function_call_args[0]->typestring != "str" 
						&& function_call_args[0]->typestring != "int"
						&& function_call_args[0]->typestring != "float"
						&& function_call_args[0]->typestring != "bool"
				   ) {
					dprintf (stderr_copy, "Error at line %d: print passed non-primitive type %s\n",
							(int)$1->lineno, function_call_args[0]->typestring.c_str());
					exit(83);
				}
			}
			else if ($1->production == "range") {
				if (function_call_args[0]->typestring != "int" 
						|| (function_call_args.size() == 2 && function_call_args[1]->typestring != "int")
				   ) {
					dprintf (stderr_copy, "Error at line %d: range passed incompatible type %s\n",
							(int)$1->lineno, function_call_args[0]->typestring.c_str());
					exit(83);
				}
			}
			else if ($1->production == "len") {
				len = 0; //avoid iteration in array later on
				if (function_call_args_dim[0] == 0) {
					dprintf (stderr_copy, "Error at line %d: argument to len() is not a list\n", (int) $1->lineno);
					exit (54);
				}
			} else {
				dprintf (1, "internal errror - current_scope is NULL inside primary -> primary (...)\n");
				exit(74);
			}
		}
		int size = 0;
		for (iter = 0; iter < len; iter ++) {
			//typecast
			bool cast = false;
			string temp = "";
			//only need coercion for nonbuiltins
			if (current_scope != NULL) {
				if ( function_call_args[iter]->typestring == "int"
			&& current_scope->arg_types[len - iter - 1] == "bool") {
					cast = true;
					temp = newtemp();
					fprintf(tac, "\t%s = INT_TO_BOOL(%s)\n", temp.c_str(), function_call_args[iter]->addr.c_str());
				}
				if ( function_call_args[iter]->typestring == "int"
			&& current_scope->arg_types[len - iter - 1] == "float") {
					cast = true;
					temp = newtemp();
					fprintf(tac, "\t%s = INT_TO_FLOAT(%s)\n", temp.c_str(), function_call_args[iter]->addr.c_str());
				}
				if ( function_call_args[iter]->typestring == "bool"
			&& current_scope->arg_types[len - iter - 1] == "int") {
					cast = true;
					temp = newtemp();
					fprintf(tac, "\t%s = BOOL_TO_INT(%s)\n", temp.c_str(), function_call_args[iter]->addr.c_str());
				}
				if ( function_call_args[iter]->typestring == "float"
			&& current_scope->arg_types[len - iter - 1] == "int") {
					cast = true;
					temp = newtemp();
					fprintf(tac, "\t%s = FLOAT_TO_INT(%s)\n", temp.c_str(), function_call_args[iter]->addr.c_str());
				}
			}
			//push onto stack
			if (cast) {
				fprintf(tac, "\tparam %s\n", temp.c_str());
			} else {
				fprintf(tac, "\tparam %s\n", dev_helper(function_call_args[iter]).c_str());
			}
			string typestring = function_call_args[iter]->typestring;
			size+=8;
			// if (typestring == "bool" || typestring == "float" || typestring == "int") {
			// 	size += 8;
			// } else if (typestring == "complex" || typestring == "str") {
			// 	size += 8;
			// } else {
			// 	size += getwidth(typestring);
			// }
		}
		
		//this is the most convenient place to put this, honest!
		//here is also where the x86 is generated for fxn calls
		if (!($1->production == "len" && $1->isLeaf)) {
            //if this is a member function, push calling object onto list too
            //address list reversed + object is 1st param => put object as last param
            //addr of obj saved in $1->addr
//             if (isMemberFn) {
//                 fprintf(tac, "\tparam %s\n", $1->addr.c_str());
//                 len++;
//                 size+=8;
			string temp="";
            if (isConstructor) {
                temp = newtemp();
                fprintf(tac,"\t%s = %d\n", temp.c_str(), getwidth($$->typestring));
                fprintf(tac,"\tparam %s\n", temp.c_str());
                fprintf(tac,"\tstackpointer -%d\n", (int)top->table_size + 8);
                fprintf(tac,"\tcall allocmem 1\n");
                fprintf(tac,"\tstackpointer +%d\n", (int) top->table_size + 8);
                fprintf(tac,"\t%s = popparam\n",temp.c_str());
                fprintf(tac,"\tparam %s\n",temp.c_str());	
                size += 8;
                
                //generate x86 for this
                //confirm if table_size needs +8 or not
                top->call_malloc(top->table_size);
				fprintf(x86asm, "\t# %s = ret\n", temp.c_str());
				fprintf(x86asm,"\tmovq %%rax, -%ld(%%rbp)\n",top->get_rbp_offset(temp));

				// fprintf(x86asm, "\t# param %s\n",temp.c_str());
				// fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rcx\n", top->get_rbp_offset(temp));
				// fprintf(x86asm ,"\tpushq %%rcx\n");				

            }
        
            //move stackptr
            fprintf(tac, "\tstackpointer -%d\n", size + 16);
            //function call
            //if the function has no return type, don't allocate a temp for it and leave addr blank
            //addr blank because should have no ops after this anyway
            //if it has a return type, allocate a temp for it and assign to this node
            //note: len has number of args (see above)
            if (!current_scope) {
                //built-in: len, print, range
                if ($1->production == "len") {
                    //this isn't handled here, check the else block at the end
                    dprintf(stderr_copy, "Internal Error: accessed len function somehow");
                    exit(1);
                } else if ($1->production == "range") {
                    //return something
                    //TO DO
                } else if ($1->production == "print") {
                    //returns nothing
                    fprintf(tac, "\tcall print 1\n");
                    top->call_printf(function_call_args[0]);
                }
            } else {
                //not a built-in
                if (current_scope->return_type != "None") {
                    $$->addr = newtemp();
                    fprintf(tac, "\t%s = call %s %d\n", $$->addr.c_str(), current_scope->label.c_str(), len);
                    
                    //do function call
                    //no issue with reversed vector, we want that to be like that
                    fprintf(x86asm, 
                    "\t# function call: %s aka %s aka %s\n", 
                    $1->production.c_str(), current_scope->name.c_str(), current_scope->label.c_str());
                    top->do_function_call(current_scope, function_call_args,temp);
					// fprintf(x86asm, "\t# param %s\n",temp.c_str());
				// fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rcx\n", top->get_rbp_offset(temp));
				// fprintf(x86asm ,"\tpushq %%rcx\n");	
                    fprintf(x86asm, "\t# %s = ret\n",$$->addr.c_str());
					fprintf(x86asm, "\tmovq %%rax, -%ld(%%rbp)\n",top->get_rbp_offset($$->addr));
                } else if (isConstructor){
                    $$->addr = newtemp();
                    fprintf(tac, "\t%s = call %s %d\n", $$->addr.c_str(), current_scope->label.c_str(), len);
                    
                    fprintf(x86asm, 
                    "\t# function call: %s aka %s aka %s\n", 
                    $1->production.c_str(), current_scope->name.c_str(), current_scope->label.c_str());
                    top->do_function_call(current_scope, function_call_args,temp);
                    fprintf(x86asm, "\t# %s = ret\n", $$->addr.c_str());
					fprintf(x86asm, "\tmovq %%rax, -%ld(%%rbp)\n",top->get_rbp_offset($$->addr));
                } else {
                    fprintf(tac, "\tcall %s %d\n", current_scope->label.c_str(), len);
                    fprintf(x86asm, 
                    "\t# function call: %s aka %s aka %s\n", 
                    $1->production.c_str(), current_scope->name.c_str(), current_scope->label.c_str());
                    top->do_function_call(current_scope, function_call_args,temp);
                }
            }		        
            fprintf(tac, "\tstackpointer +%d\n", size + 16);
        } else {
            //handle len here
            //error checking has already been handled earlier
            $$->addr = newtemp();
            //new node for constant value of param
            Node *param_length = new Node(NUMBER, (long int)function_call_args_dim[0]);
            gen($$, $$, param_length, ASSIGN);
        }
        
		function_call_args.clear();
		function_call_args_dim.clear();
		//consume current_scope, we're done with it
        current_scope = NULL;

	}
	| primary "(" ")" {
	//again, for member functions, current_scope should not be null here!
		/*
			if primary is constant then error
			if primary is not in current scope then error
			if primary is not a function then error

			update $result type as the return type of function
		*/
	    bool isConstructor = false;
	    bool isMemberFn = false;
		if (($1->production == "print" || $1->production == "len" || $1->production == "range") && ($1->isLeaf)) {
			if ($1->production == "range") {
				dprintf (stderr_copy, "Error at line %d: range() expects one or two arguments, received zero\n",
						(int)$1->lineno);
			} else {
				dprintf (stderr_copy, "Error at line %d: %s() expects one argument, received zero\n",
						(int)$1->lineno, $1->production.c_str());
			}
		    exit (83);
		}
		$$ = new Node (0, "", "");
		if ($1->isLeaf) {
			if(is_not_name($1)){
				dprintf (stderr_copy, "Error at line %d: invalid function call\n", $1->lineno);
				exit(1);
			}
			if (top->find_member_fn ($1->production)) {
			    isMemberFn = true;
				// $1->typestring = "def";
				$$->typestring = top->find_member_fn($1->production)->return_type;
				current_scope = top->find_member_fn($1->production);

				#if TEMPDEBUG
					printf("typestring = %s\n", $$->typestring.c_str());
					printf ("valid call to function %s in line %d\n", $1->production.c_str(), $1->lineno);
				#endif
				// fill 3ac for function call
			} else if (globalSymTable->ctor.find($1->production) != globalSymTable->ctor.end()) {
				// call to constructor
				isConstructor = true;
				current_scope = globalSymTable->ctor.find($1->production)->second;
				$$->typestring = $1->production;
				// $1->production+=".ctor";
				current_scope->label =$1->production+".ctor";
				#if TEMPDEBUG
				printf ("line %d valid call to constructor %s\n", $1->lineno, $1->production.c_str());
				#endif
			} else if (globalSymTable->children.find($1->production) != globalSymTable->children.end()) {
				current_scope = globalSymTable->children.find ($1->production)->second;
				$$->typestring = current_scope->return_type;
			} else if (globalSymTable->find_member_fn ($1->production)) {
				current_scope = globalSymTable->find_member_fn($1->production);
				$$->typestring = current_scope->return_type;
			} else {
				dprintf(stderr_copy, "Error at line %d: Call to undefined function %s.\n", $1->lineno, $1->production.c_str());
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
		if ($$->typestring == "")
			$$->typestring = current_scope->return_type;
			
		#if TEMPDEBUG
		printf("end typestr: %s\n", $$->typestring.c_str());
		#endif
		// printf("typestring = %s\n", $$->typestring.c_str());
		$$->lineno = $1->lineno;
        
        #if TEMPDEBUG
        if (function_call_args[0]->typestring != current_scope->arg_types[0]) {
            printf("inherited function call!\n");
        }
        #endif
        
		int size = current_scope->arg_types.size();
		if (function_call_args.size() != size
		|| (size > 0 
		    &&  (   function_call_args_dim[0] != 0
		        // ||  function_call_args[0]->typestring != current_scope->arg_types[0]
		    )
		)) {
		    dprintf(stderr_copy, "Something is terribly wrong, please check\n \
		    size: %d function_call_args_dim[0]: %d \n \
		    function_call_args typestring: [%s] current_scope arg types: [%s]\n",
		    size, function_call_args_dim[0], function_call_args[0]->typestring.c_str(),
		    current_scope->arg_types[0].c_str());
		    exit(69);
		}
		
		if (size > 0) {
		    //size should really only be 1 if we've entered here
		    if (size != 1) {
		        dprintf(stderr_copy, "Size not 1, is %d instead\n", size);
		    }
		    size *= 8;
		    //push implicit param onto stack
		    fprintf(tac, "\tparam %s\n", dev_helper(function_call_args[0]).c_str());
		}
		string temp="";
		if (isConstructor) {
			temp = newtemp();
			fprintf(tac,"\t%s = %d\n", temp.c_str(), getwidth($$->typestring));
			fprintf(tac,"\tparam %s\n", temp.c_str());
			fprintf(tac,"\tstackpointer -%d\n", 8);
			fprintf(tac,"\tcall allocmem 1\n");
			fprintf(tac,"\tstackpointer +%d\n", (int) top->table_size+8);
			fprintf(tac,"\t%s = popparam\n",temp.c_str());
			fprintf(tac,"\tparam %s\n",temp.c_str());	
			size += 8;
		top->call_malloc(top->table_size);
		fprintf(x86asm, "\t# %s = ret\n", temp.c_str());
		fprintf(x86asm,"\tmovq %%rax, -%ld(%%rbp)\n",top->get_rbp_offset(temp));

		// top->do_function_call(current_scope, function_call_args); // complete this later // made changes check !!
		// fprintf(x86asm, "\t# param %s\n",temp.c_str());
		// fprintf (x86asm, "\tmovq -%ld(%%rbp), %%rcx\n", top->get_rbp_offset(temp));
		// fprintf(x86asm ,"\tpushq %%rcx\n");
		}
		
		fprintf(tac, "\tstackpointer -%d\n", size + 16);

		if (!current_scope) {
			//built-in: len, print, range
			//these were already handled above, so if we've gotten here there is a problem
			printf ("There might be an issue because this isn't supposed to happen \
			\nhandle this case: search key tehran\n");
			exit(69);
		}
			//not a built-in
		top->do_function_call(current_scope, function_call_args,temp); // complete this later
		if (current_scope->return_type != "None"
		||  isConstructor) {
			$$->addr = newtemp();
			if (size) {
				fprintf(tac, "\t%s = call %s %d\n", $$->addr.c_str(), current_scope->label.c_str(), size / 8);
			} else {
				fprintf(tac, "\t%s = call %s\n", $$->addr.c_str(), current_scope->label.c_str());
			}
			fprintf(x86asm,"\t# %s = ret\n", $$->addr.c_str());
			fprintf(x86asm, "\tmovq %%rax, -%ld(%%rbp)\n",top->get_rbp_offset($$->addr));
		} else {
			fprintf(tac, "\tcall %s %d\n", current_scope->label.c_str(), size / 8);
		}
		
		fprintf(tac, "\tstackpointer +%d\n", size + 16);
		// $$->addr= "call "+ $1->addr;

		// milestone 3 begins here
		// if return val: fetch from rax
		function_call_args.clear();
		function_call_args_dim.clear();
		current_scope = NULL;
	}




//default value for islval is false
atom: NAME {
		if (top->getnode ($1->production) == NULL) {
			$$ = $1;
		} else {
			  $$ = top->getnode($1->production);
		}
		$$->islval = true;
}
    | NUMBER {
		$1->addr=newtemp();
		//fprintf(x86asm,"askdjfashldfjl\n\n\n");
		fprintf(tac,"\t%s = %s\n", $1->addr.c_str(),$1->production.c_str());
		fprintf(x86asm,"\t# %s = %s\n", $1->addr.c_str(),$1->production.c_str());
		fprintf(x86asm,  "\tmovq $%s, %%r13\n",$1->production.c_str());
		top->asm_store_value_r13($1->addr);
		$$=$1;
	}
    | STRING_plus {
		$$ = $1;
		$$->production = concatenating_string_plus;
		concatenating_string_plus = "\0";
		$$->typestring = "str";
		$$->addr = newtemp();

		fprintf (tac, "\t<string literal> %s = ptr(\"%s\")\n", top->getaddr($$).c_str(), $$->production.c_str()) ;
		fprintf (x86asm, "\t# <string literal> %s = ptr(\"%s\")\n", top->getaddr($$).c_str(), $$->production.c_str()) ;
		
		static_section += "str_literal" + to_string (str_count ++) + ":\t.asciz,\"";
		static_section += $$->production + "\"\n";
		fprintf (x86asm, "\tleaq str_literal%d(%%rip), %%rbx\n", str_count-1);
		fprintf (x86asm, "\tmovq %%rbx, -%ld(%%rbp)\n", top->get_rbp_offset($$->addr));
	}
	|"(" test ")"{$$=$2;}
    | "True" {
		$1->addr=newtemp();
		fprintf(tac,"\t%s = 1\n", $1->addr.c_str());
		fprintf(x86asm,"\t# %s = 1\n", $1->addr.c_str());
		fprintf(x86asm,  "\tmovq $1, %%r13\n");
		top->asm_store_value_r13($1->addr);
		$$=$1;
	}
    | "False" {
		$1->addr=newtemp();
		fprintf(tac,"\t%s = 0\n", $1->addr.c_str());
		fprintf(x86asm,"\t# %s = 0\n", $1->addr.c_str());
		fprintf(x86asm,  "\tmovq $0, %%r13\n");
		top->asm_store_value_r13($1->addr);
		$$=$1;
	}
    | "None" 
	| "[" list_start testlist "]" {
		$$ = $3;
		string temp;
		temp +="[  ] Contained\n";
		temp += $3->production;
	 	$$->rename(temp);
		list_init = false;
		// lists are the ONLY way to increase the refcounts of objects, so we cannot store lists of pointers to possibly stack objects. Copy the damn thing.
		if (find_class (currently_defining_identifier_typestring) == NULL)
		{	
			dprintf (stderr_copy, "Error at line %d: list of unknown type\n", yylineno);
			exit (55);
		}
		// Node* $$ = new Node (0, "", "");
		$$->addr= newtemp();
		int thissize = find_class (currently_defining_identifier_typestring)->table_size;
		fprintf (tac, "\t%s = ALLOC_HEAP (%lu)\n", dev_helper($$).c_str(), list_init_inputs.size() * thissize);
		fprintf (x86asm, "\t# %s = ALLOC_HEAP (%lu)\n", dev_helper($$).c_str(), list_init_inputs.size() * thissize);
		
		string ret = newtemp();
		top->call_malloc (list_init_inputs.size() * 8);
		fprintf(x86asm, "\t# %s= ret\n",ret.c_str());
		fprintf (x86asm, "\tmovq %%rax, -%ld(%%rbp)\n", top->get_rbp_offset(ret));
		for(auto itrv:list_init_inputs){
			// 3ac to copy list to temp
				gen ($$, itrv, (Node*) NULL, SW);
				fprintf(tac, "\t%s= %s + %d\n", dev_helper($$).c_str(), dev_helper($$).c_str(), thissize);
				fprintf(x86asm, "\t# %s= %s + %d\n", dev_helper($$).c_str(), dev_helper($$).c_str(), thissize);
				
				fprintf (x86asm, "\taddq $8, -%ld(%%rbp)\n", top->get_rbp_offset(ret));
		}
		fprintf(tac, "\t%s = %s - %lu\n", 
		dev_helper($$).c_str(), dev_helper($$).c_str(), list_init_inputs.size() * thissize);
		fprintf (x86asm, "\tsubq $%ld, -%ld(%%rbp)\n", list_init_inputs.size()*8, top->get_rbp_offset(ret));

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

if_stmt:    "if" test new_jump_to_end3 insert_jump_if_false3 
            ":" suite[ifsuite] insert_end_jump_label3 
            jump_target_false_lower3 upper_jump_target_reached3 {
                $$ = new Node ("If Block");
                $$->addchild($2, "If");
                $$->addchild($ifsuite, "Then");
		}
	|       "if" test new_jump_to_end3 insert_jump_if_false3 
	        ":" suite[ifsuite] insert_end_jump_label3 
	        jump_target_false_lower3 elif_block[elifsuite] {
	            $$ = new Node ("If Else Block");
	            $$->addchild($2, "If");
	            $$->addchild($ifsuite, "Then");
	            $$->addchild($elifsuite, "Else");
	    }

elif_block:
	"else" ":" suite upper_jump_target_reached3 	{ $$ = $3;}
	| "elif" test ":" insert_jump_if_false3 suite[elifsuite]	jump_target_false_lower3 upper_jump_target_reached3 
	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($elifsuite, "Then"); } /* ok????? fine */ 
	| "elif" test ":" insert_jump_if_false3 suite[elifsuite] insert_end_jump_label3 jump_target_false_lower3 elif_block[nextblock]	
	{$$ = new Node ("If"); $$->addchild ($2, "Condition"); $$->addchild($elifsuite, "Then"); $$->addchild ($nextblock, "Else"); }

new_jump_to_end3: {
			// jump to the end of the if-elif-else sequence
			// insert at the end of every suite, to jump to the end.
			get_next_label_upper3("");
	}

insert_jump_if_false3: {
		string lbl = get_next_label3("");
		fprintf (tac, "\tifFalse %s\tjmp %s\n",  dev_helper($<node>-1).c_str(), lbl.c_str());
		// fprintf (x86asm, "\t# ifFalse %s\tjmp %s\n",  dev_helper($<node>-1).c_str(), lbl.c_str());
		fprintf (x86asm, "\tcmpq $0, -%ld(%%rbp)\n", top->get_rbp_offset(dev_helper($<node>-1)));
		fprintf (x86asm, "\tje %s\n", lbl.c_str());
	}


insert_end_jump_label3: {
		string lbl = jump_labels_upper3.top().c_str();
		fprintf (tac, "\tjmp\t%s\n", lbl.c_str());
		fprintf (x86asm, "\tjmp %s\n", lbl.c_str());
	}

jump_target_false_lower3: {
		string lbl = get_current_label3();							  
		fprintf (tac, "\n%s:\n", lbl.c_str());
		fprintf (x86asm, "%s:\n", lbl.c_str());
	}

upper_jump_target_reached3 : {
		string lbl = get_current_label_upper3();
		fprintf (tac, "%s:\n", lbl.c_str());
		fprintf (x86asm, "%s:\n", lbl.c_str());
	}





while_stmt: "while" begin_loop_condition test[condition] ":" 
            insert_jump_if_false { inLoop++; }
            suite[action] { inLoop--; }
            loop_end_jump_back jump_target_false_lower {
                $$ = new Node ("While"); 
                $$->addchild($condition, "Condition"); 
                $$->addchild($action, "Do");
            }

begin_loop_condition : {
		string lbl = get_next_label_upper("");
		fprintf (tac, "\n%s:\n", lbl.c_str());
		fprintf (x86asm, "%s:\n", lbl.c_str());
	}

insert_jump_if_false : {
		string lbl = get_next_label("");
		fprintf (tac, "\tifFalse %s\tjmp %s\n", dev_helper($<node>-1).c_str(), lbl.c_str());
		fprintf (x86asm, "\tcmpq $0, -%ld(%%rbp)\n", top->get_rbp_offset(dev_helper($<node>-1).c_str()));
		fprintf (x86asm, "\tje %s\n", lbl.c_str());
	}

loop_end_jump_back : {
		string lbl = get_current_label_upper();
		fprintf (tac, "\tjmp %s\n", lbl.c_str());
		fprintf (x86asm, "\tjmp %s\n", lbl.c_str());
	}

jump_target_false_lower : {
		string lbl = get_current_label();
		fprintf (tac, "\n%s:\n", lbl.c_str());
		fprintf (x86asm, "%s:\n", lbl.c_str());
	}

arglist: test[obj]
	{	
		if (list_init) { // NUMBER, STRING, CLASS, BOOL, NONE
			// base of the list is a static region in memory but we don't know the length yet. so store in a vector for now
			list_init_inputs.push_back ($obj);
		}

		function_call_args.push_back ($obj);
		function_call_args_dim.push_back($obj->dimension);
	}
	| arglist "," test[obj] { $$ = new Node ("Multiple terms"); $$->addchild($1); $$->addchild($3);
		if (list_init)
			list_init_inputs.push_back ($obj);
		function_call_args.push_back ($obj);
		function_call_args_dim.push_back ($obj->dimension);
	}



typedarglist:  typedargument {/*top->arguments push*/$$=$1;}
	| NAME {/*this pointer in case inClass==1 otherwise error*/
		
		#if TEMPDEBUG
		printf("Inside arglist, thisname setter, name is %s\n", $1->production.c_str());
		#endif
		
		if (!Classsuite) {
			dprintf (stderr_copy, "Error in line %d: Argument %s to function does not have a type hint\n", $1->lineno, $1->production.c_str());
			exit (77);
		}
		if (top->thisname != "") {
			dprintf (stderr_copy, "Error in line %d: Argument %s to function does not have a type hint. \"this\" pointer has been declared.\n", $1->lineno, $1->production.c_str());
			exit (76);
		}
		top->thisname=$1->production;
		$$=$1;
		
		if (!inside_init) {
            //adding implicit object argument for method calls
            //NOT for constructors
            //type: class itself
            //dimension: must be 0
            top->arg_types.push_back(currently_defining_class->name);
            top->arg_dimensions.push_back(0);
		}
		
		$1->addr="t"+to_string(basecount);
		// $1->isLeaf=false;
		fprintf(tac, "\t%s = popparam\n", $1->addr.c_str());
		fprintf(x86asm, "\t# %s = popparam\n", $1->addr.c_str());
		basecount++;
		resettemp(1);
		function_params.push_back ($1);
		top->put($1, currently_defining_class->name);
		currently_defining_class->put($1, currently_defining_class->name);
		$1->addr="t"+to_string(basecount-1);
		top->getnode($1->production) ->addr= "t"+to_string(basecount-1);
		currently_defining_class->table_size = 0;
		if (currently_defining_class->parent_class) 
			currently_defining_class->table_size = currently_defining_class->parent_class->table_size;
	}
	| typedarglist "," typedargument[last] { 
		$$ = new Node ("Multiple Terms"); 
		$$->addchild($1); 
		$$->addchild($last);

	}

typedarglist_comma: typedarglist | typedarglist ","

typedargument: NAME ":" typeclass {
        $$ = new Node ("Typed Parameter");
        $$->addchild($1,"Name");
        $$->addchild($3,"Type");
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
		top->arg_types.push_back ($3->production);
		top->arg_dimensions.push_back ($3->dimension);

		$1->addr="t"+to_string(basecount);
		// $1->isLeaf=false;
		fprintf(tac, "\t%s = popparam\n", $1->addr.c_str());
		fprintf(x86asm, "\t# %s = popparam\n", $1->addr.c_str());
		basecount++;
		function_params.push_back ($1);
		resettemp(1);
		put ($1, $3);
		$1->addr="t"+to_string(basecount-1);
		top->getnode($1->production) ->addr= "t"+to_string(basecount-1);

	}

suite:  simple_stmt[first] 
	| NEWLINE  INDENT {resettemp(1);}stmts[third] DEDENT 
/* when using multiple mid-rule actions avoid using $1, $2, $3 as its more rigid to code changes*/
/* use common non terminal (like functionstart here) to use mid-rule actions if getting reduce reduce error( which occurs if two rules have the same prefix till the code segment and the lookahead symbol after the code is also same)  */


funcdef: "def" NAME[id]  functionstart "(" typedarglist_comma[param] ")" "->" typeclass[ret] {
	top->return_type = $ret->production;
	top->child_enter_function();
}":" suite[last] {
		Funcsuite=0;
		if (inside_init) currently_defining_class->print_local_symbols(stdump);
		top->print_local_symbols(stdump);
		top->child_return();
		endscope(); inside_init = 0;
		$$ = new Node ("Function Defn");
		$$->addchild($id, "Name");
		$$->addchild($param,"Parameters");
		$$->addchild($ret, "Return type");
		$$->addchild($last, "Body");
		function_call_args_dim.clear();
		function_call_args.clear();

		basecount-=function_params.size();
		function_params.clear();
		if($ret->production!="None"&&!returned){
			dprintf(stderr_copy, "Error at line %d: Function %s does not return a value\n", $id->lineno, $id->production.c_str());
			exit(1);
		}
		fprintf(x86asm,"\tretq\n");
		fprintf(tac, "\tendfunc\n");

	}
	| "def" NAME[id] functionstart "(" ")" "->" typeclass[returntype] {
		top->return_type = $returntype->production;
		top->child_enter_function();
	} ":" suite[last] {
	       	Funcsuite=0;
		if (inside_init) currently_defining_class->print_local_symbols(stdump);
		top->print_local_symbols(stdump);
			top->child_return();
		endscope(); inside_init = 0;
	       	$$ = new Node ("Function Defn"); $$->addchild($id, "Name");
	       	$$->addchild($returntype, "Return type");
	       	$$->addchild($last, "Body");
			function_call_args_dim.clear();
			function_call_args.clear();
			basecount-=function_params.size();
			function_params.clear();
			fprintf(tac, "\tendfunc\n");
		if($returntype->production!="None"&&!returned){
			dprintf(stderr_copy, "Error at line %d: Function %s does not return a value\n", $id->lineno, $id->production.c_str());
			exit(1);
		}
		if($id->production!="main")fprintf(x86asm,"\tretq\n");
	}
	| "def" NAME[id] functionstart "(" typedarglist_comma[param] ")" ":" {
	    #if TEMPDEBUG
        printf("entering function definition of %s\n", $2->production.c_str());
        #endif
			top->return_type = "None";
			top->child_enter_function();
		}
		suite[last] {
	       	Funcsuite=0;
		if (inside_init)
		    currently_defining_class->print_local_symbols(stdump);
		top->print_local_symbols(stdump);
        top->child_return();
		inside_init = 0;
        $$ = new Node ("Function Defn");
        $$->addchild($id, "Name");
        $$->addchild($param,"Parameters");
        $$->addchild($last, "Body");
        function_call_args_dim.clear();
        function_call_args.clear();

        basecount-=function_params.size();
        function_params.clear();			
        
        if ($id->production != "__init__") {
            fprintf(tac, "\tret \n");
        } else {
            fprintf(tac, "\tret t%d\n", basecount);
			string mpt= "t";
			mpt+=to_string(basecount);
			fprintf(x86asm,"\tmovq -%ld(%%rbp), %%rax\n",top->get_rbp_offset(mpt));
			// fprintf(x86asm,"\tretq -%ld(%%rbp)\n",top-.get)
        }
		if($id->production!="main")fprintf(x86asm,"\tretq\n");
		returned=0;
        fprintf(tac, "\tendfunc\n");
		endscope(); 
	}
	| "def" NAME[id] functionstart "(" ")" ":" {
			top->return_type = "None";
			top->child_enter_function();
	}suite[last] {
	       	Funcsuite=0;
		if (inside_init) currently_defining_class->print_local_symbols(stdump);
		top->print_local_symbols (stdump);
		top->child_return();
		endscope(); inside_init = 0;
		$$ = new Node ("Function Defn");
		$$->addchild($id, "Name");
		$$->addchild($last, "Body");
		function_call_args_dim.clear();
		function_call_args.clear();

		basecount-=function_params.size();
		function_params.clear();
		if(!returned)fprintf(x86asm,"\tretq\n");
		returned=0;
		fprintf(tac, "\tendfunc\n");
	}

functionstart:  {
		#if TEMPDEBUG
		printf("start function scope\n");
		printf("scope name= %s\n", $<node>0->production.c_str());
		if (Classsuite)
			printf ("class name in method def: %s\n", currently_defining_class->name.c_str());
			printf("production: %s\n", $<node>0->production.c_str());
		#endif
		// if inside_init or classsuite = 0, add functions to globalSymTable
		// else add to currently_defining_class
		if (Classsuite && $<node>0->production == "__init__"){
			inside_init = 1;
		}
		Funcsuite = 1;

		if (inside_init) {
			top = new SymbolTable (globalSymTable, CTOR_ST, currently_defining_class->name);
			string temp =currently_defining_class->name + ".ctor";
			fprintf (x86asm, "%s:\n", temp.c_str());
		}
		else {
			top = new SymbolTable (
					top,
					Classsuite?MEMBER_FN_ST:FUNCTION_ST,
					$<node>0->production);
			fprintf (x86asm, "%s:\n", $<node>0->production.c_str());
		}
		top->label=top->name;
		if(currently_defining_class){
			if(inside_init){
				top->label=currently_defining_class->name+".ctor";
			}
			else{
				top->label=currently_defining_class->name+"."+top->name;
			}
			currently_defining_class->children[$<node>0->production] = top;
		}
		top->lineno = $<node>0->lineno;
		top->isFunction =1;
		fprintf(tac, "%s:\n", top->label.c_str());
		fprintf(tac, "\tbeginfunc\n");
		returned=0;
	}
;
classdef: "class" NAME classstart ":" {
	function_call_args_dim.clear();
	function_call_args.clear();
} suite[last] {
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
	printf("Checking parent class %s\n", $parent->production.c_str());
#endif
	if (currently_defining_class || Classsuite) {
		dprintf (stderr_copy, "Error: Nested declaration of classes\n");
		exit(43);
	}
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
	currently_defining_class->parent_class = parent;
}

compound_stmt: 
	if_stmt
	| while_stmt
	| for_stmt
	| funcdef
	| classdef

for_stmt:   
        "for" NAME[iter] set_itr_ptr "in" NAME check_name_is_range 
        "(" atom set_num_range_args_1 ")" 
        handle_loop_condition ":" { inLoop++; }
        suite {
            inLoop--;
            basecount--;
            fprintf (tac, "\tt%d = t%d + 1\n",basecount, basecount);
			fprintf (x86asm, "\t# t%d = t%d + 1\n",basecount, basecount);
			
        } loop_end_jump_back
         jump_target_false_lower {}
	|   "for" NAME[iter] set_itr_ptr "in" NAME check_name_is_range 
	    "(" atom "," atom set_num_range_args_2 ")" 
	    handle_loop_condition ":" { inLoop++; }
	    suite {
	        inLoop--;
	        basecount--;
	        fprintf (tac, "\tt%d = t%d + 1\n",basecount, basecount);
	    	fprintf (x86asm, "\t# t%d = t%d + 1\n",basecount, basecount);
	    
		} loop_end_jump_back jump_target_false_lower {}

set_itr_ptr : {
    //set for loop iterator node to current top of stack i.e. NAME[iter] in previous
	for_loop_iterator_node = $<node>0;
}

check_name_is_range : {
			if ($<node>0->production != "range") {
				dprintf (stderr_copy, "Error in loop statement at line %d: Expected iterator \"range\" in statement, received %s\n",
						(int)$<node>0->lineno, $<node>0->production.c_str());
				exit (64);
			}
		}
set_num_range_args_1 : {
        //range(n) equivalent to range(0, n)
		for_loop_range_first_arg = NULL;
		for_loop_range_second_arg = $<node>0; //i.e. atom in  for loop
		//note that atom can ALSO BE A NAME. 
		}
set_num_range_args_2 : {
        //range(a, b) case
		for_loop_range_first_arg = $<node>-1; //i.e. first atom
		for_loop_range_second_arg = $<node>0; //i.e. second atom
		// fprintf (tac, "\n\t%s = %s\n", for_loop_iterator_node->addr.c_str(), for_loop_range_first_arg->addr.c_str());
	}

handle_loop_condition : {
        //generate start of for loop
        #if TEMPDEBUG
        printf("starting for loop generation...\n");
        #endif
		if(!for_loop_range_first_arg) {
			fprintf(tac,"\tt%d = %s\n", basecount, "0");
			fprintf (x86asm, "\tmovq $0, -%ld(%%rbp)\n", top->get_rbp_offset("t" + to_string(basecount)));
		}
		else{
			fprintf(tac,"\tt%d = %s\n", basecount, for_loop_range_first_arg->addr.c_str());
			top->asm_load_value_r13 (for_loop_range_first_arg->addr);
			top->asm_store_value_r13 ("t" + to_string (basecount));
		}
		basecount++;
		string lbl = get_next_label_upper ("");
		fprintf (tac, "%s:\n", lbl.c_str());
		fprintf (x86asm, "%s:\n", lbl.c_str());
		string temp = "t"+to_string(basecount-1);
		fprintf(tac, "\t%s = %s\n", top->getaddr(for_loop_iterator_node).c_str(), temp.c_str());
		top->asm_load_value_r13 (top->getaddr(for_loop_iterator_node));
		top->asm_store_value_r13 (temp);

		fprintf (tac, "\t%s = %s + 1\n", for_loop_iterator_node->addr.c_str(), for_loop_iterator_node->addr.c_str());
		
		Node* test = $<node>-1;
		int begin = 0, end = 0;
		string loop_condition = newtemp();
		Node* dummy_test_condition_node = new Node (0);
		Node* dummy_test_condition_node2 = new Node (0);
		dummy_test_condition_node->addr = loop_condition;
		if (for_loop_range_first_arg) {
			gen (dummy_test_condition_node, for_loop_iterator_node, for_loop_range_first_arg, GTE);
			gen (dummy_test_condition_node2, for_loop_iterator_node, for_loop_range_second_arg, LT);
			gen (dummy_test_condition_node, dummy_test_condition_node, dummy_test_condition_node2, AND_log);
		} else {
			gen (dummy_test_condition_node, for_loop_iterator_node, for_loop_range_second_arg, LT);
		}

		// dummy_test_condition_node is the handle to the loop condition
		lbl = get_next_label("");
		fprintf (tac, "\tifFalse %s\tjmp %s\n", dev_helper(dummy_test_condition_node).c_str(), lbl.c_str());
		fprintf (x86asm, "\tcmpq $0, -%ld(%%rbp)\n", top->get_rbp_offset(dev_helper(dummy_test_condition_node)));
		fprintf (x86asm, "\tje %s\n", lbl.c_str());
	}


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
	sprintf (outputfile, "tac.txt");

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
			// cout << "input file: " << argv[i+1] << endl;
		}
		else if (strcmp(argv[i], "-output") == 0) { // outpur file name, default tac.txt
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
			printf ("This is a basic python compiler made by Dev*\nCommand-line options:\n\t-input:\t\tInput file (default - standart input console. Use Ctrl-D for EOF)\n\t-output:\tOutput file (default: tac.txt; overwritten if exists)\n\t-verbose:\tPrint debugging information to stderr\n\t-help:\t\tPrint this summary\nVerbosity flags: (no default value)\n%s", verbositym );
			return 0;
		}
	}
	if (verbosity == 0) {
		// inint stderr_dup;
		stderr_dup = dup (2);
		stderr_copy = 2;
	}

	static_section = "\t.text\n\t.section\t.rodata\n\n" ;
	static_section += "\t\ttrue_string:\t.asciz,\"True\"\n\t\tfalse_string:\t.asciz,\"False\"\n";
	concatenating_string_plus = "\0";
	
	tac = fopen (outputfile, "w+");
	x86asm = fopen ("output.s", "w+");
	if (x86asm == NULL) {
		fprintf (stderr, "Error opening file output.s\n");
		return 1;
	}


	// entry routine
	fprintf(x86asm,".data\n");
	fprintf(x86asm,"\t\tinteger_format: .asciz,\"%%ld\\n\"\n");
	fprintf (x86asm, "\t\tstring_format: .asciz,\"%%s\\n\"\n");
	fprintf(x86asm,".global main\n");
	fprintf(x86asm,".text\n");

	fprintf (x86asm, "\t#  beginning of user functions\n");

	stdump = fopen ("symbol_table.csv", "w+");
	if(stdump == NULL){
		fprintf(stderr, "Error opening file\n");
		exit(1);
	}
	fprintf (stdump, "LEXEME,TYPE,TOKEN,LINE,PARENT SCOPE,OFFSET (for identifiers),3AC LOCATION\n");
	if(yyparse()!=0){
		/* fprintf(stderr,"Error in parsing\n"); */
		return 1;
	}
	/* return 0; */
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
	/* globalSymTable->print_st(stdump); */
	fclose (stdump);
	if (static_section != "Static section:\n")
		fprintf (x86asm, "\n\n\n%s\n", static_section.c_str());
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


