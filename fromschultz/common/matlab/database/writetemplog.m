function writetemplog(currentIteration,totalIterations,strThis,strJob)
% EXAMPLE
% writetemplog(1,2,'c:\temp\file.txt','big');

%% Protect db from stupid Microsoft backslashes (in paths)
strThis = forwardslash(strThis);
strJob = forwardslash(strJob);

%% Do templog table insert
strQuery = sprintf('INSERT INTO templog (`current_iteration`,`total_iterations`,`label`,`job`) VALUES (%d, %d, "%s", "%s");',currentIteration,totalIterations,strThis,strJob);
executemysqlquery(strQuery);