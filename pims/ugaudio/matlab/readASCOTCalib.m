function [biases,sfactors] =  readASCOTCalib(fn)
%  This function reads in an ASCOT calibration file and outputs a 
%  the biases and scalefactor text suitable for copy and paste 
%  into TSHESAccel.config 
% 
%  IMPORTANT: This file adjusts scalefactor and bias values for ASCOT
%  error.
%
%  NOTE: This function should be run in Linux environment to have 
%  Scientific notation to be 2 decimals.  In window it is three.
%  i.e. 1.23456E-07  vs. 1.234567E-007
%
% Version 1.0 - EK

xdoc = xmlread(fn);

calib = xdoc.getElementsByTagName('Calibration');

allAxes = calib.item(0).getElementsByTagName('axis');
thisTsh = calib.item(0).getElementsByTagName('tsh');
thisDesc = calib.item(0).getElementsByTagName('description');
thisDate  = calib.item(0).getElementsByTagName('start');

tshid = char(thisTsh.item(0).getAttribute('ID'));
desc = char(thisDesc.item(0).getFirstChild.getData());
startdate = char(thisDate.item(0).getFirstChild.getData());

sfactors = struct('x',zeros(1,5),'y',zeros(1,5),'z',zeros(1,5));
biases = struct('x',zeros(1,5),'y',zeros(1,5),'z',zeros(1,5));

% Step through the Axes (X,Y,Z)
for i = 0:allAxes.getLength-1
    thisAxis = allAxes.item(i);
    axis_name = lower(char(thisAxis.getAttribute('name')));
    allGains = thisAxis.getElementsByTagName('gain');
    
    %Step through the gains
    for j = 0:allGains.getLength-1
        thisGain = allGains.item(j);
        gain_value = thisGain.getAttribute('value');
        gain = str2double(gain_value);
        
        strFormat = 'Axis %s, Gain %s';
        strout =  sprintf(strFormat,char(axis_name),char(gain_value));
        
        %Get Bias
        thisBias = thisGain.getElementsByTagName('bias');
        thisSystemBias = thisBias.item(0).getElementsByTagName('system');
        btemp = thisSystemBias.item(0).getFirstChild.getData();
        b = str2double(btemp);
        b = b /(gain^2);  %Adjust for ASCOT error
        biases.(axis_name)(j+1)= b;
        
        %Get Scalefactor
        thisScaleFactor = thisGain.getElementsByTagName('scalefactor');
        thisSystemSF = thisScaleFactor.item(0).getElementsByTagName('system');
        stemp = thisSystemSF.item(0).getFirstChild.getData();
        s = str2double(stemp);
        s = s /(gain^2);%Adjust for ASCOT error
        sfactors.(axis_name)(j+1) = s;
        
    end
end

%Print it out
strOut = sprintf('Calibration values for %s\nDate:%s\nDescription:%s',tshid,startdate,desc);
strOut = sprintf('%s\nCut-n-paste text between dotted lines (non-inclusive)\n------------------- BEGIN -------------------',strOut);
strOut = sprintf('%s\nscales_x = %8.6E, %8.6E, %8.6E, %8.6E, %8.6E',strOut,sfactors.x);
strOut = sprintf('%s\nscales_y = %8.6E, %8.6E, %8.6E, %8.6E, %8.6E',strOut,sfactors.y);
strOut = sprintf('%s\nscales_z = %8.6E, %8.6E, %8.6E, %8.6E, %8.6E',strOut,sfactors.z);

strOut =  sprintf('%s\n\nbiases_x = %8.6E, %8.6E, %8.6E,%8.6E,%8.6E',strOut,biases.x);
strOut =  sprintf('%s\nbiases_y = %8.6E, %8.6E, %8.6E,%8.6E,%8.6E',strOut,biases.y);
strOut =  sprintf('%s\nbiases_z = %8.6E, %8.6E, %8.6E,%8.6E,%8.6E',strOut,biases.z);
strOut = sprintf('%s\n',strOut,'-------------------- END --------------------');

disp(strOut);
end


