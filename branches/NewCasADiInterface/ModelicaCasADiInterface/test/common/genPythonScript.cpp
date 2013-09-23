#include <iostream>
#include <sstream>
#include <fstream>
#include <ctime>
#include <numeric>

#include <Model.hpp>
#include <OptimizationProblem.hpp>
#include <Variable.hpp>


using std::vector; using std::cout; using std::endl;
  
void genScript(ModelicaCasADi::OptimizationProblem &myOptProblem, int numSteps, vector<double> &sol) {
    
    ModelicaCasADi::Model* model = myOptProblem.getModel();
    vector<int> nVar(4,0);
    vector<int> nVarCsum;
    
    // Number of vars. 
    nVar[0] = model->getVariableByKind(Model::DIFFERENTIATED).size();
    nVar[1] = model->getVariableByKind(Model::DERIVATIVE).size();
    nVar[2] = model->getVariableByKind(Model::REAL_ALGEBRAIC).size();
    nVar[3] = model->getVariableByKind(Model::REAL_INPUT).size();
    
    nVarCsum.push_back(0);
    std::partial_sum(nVar.begin(), nVar.end()-1, std::back_inserter(nVarCsum));
    int totalVars = nVarCsum[3]+nVar[3];
    int totalNumNlpVars = (numSteps+1)*totalVars;
    
    //// Create Python script to plot the solution
    std::ofstream file;
    std::string filename = "res_opt.py";
    file.open(filename.c_str());
    file << "# Results file from " __FILE__ << endl;
    file << "# Generated " __DATE__ " at " __TIME__ << endl;
    file << endl;
    file << "import numpy as np \nimport matplotlib.pyplot as plt" << endl;
    file << "analytic_time = np.linspace(" << myOptProblem.getStartTime().getValue() <<"," << myOptProblem.getFinalTime().getValue() << ", 200)" << endl;

    file<<"z_opt = np.array([[";
    for(int i = 0; i < sol.size();  ++i){
        if(i+1< sol.size()) {
            file <<sol[i] <<",";
        } else {
            file <<sol[i] <<"]]).T"<<endl;
        }
    }
    
    file<<"time = np.linspace("<<myOptProblem.getStartTime().getValue() <<","<<myOptProblem.getFinalTime().getValue() <<","<< numSteps + 1<<")"<<endl;
    std::ostringstream oss;
    vector<std::string> outVecs;
    for(int i = 0; i < nVar.size(); ++i){
        for(int j = 0; j < nVar[i]; j++){
            std::string base = (i == 0? "x" : (i==1? "dx" : (i==2? "z" : "u")));
            oss << base << j;
            outVecs.push_back(oss.str());
            oss.str("");
        }
    }
    int index = 0;
    for(int i = 0; i < nVar.size(); ++i){
        for(int j = 0; j < nVar[i]; j++){
            std::string base = outVecs[index];
            oss << base << " = z_opt["<<index<<":"<<totalNumNlpVars<<":"<<totalVars<<"]";
            file << oss.str()<<endl;
            oss.str("");
            index++;
        }
    }
    
    file<<"plt.close(1)"<<endl;
    file<<"plt.figure(1)"<<endl;
    file<<"plt.hold(True)"<<endl;
    
    index = 0;
    for(int i = 0; i < nVar.size(); ++i){
        for(int j = 0; j < nVar[i]; j++){
            std::string base = outVecs[index];
            oss <<"plt.plot(time, "<< base <<")";
            file << oss.str()<<endl;
            oss.str("");
            index++;
        }
    }
    
    index = 0;
    oss<<"plt.legend([";
    for(int i = 0; i < nVar.size(); ++i){
        for(int j = 0; j < nVar[i]; j++){
            std::string base = outVecs[index];
            oss <<"'"<< base <<(index==(totalVars-1)? "'])": "', ");
            index++;
        }
    }
    file << oss.str()<<endl;
    file<<"plt.xlabel('$t$')"<<endl;
    file<<"plt.show()"<<endl;
    file.close();
    cout << "Results saved to \"" << filename << "\"" << endl;
}
























