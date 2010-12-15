function quadNum=getRLquadrant(x,y,sChase)

% For the chase game, this quantity is added to sChase in
% chaseOutcomeMeasures
% This function determines an "anatomically normalized quadrant" meaning
% that the numbers have the following meaning:
% 1- ipsilateral distal
% 2- contralateral distal
% 3- contralateral proximal
% 4- ipsilateral proximal
%
% or
% 2  |  1       1  |  2
% -------       -------
% 3  |  4       4  |  3
% RIGHT          LEFT
%
% Inputs- (x,y) of the target and sChase to specify handedness
% 
% Output: quadrant number
%
% Sample call: quadNum=getRLquadrant(x,y,vx,vy,fx,fy,fz,sChase)
%

% Author: Morgan Clond
%$ID$

quadNum = getquadrant(x,y);

if sChase.blnRight==0 %If lefty
    switch quadNum
        case 1
            quadNum=2;
        case 2
            quadNum=1;
        case 3            
            quadNum=4;
        case 4      
            quadNum=3;
    end
end
           
    