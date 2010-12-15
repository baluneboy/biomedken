function tpain(T,tON,vON,vOFF)

% EXAMPLE
% T = 2.8; tON = 0.5; vON = 85; vOFF = 15; tpain(T,tON,vON,vOFF);

dio = digitalio('parallel',1);
iolines = addline(dio,0:7,'out');
tOFF = T - tON;
while 1
    putvalue(dio,vOFF);
    pause(tOFF);
    putvalue(dio,vON);
    pause(tON);
end