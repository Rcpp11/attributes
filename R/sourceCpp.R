sourceCppContext <- function(file){
  cpp_temp_file <- tempfile( fileext = ".cpp" )
  R_temp_file   <- tempfile( fileext = ".R" ) 
  
  file.copy( file, cpp_temp_file )
  cpp_con <- file( cpp_temp_file, open = "a" )
  R_con   <- file( R_temp_file, open = "w" )
         
  buildEnv <- new.env()
    
  ctx <- new.env()
  ctx[["add_cpp"]] = function(code){
    writeLines(code, cpp_con)  
  }
  ctx[["add_R"]] = function(code){
    writeLines(code, R_con )
  }
  ctx[["build_param"]] = function(name, value){
    # protect against null or empty string
    if (is.null(value) || !nzchar(value))
      return;
      
    if (is.null(buildEnv[[name]]) ){
      buildEnv[[name]] <- value  
    } else if( !identical( buildEnv[[name]], value ) ){
      buildEnv[[name]] <- paste( buildEnv[[name]], value )
    }
    
  }
  ctx[["compile"]] = function(){
    # finish
    close(cpp_con)
    close(R_con)
    
    # setup the build env
    
    # SHLIB
    
    # load
    
    # run the R code
    
  }
  ctx[["debug"]] = function(){
    close(cpp_con)
    close(R_con)
    
    writeLines(readLines(cpp_temp_file))
    writeLines(readLines(R_temp_file)  )
    
  }
  ctx
}

sourceCppHandlersEnv <- new.env()
sourceCppHandlersEnv[["Rcpp::export"]] <- function(attribute, context, ...){
  cpp_fun <- .Call( "parse_cpp_function", attribute$content, attribute$line )
  name <- cpp_fun$name
  arguments <- cpp_fun$arguments
  params <- paste( sprintf( "SEXP %sSEXP", names(arguments) ), collapse = ", " )
  return_type <- cpp_fun$return_type
  is_void <- identical( return_type, "void" ) 
  
  input_parameters <- sprintf( "Rcpp::traits::input_parameter<%s>::type %s(%sSEXP) ;", sapply(arguments, "[[", 1L), names(arguments), names(arguments) )
  
  return_txt <- if( is_void ){
      sprintf( "%s(%s) ;", name, paste(names(arguments), collapse = ", " ) )
  } else {
      sprintf( "%s __result = %s(%s) ; __sexp_result = PROTECT(Rcpp::wrap(__result)) ;", return_type,  name, paste(names(arguments), collapse = ", " ) ) 
  }
  unprotect <- if( is_void ){
    ""   
  } else {
    "UNPROTECT(1)" ;  
  }
  
  body <- sprintf( '
  BEGIN_RCPP
    SEXP __sexp_result ;
    {
      Rcpp::RNGScope __rngScope;
      %s
      %s
    }
    %s
    return __sexp_result ;
  END_RCPP
  ', paste( input_parameters, collapse = "\n      " ), return_txt, unprotect )
  
  # generate the cpp code
  code <- sprintf( '
// %s (%s:%d) - %s
extern "C" SEXP sourceCpp_%s( %s ){
  %s
}', name, attribute$file, attribute$line, attribute$name, name, params, body)
  
  context$add_cpp(code) 
}   

sourceCppHandlers <- function(){
  sourceCppHandlersEnv  
}


sourceCpp <- function( file, Rcpp = "Rcpp11", handlers = sourceCppHandlers() ){
  
  attributes <- parse_attributes(file)
  context <- sourceCppContext(file) 
  
  for( att in attributes$attributes ){
    # generate code or contribute to build environment
    handler <- handlers[[att$name]]
    
    # using do.call so that parameter matching works for us
    # to handle default arguments
    args <- append( list(attribute = att, context = context), att$param ) 
    do.call( handler, args )
  }
  
  context$debug()
  
}

