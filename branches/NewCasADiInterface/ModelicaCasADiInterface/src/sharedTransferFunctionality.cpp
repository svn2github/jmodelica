#include <iostream>
#include "initjcc.h"

#include "sharedTransferFunctionality.hpp"

#include "modelicacasadi_paths.h"

void setUpJVM() {
    std::cout << "Creating JVM" << std::endl;
    jint version = initJVM(MODELICACASADI_CLASSPATH, MODELICACASADI_LIBPATH);
    std::cout << "Created JVM, JNI version " << (version>>16) << "." << (version&0xffff) << '\n' << std::endl;
}

void tearDownJVM() {
    // Make sure that no JCC proxy objects live in this scope, as they will then  
    // try to free their java objects after the JVM has been destroyed. 
    std::cout << "\nDestroying JVM" << std::endl;
    destroyJVM();
    std::cout << "Destroyed JVM" << std::endl;
}


