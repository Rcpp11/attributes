#ifndef ATTRIBUTES_TYPES_TYPES_H
#define ATTRIBUTES_TYPES_TYPES_H

namespace attributes {
    // Known attribute names & parameters
    const char * const kExportAttribute = "export";
    const char * const kDependsAttribute = "depends";
    const char * const kPluginsAttribute = "plugins";
    const char * const kInterfacesAttribute = "interfaces";
    const char * const kInterfaceR = "r";
    const char * const kInterfaceCpp = "cpp";
}

#include <attributes/types/Type.h>
#include <attributes/types/Argument.h>
#include <attributes/types/Function.h>
#include <attributes/types/Param.h>
#include <attributes/types/Attribute.h>
#include <attributes/types/FunctionMap.h>
#include <attributes/types/SourceFileAttributes.h>

#endif
