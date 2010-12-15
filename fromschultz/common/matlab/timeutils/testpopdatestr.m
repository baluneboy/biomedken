cD={'44:23:59:59.876','23:59:59.876','59:59.876','59.876',};%;popdatestr(now)};
%cDateform={[]};
cDateform={'dd-mmm-yyyy,HH:MM:SS.SSS','YYYY:MM:DD:hh:mm:ss.sss','YYYY:DOY:hh:mm:ss.sss','MM/DD/YYYY,hh:mm:ss.sss',0,-2,-4,-1,[]};
%cDateform={'DD:HH:MM:SS.SSS','HH:MM:SS.SSS','MM:SS.SSS','SS.SSS'};%'DD:HH:MM:SS.SSS'

for i=1:length(cD)
   D=cD{i};
   for j=1:length(cDateform)
      dateform=cDateform{j};
      if ~isempty(dateform)
         [str,strPattern]=popdatestr(D,dateform);
      else
         [str,strPattern]=popdatestr(D);
      end
      fprintf('\n\n%s with %s gives %s (%s)',num2str(D),num2str(dateform),str,strPattern)
   end
end

      