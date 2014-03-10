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
    
    // get everything before the first '{'
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
    
    // find last ')' and first '('
    // std::string::size_type endParenLoc = signature.find_last_of(')');
    std::string::size_type beginParenLoc = signature.find_first_of('(');
        
    // find name of the function and return type
    std::string preamble = signature.substr(0, beginParenLoc) ; 
    
    std::string::size_type sep = preamble.find_last_of( " \f\n\r\t\v" ) ;
    std::string name = preamble.substr( sep + 1); 
    std::string return_type = preamble.substr( 0, sep) ;
    
    
    SEXP res   = PROTECT( Rf_allocVector( VECSXP, 2 ) );
    SEXP names = PROTECT( Rf_allocVector( STRSXP, 2 ) );
    
    SET_VECTOR_ELT(res, 0, Rf_mkString(name.c_str())) ; 
    SET_STRING_ELT(names, 0, Rf_mkChar("name") ) ;
    
    SET_VECTOR_ELT(res, 1, Rf_mkString(return_type.c_str())) ; 
    SET_STRING_ELT(names, 1, Rf_mkChar("return_type") ) ;
    
    Rf_setAttrib( res, R_NamesSymbol, names ) ; 
    UNPROTECT(2) ;
    return res  ;
}

