function readme_pimsdatafun

% README_PIMSDATAFUN helpful notes and tips on dealing with cell arrays and structures

%% Concatenate a structure array along a field
S(1).columnVector = (1:2)';
S(2).columnVector = (11:13)';
S(1).rowVector = 1:3;
S(2).rowVector = 9:-1:7;
S(1).matrixTwoByThree = ones(2,3);
S(2).matrixTwoByThree = 2*ones(2,3);
disp('Concatenate a structure array along a field that holds vectors')
catColumnVectorFields = cat(1,S.columnVector)
catRowVectorFields = cat(2,S.rowVector)
catMatrixFields = cat(1,S.matrixTwoByThree)
catMatrixFields = cat(2,S.matrixTwoByThree)
