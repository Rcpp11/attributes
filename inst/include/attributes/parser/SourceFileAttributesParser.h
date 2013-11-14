#ifndef ATTRIBUTES_PARSER_SourceFileAttributesParser_H
#define ATTRIBUTES_PARSER_SourceFileAttributesParser_H

namespace attributes {

    // Class used to parse and return attribute information from a source file
    class SourceFileAttributesParser : public SourceFileAttributes {
    public:
        explicit SourceFileAttributesParser(const std::string& sourceFile);
        
    private:
        // prohibit copying
        SourceFileAttributesParser(const SourceFileAttributesParser&);
        SourceFileAttributesParser& operator=(const SourceFileAttributesParser&); 
        
    public:
        // implemetnation of SourceFileAttributes interface
        virtual const std::string& sourceFile() const { 
            return sourceFile_; 
        }
        virtual const_iterator begin() const { return attributes_.begin(); }
        virtual const_iterator end() const { return attributes_.end(); }
        
        virtual const std::vector<std::string>& modules() const
        {
            return modules_;
        }
        
        virtual const std::vector<std::vector<std::string> >& roxygenChunks() const {
            return roxygenChunks_;                                                    
        }
        
        virtual bool hasGeneratorOutput() const 
        { 
            return !attributes_.empty() || 
                   !modules_.empty() ||
                   !roxygenChunks_.empty(); 
        }
        
        virtual bool hasInterface(const std::string& name) const {
            
            for (const_iterator it=begin(); it != end(); ++it) {
                if (it->name() == kInterfacesAttribute) {
                    return it->hasParameter(name);
                }
            }
            
            // if there's no interfaces attrbute we default to R
            if (name == kInterfaceR)
                return true;
            else
                return false;            
        }
        
        // Get lines of embedded R code
        const std::vector<std::string>& embeddedR() const {
            return embeddedR_;
        }
         
    private:
    
        // Parsing helpers
        Attribute parseAttribute(const std::vector<std::string>& match,
                                 int lineNumber); 
        std::vector<Param> parseParameters(const std::string& input); 
        Function parseFunction(size_t lineNumber); 
        std::string parseSignature(size_t lineNumber);
        std::vector<std::string> parseArguments(const std::string& argText); 
        Type parseType(const std::string& text); 
        
        // Validation helpers
        bool isKnownAttribute(const std::string& name) const; 
        void attributeWarning(const std::string& message, 
                              const std::string& attribute,
                              size_t lineNumber); 
        void attributeWarning(const std::string& message, size_t lineNumber); 
        void rcppExportWarning(const std::string& message, size_t lineNumber);
        void rcppExportNoFunctionFoundWarning(size_t lineNumber); 
        void rcppExportInvalidParameterWarning(const std::string& param, 
                                               size_t lineNumber); 
        void rcppInterfacesWarning(const std::string& message,
                                   size_t lineNumber);
         
    private:
        std::string sourceFile_;
        CharacterVector lines_;
        std::vector<Attribute> attributes_;
        FunctionMap functionMap_ ;
        std::vector<std::string> modules_;
        std::vector<std::string> embeddedR_;
        std::vector<std::vector<std::string> > roxygenChunks_; 
        std::vector<std::string> roxygenBuffer_;
    };

} // namespace attributes

#endif
