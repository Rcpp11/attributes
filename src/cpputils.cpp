#define debug(x)

#include <R.h>
#include <Rinternals.h>

#include <vector>
#include <string>

extern "C" {
  
int cfind_next_char(const char chr, const char* txt, int ind, int n);
  
// [[register]]
SEXP parse_cpp_args(SEXP x_) {
  
  debug( Rf_PrintValue(x_) );
  
  std::string x( CHAR( STRING_ELT(x_, 0) ) );
  std::vector<std::string> args;
  std::vector<std::string> types;
  
  // keep three indices: start, split, and end.
  // start to split: type
  // split to end: name
  int start = 0;
  
  int itr = 0;
  
  int n = x.length();
  
  int templateCount = 0;
  int parenCount = 0;
  bool insideQuotes = false;
  bool foundType = false;
  
  // we iterate end through the string
  while (itr < n) {
    
    debug( Rprintf("itr == %i\n", itr) );
    char curr = x[itr];
    char last = x[itr - 1];
    
    if (curr == '"' and last == '\\') {
      insideQuotes = !insideQuotes;
    }
    
    switch (curr) {
      case '<': {
        ++templateCount;
        break;
      }
      case '>': {
        --templateCount;
        break;
      }
      case '(': {
        ++parenCount;
        break;
      }
      case ')': {
        --parenCount;
        break;
      }
    }
    
    // this block handles the 'type' finding for part of a function signature
    if (!templateCount and !parenCount and !insideQuotes and !foundType and curr == ' ') {
      debug( Rprintf("Adding type: %s\n", x.substr(start, itr - start).c_str()) );
      types.push_back( x.substr(start, itr - start) );
      start = itr + 1;
      foundType = true;
    }
    
    // this block handles the 'argument' finding for part a function signature
    if (foundType) {
      
      if (curr == ',' or curr == '=') { // comma separates argument list
        debug( Rprintf("Adding arg: %s\n", x.substr(start, itr - start).c_str()) );
        args.push_back( x.substr(start, itr - start) );
        
        if (curr == '=') {
          itr = cfind_next_char(',', x.c_str(), itr + 1, n);
        }
        
        itr = cfind_next_char(' ', x.c_str(), itr, n);
        
        // bail if we've reached the end
        if (itr > n) {
          break;
        }
        
        start = itr + 1;
        foundType = false;
        
      }
      
    }
    
    ++itr;
    
  }
  
  // Add the final argument -- but guard against argument-less functions
  if (itr - start > 0) {
    args.push_back( x.substr(start, itr - start) );
  }
  
  
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

