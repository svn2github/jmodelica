// Just x, y
// line above is expected output

// test redeclare
	
model m
	model A
	  Real x=1;
	end A;
   
	model B
	 Real x=2;
	 Real y=3;
	end B;
   
	 package C
	   replaceable A a;
	 end C;
   
	 C c(redeclare B a);

	
equation

	c.a^ = 10;
		
end m;