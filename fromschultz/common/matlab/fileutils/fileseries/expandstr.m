function f=expandstr(str)
%EXPANDSTR  Expand indexed strings.
%   F = EXPANDSTR('PP[RANGE]SS') returns a cell array of strings in the form
%   'PP0000nSS', where 'PP' and 'SS' are prefix and suffix substrings, n is
%   an index lying in the range RANGE, paded with 5 zeros.  RANGE is a
%   vector, that can be in the form [N1 N2 N3..], or START:END, or
%   START:STEP:END, or all other MATLAB valid syntax.
%
%   F = EXPANDSTR('PP[RANGE,NZ]SS') also specifies the number of zeros to
%   pad the index string (NZ=5 by default). For example, 'B[1:4,2].v*'
%   gives {'B01.v*','B02.v*','B03.v*','B04.v*'}.
%
%   If the input string has more than one bracket pair [], EXPANDSTR is
%   called recursively for each pair. For example, 'B[1:4,2]_[1 2,1]'
%   gives {'B01_1','B01_2','B02_1','B02_2','B03_1','B03_2','B04_1','B04_2'}
%
%   EXPANDSTR is useful when applied to file names, e.g. with RDIR. In
%   particular, wildcards (*) may be present in PP or SS (but they are
%   kept as wildcards, i.e. they are not interpreted). For example,
%   expandstr('B[1 2 3,5]*.*') returns {'B00001*.*','B00002*.*',..}. Note
%   that EXPANDSTR is automatically called from RDIR.
%
%   Examples :
%
%   expandstr('DSC[2:2:8,4].JPG') returns
%     {'DSC0002.JPG','DSC0004.JPG','DSC0006.JPG','DSC0008.JPG'}
%
%   rdir(expandstr('B[1:10,5]*.*'))  is equivalent to rdir('B[1:10,5]*.*')
%
%   See also RDIR.


%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.01,  Date: 2005/10/04


% History:
% 2004/09/29: v1.00, first version. Replaces buildfilename.
% 2004/10/04: v1.01, works recursively when many [] are found.

error(nargchk(1,1,nargin));

f='';
p1=findstr(str,'[');
if isempty(p1),
    f=str;
else
    p1=p1(1);
    p2=findstr(str,']');
    if isempty(p2),
        error('Invalid string: Missing closing bracket '']''');
    else
        p2=p2(1);
        pp=str(1:(p1-1)); % prefix
        ss=str((p2+1):end); % suffix
        p3=findstr(str((p1+1):(p2-1)),','); 
        if length(p3),
            num=eval(str((p1+1):(p1+p3-1)));
            nz=str2double(str((p1+p3+1):(p2-1)));
            if nz>16,
                error('Invalid number of zero pading: too large.');
            end;
        else
            num=eval(str((p1+1):(p2-1)));
            nz=5; % number of zeros by default
        end;
        for i=1:length(num),
            stnum=int2str(num(i));
            if length(stnum)<nz,
                stnum=[char('0'*ones(1,nz)) stnum];
                stnum=stnum((length(stnum)-nz+1):end);
            end;
            f{i}=[pp stnum ss];
        end;
    end;
    % if brackets remain in the suffix, call again EXPANDSTR for each
    % string (and so on recursively)
    if findstr(ss,'['),
        ff={};
        for i=1:length(f),
            e=expandstr(f{i});
            ff={ff{:} e{:}};
        end;
        f=ff;
    end;
end;

