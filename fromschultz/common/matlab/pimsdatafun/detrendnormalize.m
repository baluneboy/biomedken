function dnx = detrendnormalize(x)
% DETRENDNORMALIZE detrend and normalize
dx = detrend(x);
dnx = dx./(nanmax(dx(:)));