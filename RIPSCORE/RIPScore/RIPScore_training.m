function varargout = RIPScore_training(varargin)
%RIPScore training screen.
%	GUI generated using MATLAB's GUIDE (The MathWorks Inc., Natick, MA, USA).
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

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @RIPScore_training_OpeningFcn, ...
                       'gui_OutputFcn',  @RIPScore_training_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT
end

% --- Executes just before RIPScore_training is made visible.
function RIPScore_training_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RIPScore_training (see VARARGIN)

% Choose default command line output for OpenFile
    handles.output=hObject;
% Update handles structure
    guidata(hObject,handles);

% Setup list of fields used for Save/Backup
    handles.stateFields={'TRAINEE','SCORING','IsTesting','datadir','wL','winType','ConsecutiveEvts','pctEvt',...
        'trainLength','testLength','B','ALPHA','thresholdTimePerEvent','ThresholdLowestKappa','ThresholdEffectiveTrainTime',...
        'ShowMsgs','EpochSize','Fs','TimeShiftConstant','ASBcolor','PAUcolor','MVTcolor','SYBcolor','SIHcolor','UNKcolor','NILcolor',...
        'savename','START','END','clickSample','eventIndex','states','statesStr','RCG','ABD','PPG','SAT','State','EventID',...
        'IsTestSegment','lastEventPreview','samplesForLimitsDisplay','useRealData','signalLength','lastScoredSample',...
        'BreathTroughsRCG','BreathTroughsABD','maxStartTime','evaluateExitPractice','timeL','timeH',...
        'testData','testState','testEventID'};
    
%Make a local copy of TRAINEE
    handles.TRAINEE=varargin{1};

    if(handles.TRAINEE.WorkingSession.isActive==0)
    %SCORING is initialized
        handles.SCORING={};
        handles.SCORING.NextScore=1;
        handles.SCORING.Events=zeros(0,4);
        handles.SCORING.Scorer=handles.TRAINEE.Scorer;
        handles.SCORING.Comments.start=[];
        handles.SCORING.Comments.end=[];
        handles.SCORING.Comments.eventID=[];
        handles.SCORING.Comments.comment={};
        handles.SCORING.ElapsedTime=0;
        handles.SCORING.Completed=0;
        handles.SCORING.FileName=varargin{2};
        handles.SCORING.RIPScoreVersion=handles.TRAINEE.RIPScoreVersion;

        guidata(hObject, handles);

        handles.IsTesting=0;
        handles.datadir=handles.TRAINEE.savepath;

    %Get "true-state" library
        TrueState_Library=varargin{3};

	%Get simulation parameters
        handles.wL=varargin{4};
        handles.winType=varargin{5};
        handles.ConsecutiveEvts=varargin{6};
        handles.pctEvt=varargin{7};
        handles.trainLength=varargin{8};
        handles.testLength=varargin{9};

    %Performance evaluation parameters
        handles.B=varargin{11};
        handles.ALPHA=varargin{12};
        handles.thresholdTimePerEvent=varargin{13};

    %Change of Level parameters
        handles.ThresholdLowestKappa=varargin{14};          %If the lowest kappa lower limit is >= 0.8
        handles.ThresholdEffectiveTrainTime=varargin{15};   %If the effective training time was below 4 hrs

    %Get verbose option
        handles.ShowMsgs=varargin{16};

    %Get Epoch Size selected and set Sampling Frequency
        handles.EpochSize=varargin{10};
        handles.Fs=varargin{17}; %Hertz
        handles.TimeShiftConstant=round(handles.EpochSize*2/3); %seconds

    %Set constants for color coding of events
        handles.PAUcolor=stateColor('PAU');
        handles.ASBcolor=stateColor('ASB');
        handles.MVTcolor=stateColor('MVT');
        handles.SYBcolor=stateColor('SYB');
        handles.SIHcolor=stateColor('SIH');
        handles.UNKcolor=stateColor('UNK');
        handles.NILcolor=stateColor('NIL');

        handles.savename = varargin{2};
        handles.START=[];
        handles.END=[];
        handles.clickSample=[];
        handles.eventIndex=[];

        handles.states=[1,2,3,4,5,99];
        handles.statesStr={'PAU';'ASB';'MVT';'SYB';'SIH';'UNK'};

    %Generate data for plots
        handles.RCG=[];
        handles.ABD=[];
        handles.PPG=[];
        handles.SAT=[];
        handles.State=[];
        handles.EventID=[];
        handles.IsTestSegment=[]; %0 -> training; 1 -> testing.

        handles.lastEventPreview=7.5;   %Seconds to show from the last scored segment
        handles.samplesForLimitsDisplay=1.26*handles.Fs;

        %Generate data
        handles.useRealData=[];
        if handles.TRAINEE.level==1
            handles.useRealData=0;  %"Simulated-state" data
        else
            handles.useRealData=1;  %"True-state" data
        end
        Events=generateEvents(handles.useRealData,handles.trainLength,TrueState_Library,handles.wL,true);
        [Data,State,EventID]=artificialData(Events,handles.wL,handles.winType);

        %Assign data to each signal
        handles.RCG=Data(:,1);
        handles.ABD=Data(:,2);
        handles.PPG=Data(:,3);
        handles.SAT=Data(:,4);
        handles.State=State;
        handles.EventID=zeros(size(EventID));
        handles.IsTestSegment=zeros(size(handles.RCG));

        %Recalculate signal parameters
        handles.signalLength=length(handles.RCG);
        handles.lastScoredSample=getNextRemainingSample(handles.SCORING.Events,handles.signalLength)-1;

        %Obtain estimates of breath segmentation
        Nba=101;
        Nbn=1;
        auxPeaksTroughs=breathSegmentation(handles.RCG,Nba,Nbn,handles.Fs,handles.ShowMsgs);
        handles.BreathTroughsRCG=auxPeaksTroughs(auxPeaksTroughs(:,2)==0,:);
        clear auxPeaksTroughs
        auxPeaksTroughs=breathSegmentation(handles.ABD,Nba,Nbn,handles.Fs,handles.ShowMsgs);
        handles.BreathTroughsABD=auxPeaksTroughs(auxPeaksTroughs(:,2)==0,:);
        clear auxPeaksTroughs

        % Calculate the maximum start time
        handles.maxStartTime=length(handles.RCG)./handles.Fs-handles.EpochSize;

    %Initialize practice exit condition
        handles.evaluateExitPractice=ones(size(handles.states));    %This is the sample from which the exit condition has to be evaluated for each state type

    %Get first segment to display
        newStart=getNextRemainingSample(handles.SCORING.Events,handles.signalLength)/handles.Fs-handles.lastEventPreview;
        if (newStart<0)
            newStart=0;
        elseif (newStart>handles.maxStartTime)
            newStart=handles.maxStartTime;
        elseif isempty(newStart)
            newStart=handles.maxStartTime;
        end
        handles.SCORING.currentTime=newStart;
        clear newStart;
        handles.timeL=handles.SCORING.currentTime;
        handles.timeH=handles.SCORING.currentTime+handles.EpochSize;

        guidata(hObject, handles);

    %Generate data for test stage
        clear Events Data State EventID
        %Generate test signals
        Events1=generateEvents(handles.useRealData,ceil(handles.testLength/2),TrueState_Library,handles.wL,true);
        numEvents=length(Events1.type);

        %After Events have been generated, they are shuffled and appended
        %for test-retest analysis.
        randIx=randsample(numEvents,numEvents);
        
        preEvents.Data={};
        preEvents.type=zeros(numEvents,1);
        preEvents.length=zeros(numEvents,1);
        preEvents.eventID=zeros(numEvents,1);

        for index=1:numEvents
            preEvents.Data{index}=Events1.Data{randIx(index)};
            preEvents.type(index)=Events1.type(randIx(index));
            preEvents.length(index)=Events1.length(randIx(index));
            preEvents.eventID(index)=Events1.eventID(randIx(index));
        end

        newIndices=pushRepeatedTypes(preEvents.type,[1:1:numEvents]');
    
        Events2.Data={};
        Events2.type=zeros(numEvents,1);
        Events2.length=zeros(numEvents,1);
        Events2.eventID=zeros(numEvents,1);

        for index=1:numEvents
            Events2.Data{index}=preEvents.Data{newIndices(index)};
            Events2.type(index)=preEvents.type(newIndices(index));
            Events2.length(index)=preEvents.length(newIndices(index));
            Events2.eventID(index)=preEvents.eventID(newIndices(index));
        end
    
        %The complete list of events for test - retest analysis
        Events.Data={};
        Events.type=zeros(numEvents*2,1);
        Events.length=zeros(numEvents*2,1);
        Events.eventID=zeros(numEvents*2,1);
        for index=1:numEvents
            Events.Data{index}=Events1.Data{index};
            Events.type(index)=Events1.type(index);
            Events.length(index)=Events1.length(index);
            Events.eventID(index)=Events1.eventID(index);
        end
        for index=1:numEvents
            Events.Data{index+numEvents}=Events2.Data{index};
            Events.type(index+numEvents)=Events2.type(index);
            Events.length(index+numEvents)=Events2.length(index);
            Events.eventID(index+numEvents)=Events2.eventID(index);
        end

        [handles.testData,handles.testState,handles.testEventID]=artificialData(Events,handles.wL,handles.winType);
        guidata(hObject,handles);

    %Setup Save/Backup options
        handles.TRAINEE.WorkingSession.isActive=1;
        handles.TRAINEE.WorkingSession.fileSaved=[handles.savename(1:end-4) '_SAVED.mat'];
        handles.TRAINEE.WorkingSession.fileBackup=[handles.savename(1:end-4) '_BACKUP.mat'];
    elseif(handles.TRAINEE.WorkingSession.isActive==1)
        load(handles.TRAINEE.WorkingSession.fileSelected,'stateHandles');
        handles.TRAINEE.WorkingSession.fileSelected='';
        for index=1:length(handles.stateFields)
            handles.(handles.stateFields{index})=stateHandles.(handles.stateFields{index});
        end
    end
    clear TrueState_Library     %To save memory

    set(handles.RIPScore_training_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));

    % Control Flags
    handles.flag=0;
    handles.isScoring=0;
    handles.forceDelete=0;
    
