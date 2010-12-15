function pcsamovie(strFirstDay,strLastDay,strSensor,varargin);

% pcsamovie - write QT file from roadmap pcss files
%
% pcsamovie(strFirstDay,strLastDay,strSensor[,axLims]);
%
% Inputs: strFirstDay, strLastDay - string for first/last day range (like '2-Dec-2002')
%         strSensor - string for sensor
%
% Output: implicit - file written in www/plots/movie directory

%T:\offline\batch\results\year2002\month11\day27\121f02\padspec\roadmaps_pcsa\2002_11_27_121f02_pcsa_roadmaps.mat
%t:\offline\batch\results\year2002\month11\day01\121f02\padspec\roadmaps_pcsa\2002_11_01_121f02*

blnDoneOne=0;
strBasepath='t:\offline\batch\results\';
sdnFirst=datenum(strFirstDay);
sdnLast=datenum(strLastDay);

str=popdatestr(sdnFirst,-2);str=str(1:end-13);
str1=strrep(str,':','_');
str=popdatestr(sdnLast,-2);str=str(1:end-13);
str2=strrep(str,':','_');
strMovieFile=sprintf('%sthru%s_%s_pcsa_%dd.mov',str1,str2,strSensor,round(sdnLast-sdnFirst));
MakeQTMovie('start',strMovieFile);

for sdn=sdnFirst:sdnLast
   y=year(sdn);
   m=month(sdn);
   d=day(sdn);
   u=filesep;
   strFile=sprintf('%syear%4d%smonth%02d%sday%02d%s%s%spadspec%sroadmaps_pcsa%s%4d_%02d_%02d_%s_pcsa_roadmaps.mat',strBasepath,y,u,m,u,d,u,strSensor,u,u,u,y,m,d,strSensor);
   if exist(strFile)==2
      %plotpcsa
      str=sprintf('  getframe for %s :)',strFile);
      load(strFile)
      hs=plotpcsa(freqBins,PSDBins,H,NUMPSDS,sText,'screen',[0 2]);
      blnDoneOne=1;
      [iLeft,iRight,strDelimited]=finddelimited('(',' Hz)',sText.casUL{2},1);
      strCutoff=strrep(strDelimited,'.','p');
   else
      %plotblanktitle
      str=sprintf('blanktitle for %s :(',strFile);
      sText.casUL{1}=['sys, ' strSensor ' at Location:[coords (in)]'];
      sText.casUL{2}='SampleRate (CutoffFreq)';
      sText.casUL{3}='\Deltaf =  Hz,  Nfft = ';
      sText.casUL{4}='Temp. Res. = sec, No = ';
      sText.strXType='Time';
      sText.casYStub={'\Sigma'};
      sText.strXUnits='hours';
      sText.strComment=strSensor;
      sText.casUR{1}='Increment:  , Flight: ';
      sText.casUR{2}='Sum';
      sText.casUR{3}='Hanning, k = 0';
      sText.casUR{4}='0 hours';
      sText.strTitle=['GMT ' datestr(sdn,1)];
      sText.strVersion='version';
      if blnDoneOne
         hs=plotpcsa(freqBins,PSDBins,zeros(size(H)),0,sText,'screen',[0 2]);
      end
   end
   %getframe(hFig)
   if nargin==4
      axLims=varargin{1};
      axis(axLims);
   end
   %hLine=line([110 110],[-12 -4]);
   %set(hLine,'linestyle',':','color',0.77*[1 1 1]);
   MakeQTMovie('addfigure')
   close(gcf);
   fprintf('%s\n',str)
end

fps=2; % default is 10
MakeQTMovie('framerate', fps);
MakeQTMovie('finish')
MakeQTMovie('cleanup')
