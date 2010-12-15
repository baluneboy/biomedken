function [osscomp,loccomp] = calc_ggrot_comp(T,A,cm,Ro,sHeader,sParameters,varargin)


%  This is a vectorized version of calc_gg_rot.  It calculates the gg and rotational
% acceleration components at the oss and EXPERIMENT locations.  The significant
% mathematical computations are easier to follow in calc_gg_rot.
%
%   For mapping with LVLH method:
%   [osscomp,loccomp] = calc_ggrot_comp(T,A,cm,[],sHeader,sParameters)
%                                   or
%   [osscomp,loccomp] = calc_ggrot_comp(T,A,cm,Ro,sHeader,sParameters,'LVLH')
%    
%   For mapping with all-attitude methods
%   [osscomp,loccomp] = calc_ggrot_comp(T,A,cm,Ro,sHeader,sParameters,'ALL')
%                                   or 
%   [osscomp,loccomp] = calc_ggrot_comp(T,A,cm,Ro,sHeader,sParameters)

%
% Author: Eric Kelly
% $Id: calc_ggrot_comp.m 4160 2009-12-11 19:10:14Z khrovat $
%

%  Parse the parameters
if nargin==6
   strMethod = 'ALL';
elseif nargin==7
   strMethod = deal(varargin{:});
   strMethod = upper(strMethod);
else
   disp('Wrong number of inputs to qsmap_mews!');
   return;
end

if isempty(Ro)
   strMethod = 'LVLH';
end   


% Initialize components
osscomp.gg = zeros(3,1,size(A,3));
osscomp.rot = osscomp.gg;
loccomp.gg = osscomp.gg;
loccomp.rot = osscomp.gg;

dslength = size(T,3);

%   ISS yaw,pitch,roll angles are FROM LVLH TO SSA coordinates.  PIMS method converts
%  data FROM SSA TO ANOTHER coordinate system, So we need to use the transpose of
%  the matrix

%  Create transpose of matrix to convert from SS Analysis to LVLH coordinates, T21 
T21 = permute(T,[2 1 3]);

% position vector of oss relative to CM in SS Analysis coordinates
in2m = getsf('inch','m');  % convert to meters

osspos = zeros(3,1,dslength);
osspos(1,1,:) =  in2m*(sHeader.SensorCoordinateSystemXYZ(1) - cm(1,1,:));
osspos(2,1,:) =  in2m*(sHeader.SensorCoordinateSystemXYZ(2) - cm(1,2,:));
osspos(3,1,:) =  in2m*(sHeader.SensorCoordinateSystemXYZ(3) - cm(1,3,:));

% position vector of new location relative to CM in SS Analysis coordinates
locpos = zeros(3,1,dslength);
if ~strcmp(sParameters.sMap.Name,'CM')
   locpos(1,1,:) = in2m*(sParameters.sMap.XYZ(1) - cm(1,1,:));
   locpos(2,1,:) = in2m*(sParameters.sMap.XYZ(2) - cm(1,2,:));
   locpos(3,1,:) = in2m*(sParameters.sMap.XYZ(3) - cm(1,3,:));
else
   locpos(1,1,:) = 0;
   locpos(2,1,:) = 0;
   locpos(3,1,:) = 0;
end

sf = getsf('g',sHeader.GUnits)/9.81;

if strcmp(strMethod,'LVLH'); 
   
   %This version only good in LVLH attitude
   %               [ x ]					    [ x ]
   %  gg = w0^2 *  [ y ] (1/9.81)  = sf*   [ y ]   (in g's)
   %               [-2z]					    [ z ]
   %
   %     
   %  This is the opposite of Matisaks (science/orbiter) paper.
   % Calculate magnitude of angular velocity vector w0 = sqrt(wx^2 + wy^2 +wz^2).
   % w0 is also the square root of the sum of the diagonal elements of the
   % rotational acceleration matrix divided by -2,   w02 is wo^2.
   
   w02= zeros(1,1,dslength);
   Mfactor = (A(1,1,:) + A(2,2,:) + A(3,3,:))/-2;  % w0^2
   %sf = sf*w02;
   
else 
   
   % Use the all-attitude version by default
   %This version good for all attitudes
   %                         [ x ]					     [ x ]
   %  gg =  (Ge)Re^2/Ro^3 *  [ y ] (1/9.81) =  sf* [ y ]   (in g's)
   %                         [-2z]					     [ z ]
   %  Ge is gravity at sea-level 9.81, Re is radius of earth, Ro is altitude + Re
   Ge = 9.81;
   Re = 20925672.57; % feet
   Re = Re * getsf('ft','m'); %meters
   Ro = Ro * getsf('ft','m'); %meters
   Mfactor = (Ge*Re^2)./Ro.^3; % Ge(Re^2/Ro^3);
   Mfactor = reshape(Mfactor(:,:)',1,1,size(Mfactor,1));
end

% calculate oss and new location gravity gradient components in LVLH coordinate
k = [Mfactor; Mfactor;-2*Mfactor]*(sf);
osscomp.gg = k .* multmatrixN(T21,osspos);
loccomp.gg = k .* multmatrixN(T21,locpos);

% convert gg components to SS analysis coordinates
osscomp.gg = multmatrixN(T,osscomp.gg);
loccomp.gg = multmatrixN(T,loccomp.gg);

% calculate oss and rack location rotational accleration components in SS Analysis coordinate
%k2 = (1/9.81);     % FOR g's
%k2 = (1e6/9.81);   % FOR micro-g's

k2 =  getsf('g',sHeader.GUnits)/9.81;
osscomp.rot = k2 * multmatrixN(A,osspos);
loccomp.rot = k2 * multmatrixN(A,locpos);

% if mapping to CM, simply make rackcomponents equal to zero.
if strcmp(sParameters.sMap.Name,'CM')
   loccomp.rot = zeros(size(loccomp.rot));
   loccomp.gg = zeros(size(loccomp.gg));
end

% This is if you are mapping FROM the CM ---> probably will be removed as an option
% to limit multiple mapping capability
if strcmp(sHeader.SensorCoordinateSystemName,'CM')
   osscomp.rot = zeros(size(osscomp.rot));
   osscomp.gg = zeros(size(osscomp.gg));
end

% Make the matrices  Nx3
osscomp.rot = squeeze(osscomp.rot)';
osscomp.gg = squeeze(osscomp.gg)';
loccomp.rot = squeeze(loccomp.rot)';
loccomp.gg = squeeze(loccomp.gg)';