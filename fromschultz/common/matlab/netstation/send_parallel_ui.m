function send_parallel_ui(varargin)
% SEND_PARALLEL_UI.M - Sends DIN events over parallel port to NetStation
%   Usage:  send_parallel_ui() - loads default config (events.conf)
%           send_parallel_ui(config_file) - loads config file specified in string 'config_file'
%           send_parallel_ui(keys,send) - CAS 'keys' with input keys, and vector of doubles 'send' with outputs
%   See events.conf in same folder for configuration example
%   Baseline event pulse time of 0.05 seconds is currently hardcoded 

% Author: Roger Cheng
% $Id: send_parallel_ui.m 4160 2009-12-11 19:10:14Z khrovat $

% Determines how to get key mapping
if nargin == 0 % Tries to load default config file
    [key,send] = loc_loadconfig('events.conf');
elseif nargin == 1 % Tries to load user config file
    [key,send] = loc_loadconfig(varargin{1});
elseif nargin == 2 % Uses key definitions from call
    [key,send] = deal(varargin{:});
end

% Basic validity checks
% Out of range
if max(send) > 255 || min(send) < 0 % Not sure if 0 is a valid event
    error('send_parallel_ui:OutOfRange','Output values must be integers in the range 1-255');
elseif ~isequal(floor(send),send)
    error('send_parallel_ui:NonIntOut','Output values must be integers');
elseif ~isequal(numel(unique(send)),numel(send))
    error('send_parallel_ui:DupVal','Duplicate output value mappings detected');
end
   
% Set up output device
dio = digitalio('parallel',1);
iolines = addline(dio,0:7,'out')

% Test output by flipping all bits
putvalue(dio,255);
if ~isequal(getvalue(dio),[1 1 1 1 1 1 1 1])
    error('send_parallel_ui:AllOn','Could not activate all output lines');
end
putvalue(dio,0);
if ~isequal(getvalue(dio),[0 0 0 0 0 0 0 0])
    error('send_parallel_ui:AllOff','Could not zero all output lines')
end

% Set up figure window
h = figure('NumberTitle','off','Name','Parallel Port Event Marker','menubar','none','toolbar','none','KeypressFcn',@loc_keypress);
mv = version;
if str2num(mv(1:3)) > 7.3
    set(h,'KeyReleaseFcn',@loc_keyrelease);
end
set(h,'BusyAction','cancel');
set(h,'Interruptible','off');
set(h,'CloseRequestFcn',@loc_close);
% winontop(h); doesn't seem to work when compiled

% Set up displayed text in window
axis ij;
axis off;
% Valid keypresses
disptext = cell(numel(key),1);
mkey = char(key);
for k = 1:numel(key)
    disptext{k} = sprintf('%s %0.0f (%s)',mkey(k,:),send(k),dec2bin(send(k),8));
end    
text(0,1,[{'\bf{Valid Events:}\rm'};disptext],'Units','normalized','horizontalalignment','left','verticalalignment','top','FontName','FixedWidth','FontSize',10)
% Echo command sent
htext = text(1,1,'Ready to Send','Units','normalized','horizontalalignment','right','verticalalignment','top','FontName','FixedWidth','FontSize',10,'color','blue','FontWeight','bold');
hstat = text(1,0,'Tx','Units','normalized','horizontalalignment','right','verticalalignment','bottom','FontName','FixedWidth','FontSize',12,'color','white','FontWeight','bold');

% Write necessary information to appdata structure
setappdata(h,'htext',htext);
setappdata(h,'hstat',hstat);
setappdata(h,'key',key);
setappdata(h,'send',send);
setappdata(h,'dio',dio);

%%% Local function to handle keypresses
function loc_keypress(varargin)
% tic;
h = varargin{1};
keystruct = varargin{2};
hdata = getappdata(h);
% Looks for a match
match = find(strcmpi(keystruct.Key,hdata.key));
if ~isempty(match)
    % Matches keypress to output
    sendval = hdata.send(match);
    % Sends via parallel port
    putvalue(hdata.dio,sendval);
    set(hdata.hstat,'color','red');
    % Checks for proper output
    if isequal(getvalue(hdata.dio),dec2binvec(sendval,8))
        % Echoes to keypress to window
        set(hdata.htext,'String',{keystruct.Key;sprintf('Sent %0.0f (%s)',sendval,dec2bin(sendval,8))});
        set(hdata.htext,'color','blue');
                
        %%%% ADJUST TIMING HERE
        pause(0.05);
        % 0.050 seconds is guaranteed pause; computer's own overhead for IO is ~0.010-0.020 sec 
        %%%% ------------------
        
        putvalue(hdata.dio,0);
        % Checks for proper zeroing
        if ~isequal(getvalue(hdata.dio),[0 0 0 0 0 0 0 0])
            set(hdata.htext,'String','Error zeroing output!');
            set(hdata.htext,'color','red');
        end
    else
        set(hdata.htext,'String','Error sending event!');
        set(hdata.htext,'color','red');
    end
    set(hdata.hstat,'color','white');   
else
    % No valid keypress found
    set(hdata.htext,'string',{keystruct.Key;'No match'});
    set(hdata.htext,'color','white');
end
% toc

function loc_keyrelease(varargin)
disp 'boo'

%%% Local function for loading config
function [key,send] = loc_loadconfig(cfile)   
fid = fopen(cfile,'rt');
if fid == -1
    warning('No events specifed, using single-event mode');
    key = {'space'};
    send = 1;
else
    cell_evt = textscan(fid,'%s%n','delimiter',',','commentStyle','%');
    fclose(fid);
    key = cell_evt{1};
    send = cell_evt{2};
end

%%% Gracefully close and delete the DAQ device
function loc_close(varargin)
h = varargin{1};
hdata = getappdata(h);
delete(hdata.dio);
delete(h);

