#ifndef ATTRIBUTES_GEN_ExportsGenerator_H
#define ATTRIBUTES_GEN_ExportsGenerator_H

namespace attributes{

    // Class to manage and dispatch to a list of generators
    class ExportsGenerators {
    public:
        typedef std::vector<ExportsGenerator*>::iterator Itr;
        
        ExportsGenerators() {}
        virtual ~ExportsGenerators(); 
        
        void add(ExportsGenerator* pGenerator); 
        
        void writeBegin(); 
        void writeFunctions(const SourceFileAttributes& attributes,
                            bool verbose); 
        void writeEnd(); 
        
        // Commit and return a list of the files that were updated
        std::vector<std::string> commit(
                                const std::vector<std::string>& includes); 
        
        // Remove and return a list of files that were removed
        std::vector<std::string> remove(); 
                 
    private:
        // prohibit copying
        ExportsGenerators(const ExportsGenerators&);
        ExportsGenerators& operator=(const ExportsGenerators&); 
        
    private:
        std::vector<ExportsGenerator*> generators_;
    };

}

#endif
