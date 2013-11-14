#ifndef ATTRIBUTES_TYPES_SourceFileAttributes_H
#define ATTRIBUTES_TYPES_SourceFileAttributes_H
  
namespace attributes{
       
    // interface to source file attributes
    class SourceFileAttributes
    {
    public:
        virtual ~SourceFileAttributes() {};
        virtual const std::string& sourceFile() const = 0;
        virtual bool hasInterface(const std::string& name) const = 0;
     
        typedef std::vector<Attribute>::const_iterator const_iterator;
        virtual const_iterator begin() const = 0;
        virtual const_iterator end() const = 0;
        
        virtual const std::vector<std::string>& modules() const = 0;
        
        virtual const std::vector<std::vector<std::string> >& roxygenChunks() const = 0;
                  
        virtual bool hasGeneratorOutput() const = 0;  
    };
    
    
}

#endif
