## a regex that should match all attribute-worthy code

pattern <- paste0(
  "\n", ## find a newline
  "[[:blank:]]*", ## allow for indentation
  "//[[:blank:]]*", ## the comment should be started by //, with potential spaces following
  "\\[\\[", ## the opening square brackets
  "[[:space:]]*(.*?)[[:space:]]*", ## the material within
  "\\]\\]" ## closing brackets
)

pattern_no_new_line <- substring(pattern, 2, nchar(pattern))

get_attrs <- function(x) {

  ## change Rcpp:: to attributes::
  x <- gsub("Rcpp::", "attributes::", x, perl=TRUE)

  ## if there is no '::', assume it's an 'attributes' attribute
  if (!grepl("::", x, fixed=TRUE)) {
    x <- paste0("attributes::", x)
  }

  ## wrap x in a function call, so we can handle arbitrary expressions
  call <- parse(text=paste0("dummy(", x, ")"))[[1]]

  as.list(call[2:length(call)])[[1]]

}

## Parse the Attributes within a C/C++ Source File
parse_attrs <- function(file, keep=NULL) {

  ## normalize the file name and check it exists
  if (!file.exists(file)) {
    stop("no file at location '", file, "'")
  }

  file <- normalizePath(file, mustWork=TRUE)

  ## read the file
  txt <- read(file)

  ## get the indices at which we saw attributes
  matches <- gregexpr(pattern, txt, perl=TRUE)
  ind <- c( matches[[1]] ) + 1L ## offset for newline matched
  if (identical(ind, -1L)) {
    return( list() )
  }
  n <- length(ind)

  parsed_attributes <- vector("list", n)
  for (idx in seq_along(parsed_attributes)) {

    ## Get the index locating the start of the attribute
    i <- ind[[idx]]

    before <- tryCatch( find_prev_char("\n", txt, i) + 1L,
                        error=function(e) return (1)
    )

    after <- tryCatch( find_next_char("\n", txt, i) - 1L,
                       error=function(e) return (nchar(txt))
    )

    row <- count_newlines(txt, end = after)
    line <- substring(txt, before, after)
    code <- gsub(pattern_no_new_line, "\\1", line, perl=TRUE)
    attrs <- get_attrs(code)
    parsed_attributes[[idx]] <- list(
      string=line,
      code=code,
      index=i,
      row=row,
      attrs=attrs
    )
  }

  if (!is.null(keep)) {
    parsed_attributes <- parsed_attributes[ sapply(parsed_attributes, function(x) {
      any( sapply(keep, function(k) grepl(k, x)) )
    }) ]
  }

  list(
    file=file,
    attributes=parsed_attributes
  )

}
