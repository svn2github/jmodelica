<!--
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
-->

<fmiExtendedModelDescription $XML_rootAttributes$ xmlns:equ="http://www.robertoparrotto.it/DAEXML/FEqu.xsd" xmlns:exp="http://www.robertoparrotto.it/DAEXML/FExp.xsd" xmlns:opt="http://www.robertoparrotto.it/DAEXML/Optimization.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	$XML_unitDefinitions$
	$XML_typeDefinitions$
	$XML_defaultExperiment$
	$XML_vendorAnnotations$	
	<ModelVariables>$XML_variables$
	</ModelVariables>
	$XML_bindingEquations$
	$XML_Equations$
	$XML_initialEquations$
	$XML_Optimization$	
</fmiExtendedModelDescription>