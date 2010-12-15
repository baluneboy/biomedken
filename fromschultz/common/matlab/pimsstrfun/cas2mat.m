function m = cas2mat(cas)
% cas2mat.m - converts cell array of strings [where the strings are numbers] to matrix
% 
% INPUTS
% cas - cell array of strings where each string is a number
% 
% OUTPUTS
% m - matrix of doubles the size of cas
% 
% EXAMPLE
% cas = {'0.01'; '0.02'; '0.03'};
% m = cas2mat(cas)

% Author - Krisanne Litinas
% $Id$

m = cellfun(@str2double,cas);