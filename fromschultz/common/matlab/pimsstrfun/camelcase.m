function s = camelcase(cas)
% CAMELCASE use underscore as delimiter to convert input to camelcase
%
% EXAMPLE
% cas = {'one','two'};
% cas = strcat('ax_',cas);
% s = camelcase(cas)
s = regexprep(cas, '_+(\w?)', '${upper($1)}');