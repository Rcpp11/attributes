#include <Rcpp.h>
using namespace Rcpp ;


// [[Rcpp::export]]
int foo(int a, 
    int b = 22
    ){
  return 2 ;
}

//' Some Roxygen
//' Comments preceding an
//' Rcpp::export
// [[Rcpp::export]]
int bar() {
  return 2;
}

//' Some other Roxygen
//' @export
// [[Rcpp::export]]
int baz(int bat) {
  return bat;
}
