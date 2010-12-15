function write_out(strInp,keep,outfile)


fid = fopen(strInp,'rt');
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

fid = fopen(outfile,'wt');
for k = 1:numel(keep)
    rec_end = pmid_ind(keep(k));
    if keep(k) ~= 1
        rec_beg = pmid_ind(keep(k)-1)+2;
    else
        rec_beg = 1;
    end
    for kk = rec_beg:rec_end
        fprintf(fid,'%s\n',holding{kk});
    end
    fprintf(fid,'\n');
end
fclose(fid);



% ref_db = struct;
% for k = 1:numel(pmid_ind)
%     tmp = regexp(holding{pmid_ind(k)}, '\d\d\d\d\d\d\d\d','match');
%     ref_db(k,1).authors = holding{pmid_ind(k)-3};
%     ref_db(k,1).title = holding{pmid_ind(k)-2};
%     ref_db(k,1).journal = holding{pmid_ind(k)-1};
%     ref_db(k,1).pmid = tmp;
%     ref_db(k,1).category = -1;
% end
%     
