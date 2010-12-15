disp('NEED: [fBig,yBig]=ginput; % with various zooms')

echo on
%need this to happen first
%» fBig=[];yBig=[];
%» axis([51.45 75 oa(3:4)])
%» [f,y]=ginput;fBig=[fBig(:)' f(:)'];yBig=[yBig(:)' y(:)'];
%» axis([69.5 100 oa(3:4)])
%» [f,y]=ginput;fBig=[fBig(:)' f(:)'];yBig=[yBig(:)' y(:)'];
%» axis(oa)
%» tagpcsa
echo off

h=guihandles(gcf);
BtenFlip=flipud(get(h.Image11,'cdata'));
F=get(h.Image11,'xdata');

for i=1:length(fBig);
   [d,iF]=min(abs(F-fBig(i)));
   xPos=F(iF);
   hText(i)=text(xPos,yBig(i)+0.2,sprintf('%.1f Hz',fBig(i)));
   set(hText(i),'fonts',6,'rot',90)
end