cdr <- function(x){
  .Call('get_cdr', x, PACKAGE = "attributes")  
}

parse_attributes <- function(file){
  # attribute regex
  rx <- "^//[[:space:]][[][[](.*)[]][]].*$"
  
  # find matches
  code <- readLines(file)
  matches <- grep( rx, code )
  
  double_colon <- as.name("::")
  equal <- as.name("=")
  not <- as.name("!")
   
  single_line_attributes <- NULL  
  if( length(matches) ){
    expressions <- gsub(rx, "\\1", code[matches] )
    single_line_attributes <- rep( list(NULL), along = expressions )
    for( i in seq_along(expressions)){
      expr <- parse( text = expressions[i], n = 1L )[[1L]]
      line <- matches[i]
      
      if( is.symbol(expr) ){
        # attribute of the form [[symbol]] -> equivalent to symbol()
        name <- as.character(expr)
        if( name %in% c("export", "depends" ) ){
          name <- sprintf("Rcpp::%s", name )  
        }
        single_line_attributes[[i]] <- structure(
          list( 
            file = file, line = line, content = code, name = name, param = NULL
          ), 
          class = "call_attribute"
        )
      # } else if( is.call(expr) && expr[[1L]] == equal && is.name(expr[[2]] ) ){
      #   target <- as.character(expr[[2]])
      #   single_line_attributes[[i]] <- structure(
      #     list( 
      #       file = file, line = line, content = code, target = target, code = expr[[3L]]
      #     ), 
      #     class = "assignment_attribute"
      #   )
      } else if( is.call(expr) && expr[[1L]] == double_colon && is.name(expr[[3L]]) ){
        name <- sprintf( "%s::%s", as.character(expr[[2L]]), as.character(expr[[3L]]) )
        single_line_attributes[[i]] <- structure(
          list( 
            file = file, line = line, content = code, name = name, param = NULL
          ), 
          class = "call_attribute"
        )
        
      } else if( is.call(expr) && is.call(expr[[1L]]) && expr[[1L]][[1L]] == double_colon  ){
        name <- sprintf( "%s::%s", expr[[1L]][[2L]], expr[[1L]][[3L]] )
        single_line_attributes[[i]] <- structure(
          list( 
            file = file, line = line, content = code, name = name, param = as.list(cdr(expr))
          ), 
          class = "call_attribute"
        )
        
      } else if( is.call(expr) && is.name(expr[[1L]]) ){
        name <- as.character(expr[[1L]])
        if( name %in% c("export", "depends" ) ){
          name <- sprintf("Rcpp::%s", name )  
        }
        
        single_line_attributes[[i]] <- structure(
          list( 
            file = file, line = line, content = code, name = name, param = as.list(cdr(expr))
          ), 
          class = "call_attribute"
        )
        
      } else {
        stop( sprintf( "unrecognized attribute form : [[ %s ]]", deparse(substitute(expr)) ) )  
      }
      
    }
    single_line_attributes
  }
  attributes <- single_line_attributes
  
  # R code chunks /*** R */
  start_rx <- "^/[*]{3}[[:space:]]*[Rr]"
  end_rx   <- "^[*]+/"
  start_matches  <- grep( start_rx, code )
  end_matches    <- grep( end_rx, code )
  r_code_chunks <- NULL
  if( n <- length(start_matches) ){
    r_code_chunks <- rep( list(NULL), n )
    for( i in seq_len(n) ){
      start <- start_matches[i] +1 
      end <- end_matches[ end_matches > start ][1L] - 1L
      txt <- code[ seq(start, end) ]
      expr <- parse( text = txt )
      
      r_code_chunks[[i]] <- expr
    }
  }
  
  list( 
    attributes = attributes, 
    r_code_chunks = r_code_chunks
  )
  
}

