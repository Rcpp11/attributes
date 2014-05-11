context("tools")

test_that("find_next_char works as expected", {

  fnc <- attributes:::find_next_char

  x <- "abcdef"
  expect_equal(
    fnc("a", x, 1),
    1
  )
  expect_equal(
    fnc("b", x, 1),
    2
  )

  expect_equal(
    fnc("f", x, 1),
    6
  )

  expect_error(
    fnc("g", x, 1)
  )

  expect_error(
    fnc("f", x, 7)
  )

})

test_that("find_prev_char works as expected", {

  fpc <- attributes:::find_prev_char
  x <- "abcdef"

  expect_error(
    fpc("a", x, 1)
  )

  expect_equal(
    fpc("a", x, 2),
    1
  )

})

test_that("find_matching_char works as expected", {

  fmc <- attributes:::find_matching_char
  pairs <- list(
    parens = c("(", ")"),
    braces = c("{", "}"),
    square = c("[", "]")
  )

  for (pair in pairs) {
    string <- paste0( pair[[1]], "foo", pair[[2]] )
    expect_equal(
      fmc(string, 1),
      5
    )
    expect_equal(
      fmc(string, 5),
      1
    )
  }

})


test_that("count_newlines works", {
  expect_equal( count_newlines("\n\n\n\n\n"), 5 )
  expect_equal( count_newlines("foo"), 0 )
  txt <- "#include <Rcpp.h>\nusing namespace Rcpp ;\n\n"
  expect_equal(count_newlines(txt), 3)
})
