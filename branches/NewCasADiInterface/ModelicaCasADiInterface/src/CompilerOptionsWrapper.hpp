#ifndef _MODELICACASADI_COMPILER_OPTIONS_WRAPPER
#define _MODELICACASADI_COMPILER_OPTIONS_WRAPPER
#include <string>
#include <iostream>

#include "Printable.hpp"
#include "org/jmodelica/util/OptionRegistry.h"

namespace ModelicaCasADi 
{
class CompilerOptionsWrapper: public Printable {
    public:
        CompilerOptionsWrapper(); 
        void setStringOption(std::string opt, std::string val);
        void setBooleanOption(std::string opt, bool val);
        void setIntegerOption(std::string opt, int val);
        void setRealOption(std::string opt, double val);
        
        void addStringOption(std::string opt, std::string val);
        void addBooleanOption(std::string opt, bool val);
        void addIntegerOption(std::string opt, int val);
        void addRealOption(std::string opt, double val);
        
        org::jmodelica::util::OptionRegistry getOptionRegistry();
        
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
    private:
        org::jmodelica::util::OptionRegistry optr;
};
inline CompilerOptionsWrapper::CompilerOptionsWrapper() : optr() {}
inline org::jmodelica::util::OptionRegistry CompilerOptionsWrapper::getOptionRegistry() { return optr; }
}; // End namespace
#endif
