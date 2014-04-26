#include <R.h>
#include <Rinternals.h>

int cfind_next_char(const char chr, const char* txt, int ind, int n) {
  int i = ind; // we do allow matching of the current character
  while (i < n) {
    if (txt[i] == chr) return i;
    ++i;
  }
  return i;
}

// [[register]]
SEXP find_next_char(SEXP chr_, SEXP txt_, SEXP ind_) {
  
  const char chr = CHAR( STRING_ELT(chr_, 0) )[0];
  const char* txt = CHAR( STRING_ELT(txt_, 0) );
  int ind = INTEGER(ind_)[0] - 1; // R to C style indexing
  
  int n = strlen(txt);
  
  if (ind < 0 || ind > n-1)
    error("Invalid index: valid indices are [%i, %i] but index was %i",
      0, n-1, ind);
    
  int idx = cfind_next_char(chr, txt, ind, n);
  if (idx >= n) {
    error("Could not find character '%c'\n", chr);
  }
  return ScalarInteger(idx + 1);
  
}

int cfind_prev_char(const char chr, const char* txt, int ind) {
  int i = ind - 1; // we don't match the current character
  while (i >= 0) {
    if (txt[i] == chr) return i;
    --i;
  }
  return i;
}

// [[register]]
SEXP find_prev_char(SEXP chr_, SEXP txt_, SEXP ind_) {
  
  const char  chr = CHAR( STRING_ELT(chr_, 0) )[0];
  const char* txt = CHAR( STRING_ELT(txt_, 0) );
  int ind = INTEGER(ind_)[0] - 1; // R to C style indexing
  
  int idx = cfind_prev_char(chr, txt, ind);
  if (idx == -1) {
    error("Could not find character '%c'", chr);
  }
  return ScalarInteger(idx + 1);
}

// [[register]]
SEXP find_matching_char__fwd(SEXP chr_, SEXP cmp_, SEXP txt_, SEXP ind_) {
  
  const char  chr = CHAR( STRING_ELT(chr_, 0) )[0];
  const char  cmp = CHAR( STRING_ELT(cmp_, 0) )[0];
  const char* txt = CHAR( STRING_ELT(txt_, 0) );
  int ind = INTEGER(ind_)[0] - 1; // R to C style indexing
  
  int balance = 1;
  int n = strlen(txt);
  int i = ind + 1;
  while (i < n) {
    if (txt[i] == chr) ++balance;
    if (txt[i] == cmp) --balance;
    if (balance == 0) break;
    ++i;
  }
  if (i >= n) {
    error("could not find a matching character for '%c' (was searching for '%c')",
      chr, cmp);
  }
  return ScalarInteger(i + 1);
  
}

// [[register]]
SEXP find_matching_char__bwd(SEXP chr_, SEXP cmp_, SEXP txt_, SEXP ind_) {
  
  const char  chr = CHAR( STRING_ELT(chr_, 0) )[0];
  const char  cmp = CHAR( STRING_ELT(cmp_, 0) )[0];
  const char* txt = CHAR( STRING_ELT(txt_, 0) );
  int ind = INTEGER(ind_)[0] - 1; // R to C style indexing
  
  int balance = 1;
  int i = ind - 1;
  while (i >= 0) {
    if (txt[i] == chr) ++balance;
    if (txt[i] == cmp) --balance;
    if (balance == 0) break;
    --i;
  }
  if (i < 0) {
    error("could not find a matching character for '%c' (was searching for '%c')",
      chr, cmp);
  }
  return ScalarInteger(i + 1);
  
}
