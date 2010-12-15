function [sdnStart,sdnCenter,sdnStop,sdnDuration]=calcothertimes(sdnStart,sdnCenter,sdnStop,uDuration);
% Convert duration to days (if ~nan)
if ~isnan(double(uDuration))
   sdnDuration=double(convert(uDuration,'days'));
else
   sdnDuration=NaN;
end
% Get pattern of NOT NaNs
scsd=not(isnan([sdnStart sdnCenter sdnStop sdnDuration]));
strSCSD=sprintf('%d%d%d%d',scsd);
switch strSCSD
case '1100' % start center
   sdnDuration=2*(sdnCenter-sdnStart);
   sdnStop=sdnStart+sdnDuration;
case '1010' % start stop
   sdnDuration=sdnStop-sdnStart;
   sdnCenter=mean([sdnStart sdnStop]);
case '1001' % start duration
   sdnStop=sdnStart+sdnDuration;
   sdnCenter=mean([sdnStart sdnStop]);
case '0011' % stop duration
   sdnStart=sdnStop-sdnDuration;
   sdnCenter=mean([sdnStart sdnStop]);
case '0101' % center duration
   sdnStart=sdnCenter-(sdnDuration/2);
   sdnStop=sdnCenter+(sdnDuration/2);
case '0110' % center stop
   sdnDuration=2*(sdnStop-sdnCenter);
   sdnStart=sdnStop-sdnDuration;
otherwise
   error(sprintf('unexpected input pattern SCSD: %s',strSCSD))
end
