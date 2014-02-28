parse_exports <- function(attr) {
  
  ## Read the file
  txt <- readLines(attr$file)
  txt <- txt[attr$index:length(txt)]
  
  ## Strip out comments
  txt <- strip_comments(txt)
  
  ## Collapse it
  txt <- paste(txt, collapse=" ")
  
  ## Remove excessive whitespace
  txt <- gsub("[[:space:]]+", " ", txt)
  txt <- split_string(txt)
  
  ## Find the first '{' after the index of the Rcpp::export attribute
  brace_loc <- find_next_char("{", txt, 1)
  
  ## Split it
  str_split <- txt[1:(brace_loc - 1)]
  str <- paste(str_split, collapse="")
  
  ## Split into something with this structure:
  ## (return type + modifiers)
  ## (function name)
  ## (arguments)
  
  i <- length(str_split)
  while (i > 0) {
    if (str_split[i] == ")") break
    i <- i - 1
  }
  if (i == 0) stop("couldn't find a closing brace")
  args_begin <- find_matching_char(str, i)
  args_end <- i
  args <- substring(str, args_begin+1, args_end-1)
  
  ## The function name comes immediately before the args_begin paren
  substr <- substring(str, 1, args_begin - 1)
  substr <- gsub("[[:space:]]*$", "", substr)
  function_name <- gsub(".*[[:space:]]", "", substr)
  
  return( list(
    fn=function_name,
    args=args
  ) )

}
