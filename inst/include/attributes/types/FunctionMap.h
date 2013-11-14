#ifndef ATTRIBUTES_TYPES_FunctionMap_H
#define ATTRIBUTES_TYPES_FunctionMap_H
  
namespace attributes{
       
    class FunctionMap {
        std::map< std::string, std::vector<Function> > map_ ;
        
    public:
        FunctionMap(){};
        ~FunctionMap(){} ;
        
        void insert( const Function& fun ){
            map_[ fun.name() ].push_back( fun ) ;
        }
    } ;
    
    
}

#endif
