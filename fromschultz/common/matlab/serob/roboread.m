function [i,x,y,vx,vy,fx,fy,fz,varargout]=roboread(strFile)
% ROBOREAD - read binary robotics data file (rob or gam dat files)
%
% INPUTS:
% strFile - string for binary dat file to read (either rob or gam dat file)
%
% "rob" OUTPUTS:
% index - vector of index values (that can be converted to time via sample
%         rate, which is nominally fs=200, so times=index./fs)
% x,y - vectors of robot x,y position (m) wiht origin at center of
%       workspace
% xvelocity, yvelocity - vectors of x,y velocities (m/s)
% xforce, yforce, zforce - vector of x,y,z forces (in N?)
% grasp - vector of ask Mark
% event - vector of event marker info
%
% "gam" OUTPUTS:
% index - vector of index values (that can be converted to time via sample
%         rate, which is nominally fs=200, so times=index./fs)
% x,y - vectors of robot x,y position (pixels) with origin at upper left of
%       display with y increasing downward and x increasing to the right
% xtargetcenter,ytargetcenter - vectors of x,y position (pixels) of target
% event - vector of event marker info
% radius - vector of radius (the longer a target goes without touching
%          robot cursor edge, the larger the radius becomes)
%
% "rob" EXAMPLE:
% strRobFile='d:\temp\robotics_sample\20061026_Thu\chase_rob_132201_ball_11.dat';
% [ind,x,y,vx,vy,fx,fy,fz,grasp,event]=roboread(strRobFile);
%
% "gam" EXAMPLE:
% strGamFile='d:\temp\robotics_sample\20061026_Thu\chase_gam_132201_ball_11.dat';
% [index,x,y,xtargetcenter,ytargetcenter,event,radius]=roboread(strGamFile);
%
% SEE ALSO: roboparse.pl (note - current iteration no longer depends on roboparse.pl; see comments)
%
% NOTE: Here are column headings [optional in brackets are sometimes present]
% 1 2 3 4  5  6  7  [8  9     10]
% i x y vx vy fx fy [fz grasp evt]
%
% TYPICAL ARE THESE:
% 1 2 3 4  5  6  7  8
% i x y vx vy fx fy fz

% SPECIAL CASE (gam file for visual tracking)
% 1 2 3 4
% j a b k
%
% where...
% i - index
% x,y - position for x- and y-axis
% vx,vy - velocity for x- and y-axis
% fx,fx,fz - force for x-, y- and z-axis
% grasp - grasp data [unknown to me how to interpret]
% evt - event marker
%
% in "gam" files, we have these (visual tracking)
% j - index before target presented
% a,b - position for x- and y-axis of target
% k - index after target presented (should just about match j)

% AUTHOR: Ken Hrovat
% $Id: roboread.m 4160 2009-12-11 19:10:14Z khrovat $

% If ASCII file, then dlmread
[strPath,strName,strExt,strVer]=fileparts(strFile);
if strcmpi(strExt,'.asc')
    m=dlmread(strFile);
    switch nCols(m)
        case {7,8}
            [x,y,vx,vy,fx,fy,fz]=deal(m(:,1),m(:,2),m(:,3),m(:,4),m(:,5),m(:,6),m(:,7));
        otherwise
            error('%d is unexpected number of columns in %s',nCols(m),strFile)
    end
    i=(1:length(x))';
    % Deal outputs
    switch nargout
        case 8
            % no grasp or evt outputs
        case 9
            varargout{1}=grasp;
        case 10
            varargout{1}=grasp;
            varargout{2}=evt;
        otherwise
            error('unaccounted for number of output args')
    end
    return
end

%%%%%% REPLACED WITH CALL TO ROBOREAD_HDR %%%%%%

% % Call perl parse script
% strBytesCols=perl('roboparse.pl',strFile);
% 
% % Get bytes and columns from perl output
% A=sscanf(strBytesCols,'%d,%d');
% bytes=A(1);
% cols=A(2);
% 
% % Open binary file and read doubles in little-endian format
% fid=fopen(strFile,'r','l');
% status=fseek(fid,bytes,'bof');
% M=fread(fid,'double');
% fclose(fid);
% 
% % Check for data integrity
% if isempty(find(floor(M(1:cols:end))-M(1:cols:end), 1))
%     % Reshape for column-wise data, discard incomplete data at end
%     M = M(1:floor(length(M)/cols)*cols);
%     data=reshape(M,cols,length(M)/cols)';
% else
%     % Extra or missing stuff in data, assemble by looking at indices
%     warning('Column 1 does not appear to be index! Attempting alternate read...')
%     data = [];
%     % Find location of first integer (assume it is an index)
%     indloc = 1;
%     while 1
%         index = M(indloc);
%         if floor(index) == index
%             break
%         end
%         indloc = indloc+1;
%         if indloc > length(M)
%             error('No valid index found! Exiting...')
%         end
%     end
%     
%     % Read data by looking for indices
%     while length(M) >= cols
%         loc = find(M == index,1);
%         loc2 = find(M == index+1,1);
%         if length(M) < (loc+cols-1)
%             break
%         end
%         sample = NaN*ones(1,cols);
%         % Missing data
%         if loc2-loc < cols
%             sample(1:loc2-loc) = M(loc:loc2-1)';
%         else % Normal, or extra data
%             sample = M(loc:loc+cols-1)';
%         end
%         data = [data;sample];
%         index = index+1;
%         M = M(loc2:end);
%     end
%     
%     % One last check to see if index is monotonically increasing
%     if find(diff(data(:,1)) ~= 1)
%         error('Index vector in %s does not appear to be valid!',strFile)
%     end        
%     
% end

%%%%%% ------------------------ %%%%%%

% Call roboread_hdr to unify the two programs
[hdr,data] = roboread_hdr(strFile);
cols = hdr.logcolumns;

% Do some error checking
[i,x,y,vx,vy,fx,fy,fz,grasp,evt]=deal(NaN);
switch cols
    case 4 % special visual tracking case
        i=data;
    case 7
        [i,x,y,vx,vy,fx,fy]=deal(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7));
    case 8
        [i,x,y,vx,vy,fx,fy,fz]=deal(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7),data(:,8));
    case 9
        [i,x,y,vx,vy,fx,fy,fz]=deal(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7),data(:,8));
        varargout{1} = data(:,9);
    case 10
        [i,x,y,vx,vy,fx,fy,fz]=deal(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7),data(:,8));
        varargout{1} = data(:,9);
        varargout{2} = data(:,10);
    otherwise
        warning('unexpected number of columns in file (was %d), so need more robust code',cols)
end
