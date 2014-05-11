##' Compile Rcpp Attributes for a Package
##'
##' Scan the source files within a package for attributes and generate code as
##' required. Generates the bindings required to call C++ functions from R for
##' functions adorned with the Rcpp::export attribute.
##'
##' The source files in the package directory given by pkgDir are scanned for
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
##' @param pkgDir Directory containing the package to compile attributes for
##'   (defaults to the current working directory).
##' @param verbose \code{TRUE} to print detailed information about generated
##'   code to the console.
##' @param RcppExports.R Boolean; if \code{TRUE} we write wrapper \R functions
##'   out as well. This overrides any \code{// [[Rcpp::interfaces]]} attributes
##'   specified.
##' @export
compileAttributes <- function(
  pkgDir = ".",
  verbose = FALSE,
  RcppExports.R=TRUE) {

  pkgDir <- normalizePath(pkgDir, winslash = "/")

  compileDefaultAttributes(pkgDir, verbose, RcppExports.R)

}
