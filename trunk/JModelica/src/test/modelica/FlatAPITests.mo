package FlatAPITests
	model Test1
		Real x[2];
		parameter Real p = 4;
		parameter Integer n1=1,n2=2;
	equation
		x[n1] = 3;
		x[n2] = 4;	
	end Test1;
	
	model Test2
		parameter Integer N = 2;
		Real x[N];
		Real y[N];
		parameter Real p = 4;
		parameter Integer n1=1,n2=2;
	equation
		x[n1] = 3;
		x[n2] = 4;	
	end Test2;

    model Test3
  		Real x,y,z,v;
  		parameter Real p=3;
    equation
        x=4+p;
        x+y+z=v;
        v+z=x;
        y=x; 
    end Test3;

end FlatAPITests;