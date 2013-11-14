#ifndef ATTRIBUTES_GEN_CppExportsGenerator_H
#define ATTRIBUTES_GEN_CppExportsGenerator_H

namespace attributes{

    // Class which manages generating RcppExports.cpp
    class CppExportsGenerator : public ExportsGenerator {
    public:
        explicit CppExportsGenerator(const std::string& packageDir, 
                                     const std::string& package,
                                     const std::string& fileSep);
         
        virtual void writeBegin() {}; 
        virtual void writeEnd();
        virtual bool commit(const std::vector<std::string>& includes); 
        
    private:
        virtual void doWriteFunctions(const SourceFileAttributes& attributes,
                                      bool verbose);
                                    
        std::string registerCCallable(size_t indent,
                                      const std::string& exportedName,
                                      const std::string& name) const;
        
    private:
        std::vector<Attribute> cppExports_;
    };
    
}

#endif
