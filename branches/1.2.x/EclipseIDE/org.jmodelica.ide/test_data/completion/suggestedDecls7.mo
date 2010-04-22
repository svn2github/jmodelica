// Just r
// above line is expected output

// test top-level qualified access to self

model testCase7
	
	model q
		
		Real r;
	equation
		
		testCase7.q^ = 10;
		
	end q;
	
end testCase7;

