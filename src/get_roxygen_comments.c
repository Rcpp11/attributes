#include <R.h>
#include <Rinternals.h>

int cfind_prev_char(const char chr, const char* txt, int index);

int is_roxygen(const char* x, int index) {
  int i = index;
  char curr;
  while (1) {
    curr = x[i];
    if (x[i] == '\0') return 0;
    if (x[i] == ' ' || x[i] == '\t') {
      ++i;
      continue;
    }
    if (x[i] == '/' && x[i+1] == '/' && x[i+2] == '\'') {
      return 1;
    }
    return 0;
  }
}

// [[register]]
SEXP get_roxygen_index(SEXP text_, SEXP index_) {
  
  int index = INTEGER(index_)[0] - 1;
  int i = index;
  const char* text = CHAR( STRING_ELT(text_, 0) );
  
  // skip over the first newline
  int idx = cfind_prev_char('\n', text, i);
  if (idx < 0) return R_NilValue;
  
  idx = cfind_prev_char('\n', text, idx);
  if (idx < 0) return R_NilValue;
  
  // make sure we find at least one
  if (!is_roxygen(text, idx + 1)) {
    return R_NilValue;
  }
  
  while (1) {
    idx = cfind_prev_char('\n', text, idx);
    
    if (idx < 0) {
      return ScalarInteger(1);
    }
    
    if (is_roxygen(text, idx + 1)) {
      continue;
    }
    break;
  }
  
  return ScalarInteger(idx + 3);
  
}
