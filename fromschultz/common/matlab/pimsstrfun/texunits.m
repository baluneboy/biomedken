function strTex=texunits(strWordUnits)

% TEXUNITS converts 'millig' to 'mg' and 'microg' to '\mug'
%
% strTexUnits=texunits(strWordUnits);

%Author: Ken Hrovat, 3/30/01
%$Id: texunits.m 4160 2009-12-11 19:10:14Z khrovat $

strTex=strWordUnits;
if strcmpi(strWordUnits,'millig')
   strTex='mg';
elseif strcmpi(strWordUnits,'microg')
   strTex='\mug';
end