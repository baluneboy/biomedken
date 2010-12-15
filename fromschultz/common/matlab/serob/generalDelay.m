function [timeon, sampleon, timeoff, sampleoff]=generalDelay(signal, sensitivity, oneboth, plot_sig, fs, filter, highlow, TH_0, crossDur, min_sample, platDur, platVar, TH_f, crossDur_f, min_sample_f, platDur_f, platVar_f)

% This function is designed to detect when a signal crosses a specified
% threshold.  It ensures genericity by using an utterly uncalled for number 
% of optional input variables.
%
% The optional input arguements include:
% sensitivity, oneboth, plot_sig, fs, filter, highlow, TH_0, crossDur,
% min_sample, platDur, platVar, TH_f, crossDur_f, min_sample_f, platDur_f, 
% platVar_f)
% 
% For example, when velocity exceeds .02 m/s^2, the time returned
% will specify the end of reaction time and the begining of movement time. 
% Likewise, when velocity drops below a certain value, end of move time 
% can also be detected.
%
% Example call:
% trapezoidal signal
% signal(1:19)=0;
% signal(20:39)=3.*(1:20);
% signal(40:59)=3*20;
% signal(60:79)=3.*(20:-1:1);
% signal(80:100)=0;
% [timeon, sampleon, timeoff, sampleoff]=generalDelay(signal, .05, 'both', 'yes', 100, 'no')
% 
% Or
% [i x y vx vy fx fy
% fz]=roboread('U:\data\upper\eeg_emg_rob\s1349plas\pre\se_robotics\one_slot_102834_Nt38.dat');
% [timeon, sampleon]=generalDelay(y, .02, 'one', 'yes', 200, 'no','high')
%
% INPUTS:
% signal- May be any signal.
%
% sensitivity* - A percentage from 0 to 1.  This percentage of the maximum
% amplitude will be used as the threshold.  However, explicitly specifying 
% a TH_0 (a later arguement) in the function call will override any 
% sensitivity specified in this arguement _UNLESS_ TH_0 is 
% specified as 0. Default is .03.
%
% oneboth* - Choose "one" or "both".  Choosing "one" will return the
% detection of timeon and sampleon but timeoff and sampleoff will be NaN.
% Choosing "both" will return the detection of all four output variables
% for the start and end of activity.  Default is one.
%
% plot_sig* - Choose "yes" or "no".  If yes, a new figure with a graph of the
% signal and vertical lines indicating the start and stop (if applicable) 
% of detected activity will be displayed.  Default is no.
%
% fs*- sample rate.  Default is SE robot sample rate of 200.
%
% filter* - choose "yes" or "no" to have the signal smoothed with a low pass
% butterworth filter.  Good for avoiding the detection of false starts, but 
% results in less accuracy in detection.  Defalut is no filtering.  
% Enabling plot_sig can help determine wether filtering is necessary.
%
% highlow*- choose "high" or "low".  "High" specifies that the signal value
% must exceed the threshold, "low" specifies that the signal must drop below
% the threshold.  Default will choose based on wether signal's most extreme
% excursion is in the positive or negative direction.
%
% TH_0* - Threshold value over or under which will specify the begining of 
% activity of interest.  If not specified, or specified as 0, sensitivity 
% will be used to calculate TH_0.
% 
% crossdur* - The number of samples the signal should stay above or below
% the threshold to ensure that it is really the change of interest and not
% just noise. Default is one.
%
% min_sample* - Any sample less than min_sample will not be analysed for 
% threshold crossing. (eg, if there is no stimulus in the
% first 50 samples, specify 50.)  Default is one. A "max_sample" option
% could also be added to this code if the necessity ever arose, to 
% stop the search for threshold crossing after a certain point.
% 
% platDur* - If there should be some quiet period before the signal crosses
% the threshold (a "plateau") then specify the minimum duration (in
% samples) of this plateau.  The plateau will be sought after the minimum
% specified sample. 
%
% platVar* - In the plateau region, what is the acceptable noise variance?
% (If the average resting value is 3 +/- .5, specify .5.) Default value is
% TH_0.
%
% TH_f* - Threshold value for detection of end of activity, such as a return
% to a resting baseline.  The default is the TH_0 value.
%
% crossdur_f* - The number of samples the signal should stay above or below
% the end threshold to ensure that it is really the change of interest and 
% not just noise. Default is one.
%
% min_sample_f* - Any sample less than min_sample will not be analysed for 
% end threshold crossing.  Default is the return value timeon.  This way, 
% the end of the activity cannot be detected before the start of activity.
%
% platDur_f* - If there should be some quiet period before the signal crosses
% the end threshold (a "plateau") then specify the minimum duration (in
% samples) of this plateau. Default is 1.
%
% platVar_f* - In the plateau region, what is the acceptable noise variance?
% (If the average resting value is 3 +/- .5, specify .5.)  Default value is
% TH_f.
%
% *optional input
%
% OUTPUT:
% timeon- onset in seconds
% sampleon- onset in samples
% timeoff- end of activity in seconds
% sampleoff- end of activity in samples
%

