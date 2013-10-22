//JNI
#include "jni.h"
#include "jccutils.h"

#include "CompilerOptionsWrapper.hpp"
namespace ModelicaCasADi 
{
void CompilerOptionsWrapper::setStringOption(std::string opt, std::string val) {
    try 
    {
        optr.setStringOption(StringFromUTF(opt.c_str()), StringFromUTF(val.c_str()));
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}
void CompilerOptionsWrapper::setBooleanOption(std::string opt, bool val) {
    try 
    {
    optr.setBooleanOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}
void CompilerOptionsWrapper::setIntegerOption(std::string opt, int val) {
    try 
    {
    optr.setIntegerOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}
void CompilerOptionsWrapper::setRealOption(std::string opt, double val) {
    try 
    {
    optr.setRealOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}

void CompilerOptionsWrapper::addStringOption(std::string opt, std::string val) {
    try 
    {
    optr.addStringOption(StringFromUTF(opt.c_str()), StringFromUTF(val.c_str()));
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }    
}
void CompilerOptionsWrapper::addBooleanOption(std::string opt, bool val) {
    try 
    {
    optr.addBooleanOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}
void CompilerOptionsWrapper::addIntegerOption(std::string opt, int val) {
    try 
    {
    optr.addIntegerOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}
void CompilerOptionsWrapper::addRealOption(std::string opt, double val) {
    try 
    {
    optr.addRealOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
}


void CompilerOptionsWrapper::print(std::ostream& os) const { os << env->toString(optr.this$); }
}; // End namespace
