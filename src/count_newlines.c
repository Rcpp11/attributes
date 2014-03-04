#include <R.h>
#include <Rinternals.h>

// [[register]]
SEXP count_newlines(SEXP x_, SEXP n_) {
  const char* x = CHAR( STRING_ELT(x_, 0) );
  int n = INTEGER(n_)[0];
  int count = 0;
  for (int i=0; i < n; ++i) {
    if (x[i] == '\n') ++count;
  }
  return ScalarInteger(count);
}
