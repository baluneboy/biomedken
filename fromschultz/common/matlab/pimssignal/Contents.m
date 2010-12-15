% PIMSSIGNAL
%
% Files
%   dfiltfilt                  - zero-phase forward and reverse digital filtering using dfilt structure (Hd)
%   eegspectrogram             - spectrogram of EEG data, v, at sample rate of fs
%   fade                       - fades the [audio sampled] vector x
%   gent                       - generate t vector based on length of input vector & sample rate

%   getpulsemarker             - do some discrimination to get good pulse marker based on duration criteria
%   hilbert_envelope_detection - try envelope detection with hilbert transform
%   iminterpn                  - Multidimensional interpolation using Image Processing Toolbox functions.
%   imoverlay                  - Create a mask-based image overlay.
%   moveavg                    - moving average filter EXAMPLE (see movingaverage)
%   movingaverage              - moving average filter
%   newtfit                    - 3D interpolation; can be used where griddata3 fails to find a triangularization of the datagrid (x,y,z)
%   resampled_xcorr            - resampled cross-correlation?
%   rms                        - Root Mean Square.
%   saturation                 - (non-linear) function to limit output to be within saturation values range of [ymin,ymax]
%   showcoh                    - 
%   showcoh2                   - [cohmat,cohmat_noisy,F] = showcoh2(lag, noise_amp);
%   snap2grid                  - quantize output to take only values on (or snap to) the grid specified by grid inputs
%   whitenoisegen              - generate white noise with mu mean and sigma std dev
%   getleadingedgesdurations   - get plateaus (top of event marker pulses) for finding leading edges and durations
