cas = {...
    'Jennie Hough File.txt',...
    'HOUGH^JENNIE^^^0001.dcm',...
    'HoughJ direc',...
    'beginHOUGH^JENNIE^^^0001.dcm',...
    'beginHoughJ direc',...
    'NopeDir'...
    };

p1 = '(?<before>.*)(?<during>Jennie Hough)(?<after>.*)';
p2 = '(?<before>.*)(?<during>HoughJ)(?<after>.*)';
p3 = '(?<before>.*)(?<oldstr>HOUGH\^JENNIE)(?<after>.*)';
expr = [p1 '|' p2 '|' p3]; 

fprintf('\n')
for i = 1:length(cas)
    str = cas{i};
    loc = regexp(str, expr, 'names');
    if ~isempty(loc)
        fprintf('%s TO %s\n',str,[loc.before 'ANON' loc.after])
    else
        fprintf('skip %s\n',str)
    end
end