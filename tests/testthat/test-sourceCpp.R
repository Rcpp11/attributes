context("sourceCpp")

test_that("sourceCpp's code argument works", {

  sourceCpp(code = '
            #include <Rcpp.h>
            using namespace Rcpp;

            // [[Rcpp::export]]
            int one() {
              return 1;
            }
            ')

  expect_identical(one(), 1L)

})
