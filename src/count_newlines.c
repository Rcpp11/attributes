#include <R.h>
#include <Rinternals.h>

// [[register]]
SEXP count_newlines(SEXP x_, SEXP start_, SEXP end_) {
  const char* x = CHAR( STRING_ELT(x_, 0) );
  int start = INTEGER(start_)[0] - 1; // R to C indexing
  int end = INTEGER(end_)[0] - 1; // R to C indexing
  int count = 0;
  for (int i=start; i <= end; ++i) {
    if (x[i] == '\0') return ScalarInteger(count);
    if (x[i] == '\n') ++count;
  }
  return ScalarInteger(count);
}
