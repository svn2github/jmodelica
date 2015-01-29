model Terminate
	Real x(start=0);
equation
	der(x) = 1;
	if x > 0.5 then
		terminate("Time to fail...");
	end if;
end Terminate;
