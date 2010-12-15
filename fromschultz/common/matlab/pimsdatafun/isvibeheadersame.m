function bln=isvibeheadersame(sHeader1,sHeader2);

% ISVIBEHEADERSAME true if vibe sHeader1 is "same" as vibe sHeader2 for
% purpose of splicing PAD; returns 1 if "same" and 0 otherwise
%
%bln=isvibeheadersame(sHeader1,sHeader2);
%
%Inputs: sHeader1, sHeader2 - structures for vibratory PAD headers to compare
%
%Output: bln - boolean value 1/0 for "same"/not, respectively

%Author: Ken Hrovat, 11/9/2000
% $Id: isvibeheadersame.m 4160 2009-12-11 19:10:14Z khrovat $

% These are "don't care" fields
cDontCare={'TimeZero','Gain','StationCGXYZ','ScaleFactorXYZ','BiasCoeffXYZ','GDataRecords','GDataFile','sdnDataStart','numRecords','ISSConfiguration'};

% Get fieldnames
cFields1=fieldnames(sHeader1);
cFields2=fieldnames(sHeader2);

% Find removable fields
cRemove1=intersect(cFields1,cDontCare);
cRemove2=intersect(cFields2,cDontCare);

% Remove "don't care" fields
sHeader1=rmfield(sHeader1,cRemove1);
sHeader2=rmfield(sHeader2,cRemove2);

% Compare header fields of concern
bln=isequal(sHeader1,sHeader2);
