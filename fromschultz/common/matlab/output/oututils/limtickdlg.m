function [lims,ticks]=limtickdlg(oldLims,oldTicks);
prompt={'Enter limits:';'Enter ticks:'};
def={sprintf('[ %s ]',sprintf(' %g ',oldLims));sprintf('[ %s ]',sprintf(' %g ',oldTicks))};
dlgTitle='Input For Limits & Ticks';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
eval(['lims=' answer{1} ';']);
eval(['ticks=' answer{2} ';']);