function tprintf(fids,varargin)

strFormat=varargin{1};
[otherArgs{1:length(varargin)-1}]=deal(varargin{2:end});

for i=1:length(fids)
    fid=fids(i);
    if ( fid == 1 || fid == 2 )
        fprintf(fid,strFormat,otherArgs{:})
    else
        fprintf(fid,strFormat,otherArgs{:});
    end
end
    