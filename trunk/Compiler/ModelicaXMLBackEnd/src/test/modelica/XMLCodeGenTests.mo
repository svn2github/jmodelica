/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package XMLCodeGenTests



model RemoveCopyright
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.XMLCodeGenTestCase(
         name="RemoveCopyright",
         description="Test that licence tag is filtered out",
         template="<!-- test copyright blurb --> test",
         generatedCode="test"
)})));
end RemoveCopyright;



  model XMLCodeGenTest1
  	parameter Real rp1=1;
  	parameter Real rp2=rp1;
    parameter Real rp3(start=1);
    parameter Real rp4(start=rp1);
    parameter Real rp5(start=rp1) = 5;
    Real r1(start=1);
    Real r2=3;
    Real r3;
	input Real r4 = 5;

  	parameter Integer ip1=1;
  	parameter Integer ip2=ip1;
    parameter Integer ip3(start=1);
    parameter Integer ip4(start=ip1);
    parameter Integer ip5(start=ip1) = 5;
    Integer i1(start=1);
    Integer i2=3;
  	Integer i3=4;
	input Integer r4 = 5;

  	parameter Boolean bp1=true;
  	parameter Boolean bp2=bp1;
    parameter Boolean bp3(start=true);
    parameter Boolean bp4(start=bp1);
    parameter Boolean bp5(start=bp1) = false;
    Boolean b1(start=true);
    Boolean b2=true;
	Boolean b3=true;
	input Boolean b4 =true;
		
  	parameter String sp1="hello";
  	parameter String sp2=sp1;
    parameter String sp3(start="hello");
    parameter String sp4(start=sp1);
    parameter String sp5(start=sp1) = "hello";
    String s1(start="hello");
    String s2="hello";
	String s3="hello";
	input String s4="hello";
    
    equation 
     r1 = 1;
     der(r3)=1;
     i1 = 1;
     b1 = true;
     s2 = "hello";
  end XMLCodeGenTest1;



	model XMLCodeGenTest3
	
		parameter Real p1 = 5;
		parameter Real p2 = p1+4;
		parameter Real p3 = p2-1;
		parameter Real p4 = p3*6;
		parameter Real p5 = p4/6;
		parameter Real p6 = -p5;
		parameter Real p7 = p6/83;
		parameter Real p8 = p7^2;
   	 equation
   	end XMLCodeGenTest3;

	model XMLCodeGenTest4	
		Real r(quantity="q", unit="kg", displayUnit="g", 
		  min=-2-1,max=4,start=1+1,fixed=false,nominal=4-3) = 1;
		Integer i(quantity="q", min=-2-1,max=4,start=1+1,fixed=false) = 1;
		Boolean b(quantity="q", start=true,fixed=false) = 1;
		String s(quantity="q",start="qwe") = 1;


   	 equation
   	end XMLCodeGenTest4;

	model XMLCodeGenTest5
	
		constant Real r1(unit="m", displayUnit="mm",
			min = 2*0, max = 2^5, start = 10, nominal = 0) = 1;
		parameter Real r2(quantity="q1", min = 0, max = 10, start = 0) = 2;
		discrete Real r3(quantity="q1", unit = "Hz", max = 100) = 3;
		input Real r4(start = 5, min=-10);
		output Real r5(max=4, min=3) = 1;
		
		protected Integer i1(start=5)=2;
		Integer i2(quantity="g",max=1000)=3;
		Integer i3(min=1);
		
		String s1;
		String s2(start="abc")="def";
		
		equation
			s1 = "ghi";
			r5 = der(r4);	
		
	end XMLCodeGenTest5;	

end XMLCodeGenTests;
