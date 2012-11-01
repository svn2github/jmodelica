// Just x, y
// line above is expected output

// test component redeclare 

model ComponentTest4 
	
	model A
		Real x=1;
	end A;
	
	model B
		Real x=2;
		Real y=3;
	end B;
	
	model C
		replaceable A a;
	end C;
	
	C c(redeclare B a);
	
equation
	c.a^ = 10;
		
end ComponentTest4;
