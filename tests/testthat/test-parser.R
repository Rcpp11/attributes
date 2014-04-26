context("parser")

test_that("parse_attrs works as expected", {
  
  attributes <- parse_attrs("helper-example.cpp")
  
})

test_that("parse_exports works as expected", {
  
  attributes <- parse_attrs("helper-example.cpp")
  exports <- parse_exports(attributes)
  lapply(exports, generate_export, pkgDir="../../")
  
})

test_that("parse_attrs, parse_exports work", {
  
  attributes <- parse_attrs("helper-example.cpp")
  exports <- parse_exports(attributes)
  has_roxygen <- sapply(exports, function(x) !is.null(x$roxygen))
  expect_false(has_roxygen[[1]], "helper-example 1 has no roxygen")
  expect_true(has_roxygen[[2]], "helper-example 2 has roxygen")
  expect_true(has_roxygen[[3]], "helper-example 3 has roxygen")
  
})

test_that("the c++ arg parser works", {
  
  string <- "const std::vector<double> x"
  (parsed <- parse_cpp_args(string))
  expect_equal(
    parsed[[1]], "const std::vector<double>"
  )
  expect_equal(
    parsed[[2]], "x"
  )
  
  string <- "int x = 1, int y = 2, int z = 3"
  (parsed <- parse_cpp_args(string))
  expect_equal(
    parsed,
    list( c("int", "int", "int"), c("x", "y", "z") )
  )
  
  string <- " DataFrame df     , std::string s "
  (parsed <- parse_cpp_args(string))
  expect_equal(
    parsed,
    list( c("DataFrame", "std::string"), c("df", "s"))
  )
  
  string <- " S4 o, std::string yy "
  (parsed <- parse_cpp_args(string))
  expect_equal(
    parsed,
    list( c("S4", "std::string"), c("o", "yy") )
  )
  
  string <- "std::vector<double> & x"
  (parsed <- parse_cpp_args(string))
  expect_equal(
    parsed,
    list("std::vector<double> &", "x")
  )
  
  string <- "const CharacterVector& str     "
  (parsed <- parse_cpp_args(string))
  expect_equal(
    parsed,
    list("const CharacterVector&", "str")
  )
  
})