%
% Compiled by Morgan Clond
% May 2008
% $ID$

default_synch_config;
fsdefault=fsROB; %If no sample rate is entered

if nargin==0
    error('At least one input is required.')
end
sampleon=NaN;

if nargin<=5  %filter first, so that we choose a realistic percent of peak as the threshold
    filter='no';
end
if nargin<=4
    fs=fsdefault;
end

N=(1:length(signal)); %Samples
t=N./fs; %time scale: samples/(samples/sec)

if strcmp(filter, 'yes')==1
    unfilt=signal; %store original signal for the graph
    signal=generalFilter(signal, fs);
end

%start by shifting the minimum (local minimum, before the peak) to zero
[Y,I]=max(signal);
early_signal=signal(1:I);
offs=min(early_signal);
if min(early_signal)<0  %Then we're going to add offs to set baseline on zero
    signal=signal+offs;
elseif min(early_signal)>0
    signal=signal-offs;
end

%Don't clean up the following argument order.  TH_0 must be determined
%first.
if nargin==17 %all options are specified.  No need to calculate any variables
end 
%set up start of activity detection variables
if nargin==1
    sensitivity=.03;
end
if nargin<=7  %(TH_0 is the 8th input)
    TH_0=max(signal)*sensitivity;
end
if nargin<=8
    crossDur=1;
end
if nargin>=8
    if TH_0==0; %Then don't override sensitivity
        TH_0=max(signal)*sensitivity; 
    end
end

if nargin<=11
    platVar=TH_0;
end
% subplot(2,2,2)
% hold on
% plot(0:1/10:500,TH_0,'r')
% plot(0:1/10:500,platVar,'r')
% plot(0:1/10:500,-platVar,'r')
% plot(1:length(signal),signal,'b')
if nargin<=10
    platDur=1;
end
if nargin<=9
    min_sample=2; %it is two because it has to check for a plateau of 1 at least
end
if nargin<=6 % Then you have to decide high or low on your own.  
    avesig=mean(signal);
    [upbound, ubind]=max(signal);   %Detect the min and max of the signal
    [lowbound, lowbind]=min(signal); 
    updiff=abs(upbound)-abs(avesig); %Figure out the differences between the average and the min and max
    lowdiff=lowbound-abs(avesig);
    if updiff>lowdiff  % signal spikes high
        highlow='high';
    else
        highlow='low';  % signal spikes low
    end
end

%find signal > TH_0 lasting more than crossDur after period of platDur with
%value no more or less than than platVar

if strcmp(highlow, 'high')==1
    for i=min_sample+platDur:length(signal)-crossDur
        if platDur>i  %you want a plateau, so i has to start at the
            % plateau length
            i=platDur+1;
        end        
        %we want only the part of platDur that is greater than 
        %zero and less than i.
        %if the signal is above the threshold and satisfies plateau
        %requirement
        if signal(i)>=TH_0...  
            && length(unique(signal(i+1:i+crossDur)>=TH_0))==1 ... 
            && length(signal(i-platDur:i-1)>=(-platVar))==length(i-platDur:i-1) ...
            && length(signal(i-platDur:i-1)<=(platVar))==length(i-platDur:i-1) ...
%             subplot(2,2,2)
%                 hold on
%                 plot(i-platDur,0:1/1000:.3,'b')
            sampleon=i-1; 
        break
        end
        if i==length(signal)
            sampleon=NaN;  
        end
    end
elseif strcmp(highlow,'low')==1
    for i=min_sample:length(signal)
        if signal(i)<=TH_0...
            && length(unique(signal(i+1:i+crossDur)<=TH_0))==1 ...
            && length(signal(i-platDur:i-1)>=(-platVar))==length(i-platDur:i-1)...
            && length(signal(i-platDur:i-1)<=platVar)==length(i-platDur:i-1)
            sampleon=i-1;    
        break
        end
        if i==length(signal)
            sampleon=NaN;  
        end
    end
