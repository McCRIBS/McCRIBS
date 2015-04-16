function [] = RIPScore()
%Runs RIPScore, the manual scoring GUI.
%
%Copyright (c) 2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
%McGill University
%All rights reserved.
% 
%Redistribution and use in source and binary forms, with or without modification, are 
%permitted provided that the following conditions are met:
% 
%1. Redistributions of source code must retain the above copyright notice, this list of 
%   conditions and the following disclaimer.
% 
%2. Redistributions in binary form must reproduce the above copyright notice, this list of 
%   conditions and the following disclaimer in the documentation and/or other materials 
%   provided with the distribution.
% 
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
%EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
%MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
%COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
%EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
%HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
%TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

rng('shuffle');
set(0,'defaulttextfontsize',14);

%% General Variables
RIPScoreVersion='1.2';	%Version of this RIPScore implementation
underDevelopment=false;	%Indicates whether this RIPScore version is under development

%% Show initial screen
CreateMode.Interpreter='tex';
CreateMode.WindowStyle='modal';
msg=['{\bf{RIPScore}}' ...
    char(10) ...
    'Version ' RIPScoreVersion ...
    char(10) ...
    char(10) ...
    'Copyright (c) 2015, Carlos Alejandro Robles Rubio,' ...
    char(10) ...
    'Karen A. Brown, and Robert E. Kearney.' ...
    char(10) ...
    'McGill University.' ...
    char(10) ...
    'All rights reserved.' ...
    char(10)];

msgh=msgbox(msg,'Welcome',CreateMode);
set(msgh,'Position',[600 400 240 150]);
axh=get(msgh,'CurrentAxes');
chh=get(axh,'Children');
set(chh,'FontSize',12);
uiwait(msgh);

%Get path to the main file
if isdeployed %Stand-alone mode.
    [~,result]=system('path');
    AppDir=char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    
else % MATLAB mode.
    [AppDir,~]=fileparts(mfilename('fullpath'));
end

%% Load Variables from Configuration File
if ~underDevelopment
    %Check if configuration file exists
    if exist([AppDir '\cnf.mat'],'file')~=2
        %Create 'cnf.mat'
        uiwait(msgbox('The following questions will help you to configure RIPScore.','Configure RIPScore','warn'));
        RIPScore_setParameters(AppDir);
    end
    
    %Load saved configuration parameters
    load([AppDir '\cnf.mat']);
else
    %During development, manipulate the configuration parameters here
    % GUI mode
    guiMode=1;              %0: Scorer mode (open); 1: Blind scorer mode; 2: Training mode.

    % File paths
    scordir='..\scored\';   %Directory where all the scoring files are saved
    datadir='..\data\';     %Directory with the data records to score

    % Environment variables
    EpochLen=30;            %Length of the data epoch in seconds.
    Fs=50;                  %Sampling frequency in Hz.
    ShowMsgs=true;          %Flag to indicate whether messages should be sent to the standard output

    % RIP high-pass filter
    [b_HP_RIP,a_HP_RIP]=cheby1(6,0.1,0.0825/(Fs/2),'high');  %High-pass filter for very low frequency trends in RIP signals

    % Define states
    PAU=stateCode('PAU');	%Pause
    ASB=stateCode('ASB');	%Asynchronous-Breathing
    MVT=stateCode('MVT');	%Movement Artifact
    SYB=stateCode('SYB');	%Synchronous-Breathing
    SIH=stateCode('SIH');	%Sigh
    UNK=stateCode('UNK');	%Unknown
    states=[PAU ASB MVT SYB SIH UNK]';
    numStates=length(states);

    statesAbbr=cell(6,1);   %State abbreviations
    for index=1:numStates
        statesAbbr{index}=stateAbbreviation(states(index));
    end

    statesName=cell(6,1);   %State names
    for index=1:numStates
        statesName{index}=stateName(states(index));
    end

    % Training Mode Variables
    B=500;                      %Number of bootstrap resamples for estimation of standard deviations
    ALPHA=0.01;
    wL=18;                      %Half the length of the segment concatenation window (see combineSignals)
    winType=1;                  %Type of the segment concatenation window (see combineSignals)
    ConsecutiveEvts=5;          %Number of consecutive segments (of each type) to finish practice stage
    pctEvt=0.8;                 %The proportion of the segment that has to be correctly identified to be considered detected (in practice stage)
    trainLength=5*60*Fs;        %Maximum length (in samples) of practice stage before starting the testing stage.
    testLength=5*60*Fs;         %Length (in samples) of the testing stage.
    thresholdTimePerEvent=2*60;	%The maximum time that will be counted for effective scoring time between two segments scored one after the other. In seconds
    ThresholdLowestKappa=0.8;               %If the lowest kappa lower limit is >= 0.8
    ThresholdEffectiveTrainTime=4*60*60;	%If the effective training time was below 4 hrs

    % Full path to the library of "true-state" segments
    McCRIB_DATA_ROOT=getenv('McCRIB_DATA_ROOT');    %Get McCRIB_DATA_ROOT path
    TrueState_Library_path=[McCRIB_DATA_ROOT '\POA\TrueState_Segment_Library\TrueState_Library'];