% Setup the Timer Interruption for Backup
    handles.TimerPeriod=5*60;
    handles.mytimer=timer('TimerFcn',{@TmrFcn,hObject},'BusyMode','Queue','ExecutionMode','FixedRate','Period',handles.TimerPeriod,'StartDelay',handles.TimerPeriod);
    guidata(hObject,handles);
    start(handles.mytimer);
    
    guidata(hObject, handles);
    
% Start tic
    handles.ticID=tic;
    guidata(hObject,handles);
    
%Remove toolbar buttons that are not needed
    h=findall(handles.RIPScore_training_figure,'tooltip','Insert Legend');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Insert Colorbar');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','New Figure');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Print Figure');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Open File');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Save Figure');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Show Plot Tools');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Hide Plot Tools');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Rotate 3D');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Pan');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Edit Plot');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Zoom In');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Zoom Out');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Data Cursor');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Brush/Select Data');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Link Plot');
    set(h,'Visible','off');
    h=findall(handles.RIPScore_training_figure,'tooltip','Show Plot Tools and Dock Figure');
    set(h,'Visible','off');

%Plot
    plot_data(handles,'yes');

% UIWAIT makes RIPScore_training wait for user response (see UIRESUME)
    uiwait(handles.RIPScore_training_figure);
end

% --- Outputs from this function are returned to the command line.
function varargout = RIPScore_training_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    stop(handles.mytimer);
    delete(handles.mytimer);
    guidata(hObject,handles);

% Get default command line output from handles structure
    varargout{1}=handles.output;

%Close figure
    delete(handles.RIPScore_training_figure);
end

% --- Executes on button press in RIPScore_training_button_PAU.
function RIPScore_training_button_PAU_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_PAU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    storedata(handles.RIPScore_training_figure,handles,1);
end

% --- Executes on button press in RIPScore_training_button_ASB.
function RIPScore_training_button_ASB_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_ASB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    storedata(handles.RIPScore_training_figure,handles,2);
end

%--- Executes on button press in RIPScore_training_button_MVT.
function RIPScore_training_button_MVT_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_MVT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    storedata(handles.RIPScore_training_figure,handles,3);
end

% --- Executes on button press in RIPScore_training_button_SYB.
function RIPScore_training_button_SYB_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_SYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    storedata(handles.RIPScore_training_figure,handles,4);
end

% --- Executes on button press in RIPScore_training_button_SIH.
function RIPScore_training_button_SIH_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_SIH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    storedata(handles.RIPScore_training_figure,handles,5);
end

% --- Executes on button press in RIPScore_training_button_UNK.
function RIPScore_training_button_UNK_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_UNK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    storedata(handles.RIPScore_training_figure,handles,99);
end

