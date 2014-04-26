#define debug(x)

#define R_NO_REMAP

#include <R.h>
#include <Rinternals.h>

#include <vector>
#include <string>

namespace {

size_t skip_whitespace_fwd(std::string const& x, size_t itr) { 
  debug(Rprintf("Skipping whitespace forwards from index %i\n", itr));
  while (x[itr] == ' ') {
    ++itr;
  } 
  debug(Rprintf("Skipped to index %i\n", itr));
  return itr;
}

size_t skip_whitespace_bwd(std::string const& x, size_t itr) {
  debug(Rprintf("Skipping whitespace backwards from index %i\n", itr));
  while (x[itr] == ' ') {
    --itr;
  }
  debug(Rprintf("Skipped to index %i\n", itr));
  return itr;
}

// Values used to hold state
struct State {
  
  State():
    inString(false),
    parenCount(0),
    templateCount(0),
    braceCount(0) {}

  bool inString;
  int parenCount;
  int templateCount;
  int braceCount;

  void reset() {
    inString = false;
    parenCount = 0;
    templateCount = 0;
    braceCount = 0;
  }

  bool good() {
    return !inString && !parenCount && !templateCount && !braceCount;
  }

  void update(std::string const& x, size_t itr) {
    
    // Check if we are entering, or leaving, a string
    if (x[itr] == '"') {
      if (!inString) {
        debug(Rprintf("Inside string at index %i\n", itr));
        inString = true;
      } else if (x[itr - 1] != '\\') {
        debug(Rprintf("Leaving string at index %i\n", itr));
        inString = false;
      }
    }

    // Check if we are modifying one of the state counts
    switch (x[itr]) {
    case '<': {
      ++templateCount;
      debug(Rprintf("Incrementing template count (%i)\n", templateCount));
      break;
    }
    case '>': {
      --templateCount;
      debug(Rprintf("Decrementing template count (%i)\n", templateCount));
      break;
    }
    case '{': {
      ++braceCount;
      debug(Rprintf("Incrementing brace count (%i)\n", braceCount));
      break;
    }
    case '}': {
      --braceCount;
      debug(Rprintf("Decrementing brace count (%i)\n", braceCount));
      break;
    }
    case '(': {
      ++parenCount;
      debug(Rprintf("Incrementing paren count (%i)\n", parenCount));
      break;
    }
    case ')': {
      --parenCount;
      debug(Rprintf("Decrementing paren count (%i)\n", parenCount));
      break;
    }
    }
    
  }

};

// Finds the start of an argument name, given a string and an iterator
// pointing to the end of an argument name
// E.g.:
// std::string const& x , const std::string y = "foo"
//                    ^                     ^
size_t find_name_start(std::string const& x, size_t itr) {
  debug(Rprintf("Starting start name search at %i\n", itr));
  size_t result = x.rfind(" ", itr);
  debug(Rprintf("Found start of name at index %i (character %c)\n", result, x[result]));
  if (result == std::string::npos) {
    debug(Rprintf("Failed to find start of argument name!\n"));
    return x.size() - 1;
  }
  return result + 1;
}

// Finds a character ending the argument name in a function specification
// E.g.:
// std::string const& x  , const std::string y = "foo"
//                     ^                    ^
size_t find_delimiter(std::string const& x, size_t itr, State* state) {

  int n = x.size();
  while (itr < n) {

    state->update(x, itr);

    // If we find a '=' or a ',' and the state is 'good', then we've found the
    // delimiter for arguments / types
    if (state->good() && (x[itr] == ',' or x[itr] == '=')) {
      debug(Rprintf("Found type/name delimiting character '%c' at index %i\n", x[itr], itr));
      return itr;
    }

    ++itr;
    
  }

  debug(Rprintf("Found name end at end of line\n"));
  return itr;
  
}

size_t find_name_end(std::string const& x, size_t itr) {
  if (x[itr - 1] == ' ') {
    debug(Rprintf("Moving backwards over whitespace\n"));
    return skip_whitespace_bwd(x, itr - 1) + 1;
  } else {
    debug(Rprintf("No whitespace preceding; returning index as-is\n"));
    return itr;
  }
  itr = skip_whitespace_bwd(x, itr - 1);
  debug(Rprintf("Found name end at %i (preceding character is '%c')\n", itr + 1, x[itr]));
  return itr;
 
}

// Add the substring of x from start to end to container
void add_to(std::vector<std::string>& container, std::string const& x, size_t start, size_t end) {
  debug(
    if (end < start) {
      REprintf("Error: end < start in 'add_to' call!\n");
    }
  )
    std::string substr = x.substr(start, end - start);
  debug(Rprintf("Adding substring %s [%i, %i]\n", substr.c_str(), start, end));
  container.push_back(substr);
}

// Find the location of the next start
// We have to handle the case where the iterator landed at an '='
size_t find_next_start(std::string const& x, size_t itr) {

  debug(Rprintf("Finding next start from a '%c'\n", x[itr]));

  int nextDelim = x.find_first_of("=,", itr);
  if (nextDelim == std::string::npos) {
    debug(Rprintf("Could not find a new location to start\n"));
    return x.size();
  }
  
  if (x[nextDelim] == '=') {
    debug(Rprintf("Found character '='; skipping to next ',' (starting search from %i)\n", itr));
    // Find the next ','
    State state;
    while (true) {
      ++itr;
      if (itr >= x.size()) return x.size();
      state.update(x, itr);
      if (state.good() && x[itr] == ',') {
        debug(Rprintf("Found a ',' at index %i\n", itr));
        itr = skip_whitespace_fwd(x, itr + 1);
        debug(Rprintf("Skipped over whitespace to new start at index %i\n", itr));
        return itr;
      }
      
    }
    
  } else if (x[nextDelim] == ',') {
    debug(Rprintf("Found character ',', skipping over whitespace\n"));
    itr = itr + 1;
    while (x[itr] == ' ') ++itr;
    return itr;
  } else {
    return x.size();
  }
  
}

} // end anonymous namespace

