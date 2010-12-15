function figure_keypress
figure('KeyPressFcn',@printfig);
plot(humps)
function printfig(src,evnt)
if evnt.Character == 'e' % for e
    print('-depsc','-tiff','-r600',['c:\temp\figure' num2str(src) '_' datestr(now,30)])
elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:}, 'control') & evnt.Key == 't' % for Ctrl-t
    print('-dtiff','-r600',['c:\temp\figure' num2str(src) '_' datestr(now,30)])
elseif evnt.Character == 'x' % for x
    disp('you hit x key')
end
