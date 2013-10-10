//JNI
#include "jni.h"
#include "jccutils.h"

#include "CompilerOptionsWrapper.hpp"
namespace ModelicaCasADi 
{
void CompilerOptionsWrapper::setStringOption(std::string opt, std::string val) {
    optr.setStringOption(StringFromUTF(opt.c_str()), StringFromUTF(val.c_str()));
}
void CompilerOptionsWrapper::setBooleanOption(std::string opt, bool val) {
    optr.setBooleanOption(StringFromUTF(opt.c_str()), val);
}
void CompilerOptionsWrapper::setIntegerOption(std::string opt, int val) {
    optr.setIntegerOption(StringFromUTF(opt.c_str()), val);
}
void CompilerOptionsWrapper::setRealOption(std::string opt, double val) {
    optr.setRealOption(StringFromUTF(opt.c_str()), val);
}

void CompilerOptionsWrapper::addStringOption(std::string opt, std::string val) {
    optr.addStringOption(StringFromUTF(opt.c_str()), StringFromUTF(val.c_str()));
}
void CompilerOptionsWrapper::addBooleanOption(std::string opt, bool val) {
    optr.addBooleanOption(StringFromUTF(opt.c_str()), val);
}
void CompilerOptionsWrapper::addIntegerOption(std::string opt, int val) {
    optr.addIntegerOption(StringFromUTF(opt.c_str()), val);
}
void CompilerOptionsWrapper::addRealOption(std::string opt, double val) {
    optr.addRealOption(StringFromUTF(opt.c_str()), val);
}


void CompilerOptionsWrapper::print(std::ostream& os) const { os << env->toString(optr.this$); }
}; // End namespace
