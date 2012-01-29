#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "fmiModelDescription.h"

void print_int(int i,void* data) {
    printf("%d\n", i);
}

void print_dbl(double d,void* data) {
    printf("%g\n", d);
}

void printTypeInfo(fmiVariableType* vt) {
    const char* quan;

    if(!vt) {
        printf("No type definition\n");
        return;
    }

    quan = fmiGetTypeQuantity(vt);

    printf("Type %s\n description: %s\n",  fmiGetTypeName(vt), fmiGetTypeDescription(vt));

    printf("Base type: %s\n", fmiConvertBaseTypeToString(fmiGetBaseType(vt)));

    if(quan) {
        printf("Quantity: %s\n", quan);
    }
    switch(fmiGetBaseType(vt)) {
    case fmiBaseTypeReal: {
        fmiRealType* rt = fmiGetTypeAsReal(vt);
        fmiReal min = fmiGetRealTypeMin(rt);
        fmiReal max = fmiGetRealTypeMax(rt);
        fmiReal nom = fmiGetRealTypeNominal(rt);
        fmiUnit* u = fmiGetRealTypeUnit(rt);
        fmiDisplayUnit* du = fmiGetTypeDisplayUnit(rt);

        printf("Min %g, max %g, nominal %g\n", min, max, nom);

        if(u) {
            printf("Unit: %s\n", fmiGetUnitName(u));
        }
        if(du) {
            printf("Display unit: %s, gain: %g, offset: %g, is relative: %s",
                   fmiGetDisplayUnitName(du),
                   fmiGetDisplayUnitGain(du),
                   fmiGetDisplayUnitOffset(du),
                   fmiGetRealTypeIsRelativeQuantity(rt)?"yes":"no"
                   );
        }

        break;
    }
    case fmiBaseTypeInteger:{
        fmiIntegerType* it = fmiGetTypeAsInteger(vt);
        int min = fmiGetIntegerTypeMin(it);
        int max = fmiGetIntegerTypeMax(it);
        printf("Min %d, max %d\n", min, max);
        break;
    }
    case fmiBaseTypeBoolean:{
        break;
    }
    case fmiBaseTypeString:{
        break;
    }
    case fmiBaseTypeEnumeration:{
        fmiEnumerationType* et = fmiGetTypeAsEnum(vt);
        int min = fmiGetEnumTypeMin(et);
        int max = fmiGetEnumTypeMax(et);
        printf("Min %d, max %d\n", min, max);
        {
            size_t ni, i;
            ni = fmiGetEnumTypeSize(et);
            printf("There are %d items \n",ni);
            for(i = 0; i < ni; i++) {
                printf("[%d] %s (%s) \n", i+1, fmiGetEnumTypeItemName(et, i), fmiGetEnumTypeItemDescription(et, i));
            }
        }
        break;
    }
    default:
        printf("Error in fmiGetBaseType()\n");
    }

}

void printVariableInfo(fmiVariable* v) {
    printf("Variable name: %s\n", fmiGetVariableName(v));
    printf("Description: %s\n", fmiGetVariableDescription(v));
    printf("VR: %d\n", fmiGetVariableValueReference(v));
    printf("Variability: %s\n", fmiVariabilityToString(fmiGetVariability(v)));
    printf("Causality: %s\n", fmiCausalityToString(fmiGetCausality(v)));

    printTypeInfo(fmiGetVariableDeclaredType(v));
    if(fmiGetVariableBaseType(v) == fmiBaseTypeReal) {
        fmiRealVariable *rv = fmiGetVariableAsReal(v);
        fmiUnit * u = fmiGetRealVariableUnit(rv);
        fmiDisplayUnit * du = fmiGetRealVariableDisplayUnit(rv);
        printf("Unit: %s, display unit: %s\n", u ? fmiGetUnitName(u):0, du?fmiGetDisplayUnitName(du):0);
    }

    if(fmiGetVariableHasStart(v)) {
        printf("There is a start value, fixed attribute is '%s'\n", (fmiGetVariableIsFixed(v))?"true":"false");

        switch(fmiGetVariableBaseType(v)) {
        case fmiBaseTypeReal: {
            fmiRealVariable *rv = fmiGetVariableAsReal(v);
            printf("start =%g\n", fmiGetRealVariableStart(rv));
            break;
        }
        case fmiBaseTypeInteger:{
            printf("start =%d\n", fmiGetIntegerVariableStart(fmiGetVariableAsInteger(v)));
            break;
        }
        case fmiBaseTypeBoolean:{
            printf("start = %d\n", fmiGetBooleanVariableStart(fmiGetVariableAsBoolean(v)));
            break;
        }
        case fmiBaseTypeString:{
            printf("start = '%s'\n", fmiGetStringVariableStart(fmiGetVariableAsString(v)));
            break;
        }
        case fmiBaseTypeEnumeration:{
            printf("start = %d\n", fmiGetEnumVariableStart(fmiGetVariableAsEnumeration(v)));
            break;
        }
        default:
            printf("Error in fmiGetBaseType()\n");
        }
    }
}

