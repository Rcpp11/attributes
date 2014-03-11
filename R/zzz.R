attributes_lib <- NULL

.onLoad <- function(libname, pkgname){
  attributes_lib <<- tempfile()
  dir.create( attributes_lib )
}

