sourceCppContext <- function(file){
  cpp_temp_file <- tempfile( fileext = ".cpp" )
  R_temp_file   <- tempfile( fileext = ".R" ) 
  dynlib        <- gsub( "[.]cpp", .Platform$dynlib.ext, cpp_temp_file)
  
  file.copy( file, cpp_temp_file )
  cpp_con <- file( cpp_temp_file, open = "a" )
  R_con   <- file( R_temp_file, open = "w" )
         
  buildEnv <- new.env()
  buildEnv[["USE_CXX1X"]] <- "yes"
    
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
    if( length(ls(buildEnv)) )
      do.call( Sys.setenv, as.list(buildEnv) )
    
    owd <- setwd( tempdir() )
    on.exit( { setwd(owd) })
    
    # SHLIB
    cmd <- paste(R.home(component="bin"), .Platform$file.sep, "R ",
                     "CMD SHLIB ",
                     shQuote(basename(cpp_temp_file)), sep="")
    
    system( cmd, intern = TRUE )
    
    # load
    dyn.load( basename(dynlib) )    
    
    # run the R code
    source( R_temp_file )
    
  }
  ctx
}

sourceCppHandlersEnv <- new.env()
sourceCppHandlersEnv[["Rcpp::export"]] <- function(attribute, context, ...){
  # parse C++ function internally
  cpp_fun <- .Call( C_parse_cpp_function, attribute$content, attribute$line )
  name <- cpp_fun$name
  arguments <- cpp_fun$arguments
  if( identical(arguments, "void" ) ) arguments <- list() 
  
  params <- paste( sprintf( "SEXP %sSEXP", names(arguments) ), collapse = ", " )
  return_type <- cpp_fun$return_type
  is_void <- identical( return_type, "void" ) 
  
  # generate C++ code
  input_parameters <- sprintf( "Rcpp::traits::input_parameter<%s>::type %s(%sSEXP) ;", sapply(arguments, "[[", 1L), names(arguments), names(arguments) )
  
  return_txt <- if( is_void ){
      sprintf( "%s(%s) ; __sexp_result = R_NilValue ;", name, paste(names(arguments), collapse = ", " ) )
  } else {
      sprintf( "%s __result = %s(%s) ; PROTECT(__sexp_result = Rcpp::wrap(__result)) ;", return_type,  name, paste(names(arguments), collapse = ", " ) ) 
  }
  unprotect <- if( is_void ){
    ""   
  } else {
    "UNPROTECT(1) ;"  
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
  
  # generate R code
  R_params <- paste( sapply( arguments, function(arg){
    if( arg[1L] %in% c("Dots", "Rcpp::Dots", "NamedDots", "Rcpp::NamedDots") ){
      "..."  
    } else {
      arg[3L]  
    }
  }), collapse = ", " )
  
  if( length(arguments) ) {
    cpp_params <- paste( sapply( arguments, function(arg){
      if( arg[1L] %in% c("Dots", "Rcpp::Dots", "NamedDots", "Rcpp::NamedDots") ){
        "environment()"  
      } else {
        arg[3L]
      }
    }), collapse = ", " )
    cpp_params <- sprintf( ", %s", cpp_params )
  } else {
    cpp_params <- ""  
  }
  
  return_txt <- if( is_void ) "invisible(NULL)" else "res"
  
  Rcode <- sprintf( '
  %s <- function(%s){
    res <- .Call( "sourceCpp_%s" %s)
    %s
  }
  ', name, R_params, name, cpp_params, return_txt)
  context$add_R(Rcode)
  
}   

sourceCppHandlersEnv[["Rcpp::depends"]] <- function(attribute, context, ...){
  packages <- sapply( attribute$param, as.character )
  # emulate LinkingTo

  paths <- sapply( packages, function(.){
    system.file( "include", package = . )
  })
  paths <- paths[ paths != "" ]
  
  flag <- paste( sprintf( '-I"%s"', paths ), collapse = " " )
  context$build_param( "CLINK_CPPFLAGS", flag )
  
}

sourceCppHandlers <- function(){
  sourceCppHandlersEnv  
}

##' @export
sourceCpp <- function( file, Rcpp = "Rcpp11", handlers = sourceCppHandlers() ){
  
  attributes <- parse_attributes(file)
  context <- sourceCppContext(file) 
  
  for( att in attributes$attributes ){
    # generate code or contribute to build environment
    handler <- handlers[[att$name]]
    if( is.null(handler) ){
      warning( sprintf("unknown attribute '%s' ", att$name) )  
    } else {
    
      # using do.call so that parameter matching works for us
      # to handle default arguments
      args <- append( list(attribute = att, context = context), att$param ) 
      do.call( handler, args )
    }
  }
  
  # add the LinkingTo: Rcpp*
  context$build_param( "CLINK_CPPFLAGS", .buildClinkCppFlags(Rcpp) )
  
  context$compile()
  
  for( chunk in attributes$r_code_chunks ){
    temp <- tempfile( fileext = ".R" )
    writeLines( chunk, temp )
    source( temp, echo = TRUE )
  }
  
}

