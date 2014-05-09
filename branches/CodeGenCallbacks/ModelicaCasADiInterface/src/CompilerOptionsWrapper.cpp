/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
        rethrowJavaException(e);
    }
}
void CompilerOptionsWrapper::setBooleanOption(std::string opt, bool val) {
    try 
    {
    optr.setBooleanOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }
}
void CompilerOptionsWrapper::setIntegerOption(std::string opt, int val) {
    try 
    {
    optr.setIntegerOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }
}
void CompilerOptionsWrapper::setRealOption(std::string opt, double val) {
    try 
    {
    optr.setRealOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }
}

void CompilerOptionsWrapper::addStringOption(std::string opt, std::string val) {
    try 
    {
    optr.addStringOption(StringFromUTF(opt.c_str()), StringFromUTF(val.c_str()));
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }    
}
void CompilerOptionsWrapper::addBooleanOption(std::string opt, bool val) {
    try 
    {
    optr.addBooleanOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }
}
void CompilerOptionsWrapper::addIntegerOption(std::string opt, int val) {
    try 
    {
    optr.addIntegerOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }
}
void CompilerOptionsWrapper::addRealOption(std::string opt, double val) {
    try 
    {
    optr.addRealOption(StringFromUTF(opt.c_str()), val);
    }
    catch (JavaError e) 
    {
        rethrowJavaException(e);
    }
}


void CompilerOptionsWrapper::print(std::ostream& os) const { os << "CompilerOptionsWrapper(" << env->toString(optr.this$) << ")"; }
}; // End namespace
