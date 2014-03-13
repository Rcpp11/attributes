context("tools")

attributes <- parse_attrs("helper-example.cpp")
exports <- parse_exports(attributes)

test_that("Attributes two and three have roxygen", {
  sapply(attributes[[2]], function(x) !is.null(x$roxygen))
})
