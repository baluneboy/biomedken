
secPilot=3600;
hoursRemaining=12;
sdnEndBatch=now+hoursRemaining/24;
strTitle=sprintf('Pilot Run Elapsed Time: ~%g minutes',secPilot/60);
strBatchEndTime=sprintf('%s on %s',datestr(sdnEndBatch,14),datestr(sdnEndBatch,1));
strQuestion=sprintf('Start now for batch end at ~%s (%g hrs)?',strBatchEndTime,hoursRemaining);
strButtonName=questdlg(strQuestion,strTitle,'Yes','No','No');
