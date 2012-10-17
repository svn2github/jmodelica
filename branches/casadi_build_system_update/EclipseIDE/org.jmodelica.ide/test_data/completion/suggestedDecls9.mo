// Just A, B
// line above is expected output

// test extends

model ClassTest5
	
	model M1
		model A
			Real x=2;
		end A;
	end M1;
	
	model M2 extends M1;
		model B extends M1.A;
			Real y=3;
		end B;
	end M2;
	
	M2^ m2;
		
		
end ClassTest5;
