function catappend(strFile)
strCmd1 = ['c:\cygwin\bin\cat.exe ' strFile ' >> c:\temp\catappend.txt'];
strCmd2 = ['c:\cygwin\bin\echo.exe "" >> c:\temp\catappend.txt'];
dos(strCmd1);
dos(strCmd2);