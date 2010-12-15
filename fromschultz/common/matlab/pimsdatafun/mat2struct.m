function s = mat2struct(m,cas)
% mat2struct - assigns each column to a structure field named by and labels according to input cas
% 
% INPUTS
% m - mxn matrix
% cas - 1xn or nx1 cell array containing labels where each element corresponds to a column in matrix m 
% 
% OUTPUTS
% s - 1x1 structure with n fields with each field named cas{i} and containing m(:,i)
% 
% EXAMPLE
% m = magic(6);
% cas = {'one','two','three','four','five','six'};
% s = mat2struct(m,cas);

% Author:  Krisanne Litinas
% $Id: mat2struct.m 4160 2009-12-11 19:10:14Z khrovat $

for i = 1:nCols(m)
    strCmd = sprintf('%s%s%s','s.',cas{i},' = m(:,i);');
    eval(strCmd);
end

