function dirlist = getsubdirs(dirname)
%GETSUBDIRS Recursively get all subdirectories of a directory

fs = filesep;

files = dir(dirname);
subdirs = files(logical([files.isdir]));

dirlist = {dirname};
%  ~strcmp(this,'..') strcmp(this(1),'h')

if ~isempty(subdirs)
    for n = 1:length(subdirs)
        % Short circuit directories on the stop list
        this = subdirs(n).name;
        if      ~strcmp(this(1),'@') && ...
                ~strcmp(this,'.') && ...
                ~strcmp(this,'..')
            dirlist = [dirlist; ...
                getsubdirs([dirname fs this])];
            % disp([dirname filesep this])
        end
    end
end