% elseif strcmp(highlow,'either')==1
%     for i=min_sample:length(signal)
%         if abs(signal(i))>=TH_0...
%             && length(unique(abs(signal(i+1:i+crossDur))>=TH_0))==1 ...
%             && length(signal(i-platDur:i-1)>=(-platVar))==length(i-platDur:i-1)...
%             && length(signal(i-platDur:i-1)<=(platVar))==length(i-platDur:i-1)        
%             sampleon=i-1;
%         break
%         end 
%         if i==length(signal)
%             sampleon=NaN;  
%         end
%     end
end

if strcmp(num2str(sampleon),'NaN')==1
    timeon=NaN;
    warning('Threshold crossing not detected')
else
    timeon=sampleon/fs;
end

%set up end of activity detection variables
if strcmp(oneboth, 'both')==1
    if nargin<=12
        TH_f=TH_0;
    end
    if nargin<=16
        platVar_f=TH_f;
    end
    if nargin<=15
        platDur_f=1;
    end
    if nargin<=14
        min_sample_f=sampleon+1;
    end
    if nargin<=13
        crossDur_f=1;
    end
    
%detect the end
    if strcmp(highlow,'high')==1
        for f=min_sample_f+platDur_f:length(signal)-crossDur_f
            if signal(f)>TH_f...
                && length(unique(signal(f+1:f+crossDur_f)>=TH_f))==1 ...
                && length(signal(f-platDur_f:f-1)>=-platVar_f)==length(f-platDur_f:f-1)...
                && length(signal(f-platDur_f:f-1)<=platVar_f)==length(f-platDur_f:f-1)
                sampleoff=f;    
            break
            end
            if f==length(signal)
                sampleoff=NaN;
            end
        end
    elseif strcmp(highlow,'low')==1
        for f=min_sample_f:length(signal)
            if signal(f)<TH_f...
                && length(unique(signal(f+1:f+crossDur_f)<=TH_f))==1 ...
                && length(signal(f-platDur_f:f-1)>=-platVar_f)<=length(f-platDur_f:f-1)...
                && length(signal(f-platDur_f:f-1)<=platVar_f)<=length(f-platDur_f:f-1)                
                sampleoff=f;    
            break
            end
            if f==length(signal)
                sampleoff=NaN;
            end
        end
%     elseif strcmp(highlow,'either')==1
%         for f=min_sample_f:length(signal)
%             if abs(signal(f))<TH_f...
%                 && length(unique(abs(signal(f+1:f+crossDur_f))<=TH_f))==1 ...
%                 && length(signal(f-platDur_f:f-1)>=-platDur_f)==length(f-platDur_f:f-1)...
%                 && length(signal(f-platDur_f:f-1)<=platVar_f)==length(f-platDur_f:f-1)
%                 sampleoff=f;
%             break
%             end
%             if f==length(signal)
%                 sampleoff=NaN;
%             end
%         end
    end
    timeoff=sampleoff/fs;
else 
    sampleoff=NaN;
    timeoff=NaN;
end

signal=signal+offs;

if strcmp(plot_sig,'yes')==1
    figure
    plot(t, signal)
    xlabel('Time')
    ylabel('Signal Amplitude')
    title('Result of Threshold Detection')
    hold on
    if strcmp(filter,'yes')==1
        plot(t, unfilt, 'm')
    end
    dims=axis;
    if dims(4)==0 %So you don't divide zero by 1000
        dims(4)=1;
    end
    plot(timeon,dims(3):abs(dims(4)/1000):dims(4),'g')
    if strcmp(oneboth,'both')==1
        plot(timeoff,dims(3):dims(4)/1000:dims(4),'r')
        hold off
    end
end

% if strcmp(plot_sig,'master')==1  %both will be the same color...
%     subplot(1,2,2)
%     hold on
%         if strcmp(filter,'yes')==1
%         plot(t, unfilt, 'm')
%     end
%     dims=axis;
%     if dims(4)==0 %So you don't divide zero by 1000
%         dims(4)=1;
%     end
%     plot(timeon,dims(3):abs(dims(4)/1000):dims(4),'g')
%     if strcmp(oneboth,'both')==1
%         plot(timeoff,dims(3):dims(4)/1000:dims(4),'r')
%         hold off
%     end 
% end