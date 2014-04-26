complements <- c(
  "["="]",
  "{"="}",
  "("=")",
  "]"="[",
  ")"="(",
  "}"="{"
)

tab <- function(n, ...) {
  paste0( paste0( rep("    ", n), collapse="" ), ... )
}

normalize_newlines <- function(x) {
  x <- gsub("\\r\\n|\\n\\r", "\n", x, perl=TRUE)
  x <- gsub("\\r", "\n", x)
  return(x)
}

parse_cpp_args <- function(args) {
  .Call(C_parse_cpp_args, as.character(args))
}

count_newlines <- function(text, start=1L, end=nchar(text)) {
  .Call(C_count_newlines, as.character(text), as.integer(start), as.integer(end))
}

read <- function(path) {
  if (!file.exists(path)) {
    stop("no file at path '", path, "'")
  }
  path <- normalizePath(path, mustWork=TRUE)
  if (length(path) != 1) stop("'path' should be a single string")
  normalize_newlines( .Call(C_readfile, path) )
}

split_string <- function(string) {
  unlist( strsplit( string, "", fixed=TRUE ) )
}

strip_comments <- function(txt) {
  txt <- gsub("(?s)\\/\\*(.*?)*\\*\\/", "", txt, perl=TRUE)
  txt <- gsub("(?s)\\/\\/(.*?)*(?<!\\\\)\\n", "", txt, perl=TRUE)
  return(txt)
}

trim_whitespace <- function(txt) {
  gsub("^[[:space:]]*(.*?)[[:space:]]*$", "\\1", txt, perl=TRUE)
}

find_next_char <- function(chr, txt, ind) {
  return( .Call(C_find_next_char, 
    as.character(chr),
    as.character(txt),
    as.integer(ind)
  ) )
}

find_prev_char <- function(chr, txt, ind) {
  return( .Call(C_find_prev_char, 
    as.character(chr),
    as.character(txt),
    as.integer(ind)
  ) )
}

find_matching_char <- function(txt, ind) {
  chr <- substring(txt, ind, ind)
  cmp <- complements[chr]
  if (is.na(cmp)) {
    stop("no complementary character for '", chr, "'")
  }
  
  if (chr %in% c("[", "(", "{")) {
    .Call( C_find_matching_char__fwd, 
      as.character(chr), 
      as.character(cmp), 
      as.character(txt),
      as.integer(ind) 
    )
  } else {
    .Call( C_find_matching_char__bwd,
      as.character(chr), 
      as.character(cmp), 
      as.character(txt),
      as.integer(ind) 
    )
  }
}

parse_cpp_function <- function(txt, line) {
  .Call( C_parse_cpp_function, txt, line )
}

