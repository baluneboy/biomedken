% List of pcsa directories
% For each pcsa directory:
% 1. load hist2d file for freq & PSD bins
% 2. load ../<specInfo> file to get dT
% 3. add to H (and T for future work)
% 4. add to numPSDs
% After all H's & numPSD's added, imagesc
% Ancillary text with non-contiguous considered (dT*numPSDs)

% List of pcsa directories
%'T:\offline\batch\results\inc02\hirap\spectrogram\
%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp425643/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp314116/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp565223/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp105770/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp214051/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp285545/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc02/121f06/spectrogram/SAMSf_tp254955/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/121f06/spectrogram/SAMSf_tp023296/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/121f06/spectrogram/SAMSf_tp323504/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/121f06/spectrogram/SAMSf_tp223428/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc02/121f03/spectrogram/SAMSf_tp315626/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/121f03/spectrogram/SAMSf_tp551382/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/121f03/spectrogram/SAMSf_tp223396/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc03/121f03/spectrogram/SAMSf_tp360162/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc03/121f04/spectrogram/SAMSf_tp312634/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc03/hirap/spectrogram/MAMSHiRAP_tp244279/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc03/121f06/spectrogram/SAMSf_tp243599/pcsa/'};

%casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc03/121f05/spectrogram/SAMSf_tp253963/pcsa/'};

%casPCSAdirs=strrep(casPCSAdirs,'/r/tsccrusader/sdds','t:');

%casPCSAdirs={'/cvs/temp/usmp2fboast2/pcsa/'};

casPCSAdirs=strrep(casPCSAdirs,'/r/tsccrusader/sdds/','t:/');

for iDir=1:length(casPCSAdirs)
   
   % Gather path/files
   strPCSAdir=casPCSAdirs{iDir};
   fprintf('\n%s ... ',strPCSAdir)
   [strUniquePath,strName,strExt,strVer]=fileparts(strPCSAdir(1:end-1));
   [strTrash,strUniqueName,strTrash,strTrash]=fileparts(strUniquePath);
   strHist2dInfoFile=[strUniquePath filesep strUniqueName '_info'];
   strSpecInfoFile=[strPCSAdir strUniqueName '_hist2d'];
   
   % Load hist2d file for freq & PSD bins
   load(strHist2dInfoFile)
   
   % Load spectrogram info file (for temporal resolution)
   load(strSpecInfoFile)
   
   % Compute temporal resolution
   dTi=(sPlot.Nfft-sPlot.No)/sHeader.SampleRate;
   
   % Verify matching parameters
   if iDir==1
      dT=dTi;
      fBins=freqBins;
      pBins=PSDBins;
   else
      if ( dTi~=dT | all(freqBins~=fBins) | all(PSDBins~=pBins) )
         error('mismatched temporal resolutions')
      end
   end
   
   % Get list of pcsa files
   [casFilenames,sDetails]=dirdeal([strPCSAdir '*pcsa*']);
   
   % For each pcsa directory, add histogram and count info (and later T) to grand totals
   for iFile=1:length(casFilenames)
      
      strFile=casFilenames{iFile};
      
      % Load file
      fprintf('\n%s',strFile)
      load([strPCSAdir strFile])
      
      % Verify matching parameters
      if ( iDir==1 & iFile==1 )
         % Initial values
         bigH=H;
         %bigT=T;
         totalPSDs=numPSDs;
         sdnFirstStart=sHeader.sdnDataStart;
      else
         % Add to grand totals for H, numPSDs, and  (and T for future work)
         bigH=bigH+H;
         totalPSDs=totalPSDs+numPSDs;
         %bigT=[bigT T];
      end
      
   end
   
end

% Gather text
CLim=[0 2];
sText.strXType='Frequency';
sText.strXUnits='Hz';
sText.casYStub={''};
sText.casYTypes='YType';
sText.casYUnits='YUnits';
amountHours=(dT*totalPSDs)/3600;

% After all H's & numPSD's added, imagesc
%imagesc(freqBins,PSDBins,100*(bigH/totalPSDs)),axis xy,colormap(pimsmap2),colorbar
hs=plotpcsa(freqBins,PSDBins,bigH,totalPSDs,sText,'screen',CLim);
set(hs.TextUpperRight4,'str',sprintf('Total of %.1f hours',amountHours));
set(hs.TextUpperRight3,'str',sprintf('%s, %d PSDs',sPlot.Window,totalPSDs));
%set(hs.TextTitle,'str',sprintf('First Start GMT %s',popdatestr(sdnFirstStart,0)));
set(hs.TextTitle,'str','');

disp('want to call retrosavepcsa for this gcf?')