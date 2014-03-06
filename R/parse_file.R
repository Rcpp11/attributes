get_attrs <- function(x) {
  ## change Rcpp:: to attributes::
  x <- gsub("Rcpp::", "attributes::", x, perl=TRUE)
  call <- parse(text=paste0("dummy(", x, ")"))[[1]]
  as.list( call[2:length(call)] )
}

## Parse the Attributes within a C/C++ Source File
parse_attrs <- function(file) {
  
  ## normalize the file name and check it exists
  if (!file.exists(file)) {
    stop("no file at location '", file, "'")
  }
  
  file <- normalizePath(file, mustWork=TRUE)
  
  ## read the file
  txt <- read(file)
  
  ## a regex that should match all attribute-worthy code
  pattern <- rex <- 
    "//[[:space:]]*\\[\\[[[:space:]]*(.*?)[[:space:]]*\\]\\]"
  
  ## get the indices at which we saw attributes
  matches <- gregexpr(rex, txt, perl=TRUE)
  ind <- c( matches[[1]] )
  if (identical(ind, -1L)) {
    return( list() )
  }
  n <- length(ind)
  
  lapply(ind, function(i) {
    before <- tryCatch( find_prev_char("\n", txt, i) + 1,
      error=function(e) return (1)
    )
    after <- tryCatch( find_next_char("\n", txt, i) - 1,
      error=function(e) return (nchar(txt))
    )
    row <- count_newlines(txt, before) + 1L
    line <- substring(txt, before, after)
    code <- gsub(pattern, "\\1", line, perl=TRUE)
    attrs <- get_attrs(code)
    return( list(
      string=line,
      code=code,
      index=i,
      row=row,
      attrs=attrs,
      file=file
    ) )
  })
  
}
