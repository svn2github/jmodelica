// Just c, r
// line above is expected output

// normal completion on class

model m
	package A
		model c
			
		end c;
		constant Real r;
	end A;

	A^ aa;
	

end m;