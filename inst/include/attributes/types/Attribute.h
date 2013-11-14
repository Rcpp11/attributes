#ifndef ATTRIBUTES_TYPES_Attribute_H
#define ATTRIBUTES_TYPES_Attribute_H
  
namespace attributes{
       
    // Attribute (w/ optional params and signature of function it qualifies) 
    class Attribute {
    public:
        Attribute() {}
        Attribute(const std::string& name, 
                  const std::vector<Param>& params,
                  const Function& function,
                  const std::vector<std::string>& roxygen)
            : name_(name), params_(params), function_(function), roxygen_(roxygen)
        {
        }
        
        bool empty() const { return name().empty(); }
        
        const std::string& name() const { return name_; }
        
        const std::vector<Param>& params() const { return params_; }
         
        Param paramNamed(const std::string& name) const; 
         
        bool hasParameter(const std::string& name) const {
            return !paramNamed(name).empty();
        }
        
        const Function& function() const { return function_; }
        
        bool isExportedFunction() const {
            return (name() == kExportAttribute) && !function().empty();
        }
        
        std::string exportedName() const {   
            if (!params().empty())
                return params()[0].name();
            else
                return function().name();
        }
        
        const std::vector<std::string>& roxygen() const { return roxygen_; }
        
        std::ostream& operator<<(std::ostream& os, const Attribute& attribute); 

    private:
        std::string name_;
        std::vector<Param> params_;
        Function function_;
        std::vector<std::string> roxygen_;
    };
    
    
}

#endif
