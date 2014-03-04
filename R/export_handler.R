## Parse exports from a list of attributes
## Assume these are the attributes for one file
parse_exports <- function(attrs) {
  
  uniq_files <- unique( sapply(attrs, "[[", "file") )
  if (length(uniq_files) != 1) {
    stop("expected a single file encompassed by this list of attributes")
  }
  file <- attrs[[1]]$file
  allText <- read(file)
  
  lapply(attrs, function(attr) {
    
    ## Get Roxygen comments, if available
    comment_index <- get_roxygen_index(allText, attr$index)
    if (!is.null(comment_index)) {
      roxygen <- substring(allText, comment_index, attr$index - 1)
    } else {
      roxygen <- NULL
    }
    
    txt <- substring(allText, attr$index, nchar(allText))
    
    ## Strip out comments
    txt <- strip_comments(txt)
    
    ## Get up to the next "{"
    txt <- substring(txt, 1, find_next_char("{", txt, 1))
    
    ## Remove excessive whitespace and newlines
    txt <- gsub("\n|[[:space:]]+", " ", txt)
    
    ## Get the prototype
    prototype <- gsub("[[:space:]]+\\{", ";", txt)
    
    ## Get the arguments
    args_end <- find_prev_char(")", txt, nchar(txt))
    args_begin <- find_matching_char(txt, args_end)
    args <- substring(txt, args_begin+1, args_end-1)
    
    ## Clean out the whitespace
    args <- gsub("^[[:space:]]", "", args)
    args <- gsub("[[:space:]]$", "", args)
    
    ## The function name comes immediately before the args_begin paren
    substr <- substring(txt, 1, args_begin - 1)
    substr <- gsub("[[:space:]]*$", "", substr)
    function_name <- gsub(".*[[:space:]]", "", substr)
    
    ## We extract the type from everything before the function name
    function_type <- gsub( paste0(function_name, ".*"), "", prototype )
    function_type <- gsub("[[:space:]]*$", "", gsub("const ", "", function_type))
    
    ## Get argument names, types
    parsed_args <- parse_args(args)
    
    return( list(
      prototype=prototype,
      func=function_name,
      type=function_type,
      args=args,
      arg_types=parsed_args[[1]],
      arg_names=parsed_args[[2]],
      roxygen=roxygen
    ) )
    
  })
    
}

## Given the parsed information from parse_exports, generate some text that
## can be written to RcppExports.cpp
## Example:
##
## // char_to_factor
## RObject char_to_factor(RObject x_, bool inplace);
## RcppExport SEXP Kmisc_char_to_factor(SEXP x_SEXP, SEXP inplaceSEXP) {
## BEGIN_RCPP
##     SEXP __sexp_result;
##     {
##         Rcpp::RNGScope __rngScope;
##         Rcpp::traits::input_parameter< RObject >::type x_(x_SEXP );
##         Rcpp::traits::input_parameter< bool >::type inplace(inplaceSEXP );
##         RObject __result = char_to_factor(x_, inplace);
##         PROTECT(__sexp_result = Rcpp::wrap(__result));
##     }
##     UNPROTECT(1);
##     return __sexp_result;
## END_RCPP
## } 
generate_export <- function(x) {
  
  get_input_parameters <- function(x) {
    paste0("Rcpp::traits::input_parameter< ", x$arg_types, " >::type ", x$arg_names, "( ", x$arg_names, "SEXP );")
  }
  
  get_result_statement <- function(x) {
    paste( sep="", collapse=" ",
      x$type, " __result = ", x$func, "(", 
      paste(x$arg_names, collapse=", "), 
      ");"
    )
  }
  
  void_result_statement <- function(x) {
    paste( sep="", collapse=" ",
      x$func, "(", 
      paste(x$arg_names, collapse=", "), 
      ");"
    )
  }
  
  pkg_name <- read.dcf("DESCRIPTION")[,"Package"]
  comment_header <- paste("//", x$func)
  prototype <- x$prototype
  defn_args <- paste0("SEXP ", x$arg_names, "SEXP")
  defn_start <- paste0(
    "extern \"C\" SEXP ", paste(pkg_name, x$func, sep="_"), "(",
    paste(defn_args, collapse=", "), ") {"
  )
  
  if (x$type == "void") {
    defn <- c(
      comment_header,
      prototype,
      defn_start,
      tab(0, "BEGIN_RCPP"),
      tab(1, "{"),
      tab(2, "Rcpp::RNGScope __rngScope;"),
      tab(2, get_input_parameters(x)),
      tab(2, void_result_statement(x)),
      tab(1, "}"),
      tab(1, "return R_NilValue;"),
      tab(0, "END_RCPP"),
      tab(0, "}"),
      ""
    )
  } else {
    defn <- c(
      comment_header,
      prototype,
      defn_start,
      tab(0, "BEGIN_RCPP"),
      tab(1, "SEXP __sexp_result;"),
      tab(1, "{"),
      tab(2, "Rcpp::RNGScope __rngScope;"),
      tab(2, get_input_parameters(x)),
      tab(2, get_result_statement(x)),
      tab(2, "PROTECT(__sexp_result = Rcpp::wrap(__result));"),
      tab(1, "}"),
      tab(1, "UNPROTECT(1);"),
      tab(1, "return __sexp_result;"),
      tab(0, "END_RCPP"),
      tab(0, "}"),
      ""
    )
  }
  
  
  
  return(defn)
  
}
