function [symbol,name] = convertstyle(stylechoice);

% Converts the character string that contains a line style name into
% the symbol that can be used in plot of the form plot(x,y,'color',convertcolor(colorchoice)).  
%
%  Note: In most cases the symbols will not work with the plot option,
%  i.e. plot(x,y,'a:') will not work, the plot function cannot understand 'a'.
%
%  [symbol] = convertcolor(name)
%

% $Id: convertstyle.m 4160 2009-12-11 19:10:14Z khrovat $

% Author: Eric Kelly

NumberOfStyles = 4;
if nargin == 0
   stylechoice ='list';
elseif nargin>1
   error('Too many input parameters into convertcolor')
end
style = lower(stylechoice);
switch(stylechoice)
case {1,'solid','solid','-'}
   name = 'solid';symbol ='-';
case {2,'dash','dashed','--'}
   name = 'dash';symbol ='--';
case {3,'dash-dot','dashdot','-.'}
   name = 'dash-dot';symbol ='-.';
case {4,'dot','dotted',':'}
   name = 'dot';symbol =':';
case {0,'list'}
   disp(sprintf('%2s %20s %10s','#','NAME','SYMBOL'));
   disp(sprintf('%2s %20s %10s','-','----','------'));
   for i =1:NumberOfStyles
      [name1,symbol1] = convertstyle(i);
      str = sprintf('%2d %20s %10s',i,name1,symbol1);
      disp(str);
   end
case {-1,'cell'}
      name = cell(NumberOfStyles,1);symbol = cell(NumberOfStyles,1);
      for i =1:NumberOfStyles
      [name{i},symbol{i}] = convertstyle(i);
   end
end

