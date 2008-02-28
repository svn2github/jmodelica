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
		parameter Real p = 4;
		parameter Integer n1=1,n2=2;
	equation
		x[n1] = 3;
		x[n2] = 4;	
	end Test2;



end FlatAPITests;