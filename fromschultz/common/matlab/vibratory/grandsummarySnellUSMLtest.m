clear all;

sdnFirst=datenum(1995,10,20);
sdnLast=datenum(1995,11,5);

i=0;
for sdn=sdnFirst:sdnLast
   i=i+1;
   Y(i)=year(sdn);M(i)=month(sdn);D(i)=day(sdn);
   cCombine{i}=[0:23];
   if i==5
      [mg95five,cp95,fs,mgBins,sNBIG,sNumHoursBIG,sText]=snellhistbatday('headc',Y,M,D,'padhist',sprintf('Snell, First Five Days, USML-2, STS-73, Head C',i),1,cCombine);
      strDayFive=datestr(datenum(Y(i),M(i),D(i)));
   end
end
[mg95all,cp95,fs,mgBins,sNBIG,sNumHoursBIG,sText]=snellhistbatday('headc',Y,M,D,'padhist',sprintf('Snell, USML-2, STS-73, Head C',i),1,cCombine);
fprintf('%s,%.1f,%s,%.1f\n',strDayFive,mg95five*1e3,datestr(datenum(Y(end),M(end),D(end))),mg95all*1e3)


