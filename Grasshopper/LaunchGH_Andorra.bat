@ECHO off
title reset batch script
rem this script resets the GH/rhino, Unity, and Gama
echo restarting Rhino and Grasshopper..
cd C:\Users\CPG_Andorra\Documents\GitHub\Andorra\Grasshopper\Rhino
start "" "C:\Program Files\Rhinoceros 5 (64-bit)\System\Rhino.exe" /nosplash /runscript="-loadscript C:\Users\CPG_Andorra\Documents\GitHub\Andorra\Grasshopper\Rhino\Andorra_reset.rvb _enter" 170822_CityScope_Andorra_WIP.3dm

pause