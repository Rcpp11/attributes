compileDefaultAttributes <- function(pkgdir, verbose, RcppExports.R) {
  
  DESCRIPTION <- as.list(read.dcf( file.path(pkgdir, "DESCRIPTION") )[1, ])
  pkgname <- DESCRIPTION$Package
  
  LinkingTo <- gsub("^[[:space:]]*", "",
    unlist( strsplit( gsub("\\r|\\n", " ", DESCRIPTION$LinkingTo), ",[[:space:]]+" ) )
  )
  
  srcDir <- file.path(pkgdir, "src")

  ## Get rid of the old RcppExports files if they exist
  if (file.exists(file <- file.path(pkgdir, "src", "RcppExports.cpp"))) {
    unlink(file)
  }
  
  if (file.exists(file <- file.path(pkgdir, "R", "RcppExports.R"))) {
    unlink(file)
  }
  
  ## Get the C++ source files
  files <- list.files(srcDir, full.names=TRUE, pattern=".cc$|.cpp$")
  
  ## Parse the attributes
  export_attrs <- lapply(files, parse_attrs, keep="Rcpp::export")
  
  ## Get the definitions for each export
  exports <- unlist( lapply(export_attrs, parse_exports), recursive=FALSE )
  
  if (length(exports)) {
    defns <- lapply(exports, generate_export, pkgdir=pkgdir)
    
    ## Write out the RcppExports.cpp file
    
    ## If we're linking to RcppArmadillo, include that instead of Rcpp
    if ("RcppArmadillo" %in% LinkingTo) {
      RcppIncludes <- "#include <RcppArmadillo.h>"
    } else {
      RcppIncludes <- "#include <Rcpp.h>"
    }
    
    RcppExports.cpp <- paste( sep="\n",
      RcppIncludes,
      "using namespace Rcpp;",
      "",
      do.call( function(...)
        paste(..., sep="\n", collapse="\n"),
        lapply(defns, function(x) paste(x, collapse="\n"))
      )
    )
    
    cat(RcppExports.cpp, file=file.path(pkgdir, "src", "RcppExports.cpp"))
    
    ## Similarily, we must generate an RcppExports.R file
    make_R_function <- function(export) {
      Rfun <- paste( sep="\n",
        tab(0, export$roxygen),
        tab(0, paste0(export$func, " <- function(", paste(export$arg_names, collapse=", "), ") {")),
        tab(1, ".Call('", paste(pkgname, export$func, sep="_"), "', PACKAGE='", pkgname, "', ",
          paste(export$arg_names, collapse=", "), ")"),
        tab(0, "}"),
        "\n"
      )
    }
    
    if (RcppExports.R) {
      RcppExports.R <- do.call( function(...)
        paste(..., collapse="\n"),
        lapply(exports, make_R_function)
      )
      
      cat(RcppExports.R, file=file.path(pkgdir, "R", "RcppExports.R"))
    }
    
  }
  
}
