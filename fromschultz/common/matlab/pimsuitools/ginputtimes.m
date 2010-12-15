function [casTimes,sdnTimes]=ginputtimes;

h=guihandles(gcf);
strRawTime=get(h.TextTitle,'str');
iKeep=find(ismember(strRawTime,'0.123456789:'));
strTime=strRawTime(iKeep);
sdnStart=popdatenum(strTime);

[t,y]=ginput;

hAx=h.Axes11;
strXLabel=get(get(hAx,'xlabel'),'str');
[iLeft,iRight,strDelimited]=finddelimited('(',')',strXLabel,1);

tdays=double(convert(t*units(strDelimited),'days'));

sdnTimes=sdnStart+tdays;

casTimes={};
for i=1:length(sdnTimes)
   casTimes{i}=popdatestr(sdnTimes(i),0);
end
