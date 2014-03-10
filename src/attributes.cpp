#define USE_RINTERNALS
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <string>
#include <algorithm>
#include <fstream>
#include <sstream>

std::string get_function_signature( SEXP txt, int pos ){
  std::string current_line = CHAR(STRING_ELT(txt, pos)) ;
  
  // skip comments
  while( current_line[0] == '/' ){
    current_line = CHAR(STRING_ELT(txt, ++pos)) ;
  }
  
  std::stringstream res ; 
  while( true ){
    int brace_pos = current_line.find('{') ;
    if( brace_pos == std::string::npos ){
      res << current_line << ' ' ;
      current_line = CHAR(STRING_ELT(txt, ++pos)) ;
    } else {
      res << current_line.substr(0, brace_pos) ;
      break ;
    }
    
  }
  
  return res.str() ;
  
}


extern "C" SEXP parse_cpp_function( SEXP txt, SEXP line ){
  int pos = INTEGER(line)[0] ;
  std::string signature = get_function_signature( txt, pos ) ;
  
  SEXP res = PROTECT(Rf_allocVector(STRSXP, 1)) ;
  STRING_ELT(res,0) = Rf_mkChar( signature.c_str() ); 
  UNPROTECT(1) ;
  
  return res ;
}

