#include <iostream>
#include "OptimizationProblem.hpp"
#include <string>
#include <vector>
#include "Ref.hpp"
#include "CompilerOptionsWrapper.hpp"
#include "transferOptimica.hpp"
#include "sharedTransferFunctionality.hpp"

int main(int argc, char ** argv)
{
  //std::string className("CombinedCycleStartup.Startup6Reference");
  std::string className("VDP_pack.VDP_Opt2");
  //std::cout<<"Type class name: \n";
  //std::cin>>className;
  //std::string modelicaFile("./CombinedCycle.mo");
  //std::cout<<"Type modelica File Name: \n";
  //std::cin>>modelicaFile;
  std::string optimicaFile("./VDP.mop");
  //std::string optimicaFile("./CombinedCycleStartup.mop");
  //std::cout<<"Type Optimica File Name: \n";
  //std::cin>>optimicaFile;
  
  std::vector<std::string> files;
  //files.push_back(modelicaFile);
  files.push_back(optimicaFile);
  std::string log_level = "warning";
  
  // Start java vitual machine  
  setUpJVM();
  // Model
  ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> optProblem = new ModelicaCasADi::OptimizationProblem();
  // CompilerOptions
  ModelicaCasADi::Ref<ModelicaCasADi::CompilerOptionsWrapper> options = new ModelicaCasADi::CompilerOptionsWrapper();
  
  ModelicaCasADi::transferOptimizationProblem(optProblem, className, files, options, log_level);  
  
  std::cout<<optProblem<<"\n";
  // Stops virtual machine
  tearDownJVM();
  std::cout<<"DONE\n";  
  return 0;
}
