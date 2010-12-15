function z_snap = spacebarquantization(z_spacebar_measurements,resolution,blnPlot)

% SPACEBARQUANTIZATION quantized output from spacebar "trajectory" measurements' z-component
% all units of measure must be the same (mm?)
%
% z_snap = spacebarquantization(z_spacebar_measurements,resolution,blnPlot);
%
% INPUTS:
% z_spacebar_measurements - vector of spacebar's z-component
% resolution - scalar for measurement resolution (Vicon is 2mm?)
% blnPlot - boolean scalar (1 = plot it; 0 = no plot)
%
% OUTPUTS:
% z_snap - vector of quantized z-component of spacebar's trajectory
%
% EXAMPLE:
%
% % Some constants (that are derived or reckoned from data)
% resolution = 2; % mm?
% dz = [ 240 240 240 239 238 ]; % dummy z-components of spacebar trajectory
% a = mode(dz); % or use histogram and other smarts to get this value
% mmSpacebarTravels = 4; % does spacebar travel 4mm?
% A = a + mmSpacebarTravels;
%
% % A clean pulse train of a fictional spacebar trajectory
% z_clean = [ a a a A A A A A a a A A A A a a a A A A A a a ];
%
% % "Nice" noise
% z_noise = randn(size(z_clean))/5;
%
% % The only signal we get to work with via measurement
% z_spacebar_measurements = z_clean + z_noise;
%
% % Snap it to the grid (is what she was heard to say)
% blnPlot = 1;
% z_snap = spacebarquantization(z_spacebar_measurements,resolution,blnPlot);

% Try snap2grid (not saturation) as a function that may help (maybe after other signal conditioning too)
% (there is likely better choices for how to derive gridmin and gridmax. I am thinking histogram, but for now...)
gridstep = resolution; % this represents the quantization level that we supposed
gridmin = min(z_spacebar_measurements) - gridstep; % with a little bit of a buffer down below
gridmax = max(z_spacebar_measurements) + gridstep; % and buffer above too
z_snap = snap2grid(z_spacebar_measurements,gridmin,gridstep,gridmax,0); % last arg is "lean"; we round

if ~blnPlot, return, end

% Have a look
hBlue = plot(z_spacebar_measurements,'b'); hold on
hGreen = plot(z_snap,'go');
set(gca,'ytick',gridmin-gridstep:gridstep:gridmax+gridstep)
set(gca,'ygrid','on')