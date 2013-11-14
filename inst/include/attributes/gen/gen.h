#ifndef ATTRIBUTES_GEN_GEN_H
#define ATTRIBUTES_GEN_GEN_H

#include <attributes/gen/ExportsGenerator.h>
#include <attributes/gen/CppExportsGenerator.h>
#include <attributes/gen/CppExportsIncludeGenerator.h>
#include <attributes/gen/CppPackageIncludeGenerator.h>
#include <attributes/gen/RExportsGenerator.h>
#include <attributes/gen/ExportsGenerators.h>

namespace attributes{

    std::string generateRArgList(const Function& function);
    
    void generateCpp(std::ostream& ostr,
                     const SourceFileAttributes& attributes,
                     bool includePrototype,
                     bool cppInterface,
                     const std::string& contextId); 
    
}

#endif
