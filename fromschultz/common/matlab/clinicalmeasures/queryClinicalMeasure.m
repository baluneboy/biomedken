function result=queryClinicalMeasure(strDir, study, subject, measure, result)

% This function retrieves results from clinical measures excel spreadsheets
% and returns the results in a structure whose format is
% results.study.subject.measure.data_collect
% for example,
% results.plas.c1339plas.Modified_Ashworth.dc1=10
% Currently, this function is written for Fugl-Meyer, Modified Ashworth, 
% and MMT.  Other studies can be added as necessary.
%
% INPUTS:
% strDir- specify directory like S:\data\upper\clinical_measures.  There is
%   a fair amount of inflexibility with file structure:
%   1) You can enter S:\data if you are retrieving both upper and lower 
%   extremety data and it will fill in \clinical_measures\study\subject\
%   measure-subject.xls
%   Or
%   2) You can enter S:\data\upper\clinical_measures and it will fill in
%   \study\subject\measure-subject.xls
% study-enter the 4 letter code, such as moda, plas, hand, or string 'all' 
% subject- enter a standard numerical subject code (format s1234stdy) or
%   string 'all'
% measure- (Modified Ashworth, Fugl-Meyer, MMT) or 'all', with either spaces or
%   dashes.
% result- Enter something like zero to start the routine.  This function
%   is recursive, so when it calls itself, it passes on the result 
%   structure is so far. 
% 
% OUTPUTS:
% result- a structure whose format is
%   results.study.subject.measure.data_collect
%   for example,
%   results.plas.c1339plas.Modified_Ashworth.dc1=10
%
% Example call:
% result=queryClinicalMeasure('S:\data\upper\clinical_measures', 'plas',... 
% 'all', 'all', 0)
%

% Author: Morgan Clond
% $ID$
%

%% extremity and study
if or(or(strcmp(study,'plas')==1,strcmp(study,'moda')==1),...
        strcmp(study,'modalities')==1)
    extr='upper'; % if it is plas, moda, or modalities, it means upper extremity
elseif or(or(strcmp(study,'loko'==1),strcmp(study,'acute')==1),...
        strcmp(study,'biofeedback')==1)
    extr='lower'; %If the study is loko, acute, or biofeedback, it means lower extremity
    disp('Attention! queryClinicalMeasure is not yet able to retrieve lower extremity data!')
elseif strcmp(study,'all')==1
    study=[{'plas','moda','loko','acute','biofeedback'}];   %cycle through the studies
    for i=1:length(study)
        result=queryClinicalMeasure(strDir, study{i}, subject, measure, result);
    end
    return
else
    ls(strDir)
    error('Study %s was not found', study)    
end

