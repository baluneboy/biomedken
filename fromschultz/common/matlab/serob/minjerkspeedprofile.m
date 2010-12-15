function v = minjerkspeedprofile(delta,t,T)

% INPUTS:
% delta - scalar distance to target (m)
% t - vector of times (sec)
% T - scalar duration of trial (sec) using 1% peak-speed threshold
%
% OUTPUTS:
% v - vector of speed for min jerk profile (m/s); per Krebs et al "1% peak-speed threshold span"
% 
% EXAMPLE
% delta = 0.14; T = 2; fs = 200; t = 0:1/fs:T;
% v = minjerkspeedprofile(delta,t,T);
% figure, plot(t,v), xlabel('time(s)'), ylabel('velocity(m/s)')

P = delta/T * [ 30/T^5 -60/T^4 30/T^3 0 0 ];
v = polyval(P,t);