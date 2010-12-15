strFile='aris_onboard_fig2';
hgload(strFile);
h=guihandles(gcf);
ff=get(h.Line11,'xd');
gg=get(h.Line11,'yd');
rr=get(h.LineISS11,'yd');
xx=get(h.LineISS11,'xd');

hold on
for i=1:2:length(ff)
   f=ff(i:i+1);
   g=gg(i:i+1);
   r=rr(i);
   x=[f fliplr(f)];
   y=[g 3e-16 3e-16];
   if g(1)<r
      c=[0 1 0];
   else
      c=[1 0 0];
   end
   patch(x,y,c);
   set(gca,'xscale','log')
end

hc=copyobj(h.LineISS11,gca);
delete(h.LineISS11);
