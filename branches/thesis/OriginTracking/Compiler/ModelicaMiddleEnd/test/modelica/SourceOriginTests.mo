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
end SourceOriginTests;