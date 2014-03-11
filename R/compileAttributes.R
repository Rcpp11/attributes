compileAttributes <- function( root ){
  pkg <- basename(root)
  
  cpp_files <- list.files( file.path(root, "src" ), 
    pattern = "[.](cc,cpp)$", full.names = TRUE)
  
  attributes <- c(lapply( cpp_files, function(file){
    parse_attributes(file)$attributes
  }))
  
  attributes
  
}
