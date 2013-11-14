#ifndef ATTRIBUTES_GEN_CppPackageIncludeGenerator_H
#define ATTRIBUTES_GEN_CppPackageIncludeGenerator_H

namespace attributes{

    // Class which manages generating PackageName_RcppExports.h header file
    class CppPackageIncludeGenerator : public ExportsGenerator {
    public:
        CppPackageIncludeGenerator(const std::string& packageDir, 
                                   const std::string& package,
                                   const std::string& fileSep);
            
        virtual void writeBegin() {}
        virtual void writeEnd(); 
        virtual bool commit(const std::vector<std::string>& includes); 
        
    private:  
        virtual void doWriteFunctions(const SourceFileAttributes& attributes,
                                      bool verbose) {}
        std::string getHeaderGuard() const; 
        
    private:
        std::string includeDir_;
    };

    
}

#endif
