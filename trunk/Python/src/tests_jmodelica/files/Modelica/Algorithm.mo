package Algorithm "Some tests for algorithms" 
model AlgoTest1
	Boolean b;
	Integer i;
	Real r;
algorithm
	b := i >= 2 and i < 4;
equation
	r = time*time + 1;
	i = integer(r);
end AlgoTest1;

model AlgoTest2
	Real x;
	Real y(start=0);
	Real z(start=0);
	Real a(start=0.05);
algorithm
	x := der(y);
	if x < 0.2 then
		x := -1;
	end if;
	while a < x loop
		a := a + 0.01;
	end while;
equation
	der(y) = time;
	der(z) = x;
end AlgoTest2;

model AlgoTest3
	function f
		input Real a;
		input Real b;
		output Real o;
	algorithm
		o := sqrt(a*a + b*b);
	end f;

	constant Integer is[10] = {3,6,4,2,-1,8,-10,10,-20,37};
	Integer n;
	Real r;
algorithm
	n := integer(time*10);
	for i in is loop
		n := n + 1;
	end for;
algorithm
	for i in is loop
		r := f(r,i) / n;
	end for;
end AlgoTest3;

model AlgoTest4
	Real x(start = 1);
	Real y(start = 0);
	discrete Real d;
initial equation
	d = -1;
algorithm
	assert(x > y,"Fail");
	if y > 1.4 then
		terminate("Stop");
	end if;
equation
	der(x) = y;
	der(y) = 1;
	when y > 1.5 then
		d = x - 0.5;
	end when;
end AlgoTest4;

end Algorithm;