end
clear AppDir

%% Load application
if(guiMode==0)  %Run RIPScore in OPEN mode
    %Obtain the RAW DATA file to score
    [filename,pathname]=uigetfile([datadir '*.mat'],'Pick a data file to open for scoring');

    if(filename ~= 0)
        %Verify file format
        [~,~,fileExt]=fileparts(filename);
        if strcmpi(fileExt,'.mat')~=1
            errordlg('The format of selected file is not supported','File format not supported', 'modal');
            return;
        end
        
        %File to open
        rawdataFile=[pathname filename];

        %Get the scorer ID
        scorer=RIPScore_enterScorerID(nan,scordir);
        if isnan(scorer)
            errordlg('Identification is Required to Continue Scoring','No Identification', 'modal');
            return;
        end

        %The scoring file will be saved in the directory 'scordir', and
        %will have the same name as 'filename', with the prefix 'scored'
        %and the scorer ID.
        savename = [scordir 'scored_' scorer '_' filename(1:end-4) '.mat'];
        verbose(['Save name: ' savename],ShowMsgs);

        %Load the signals from the selected RAW DATA file
        [~,RCG,ABD,PPG,SAT]=RIPScore_readData([pathname filename(1:end-4)]);
        RCG=filtfilt(b_HP_RIP,a_HP_RIP,RCG);
        ABD=filtfilt(b_HP_RIP,a_HP_RIP,ABD);
        Signals=[RCG ABD PPG SAT];
        L=size(Signals,1);

        if L < 1
            errordlg('File does not contain data in RIPScore format','No Data','modal');
            return;
        else %if file was read correctly and correct file was selected
            %Check if the selected file has already been opened by scorer
            fopenResult = fopen(savename);
            fclose('all');

            backup=dir([savename(1:end-4) '_BACKUP.mat']);
            regulr=dir([savename]);
            if(fopenResult >= 3) %Load saved version
                if length(backup)<=0    %If there is NO backup
                    uiwait(msgbox(['There is a previous version of scores for this file.' char(10) char(10) 'You will be able to see and modify the scores in the main window.' char(10) char(10) 'Any changes will be saved when selecting the "Save" option.'],'Saved Version','warn'));
                    load(savename,'SCORING');
                else    %If there is a backup, ask user
                    whichVer=questdlg(['There are two saved versions of scores for this file.' char(10) char(10) 'The regular save is from: ' regulr.date '.' char(10) 'The backup save is from: ' backup.date '.' char(10) char(10) 'Which version do you want to keep?' char(10) char(10) 'Any changes will be saved when selecting the "Save" option.'],'Two saved versions','Regular','Backup','Backup');
                    switch whichVer
                        case 'Regular'
                            load(savename,'SCORING');
                            verbose('Loaded Regular Version',ShowMsgs);
                        case 'Backup'
                            load([savename(1:end-4) '_BACKUP.mat'],'SCORING');
                            verbose('Loaded Backup Version',ShowMsgs);
                    end
                end
            else %First time
                if length(backup)<=0    %If there is no backup, initialize file
                    uiwait(msgbox('This is the first time you score this file.','First Time','warn'));
                    SCORING=nan;
                else    %If there is a backup, ask user
                    whichVer=questdlg(['There is a backup saved version of scores for this file from: ' backup.date '.' char(10) char(10) 'Do you want to work with the backup version or create a new file for the scores?' char(10) char(10) 'Any changes will be saved when selecting the "Save" option.'],'Backup version','New','Backup','Backup');
                    switch whichVer
                        case 'New'
                            SCORING=nan;
                        case 'Backup'
                            load([savename(1:end-4) '_BACKUP.mat'],'SCORING');
                            verbose('Loaded Backup Version',ShowMsgs);
                    end
                end
            end    

            %Load the main screen to start scoring
            ScoredInfo=RIPScore_main(Signals,[],EpochLen,savename,SCORING,scorer,datadir,filename,RIPScoreVersion,ShowMsgs,Fs);
        end
    else
        errordlg('No file selected','No Such File', 'modal');
        return;
    end
