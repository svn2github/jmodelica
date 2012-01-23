#ifndef FMIUNITIMPL_H
#define FMIUNITIMPL_H

#include <jm_vector.h>
#include <jm_named_ptr.h>
#include "fmiModelDescription.h"
#include "fmiXMLParser.h"

/* Structure encapsulating base unit information */

struct fmiDisplayUnit {
    fmiReal gain;
    fmiReal offset;
    fmiUnit* baseUnit;
    char displayUnit[1];
};

struct fmiUnit {
        jm_vector(jm_voidp) displayUnits;
        char baseUnit[1];
};

struct fmiUnitDefinitions {
    jm_vector(jm_named_ptr) definitions;
};

fmiUnit* fmiXMLGetUnit(fmiXMLParserContext *context, jm_vector(char)* name, int sorted);

#endif /* FMIUNITIMPL_H */
