## Parse the Attributes within a C/C++ Source File
parse_file <- function(file) {
  
  ## normalize the file name and check it exists
  if (!file.exists(file)) {
    stop("no file at location '", file, "'")
  }
  
  file <- normalizePath(file, mustWork=TRUE)
  
  ## read the file
  txt <- readLines(file)
  
  ## a regex that should match all attribute-worthy code
  ## /\s*//\s*\[\[(.*?)\]\]
  rex <- "[[:space:]]*//[[:space:]]\\[\\[(.*?)\\]\\]"
  
  ## get the indices at which we saw attributes
  ind <- grep(rex, txt, perl=TRUE)
  n <- length(ind)
  
  lapply(ind, function(i) {
    line <- txt[i]
    code <- gsub(rex, "\\1", line, perl=TRUE)
    return( list(
      string=line,
      code=code,
      expr=parse(text=code),
      index=i,
      file=file
    ))
  })
  
}