int main(int argc, char* argv[]) {

    fmiModelDescription* md = fmiAllocateModelDescription( 0 );

    if(!md) abort();

    if(fmiParseXML(md, argv[1])) {
        printf("Error parsing XML file %s:%s\n", argv[1], fmiGetLastError(md));
        abort();
    }

    printf("Model name: %s\n", fmiGetModelName(md));
    printf("Model identifier: %s\n", fmiGetModelIdentifier(md));
    printf("Model GUID: %s\n", fmiGetGUID(md));
    printf("Description: %s\n", fmiGetDesciption(md));
    printf("Author: %s\n", fmiGetAuthor(md));
    printf("FMI Version: %s\n", fmiGetModelStandardVersion(md));
    printf("Generation tool: %s\n", fmiGetGenerationTool(md));
    printf("Generation date and time: %s\n", fmiGetGenerationDateAndTime(md));
    printf("Version: %s\n", fmiGetModelVersion(md));
    printf("Naming : %s\n", fmiNamingConvensionToString(fmiGetNamingConvension(md)));

    printf("NumberOfContinuousStates = %d\n", fmiGetNumberOfContinuousStates(md));
    printf("NumberOfEventIndicators = %d\n", fmiGetNumberOfEventIndicators(md));

    printf("Default experiment start = %g, end = %g, tolerance = %g\n",
           fmiGetDefaultExperimentStartTime(md),
           fmiGetDefaultExperimentStopTime(md),
           fmiGetDefaultExperimentTolerance(md));
    {
        fmiVendorList* vl = fmiGetVendorList(md);
        size_t i, nv = fmiGetNumberOfVendors(vl);
        printf("There are %d tool annotation records \n", nv);
        for( i = 0; i <= nv; i++) {
            fmiVendor* vendor = fmiGetVendor(vl, i);
            if(!vendor) {
                printf("Error getting vendor for index %d\n", i);
                break;
            }
            printf("Vendor name [%d] %s", i, fmiGetVendorName(vendor));
            {
                size_t j, na = fmiGetNumberOfVendorAnnotations(vendor);

                for(j = 0; j<= na; j++) {
                    fmiAnnotation* a = fmiGetVendorAnnotation(vendor, j);
                    if(!a) {
                        printf("Error getting vendor for index %d (%s)\n", j, fmiGetLastError(md));
                        break;
                    }

                    printf("Annotation: %s = %s", fmiGetAnnotationName(a), fmiGetAnnotationValue(a));
                }
            }
        }
    }
    {
        fmiUnitDefinitions* ud = fmiGetUnitDefinitions(md);
        if(ud) {
            size_t  i, nu = fmiGetUnitDefinitionsNumber(ud);
            printf("There are %d different units used \n", nu);

            for(i = 0; i <= nu; i++) {
                fmiUnit* u = fmiGetUnit(ud, i);
                if(!u) {
                    printf("Error getting unit for index %d (%s)\n", i, fmiGetLastError(md));
                    break;
                }
                printf("Unit [%d] is %s, it has %d display units\n", i, fmiGetUnitName(u), fmiGetUnitDisplayUnitsNumber(u));
            }
        }
        else
            printf("Error getting unit definitions (%s)\n", fmiGetLastError(md));
    }
    {
        fmiTypeDefinitions* td = fmiGetTypeDefinitions(md);
        if(td) {
            {
                size_t i, ntd = fmiGetTypeDefinitionsNumber(td);
                printf("There are %d defs\n", ntd);
                for(i = 0; i <= ntd; i++) {
                    fmiVariableType* vt = fmiGetTypeDefinition(td, i);
                    if(!vt) {
                        printf("Error getting vartype for index %d (%s)\n", i, fmiGetLastError(md));
                        break;
                    }
                    printTypeInfo(vt);
                }
            }
        }
        else
            printf("Error getting type definitions (%s)\n", fmiGetLastError(md));
    }
    {
        size_t nv, i;
        fmiVariableList* vl = fmiGetVariableList(md);
        assert(vl);
        nv = fmiGetVariableListSize(vl);
        printf("There are %d variables in total \n",nv);
        for(i = 0; i < nv; i++) {
            fmiVariable* var = fmiGetVariable(vl, i);
            printVariableInfo(var);
        }
    }
    return 0;
}
