#ifndef ATTRIBUTES_TYPES_TYPE_H
#define ATTRIBUTES_TYPES_TYPE_H
  
namespace attributes{
    
    class Type {
    public:
        Type() {}
        Type(const std::string& name, bool isConst, bool isReference)
            : name_(name), isConst_(isConst), isReference_(isReference)
        {
        }
        bool empty() const {
            return name().empty(); 
        }
        
        const std::string& name() const { 
            return name_; 
        }
        std::string full_name() const {
            std::string res ;
            if( isConst() ) res += "const " ;
            res += name() ;
            if( isReference() ) res += "&" ;
            return res ;
        }
        
        bool isVoid() const {
            return name() == "void"; 
        }
        bool isConst() const { 
            return isConst_; 
        }
        bool isReference() const {
            return isReference_; 
        }
        
        friend std::ostream& operator<<(std::ostream& os, const Type& type); 
        
    private:
        std::string name_;
        bool isConst_;
        bool isReference_;
    };
     
    
}

#endif
