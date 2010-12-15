function [same,different,diffvals] = nancomparestructs(A,B)
%NANCOMPARESTRUCTS compares two structures of the same size and determines which fields are the same, and which are different; returns a structure of fields which are different to faciliate comparisons.
%This is useful for comparing properties (ex: tmp1 = get(axes1);tmp2=get(axes2); [same, different] = nancomparestructs(tmp1,tmp2))
%to see how an item has changed.
% NaNs are usually never equal when compared by ==, BUT THEY ARE HERE!

if nargin ~= 2 | ~isstruct(A) | ~isstruct(B)
    error('NANCOMPARESTRUCTS requires 2 input arguments, each of which must be a structure.')
end
namesA = fieldnames(A);
namesB = fieldnames(B);
same = cell(size(namesA));
different = cell(size(namesA));

if length(namesA)~=length(namesB)
    error('Structures are of different size.');
end
if isequal(A,B)
    same = namesA;
    different = [];
    diffvals = [];
    return
else
    for ii = 1:length(namesA)
        if isequal(getfield(A,namesA{ii}),getfield(B,namesA{ii})) | (and(isnan(getfield(A,namesA{ii})),isnan(getfield(B,namesA{ii}))))
            same{ii} = namesA{ii};
        else
            different{ii} = namesA{ii};
        end
    end
end

same(cellfun('isempty',same))=[];
different(cellfun('isempty',different))=[];
if ~isempty(different)
    diffvals = struct('Structure_Names',{{inputname(1),inputname(2)}},different{1},{{getfield(A,different{1}),getfield(B,different{1})}});
    for ii = 2:length(different)
        diffvals=setfield(diffvals,different{ii},{getfield(A,different{ii}),getfield(B,different{ii})});
    end
end