
sourceCpp <- function(file){
  
  # error if the file extension isn't one supported by R CMD SHLIB
  if (! file_ext(file) %in% c("cc", "cpp")) {
      stop("The filename '", basename(file), "' does not have an ",
           "extension of .cc or .cpp so cannot be compiled.")
  }
         
  # resolve the file path
  file <- normalizePath(file, winslash = "/")
         
  # gather attributes data
  attributes <- parse_attributes(file)
     
  att <- attributes$attributes
  
  
  att
  
}
