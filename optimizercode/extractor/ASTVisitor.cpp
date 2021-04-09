#include "ASTVisitor.hpp"
#include "LoopInfo.cpp"
#include <stack>

namespace Sif {

  static bool in_loop = false;
  static bool in_loop_body = false;
  static bool in_loopinit = false;  
  static std::vector<ASTNode*> seen_loops;
  static int num_lines = 0;

  static std::vector<LoopInfo> all_loops;
  static std::vector<ASTNode*> visited_loops;
  static std::stack<LoopInfo*> current_loops;
  static Indentation empty(0);
  static std::vector<ASTNode*> visited;
  static bool in_header = false;
  static std::map<std::string, ASTNode*> type_table;
  static bool uses_safemath = false;
  static std::map<std::string, std::string> struct_table;
  static std::vector<std::string> events;
  
  std::string function_call_source_code(FunctionCallNode* fn, LoopInfo* loop) {
    std::string fname = fn->get_callee()->source_code(empty);
    std::string result = fname + "(";
    for (int i = 0; i < fn->num_arguments(); i++ ) {
      result += fn->get_argument(i)->source_code(empty);
      if (i != fn->num_arguments()-1) {
	result += ", ";
      }
    }
    result += ")";
    if (std::count(events.begin(), events.end(), fname) != 0) {
      (loop->event_stmts).push_back(result+";");
      (loop->size)--;
    } else {
      (loop->functions_called).push_back(result);
    }
    return result;
  }

  
  LoopInfo for_source_code(ForStatementNode* fs) {
    // Fetch current loop
    LoopInfo* loop = current_loops.top();

    // Cache loop size pre-header and set header flag for visit
    int prev_loop_size = loop->size;
    in_header = true;
    
    // Build loop initialization string
    if (fs->get_init() != nullptr) {
      loop->init = fs->get_init()->source_code(empty) + " ";
    } else {
      loop->init = "; ";
    }
      
    // Build loop condition string
    
    if (fs->get_condition() != nullptr) {
      loop->condition = fs->get_condition()->source_code(empty) + "; ";
    } else {
      loop->condition = "; ";
    }
    
    // Build loop increment string
    std::string increment_str = "";
    if (fs->get_increment() != nullptr) {
      increment_str = fs->get_increment()->source_code(empty);
      size_t increment_str_len = increment_str.length();
      // Remove semicolon, newline, and space
      for (int i = increment_str.length() - 1; i >= 0; --i) {
  	char ch = increment_str[i];
  	if (ch == ' ' || ch == '\n') {
  	  --increment_str_len;
  	} else if (ch == ';') {
  	  --increment_str_len;
  	  break;
  	} else {
  	  break;
  	}
      }
      increment_str = increment_str.substr(0, increment_str_len);
      loop->increment = increment_str;
    }

    // Reset loop size so that header stuff isn't added, and unset header flag
    loop->size = prev_loop_size;
    in_header = false;

    // Fetch loop body source
    loop->body = fs->get_body()->source_code(empty) + "\n";

    return *loop;
  }

  void while_source_code(WhileStatementNode* ws) {
    // Fetch current loop
    LoopInfo* loop = current_loops.top();

    // Set loop as while
    loop->is_while = true;
    
    int prev_loop_size = loop->size;

    // Fetch loop condition
    loop->condition = ws->get_condition()->source_code(empty);

    // Reset loop size so that header stuff isn't added
    loop->size = prev_loop_size;

    // Fetch loop body source
    loop->body = ws->get_loop_body()->source_code(empty);    
  }
  

  void before(std::string arg) {
    return;
  }

  void incrementLoopSize(ASTNode* node) {
    if (current_loops.size() > 0) {
      if (node->get_node_type() == NodeTypePlaceholderStatement ||
      	  node->get_node_type() == NodeTypeIfStatement ||
      	  node->get_node_type() == NodeTypeDoWhileStatement ||
      	  node->get_node_type() == NodeTypeWhileStatement ||
      	  node->get_node_type() == NodeTypeForStatement ||
      	  node->get_node_type() == NodeTypeEmitStatement ||
      	  node->get_node_type() == NodeTypeVariableDeclarationStatement ||
      	  node->get_node_type() == NodeTypeExpressionStatement) {
	((current_loops.top())->size)++;
      }
    }
  }

  void fetch_struct_types(ASTNode* node, LoopInfo* loop) {
    // Fetch possible structs. Note, this could be other contracts as well
    if (node->get_node_type() == NodeTypeUserDefinedTypeName) {
      loop->structs_used.push_back(node->source_code(empty));
    }
    // Recursively fetch possible structs used in mappings
    if (node->get_node_type() == NodeTypeMapping) {
      fetch_struct_types((((MappingNode*) node)->get_key_type()).get(), loop);
      fetch_struct_types((((MappingNode*) node)->get_value_type()).get(), loop);      
    }
    // Recursively fetch types in arrays
    if (node->get_node_type() == NodeTypeArrayTypeName) {
      fetch_struct_types((((ArrayTypeNameNode*) node)->get_base_type()).get(), loop);
    }
    
  }

  void concatenate_vectors(std::vector<std::string> v1, std::vector<std::string>* v2) {
      std::vector<std::string>::iterator it = v1.begin();
      for(; it != v1.end(); ++it) {
	v2->push_back(*it);
      }
  }
  
