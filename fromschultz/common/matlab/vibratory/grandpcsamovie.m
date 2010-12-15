% List of pcsa directories
% For each pcsa directory:
% 1. load hist2d file for freq & PSD bins
% 2. load ../<specInfo> file to get dT
% 3. add to H (and T for future work)
% 4. add to numPSDs
% After all H's & numPSD's added, imagesc
% Ancillary text with non-contiguous considered (dT*numPSDs)

% List of pcsa directories
%casPCSAdirs={'T:\offline\batch\results\inc02\hirap\spectrogram\MAMSHiRAP_tp314116\pcsa\';
%'T:\offline\batch\results\inc02\hirap\spectrogram\MAMSHiRAP_tp105770\pcsa\';...
casPCSAdirs={'/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp425643/pcsa/'};
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp314116/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp565223/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp105770/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp214051/pcsa/';
%   '/r/tsccrusader/sdds/offline/batch/results/inc02/hirap/spectrogram/MAMSHiRAP_tp285545/pcsa/'};

iFrame=1;
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
      else
         % Add to grand totals for H, numPSDs, and  (and T for future work)
         bigH=bigH+H;
         totalPSDs=totalPSDs+numPSDs;
         %bigT=[bigT T];
      end
      
      % Movie frame of imagesc
      imagesc(freqBins,PSDBins,100*(bigH/totalPSDs),[0 2]),axis xy,colormap(pimsmap2),colorbar
      
      % Ancillary text with non-contiguous considered (dT*numPSDs)
      amountHours=(dT*totalPSDs)/3600;
      title(sprintf('Total PSDs: %d, Total Hours: %.1f',totalPSDs,amountHours));
      
      oa=axis;
      axis([oa(1:2) -14 -3]);
      M(iFrame)=getframe;
      iFrame=iFrame+1;
      
   end
   
end

echo on
movie(M)
echo off
