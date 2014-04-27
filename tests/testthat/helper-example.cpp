// [[Rcpp::depends(RcppArmadillo)]]
#include <Rcpp.h>
using namespace Rcpp ;


// [[Rcpp::export(R_foo)]]
int foo(int a,
    int b = 22
    ){
  return 2 ;
}

//' Some Roxygen
//' Comments preceding an
//' Rcpp::export
// [[attributes::export]]
int bar() {
  return 2;
}

//' Some other Roxygen
//' @export
// [[export]]
int baz(int bat) {
  return bat;
}

// Something that isn't an Rcpp::export attribute
// [[attributes::somethingElse]]
void somethingElse() {}
