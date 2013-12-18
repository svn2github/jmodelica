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
    nVar[0] = model->getVariables(Model::DIFFERENTIATED).size();
    nVar[1] = model->getVariables(Model::DERIVATIVE).size();
    nVar[2] = model->getVariables(Model::REAL_ALGEBRAIC).size();
    nVar[3] = model->getVariables(Model::REAL_INPUT).size();
    
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
























