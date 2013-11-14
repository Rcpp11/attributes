#ifndef ATTRIBUTES_GEN_RExportsGenerator_H
#define ATTRIBUTES_GEN_RExportsGenerator_H

namespace attributes{

    // Class which manages generator RcppExports.R
    class RExportsGenerator : public ExportsGenerator {
    public:
        RExportsGenerator(const std::string& packageDir,
                          const std::string& package,
                          const std::string& fileSep);
        
        virtual void writeBegin() {}
        virtual void writeEnd(); 
        virtual bool commit(const std::vector<std::string>& includes); 
        
    private:
        virtual void doWriteFunctions(const SourceFileAttributes& attributes,
                                      bool verbose);

    };
    
}

#endif
