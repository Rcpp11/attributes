#ifndef ATTRIBUTES_TYPES_PARAM_H
#define ATTRIBUTES_TYPES_PARAM_H
  
namespace attributes{
       
    // Attribute parameter (with optional value)
    class Param {
    public:
        Param() {}
        explicit Param(const std::string& paramText);
        bool empty() const { return name().empty(); }
        
        const std::string& name() const { return name_; }
        const std::string& value() const { return value_; }
       
        std::ostream& operator<<(std::ostream& os, const Param& param); 
    
    private:
        std::string name_;
        std::string value_;
    };
    
    
}

#endif
