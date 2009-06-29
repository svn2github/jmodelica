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


package org.jmodelica.modelica.test;

import org.jmodelica.modelica.ast.*;
import java.io.*;
import java.util.Random;

 public class GenLargeRLC {

	public class RLCGenerator {

		Random r = new Random();
		
		public ComponentDecl createComponentDecl(String c, String name) {
			
			ComponentDecl cd = new ComponentDecl(new Opt(),
                      new Opt(),
                        new Opt(),
                        new Opt(),
                        new Opt(),
                        new Opt(),
                        new Opt(),
                        new Opt(),
                        new ClassAccess(c),
                        new Opt(),
                        new PublicVisibilityType(),
                        new IdDecl(name),
                        new Opt(),
                        new Opt(),
                        new Opt(),
                        new Comment(),
                        new Opt(),
                        new Comment());
			
			return cd;
			
		}
		
		public Program genBaseRLC(int n, int m) {
		
			if ((n%2)==0)
				n=n+1;
			
			Program p = new Program();
			FullClassDecl cd = new FullClassDecl();
			cd.setVisibilityType(new PublicVisibilityType());
			cd.setRestriction(new Model());
			cd.setName(new IdDecl("BaseCircuit"));
		    			
		    cd.addComponentDecl(createComponentDecl("ConstantVoltage","cv"));
		    cd.addComponentDecl(createComponentDecl("Ground","g"));
		    
		    for (int i=1;i<=n; i++) {
				for (int j=1;j<=(m+((i+1) % 2)); j++) {
					int q = r.nextInt(3)+1;
					switch (q) {
					case 1:
						cd.addComponentDecl(createComponentDecl("Resistor","c_"+i+"_"+j));
						break;
					case 2:
						cd.addComponentDecl(createComponentDecl("Capacitor","c_"+i+"_"+j));
						break;
					case 3:
						cd.addComponentDecl(createComponentDecl("Inductor","c_"+i+"_"+j));
						break;
                    default: break;					
					}

				}
			}
			
		    cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("cv",new Opt()),new ComponentAccess("p",new Opt())),
                    new Dot("",new ComponentAccess("c_1_1",new Opt()),new ComponentAccess("p",new Opt()))));
		    cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("cv",new Opt()),new ComponentAccess("n",new Opt())),
                    new Dot("",new ComponentAccess("g",new Opt()),new ComponentAccess("p",new Opt()))));
		    cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("g",new Opt()),new ComponentAccess("p",new Opt())),
                    new Dot("",new ComponentAccess("c_"+n+"_1",new Opt()),new ComponentAccess("n",new Opt()))));
		   
		    int i=1;
		    while (i<=n) {
		    	for (int j=1;j<m;j++)
		    		cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("c_"+i+"_"+j,new Opt()),new ComponentAccess("n",new Opt())),
		                    new Dot("",new ComponentAccess("c_"+i+"_"+(j+1),new Opt()),new ComponentAccess("p",new Opt()))));
		    	i+=2;
		    }
		    
		    i=2;
		    while (i<=n) {
		    	for (int j=1;j<=m;j++){
		    		cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("c_"+i+"_"+j,new Opt()),new ComponentAccess("p",new Opt())),
		                    new Dot("",new ComponentAccess("c_"+(i-1)+"_"+j,new Opt()),new ComponentAccess("p",new Opt()))));
		    		cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("c_"+i+"_"+j,new Opt()),new ComponentAccess("n",new Opt())),
	                    new Dot("",new ComponentAccess("c_"+(i+1)+"_"+j,new Opt()),new ComponentAccess("p",new Opt()))));
		    	}
		    	cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("c_"+i+"_"+(m+1),new Opt()),new ComponentAccess("p",new Opt())),
	                    new Dot("",new ComponentAccess("c_"+(i-1)+"_"+m,new Opt()),new ComponentAccess("n",new Opt()))));
	    		cd.addEquation(new ConnectClause(new Opt(),new Comment(),new Dot("",new ComponentAccess("c_"+i+"_"+(m+1),new Opt()),new ComponentAccess("n",new Opt())),
                    new Dot("",new ComponentAccess("c_"+(i+1)+"_"+m,new Opt()),new ComponentAccess("n",new Opt()))));
		    	
		    	i+=2;
		    }
		    
		    
		    
			p.getUnstructuredEntity(0).addElement(cd);
						
			return p;
		}
	
	}
	
	
	public static void main(String args[]) {

		GenLargeRLC g = new GenLargeRLC();
		
		RLCGenerator gen = g.new RLCGenerator();
		
		
		
		
		  StringBuffer str =  new StringBuffer(  
"connector Pin\n" +
"  Real v;\n" +
"  flow Real i;\n"+
"end Pin;\n"+
"\n"+
 " connector PositivePin\n"+
"    Real v;\n"+
"    flow Real i;\n"+
"  end PositivePin;\n"+
"\n"+
"  connector NegativePin\n"+
"    Real v;\n"+
"    flow Real i;\n"+
"  end NegativePin;\n"+
"\n"+
"  model TwoPin\n"+
"    Real v;\n"+
"    PositivePin p;\n"+
"    NegativePin n;\n"+
"  equation\n"+
"    v = p.v-n.v;\n"+
"  end TwoPin;\n"+
"\n"+
"  model OnePort\n"+
"    Real v;\n"+
"    Real i;\n"+
"    PositivePin p;\n"+
"    NegativePin n;\n"+
"  equation\n"+
"    v = p.v-n.v;\n"+
"    0 = p.i+n.i;\n"+
"    i = p.i;\n"+
"  end OnePort;\n"+
"\n"+
"  model Resistor\n"+
"  extends OnePort;\n"+
"    parameter Real R=1;\n"+
"  equation\n"+
"    R*i = v;\n"+
"  end Resistor;\n"+
"\n"+
"  model Capacitor\n"+
"  extends OnePort;\n"+
"    parameter Real C=1;\n"+
"  equation\n"+
"    i = C*der(v);\n"+
"  end Capacitor;\n"+
"\n"+
"  model Inductor\n"+
"  extends OnePort;\n"+
"    parameter Real L=1;\n"+
"  equation\n"+
"    L*der(i) = v;\n"+
"  end Inductor;\n"+
"\n"+
"  model ConstantVoltage\n"+
"  extends OnePort;\n"+
"    parameter Real V=1;\n"+
"  equation\n"+
"    v = V;\n"+
"  end ConstantVoltage;\n"+
"\n"+
"  model Ground\n"+
"    Pin p;\n"+
"  equation\n"+
"    p.v = 0;\n"+
"  end Ground;\n");

str.append(gen.genBaseRLC(51,50).prettyPrint("  "));

str.append("model Electrical\n" 
+ "  BaseCircuit bc;\n"
+ "end Electrical;\n");

	System.out.println(str.toString());	  
		  	  
	}
	
}
