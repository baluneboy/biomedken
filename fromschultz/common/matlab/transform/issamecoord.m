function [issame]= issamecoord(sCoord1,sCoord2,varargin)

% ISSAMECOORD compares two different coordinate systems to see if they are the same.  ISSAMECOORD
% returns a 1 if they are the same, and a 0 if they are not.  A coordinate system structure has the
% fields, Name,Comment,PYR,XYZ,Time. By default, sCoord1=sCoord2 sCoord1.PYR =sCoord2.PYR and 
% sCoord1.XYZ =sCoord2.XYZ.  If the flag 'exact' is used, all fields must be equal.
%
%
% [issame] = issamecoord(sCoord1,sCoord2);          Only fields PYR and XYZ need to be equal
% [issame] = issamecoord(sCoord1,sCoord2,'exact');  Name,Comment,PYR,XYZ and Time need to be equal
%        

%Inputs: sCoord1,sCoord2 = structures describing coordinate systems
%        strFlag = optional flag to require all fields to be equal
%
%Outputs: issame - 1 if equal, 0 if not equal
% 
%  Author Eric Kelly
% $Id: issamecoord.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Distribute inputs
if nargin==3
   strFlag = varargin{1}
elseif nargin==2
   strFlag= 'PYRXYZ';
end

issame1=0;
issame2=0;
issame=0;

% Check RPY and XYZ
issame1 = isequal([sCoord1.PYR sCoord1.XYZ],[sCoord2.PYR sCoord2.XYZ]);

% compare the structures
if ~strcmp(strFlag,'exact')
   issame2 = 1;
else
  issame2 = isequal({sCoord1.Name,sCoord1.Comment,sCoord1.Time},{sCoord2.Name,sCoord2.Comment,sCoord2.Time});
end

issame = issame1*issame2;


   
 