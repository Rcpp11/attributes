#include <R.h>
#include <Rinternals.h>

#include <vector>
#include <string>

extern "C" {
  
// [[register]]
SEXP parse_args(SEXP x_) {
  
  std::string x( CHAR( STRING_ELT(x_, 0) ) );
  std::vector<std::string> args;
  std::vector<std::string> types;
  
  // keep three indices: start, split, and end.
  // start to split: type
  // split to end: name
  int start = 0;
  int split = 0;
  int end = 0;
  
  int n = x.length();
  
  // we have to keep track of whether we're in a template
  int balance = 0;
  
  while (end < n) {
    
    char curr = x[end];
    
    // check template balance
    if (curr == '<') ++balance;
    if (curr == '>') --balance;
    if (balance < 0) error("malformed arguments");
    
    // if we find a space, it separates the type and the argument
    if (balance == 0 && curr == ' ') split = end;
    if (balance == 0 && curr == ',') {
      
      types.push_back( x.substr(start, split - start) );
      args .push_back( x.substr(split + 1, end - split - 1) );
      
      start = end + 2;
      split = end + 2;
      
    }
    
    ++end;
    
  }
  
  // if we reached the end, with no comma, we have found the last args
  types.push_back( x.substr(start, split - start) );
  args .push_back( x.substr(split + 1, end - split - 1) );
  
  // Generate an R list to hold the results
  int nargs = args.size();
  int ntypes = types.size();
  
  SEXP result = PROTECT( allocVector(VECSXP, 2) );
  SEXP Rtypes = PROTECT( allocVector(STRSXP, ntypes) );
  for (int i=0; i < ntypes; ++i) {
    SET_STRING_ELT(Rtypes, i, mkChar(types[i].c_str()));
  }
  
  SEXP Rargs = PROTECT( allocVector(STRSXP, nargs) );
  for (int i=0; i < nargs; ++i) {
    SET_STRING_ELT(Rargs, i, mkChar(args[i].c_str()));
  }
  
  SET_VECTOR_ELT(result, 0, Rtypes);
  SET_VECTOR_ELT(result, 1, Rargs);
  
  UNPROTECT(3);
  return result;
  
}  

} // extern "C"

