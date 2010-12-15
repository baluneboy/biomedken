% VIBRATORY
%
% Files
%   batsnaptime                  - batsnaptime - coerce input serial date number times to grid times.
%   batsnaptimeday               - batsnaptime - coerce input serial date number times to grid times.
%   binitialize                  - binitialize - initialize B matrix for color spectrogram
%   binitializeday               - binitialize - initialize B matrix for color spectrogram
%   checkpadstat                 - script to check padstat routine
%   convert2ugrms                - 
%   cumpcsadensity               - This function is used to produce cumulative PCSA density plots
%   cumrms                       - - Function to compute the cumulative RMS vs. frequency
%   deltagrms                    - - Function to calculate the change in RMS accleration level given 
%   extractband                  - - Extract band of frequencies and the corresponding PSD values
%   findbands                    - findbands - use fancy indexing to find indexes into f bounded by
%   getinfofile                  - 
%   grandpcsa                    - List of pcsa directories
%   grandpcsamovie               - List of pcsa directories
%   grandpcsanew                 - grandpcsanew(strLabel,strSensor,strFirstDay,strLastDay,blnOverlay,strSkipDay1,strSkipDay2,...);
%   grandpcsanewsts107           - grandpcsanew(strLabel,strSensor,strFirstDay,strLastDay,blnOverlay,strSkipDay1,strSkipDay2,...);
%   grandpcsaold                 - List of pcsa directories
%   grandsummary1dataset1script  - 
%   grandsummary1dataset2script  - 
%   grandsummary1dataset3script  - 
%   grandsummary1dataset4script  - 
%   grandsummary1dataset5f03     - 
%   grandsummary1dataset5script  - 
%   grandsummary1inc2script      - 
%   grandsummary1inc3script      - 
%   grandsummaryfontcheckscript  - 
%   grandsummarySnellUSMLtest    - 
%   gsummary1dataset1thru5script - 
%   hist2dspec                   - hist2dspec - 2D histogram from spectrogram matrices
%   isvalidrmsbvtname            - isvalidrmsbvtname - checks for expected filename convention
%   isvibedatatype               - isvibedatatype - true if header field, DataType, has 'sams' or 'hirap'
%   isvibeheadersame             - - true if vibe sHeader1 is "same" as vibe sHeader2 for
%   MakeQTMovie                  - function MakeQTMovie(cmd, arg, arg2)
%   one3rdhist                   - ONE3RDHSIT - Function to do log10 and update histograms for each of
%   oto                          - oto - Compute 1/3 octave band RMS acceleration levels
%   otobar                       - - Function to overlay plot of 1/3 octave stat bars on top of
%   otofrompsd                   - otofrompsd - compute otogram from PSD or b matrix of PSDs (fancy indexing)
%   otogrambat                   - Set flag for super batch
%   otogrambatday                - ex.//
%   otohist                      - -  Function that loads desired 1/3 octave (oto*.mat) files
%   otomapfade                   - This is used for the OTO fade colormap
%   otomapsharp                  - This is used for the OTO sharp colormap
%   otopatch                     - 
%   otopct                       - - Function that loads desired 1/3 octave (oto*.mat) files
%   otopercentiles               - - Function that loads desired 1/3 octave (oto*.mat) files
%   otostats                     - - Function that loads desired 1/3 octave (oto*.mat) files
%   parseval                     - parseval - grms from Parseval's Theorem for PSD input(s) using
%   pcsa                         - - Performs Principal Component Spectral Analysis on
%   pcsabat                      - Set flag for super batch
%   pcsabatday                   - ex.//
%   pcsabatold                   - PCSABAT - Batch processing for Principal Component Spectral Analysis
%   pcsadensityratio             - This function is used to compute and plot the PCSA density ratio.
%   pcsagetdir                   - This function is used to read the directory for the PCSA bulk processing.
%   pcsajpegs4movie              - pcsajpegs4movie - write sequenced JPEG files from roadmap pcss files for compilation into move
%   pcsamovie                    - pcsamovie - write QT file from roadmap pcss files
%   pswindowchoice               - This function prompts the user for their windowchoice, and outputs 
%   pswindowgen                  - This function is used to generate the windows.  Inputs are the numerical value
%   ReadQTMovie                  - im = ReadQTMovie(cmd, arg)
%   rmsavst                      - rmsavst - RMS acceleration batch function which will generate RMS accel. vs. t
%   rmsbatday                    - rmsbatday(strLabel,strSensor,strFirstDay,strLastDay);
%   rvtbat                       - Set flag for super batch
%   rvtfromspecgram              - rvtfromspecgram - compute RMS acceleration for bands from PSD or b matrix of PSDs (fancy indexing)
%   rvtseriesjoin                - 
%   savepadfilt                  - savepadfilt - save sptool filter structure into octave path
%   selectcolorlim               - 
%   spacestudiesboardscript      - 
%   specbat                      - Set flag for super batch
%   specbatday                   - ex.//
%   specbatorder                 - specbatorder - chrono sort cell array of specbat files.
%   specbatorderday              - specbatorder - chrono sort cell array of specbat files.
%   specialspecbat               - Set flag for super batch
%   specone                      - ex.//
%   specpcsabatday               - ex.//
%   specpcsabatdaylocalra        - ex.//
%   specpcsarvtday               - ex.//
%   specpcsarvtdaysts107         - ex.//
%   specpcsarvtdaysts107nyq      - ex.//
%   spectrogrambat               - Get results path
%   spectrogrambatx              - 
%   specvehiclemotobatday        - specvehiclemotobatday(strSensorID,numYear,numMonth,numDay);
%   spgseriesjoin                - spgseriesjoin(hFigs,fmin,fmax); % spgseriesjoin([1 2 3],100,120)
%   superspecbat                 - Loop through lines of specbat CSV instruction file
%   tagpcsa                      - 
%   templocalra                  - ex.//
%   topdensityhits               - This function is used to analyze a density image to find the top 
%   vehiclemoto                  - otoResults=vehiclemoto(f,p,fc);
