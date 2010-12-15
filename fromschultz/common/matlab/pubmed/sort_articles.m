function ref_db = sort_articles(strInp)

if ~isstruct(strInp)
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

    ref_db = struct;
    for k = 1:numel(pmid_ind)
        tmp = regexp(holding{pmid_ind(k)}, '\d\d\d\d\d\d\d\d','match');
        ref_db(k,1).authors = holding{pmid_ind(k)-3};
        ref_db(k,1).title = holding{pmid_ind(k)-2};
        ref_db(k,1).journal = holding{pmid_ind(k)-1};
        ref_db(k,1).pmid = tmp;
        ref_db(k,1).category = -1;
    end
    
else
    ref_db = strInp;
end

% Sort

% Assign
for k = 1:size(ref_db,1)
    disp(ref_db(k,1).title);
    ref_db(k,1).category = input('Category: ');
end