  void process_loop(ASTNode*node, bool is_while) {
    // Add loop to set of visited loops
    visited_loops.push_back(node);      

    // Build new loop, and add to both current loops
    LoopInfo loop;
    current_loops.push(&loop);

    // Fetch and set loop source code
    if (is_while) {
      WhileStatementNode* ws = (WhileStatementNode*) node;
      while_source_code(ws);
    } else {
      ForStatementNode* fs = (ForStatementNode*) node;
      for_source_code(fs);
    }
    
    // Remove loop from current set and add to history of all loops
    current_loops.pop();
    all_loops.push_back(loop);

    // Update outer loop's fields accordingly if this loop was nested
    if (current_loops.size() > 0) {
      // Update size
      current_loops.top()->size += loop.size;
      // Update vectors
      concatenate_vectors(loop.variables_used, &current_loops.top()->variables_used);
      concatenate_vectors(loop.variables_declared, &current_loops.top()->variables_declared);
      concatenate_vectors(loop.functions_called, &current_loops.top()->functions_called);
      concatenate_vectors(loop.structs_used, &current_loops.top()->structs_used);
      concatenate_vectors(loop.event_stmts, &current_loops.top()->event_stmts);
    }
  }
  
  void visit(ASTNode* node) {
    // Only visit previously unvisited nodes
    if (std::count(visited.begin(), visited.end(), node) != 0) {
      return;
    }
    // Add node to visited
    visited.push_back(node);

    // Increment loop size as necessary
    incrementLoopSize(node);

    // Process For loop
    if (node->get_node_type() == NodeTypeForStatement &&
    	std::count(visited_loops.begin(), visited_loops.end(), node) == 0) {
      process_loop(node, false);
    }

    // Process While loop
    if (node->get_node_type() == NodeTypeWhileStatement &&
    	std::count(seen_loops.begin(), seen_loops.end(), node) == 0) {
      process_loop(node, true);
    }

    // Record struct source
    if (node->get_node_type() == NodeTypeStructDefinition) {
      std::string name = ((StructDefinitionNode*) node)->get_name();
      std::string source = ((StructDefinitionNode*) node)->source_code(empty);

      struct_table[name] = source;
    }
    
    // Record variable types (technically, this could be wonky with scoping)
    if (node->get_node_type() == NodeTypeVariableDeclaration) {
      // Fetch variable name
      std::string var_name = ((VariableDeclarationNode*) node)->get_variable_name();      
      // Fetch variable type
      ASTNode* var_type = (((VariableDeclarationNode*) node)->get_type()).get();
      type_table[var_name] = var_type;
    }

    if (node->get_node_type() == NodeTypeUsingForDirective) {
      // Fetch lib being used
      std::string lib = ((UsingForDirectiveNode*) node)->get_using();

      if (lib == "SafeMath") {
    	uses_safemath = true;
      }
    }

    // Keep track of Event definitions so we now when a function call is an event
    if (node->get_node_type() == NodeTypeEventDefinition) {
      events.push_back(((EventDefinitionNode*) node)->get_name());
    }
    
    // The rest of the actions should only occur when in a loop,
    //   so return if not in a loop
    if (current_loops.size() == 0) return;
    
    // Fetch current loop
    LoopInfo* loop = current_loops.top();
    
    // Process variable declarations in loop
    if (node->get_node_type() == NodeTypeVariableDeclaration) {
      // Fetch variable name
      std::string var_name = ((VariableDeclarationNode*) node)->get_variable_name();
      // Fetch variable type
      ASTNode* var_type = (((VariableDeclarationNode*) node)->get_type()).get();
      // Add to type table
      type_table[var_name] = var_type;
      
      // If we declare a var in header, we assume this is the loop iterator
      if (in_header) {
    	loop->iterator_decd_in_loop = true;
    	loop->iterator = var_name;
      } else {
    	(loop->variables_declared).push_back(var_name);
      }
    }

    // Fetch loop iterator if not already found in a declaration
    if (node->get_node_type() == NodeTypeAssignment && in_header && loop->iterator == "") {
      // Fetch variable name
      std::string var_name = ((AssignmentNode *) node)->get_left_hand_operand()->source_code(empty);
      loop->iterator = var_name;
    }

    // Fetch all used variables
    if (node->get_node_type() == NodeTypeIdentifier) {
      std::string var_name = ((IdentifierNode*) node)->get_name();

      // ignore any non-declared variable (could be function call name, constructor name,
      //   or even "this"
      if (type_table.find(var_name) == type_table.end()) {
    	return;
      }
      
      ASTNode* type = type_table[var_name];
      std::string var_type = type->source_code(empty);

      // Replace bytes with integer array
      if (var_type == "bytes") {
      	var_type = "uint[]";
      }
      
      std::string tuple = var_name+":"+var_type;

      fetch_struct_types(type, loop); 
      
      if(std::count(loop->variables_used.begin(), loop->variables_used.end(), tuple) == 0
      	 && var_type != "") {
      	loop->variables_used.push_back(tuple);
      }
    }

    // Fetch all function calls
    if (node->get_node_type() == NodeTypeFunctionCall) {
      // Fetch and add function name
      std::string func_call = function_call_source_code(((FunctionCallNode*) node), loop);
    }

    // Fetch all emit statements
    if (node->get_node_type() == NodeTypeEmitStatement) {
      std::string event_stmt = ((EmitStatementNode*) node)->source_code(empty);
      (loop->event_stmts).push_back(event_stmt);
    }
    
    return;
  }
  
  void after() {
    std::vector<LoopInfo>::iterator it;
    for(it = all_loops.begin(); it != all_loops.end(); ++it) {
      std::cout << (*it).to_str(struct_table);
      std::cout << "****************\n";
    }

    std::cout << "\nUSES SAFEMATH: " << std::to_string(uses_safemath) << "\n";
    
    return;
  }

}
