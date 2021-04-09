// using namespace std;

class LoopInfo {

public:

  std::string condition = "";
  std::string init = "";
  std::string increment = "";
  std::string body = "";
  int size = 0;
  std::string iterator = "";
  std::vector<std::string> variables_used;
  std::vector<std::string> variables_declared;
  std::vector<std::string> functions_called;
  std::vector<std::string> structs_used;
  std::vector<std::string> event_stmts;
  bool is_while = false;
  bool iterator_decd_in_loop = false;

  std::string variables_used_str();
  std::string variables_declared_str();
  std::string functions_called_str();
  std::string structs_used_str();
  std::string structs_source_str(std::map<std::string, std::string>);
  std::string event_stmts_str();
  std::string to_str(std::map<std::string,std::string>);
  std::string source();
  std::string print_vector(std::vector<std::string>, std::string, std::string);
};

std::string LoopInfo::print_vector(std::vector<std::string> vec, std::string str, std::string sep) {
  if (vec.size() > 0) {
      std::vector<std::string>::iterator it = vec.begin();
      str += *it;
      for(it++; it != vec.end(); ++it) {
        str += sep + *it;
      }
  }
  return str+"\n";  
}

std::string LoopInfo::variables_used_str() {
  return print_vector(this->variables_used, "USED: ", ",");
}

std::string LoopInfo::variables_declared_str() {
  return print_vector(this->variables_declared, "DECLARED: ", ",");
}
  
std::string LoopInfo::functions_called_str() {
  return print_vector(this->functions_called, "FUNCTIONS: ", "$$");  
}
  
std::string LoopInfo::structs_used_str() {
  return print_vector(this->structs_used, "STRUCTS: ", ",");  
}
  
std::string LoopInfo::event_stmts_str() {
  return print_vector(this->event_stmts, "EVENTS: ", "$$");
}

std::string LoopInfo::structs_source_str(std::map<std::string, std::string> struct_table) {
  std::vector<std::string> vec;
  std::vector<std::string>::iterator it=this->structs_used.begin();
  for(; it != this->structs_used.end(); it++) {
    vec.push_back(struct_table[*it]);
  }
  return print_vector(vec, "", "$$$$$$$$$$$$$\n");
}
  
std::string LoopInfo::to_str(std::map<std::string,std::string> struct_table) {
  std::string src = this->source();
  std::string vars_used = this->variables_used_str();
  std::string vars_decd = this->variables_declared_str();
  std::string funcs_called = this->functions_called_str();
  std::string structs_used = this->structs_used_str();
  std::string structs_source = this->structs_source_str(struct_table);
  std::string events = this->event_stmts_str();
  std::string sep = "==============\n";
  std::string str = sep + src + sep + "\n" + vars_used + vars_decd + funcs_called + structs_used + events;
  str += "ITERATOR: " + this->iterator + "\n";
  str += "SIZE: " + std::to_string(this->size) + "\n";
  str += "LOOP DEC: " + std::to_string(this->iterator_decd_in_loop) + "\n";  
  str += sep;
  str += structs_source + sep;
  return str;
}
  
std::string LoopInfo::source() {
  if (this->is_while) {
    return "while("+condition+")"+body+"\n";      
  }
  return "for("+init+condition+increment+")"+body+"\n";
}
