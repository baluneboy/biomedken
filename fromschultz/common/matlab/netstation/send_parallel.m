function send_parallel()
% SEND_PARALLEL.M - Sends DIN events to NetStation
%   Usage: send_parallel [no arguments needed]

dio = digitalio('parallel',1)
iolines = addline(dio,0:7,'out')
disp('Enter codes, 0-255; -1 to quit');
to_send = 0;
while to_send >= 0
    to_send = floor(input('Value: '));
    if to_send > 255
        disp('Invalid code');
    elseif to_send < 0
        disp('Aborting');
        break
    else
        disp(sprintf('Sending %0.0f',to_send));
        putvalue(dio,to_send)
    end
end