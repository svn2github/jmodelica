package ModelicaXMLCodeGenTests

model ModelicaXMLCodeGenTest1
	input Real u;
    Real x(start=1);
    output Real y;
equation
    der(x) = u;
    y = x;

	annotation(__JModelica(UnitTesting(tests={
		ModelicaXMLCodeGenTestCase(
			name="ModelicaXMLCodeGenTest1",
			description="Test a basic model with modifiers, causality and der()-call",
			template="",
			generatedCode="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<class kind=\"model\">
    <declaration>
        <component name=\"u\" causality=\"input\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x\">
            <builtin name=\"Real\"/>
            <modifier>
                <item name=\"start\">
                    <integer value=\"1\"/>
                </item>
            </modifier>
        </component>
        <component name=\"y\" causality=\"output\">
            <builtin name=\"Real\"/>
        </component>
    </declaration>

    <equation kind=\"initial\">
        <equal>
            <local name=\"x\"/>
            <integer value=\"1\"/>
        </equal>
    </equation>

    <equation>
        <equal>
            <operator name=\"der\">
                <local name=\"x\"/>
            </operator>
            <local name=\"u\"/>
        </equal>
        <equal>
            <local name=\"y\"/>
            <local name=\"x\"/>
        </equal>
    </equation>
</class>
			"
 )})));
end ModelicaXMLCodeGenTest1;

model TestMathFunctions
    Real x1;
    Real x2;
    Real x3;
    Real x4;
    Real x5;
    Real x6;
    Real x7;
    Real x8;
    Real x9;
    Real x10;
    Real x11;
    Real x12;
    Real x13;
    Real x14;
    Real x15;
    Real x16;
    Real x17;
    Real x18;
    Real x19;
    Real x20;
    Real x21;
    Real x22;
    Real x23;

equation
    der(x1) = x1+x2;
    der(x2) = x1-x2;
    der(x3) = x1/x2;
    der(x4) = x1*x2;
    der(x5) = sin(x4);
    der(x6) = cos(x5);
    der(x7) = tan(x6);
    der(x8) = asin(x7);
    der(x9) = acos(x8);
    der(x10) = atan(x9);
    der(x11) = atan2(x9, x10);
    der(x12) = sinh(x11);
    der(x13) = cosh(x12);
    der(x14) = tanh(x13);
    der(x15) = exp(x14);
    der(x16) = log(x15);
    der(x17) = log10(x16);
    der(x18) = abs(x19);
    der(x19) = x20^2;
    der(x20) = abs(x21);
    der(x21) = -x22;
    der(x22) = min(x20, x21);
    der(x23) = max(x21, x22);
    
    annotation(__JModelica(UnitTesting(tests={
        ModelicaXMLCodeGenTestCase(
            name="TestMathFunctions",
            description="Test generation of mathematical functions",
            template="",
            generatedCode="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<class kind=\"model\">
    <declaration>
        <component name=\"x1\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x2\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x3\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x4\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x5\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x6\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x7\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x8\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x9\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x10\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x11\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x12\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x13\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x14\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x15\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x16\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x17\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x18\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x19\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x20\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x21\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x22\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"x23\">
            <builtin name=\"Real\"/>
        </component>
    </declaration>
    
    <equation kind=\"initial\">
        <equal>
            <local name=\"x1\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x2\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x3\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x4\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x5\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x6\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x7\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x8\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x9\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x10\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x11\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x12\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x13\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x14\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x15\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x16\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x17\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x18\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x19\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x20\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x21\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x22\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"x23\"/>
            <real value=\"0.0\"/>
        </equal>
    </equation>
    
    <equation>
        <equal>
            <operator name=\"der\">
                <local name=\"x1\"/>
            </operator>
            <call builtin=\"+\">
                <local name=\"x1\"/>
                <local name=\"x2\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x2\"/>
            </operator>
            <call builtin=\"-\">
                <local name=\"x1\"/>
                <local name=\"x2\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x3\"/>
            </operator>
            <call builtin=\"/\">
                <local name=\"x1\"/>
                <local name=\"x2\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x4\"/>
            </operator>
            <call builtin=\"*\">
                <local name=\"x1\"/>
                <local name=\"x2\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x5\"/>
            </operator>
            <call builtin=\"sin\">
                <local name=\"x4\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x6\"/>
            </operator>
            <call builtin=\"cos\">
                <local name=\"x5\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x7\"/>
            </operator>
            <call builtin=\"tan\">
                <local name=\"x6\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x8\"/>
            </operator>
            <call builtin=\"asin\">
                <local name=\"x7\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x9\"/>
            </operator>
            <call builtin=\"acos\">
                <local name=\"x8\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x10\"/>
            </operator>
            <call builtin=\"atan\">
                <local name=\"x9\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x11\"/>
            </operator>
            <call builtin=\"atan2\">
                <local name=\"x9\"/>
                <local name=\"x10\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x12\"/>
            </operator>
            <call builtin=\"sinh\">
                <local name=\"x11\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x13\"/>
            </operator>
            <call builtin=\"cosh\">
                <local name=\"x12\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x14\"/>
            </operator>
            <call builtin=\"tanh\">
                <local name=\"x13\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x15\"/>
            </operator>
            <call builtin=\"exp\">
                <local name=\"x14\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x16\"/>
            </operator>
            <call builtin=\"log\">
                <local name=\"x15\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x17\"/>
            </operator>
            <call builtin=\"log10\">
                <local name=\"x16\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x18\"/>
            </operator>
            <call builtin=\"abs\">
                <local name=\"x19\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x19\"/>
            </operator>
            <call builtin=\"^\">
                <local name=\"x20\"/>
                <integer value=\"2\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x20\"/>
            </operator>
            <call builtin=\"abs\">
                <local name=\"x21\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x21\"/>
            </operator>
            <call builtin=\"-\">
                <local name=\"x22\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x22\"/>
            </operator>
            <call builtin=\"min\">
                <local name=\"x20\"/>
                <local name=\"x21\"/>
            </call>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"x23\"/>
            </operator>
            <call builtin=\"max\">
                <local name=\"x21\"/>
                <local name=\"x22\"/>
            </call>
        </equal>
    </equation>
</class>"
 )})));
