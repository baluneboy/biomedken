function casFiles = recursivelyfindfiles(strTop,strPattern)

% EXAMPLE
% strTop = 'C:\data\fmri\fromopticalmedia\temp4preone\s1372plas\13720000';
% strPattern = '.*\.dcm';
% casFiles = recursivelyfindfiles(strTop,strPattern);

%% Get parameters to work with spm_select
sFilt.code = 0;
sFilt.frames = [];
sFilt.ext = {'.*'};
sFilt.filt = {strPattern};

%% Call recurse functionality added to spm_select
casFiles = spm_select('recurse',strTop,sFilt);