// Just r
// line above is expected output

// no renamed imports should be suggested doing a quialified import

model m
	
	import SI = Modelica;
	Real r;
	
end m;

class m2
	
	m^ mm; // SI should not be included
	
end m2;