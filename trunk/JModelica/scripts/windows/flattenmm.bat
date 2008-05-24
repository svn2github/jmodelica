echo off
rem set JAR_DIR=

java -Xmx256M -classpath bin\jmodelica.jar org.jmodelica.applications.FlattenModel %1 %2


