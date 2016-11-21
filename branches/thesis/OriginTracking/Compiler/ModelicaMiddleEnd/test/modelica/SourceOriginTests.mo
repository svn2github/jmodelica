package SourceOriginTests
	model A
		Real x = sin(time);
	
	    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="A",
            description="",
            methodName="sourceDiagnostics",
            methodResult="
<html>
<head>

<style>
span {
	line-height: 20px;
	background: linear-gradient(0deg, black 1px, white 1px, transparent 1px);
	background-position: 0 100%;
}
.s1 {
	line-height: 24px;
	padding-bottom: 4px;
}
.s2 {
	line-height: 28px;
	padding-bottom: 8px;
}
.s3 {
	line-height: 32px;
	padding-bottom: 12px;
}
.s4 {
	line-height: 36px;
	padding-bottom: 16px;
}
.s5 {
	line-height: 40px;
	padding-bottom: 20px;
}
</style>

</head><body>
<b>fclass SourceOriginTests.A</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 2:8 3:21\"> Real x</span>;<br>
<b>equation</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 2:8 3:21\"> x = sin(time)</span>;<br>
<b>end SourceOriginTests.A;</b>
</body>
</html>

")})));
end A;

model Test_1
    // alias elimination
    Real a,b,c;
equation
    a = c + 1;
    b = c;
    c = time;
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="A",
            description="",
            methodName="sourceDiagnostics",
            methodResult="
<html>
<head>

<style>
span {
	line-height: 20px;
	background: linear-gradient(0deg, black 1px, white 1px, transparent 1px);
	background-position: 0 100%;
}
.s1 {
	line-height: 24px;
	padding-bottom: 4px;
}
.s2 {
	line-height: 28px;
	padding-bottom: 8px;
}
.s3 {
	line-height: 32px;
	padding-bottom: 12px;
}
.s4 {
	line-height: 36px;
	padding-bottom: 16px;
}
.s5 {
	line-height: 40px;
	padding-bottom: 20px;
}
</style>

</head><body>
<b>fclass SourceOriginTests.Test_1</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 55:12 57:15\"> Real a</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 57:12 57:12\"> Real b</span>;<br>
<b>equation</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 59:5 59:14\"> a = b + 1</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 61:5 61:13\"> b = time</span>;<br>
<b>end SourceOriginTests.Test_1;</b>
</body>
</html>

")})));
end Test_1;

model Test_2
    // common subexpression elimination
    function f
        input Real x;
        output Real y;
        external;
    end f;
    Real a,b;
equation
    a = f(time) + 1;
    b = f(time) + 2;
end Test_2;


model Test_3
    // function inlining
    function f
        input Real x;
        output Real y = x + x;
        algorithm
    end f;
    Real a = f(b);
    Real b = time;
end Test_3;


model IndexReduction1a_PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
  end IndexReduction1a_PlanarPendulum;


model B
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="B",
			description="Test of tearing",
			equation_sorting=true,
			automatic_tearing=true,
			methodName="sourceDiagnostics",
			methodResult="
<html>
<head>

<style>
span {
	line-height: 20px;
	background: linear-gradient(0deg, black 1px, white 1px, transparent 1px);
	background-position: 0 100%;
}
.s1 {
	line-height: 24px;
	padding-bottom: 4px;
}
.s2 {
	line-height: 28px;
	padding-bottom: 8px;
}
.s3 {
	line-height: 32px;
	padding-bottom: 12px;
}
.s4 {
	line-height: 36px;
	padding-bottom: 16px;
}
.s5 {
	line-height: 40px;
	padding-bottom: 20px;
}
</style>

</head><body>
<b>fclass SourceOriginTests.B</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 76:11 76:12\"> Real u1</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 76:14 76:15\"> Real u2</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 76:20 76:21\"> Real uL</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 76:22 77:22\"> Real i0</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 77:11 77:12\"> Real i1</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 77:14 77:15\"> Real i2</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 77:17 77:18\"> Real i3</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 77:20 77:21\"> Real iL</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 77:22 78:24\"> parameter Real R1 = 1 /* 1 */</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 78:24 79:24\"> parameter Real R2 = 1 /* 1 */</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 79:24 80:24\"> parameter Real R3 = 1 /* 1 */</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 80:24 81:23\"> parameter Real L = 1 /* 1 */</span>;<br>
<b>initial equation</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 77:20 77:21\"> iL = 0.0</span>;<br>
<b>equation</b><br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 83:3 83:17\"> uL = sin(time)</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 84:3 84:13\"> u1 = R1 * i1</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 85:3 85:13\"> u2 = R2 * i2</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 86:3 86:13\"> u2 = R3 * i3</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 87:3 87:17\"> uL = L * der(iL)</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 88:3 88:15\"> uL = u1 + u2</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 91:3 91:15\"> i0 = i1 + iL</span>;<br>
<span class=\"s0\" title=\"JModelica\\Compiler\\ModelicaMiddleEnd\\test\\modelica\\SourceOriginTests.mo 92:3 92:15\"> i1 = i2 + i3</span>;<br>
<b>end SourceOriginTests.B;</b>
</body>
</html>

")})));
end B;







end SourceOriginTests;