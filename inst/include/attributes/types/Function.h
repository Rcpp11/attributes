#ifndef ATTRIBUTES_TYPES_FUNCTION_H
#define ATTRIBUTES_TYPES_FUNCTION_H
  
namespace attributes{
    
    class Function {
    public:
        Function() {}
        Function(const Type& type,
                 const std::string& name, 
                 const std::vector<Argument>& arguments,
                 const std::string& source)
            : type_(type), name_(name), arguments_(arguments), source_(source)
        {
        }
        
        Function renamedTo(const std::string& name) const {
            return Function(type(), name, arguments(), source());
        }
        
        std::string signature() const { return signature(name()); }
        std::string signature(const std::string& name) const;
        
        bool isHidden() const {
            return name().find_first_of('.') == 0;
        }
        
        bool empty() const { return name().empty(); }
        
        const Type& type() const { return type_; }
        const std::string& name() const { return name_; }
        const std::vector<Argument>& arguments() const { return arguments_; }
        const std::string& source() const { return source_; }
        
        friend std::ostream& operator<<(std::ostream& os, const Function& function);
    
    private:
        Type type_;
        std::string name_;
        std::vector<Argument> arguments_;
        std::string source_;
    };
     
    
}

#endif