end TestMathFunctions;

model TestEnumDeclaration
    type A = enumeration(a "This is a", b, c) "This is a";
    type B = enumeration(a, c, b "This is b");
    
    parameter A x = A.a;
    parameter B y = B.b;

    annotation(__JModelica(UnitTesting(tests={
        ModelicaXMLCodeGenTestCase(
            name="TestEnumDeclaration",
            description="Test declaration of enums",
            template="",
            generatedCode="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<class kind=\"model\">
    <declaration>
        <classDefinition name=\"ModelicaXMLCodeGenTests.TestEnumDeclaration.A\">
            <enumeration>
                <item name=\"a\"/>
                <item name=\"b\"/>
                <item name=\"c\"/>
            </enumeration>
        </classDefinition>
        <classDefinition name=\"ModelicaXMLCodeGenTests.TestEnumDeclaration.B\">
            <enumeration>
                <item name=\"a\"/>
                <item name=\"c\"/>
                <item name=\"b\"/>
            </enumeration>
        </classDefinition>
        <component name=\"x\" variability=\"parameter\">
            <local name=\"ModelicaXMLCodeGenTests.TestEnumDeclaration.A\"/>
            <bindingExpression>
                <local name=\"ModelicaXMLCodeGenTests.TestEnumDeclaration.A.a\"/>
            </bindingExpression>
        </component>
        <component name=\"y\" variability=\"parameter\">
            <local name=\"ModelicaXMLCodeGenTests.TestEnumDeclaration.B\"/>
            <bindingExpression>
                <local name=\"ModelicaXMLCodeGenTests.TestEnumDeclaration.B.b\"/>
            </bindingExpression>
        </component>
    </declaration>
</class>"
)})));
end TestEnumDeclaration;


model TestBooleanExpressions
    Real x1;
    Boolean b1;
    Boolean b2;
    Boolean b3;
    Boolean b4;
    Boolean b5;
    Boolean b6;
    Boolean b7;
    Boolean b8;
    Boolean b9;

