#include <iostream>
#include <string>
#include <vector>
#include <stdlib.h>
#include "initjcc.h" // for env
#include "JCCEnv.h"
#include "ifcasadi/MX.h"
#include "ifcasadi/ifcasadi.h"
#include "java/lang/String.h"


void setUpJVM() {
    std::cout << "Creating JVM" << std::endl;
    jint version = initJVM();
    std::cout << "Created JVM, JNI version " << (version>>16) << "." << (version&0xffff) << '\n' << std::endl;
}

void tearDownJVM() {
    // Make sure that no JCC proxy objects live in this scope, as they will then  
    // try to free their java objects after the JVM has been destroyed. 
    std::cout << "\nDestroying JVM" << std::endl;
    destroyJVM();
    std::cout << "Destroyed JVM" << std::endl;
}


int main(int argc, char ** argv)
{
  
  // Start java vitual machine  
  setUpJVM();
  {
      {ifcasadi::MX* myMX = new ifcasadi::MX();
      delete myMX;}
      {ifcasadi::MX* myMX2 = new ifcasadi::MX();
      delete myMX2;}
      ifcasadi::ifcasadi x;
      java::lang::String s;
      ifcasadi::MX symX = ifcasadi::ifcasadi::msym(s);

  }
  tearDownJVM();
  std::cout<<"DONE\n";  
  return 0;
}