extern "C" {

  // [[register]]
  SEXP parse_cpp_args(SEXP x_) {
  
    std::string x( CHAR( STRING_ELT(x_, 0) ) );
    std::vector<std::string> names;
    std::vector<std::string> types;
    State state;
  
    debug(Rprintf("Trying to parse string '%s'\n", x.c_str()));
  
    // We have to keep track of a few locations in order to parse the function
    // declaration -- e.g. for 'const std::vector<int> x = {1, 2, 3}', we need:
    // 1. The start and end of the type,
    // 2. The start and end of the argument name
  
    // The main iterator looking through the string
    size_t itr = 0;
  
    // Other iterators that will hold position
    size_t type_end   = 0;
    size_t name_start = 0;
    size_t name_end   = 0;
  
    // Skip over initial whitespace
    itr = skip_whitespace_fwd(x, itr);
    size_t type_start = itr;

    size_t n = x.size();
  
    while (itr < n) {

      itr = find_delimiter(x, itr, &state);

      name_end = find_name_end(x, itr);
      debug(Rprintf("Found name end at index %i\n", name_end)); 
      debug(Rprintf("Setting name_end at %i (character '%c')\n", name_end, x[name_end]));
    
      name_start = find_name_start(x, name_end - 1);
      debug(Rprintf("Setting name_start at %i\n", name_start));

      type_end = skip_whitespace_bwd(x, name_start - 1) + 1;
      debug(Rprintf("Setting type_end at %i\n", type_end));
    
      add_to(types, x, type_start, type_end);
      add_to(names, x, name_start, name_end);
    
      itr = find_next_start(x, itr);
      debug(Rprintf("Starting next lookup at %i\n", itr));
      type_start = itr;
    
      state.reset();
      debug(Rprintf("\n\n"));
    
    }
  
    // Generate an R list to hold the results
    int nnames = names.size();
    int ntypes = types.size();
  
    SEXP result = PROTECT( Rf_allocVector(VECSXP, 2) );
    SEXP Rtypes = PROTECT( Rf_allocVector(STRSXP, ntypes) );
    for (int i=0; i < ntypes; ++i) {
      SET_STRING_ELT(Rtypes, i, Rf_mkChar(types[i].c_str()));
    }
  
    SEXP Rnames = PROTECT( Rf_allocVector(STRSXP, nnames) );
    for (int i=0; i < nnames; ++i) {
      SET_STRING_ELT(Rnames, i, Rf_mkChar(names[i].c_str()));
    }
  
    SET_VECTOR_ELT(result, 0, Rtypes);
    SET_VECTOR_ELT(result, 1, Rnames);
  
    UNPROTECT(3);
    return result;
  
  }

}
