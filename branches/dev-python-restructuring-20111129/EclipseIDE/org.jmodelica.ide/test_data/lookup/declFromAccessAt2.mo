// Just qq
// the line above identifies expected output of test case

// standard positive test for component access

model m

	model q
		Real r;
	end q;
	
	q qq;
	
equation
	
	q^q = q(r = 10);
	
end m;
