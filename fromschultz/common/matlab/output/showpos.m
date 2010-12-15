function showpos(hFig);

%showpos - copy of figure that shows positions and units

hFig2=copyobj(hFig,0);

% Get object handles
if exist('guihandles')==2
   h=guihandles(hFig);
else
   h=get(hFig,'userdata');
end

% Get fieldnames
casFields=fieldnames(h);

for i=1:length(casFields)
   strField=casFields{i};
   hObj=getfield(h,strField);
   strType=get(hObj,'type');
   if ~iscell(strType)
      if strcmp(strType,'line') 
         delete(hObj)
      elseif  strcmp(strType(1:2),'ui')
         %ignore
      else
         strUnits=get(hObj,'units');
         if ~strcmp(strUnits,'data')
            switch strType
            case 'axes'
               xywh=get(hObj,'pos');
               str=sprintf('xywh=[%.3f,  %.3f,  %.3f,  %.3f]',xywh);
               ht=text(...
                  'HorizontalAlign','center',...
                  'Parent',hObj,...
                  'Position',[0.5 0.5 0],...
                  'String',str,...
                  'Units','normalized');
            case 'text'
               xyz=get(hObj,'pos');
               str=sprintf('xy=[%.3f,  %.3f]',xyz(1:2));
               set(hObj,'string',str);
            otherwise
               % nothing
            end
         end
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=locPrettyString(pos,strUnits);