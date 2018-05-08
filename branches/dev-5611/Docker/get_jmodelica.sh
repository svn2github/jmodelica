#    Copyright (C) 2018 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.


if [ "$JMODELICA_BRANCH" == "" ] 
then 
	JMODELICA_BRANCH=trunk
else 
	JMODELICA_BRANCH="/branches/${JMODELICA_BRANCH}"
fi

svn co https://svn.jmodelica.org/${JMODELICA_BRANCH} JModelica.org