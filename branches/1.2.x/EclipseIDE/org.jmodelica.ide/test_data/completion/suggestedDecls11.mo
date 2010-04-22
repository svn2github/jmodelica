// Just x, y
// line above is expected output

// test extends


model ComponentTest2
	model A
		Real x;
	end A;
	
	model B extends A;
		Real y;
		
	end B;

	B b;

equation
	
	b^ = 10;
	
end ComponentTest2;