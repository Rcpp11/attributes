#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
int stdVectorDoubleConst(const std::vector<double> x) { 
  return x.size();
}
