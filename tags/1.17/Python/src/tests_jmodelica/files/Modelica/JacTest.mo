package JacFuncTests

    model BasicJacobianTest
      Real x1;
      Real x2;
      
      equation
        der(x1) = x1     + 2 * x2 + 7 * x2^2;
        der(x2) = x1 * 3 + 4 * x2 + 11 * x1^1;
        
    end BasicJacobianTest;

	model sparseFunc1
		function F1
      		input Real x1[3];
      		input Real x2;
      		input Real x3;
      		output Real y1;
      		output Real y2[3];
    	algorithm
      		y1 := x1[1]+x2;
      		y2 := {x1[1],x2,x3} + x1;
    	end F1;
    	Real y[3](start={1,2,3});
    	Real a(start = 3);
    	Real q = 3;
   		Real x[3](start={3,2,2});
	equation
    	(a,y) = F1(der(x)+x,q,a);
    	der(x) = -x;
	end sparseFunc1;

	model sparseFunc2
		function F1
      		input Real x1[3];
      		input Real x2;
      		input Real x3;
      		output Real y1;
      		output Real y2[3];
   		algorithm
      		y1 := x1[1]+x2;
      		y2 := {x1[1],x2,x3} + x1;
    	end F1;
    	Real y[3](start={1,2,3});
    	Real a(start = 3);
    	Real q = 3;
    	input Real x[3](start={3,2,2});
	equation
    	(a,y) = F1(x,q,a);
	end sparseFunc2;
	
	model sparseFunc3
		function F1
      	input Real x1[3];
      		input Real x2;
      		input Real x3;
      		output Real y1;
      		output Real y2[3];
    	algorithm
      		y1 := x1[1]+x2;
      		y2 := {x1[1],x2,x3} + x1;
    	end F1;
    	Real y[3](start={1,2,3});
    	Real a(start = 3);
    	Real q = 3;
    	parameter Real x[3](start={3,2,2});
    	parameter Real z(start=1);
    	parameter Real w(start =3);
	equation
    	(a,y) = F1(x,q,a);
    end sparseFunc3;
end JacFuncTests;
