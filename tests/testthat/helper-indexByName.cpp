// [[Rcpp::export]]
SEXP index_byName( DataFrame df, std::string s ){
    return df[s];
}
