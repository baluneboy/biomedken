function [b_num,a_den,fsOld,fc,fsNew,everynth]=savepadfilt(filtName);

% savepadfilt - save sptool filter structure into octave path
%
% [b_num,a_den,fsOld,fc,fsNew]=savepadfilt(filtName);
%
% Inputs: filtName - structure of filter parameters from sptool export
%
% Outputs: implicit is save of mat file
%          b_num, a_den - vectors of filter coefficients
%          fsOld - scalar for original sample rate
%          fc - scalar for new cutoff frequency
%          fsNew - scalar for down sample rate
%          everynth - scalar for downsample ratio

% Author: Ken Hrovat
% $Id: savepadfilt.m 4160 2009-12-11 19:10:14Z khrovat $

b_num=filtName.tf.num;

% Check for that the FIR filter is symmetric so the phase will be linear
if locIsNotSymmetric(b_num)
   error('filter not symmetric, so phase would not be linear')
end

a_den=filtName.tf.den;
fsOld=filtName.Fs;

specs=getfield(filtName.specs,filtName.specs.currentModule);
fc=specs.f(2)*fsOld/2;  % called Fp in sptool
FStop=specs.f(3)*fsOld; % called Fs in sptool
everynth=floor(fsOld/FStop);
fsNew=fsOld/everynth;

strPath='T:\users\khrovat\programs\octave\pad\';
strFs=strrep(sprintf('%.1f',fsOld),'.','p');
strFile=sprintf('lowpass_%ssps_%dhz',strFs,fc);
[strPath strFile]
save([strPath strFile],'-v4','b_num','a_den','fsOld','fsNew','everynth');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bln=locIsNotSymmetric(b);
len=length(b);
if ~iseven(len)
   b(ceil(length(b)/2))=[];
end
b=reshape(b,2,len/2);
b(2,:)=fliplr(b(2,:));
bln=any(diff(b));
