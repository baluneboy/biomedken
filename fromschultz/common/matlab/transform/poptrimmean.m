function [newdata] = poptrimmean(data)

% POPTRIMMEAN calculates the trimmed mean for each column in a MxN array.
% The function returns a column vector of means of size 1xN.
%   [newdata] = mamstrimmean (datamatrix);

%  Written by Eric Kelly
%  April 14, 2001
% $Id: poptrimmean.m 4160 2009-12-11 19:10:14Z khrovat $

upperperc = 0.2; 
lowerperc = 0.5;
FilterSize = size(data,1);

% sort the array
data = sort(data);

upper=round(FilterSize*upperperc);  % used in calculation of Q
lower=round(FilterSize*lowerperc);

minusupper=FilterSize-upper+1;     
minuslower=FilterSize-lower+1;

% calculate the upper and lower averages  using sum and upper
U_num = mean(data(minusupper:FilterSize,:));
L_num = mean(data(1:upper,:));
U_den = mean(data(minuslower:FilterSize,:));
L_den = mean(data(1:lower,:));


%if ~isempty(find(U_den-L_den==0))
   %disp (['Q denominator=0']);
%end

% calculate Q 
Q=(U_num-L_num)./(U_den-L_den);
indbadQ=find(Q==Inf);

if length(indbadQ)~=0
	Q(indbadQ)=zeros(indbadQ)';
end

% calculate alpha
alpha = zeros(size(Q));
alpha(find(Q<=1.75)) = 0.05; 
Qindex = find(Q>1.75 & Q<2.0);
alpha(Qindex)= 0.05 + (0.35/0.25)*(Q(Qindex)-1.75);
alpha(find(Q>=2.0))=0.4;

% number of samples to trim from each end
trim=round(alpha*FilterSize);

% Calculate mean of trimmed end
newdata = zeros(size(data,2),1);
for i = 1:size(data,2)
  newdata(i) = mean(data(trim(i)+1:FilterSize-trim(i),i));
end


