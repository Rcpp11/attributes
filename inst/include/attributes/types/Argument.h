#ifndef ATTRIBUTES_TYPES_ARGUMENT_H
#define ATTRIBUTES_TYPES_ARGUMENT_H
  
namespace attributes{

    class Argument {
    public:
        Argument() {}
        Argument(const std::string& name, 
                 const Type& type,
                 const std::string& defaultValue) 
            : name_(name), type_(type), defaultValue_(defaultValue) 
        {
        }
        
        bool empty() const { return type().empty(); }
        
        const std::string& name() const { return name_; }
        const Type& type() const { return type_; }
        const std::string& defaultValue() const { return defaultValue_; }
         
        friend std::ostream& operator<<(std::ostream& os, const Argument& argument); 
    
    private:
        std::string name_;
        Type type_;
        std::string defaultValue_;
    };
    
}

#endif
