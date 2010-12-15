function [vprime, angles_deg] = vectortransform(v, a, b, t)
% vectortransform - routine that transforms vector from A frame to B frame
%                   coordinates
%
% INPUTS:
% v - vector (nx3) in A coordinates (should be unit length)
% a - 3x3xn matrix containing [i j k]' unit vectors for A frame for n
% number of sample points (if A is static, just need 3x3)
% b - 3x3xn matrix containing [iprime jprime kprime]' unit vectors for B
% frame for n number of sample points
% t - 3x1xn translation vector from frame A to frame B 
%
% OUTPUTS:  
% vprime - 3x1xn matrix containing vector in B coordinates 
% angles_deg - 3x1xn matrix containing angles (in degrees) from positive 
% iprime, jprime, and kprime axes
%
% EXAMPLE
% v = rand(3,4);
% a = eye(3);
% b = rand(3,3,4);
% t = zeros(3,1,4);
% [vprime, angles_deg] = vectortransform(v, a, b, t);
% 
% NOTES:
% Flexion axis:  90 - acosd(vprime(3))

% AUTHOR:  Krisanne Litinas

% Check for dimension requirements of v and t
if size(v, 1) == 1
    v = v';
end

if size(t, 1) == 1
    t = t';
end


if size(a,3) == 1
    i = a(1,:);
    j = a(2,:);
    k = a(3,:);
    iM = bsxfun(@times, repmat(i,3,1), ones(size(b)));
    jM = bsxfun(@times, repmat(j,3,1), ones(size(b)));
    kM = bsxfun(@times, repmat(k,3,1), ones(size(b)));
end


% Get rotation matrix abR
abR = [dot(iM,b,2) dot(jM,b,2) dot(kM,b,2)];
abR(4,:,:) = zeros;
t(4,:,:) = ones;

% Does calculation of vprime = abR*v + t
abRT = [abR t];
v(4,:) = ones;
v = reshape(v, [4 1 size(b,3)]);
vprime = ndfun('mult', abRT, v);
vprime(4,:,:) = [];

% Get angles from i', j', k' axes using vprime direction cosines
angles_deg = acosd(vprime);

