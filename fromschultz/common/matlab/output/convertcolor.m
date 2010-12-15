function [RGB,name,symbol] = convertcolor(colorchoice);

% Converts the character string that contains a line style name into
% the symbol that can be used in plot of the form plot(x,y,'color',convertcolor(colorchoice)).  
%
%  Note: In most cases the symbols will not work with the plot option,
%  i.e. plot(x,y,'a:') will not work, the plot function cannot understand 'a'.
%
%  [symbol] = convertcolor(name)
%

% $Id: convertcolor.m 4160 2009-12-11 19:10:14Z khrovat $

% Author: Eric Kelly

NumberOfColors = 42;
if nargin == 0
   colorchoice='list';
elseif nargin>1
   error('Too many input parameters into convertcolor')
end
colorchoice = lower(colorchoice);
switch(colorchoice)
case {1,'aqua','a'}
   name = 'aqua';symbol ='a';
   RGB = [.26 .72 .73];
case {2,'black','k'}
   name = 'black';symbol ='k';
   RGB = [0 0 0];
case {3,'blue','b'}
   name = 'blue';symbol ='b';
   RGB = [0 0 1];
case {4,'coral','co'}
   name = 'coral';symbol ='co';
   RGB = [.97 .40 .25];
case {5,'cyan','c'} 
   name = 'cyan';symbol ='c';
   RGB = [0 1 1];
case {6,'dark gray','dgr','dark grey'}
   name = 'dark gray';symbol ='dgr';
   RGB = [.3 .3 .3];
case {7,'dark green','dg'}
   name = 'dark green';symbol ='dg';
   RGB = [.15 .25 .09];  
case {8,'dark khaki','dk'}
   name = 'dark khaki';symbol ='dk';
   RGB = [.72 .68 .35];
case {9,'dark olive green','dog'}
   name = 'dark olive green';symbol ='dog';
   RGB = [.29 .25 .09];
case {10,'dark sea green','dsg'}
   name = 'dark sea green';symbol ='dsg';
   RGB = [.55 .70 .51];
case {11,'deep pink','dp'}
   name = 'deep pink';symbol ='dp';
   RGB = [.96 .16 .53];
case {12,'deep sky blue','dsb'}
   name = 'deep sky blue';symbol ='dsb';
   RGB = [.23 .73 1];
case {13,'forest green','fg'}
   name = 'forest green';symbol ='fg';
   RGB = [.31 .57 .35];
case {14,'ghost white','gw'}
   name = 'ghost white';symbol ='gw';
   RGB = [.97 .97 1];
case {15,'gold','go'}
   name = 'gold';symbol ='go';
   RGB = [.83 .63 .09];
case {16,'gray','gr','grey'}
   name = 'gray';symbol ='gr';
   RGB = [.5 .5 .5];
case {17,'green','g'}
   name = 'green';symbol ='g';
   RGB = [0 1 0];
case {18,'khaki','kh'}
   name = 'khaki';symbol ='kh';
   RGB = [.68 .66 .43];
case {19,'lavender','l'}
   name = 'lavender';symbol ='l';
   RGB = [.99 .93 .96];
case {20,'lawn green','lg'}
   name = 'lawn green';symbol ='lg';
   RGB = [.53 .97 .09];
case {21,'lemon','lm'}
   name = 'lemon';symbol ='lm';
   RGB = [1 .97 0.09];
case {22,'light gray','lgr','light grey'}
   name = 'light gray';symbol ='lgr';
   RGB = [.8 .8 .8];
case {23,'magenta','m'}
   name = 'magenta';symbol ='m';
   RGB = [1 0 1];
case {24,'maroon','mr'}
   name = 'maroon';symbol ='mr';
   RGB = [.51 .02 .25]; 
case {25,'medium aqua','ma'}
   name = 'medium aqua';symbol ='ma';
   RGB = [.20 .53 .51];
case {26,'midnight blue','mb'}
   name = 'midnight blue';symbol ='mb';
   RGB = [.08 .11 .33];
case {27,'mint','mi'}
   name = 'mint';symbol ='mi';
   RGB = [.96 1 .98];
case {28,'navy blue','nb'}
   name = 'nb';symbol ='nb';
   RGB = [.08 .02 .40];
case {29,'old lace','ol'}
   name = 'old lace';symbol ='ol';
   RGB = [.99 .95 .89];
case {30,'plum','p'}
   name = 'plum';symbol ='p';
   RGB = [.73 .23 .56];
case {31,'saddle brown','sad'}
   name = 'saddle brown';symbol ='sad';
   RGB = [.49 .19 .09];
case {32,'salmon','sal'}
   name = 'salmon';symbol ='sal';
   RGB = [.88 .55 .42];
case {33,'sandy brown','san'}
   name = 'sandy brown';symbol ='san';
   RGB = [.93 .60 .30];
case {34,'tan','t'}
   name = 'tan';symbol ='t';
   RGB = [.85 .69 .47];
case {35,'tomato','tom','tomatoe'} % Correct for potential usage by Dan Quayle
   name = 'tomato';symbol ='tom';
   RGB = [0.97 0.33 0.19];
case {36,'turquoise','tq'}
   name = 'turqoise';symbol ='tq';
   RGB = [.26 .78 .66];
case {37,'violet','v'}
   name = 'violet';symbol ='v';
   RGB = [.55 .22 .79];
case {38,'wheat','wh'}
   name = 'wheat';symbol ='wh';
   RGB = [.95 .85 .66];
case {39,'white','w'}
   name = 'white';symbol ='w';
   RGB = [1 1 1];
case {40,'yellow','y'}
   name = 'yellow';symbol ='y';
   RGB = [1 1 0];
case {41,'pims purple','pp'}
   name = 'pims purple';symbol ='pp';
   RGB = [.4 0 .6];
case {42,'pims orange','po'}
   name = 'pims orange';symbol ='po';
   RGB = [1 .6 0];  
case {0,'list'}
   disp(sprintf('%2s %20s %10s %20s %6s %6s','#','NAME','SYMBOL','R','G','B'));
   disp(sprintf('%2s %20s %10s %20s %6s %6s','-','----','------','-','-','-'));
   for i =1:NumberOfColors
      [RGB1,name1,symbol1] = convertcolor(i);
      str = sprintf('%2d %20s %10s %20.2f %6.2f %6.2f',i,name1,symbol1,(RGB1));
      disp(str);
   end
case {-1,'cell'}
      RGB = cell(NumberOfColors,1);name = cell(NumberOfColors,1);symbol = cell(NumberOfColors,1);
      for i =1:NumberOfColors
      [RGB{i},name{i},symbol{i}] = convertcolor(i);
   end
end

