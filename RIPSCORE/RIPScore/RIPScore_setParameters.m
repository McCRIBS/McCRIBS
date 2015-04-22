function [] = RIPScore_setParameters(AppDir)
%RIPSCORE_SETPARAMETERS configures RIPScore
%	[] = RIPScore_setParameters(AppDir) saves RIPScore's
%       configuration in the file 'cnf.mat'.
%
%   INPUT
%   AppDir is a string with the path to the directory
%       containing the main application file (RIPScore.m).
%
%   OUTPUT
%
%   EXAMPLE
%   RIPScore_setParameters(AppDir);
%
%   VERSION HISTORY
%   2015_04_13 - Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, G. Bertolizio, K. A. Brown, and R. E. Kearney,
%       "Scoring Tools for the Analysis of Infant Respiratory
%       Inductive Plethysmography Signals," submitted to
%       PLoS One, 2015.
%
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

    %% RIPScore Mode (guiMode: (0) Administrator (open), (1) Blind scorer (default), (2) Training)
    modeAdmin='Administrator (open)';
    modeBlind='Blind scorer (default)';
    modeTrain='Training';
    chGuiMode=questdlg('Select RIPScore Mode','RIPScore Mode',modeAdmin,modeBlind,modeTrain,modeBlind);
    switch chGuiMode
        case ''         %User closed window
            guiMode=1;
        case modeAdmin	%Administrator (open)
            guiMode=0;
        case modeBlind	%Blind scorer (default)
            guiMode=1;
        case modeTrain	%Training
            guiMode=2;
        otherwise       %Default
            guiMode=1;
    end
    clear modeAdmin modeBlind modeTrain chGuiMode

    %% Path to directory where scoring results are saved
    uiwait(msgbox('Select directory where scoring results are saved','Scoring results path','warn'));
    pause(0.25);
    scordir=uigetdir(AppDir,'Scoring results path');
    scordir=[scordir '\'];
    uiwait(msgbox(['Scoring results will be saved to: ' char(10) scordir],'Scoring results path','warn'));
    
    %% Path to directory where data records are stored
    uiwait(msgbox('Select directory where data records are stored','Data records path','warn'));
    pause(0.25);
    datadir=uigetdir([scordir '..\'],'Data records path');
    datadir=[datadir '\'];
    uiwait(msgbox(['Data records will be loaded from: ' char(10) datadir],'Data records path','warn'));

    %% Set Environment Variables
    dlg_title='Set Environment Variables';
    prompt={'Enter Epoch Length (s):','Enter Sampling Frequency (Hz):'};
    defAns={'30','50'};
    num_lines=[1 35; 1 35];
    envVars=inputdlg(prompt,dlg_title,num_lines,defAns);

    EpochLen=str2double(envVars{1});	%Length of the data epoch in seconds.
    Fs=str2double(envVars{2});          %Sampling frequency in Hz.
    clear dlg_title prompt defAns num_lines envVars

    %% Training Mode Variables
    dlg_title='Set Training Mode Variables';
    prompt={'Bootstrap resamples to estimate standard deviations (#):',...
        'ALPHA for (1-ALPHA) confidence intervals:',...
        'wL (half the length in samples of the segment concatenation window, see combineSignals):',...
        'winType (type of concatenation window, see combineSignals):',...
        'Consecutive segments (of each state type) to finish practice stage (#):',...
        'Segment proportion that has to be correctly identified to be considered detected (in practice stage):',...
        'Maximum length (in s) of practice stage before starting the testing stage:',...
        'Length (in s) of the testing stage:',...
        'Effective training time inclusion threshold (in s):',...
        'Kappa threshold to advance level:',...
        'Effective training time threshold to advance level (in s):'};
    defAns={'500','0.01','18','1','5','0.8',num2str(60*60),num2str(65*60),num2str(2*60),'0.8',num2str(4*60*60)};
    num_lines=[1 60;1 60;1 60;1 60;1 60;1 60;1 60;1 60;1 60;1 60;1 60];
    trainVars=inputdlg(prompt,dlg_title,num_lines,defAns);
    
    B=str2double(trainVars{1});                 %Number of bootstrap resamples for estimation of standard deviations
    ALPHA=str2double(trainVars{2});
    wL=str2double(trainVars{3});                %Half the length of the segment concatenation window (see combineSignals)
    winType=str2double(trainVars{4});           %Type of the segment concatenation window (see combineSignals)
    ConsecutiveEvts=str2double(trainVars{5});	%Number of consecutive segments (of each type) to finish practice stage
    pctEvt=str2double(trainVars{6});            %The proportion of the segment that has to be correctly identified to be considered detected (in practice stage)
    trainLength=str2double(trainVars{7})*Fs;	%Maximum length (in samples) of practice stage before starting the testing stage.
    testLength=str2double(trainVars{8})*Fs;     %Length (in samples) of the testing stage.
    thresholdTimePerEvent=str2double(trainVars{9});         %The maximum time that will be counted for effective scoring time between two segments scored one after the other. In seconds
    ThresholdLowestKappa=str2double(trainVars{10});         %If the lowest kappa lower limit is >= 0.8
    ThresholdEffectiveTrainTime=str2double(trainVars{11});	%If the effective training time was below 4 hrs
    clear dlg_title prompt defAns num_lines trainVars

    %% Full path to the library of "true-state" segments
    uiwait(msgbox('Select the "true-state" segment library file.','"True-state" Library','warn'));
    pause(0.25);
    [tslFilename,tslPathname]=uigetfile({'*.mat','MATLAB file'},'"True-state" Library');
    TrueState_Library_path=[tslPathname tslFilename];
    uiwait(msgbox(['The "true-state" segment library will be loaded from: ' char(10) TrueState_Library_path],'"True-state" Library','warn'));
    clear tslFilename tslPathname
    
    %% Define states
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
    clear index
    
	%% Other variables
    ShowMsgs=false;     %Flag to indicate whether messages should be sent to the standard output
    % RIP high-pass filter
    [z_HP_RIP,p_HP_RIP,k_HP_RIP]=cheby1(6,0.1,0.0825/(Fs/2),'high');  %High-pass filter for very low frequency trends in RIP signals
    [sos_HP_RIP,g_HP_RIP]=zp2sos(z_HP_RIP,p_HP_RIP,k_HP_RIP);

    %% Save configuration
    save([AppDir '\cnf.mat']);
    
    uiwait(msgbox(['RIPScore has been configured.' char(10)  char(10) 'To modify the configuration:' char(10) '   - run ''RIPScore_setParameters'', or' char(10) '   - delete the file "' AppDir '\cnf.mat" and re-load RIPScore.' char(10)],'Configuration Finished','warn'));
end