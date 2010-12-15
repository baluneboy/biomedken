function [indLo,indHi] = getclusters(z,numClusters)

% Specify that we only want 4 clusters & get'em
c = clusterdata(z,'maxclust',numClusters);

% Determine how clusters stack up (sort'em)
for i = 1:numClusters
    strCmd = sprintf('%s%d%s%d','z',i,'=mean(z(c==',i,'));');
    eval(strCmd);
    % z1 = mean(z(c==1));
    % z2 = mean(z(c==2));
    % z3 = mean(z(c==3));
    % z4 = mean(z(c==4));
end

if numClusters==4
    % Get hi/lo cluster indices
    [foo,indSort] = sort([z1 z2 z3 z4]);
    indLo = find(c==indSort(1) | c==indSort(2));
    indHi = find(c==indSort(3) | c==indSort(4));
else
    error('daly:eegemgvicon:noworkflowyet for %d clusters',numClusters)
end
