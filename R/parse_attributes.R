     
# [[ symbol ]]     
symbol_attribute <- function(expr, file, line){
  structure(
    list(
      expr = expr, file = file, line = line, 
      name = as.character(expr)
    ), class = c("symbol_attribute", "attribute")
  )  
}
 
# [[ !symbol ]]
negated_symbol_attribute <- function(expr, file, line){
  structure( 
    list(
      expr = expr, file = file, line = line, 
      name   = as.character(expr[[2L]])
    ), class = c("negated_symbol_attribute", "symbol_attribute", "attribute")
  )  
}

# [[ symbol = expr ]]
assignment_attribute <- function(expr, file, line){ 
  structure( 
    list(
      expr = expr, file = file, line = line, 
      target = as.character(expr[[2]]), 
      code = expr[[3]]
    ), class = c("assignment_attribute", "attribute")
  )
}
   
# [[ pkg::symbol ]]
scoped_symbol_attribute <- function(expr, file, line){
  structure(
    list(
      expr = expr, file = file, line = line, 
      package = as.character(expr[[2L]]), 
      name = as.character(expr[[3L]])
    ), class = c("scoped_symbol_attribute", "symbol_attribute", "attribute")
  )
}
  
# [[ pkg::foo(expr) ]]
scoped_call_attribute <- function(expr, file, line){
  structure(
    list( 
      expr = expr, file = file, line = line, 
      package = expr[[1L]][[2L]],
      name = expr[[1L]][[3L]]
    ), class = c("scoped_call_attribute", "call_attribute", "attribute" )
  )
}

# [[ foo(expr) ]]
call_attribute <- function(expr, file, line){
  structure( 
    list( 
      expr = expr, file = file, line = line, 
      name = as.character(expr[[1L]])
    ), class = c("call_attribute", "attribute" )
  )  
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
      
      single_line_attributes[[i]] <- if( is.symbol(expr) ){
        # attribute of the form [[symbol]]
        symbol_attribute(expr, file, line)
        
      } else if( is.call(expr) && expr[[1L]] == not && is.name(expr[[2L]]) ){
        # attribute of the form [[ !symbol ]]
        negated_symbol_attribute(expr, file, line)
          
      } else if( is.call(expr) && expr[[1L]] == equal && is.name(expr[[2]] ) ){
        # attribute of the form [[symbol = something]]
        assignment_attribute(expr, file, line) 
        
      } else if( is.call(expr) && expr[[1L]] == double_colon && is.name(expr[[3L]]) ){
        # attribute of the form [[ pkg::symbol ]]
        scoped_symbol_attribute(expr, file, line)
        
      } else if( is.call(expr) && is.call(expr[[1L]]) && expr[[1L]][[1L]] == double_colon  ){
        # attribute of the form [[ pkg::symbol(...) ]]
        scoped_call_attribute(expr, file, line)
        
      } else if( is.call(expr) && is.name(expr[[1L]]) ){
        # attribute of the form [[ foo(...) ]]
        call_attribute(expr, file, line) 
        
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

