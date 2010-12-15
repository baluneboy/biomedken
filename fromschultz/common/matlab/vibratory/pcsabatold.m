function pcsabat(t,x,y,z,winstr,freq_range,topn,nbd_in_Hz,thresh,subdir,id,df)

% PCSABAT - Batch processing for Principal Component Spectral Analysis
%           on the power spectral densities (pxx,pyy,pzz, and pvv). User
%           specifies frequency range (freq_range) to be considered
%           along with the neighborhood (nbd_in_Hz) and threshold (thresh)
%           to be used by the peak detector algorithm (see dpeaks.m).
%           Defaults are: winstr='hanning', freq_range=[0 Nyquist], topn=inf,
%           nbd_in_Hz=0.1 Hz, and thresh=0.  Implicit outputs are *.mat files
%           for dot plots.
%
% pcsabat(t,x,y,z,winstr,freq_range,topn,nbd_in_Hz,thresh,subdir,id,df)
%
% Inputs: t,x,y,z - vectors of acceleration data as provided by batch processing
%                   (gets demeaned in this function)
%         winstr - string to identify window type
%         freq_range - freq_range to consider when finding peaks
%                      of the form [minf maxf]
%         topn - the number of top spectral components to return
%         nbd_in_Hz - neighborhood of freqs used for peak detector
%         thresh - threshold used for peak detector
%         subdir - string subdirectory for implicit output files
%                  (e.g. 'iml2/headc'); pointed to by bulkanchfile.m function
%         id - string for unique identification of batch run
%         df - scalar resolution frequency for Milton's gsb4grmsvf.m program, note:
%              if it's empty, then don't run it
%
% Outputs: implicit outputs are *.mat files in directory pointed to by
%          bulkanchfile function with filenames of the form:
%          <axis><id><dddhhmmss>.mat for example, xmir2swish198180000.mat

% written by: Ken Hrovat on 3/13/96
% $Id: pcsabatold.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by: Ken Hrovat on 4/11/96 and on 4/17/96

if ~(size(t,1)<2)
   
   % 1. Error checking
   
   if ( length(x)~=length(y) | length(y)~=length(z) | length(z)~=length(t) )
      disp('PCSABAT: LENGTH OF TIME DOMAIN VECTORS t,x,y,z ARE NOT THE SAME')
      disp('Ignoring the entire input for this period.')
      return
   end
   
   % 2. Determine fs
   
   fs=1/(t(2)-t(1));
   TSpan=t(end)-t(1);
   NSpan=fs*TSpan;
   nfft=flogtwo(NSpan);
   
   if ( (length(x)<=1) | length(x)<nfft )
      fprintf('\nlength(data)=%d, while Nfft=%d, so skip this period.\n',length(x),nfft)
      return
   end
   
   t=t(1:nfft);
   x=x(1:nfft); x=x-mean(x);
   y=y(1:nfft); y=y-mean(y);
   z=z(1:nfft); z=z-mean(z);
   
   % 3. Defaults
   
   if ( isempty(winstr) )
      winstr='hanning';
   end
   if ( isempty(freq_range) )
      freq_range=[0 fs/2];
   end
   if ( isempty(topn) )
      topn=inf;
   end
   if ( isempty(nbd_in_Hz) )
      nbd_in_Hz=0.1;
   end
   if ( isempty(thresh) )
      thresh=0;
   end
   
   % 4. Calculate PSDs
   
   eval(['[pxx,f]=psdpims(x,nfft,fs,' winstr '(nfft),0);']);
   eval(['pyy=psdpims(y,nfft,fs,' winstr '(nfft),0);']);
   eval(['pzz=psdpims(z,nfft,fs,' winstr '(nfft),0);']);
   pvv=pxx+pyy+pzz;
   
   % 5. Call pcsa function
   
   deltaf=fs/nfft;
   nbd=nbd_in_Hz/deltaf;
   
   [freqx,magx]=pcsa(f,pxx,freq_range,topn,nbd,thresh);
   [freqy,magy]=pcsa(f,pyy,freq_range,topn,nbd,thresh);
   [freqzz,magz]=pcsa(f,pzz,freq_range,topn,nbd,thresh);
   [freqv,magv]=pcsa(f,pvv,freq_range,topn,nbd,thresh);
   
   % 6. Save output files
   
   [d1,h1,m1,s1]=sec2met(t(1));
   s1=fix(s1);
   samestr=[id sprintf('%03d%02d%02d%02d',d1,h1,m1,s1)];
   [one,two]=unix(['mkdir ' bulkanchfile(subdir)]);
   [one,two]=unix(['mkdir ' bulkanchfile([subdir '/v/'])]);
   [one,two]=unix(['mkdir ' bulkanchfile([subdir '/x/'])]);
   [one,two]=unix(['mkdir ' bulkanchfile([subdir '/y/'])]);
   [one,two]=unix(['mkdir ' bulkanchfile([subdir '/z/'])]);
   xcmdstr=['save ' bulkanchfile([subdir '/x/x' samestr]) ' freqx magx'];
   ycmdstr=['save ' bulkanchfile([subdir '/y/y' samestr]) ' freqy magy'];
   zcmdstr=['save ' bulkanchfile([subdir '/z/z' samestr]) ' freqzz magz'];
   vcmdstr=['save ' bulkanchfile([subdir '/v/v' samestr]) ' freqv magv'];
   eval(xcmdstr);
   eval(ycmdstr);
   eval(zcmdstr);
   eval(vcmdstr);
   
   % 7. Call gsb4grmsvf.m if desired:
   
   if ( ~isempty(df) )
      gsb4grmsvf(f,pxx,pyy,pzz,pvv,samestr,df);
   end
   
end