elseif(guiMode==1)  %Run RIPScore in BLIND scorer mode
	verbose('Blind Scorer Mode',ShowMsgs)

    %The initials of the scorer for identification
    scorer=RIPScore_enterScorerID(nan,scordir,1);
    if isnan(scorer)
        errordlg('Identification is Required to Continue Scoring','No Identification', 'modal');
        return;
    end

    %Load SCORER data
    if (exist([scordir 'scorer_' scorer '.mat']))
        verbose(['Exists'],ShowMsgs)
        load([scordir 'scorer_' scorer '.mat'],'SCORER');
    else
        verbose(['New SCORER file'],ShowMsgs)
        SCORER.finished.file={};
        SCORER.finished.alias={};
        SCORER.current.file='';
        SCORER.current.alias='';
        SCORER.RIPScoreVersion=RIPScoreVersion;
    end
    
    pathname=scordir;
    if isempty(SCORER.current.file)  %Search 'datadir' to get a new file for scoring
        rawFiles=dir([datadir '*.mat']);
        totFiles=size(rawFiles,1);
        finFiles=size(SCORER.finished.file,2);
        if finFiles<=totFiles
            uiwait(msgbox(['You have ' num2str(totFiles-finFiles) ' of ' num2str(totFiles) ' files left'],'Files Left','warn'));
            lstFiles={};    %The list of files in 'datadir'
            for index=1:totFiles
                lstFiles{index}=rawFiles(index).name;
            end
            idxFinFiles=zeros(finFiles,1);  %Indices of finished files as listed in 'lstFiles'
            for index=1:finFiles
                idxFinFiles(index)=strmatch(SCORER.finished.file{index},lstFiles);
            end
            idxLeftFiles=ones(totFiles,1);      %Indices of files from 'lstFiles' that remain to be scored
            idxLeftFiles(idxFinFiles)=0;
            idxLeftFiles=find(idxLeftFiles==1);

            %Select the next file to score
            if isscalar(idxLeftFiles)
                idxNextFile=idxLeftFiles;               
            else
                idxNextFile=randsample(idxLeftFiles,1);
            end
            
            %Save selected file to SCORER data, assign an alias, and create new SCORING file
            SCORER.current.file=lstFiles{idxNextFile};
            SCORER.current.alias=['STUDY_' num2str(finFiles+1,'%02d') '.mat'];
            save([scordir 'scorer_' scorer '.mat'],'SCORER');
        else
            uiwait(msgbox(['You have finished all ' num2str(totFiles) ' files. Thank you.'],'Finished Files','warn'));
            return;
        end
    else    %The current file is not finished yet
        uiwait(msgbox(['Current file is not finished yet'],'File not finished','warn'));
        verbose(SCORER.current.file,ShowMsgs);
    end
        
    %The scoring file will be saved in 'scordir', with the alias
    %of the selected file, the prefix 'scored', and the scorer ID
    savename = [scordir 'scored_' scorer '_' SCORER.current.alias(1:end-4) '.mat'];
    verbose(['Save name: ' savename],ShowMsgs);
    
    %Load the signals from the selected data file
    [~,~,fileExt]=fileparts(SCORER.current.file);
    if strcmpi(fileExt,'.mat')~=1
        errordlg('The format of selected file is not supported','File format not supported', 'modal');
        return;
    end
    [~,RCG,ABD,PPG,SAT]=RIPScore_readData([datadir SCORER.current.file(1:end-4)]);
    RCG=filtfilt(b_HP_RIP,a_HP_RIP,RCG);
    ABD=filtfilt(b_HP_RIP,a_HP_RIP,ABD);
    Signals=[RCG ABD PPG SAT];
    L=size(Signals,1);

    if L < 1
        errordlg('File does not contain data in RIPScore format','No Data','modal');
        return;
    else %if file was read correctly and correct file was selectd
        %Check if the selected file has already been opened by scorer
        fopenResult = fopen(savename);
        fclose('all');

        backup=dir([savename(1:end-4) '_BACKUP.mat']);
        regulr=dir([savename]);
        if(fopenResult >= 3) %Load saved version
            if length(backup)<=0
                uiwait(msgbox(['There is a previous version of scores for this file.' char(10) char(10) 'You will be able to see and modify the scores in the main window.' char(10) char(10) 'Any changes will be saved when selecting the "Save" option.'],'Saved Version','warn'));
                load(savename,'SCORING');
            else    %If there is a backup, ask user
                whichVer=questdlg(['There are two saved versions of scores for this file.' char(10) char(10) 'The regular save is from: ' regulr.date '.' char(10) 'The backup save is from: ' backup.date '.' char(10) char(10) 'Which version do you want to keep?' char(10) char(10) 'Any changes will be saved when selecting the "Save" option.'],'Two saved versions','Regular','Backup','Backup');
                switch whichVer
                    case 'Regular'
                        load(savename,'SCORING');
                        verbose('Loaded Regular Version',ShowMsgs);
                    case 'Backup'
                        load([savename(1:end-4) '_BACKUP.mat'],'SCORING');
                        verbose('Loaded Backup Version',ShowMsgs);
                end
            end
        else %First time
            if length(backup)<=0
                uiwait(msgbox('This is the first time you score this file.','First Time','warn'));
                SCORING=nan;
            else    %If there is a backup, ask user
                whichVer=questdlg(['There is a backup saved version of scores for this file from: ' backup.date '.' char(10) char(10) 'Do you want to work with the backup version or create a new file for the scores?' char(10) char(10) 'Any changes will be saved when selecting the "Save" option.'],'Backup version','New','Backup','Backup');
                switch whichVer
                    case 'New'
                        SCORING=nan;
                    case 'Backup'
                        load([savename(1:end-4) '_BACKUP.mat'],'SCORING');
                        verbose('Loaded Backup Version',ShowMsgs);
                end
            end
        end    

        %Load the main screen to start scoring
        ScoredInfo=RIPScore_main(Signals,[],EpochLen,savename,SCORING,scorer,datadir,SCORER.current.file,RIPScoreVersion,ShowMsgs,Fs);
        
        clear SCORING
        fopenResultEnd = fopen(savename);
        fclose('all');
        if(fopenResultEnd >= 3) %If there is a saved version, update SCORER file
            load(savename,'SCORING');
            if (SCORING.Completed==1)
                offset=size(SCORER.finished.file,2);
                SCORER.finished.file{offset+1}=SCORER.current.file;
                SCORER.finished.alias{offset+1}=SCORER.current.alias;
                SCORER.current.file='';
                SCORER.current.alias='';
                save([scordir 'scorer_' scorer '.mat'],'SCORER');
            end
        end
    end
