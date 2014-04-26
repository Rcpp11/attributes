context("pattern")

test_that("the pattern used successfully matches attributes", {
  
  txt <- read("helper-example.cpp")
  matches <- gregexpr(pattern, txt)
  ml <- attr(matches[[1]], "match.length")
  expect_equal( length(unique(ml)), 1 )
  
})
