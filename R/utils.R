complements <- c(
  "["="]",
  "{"="}",
  "("=")",
  "]"="[",
  ")"="(",
  "}"="{"
)

split_string <- function(string) {
  unlist( strsplit( string, "", fixed=TRUE ) )
}

strip_comments <- function(txt) {
  
  ## collapse with something other than '\n' so we can regex over the
  ## newlines
  txt <- paste(txt, collapse="__ATTRIBUTES__NEWLINE__MARKER__")
  
  txt <- gsub("\\/\\*(.*?)\\*\\/", "", txt, perl=TRUE)
  txt <- gsub("\\/\\/(.*?)__ATTRIBUTES__NEWLINE__MARKER__", "", txt, perl=TRUE)
  
  return( unlist(strsplit(txt, "__ATTRIBUTES__NEWLINE__MARKER__", fixed=TRUE)) )
  
}

find_next_char <- function(chr, txt, ind) {
  i <- ind + 1
  n <- length(txt)
  while (i <= n) {
    if (txt[i] == chr) return(i)
    i <- i + 1
  }
  stop("couldn't find character '", chr, "'")
}

find_prev_char <- function(chr, txt, ind) {
  i <- ind - 1
  while (i > 0) {
    if (txt[i] == chr) return(i)
    i <- i - 1
  }
  stop("couldn't find character '", chr, "'")
}

find_matching_char <- function(txt, ind, direction="") {
  txt <- unlist( strsplit( txt, "", fixed=TRUE ) )
  chr <- txt[ind]
  cmp <- complements[chr]
  if (is.na(cmp)) {
    stop("no complementary character for '", chr, "'")
  }
  
  if (direction == "forward" || ind %in% c("[", "(", "{")) {
    .find_matching_char__fwd(chr, cmp, txt, ind)
  } else {
    .find_matching_char__bwd(chr, cmp, txt, ind)
  }
}

.find_matching_char__fwd <- function(chr, cmp, txt, ind) {
  balance <- 1
  n <- nchar(txt)
  i <- ind + 1
  while (i <= n) {
    if (txt[i] == chr) balance <- balance + 1
    if (txt[i] == cmp) balance <- balance - 1
    if (balance == 0) break
    i <- i + 1
  }
  if (i == n) stop("could not find a matching character");
  return(i)
}

.find_matching_char__bwd <- function(chr, cmp, txt, ind) {
  balance <- 1
  n <- nchar(txt)
  i <- ind - 1
  while (i > 0) {
    if (txt[i] == chr) balance <- balance + 1
    if (txt[i] == cmp) balance <- balance - 1
    if (balance == 0) break
    i <- i - 1
  }
  if (i == 0) stop("could not find a matching character");
  return(i)
}
