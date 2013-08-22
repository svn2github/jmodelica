/*
    Copyright (C) 2013 Modelon AB

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

package OverconstrainedConnection

type TBase = Real[2];

type T1
	extends TBase;
	
	function equalityConstraint
		input T1 i1;
		input T1 i2;
		output Real[1] o;
	algorithm
		o := sum(i1 .+ i2);
	end equalityConstraint;
end T1;

connector C1
	T1 t;
end C1;

model OverconstrainedCorrect1
	C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
equation
	connect(c1, c3);
    connect(c2, c4);
    Connections.branch(c1.t, c2.t);
	c1.t = c2.t;
    Connections.branch(c3.t, c4.t);
	c3.t = c4.t;
	Connections.root(c1.t);
	c1.t[1] = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect1",
			description="Basic test of overconstrained connection graphs",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect1
 OverconstrainedConnection.T1 c1.t[2];
 OverconstrainedConnection.T1 c2.t[2];
 OverconstrainedConnection.T1 c3.t[2];
 OverconstrainedConnection.T1 c4.t[2];
equation
 c1.t[1:2] = c2.t[1:2];
 c3.t[1:2] = c4.t[1:2];
 c1.t[1] = 0;
 c1.t[1:2] = c3.t[1:2];
 zeros(1) = OverconstrainedConnection.T1.equalityConstraint(c2.t[1:2], c4.t[1:2]);

public
 function OverconstrainedConnection.T1.equalityConstraint
  input Real[2] i1;
  input Real[2] i2;
  output Real[1] o;
 algorithm
  o := sum(i1 .+ i2);
  return;
 end OverconstrainedConnection.T1.equalityConstraint;

 type OverconstrainedConnection.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect1;
")})));
end OverconstrainedCorrect1;


model OverconstrainedCorrect2
    C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
equation
    connect(c1, c3);
    connect(c2, c4);
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.branch(c3.t, c4.t);
    c3.t = c4.t;
    Connections.potentialRoot(c1.t);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect2",
			description="Overconstrained connection graphs with potential roots",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect2
 OverconstrainedConnection.T1 c1.t[2];
 OverconstrainedConnection.T1 c2.t[2];
 OverconstrainedConnection.T1 c3.t[2];
 OverconstrainedConnection.T1 c4.t[2];
equation
 c1.t[1:2] = c2.t[1:2];
 c3.t[1:2] = c4.t[1:2];
 c1.t[1] = 0;
 c1.t[1:2] = c3.t[1:2];
 zeros(1) = OverconstrainedConnection.T1.equalityConstraint(c2.t[1:2], c4.t[1:2]);

public
 function OverconstrainedConnection.T1.equalityConstraint
  input Real[2] i1;
  input Real[2] i2;
  output Real[1] o;
 algorithm
  o := sum(i1 .+ i2);
  return;
 end OverconstrainedConnection.T1.equalityConstraint;

 type OverconstrainedConnection.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect2;
")})));
end OverconstrainedCorrect2;


model OverconstrainedCorrect3
    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.potentialRoot(c1.t, 1);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect3",
			description="Simple root selection and isRoot()",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect3
 OverconstrainedConnection.T1 c1.t[2];
 OverconstrainedConnection.T1 c2.t[2];
 constant Boolean c1Root1 = Connections.isRoot(c1.t[1:2]);
 constant Boolean c1Root2 = false;
 constant Boolean c2Root1 = Connections.isRoot(c2.t[1:2]);
 constant Boolean c2Root2 = true;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;

public
 type OverconstrainedConnection.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect3;
")})));
end OverconstrainedCorrect3;


model OverconstrainedCorrect4
    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect4",
			description="Simple root selection and isRoot()",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect4
 OverconstrainedConnection.T1 c1.t[2];
 OverconstrainedConnection.T1 c2.t[2];
 constant Boolean c1Root1 = Connections.isRoot(c1.t[1:2]);
 constant Boolean c1Root2 = false;
 constant Boolean c2Root1 = Connections.isRoot(c2.t[1:2]);
 constant Boolean c2Root2 = true;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;

public
 type OverconstrainedConnection.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect4;
")})));
end OverconstrainedCorrect4;


model OverconstrainedCorrect5
    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.root(c1.t);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect5",
			description="Simple root selection and isRoot(), unbreakable branch",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect5
 OverconstrainedConnection.T1 c1.t[2];
 OverconstrainedConnection.T1 c2.t[2];
 constant Boolean c1Root1 = Connections.isRoot(c1.t[1:2]);
 constant Boolean c1Root2 = true;
 constant Boolean c2Root1 = Connections.isRoot(c2.t[1:2]);
 constant Boolean c2Root2 = false;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;

public
 type OverconstrainedConnection.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect5;
")})));
end OverconstrainedCorrect5;


model OverconstrainedCorrect6
connector C1
    Real x;
	flow Real y;
end C1;
	C1 c1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect6",
			description="Unconnected connector",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect6
 Real c1.x;
 Real c1.y;
equation
 c1.y = 0;
end OverconstrainedConnection.OverconstrainedCorrect6;
")})));
end OverconstrainedCorrect6;


model OverconstrainedCorrect7
    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    connect(c1.t, c2.t);
    c1.t = c2.t;
    Connections.root(c1.t);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="OverconstrainedCorrect7",
			description="Simple root selection and isRoot(), breakable branch",
			flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect7
 OverconstrainedConnection.T1 c1.t[2];
 OverconstrainedConnection.T1 c2.t[2];
 constant Boolean c1Root1 = Connections.isRoot(c1.t[1:2]);
 constant Boolean c1Root2 = true;
 constant Boolean c2Root1 = Connections.isRoot(c2.t[1:2]);
 constant Boolean c2Root2 = false;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;
 c1.t[{1, 2}] = c2.t[{1, 2}];

public
 type OverconstrainedConnection.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect7;
")})));
end OverconstrainedCorrect7;


end OverconstrainedConnection;
