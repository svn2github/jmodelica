var list_across0 = [
'_contents_xml.htm',
'_reference.xml',
'_index.xml',
'_search_xml.htm',
'_external.xml'
];
var list_up0 = [
'cppad.xml',
'install.xml',
'installunix.xml'
];
var list_down2 = [
'install.xml',
'introduction.xml',
'ad.xml',
'adfun.xml',
'library.xml',
'example.xml',
'configure.xml',
'appendix.xml'
];
var list_down1 = [
'installunix.xml',
'installwindows.xml'
];
var list_down0 = [
'subversion.xml'
];
var list_current0 = [
'installunix.xml#Fedora',
'installunix.xml#RPM',
'installunix.xml#Download',
'installunix.xml#Download.Subversion',
'installunix.xml#Download.Web Link',
'installunix.xml#Download.Unix Tar Files',
'installunix.xml#Download.Tar File Extraction',
'installunix.xml#Configure',
'installunix.xml#make test',
'installunix.xml#Introduction',
'installunix.xml#Introduction.Getting Started',
'installunix.xml#Introduction.exp_apx',
'installunix.xml#CppAD Examples',
'installunix.xml#More Testing',
'installunix.xml#Speed Testing',
'installunix.xml#Speed Testing.CppAD Derivative Speed Tests',
'installunix.xml#Speed Testing.Function Speed Tests',
'installunix.xml#Speed Testing.Examples For Speed Tests',
'installunix.xml#Profiling CppAD',
'installunix.xml#PrintFor',
'installunix.xml#PrefixDir',
'installunix.xml#--with-Documentation',
'installunix.xml#--with-stdvector',
'installunix.xml#PostfixDir',
'installunix.xml#AdolcDir',
'installunix.xml#AdolcDir.Linux',
'installunix.xml#AdolcDir.Cygwin',
'installunix.xml#FadbadDir',
'installunix.xml#SacadoDir',
'installunix.xml#BoostDir',
'installunix.xml#IpoptDir',
'installunix.xml#CompilerFlags',
'installunix.xml#make install'
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
