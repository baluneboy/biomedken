function casNew = cassplit(cas, strSplitter)
% cassplit - splits each element of cell array of strings using a splitter
% 
% INPUTS
% cas - nx1 cell array of strings to be split
% strSplitter - string, where you want the rows to be split
% 
% OUTPUTS
% casNew - nxm cell array of strings, where m is the result of split
% 
% NOTE
% I'm in a hurry, so this only works if there is the same number of
% splitters in each row.
% 
% EXAMPLE
% cas = {'one\two\three'; 'four\five\six'};
% casNew = cassplit(cas,'\')

% Author - Krisanne Litinas
% $Id$

% Split and unnest the cellfun-determined result
casSplitter = repmat({strSplitter},size(cas));
casNest = cellfun(@strsplit,casSplitter,cas,'uni',false);
casUnnested = unnestcell(casNest);

% Determine size of output cas
numOutputRows = nRows(cas);
numOutputCols = numel(casUnnested)/numOutputRows;

% Reshape and transpose [kind of clumsy]
casReshaped = reshape(casUnnested,numOutputCols,numOutputRows);
casNew = casReshaped';
