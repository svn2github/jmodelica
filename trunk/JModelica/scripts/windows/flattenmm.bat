echo off

rem    Copyright (C) 2009 Modelon AB
rem
rem    This program is free software: you can redistribute it and/or modify
rem    it under the terms of the GNU General Public License as published by
rem    the Free Software Foundation, version 3 of the License.
rem
rem    This program is distributed in the hope that it will be useful,
rem    but WITHOUT ANY WARRANTY; without even the implied warranty of
rem    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem    GNU General Public License for more details.
rem
rem    You should have received a copy of the GNU General Public License
rem    along with this program.  If not, see <http://www.gnu.org/licenses/>.

rem set JAR_DIR=

java -Xmx256M -classpath bin\jmodelica.jar org.jmodelica.applications.FlattenModel %1 %2


