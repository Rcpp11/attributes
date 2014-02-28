## Parse the Attributes within a C/C++ Source File
parse_file <- function(file) {
  
  ## normalize the file name and check it exists
  if (!file.exists(file)) {
    stop("no file at location '", file, "'")
  }
  
  file <- normalizePath(file, mustWork=TRUE)
  
  ## read the file
  txt <- read(file)
  
  ## a regex that should match all attribute-worthy code
  ## /\s*//\s*\[\[(.*?)\]\]
  pattern <- "//[[:space:]]\\[\\[(.*?)\\]\\]"
  rex <- "(?=//[[:space:]]\\[\\[(.*?)\\]\\])"
  
  ## get the indices at which we saw attributes
  matches <- gregexpr(rex, txt, perl=TRUE)
  ind <- c( matches[[1]] )
  n <- length(ind)
  
  lapply(ind, function(i) {
    before <- tryCatch( find_prev_char("\n", txt, i) + 2,
      error=function(e) return (1)
    )
    after <- tryCatch( find_next_char("\n", txt, i) - 1,
      error=function(e) return (nchar(txt))
    )
    line <- substring(txt, before, after)
    code <- gsub(pattern, "\\1", line, perl=TRUE)
    return( list(
      string=line,
      code=code,
      expr=parse(text=code),
      index=i,
      file=file
    ))
  })
  
}
