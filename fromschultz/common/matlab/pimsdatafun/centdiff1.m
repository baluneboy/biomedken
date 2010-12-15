function dx = centdiff1(x,dim)
% CENTDIFF1 calculates first central difference

% this isn't written yet
% if ndims(x) > 2
    %     if nargin == 1
    %         dim = find(size(x) > 1,1);
    %     end
    %     if size(x,dim) < 3
    %         error('Need to have 3 or more samples for central difference');
    %     end
    % end
% else
   
% end

dx = (x(3:end)-x(1:end-2))./2;