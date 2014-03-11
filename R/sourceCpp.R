
sourceCpp <- function( file, Rcpp = "Rcpp11", lib = attributes_lib ){
  # the package root directory
  root  <- tempfile()
  pkg   <- basename(root) 
  dir.create( root )
  
  # the .cpp code
  dir.create( file.path( root, "src" ) )
  file.copy( file, file.path( root, "src", basename(file) ) )
  
  # DESCRIPTION and NAMESPACE
  DESCRIPTION <- file.path( root, "DESCRIPTION" )
  writeLines( sprintf('
Package: %s
Title: %s
Version: 0.0
Depends: R (>= %s), %s
LinkingTo: %s

  ', pkg, pkg, sprintf( "%s.%s", version$major, version$minor ), Rcpp, Rcpp), DESCRIPTION )
  
  NAMESPACE <- file.path( root, "NAMESPACE" )
  writeLines( sprintf( 'useDynLib("%s")', pkg ), NAMESPACE )
  
  compileAttributes( root )
  
  install_cmd <- sprintf( "R CMD INSTALL --library=%s %s", shQuote(lib), shQuote(root) )
  result <- system( install_cmd )
  
  library( pkg, character.only=TRUE, lib = lib )
  root
}

