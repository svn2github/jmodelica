@echo off
start /min /w gnumake2.cmd %1 %2
type gnumake.out
del gnumake.out 
