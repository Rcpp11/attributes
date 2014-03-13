#define USE_RINTERNALS
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <string>
#include <vector>
#include <algorithm>
#include <fstream>
#include <sstream>

static const char * const kWhitespaceChars = " \f\n\r\t\v" ;

// Trim a string

void trimWhitespace(std::string& s) {   
    
    // skip empty case
    if (s.empty())
        return;
    
    // trim right                  
    std::string::size_type pos = s.find_last_not_of(kWhitespaceChars);
    if (pos != std::string::npos)
        s.erase(pos + 1);    
        
    // trim left
    pos = s.find_first_not_of(kWhitespaceChars);
    s.erase(0, pos);
}

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

SEXP parse_arguments( const std::string& args ){
    std::vector<std::string> arguments ;
    
    int templateCount = 0 ;
    int parenCount = 0;
    bool insideQuotes = false ;
    std::string currentArg;
        
    char prevChar = 0 ;
    for( std::string::const_iterator it = args.begin(); it != args.end(); ++it ){
        char ch = *it ;
        if( ch == '"' && prevChar != '\\' ) {
            insideQuotes = !insideQuotes;
        }
        
        if( ch == ',' && !templateCount && !parenCount && !insideQuotes ){
            arguments.push_back(currentArg) ;
            currentArg.clear() ;
        } else {
            currentArg.push_back(ch);
            switch(ch) {
                case '<':
                    templateCount++;
                    break;
                case '>':
                    templateCount--;
                    break;
                case '(':
                    parenCount++;
                    break;
                case ')':
                    parenCount--;
                    break;
            }
        }
        
        prevChar = ch;
    }  
    
    if (!currentArg.empty() && currentArg != "void" ){
        arguments.push_back(currentArg);
    }
    
    int n = arguments.size() ;
    SEXP names = PROTECT(Rf_allocVector(STRSXP, n) ) ;
    SEXP res = PROTECT(Rf_allocVector( VECSXP, n) ) ;
    SEXP param_name = PROTECT(Rf_allocVector(STRSXP, 2)) ;
    SET_NAMED(param_name, 2) ;
    SET_STRING_ELT(param_name, 0, Rf_mkChar("type")); 
    SET_STRING_ELT(param_name, 1, Rf_mkChar("default")); 
    
    for( int i=0; i<n; i++){
        std::string arg = arguments[i] ;
        std::string::size_type start = arg.find_first_not_of( kWhitespaceChars ) ;
        std::string::size_type end   = arg.find_last_not_of( kWhitespaceChars ) ;
        
        // find default value (if any). 
        std::string::size_type eqPos = arg.find_first_of( '=', start ) ;
        SEXP current = PROTECT(Rf_allocVector(STRSXP, 3)) ;
        
        if( eqPos != std::string::npos ){
            std::string::size_type default_start = arg.find_first_not_of( kWhitespaceChars, eqPos + 1 ) ;
            SET_STRING_ELT( current, 1, Rf_mkCharLen( arg.data() + default_start , end - default_start + 1 ) ) ;
            arg.erase( eqPos ) ;
        } else {
            SET_STRING_ELT( current, 1, NA_STRING ) ;    
        }
        
        // only keep (trimmed) part before the '='
        arg.erase( 0, start ) ;
        end = arg.find_last_not_of( kWhitespaceChars );
        if( end != std::string::npos ){
            arg.erase( end + 1) ;    
        }
        
        // where does the type end
        end = arg.find_last_of( kWhitespaceChars ) ;
        
        // name
        SET_STRING_ELT(names, i, Rf_mkCharLen(arg.data() + end + 1, arg.size() - end - 1 ) ) ;
        SET_STRING_ELT(current, 2, STRING_ELT(names, i) ) ;
        
        // type
        SET_STRING_ELT(current, 0, Rf_mkCharLen(arg.data(), end ) ) ;
        
        Rf_setAttrib(current, R_NamesSymbol, param_name ) ;
        SET_VECTOR_ELT(res, i, current) ;
        UNPROTECT(1) ; // current
    }
    Rf_setAttrib( res, R_NamesSymbol, names );
    UNPROTECT(3) ; // res, names, param_name
    return res ;
}

extern "C" {
  
  // [[register]]
  SEXP parse_cpp_function( SEXP txt, SEXP line ){
    
    int pos = INTEGER(line)[0] ;
    std::string signature = get_function_signature( txt, pos ) ;
    
    // find last ')' and first '('
    std::string::size_type endParenLoc = signature.find_last_of(')');
    std::string::size_type beginParenLoc = signature.find_first_of('(');
        
    // find name of the function and return type
    std::string preamble = signature.substr(0, beginParenLoc) ; 
    std::string::size_type sep = preamble.find_last_of( kWhitespaceChars ) ;
    std::string name = preamble.substr( sep + 1); 
    std::string return_type = preamble.substr( 0, sep) ;
    
    std::string args = signature.substr( beginParenLoc + 1, endParenLoc-beginParenLoc-1 ) ;
    trimWhitespace(args) ;    
    
    SEXP res   = PROTECT( Rf_allocVector( VECSXP, 3 ) );
    SEXP names = PROTECT( Rf_allocVector( STRSXP, 3 ) );
    
    SET_VECTOR_ELT(res, 0, Rf_mkString(name.c_str())) ; 
    SET_STRING_ELT(names, 0, Rf_mkChar("name") ) ;
    
    SET_VECTOR_ELT(res, 1, Rf_mkString(return_type.c_str())) ; 
    SET_STRING_ELT(names, 1, Rf_mkChar("return_type") ) ;    
    
    SET_VECTOR_ELT(res, 2, parse_arguments(args) ) ; 
    SET_STRING_ELT(names, 2, Rf_mkChar("arguments") ) ;    
    
    
    Rf_setAttrib( res, R_NamesSymbol, names ) ; 
    UNPROTECT(2) ;
    return res  ;
  }

  // [[register]]
  SEXP get_cdr(SEXP x){
    return CDR(x) ;
  }
  
}