%% subject
%opens the study directory and matches the names to a regular expression if
%the subject given was 'all.'  Otherwise skip this part...
if strcmp(subject,'all')==1
    subj=dir(strcat(strDir,'\',study,'\'));
    for i=1:length(subj)
       if isempty(regexpi(subj(i).name,'[c s]\d{4}[p m][l o][a d][s a]','match'))==0;
             result=queryClinicalMeasure(strDir, study, subj(i).name, measure,result);
        end
    end
    return
end

%% measure
% Start by checking the data type.  If there is more than one measure, 
% then the variable measure is a cell array of strings, so do one at a time.
if isa(measure,'cell')==1 
    for i=1:length(measure)
        result=queryClinicalMeasure(strDir, study, subject, measure{i},result);
    end
end
if strcmp(measure,'all')==1
    if strcmp(extr,'upper')            
        measure=[{'Modified-Ashworth','Fugl-Meyer','MMT'}];
        for i=1:length(measure)
            result=queryClinicalMeasure(strDir, study, subject, measure{i},result);
        end
        
        return
    elseif strcmp(extr,'lower')
    elseif strcmp(extr,'both')
    end
elseif isempty(regexpi(measure,'Modified.Ashworth','match'))==0
    %if you asked for the modified ashworth, find out if it has a dash
    nosp_measure='Modified_Ashworth'; 
    sumSheet='Totals.*'; %Maybe there's a space there?  I don't know.
    m=dir(strcat(strDir,'\',study,'\',subject,'\'));
    for i=1:length(m)+1
        if i==length(m)+1
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_post3=inf;'));    
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=inf;'));    
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=inf;'));        
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post3=inf;'));    
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post6=inf;'));         
            warning('Modified Ashworth for subject %s cannot be found. \n',subject)       
            return
        end
        realMeas=regexpi(m(i).name,'Modified.Ashworth.[c s]\d{4}[p m][l o][a d][s a].xls','match');
        if length(realMeas)>0
            filename=m(i).name;  
            break
        end
    end
elseif isempty(regexpi(measure,'Fugl.Meyer','match'))==0
    %if you asked for the fugl meyer, find out if it has a dash or what
    nosp_measure='Fugl_Meyer';
    sumSheet='Combine.*';
    m=dir(strcat(strDir,'\',study,'\',subject,'\'));
    for i=1:length(m)+1
        if i==length(m)+1
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post3=inf;'));    
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post6=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_post3=inf;'));    
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_post3=inf;')); 
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_post3=inf;'));        
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_post3=inf;'));
            warning('Fugl-Meyer for subject %s cannot be found. \n',subject)       
            return
        end
        realMeas=regexpi(m(i).name,'Fugl.Meyer.[c s]\d{4}[p m][l o][a d][s a].xls','match');
        if length(realMeas)>0
            filename=m(i).name;
            break
        end
    end    
% elseif isempty(regexpi(measure,'FM_details','match'))==0
%     %if you asked for the fugl meyer, find out if it has a dash
%     nosp_measure='FM_details';
%     sumSheet='Combine.*';
%     m=dir(strcat(strDir,'\',study,'\',subject,'\'));
%     for i=1:length(m)+1
%     if i==length(m)+1
%         eval(strcat('result.',study,'.',subject,'.',nosp_measure,'=inf;'));
%         warning('Fugl-Meyer for subject %s cannot be found. \n',subject)       
%         return
%     end
%     realMeas=regexpi(m(i).name,'Fugl.Meyer.[c s]\d{4}[p m][l o][a d][s a].xls','match');
%         if length(realMeas)>0
%             filename=m(i).name;
%             break
%         end
%     end    
elseif isempty(regexpi(measure,'MMT','match'))==0
    nosp_measure='MMT';
    sumSheet='Combine.*';
    m=dir(strcat(strDir,'\',study,'\',subject,'\'));
    for i=1:length(m)+1
        if i==length(m)+1
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_post3=inf;'));        
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=inf;'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=inf;'));           
            warning('MMT for subject %s cannot be found. \n',subject)       
            return
        end
        realMeas=regexpi(m(i).name,'MMT.[c s]\d{4}[p m][l o][a d][s a].xls','match');
        if length(realMeas)>0
            filename=m(i).name;
            break
        end
    end 
end

%% Now you got a subject, a study, a measure, and you know where to look
% for it...

strPath=strcat('S:\data\',extr,'\clinical_measures\',study,'\',subject,'\');

if strcmp(subject,'all')==0  %as long as this isn't the first function that was called ending
    result=goGet(strcat(strPath,filename),nosp_measure,sumSheet,study,subject,result);
end

function meas=goGet(strPath,nosp_measure,sumSheet,study,subject,result)
    [typ, desc] = xlsfinfo(strPath);
    for i=1:length(desc)
       %figure out which sheet looks the most like it is the combined sheet
       check=regexpi(desc{i},sumSheet,'match'); 
       if length(check)>0
           sumSheet=check{1};
           break
       end
    end
    [num,str,raw]=xlsread(strPath,sumSheet); %and read that sheet
    
    %figure out which subfunction to call
    if strcmpi(nosp_measure,'Fugl_Meyer')==1
        meas=fuglmeyer(nosp_measure,study,subject, num, result);
    elseif strcmpi(nosp_measure,'Modified_Ashworth')==1
        meas=ashworth(nosp_measure,study,subject, num, result);
    elseif strcmpi(nosp_measure,'MMT')==1
        meas=MMT(nosp_measure,study,subject,num,str,result);
    end
        
function result=fuglmeyer(nosp_measure,study,subject,num,result) %
        [len,wid]=size(num); %len should be 49 for FM
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc1=num(len,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc2=num(len,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc3=num(len,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post3=num(len,4);'));    
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post6=num(len,5);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc1=num(8,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc2=num(8,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc3=num(8,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_post3=num(8,4);'));    
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_dc1=num(9,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_dc2=num(9,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_dc3=num(9,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.ret_post3=num(9,4);')); 
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_dc1=num(10,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_dc2=num(10,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_dc3=num(10,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.abd_post3=num(10,4);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc1=num(11,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc2=num(11,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc3=num(11,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_post3=num(11,4);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=num(12,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=num(12,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=num(12,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=num(12,4);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_dc1=num(15,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_dc2=num(15,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_dc3=num(15,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_irot_post3=num(15,4);'));        
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=num(16,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=num(16,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=num(16,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=num(16,4);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc1=num(20,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc2=num(20,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc3=num(20,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_post3=num(20,4);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_dc1=num(47,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_dc2=num(47,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_dc3=num(47,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.dysm_post3=num(47,4);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_dc1=num(48,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_dc2=num(48,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_dc3=num(48,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.time_post3=num(48,4);'));
        return

function result=ashworth(nosp_measure,study,subject,num,result) %
        [len,wid]=size(num); %len should be 14 for ashworth
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_dc1=num(5,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_dc2=num(5,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_dc3=num(5,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sirot_post3=num(5,4);'));    
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=num(6,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=num(6,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=num(6,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=num(6,4);'));    
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=num(7,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=num(7,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=num(7,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=num(7,4);'));        
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc1=num(len,1);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc2=num(len,2);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_dc3=num(len,3);'));
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post3=num(len,4);'));    
        eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.total_post6=num(len,5);'));
        return
        
function result=MMT(nosp_measure,study,subject,num,str,result);
        %Is it one format or the other?
        if strcmp(str(6,13),'Scale')==1 %then data is in 2,4,6,8 as in s1305
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc1=num(3,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc2=num(3,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc3=num(3,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_post3=num(3,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc1=num(4,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc2=num(4,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc3=num(4,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_post3=num(4,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc1=num(5,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc2=num(5,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc3=num(5,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_post3=num(5,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc1=num(6,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc2=num(6,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc3=num(6,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_post3=num(6,8);'));        
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc1=num(7,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc2=num(7,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc3=num(7,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_post3=num(7,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc1=num(9,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc2=num(9,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc3=num(9,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_post3=num(9,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc1=num(10,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc2=num(10,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc3=num(10,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_post3=num(10,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc1=num(11,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc2=num(11,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc3=num(11,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_post3=num(11,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc1=num(12,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc2=num(12,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc3=num(12,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_post3=num(12,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc1=num(13,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc2=num(13,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc3=num(13,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_post3=num(13,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc1=num(14,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc2=num(14,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc3=num(14,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_post3=num(14,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc1=num(15,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc2=num(15,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc3=num(15,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_post3=num(15,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=num(17,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=num(17,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=num(17,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=num(17,8);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=num(18,2);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=num(18,4);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=num(18,6);'));
            eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=num(18,8);'));
        elseif strcmp(str(3,13),'Scale')==1
            if length(num)==30 %as in s1301
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc1=num(3,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc2=num(3,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc3=num(3,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_post3=num(3,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc1=num(4,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc2=num(4,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc3=num(4,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_post3=num(4,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc1=num(5,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc2=num(5,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc3=num(5,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_post3=num(5,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc1=num(6,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc2=num(6,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc3=num(6,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_post3=num(6,7);'));        
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc1=num(7,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc2=num(7,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc3=num(7,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_post3=num(7,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc1=num(9,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc2=num(9,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc3=num(9,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_post3=num(9,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc1=num(10,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc2=num(10,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc3=num(10,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_post3=num(10,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc1=num(11,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc2=num(11,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc3=num(11,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_post3=num(11,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc1=num(12,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc2=num(12,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc3=num(12,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_post3=num(12,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc1=num(13,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc2=num(13,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc3=num(13,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_post3=num(13,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc1=num(14,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc2=num(14,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc3=num(14,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_post3=num(14,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc1=num(15,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc2=num(15,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc3=num(15,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_post3=num(15,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=num(17,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=num(17,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=num(17,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=num(17,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=num(18,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=num(18,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=num(18,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=num(18,7);'));
            elseif length(num)==28 %as in s1328
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc1=num(1,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc2=num(1,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_dc3=num(1,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAbd_upRot_post3=num(1,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc1=num(2,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc2=num(2,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_dc3=num(2,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.elev_post3=num(2,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc1=num(3,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc2=num(3,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_dc3=num(3,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scap_add_post3=num(3,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc1=num(4,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc2=num(4,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_dc3=num(4,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.add_dep_post3=num(4,7);'));        
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc1=num(5,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc2=num(5,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_dc3=num(5,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.scapAdd_dnRot_post3=num(5,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc1=num(7,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc2=num(7,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_dc3=num(7,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sflex_post3=num(7,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc1=num(8,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc2=num(8,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_dc3=num(8,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sext_post3=num(8,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc1=num(9,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc2=num(9,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_dc3=num(9,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.sabd_post3=num(9,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc1=num(10,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc2=num(10,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_dc3=num(10,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_add_post3=num(10,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc1=num(11,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc2=num(11,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_dc3=num(11,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.hoz_abd_post3=num(11,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc1=num(12,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc2=num(12,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_dc3=num(12,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.erot_post3=num(12,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc1=num(13,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc2=num(13,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_dc3=num(13,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.irot_post3=num(13,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc1=num(15,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc2=num(15,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_dc3=num(15,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eflex_post3=num(15,7);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc1=num(16,1);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc2=num(16,3);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_dc3=num(16,5);'));
                eval(strcat('result.',study,'.',subject,'.',nosp_measure,'.eext_post3=num(16,7);'));
            else
                warning('Different MMT format detected')
            end
        else
            warning('Different MMT format detected')
        end
            return