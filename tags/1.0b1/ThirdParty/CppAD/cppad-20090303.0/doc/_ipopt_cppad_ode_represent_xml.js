var list_across0 = [
'_contents_xml.htm',
'_reference.xml',
'_index.xml',
'_search_xml.htm',
'_external.xml'
];
var list_up0 = [
'cppad.xml',
'example.xml',
'general.xml',
'ipopt_cppad_nlp.xml',
'ipopt_cppad_ode.xml',
'ipopt_cppad_ode_represent.xml'
];
var list_down3 = [
'ipopt_cppad_nlp.xml',
'interface2c.cpp.xml',
'jacminordet.cpp.xml',
'jacludet.cpp.xml',
'hesminordet.cpp.xml',
'hesludet.cpp.xml',
'odestiff.cpp.xml',
'ode_taylor.cpp.xml',
'ode_taylor_adolc.cpp.xml',
'stackmachine.cpp.xml',
'mul_level.xml'
];
var list_down2 = [
'ipopt_cppad_windows.xml',
'ipopt_cppad_simple.cpp.xml',
'ipopt_cppad_ode.xml'
];
var list_down1 = [
'ipopt_cppad_ode_forward.xml',
'ipopt_cppad_ode_inverse.xml',
'ipopt_cppad_ode_simulate.xml',
'ipopt_cppad_ode_represent.xml',
'ipopt_cppad_ode.cpp.xml'
];
var list_current0 = [
'ipopt_cppad_ode_represent.xml#Purpose',
'ipopt_cppad_ode_represent.xml#Trapezoidal Time Grid',
'ipopt_cppad_ode_represent.xml#Argument Vector',
'ipopt_cppad_ode_represent.xml#Objective',
'ipopt_cppad_ode_represent.xml#Initial Condition',
'ipopt_cppad_ode_represent.xml#Trapezoidal Approximation'
];
function choose_across0(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_across0[index-1];
}
function choose_up0(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_up0[index-1];
}
function choose_down3(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_down3[index-1];
}
function choose_down2(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_down2[index-1];
}
function choose_down1(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_down1[index-1];
}
function choose_down0(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_down0[index-1];
}
function choose_current0(item)
{	var index          = item.selectedIndex;
	item.selectedIndex = 0;
	if(index > 0)
		document.location = list_current0[index-1];
}