elseif (guiMode==2)  %Run RIPScore in TRAINING mode
    verbose('Training Mode',ShowMsgs);

    %Obtain the trainee ID
    trainee=RIPScore_enterScorerID(nan,scordir,1,'trainee');
    if isnan(trainee)
        errordlg('Identification is Required to Continue Training','No Identification', 'modal');
        return;
    end

    %Load TRAINEE data
    if (exist([scordir 'trainee_' trainee '.mat']))
        verbose(['Exists'],ShowMsgs)
        load([scordir 'trainee_' trainee '.mat'],'TRAINEE');
    else
        verbose(['New trainee'],ShowMsgs)
        TRAINEE.Scorer=trainee;         %Scorer ID
        TRAINEE.level=1;                %Level 1: Simulations, Level 2: Concatenated Real Data, Level 3: Finished Training
        TRAINEE.iteration=zeros(1,2);   %The last session completed at each level
        TRAINEE.InterAgreement{1}.k=zeros(1,1);                  %The accuracy evaluation (kappa) for each session in level 1. Each row is an session.
        TRAINEE.InterAgreement{1}.kj=zeros(1,length(states));
        TRAINEE.InterAgreement{1}.kstd=zeros(1,1);
        TRAINEE.InterAgreement{1}.kjstd=zeros(1,length(states));
        TRAINEE.InterAgreement{1}.kcil=zeros(1,1);
        TRAINEE.InterAgreement{1}.kcih=zeros(1,1);
        TRAINEE.InterAgreement{1}.kjcil=zeros(1,length(states));
        TRAINEE.InterAgreement{1}.kjcih=zeros(1,length(states));
        TRAINEE.InterAgreement{2}.k=zeros(1,1);                  %The accuracy evaluation (kappa) for each session in level 2. Each row is an session.
        TRAINEE.InterAgreement{2}.kj=zeros(1,length(states));
        TRAINEE.InterAgreement{2}.kstd=zeros(1,1);
        TRAINEE.InterAgreement{2}.kjstd=zeros(1,length(states));
        TRAINEE.InterAgreement{2}.kcil=zeros(1,1);
        TRAINEE.InterAgreement{2}.kcih=zeros(1,1);
        TRAINEE.InterAgreement{2}.kjcil=zeros(1,length(states));
        TRAINEE.InterAgreement{2}.kjcih=zeros(1,length(states));
        TRAINEE.IntraAgreement{1}.k=zeros(1,1);                  %The consistency evaluation (kappa) for each session in level 1. Each row is an session.
        TRAINEE.IntraAgreement{1}.kj=zeros(1,length(states));
        TRAINEE.IntraAgreement{1}.kstd=zeros(1,1);
        TRAINEE.IntraAgreement{1}.kjstd=zeros(1,length(states));
        TRAINEE.IntraAgreement{1}.kcil=zeros(1,1);
        TRAINEE.IntraAgreement{1}.kcih=zeros(1,1);
        TRAINEE.IntraAgreement{1}.kjcil=zeros(1,length(states));
        TRAINEE.IntraAgreement{1}.kjcih=zeros(1,length(states));
        TRAINEE.IntraAgreement{2}.k=zeros(1,1);                  %The consistency evaluation (kappa) for each session in level 2. Each row is an session.
        TRAINEE.IntraAgreement{2}.kj=zeros(1,length(states));
        TRAINEE.IntraAgreement{2}.kstd=zeros(1,1);
        TRAINEE.IntraAgreement{2}.kjstd=zeros(1,length(states));
        TRAINEE.IntraAgreement{2}.kcil=zeros(1,1);
        TRAINEE.IntraAgreement{2}.kcih=zeros(1,1);
        TRAINEE.IntraAgreement{2}.kjcil=zeros(1,length(states));
        TRAINEE.IntraAgreement{2}.kjcih=zeros(1,length(states));
        TRAINEE.ScoredSamples{1}=zeros(1,1);	%The amount of data scored (in samples) each session in level 1. Each row is an session.
        TRAINEE.ScoredSamples{2}=zeros(1,1);	%The amount of data scored (in samples) each session in level 2. Each row is an session.
        TRAINEE.PracticeTime{1}=zeros(1,1);     %The time (in seconds) required to complete practice in each session in level 1. Each row is an session.
        TRAINEE.PracticeTime{2}=zeros(1,1);     %The time (in seconds) required to complete practice in each session in level 2. Each row is an session.
        TRAINEE.IterationTime{1}=zeros(1,1);	%The time (in seconds) required to complete each session in level 1. Each row is an session.
        TRAINEE.IterationTime{2}=zeros(1,1);	%The time (in seconds) required to complete each session in level 2. Each row is an session.
        TRAINEE.IterationTime{1}=zeros(1,1);	%The time (in seconds)
        TRAINEE.IterationTime{2}=zeros(1,1);	%The time (in seconds)
        TRAINEE.savepath=scordir;
        TRAINEE.savename=['trainee_' TRAINEE.Scorer '.mat'];
        TRAINEE.RIPScoreVersion=RIPScoreVersion;
        TRAINEE.WorkingSession.isActive=0;
        TRAINEE.WorkingSession.fileSaved='';
        TRAINEE.WorkingSession.fileBackup='';
        TRAINEE.WorkingSession.fileSelected='';
        
        save([TRAINEE.savepath TRAINEE.savename],'TRAINEE');
        verbose(['Trainee.savename: ' TRAINEE.savename],ShowMsgs);
    end
    
    switch TRAINEE.level
        case 1
            uiwait(warndlg('Your current level is: 1 of 2','Level 1','modal'));
        case 2
            uiwait(warndlg('Your current level is: 2 of 2','Level 2','modal'));
        case 3
            errordlg([TRAINEE.Scorer ' has completed the training.'],'Training Complete', 'modal');
            return;
    end
    
    if(TRAINEE.WorkingSession.isActive==1)  %If the session has not been finished and is being opened
        saveVer=dir(TRAINEE.WorkingSession.fileSaved);
        backVer=dir(TRAINEE.WorkingSession.fileBackup);
        if size(saveVer,1)>0 && size(backVer,1)>0
            msg=['There are two stored versions of scores for this file.' char(10) char(10) '     SAVED version:' char(10) saveVer.date '.' char(10) char(10) '     BACKUP version:' char(10) backVer.date '.' char(10) char(10) 'Do you want to work with the SAVED or the BACKUP version?'];
            whichVer=questdlg([msg ''],'Select Stored Version','SAVED','BACKUP','SAVED');
        elseif size(saveVer,1)>0 && size(backVer,1)<=0
            whichVer='SAVED';
        elseif size(saveVer,1)<=0 && size(backVer,1)>0
            whichVer='BACKUP';
        else
            whichVer='NEW';
        end
        switch whichVer
            case 'SAVED'
                TRAINEE.WorkingSession.fileSelected=TRAINEE.WorkingSession.fileSaved;
                verbose('Loaded SAVED Version.',ShowMsgs);
            case 'BACKUP'
                TRAINEE.WorkingSession.fileSelected=TRAINEE.WorkingSession.fileBackup;
                verbose('Loaded BACKUP Version.',ShowMsgs);
            case 'NEW'
                TRAINEE.WorkingSession.isActive=0;
                TRAINEE.WorkingSession.fileSaved='';
                TRAINEE.WorkingSession.fileBackup='';
                TRAINEE.WorkingSession.fileSelected='';
                verbose('New file, could not find saved version.',ShowMsgs);
        end
    elseif(TRAINEE.WorkingSession.isActive==0)
        TRAINEE.iteration(TRAINEE.level)=TRAINEE.iteration(TRAINEE.level)+1;    %We are in the next session now.
    end
    
    %The results will be saved in this path
    pathname=scordir;

    %And will have this name, indicating the TRAINEE, level and iteration
    savename=[pathname 'trained_' trainee '_level_' num2str(TRAINEE.level) '_iteration_' num2str(TRAINEE.iteration(TRAINEE.level)) '.mat'];
    verbose(['Save name: ' savename],ShowMsgs);
    
    %Load "true-state" library
    aux=load(TrueState_Library_path);
    TrueState_Library=aux.goldenEvents;
    clear aux
    
    %Call to the GUI App
    RIPScore_training(TRAINEE,savename,TrueState_Library,wL,winType,ConsecutiveEvts,pctEvt,trainLength,testLength,EpochLen,B,ALPHA,thresholdTimePerEvent,ThresholdLowestKappa,ThresholdEffectiveTrainTime,ShowMsgs,Fs);
else
    errordlg(['RIPScore mode=' num2str(guiMode) ' not supported'],'Mode Not Supported','modal');
    return;
end