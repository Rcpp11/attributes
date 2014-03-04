context("Rcpp::export")

txt <- paste(sep="\n",
  "//' Some Roxygen",
  "//' Comments preceding a",
  "//' Rcpp::export",
  "// [[Rcpp::export]]",
  "int foo(int bar) {",
  "",
  "//' Some other Roxygen",
  "//' @export",
  "// [[Rcpp::export]]",
  "int baz(int bat) {",
  ""
)

file <- tempfile()
cat(txt, file=file)

attrs <- parse_attrs(file)
attr <- attrs[[1]]
expect_equal( attr$row, 4 )
expect_equal( attr$index, 60 )

exports <- parse_exports(attrs)
