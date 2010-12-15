function hold_out = find_unique_articles(strFile)
fid = fopen(strFile,'rt');

holding = {};
while(~feof(fid))
    tmp = fgetl(fid);
    if ~isempty(tmp)
        holding = [holding;tmp];
    end
end
fclose(fid);

pmid_ind = [];
tmp = regexp(holding,'PMID: ');
for k = 1:numel(tmp)
    if ~isempty(tmp{k})
        pmid_ind = [pmid_ind;k];
    end
end

pmid = zeros(size(pmid_ind));
for k = 1:numel(pmid_ind)
    tmp = regexp(holding{pmid_ind(k)}, '\d\d\d\d\d\d\d\d','match');
    pmid(k) = str2num(tmp{1});
end
[upmid,upmid_ind] = unique(pmid);

hold_out = {};
for k = 1:numel(upmid_ind)
    end_ind = pmid_ind(upmid_ind(k));
    if end_ind == 1
        ent_rows = 1:end_ind;
    else
        ent_rows = pmid_ind(upmid_ind(k)-1)+1:end_ind;
    end
    tmp = holding(ent_rows);
    
    tmpline = '';
    for kk = 1:numel(tmp)-1
        if isempty(tmpline)
            tmpline = strcat(tmpline,tmp{kk});
        else
            tmpline = [tmpline,' ',tmp{kk}];
        end
        if isequal(deblank(tmpline(end)),'.') || isequal(deblank(tmpline(end)),']')
            hold_out = [hold_out;tmpline];
            tmpline = '';
        end
    end     
    hold_out = [hold_out;tmp{numel(tmp)};' '];
end
    
%     authors = '';
%     title = '';
%     journal = '';
%     pmidtag = '';
    
%     counter = 1;
%     while 1
%         authors = strcat(authors,' ',tmp{counter});
%         counter = counter+1;
%         nl = tmp{counter};
%         if isequal(nl(1),' ')
%             break
%         end
%     end
%     
%     while 1
%         title = strcat(title,' ',tmp{counter});
%         counter = counter+1;
%         nl = tmp{counter};
%         if length(nl) >= 5 &&isequal(nl(1:5),'PMID:')
%             break
%         end
%     end
            
        
    