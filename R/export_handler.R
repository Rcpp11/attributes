parse_exports <- function(attr) {
  
  ## Read the file
  txt <- read(attr$file)
  txt <- substring(txt, attr$index, nchar(txt))
  
  ## Strip out comments
  txt <- strip_comments(txt)
  
  ## Get up to the next "{"
  txt <- substring(txt, 1, find_next_char("{", txt, 1))
  
  ## Remove excessive whitespace and newlines
  txt <- gsub("\n|[[:space:]]+", " ", txt)
  
  ## Get the arguments
  args_end <- find_prev_char(")", txt, nchar(txt))
  args_begin <- find_matching_char(txt, args_end)
  args <- substring(txt, args_begin+1, args_end-1)
  
  ## The function name comes immediately before the args_begin paren
  substr <- substring(txt, 1, args_begin - 1)
  substr <- gsub("[[:space:]]*$", "", substr)
  function_name <- gsub(".*[[:space:]]", "", substr)
  
  return( list(
    fn=function_name,
    args=args
  ) )

}