% --- Executes on key press with focus on RIPScore_training_figure or any of its controls.
function RIPScore_training_figure_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_figure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    if(strcmp(lower(eventdata.Key),'s'))
        verbose(['''s'' key pressed!'],handles.ShowMsgs);
        RIPScore_training_button_StartScoring_Callback(handles.RIPScore_training_button_StartScoring,eventdata,handles);
    elseif(handles.isScoring==1)
        if(not(isempty(handles.END)))
            if(strcmp(eventdata.Key,'1') || strcmp(eventdata.Key,'numpad1'))
                code=1;
            elseif(strcmp(eventdata.Key,'2') || strcmp(eventdata.Key,'numpad2'))
                code=2;
            elseif(strcmp(eventdata.Key,'3') || strcmp(eventdata.Key,'numpad3'))
                code=3;
            elseif(strcmp(eventdata.Key,'4') || strcmp(eventdata.Key,'numpad4'))
                code=4;
            elseif(strcmp(eventdata.Key,'5') || strcmp(eventdata.Key,'numpad5'))
                code=5;
            elseif(strcmp(eventdata.Key,'9') || strcmp(eventdata.Key,'numpad9'))
                code=99;
            end
            if(exist('code'))
                storedata(hObject,handles,code);
                clear code;
            end
        end
    end
end

% --- Executes on button press in RIPScore_training_button_StartScoring.
function RIPScore_training_button_StartScoring_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_StartScoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (handles.isScoring==0)
        if(handles.flag == 0)
            if(getNextRemainingSample(handles.SCORING.Events,handles.signalLength)<=handles.signalLength)
                %If we are in Visualization Mode, switch to Scoring Mode
                set(hObject,'String','(S)top Scoring')
                handles.isScoring=1;
                handles.flag=1;
                handles.clickSample=[];
                handles.eventIndex=[];  %Deselect the segment for deletion

                handles.START=[];
                handles.END=[];

                guidata(handles.RIPScore_training_figure,handles);

                getNextEndTime(handles.RIPScore_training_figure);
            else
               errordlg('The recording has been scored completely, there are no segments without scoring','Finished Scoring','modal'); 
            end
        end
    else
        %If we are in Scoring Mode, switch to Visualization Mode
        set(hObject,'String','(S)tart Scoring');
        handles.isScoring = 0;
        handles.START = [];
        handles.END = [];
        set(handles.RIPScore_training_edit_SegmSt,'string','');
        set(handles.RIPScore_training_edit_SegmEn,'string','');
        handles.flag = 0;
        guidata(handles.RIPScore_training_figure,handles);
        plot_data(handles,'Stop Scoring')
    end
end

%Execute command on click of StateScoring buttons or hot-keys
function storedata(hObject,handles,code)
    if(handles.isScoring == 1)
        %If we are in Scoring Mode, save the properties of the scored segment
        if(isempty(handles.END))
            errordlg('No segment has been selected for scoring','No Input','modal');
        else
            if handles.END*handles.Fs>handles.signalLength
                handles.END=handles.signalLength./handles.Fs;
            end

            %Save the segment properties
            handles.SCORING.Events(handles.SCORING.NextScore,:)=[round(handles.START*handles.Fs) round(handles.END*handles.Fs) code now];
            handles.SCORING.NextScore=handles.SCORING.NextScore+1;

            %Identify the last scored sample
            handles.lastScoredSample=getNextRemainingSample(handles.SCORING.Events,handles.signalLength)-1;
            isIncorrect=0;

            if handles.IsTesting==0 %If TRAINEE is in practice stage
                %Evaluate if last scored segment is correct
                segmEvt=handles.State(handles.SCORING.Events(handles.SCORING.NextScore-1,1):handles.SCORING.Events(handles.SCORING.NextScore-1,2)); %Get the Actual State for the selected segment
                segmEvt=segmEvt(segmEvt>0); %Discard transition samples
                pctIdentified=mean(segmEvt==code);
                isIncorrect=pctIdentified<handles.pctEvt;
                
                if isIncorrect
                    %If TRAINEE only identified less than handles.pctEvt, then they have to review and correct accordingly
                    plot_data(handles,'storedata - incorrect score')
                    ShowCursorData(handles)
                    msg=['The last segment was scored incorrectly.' char(10) char(10) 'Please review the Actual State and the highlighted signals.' char(10) char(10) 'Click "OK" to correct your score.' char(10)];
                    uiwait(errordlg([msg ''],'Incorrect State','modal'));
                    
                    %Reset condition to exit practice in the incorrect events
                    %   in the state type of the one that was not identified,
                    whichStates=unique(segmEvt);
                    auxmsg=[''];
                    for index=1:length(whichStates)
                        handles.evaluateExitPractice(handles.states==whichStates(index))=max(handles.SCORING.Events(handles.SCORING.NextScore-1,2)+1,handles.evaluateExitPractice(handles.states==whichStates(index)));
                        auxmsg=[auxmsg ' ' handles.statesStr{handles.states==whichStates(index)}];
                    end
                    %   in the one that was incorrectly selected.
                    handles.evaluateExitPractice(handles.states==code)=handles.SCORING.Events(handles.SCORING.NextScore-1,2)+1;
                    verbose(['Segment incorrectly scored:'],handles.ShowMsgs);
                    verbose([char(9) 'True type: ' auxmsg],handles.ShowMsgs);
                    verbose([char(9) 'Scor type: ' handles.statesStr{handles.states==code}],handles.ShowMsgs);
                    verbose([char(9) 'Updated exit eval starts: '],handles.ShowMsgs);
                    for index=1:length(handles.states)
                        verbose([char(9) char(9) handles.statesStr{index} ': ' num2str(handles.evaluateExitPractice(index)./handles.Fs,'%1.2f') ' s'],handles.ShowMsgs);
                    end
                    
                    %Delete segment
                    handles.eventIndex=handles.SCORING.NextScore-1;
                    handles.clickSample=round(mean(handles.SCORING.Events(handles.eventIndex,1:2)));
                    
                    %Find the comments that do not correspond to the selected coordinates
                    idxComments=find(not(and(handles.SCORING.Comments.start<=handles.clickSample,handles.SCORING.Comments.end>=handles.clickSample)));
            
                    %Delete segment's comments (keep only the comments from the rest of the segments)                    
                    handles.SCORING.Comments.start=handles.SCORING.Comments.start(idxComments);
                    handles.SCORING.Comments.end=handles.SCORING.Comments.end(idxComments);
                    handles.SCORING.Comments.comment=handles.SCORING.Comments.comment(idxComments);
                    handles.SCORING.Comments.eventID=handles.SCORING.Comments.eventID(idxComments);

                    indexes=ones(handles.SCORING.NextScore-1,1);
                    indexes(handles.eventIndex)=0;
                    indexes=(indexes==1);
                    auxEvents=handles.SCORING.Events(indexes,:);
                    handles.SCORING.Events=auxEvents;
                    handles.SCORING.NextScore=handles.SCORING.NextScore-1;
                    set(handles.RIPScore_training_edit_SegmSt,'string','');
                    set(handles.RIPScore_training_edit_SegmEn,'string','');
                    handles.clickSample=[];
                    handles.eventIndex=[];

                    handles.SCORING.Completed=0;
                    guidata(handles.RIPScore_training_figure,handles);
                end
            end
            
            guidata(handles.RIPScore_training_figure,handles)
            if isempty(handles.lastScoredSample) && handles.IsTesting    %This is the end of the recording (at the testing stage)
                %Stop Scoring
                set(handles.RIPScore_training_button_StartScoring,'String','(S)tart Scoring');
                handles.isScoring = 0;
                handles.START=[];
                handles.END=[];
                set(handles.RIPScore_training_edit_SegmSt,'string','');
                set(handles.RIPScore_training_edit_SegmEn,'string','');
                handles.flag=0;
                handles.SCORING.Completed=1;

                guidata(handles.RIPScore_training_figure,handles);
                plot_data(handles,'(S)top Scoring')
                Conclude_Session(handles.RIPScore_training_figure,handles);
            else
                if handles.IsTesting==0 && ~isIncorrect
                    %Determine if the exit condition has been met to start the testing stage
                    handles=StartTest(handles.RIPScore_training_figure,handles);
                    guidata(handles.RIPScore_training_figure,handles);
                end
                getNextEndTime(handles.RIPScore_training_figure);
            end
        end
    else
        %If we are in Visualization Mode, move EpochTime to the next segment scored as 'code'
        eventStarts=handles.SCORING.Events(handles.SCORING.Events(:,3)==code,1);
        nextEvents=eventStarts(eventStarts>(handles.SCORING.currentTime+handles.lastEventPreview+0.2).*handles.Fs);
        if(~isempty(nextEvents))
            timeAux=min(nextEvents)./handles.Fs-handles.lastEventPreview;
            if(timeAux>handles.maxStartTime)
                timeAux=handles.maxStartTime;
            end
            handles.SCORING.currentTime=timeAux;
            set(handles.RIPScore_training_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));
            handles.timeL=handles.SCORING.currentTime;
            handles.timeH=handles.SCORING.currentTime+handles.EpochSize;
            guidata(handles.RIPScore_training_figure,handles);
            plot_data(handles,'goToNextEvent');
        end
    end
end

%Determines if the transition to the testing stage has been met.
%If so, it changes the mode and begins the test.
function handles=StartTest(hObject,handles)
    handles.flag=1;
    guidata(hObject,handles);
    startFlag=0;
    
    %Determine if exit condition has been met
    if handles.signalLength/handles.Fs-(handles.timeL+handles.lastEventPreview) < handles.EpochSize
        %If there is only one epoch left in the recording
        verbose(['Less than 1 epoch condition to start test...'],handles.ShowMsgs);
        startFlag=1;
    else
        exitNumEach=zeros(size(handles.evaluateExitPractice));
        exitCondition=zeros(size(handles.evaluateExitPractice));
        lastScoredSample=max(handles.SCORING.Events(:,2));
        myEvents=sortrows(signal2events(handles.State(1:lastScoredSample)),1);
        lastUndeterminedState=find(myEvents(:,3)==0,1,'last');  %This is the last undetermined segment
        myEvents=myEvents(1:lastUndeterminedState-1,:);
        for index=1:length(exitCondition)
            exitNumEach(index)=size(myEvents(and(myEvents(:,1)>=handles.evaluateExitPractice(index),myEvents(:,3) == handles.states(index))),1);
            exitCondition(index)=(exitNumEach(index) >= handles.ConsecutiveEvts);
        end
        verbose(['Events in a row (exit condition):'],handles.ShowMsgs);
        for index=1:length(handles.states)
            verbose([char(9) handles.statesStr{index} ': ' num2str(exitNumEach(index))],handles.ShowMsgs);
        end
        if sum(exitCondition)==length(exitCondition)
            startFlag=1;
            verbose([num2str(handles.ConsecutiveEvts) ' consecutive of each state type condition to start test...'],handles.ShowMsgs);
        end
    end
    
    %Determine the last sample in practice mode
    lastPracticeSample=round(handles.timeH*handles.Fs)-1;
    
    if startFlag==1 %If testing mode has to start
        verbose(['Initializing testing mode...'],handles.ShowMsgs);
        %Set mode
        handles.IsTesting=1;
        
        %Store time elapsed during practice at this iteration
        handles.TRAINEE.PracticeTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level))=handles.SCORING.ElapsedTime+toc(handles.ticID);
        
        %Output message to trainee
        msg=['Practice has been completed.' char(10) char(10) 'The test stage will start shortly...' char(10) 'During the test the Actual States will not be shown for comparison.' char(10) 'The test consists of ' num2str(handles.testLength./(60*60*handles.Fs),'%1.1f') ' hrs of recording.' char(10)];
        uiwait(warndlg([msg ''],'Results','modal'));
        
        %Concatenate the signals of practice and testing stages
        [auxData,trIx]=combineSignals([handles.RCG(1:lastPracticeSample),handles.ABD(1:lastPracticeSample),handles.PPG(1:lastPracticeSample),handles.SAT(1:lastPracticeSample)],handles.testData,handles.wL,handles.winType);
        auxState=zeros(size(auxData,1),1);
        limOld=length(handles.State);
        if limOld>length(auxState)
            limOld=length(auxState);
        end
        auxState(1:limOld)=handles.State(1:limOld);
        auxState(trIx(1):end)=handles.testState;
        auxState(trIx)=0;
        handles.State=auxState;
    
        auxEventID=zeros(size(auxData,1),1);
        limOld=length(handles.EventID);
        if limOld>length(auxEventID)
            limOld=length(auxEventID);
        end
        auxEventID(1:limOld)=handles.EventID(1:limOld);
        auxEventID(trIx(1):end)=handles.testEventID;
        auxEventID(trIx)=0;
        handles.EventID=auxEventID;
        
        auxIsTestSegment=zeros(size(auxData,1),1);
        auxIsTestSegment(trIx(end)+1:end)=1;
        handles.IsTestSegment=auxIsTestSegment;
        
        handles.RCG=auxData(:,1);
        handles.ABD=auxData(:,2);
        handles.PPG=auxData(:,3);
        handles.SAT=auxData(:,4);
        
        %Recalculate signal parameters
        handles.signalLength=length(handles.RCG);
        handles.lastScoredSample=getNextRemainingSample(handles.SCORING.Events,handles.signalLength)-1;
        
        %Obtain estimates of breath segmentation
        Nba=101;
        Nbn=1;
        auxPeaksTroughs=breathSegmentation(handles.RCG,Nba,Nbn,handles.Fs,handles.ShowMsgs);
        handles.BreathTroughsRCG=auxPeaksTroughs(auxPeaksTroughs(:,2)==0,:);
        clear auxPeaksTroughs
        auxPeaksTroughs=breathSegmentation(handles.ABD,Nba,Nbn,handles.Fs,handles.ShowMsgs);
        handles.BreathTroughsABD=auxPeaksTroughs(auxPeaksTroughs(:,2)==0,:);
        clear auxPeaksTroughs
        
        % Calculate the maximum start time
        handles.maxStartTime=length(handles.RCG)./handles.Fs-handles.EpochSize;
    end
    handles.flag=0;
    guidata(hObject,handles);
end

%Shifts EpochTime and asks for the end point of the next segment
function getNextEndTime(hObject)
    myhandles=guidata(hObject);
    myhandles.START=getNextRemainingSample(myhandles.SCORING.Events,myhandles.signalLength)/myhandles.Fs;
    remainingSegment=getRemainingSegments(myhandles.SCORING.Events,myhandles.signalLength);
    remainingSegment=remainingSegment(1,:);

    newStart=getNextRemainingSample(myhandles.SCORING.Events,myhandles.signalLength)/myhandles.Fs-myhandles.lastEventPreview;
    if (newStart<0)
        newStart=0;
    elseif (newStart>myhandles.maxStartTime)
        newStart=myhandles.maxStartTime;
    end
    myhandles.timeL=newStart;
    myhandles.timeH=newStart+myhandles.EpochSize;
    myhandles.SCORING.currentTime=myhandles.timeL;
    set(myhandles.RIPScore_training_edit_EpochTime,'string',num2str(myhandles.SCORING.currentTime));
    guidata(hObject,myhandles);
    plot_data(myhandles,'getNextEndTime')
    
    x=[];

    while true
        [x,~,key]=ginput(1);
        if (x>myhandles.START && key==1)
            if (x>remainingSegment(2)/myhandles.Fs)
                x=remainingSegment(2)/myhandles.Fs;
            end
            break;
        elseif (key~=1)
            continue;
        else
            uiwait(errordlg('Error: time selection out of limits','Error','modal'));
        end
    end
    myhandles.END=round(x*myhandles.Fs)/myhandles.Fs;
    
    set(myhandles.RIPScore_training_edit_SegmSt,'string',num2str(myhandles.START,'%10.2f'));
    set(myhandles.RIPScore_training_edit_SegmEn,'string',num2str(myhandles.END,'%10.2f'));
    guidata(hObject,myhandles);
    ShowCursorData(myhandles);
end
    
function [nextSample] = getNextRemainingSample(Events,signalLength)
    remainingSegments=getRemainingSegments(Events,signalLength);
    if (isempty(remainingSegments))
        nextSample=[];
    else
        nextSample=remainingSegments(1,1);
    end
end
    
%Get all segments that have not been scored
function [remainingSegments] = getRemainingSegments(Events,signalLength)
    sortedEvents=sortrows(Events,1);
    Ivect=[sortedEvents(:,1);signalLength+1];
    Fvect=[0;sortedEvents(:,2)];
    holeLength=Ivect-Fvect;
    if(~isempty(find(holeLength<1)))
        errordlg('Error: Segment contains Duplicate Scores','Error','modal');
        return;
    end
    remainingSegments=[Fvect(holeLength>1)+1 Ivect(holeLength>1)-1];
end

% --- Executes on mouse press over axes background.
function RIPScore_training_axes_AssignedState_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_axes_AssignedState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    clickCoords=get(hObject,'CurrentPoint');    %The coordinates of the click over the states' bar
    clickSample=round(clickCoords(1,1).*handles.Fs);

    %Find the segment that corresponds to the selected coordinates
    eventIndex=find(and(handles.SCORING.Events(:,1)<=clickSample,handles.SCORING.Events(:,2)>=clickSample));   %This index will be unique and corresponds to the segment that was selected.
    if(not(isempty(eventIndex)))
        %If segment exists, update Segment Start and End time boxes
        set(handles.RIPScore_training_edit_SegmSt,'string',num2str(handles.SCORING.Events(eventIndex,1)./handles.Fs,'%10.2f'));
        set(handles.RIPScore_training_edit_SegmEn,'string',num2str(handles.SCORING.Events(eventIndex,2)./handles.Fs,'%10.2f'));
        handles.clickSample=clickSample;
        handles.eventIndex=eventIndex;
        %Plot selected segment in RIPScore_training_axes_ABDvsRCG
        timeXPlot=[handles.SCORING.Events(eventIndex,1):handles.SCORING.Events(eventIndex,2)]'./handles.Fs;
        plot(handles.RIPScore_training_axes_ABDvsRCG,handles.ABD(round(timeXPlot.*handles.Fs)),handles.RCG(round(timeXPlot.*handles.Fs)));
        set(handles.RIPScore_training_axes_ABDvsRCG,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
        ylim(handles.RIPScore_training_axes_ABDvsRCG,[min(handles.RCG(round(timeXPlot.*handles.Fs))) max(handles.RCG(round(timeXPlot.*handles.Fs)))]);
        xlim(handles.RIPScore_training_axes_ABDvsRCG,[min(handles.ABD(round(timeXPlot.*handles.Fs))) max(handles.ABD(round(timeXPlot.*handles.Fs)))]);
    else
        %If segment doesn't exist, clear Segment Start and End time boxes
        set(handles.RIPScore_training_edit_SegmSt,'string','');
        set(handles.RIPScore_training_edit_SegmEn,'string','');
        handles.clickSample=[];
        handles.eventIndex=[];
    end
    guidata(hObject,handles);
end

% --- Executes on mouse press over axes background.
function RIPScore_training_axes_RCG_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_axes_RCG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles=guidata(hObject);
    if(handles.flag==0)
        %If not scoring, show horizontal cursors
        currentPoint=get(hObject,'CurrentPoint');
        auxBaseline=handles.RCG(handles.BreathTroughsRCG(handles.BreathTroughsRCG(:,1)<currentPoint(1).*handles.Fs,1));
        showLimits(hObject,get(hObject,'CurrentPoint'),0.9,handles.RCG,auxBaseline(end));
        set(hObject,'ButtonDownFcn', @RIPScore_training_axes_RCG_ButtonDownFcn);
        set(allchild(hObject),'HitTest','off');
        guidata(hObject,handles);
    end
end

% --- Executes on mouse press over axes background.
function RIPScore_training_axes_ABD_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_axes_ABD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles=guidata(hObject);
    if(handles.flag==0)
        %If not scoring, show horizontal cursors
        currentPoint=get(hObject,'CurrentPoint');
        auxBaseline=handles.ABD(handles.BreathTroughsABD(handles.BreathTroughsABD(:,1)<currentPoint(1).*handles.Fs,1));
        showLimits(hObject,currentPoint(),0.9,handles.ABD,auxBaseline(end));
        set(hObject,'ButtonDownFcn', @RIPScore_training_axes_ABD_ButtonDownFcn);
        set(allchild(hObject),'HitTest','off');
        guidata(hObject,handles);
    end
end

%Plot horizontal cursors
function showLimits(hObject,coord,limit,signal,baseline)
    handles=guidata(hObject);
    xSamp=round(coord(1)*handles.Fs);
    if(xSamp<handles.samplesForLimitsDisplay+1)
        xSamp=handles.samplesForLimitsDisplay+1;
    end
    if(xSamp>handles.signalLength)
        xSamp=handles.signalLength;
    end
    amplitude=signal(xSamp)-baseline;
    ytop=signal(xSamp)+amplitude*limit;
    ylow=signal(xSamp)-amplitude*limit;
	plot_data(handles,'yes');
    set(hObject,'NextPlot','add');
    plot([handles.timeL handles.timeH],[ylow ylow],':k');
    plot([handles.timeL handles.timeH],[signal(xSamp) signal(xSamp)],'.-k');
    plot([handles.timeL handles.timeH],[ytop ytop],':k');
    set(hObject,'NextPlot','replacechildren');
    guidata(hObject,handles);
end

% --- Executes on button press in RIPScore_training_button_Delete.
function RIPScore_training_button_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag == 0)
        handles.flag = 1;
        guidata(hObject,handles);
        if(and( not(isempty(handles.eventIndex)) , not(isempty(handles.clickSample)) ))
            verbose(['Delete from Button'],handles.ShowMsgs);
            button=questdlg('Are you sure you want to delete the selected segment?','Delete');
            if(isequal(button,'Yes'))
                verbose([char(9) '... deleting event ...'],handles.ShowMsgs);
                
                %Find the comments that do not correspond to the selected coordinates
                idxComments=find(not(and(handles.SCORING.Comments.start<=handles.clickSample,handles.SCORING.Comments.end>=handles.clickSample)));
            
                %Delete segment's comments (keep only the comments from the rest of the segments)
                handles.SCORING.Comments.start=handles.SCORING.Comments.start(idxComments);
                handles.SCORING.Comments.end=handles.SCORING.Comments.end(idxComments);
                handles.SCORING.Comments.comment=handles.SCORING.Comments.comment(idxComments);
                handles.SCORING.Comments.eventID=handles.SCORING.Comments.eventID(idxComments);

                indexes=ones(handles.SCORING.NextScore-1,1);
                indexes(handles.eventIndex)=0;
                indexes=(indexes==1);
                auxEvents=handles.SCORING.Events(indexes,:);
                handles.SCORING.Events=auxEvents;
                handles.SCORING.NextScore=handles.SCORING.NextScore-1;
                set(handles.RIPScore_training_edit_SegmSt,'string','');
                set(handles.RIPScore_training_edit_SegmEn,'string','');
                handles.clickSample=[];
                handles.eventIndex=[];

                handles.SCORING.Completed=0;
                guidata(handles.RIPScore_training_figure, handles);
                plot_data(handles,'yes');
            end
        else
            errordlg('Error: No segment selected','Error','modal');
        end
        handles.flag = 0;
        guidata(hObject,handles);
    end
end
    
% --- Executes on button press in RIPScore_training_button_Comment.
function RIPScore_training_button_Comment_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag == 0)
        handles.flag = 1;
        guidata(hObject, handles);
        if(not(isempty(handles.eventIndex)))
            comment = inputdlg('Please enter your comment for the selected segment','Comment');
            if(not(isempty(comment)) && not(isempty(comment{1})))
                commentIndex=length(handles.SCORING.Comments.start)+1;
                handles.SCORING.Comments.start(commentIndex)=handles.SCORING.Events(handles.eventIndex,1);
                handles.SCORING.Comments.end(commentIndex)=handles.SCORING.Events(handles.eventIndex,2);
                handles.SCORING.Comments.comment{commentIndex}=comment{1};
                handles.SCORING.Comments.eventID(commentIndex)=handles.eventIndex;
                guidata(hObject, handles);
                plot_data(handles,'yes');
            else
                errordlg('Error: No comment entered.','Error','modal');
            end
        else
            errordlg('Error: No segment selected','Error','modal');
        end
        handles.flag = 0;
        guidata(hObject,handles);
    end
end

% --- Executes on button press in RIPScore_training_button_BadPPG.
function RIPScore_training_button_BadPPG_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_BadPPG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag==0)
        handles.flag=1;
        guidata(hObject,handles);
        if(not(isempty(handles.eventIndex)))
                commentIndex=length(handles.SCORING.Comments.start)+1;
                handles.SCORING.Comments.start(commentIndex)=handles.SCORING.Events(handles.eventIndex,1);
                handles.SCORING.Comments.end(commentIndex)=handles.SCORING.Events(handles.eventIndex,2);
                handles.SCORING.Comments.comment{commentIndex}='Bad PPG';
                handles.SCORING.Comments.eventID(commentIndex)=handles.eventIndex;
                guidata(hObject, handles);
                plot_data(handles,'yes');
        else
            errordlg('Error: No segment selected','Error','modal');
        end
        handles.flag=0;
        guidata(hObject,handles);
    end
end
    
% --- Executes on button press in RIPScore_training_button_Next.
function RIPScore_training_button_Next_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag==0)
        handles.flag=1;
        guidata(hObject,handles);

        if(handles.timeH+handles.TimeShiftConstant > (length(handles.RCG))/handles.Fs)
            %If it goes beyond the number of samples
            handles.timeH=double((length(handles.RCG))/handles.Fs);
            handles.timeL=double(handles.timeH-handles.EpochSize);
        else
            %Shift EpochTime by TimeShiftConstant
            handles.timeL=handles.timeL+handles.TimeShiftConstant;
            handles.timeH=handles.timeH+handles.TimeShiftConstant;
        end
        set(handles.RIPScore_training_edit_SegmSt,'string','');
        set(handles.RIPScore_training_edit_SegmEn,'string','');
        handles.SCORING.currentTime=handles.timeL;
        set(handles.RIPScore_training_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));

        plot_data(handles,'yes');

        handles.clickSample=[];
        handles.eventIndex=[];

        handles.flag=0;
        guidata(hObject,handles);
    end
end

% --- Executes on button press in RIPScore_training_button_Previous.
function RIPScore_training_button_Previous_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_Previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag==0)
        handles.flag=1;
        guidata(hObject,handles);

        if(handles.timeL-handles.TimeShiftConstant < 0)
            %If it goes less than the first sample
            handles.timeL=double(0);
            handles.timeH=double(handles.timeL+handles.EpochSize);
        else
            %Shift EpochTime by TimeShiftConstant
            handles.timeL=handles.timeL-handles.TimeShiftConstant;
            handles.timeH=handles.timeH-handles.TimeShiftConstant;
        end
        set(handles.RIPScore_training_edit_SegmSt,'string','');
        set(handles.RIPScore_training_edit_SegmEn,'string','');
        handles.SCORING.currentTime=handles.timeL;
        set(handles.RIPScore_training_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));

        plot_data(handles,'yes');

        handles.clickSample=[];
        handles.eventIndex=[];

        handles.flag=0;
        guidata(hObject,handles);
    end
end
    
function RIPScore_training_edit_EpochTime_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_edit_EpochTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RIPScore_training_edit_EpochTime as text
%        str2double(get(hObject,'String')) returns contents of RIPScore_training_edit_EpochTime as a double
    if (handles.flag==0)
        handles.flag=1;
        guidata(hObject,handles);

        %Get EpochTime input
        inputCurrentTime=str2double(get(hObject,'String'));

        if (not(isnan(inputCurrentTime)))
            inputCurrentTime=round(inputCurrentTime*handles.Fs)/handles.Fs;
            if inputCurrentTime<0
                inputCurrentTime=0;
            elseif inputCurrentTime>handles.maxStartTime
                inputCurrentTime=handles.maxStartTime;
            end

            %Update EpochTime
            handles.timeL=inputCurrentTime;
            handles.timeH=inputCurrentTime+handles.EpochSize;

            set(handles.RIPScore_training_edit_SegmSt,'string','');
            set(handles.RIPScore_training_edit_SegmEn,'string','');
            handles.SCORING.currentTime=handles.timeL;
            set(handles.RIPScore_training_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));

            plot_data(handles,'yes');
        else
            errordlg('Please enter a correct value for Epoch Start Time','Input Error','modal');
        end

        handles.flag=0;
        guidata(hObject,handles);
    end
end

%Plots the signals and the state bars
function plot_data(handles,msg)
%     if(~isempty(msg))
%         display(['Plot message:' msg])
%     end
    %The x-axis, and its corresponding sample indices
    x=handles.timeL+0.02:0.02:handles.timeH;
    x_samples=round(x*handles.Fs);

    eventInDisplay=or(and(ge(x_samples(1),handles.SCORING.Events(:,1)),lt(x_samples(1),handles.SCORING.Events(:,2))),or(and(gt(x_samples(end),handles.SCORING.Events(:,1)),le(x_samples(end),handles.SCORING.Events(:,2))),and(lt(x_samples(1),handles.SCORING.Events(:,1)),gt(x_samples(end),handles.SCORING.Events(:,2)))));
    eventIndex=find(eventInDisplay);

    %Plotting the signals
    plot(handles.RIPScore_training_axes_RCG,x,handles.RCG(x_samples));set(handles.RIPScore_training_axes_RCG,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH]);
    ylim(handles.RIPScore_training_axes_RCG,[min(handles.RCG(x_samples))-sqrt(handles.RCG(x_samples)'*handles.RCG(x_samples))*0.005 max(handles.RCG(x_samples))+sqrt(handles.RCG(x_samples)'*handles.RCG(x_samples))*0.005]);
    plot(handles.RIPScore_training_axes_ABD,x,handles.ABD(x_samples));set(handles.RIPScore_training_axes_ABD,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH]);
    ylim(handles.RIPScore_training_axes_ABD,[min(handles.ABD(x_samples))-sqrt(handles.ABD(x_samples)'*handles.ABD(x_samples))*0.005 max(handles.ABD(x_samples))+sqrt(handles.ABD(x_samples)'*handles.ABD(x_samples))*0.005]);
    plot(handles.RIPScore_training_axes_PPG,x,handles.PPG(x_samples));set(handles.RIPScore_training_axes_PPG,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH]);
    plot(handles.RIPScore_training_axes_SAT,x,handles.SAT(x_samples));set(handles.RIPScore_training_axes_SAT,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XLim',[handles.timeL handles.timeH]);xlabel(handles.RIPScore_training_axes_SAT,'Time(s)');
    cla(handles.RIPScore_training_axes_ABDvsRCG);
    set(handles.RIPScore_training_axes_ABDvsRCG,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    
    %Plotting the color-coded SCORED segments
    cla(handles.RIPScore_training_axes_AssignedState);
    for index=1:length(eventIndex)
        switch handles.SCORING.Events(eventIndex(index),3)
            case 1
                colorCode=handles.PAUcolor;
            case 2
                colorCode=handles.ASBcolor;
            case 3
                colorCode=handles.MVTcolor;
            case 4
                colorCode=handles.SYBcolor;
            case 5
                colorCode=handles.SIHcolor;
            case 99
                colorCode=handles.UNKcolor;
            otherwise
                colorCode=handles.NILcolor;
        end
        set(patch([handles.SCORING.Events(eventIndex(index),1) handles.SCORING.Events(eventIndex(index),2) handles.SCORING.Events(eventIndex(index),2) handles.SCORING.Events(eventIndex(index),1)]./handles.Fs,[0 0 1 1],colorCode),'Parent',handles.RIPScore_training_axes_AssignedState);
    end
    
    %Plotting the color-coded TRUE segments
    cla(handles.RIPScore_training_axes_ActualState);
    last2show=min([getNextRemainingSample(handles.SCORING.Events,handles.signalLength)-1, find(handles.IsTestSegment==0,1,'last')]);   %The minimum value between the last scored sample and the last sample in the train stage
    
    if handles.SCORING.Completed==1     %If the test stage is completed, show all of the scores for review mode
        last2show=length(handles.RCG);
    end
    
    if last2show>0
        TrueEvents=signal2events(handles.State(1:last2show));
        for index=1:size(TrueEvents,1)
            switch TrueEvents(index,3)
                case 1
                    colorCode=handles.PAUcolor;
                case 2
                    colorCode=handles.ASBcolor;
                case 3
                    colorCode=handles.MVTcolor;
                case 4
                    colorCode=handles.SYBcolor;
                case 5
                    colorCode=handles.SIHcolor;
                case 99
                    colorCode=handles.UNKcolor;
                otherwise
                    colorCode=handles.NILcolor;
            end
            set(patch([TrueEvents(index,1) TrueEvents(index,2) TrueEvents(index,2) TrueEvents(index,1)]./handles.Fs,[0 0 1 1],colorCode),'Parent',handles.RIPScore_training_axes_ActualState);
        end
    end
    
    set(handles.RIPScore_training_axes_AssignedState,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH],'YLim',[0 1],'YTick',[0 1],'YTickLabel',[]);
    set(handles.RIPScore_training_axes_ActualState,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH],'YLim',[0 1],'YTick',[0 1],'YTickLabel',[]);
    set(handles.RIPScore_training_axes_RCG,'ButtonDownFcn',@RIPScore_training_axes_RCG_ButtonDownFcn);
    set(handles.RIPScore_training_axes_ABD,'ButtonDownFcn',@RIPScore_training_axes_ABD_ButtonDownFcn);
    set(allchild(handles.RIPScore_training_axes_RCG),'HitTest','off');
    set(allchild(handles.RIPScore_training_axes_ABD),'HitTest','off');
    set(allchild(handles.RIPScore_training_axes_AssignedState),'HitTest','off');
    set(allchild(handles.RIPScore_training_axes_ActualState),'HitTest','off');
    
    %Adding the Scorer Comments
    if(length(handles.SCORING.Comments.start)>0)
        idxScorerComments=find(not(or(lt(handles.SCORING.Comments.end,handles.timeL.*handles.Fs),gt(handles.SCORING.Comments.start,handles.timeH.*handles.Fs))));
        scorerString={};
        for indexComments=1:length(idxScorerComments)
            scorerString{indexComments}=['(' num2str(handles.SCORING.Comments.start(idxScorerComments(indexComments))./handles.Fs,'%10.2f') ' to ' num2str(handles.SCORING.Comments.end(idxScorerComments(indexComments))./handles.Fs,'%10.2f') ') ' handles.SCORING.Comments.comment{idxScorerComments(indexComments)}];
        end
        set(handles.RIPScore_training_listbox_ScorerComments,'String',scorerString);
    else
        set(handles.RIPScore_training_listbox_ScorerComments,'String',{});
    end
	%There are no Acquisition Notes
    set(handles.RIPScore_training_listbox_AcquisitionNotes,'String',{});
end

%Plots the selected signals' segment in RED
function [] = ShowCursorData(handles)
    %The x-axis
    timeXPlot=[handles.START:1/handles.Fs:handles.END]';
    %Plot cardiorespiratory signals
    axes(handles.RIPScore_training_axes_RCG);hold on;
    plot(handles.RIPScore_training_axes_RCG,timeXPlot,handles.RCG(round(timeXPlot.*handles.Fs)),'r');hold off;
    axes(handles.RIPScore_training_axes_ABD);hold on;
    plot(handles.RIPScore_training_axes_ABD,timeXPlot,handles.ABD(round(timeXPlot.*handles.Fs)),'r');hold off;
    axes(handles.RIPScore_training_axes_PPG);hold on;
    plot(handles.RIPScore_training_axes_PPG,timeXPlot,handles.PPG(round(timeXPlot.*handles.Fs)),'r');hold off;
    axes(handles.RIPScore_training_axes_SAT);hold on;
    plot(handles.RIPScore_training_axes_SAT,timeXPlot,handles.SAT(round(timeXPlot.*handles.Fs)),'r');hold off;
	set(handles.RIPScore_training_axes_RCG,'ButtonDownFcn',@RIPScore_training_axes_RCG_ButtonDownFcn);
    set(handles.RIPScore_training_axes_ABD,'ButtonDownFcn',@RIPScore_training_axes_ABD_ButtonDownFcn);
    set(allchild(handles.RIPScore_training_axes_RCG),'HitTest','off');
    set(allchild(handles.RIPScore_training_axes_ABD),'HitTest','off');
    set(allchild(handles.RIPScore_training_axes_AssignedState),'HitTest','off');
    %Plot RIPScore_training_axes_ABDvsRCG
	plot(handles.RIPScore_training_axes_ABDvsRCG,handles.ABD(round(timeXPlot.*handles.Fs)),handles.RCG(round(timeXPlot.*handles.Fs)));
    set(handles.RIPScore_training_axes_ABDvsRCG,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    ylim(handles.RIPScore_training_axes_ABDvsRCG,[min(handles.RCG(round(timeXPlot.*handles.Fs))) max(handles.RCG(round(timeXPlot.*handles.Fs)))]);
    xlim(handles.RIPScore_training_axes_ABDvsRCG,[min(handles.ABD(round(timeXPlot.*handles.Fs))) max(handles.ABD(round(timeXPlot.*handles.Fs)))]);
end

%Timer Callback
function TmrFcn(src,event,handles)
    handles=guidata(handles);
    handles.SCORING.ElapsedTime=handles.SCORING.ElapsedTime+toc(handles.ticID);
    stateHandles=getStateHandles(handles);
    save(handles.TRAINEE.WorkingSession.fileBackup,'stateHandles');
    TRAINEE=handles.TRAINEE;
    save([handles.TRAINEE.savepath handles.TRAINEE.savename],'TRAINEE');
    handles.ticID=tic;
    guidata(handles.RIPScore_training_figure,handles);
    verbose('Backup Saved',handles.ShowMsgs);
end

% --- Executes on button press in RIPScore_training_button_SaveContinue.
function RIPScore_training_button_SaveContinue_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_SaveContinue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag==0)
        handles.flag=1;
        guidata(hObject,handles);
        button=questdlg('Are you sure you want to save and continue?','Save');
        if(isequal(button,'Yes'))
            handles.SCORING.ElapsedTime=handles.SCORING.ElapsedTime+toc(handles.ticID);
            stateHandles=getStateHandles(handles);
            save(handles.TRAINEE.WorkingSession.fileSaved,'stateHandles');
            TRAINEE=handles.TRAINEE;
            save([handles.TRAINEE.savepath handles.TRAINEE.savename],'TRAINEE');
            verbose('Scored Data Saved',handles.ShowMsgs);
            
            %Check if there is a backup of this scoring file
            backup=dir(handles.TRAINEE.WorkingSession.fileBackup);
            if(length(backup)>0)
                %If there is a backup, delete it
                delete(handles.TRAINEE.WorkingSession.fileBackup);
            end
        handles.ticID=tic;
        end
        handles.flag=0;
        guidata(hObject,handles);
    end
end

%Sets all the variables that we need to save in a structure for saving
function stateHandles = getStateHandles(handles)
    for index=1:length(handles.stateFields)
        stateHandles.(handles.stateFields{index})=handles.(handles.stateFields{index});
    end
end
    
function Conclude_Session(hObject,handles)
    msg=[''];
    msg=[msg 'You have finished this training session!!' char(10) char(10) 'You will exit Scoring Mode after clicking OK.' char(10) char(10) 'Once you click OK, please wait for your results to be displayed.' char(10)];
    uiwait(warndlg([msg ''],'Finished session','modal'))
    
%Stops the backup timer to avoid backups after saving
    stop(handles.mytimer);
    guidata(hObject, handles);

%Disable Scoring Controls
    set(handles.RIPScore_training_button_Comment,'Enable','off');
    set(handles.RIPScore_training_button_Delete,'Enable','off');
    set(handles.RIPScore_training_button_StartScoring,'Enable','off');
    set(handles.RIPScore_training_button_SaveContinue,'Enable','off');
    
%Performance Evaluation
    %Accuracy
    scorsig=events2signal(handles.SCORING.Events);
    ixEval=and(handles.IsTestSegment==1,handles.State>0);   %We evaluate the agreement in all samples in the test stage with valid states (i.e., State>0)
    gold=handles.State(ixEval);
    scor=scorsig(ixEval);
    for index=1:length(handles.states)
        gold(gold==handles.states(index))=index;
        scor(scor==handles.states(index))=index;
    end
    [handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.k(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kj(handles.TRAINEE.iteration(handles.TRAINEE.level),:),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kstd(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kjstd(handles.TRAINEE.iteration(handles.TRAINEE.level),:),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kcil(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kcih(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kjcil(handles.TRAINEE.iteration(handles.TRAINEE.level),:),handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kjcih(handles.TRAINEE.iteration(handles.TRAINEE.level),:),~] = scorerAgreement(gold,scor,1,handles.B,handles.ALPHA,0,inf,0,0,[1:length(handles.states)]',true);

    %Confusion matrix
    handles.TRAINEE.ConfusionMatrix{handles.TRAINEE.level,handles.TRAINEE.iteration(handles.TRAINEE.level)}=zeros(length(handles.states));
    for index=1:length(handles.states)
        for jndex=1:length(handles.states)
            handles.TRAINEE.ConfusionMatrix{handles.TRAINEE.level,handles.TRAINEE.iteration(handles.TRAINEE.level)}(index,jndex)=mean(scor(gold==jndex)==index);
        end
    end
    
    %Consistency
    scorsig=events2signal(handles.SCORING.Events);
    truEvts=signal2events(handles.EventID(1:end-(2*handles.wL+1))); %Discard the last 2*wL+1 samples to match last segment to its first appearence
    truEvts=sortrows(truEvts(truEvts(:,3)>0,:),3);
    scor1=[];
    scor2=[];
    for index=1:2:size(truEvts,1)
        scor1=[scor1;scorsig(truEvts(index,1):truEvts(index,2))];
        scor2=[scor2;scorsig(truEvts(index+1,1):truEvts(index+1,2))];
    end
    for index=1:length(handles.states)
        scor1(scor1==handles.states(index))=index;
        scor2(scor2==handles.states(index))=index;
    end
    [handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.k(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kj(handles.TRAINEE.iteration(handles.TRAINEE.level),:),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kstd(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kjstd(handles.TRAINEE.iteration(handles.TRAINEE.level),:),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kcil(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kcih(handles.TRAINEE.iteration(handles.TRAINEE.level)),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kjcil(handles.TRAINEE.iteration(handles.TRAINEE.level),:),handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kjcih(handles.TRAINEE.iteration(handles.TRAINEE.level),:),~] = scorerAgreement(scor1,scor2,1,handles.B,handles.ALPHA,0,inf,0,0,[1:length(handles.states)]',true);

%Update TRAINEE
    handles.TRAINEE.ScoredSamples{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level))=length(handles.RCG);     %The amount of data scored (in samples) each session in level 1. Each row is a session.
    handles.TRAINEE.IterationTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level))=handles.SCORING.ElapsedTime+toc(handles.ticID);     %The time (in seconds) required to complete each session in level 1. Each row is a session.

%Determine Effective Training Time
    iterationTime=handles.TRAINEE.IterationTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level));
    practiceTime=handles.TRAINEE.PracticeTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level));

    indexTestingEvents=handles.SCORING.Events(:,1)>=find(handles.IsTestSegment==1,1);
    timeBetweenEvents=diff(sort(handles.SCORING.Events(indexTestingEvents,4)))*24*60*60;   %The elapsed time between scored segments in seconds
    myThreshold=median(timeBetweenEvents)*50;
    if(myThreshold<handles.thresholdTimePerEvent)
        myThreshold=handles.thresholdTimePerEvent;
    end
    verbose(['Estimated myThreshold for Idle Testing Time: ' num2str(myThreshold,'%1.2f')],handles.ShowMsgs);
    indexNotIdle=timeBetweenEvents<=myThreshold;
    estimatedNotIdleTestingTime=sum(timeBetweenEvents(indexNotIdle));
    
    handles.TRAINEE.EffectiveTrainingTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level))=estimatedNotIdleTestingTime;
    
% Show message with performance results
    msg=[''];
    msg=[msg 'These are your results on the test stage:' char(10) char(10)];
    k=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.k(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kj=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kj(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    kstd=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kstd(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kjstd=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kjstd(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    kcil=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kcil(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kcih=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kcih(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kjcil=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kjcil(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    kjcih=handles.TRAINEE.InterAgreement{handles.TRAINEE.level}.kjcih(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    min_kappa=min(min(kjcil),kcil);
    msg=[msg 'Accuracy (Fleiss'' kappa: mean [C.I. alpha=' num2str(handles.ALPHA) ']):' char(10)];
    msg=[msg '   ALL:   ' num2str(k,'%1.2f') '   [' num2str(kcil,'%1.2f') ', ' num2str(kcih,'%1.2f') ']' char(10)];
    for index=1:length(handles.states)
        msg=[msg '   ' handles.statesStr{index} ':   ' num2str(kj(index),'%1.2f') '   [' num2str(kjcil(index),'%1.2f') ', ' num2str(kjcih(index),'%1.2f') ']' char(10)];
    end
    
    k=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.k(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kj=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kj(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    kstd=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kstd(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kjstd=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kjstd(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    kcil=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kcil(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kcih=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kcih(handles.TRAINEE.iteration(handles.TRAINEE.level));
    kjcil=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kjcil(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    kjcih=handles.TRAINEE.IntraAgreement{handles.TRAINEE.level}.kjcih(handles.TRAINEE.iteration(handles.TRAINEE.level),:);
    min_kappa=min(min_kappa,min(min(kjcil),kcil));
    msg=[msg char(10) 'Consistency (Fleiss'' kappa: mean [C.I. alpha=' num2str(handles.ALPHA) ']):' char(10)];
    msg=[msg '   ALL:   ' num2str(k,'%1.2f') '   [' num2str(kcil,'%1.2f') ', ' num2str(kcih,'%1.2f') ']' char(10)];
    for index=1:length(handles.states)
        msg=[msg '   ' handles.statesStr{index} ':   ' num2str(kj(index),'%1.2f') '   [' num2str(kjcil(index),'%1.2f') ', ' num2str(kjcih(index),'%1.2f') ']' char(10)];
    end
    msg=[msg char(10)];

    msg=[msg 'Session Time:   ' num2str(handles.TRAINEE.IterationTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level)),'%1.2f') ' s' char(10)];
    msg=[msg 'Total Recording Length:   ' num2str(handles.TRAINEE.ScoredSamples{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level))./handles.Fs,'%1.2f') ' s' char(10)];
    msg=[msg 'Effective Training Time:   ' num2str(handles.TRAINEE.EffectiveTrainingTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level)),'%1.2f') ' s' char(10)];
    
    uiwait(warndlg([msg ''],'Results','modal'))
    
%Determine if trainee has passed the level, and update profile accordingly
    if(handles.TRAINEE.level==1)
        %If the current level of TRAINEE is 1
        effectiveTrainingTime=handles.TRAINEE.EffectiveTrainingTime{handles.TRAINEE.level}(handles.TRAINEE.iteration(handles.TRAINEE.level));
        verbose(['Evaluating change to Level 2 ...'],handles.ShowMsgs);
        verbose(['   min_kappa = ' num2str(min_kappa,'%1.2f')],handles.ShowMsgs);
        verbose(['   effectiveTrainingTime = ' num2str(effectiveTrainingTime,'%1.2f') ' s'],handles.ShowMsgs);
        if(min_kappa>=handles.ThresholdLowestKappa)                         %If the lowest kappa lower limit is >= ThresholdLowestKappa
            if(effectiveTrainingTime<handles.ThresholdEffectiveTrainTime)   %If the effective training time was < ThresholdEffectiveTrainTime
                handles.TRAINEE.level=2;
                verbose(['Scorer advanced to Level 2.'],handles.ShowMsgs);
                uiwait(warndlg(['Congratulations, you have advanced to Training Level 2!!!'],'Advance Level','modal'))
            end
        end
    end

%Save Signals and SCORING
    handles.SCORING.ElapsedTime=iterationTime;
    SCORING=handles.SCORING;
    DATA.RC=handles.RCG;
    DATA.AB=handles.ABD;
    DATA.PP=handles.PPG;
    DATA.SA=handles.SAT;
    DATA.State=handles.State;
    DATA.EventID=handles.EventID;
    DATA.IsTestSegment=handles.IsTestSegment;
    DATA.RIPScoreVersion=handles.TRAINEE.RIPScoreVersion;
    save(handles.savename,'SCORING','DATA');
    
%Delete any backups or user saved versions
    auxBackup=dir(handles.TRAINEE.WorkingSession.fileBackup);
    if(length(auxBackup)>0)
        delete(handles.TRAINEE.WorkingSession.fileBackup);
    end
    auxSaved=dir(handles.TRAINEE.WorkingSession.fileSaved);
    if(length(auxSaved)>0)
        delete(handles.TRAINEE.WorkingSession.fileSaved);
    end

%Final update and save TRAINEE
    handles.TRAINEE.WorkingSession.isActive=0;
    handles.TRAINEE.WorkingSession.fileSaved='';
    handles.TRAINEE.WorkingSession.fileBackup='';
    handles.TRAINEE.WorkingSession.fileSelected='';
    TRAINEE=handles.TRAINEE;
    save([handles.TRAINEE.savepath handles.TRAINEE.savename],'TRAINEE');
    
%Review mode. Indicate that Actual States will be shown for comparison
%When finished reviewing the scores, click RIPScore_training_button_SaveDone to terminate the session.
    msg=['Actual States will be shown for you to review.' char(10) 'Click "Done" to terminate the session.'];
    uiwait(warndlg([msg ''],'Review','modal'))
    
    %Enable the "RIPScore_training_button_SaveDone" button
    set(handles.RIPScore_training_button_SaveDone,'Enable','on');
end
    
% --- Executes on button press in RIPScore_training_button_SaveDone.
function RIPScore_training_button_SaveDone_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_button_SaveDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    button=questdlg(['Are you done reviewing your scores?' char(10) 'After clicking "Yes" the session will be terminated'],'Finish Session');
    if(isequal(button,'Yes'))
        uiresume(handles.RIPScore_training_figure);
    end
end

% --- Executes when user attempts to close RIPScore_training_figure.
function RIPScore_training_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag==0)
        button=questdlg(['Are you sure you want to exit before the end of the session?' char(10) 'If you exit nothing will be saved'],'Exit');
        if(isequal(button,'Yes'))
            handles.output=[];
            guidata(hObject,handles);
            uiresume(handles.RIPScore_training_figure);
        end
    end
end 

% --- Executes during object creation, after setting all properties.
function RIPScore_training_edit_EpochTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_edit_EpochTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes during object creation, after setting all properties.
function RIPScore_training_edit_SegmSt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_edit_SegmSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes during object creation, after setting all properties.
function RIPScore_training_edit_SegmEn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_edit_SegmSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in RIPScore_training_listbox_ScorerComments.
function RIPScore_training_listbox_ScorerComments_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_listbox_ScorerComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RIPScore_training_listbox_ScorerComments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RIPScore_training_listbox_ScorerComments
end

% --- Executes during object creation, after setting all properties.
function RIPScore_training_listbox_ScorerComments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_listbox_ScorerComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in RIPScore_training_listbox_AcquisitionNotes.
function RIPScore_training_listbox_AcquisitionNotes_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_listbox_AcquisitionNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RIPScore_training_listbox_AcquisitionNotes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RIPScore_training_listbox_AcquisitionNotes
end

% --- Executes during object creation, after setting all properties.
function RIPScore_training_listbox_AcquisitionNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_training_listbox_AcquisitionNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
