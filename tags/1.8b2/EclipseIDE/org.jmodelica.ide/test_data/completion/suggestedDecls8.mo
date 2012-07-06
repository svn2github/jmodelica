// Just q
// line above is expected output

// test extends

model testCase7
	
	model q
		
		Real r;
	equation
		
		m.q = 10;
		
	end q;
	
end testCase7;
model testCase8
	
	testCase7^ r;
	
end testCase8;

