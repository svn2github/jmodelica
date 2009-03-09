# Constraints
subject to CONSTR_0  {_i in FE, _j in CP} : -(0.4)-(x1[_i,_j])<=0.0;
subject to CONSTR_1  {_i in FE, _j in CP} : -(0.1)-(u[_i,_j])<=0.0;
subject to CONSTR_2  {_i in FE, _j in CP} : u[_i,_j]-(0.75)<=0.0;

