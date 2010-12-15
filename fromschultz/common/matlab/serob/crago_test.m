function casFiles = crago_test(strDir,casKeep)

%
% EXAMPLE
% strDir = 'S:\nightly_mirror\serob\therapist\test\eval\20080710_Thu';
% casKeep = {'point_to_point','chase_rob','circle','playback_rec','digates_rob','round_dyn','playback_static'};
% casFiles = crago_test(strDir,casKeep);

[casFiles,sDetails]=dirdeal(strDir);
casKeepers = casfilter(casFiles,casKeep);
fprintf('\nFound %d files, but just keeping %d "rob_data" files',length(casFiles),length(casKeepers))
for i = 1:length(casKeepers)
    strFile = casKeepers{i};
    try
        strFull = fullfile(strDir,strFile);
        [ind,x,y,vx,vy,fx,fy,fz,grasp,evt] = roboread(strFull);
        fprintf('\n  %s plotting',strFull)
        figure
        plot(ind,evt)
        title(strFull,'interpreter','none')
        [foo,strName] = fileparts(strFull);
        print(gcf,'-depsc','-tiff','-r600',['crago_test_' strName '_' datestr(now,30)]);
        close(gcf)
    catch
        fprintf('\nX %s does not appear to have 10th [event] column',strFull)
    end
end
fprintf('\n')