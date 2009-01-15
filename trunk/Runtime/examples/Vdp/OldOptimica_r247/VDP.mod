#Model description

param TIME = 5.0;

#Grid parameters
param NFE >=1 integer;
param NCP >=1 integer;
set FE := {1..NFE};
set CP := {1..NCP};
set CPP := {0..NCP};

#Collocation matrices
param _A{CPP,CPP}; #Collocation matrix
param _p{CP};      #Collocation points
param _w{CP};      #Quadrature weights
param _l0{CP};     #Lagrange pols evaluated at 0.0 for algebraic variables
param _H{FE} >=1/NFE, <=1/NFE;   #Finite element Lengths

#Bounds
param p1_lb;
param p1_ub;

#Parameters
var p1 >= p1_lb,  <= p1_ub;
param p2;
param p3;

#Derivative bounds

#Variables
var x1 {FE,CPP};
var x2 {FE,CPP};
var x3 {FE,CPP};
var w {FE,CP};
var u {FE,CP};
var time {FE,CPP};

#Derivatives
var DER_x1 {FE,CP} ;
var DER_x2 {FE,CP} ;
var DER_x3 {FE,CP} ;
var DER_time {FE,CP} ;

#Initial condition variables
param x1_0;
param x2_0;
param x3_0;
param w_0;
param u_0;
param time_0;

#Initial guess variables
param x1_ig;
param DER_x1_ig;
param x2_ig;
param DER_x2_ig;
param x3_ig;
param DER_x3_ig;
param w_ig;
param u_ig;
param time_ig;
param DER_time_ig;

#Element length constraint
#subject to CONSTR_FE: sum {_i in FE} _H[_i] = 1;

#Dynamic binding equation residuals

#Dynamic equation residuals
var DYN_RESID_1{_i in FE, _j in CP} = DER_x1[_i,_j]-((1-(x2[_i,_j]^2))*(x1[_i,_j])-(x2[_i,_j])+u[_i,_j]);
var DYN_RESID_2{_i in FE, _j in CP} = DER_x2[_i,_j]-((p1)*(x1[_i,_j]));
var DYN_RESID_3{_i in FE, _j in CP} = DER_x3[_i,_j]-((exp((p3)*(time[_i,_j])))*(x1[_i,_j]^2+x2[_i,_j]^2+u[_i,_j]^2));
var DYN_RESID_4{_i in FE, _j in CP} = w[_i,_j]-(x1[_i,_j]+x2[_i,_j]);
var DYN_RESID_5{_i in FE, _j in CP} = DER_time[_i,_j]-(1.0);

#Dynamic binding equations

#Dynamic equations
subject to DYN_CONSTR_1{_i in FE, _j in CP}: DYN_RESID_1[_i,_j] =0;
subject to DYN_CONSTR_2{_i in FE, _j in CP}: DYN_RESID_2[_i,_j] =0;
subject to DYN_CONSTR_3{_i in FE, _j in CP}: DYN_RESID_3[_i,_j] =0;
subject to DYN_CONSTR_4{_i in FE, _j in CP}: DYN_RESID_4[_i,_j] =0;
subject to DYN_CONSTR_5{_i in FE, _j in CP}: DYN_RESID_5[_i,_j] =0;

#Collocation equations
subject to FECOL_CONSTR_1{_i in FE, _j in CP}: DER_x1[_i,_j]=1/(TIME*_H[_i])*sum{_k in CPP}x1[_i,_k]*_A[_k,_j];
subject to FECOL_CONSTR_2{_i in FE, _j in CP}: DER_x2[_i,_j]=1/(TIME*_H[_i])*sum{_k in CPP}x2[_i,_k]*_A[_k,_j];
subject to FECOL_CONSTR_3{_i in FE, _j in CP}: DER_x3[_i,_j]=1/(TIME*_H[_i])*sum{_k in CPP}x3[_i,_k]*_A[_k,_j];
subject to FECOL_CONSTR_4{_i in FE, _j in CP}: DER_time[_i,_j]=1/(TIME*_H[_i])*sum{_k in CPP}time[_i,_k]*_A[_k,_j];

#Continuity equations
subject to FECONT_CONSTR_1{_i in FE diff{1}}: x1[_i-1,NCP]=x1[_i,0];
subject to FECONT_CONSTR_2{_i in FE diff{1}}: x2[_i-1,NCP]=x2[_i,0];
subject to FECONT_CONSTR_3{_i in FE diff{1}}: x3[_i-1,NCP]=x3[_i,0];
subject to FECONT_CONSTR_4{_i in FE diff{1}}: time[_i-1,NCP]=time[_i,0];

#Initial Conditions
subject to INITIAL_CONSTR_x1 : x1[1,0]=x1_0;
subject to INITIAL_CONSTR_x2 : x2[1,0]=x2_0;
subject to INITIAL_CONSTR_x3 : x3[1,0]=x3_0;
subject to INITIAL_CONSTR_time : time[1,0]=time_0;


