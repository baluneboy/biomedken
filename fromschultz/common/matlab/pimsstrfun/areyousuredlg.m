function bln = areyousuredlg(strQuestion,strTitle)

% AREYOUSUREDLG gui for simple yes/no dialog

bln = 0;
ButtonName = questdlg(strQuestion,strTitle,'No', 'Yes', 'No');
switch ButtonName
    case 'Yes'
        bln = 1;
    case 'No'
        bln = 0;
    otherwise
        bln = 0;
end