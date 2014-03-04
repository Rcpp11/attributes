get_roxygen_index <- function(text, index) {
  return( .Call(C_get_roxygen_index, text, index) )
}
