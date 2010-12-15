function a = removezerorows(a)
% EXAMPLE
% a = [
%           1 2 3
%           0 0 0
%           4 5 6
%           0 0 0
%           7 8 9
%      ]
% b = removezerorows(a)
iZeroRows = find(all(a==0,2));
a(iZeroRows,:) = [];