equation
    der(x1) = if(b1) then 1 else 2;
    b1 = x1 > 0;
    b2 = x1 < 0;
    b3 = x1 >= 0;
    b4 = x1 <= 0;
    b5 = b2 == b3;
    b6 = b2 <> b3;
    b7 = b1 or b4;
    b8 = b1 and b4;
    b9 = not b4;

    annotation(__JModelica(UnitTesting(tests={
        ModelicaXMLCodeGenTestCase(
            name="TestBooleanExpressions",
            description="",
            template="",
            generatedCode="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<class kind=\"model\">
    <declaration>
        <component name=\"x1\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"b1\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b2\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b3\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b4\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b5\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b6\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b7\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b8\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"b9\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b1)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b2)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b3)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b4)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b5)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b6)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b7)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b8)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
        <component name=\"pre(b9)\" variability=\"discrete\">
            <builtin name=\"Boolean\"/>
        </component>
    </declaration>
    
    <equation kind=\"initial\">
        <equal>
            <local name=\"x1\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b1\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b2\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b3\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b4\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b5\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b6\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b7\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b8\"/>
            </operator>
            <false/>
        </equal>
        <equal>
            <operator name=\"pre\">
                <local name=\"b9\"/>
            </operator>
            <false/>
        </equal>
    </equation>
    
    <equation>
        <equal>
            <operator name=\"der\">
                <local name=\"x1\"/>
            </operator>
            <if>
                <cond>
                    <local name=\"b1\"/>
                </cond>
                <then>
                    <integer value=\"1\"/>
                </then>
                <else>
                    <integer value=\"2\"/>
                </else>
            </if>
        </equal>
        <equal>
            <local name=\"b1\"/>
            <call builtin=\"&gt;\">
                <local name=\"x1\"/>
                <integer value=\"0\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b2\"/>
            <call builtin=\"&lt;\">
                <local name=\"x1\"/>
                <integer value=\"0\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b3\"/>
            <call builtin=\"&gt;=\">
                <local name=\"x1\"/>
                <integer value=\"0\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b4\"/>
            <call builtin=\"&lt;=\">
                <local name=\"x1\"/>
                <integer value=\"0\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b5\"/>
            <call builtin=\"==\">
                <local name=\"b2\"/>
                <local name=\"b3\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b6\"/>
            <call builtin=\"&lt;&gt;\">
                <local name=\"b2\"/>
                <local name=\"b3\"/>
            </call>
        </equal>
        
        <equal>
            <local name=\"b7\"/>
            <call builtin=\"or\">
                <local name=\"b1\"/>
                <local name=\"b4\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b8\"/>
            <call builtin=\"and\">
                <local name=\"b1\"/>
                <local name=\"b4\"/>
            </call>
        </equal>
        <equal>
            <local name=\"b9\"/>
            <call builtin=\"not\">
                <local name=\"b4\"/>
            </call>
        </equal>
    </equation>
</class>"
 )})));
end TestBooleanExpressions;

model TestModifier
    Real x(start=2);
    Real y(min=20);
equation
    x = y+1;
    y = x-1;

    annotation(__JModelica(UnitTesting(tests={
        ModelicaXMLCodeGenTestCase(
            name="TestModifier",
            description="",
            template="",
            generatedCode="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<class kind=\"model\">
    <declaration>
        <component name=\"x\">
            <builtin name=\"Real\"/>
            <modifier>
                <item name=\"start\">
                    <integer value=\"2\"/>
                </item>
            </modifier>
        </component>
        <component name=\"y\">
            <builtin name=\"Real\"/>
            <modifier>
                <item name=\"min\">
                    <integer value=\"20\"/>
                </item>
            </modifier>
        </component>
    </declaration>
    
    
    <equation>
        <equal>
            <local name=\"x\"/>
            <call builtin=\"+\">
                <local name=\"y\"/>
                <integer value=\"1\"/>
            </call>
        </equal>
        <equal>
            <local name=\"y\"/>
            <call builtin=\"-\">
                <local name=\"x\"/>
                <integer value=\"1\"/>
            </call>
        </equal>
    </equation>
</class>"
 )})));
end TestModifier;

model TestDeclarations
    Real theta;
    Real omega;
    parameter Real L=2;
    constant Real g=9.81;
    input Modelica.SIunits.Voltage u1;
equation
    der(theta) = omega;
    der(omega) = -(g/L)*Modelica.Math.sin(theta);

    annotation(__JModelica(UnitTesting(tests={
        ModelicaXMLCodeGenTestCase(
            name="TestDeclarations",
            description="Test declarations with different causality and variability",
            template="",
            generatedCode="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<class kind=\"model\">
    <declaration>
        <component name=\"theta\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"omega\">
            <builtin name=\"Real\"/>
        </component>
        <component name=\"L\" variability=\"parameter\">
            <builtin name=\"Real\"/>
            <bindingExpression>
                <integer value=\"2\"/>
            </bindingExpression>
        </component>
        <component name=\"g\" variability=\"constant\">
            <builtin name=\"Real\"/>
            <bindingExpression>
                <real value=\"9.81\"/>
            </bindingExpression>
        </component>
        <component name=\"u1\" causality=\"input\">
            <local name=\"Modelica.SIunits.ElectricPotential\"/>
        </component>
    </declaration>
    
    <equation kind=\"initial\">
        <equal>
            <local name=\"theta\"/>
            <real value=\"0.0\"/>
        </equal>
        <equal>
            <local name=\"omega\"/>
            <real value=\"0.0\"/>
        </equal>
    </equation>
    
    <equation>
        <equal>
            <operator name=\"der\">
                <local name=\"theta\"/>
            </operator>
            <local name=\"omega\"/>
        </equal>
        <equal>
            <operator name=\"der\">
                <local name=\"omega\"/>
            </operator>
            <call builtin=\"*\">
                <call builtin=\"-\">
                    <call builtin=\"/\">
                        <real value=\"9.81\"/>
                        <local name=\"L\"/>
                    </call>
                </call>
                <call builtin=\"sin\">
                    <local name=\"theta\"/>
                </call>
            </call>
        </equal>
    </equation>
</class>"
 )})));
end TestDeclarations;

end ModelicaXMLCodeGenTests;
