function cas = renamenexusfiles(strDir,casExtension,increment,range_to_change)
% EXAMPLES
% renamenexusfiles('C:\temp\20091123_c1363plas','x2d');
% renamenexusfiles('C:\temp\20091123_c1363plas','x2d',-1);
% renamenexusfiles('C:\temp\20091123_c1363plas','x2d',1,[61 100]);


for j = 1:length(casExtension)
    extension = casExtension{j};
    strPattern = ['(?<num>\d{2,3}.)(?<ext>' extension ')'];
    casFiles = getpatternfiles(strPattern,strDir,'cas');
    casFiles = sortnexusfiles(casFiles);
    
    % No incrementing
    switch nargin
        case 2
            increment = 0;
            bounds_to_change = [1 length(casFiles)];
        case 3
            bounds_to_change = [1 length(casFiles)];
    end
    
    % if incrementing up, have to do it in reverse order so files don't get
    % overwritten
    if increment > 0 
        bounds_to_change = [range_to_change(2) range_to_change(1)];
        stepsize = -1;
    elseif increment < 0 && nargin == 4
        bounds_to_change = [range_to_change(1) range_to_change(2)];
        stepsize = 1;
    end
    
    cas = {};
    
    % step through casFiles and increment/decrement
    for i = bounds_to_change(1)-1:stepsize:bounds_to_change(2)-1
        strFile = casFiles{i};
        m = regexp(strFile,strPattern,'names');
        strOldNum = m.num(1:end-1);
        strNewNum = num2str(str2num(strOldNum) + increment);
        
        switch length(strNewNum)
            case 1
                strNewNum = ['00' strNewNum];
            case 2
                strNewNum = ['0' strNewNum];
        end
        strNewFile = strrep(strFile,m.num,[strNewNum '.']);
        strNewFile = lower(strNewFile);
        cas{i} = strNewFile;
        movefile(strFile,strNewFile)
    end
    cas = cas';
    
end