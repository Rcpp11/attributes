context("pattern")

test_that("the pattern used successfully matches attributes", {

  txt <- read("helper-example.cpp")
  matches <- gregexpr(pattern, txt)
  expect_equal( length(matches[[1]]), 4 )

})
