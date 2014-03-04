##' Compile Rcpp Attributes for a Package
##' 
##' Scan the source files within a package for attributes and generate code as 
##' required. Generates the bindings required to call C++ functions from R for
##' functions adorned with the Rcpp::export attribute.
##' 
##' The source files in the package directory given by pkgdir are scanned for
##' attributes and code is generated as required based on the attributes.
##' 
##' For C++ functions adorned with the Rcpp::export attribute, the C++ and R 
##' source code required to bind to the function from R is generated and added
##' (respectively) to \code{src/RcppExports.cpp} or \code{R/RcppExports.R}.
##' 
##' @return Returns (invisibly) a character vector with the paths to any 
##' files that were updated as a result of the call.
##' 
##' @note
##' 
##' The compileAttributes function deals only with exporting C++ functions 
##' to R. If you want the functions to additionally be publicly available from
##' your package's namespace another step may be required. Specifically, if
##' your package NAMESPACE file does not use a pattern to export functions
##' then you should add an explicit entry to NAMESPACE for each R function
##' you want publicly available.
##' 
##' In addition to exporting R bindings for C++ functions, the compileAttributes
##' function can also generate a direct C++ interface to the functions using
##' the Rcpp::interfaces attribute.
##' 
##' @param pkgdir Directory containing the package to compile attributes for
##'   (defaults to the current working directory).
##' @param verbose \code{TRUE} to print detailed information about generated
##'   code to the console.
##' @export
compileAttributes <- function(pkgdir = ".", verbose = FALSE) {
  
  pkgdir <- normalizePath(pkgdir, winslash = "/")
  pkgname <- read.dcf( file.path(pkgdir, "DESCRIPTION") )[, "Package"]
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
  attrs <- unlist( lapply(files, parse_attrs), recursive=FALSE )
  
  ## Get the exports
  export_attrs <- attrs[ sapply(attrs, function(x) {
    grepl("Rcpp::export", x$code)
  })]
  
  ## Get the definitions for each export
  files <- sapply(export_attrs, "[[", "file")
  uniq_files <- unique(files)
  exports <- unlist(recursive=FALSE, lapply(uniq_files, function(file) {
    parse_exports( export_attrs[files == file] )
  }))
  
  if (length(exports)) {
    defns <- lapply(exports, generate_export)
    
    ## Write out the RcppExports.cpp file
    RcppExports.cpp <- paste( sep="\n",
      "#include <Rcpp.h>",
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
    
    RcppExports.R <- do.call( function(...)
      paste(..., collapse="\n"),
      lapply(exports, make_R_function)
    )
    
    cat(RcppExports.R, file=file.path(pkgdir, "R", "RcppExports.R"))
    
  }
  
}
