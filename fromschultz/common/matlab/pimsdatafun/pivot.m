function [d,m] = pivot(strFileXLSin,strFileXLSout)

% % EXAMPLE
% % NOTE: FIRST COLUMN SHOULD BE ARBITRARY ASCENDING SORTED ID # (WHY?)
% % NOTE: COLUMN HEADING SHOULD NOT HAVE UNDERSCORES AND OTHERWISE BE
% %       MATLAB VARIABLE COMPATIBLE STRING
% strFileXLSin = 'C:\_workcopy\common\matlab\pimsdatafun\pivot_example.xlsx';
% strFileXLSout = 'C:\_workcopy\common\matlab\pimsdatafun\pivot_example_output.xlsx';
% [d,m] = pivot(strFileXLSin,strFileXLSout);

d = dataset('XLSFile',strFileXLSin,'ReadObsNames',true);
m = grpstats(d,{'subject','task','session','type'},{'min'},'datavars',{'rsquared','ydist'});
export(m,'xlsfile',strFileXLSout);
