function strName=figname(strMfilename,strWhichAx);
switch strWhichAx
case 'sum'
   strLetter='s';
case 'xyz'
   strLetter='3';
case 'vecmag'
   strLetter='m';
case {'x','y','z'}
   strLetter=strWhichAx;
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end
strName=[strMfilename strLetter];
