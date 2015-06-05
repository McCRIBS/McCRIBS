function varargout = RIPScore_main(varargin)
%RIPScore main screen.
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
                   'gui_OpeningFcn', @RIPScore_main_OpeningFcn, ...
                   'gui_OutputFcn',  @RIPScore_main_OutputFcn, ...
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


% --- Executes just before RIPScore_main is made visible.
function RIPScore_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RIPScore_main (see VARARGIN)

% Choose default command line output for OpenFile
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%Determine if continuing from previous save
if(isstruct(varargin{5}))
    handles.SCORING = varargin{5};
else
    %If this is the first time to perform scoring
    handles.SCORING={};
    handles.SCORING.NextScore = 1;
    handles.SCORING.Events = zeros(0,4);
    handles.SCORING.Scorer = varargin{6};
    handles.SCORING.Comments.start=[];
    handles.SCORING.Comments.end=[];
    handles.SCORING.Comments.eventID=[];
    handles.SCORING.Comments.comment={};
    handles.SCORING.ElapsedTime=0;
    handles.SCORING.Completed=0;
    handles.SCORING.FileName=varargin{8};
    handles.SCORING.RIPScoreVersion=varargin{9};
end
guidata(hObject,handles);

handles.datadir=varargin{7};
handles.ShowMsgs=varargin{10};

%Get signals for plots
Signals=varargin{1};
handles.RCG=Signals(:,1);
handles.ABD=Signals(:,2);
handles.PPG=Signals(:,3);
handles.SAT=Signals(:,4);

%Get Epoch Size selected and set Sampling Frequency
handles.EpochSize=varargin{3};
handles.Fs=varargin{11}; %Hertz
handles.TimeShiftConstant=round(handles.EpochSize*2/3); %seconds

%Set constants for color coding of events
handles.PAUcolor=stateColor('PAU');
handles.ASBcolor=stateColor('ASB');
handles.MVTcolor=stateColor('MVT');
handles.SYBcolor=stateColor('SYB');
handles.SIHcolor=stateColor('SIH');
handles.UNKcolor=stateColor('UNK');
handles.NILcolor=stateColor('NIL');

handles.savename=varargin{4};
handles.START=[];
handles.END=[];
handles.clickSample=[];
handles.eventIndex=[];

handles.signalLength=length(handles.RCG);
handles.lastScoredSample=getNextRemainingSample(handles.SCORING.Events,handles.signalLength)-1;
handles.samplesForLimitsDisplay=1.26*handles.Fs;

%Obtain estimates of breath segmentation
Nba=101;
Nbn=1;
auxPeaksTroughs=breathSegmentation(handles.RCG,Nba,Nbn,handles.Fs,handles.ShowMsgs);
handles.BreathTroughsRCG=auxPeaksTroughs(auxPeaksTroughs(:,2)==0,:);
clear auxPeaksTroughs
auxPeaksTroughs=breathSegmentation(handles.ABD,Nba,Nbn,handles.Fs,handles.ShowMsgs);
handles.BreathTroughsABD=auxPeaksTroughs(auxPeaksTroughs(:,2)==0,:);
clear auxPeaksTroughs

%Calculate the maximum start time
handles.maxStartTime=length(handles.RCG)./handles.Fs-handles.EpochSize;
handles.lastEventPreview=7.5;   %Seconds to show from the last scored segment

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

%Control Flags
handles.flag = 0;
handles.isScoring = 0;

set(handles.RIPScore_main_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));

%Read Acquisition Notes
%7:scored_, 1:_
k=strfind(handles.savename,'scored_')+7+length(handles.SCORING.Scorer)+1;
caseid=handles.savename(k:end-4);
pathid=handles.datadir;
fid=fopen([pathid 'behavioral_state_' handles.SCORING.FileName(1:end-4) '.dat']);
if (fid>=3)
    genCom=textscan(fid,'%f %f %s','Delimiter','\t');
    handles.GenComments.start=genCom{1};
    handles.GenComments.end=genCom{2};
    handles.GenComments.comment=genCom{3};
else
	handles.GenComments.start=[];
    handles.GenComments.end=[];
    handles.GenComments.comment={};
end
fclose('all');

%Set timer interruption for backups
handles.TimerPeriod=5*60;	%Execute every 5 min
handles.mytimer=timer('TimerFcn',{@TmrFcn,hObject},'BusyMode','Queue','ExecutionMode','FixedRate','Period',handles.TimerPeriod,'StartDelay',handles.TimerPeriod);
guidata(hObject,handles);
start(handles.mytimer);

guidata(hObject, handles);

%Remove toolbar buttons that are not used
h=findall(handles.RIPScore_main_figure,'tooltip','Insert Legend');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Insert Colorbar');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','New Figure');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Print Figure');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Open File');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Save Figure');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Show Plot Tools');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Hide Plot Tools');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Rotate 3D');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Pan');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Edit Plot');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Zoom In');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Zoom Out');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Data Cursor');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Brush/Select Data');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Link Plot');
set(h,'Visible','off');
h=findall(handles.RIPScore_main_figure,'tooltip','Show Plot Tools and Dock Figure');
set(h,'Visible','off');

%Plot
plot_data(handles,'yes');

tic;

% UIWAIT makes RIPScore_main wait for user response (see UIRESUME)
uiwait(handles.RIPScore_main_figure);

% --- Outputs from this function are returned to the command line.
function varargout = RIPScore_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stop(handles.mytimer);
delete(handles.mytimer);
guidata(hObject, handles);

% Get default command line output from handles structure
varargout{1} = handles.output;

%Close figure
delete(handles.RIPScore_main_figure);

% --- Executes on button press in RIPScore_main_button_PAU.
function RIPScore_main_button_PAU_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_PAU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
storedata(handles.RIPScore_main_figure,handles,1);

% --- Executes on button press in RIPScore_main_button_ASB.
function RIPScore_main_button_ASB_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_ASB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
storedata(handles.RIPScore_main_figure,handles,2);

%--- Executes on button press in RIPScore_main_button_MVT.
function RIPScore_main_button_MVT_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_MVT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
storedata(handles.RIPScore_main_figure,handles,3);

% --- Executes on button press in RIPScore_main_button_SYB.
function RIPScore_main_button_SYB_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_SYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
storedata(handles.RIPScore_main_figure,handles,4);

% --- Executes on button press in RIPScore_main_button_SIH.
function RIPScore_main_button_SIH_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_SIH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
storedata(handles.RIPScore_main_figure,handles,5);

% --- Executes on button press in RIPScore_main_button_UNK.
function RIPScore_main_button_UNK_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_UNK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
storedata(handles.RIPScore_main_figure,handles,99);

% --- Executes on key press with focus on RIPScore_main_figure or any of its controls.
function RIPScore_main_figure_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_figure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    if(strcmp(lower(eventdata.Key),'p'))    %Get a screenshot
        verbose(['''p'' key pressed!'],handles.ShowMsgs);
        auxDate=datevec(now);
        print(hObject,['RIPScore_' handles.SCORING.Scorer ' ' handles.SCORING.FileName(1:end-4)],'-dmeta')
    end
    if(strcmp(lower(eventdata.Key),'s'))
        verbose(['''s'' key pressed!'],handles.ShowMsgs);
        RIPScore_main_button_StartScoring_Callback(handles.RIPScore_main_button_StartScoring,eventdata,handles);
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

% --- Executes on button press in RIPScore_main_button_StartScoring.
function RIPScore_main_button_StartScoring_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_StartScoring (see GCBO)
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

                guidata(handles.RIPScore_main_figure,handles);

                getNextEndTime(handles.RIPScore_main_figure);
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
        set(handles.RIPScore_main_edit_SegmSt,'string','');
        set(handles.RIPScore_main_edit_SegmEn,'string','');
        handles.flag = 0;
        guidata(handles.RIPScore_main_figure,handles);
        plot_data(handles,'Stop Scoring')
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

        guidata(handles.RIPScore_main_figure,handles)
        if isempty(handles.lastScoredSample)
            %If there are no more samples to score, Stop Scoring
            set(handles.RIPScore_main_button_StartScoring,'String','(S)tart Scoring');
            handles.isScoring=0;
            handles.START=[];
            handles.END=[];
            set(handles.RIPScore_main_edit_SegmSt,'string','');
            set(handles.RIPScore_main_edit_SegmEn,'string','');
            handles.flag=0;
            handles.SCORING.Completed=1;    %Mark the file as completed
            
            guidata(handles.RIPScore_main_figure,handles);
            plot_data(handles,'(S)top Scoring')
            uiwait(msgbox('You have finished scoring this recording. You will exit Scoring Mode after clicking OK','Finished Scoring','warn'));
        else
            getNextEndTime(handles.RIPScore_main_figure);
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
        set(handles.RIPScore_main_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));
        handles.timeL=handles.SCORING.currentTime;
        handles.timeH=handles.SCORING.currentTime+handles.EpochSize;
        guidata(handles.RIPScore_main_figure,handles);
        plot_data(handles,'goToNextEvent');
    end
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
    set(myhandles.RIPScore_main_edit_EpochTime,'string',num2str(myhandles.SCORING.currentTime));
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
    
    set(myhandles.RIPScore_main_edit_SegmSt,'string',num2str(myhandles.START,'%10.2f'));
    set(myhandles.RIPScore_main_edit_SegmEn,'string',num2str(myhandles.END,'%10.2f'));
    guidata(hObject,myhandles);
    ShowCursorData(myhandles);
    
function [nextSample] = getNextRemainingSample(Events,signalLength)
    remainingSegments=getRemainingSegments(Events,signalLength);
    if (isempty(remainingSegments))
        nextSample=[];
    else
        nextSample=remainingSegments(1,1);
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

% --- Executes on mouse press over axes background.
function RIPScore_main_axes_AssignedState_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_axes_AssignedState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    clickCoords=get(hObject,'CurrentPoint');    %The coordinates of the click over the RIP pattern bar
    clickSample=round(clickCoords(1,1).*handles.Fs);

    verbose(['Click on RIPScore_main_axes_AssignedState!'],handles.ShowMsgs);
    
    %Find the segment that corresponds to the selected coordinates
    eventIndex=find(and(handles.SCORING.Events(:,1)<=clickSample,handles.SCORING.Events(:,2)>=clickSample));   %This index will be unique and corresponds to the segment that was selected.
    if(not(isempty(eventIndex)))
        %If segment exists, update Segment Start and End time boxes
        set(handles.RIPScore_main_edit_SegmSt,'string',num2str(handles.SCORING.Events(eventIndex,1)./handles.Fs,'%10.2f'));
        set(handles.RIPScore_main_edit_SegmEn,'string',num2str(handles.SCORING.Events(eventIndex,2)./handles.Fs,'%10.2f'));
        handles.clickSample=clickSample;
        handles.eventIndex=eventIndex;
        %Plot selected segment in RIPScore_main_axes_ABDvsRCG
        timeXPlot=[handles.SCORING.Events(eventIndex,1):handles.SCORING.Events(eventIndex,2)]'./handles.Fs;
        plot(handles.RIPScore_main_axes_ABDvsRCG,handles.ABD(round(timeXPlot.*handles.Fs)),handles.RCG(round(timeXPlot.*handles.Fs)));
        set(handles.RIPScore_main_axes_ABDvsRCG,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
        ylim(handles.RIPScore_main_axes_ABDvsRCG,[min(handles.RCG(round(timeXPlot.*handles.Fs))) max(handles.RCG(round(timeXPlot.*handles.Fs)))]);
        xlim(handles.RIPScore_main_axes_ABDvsRCG,[min(handles.ABD(round(timeXPlot.*handles.Fs))) max(handles.ABD(round(timeXPlot.*handles.Fs)))]);
    else
        %If segment doesn't exist, clear Segment Start and End time boxes
        set(handles.RIPScore_main_edit_SegmSt,'string','');
        set(handles.RIPScore_main_edit_SegmEn,'string','');
        handles.clickSample=[];
        handles.eventIndex=[];
    end
    guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function RIPScore_main_axes_RCG_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_axes_RCG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles=guidata(hObject);
    if(handles.flag==0)
        %If not scoring, show horizontal cursors
        currentPoint=get(hObject,'CurrentPoint');
        auxBaseline=handles.RCG(handles.BreathTroughsRCG(handles.BreathTroughsRCG(:,1)<currentPoint(1).*handles.Fs,1));
        showLimits(hObject,get(hObject,'CurrentPoint'),0.9,handles.RCG,auxBaseline(end));
        set(hObject,'ButtonDownFcn', @RIPScore_main_axes_RCG_ButtonDownFcn);
        set(allchild(hObject),'HitTest','off');
        guidata(hObject,handles);
    end

% --- Executes on mouse press over axes background.
function RIPScore_main_axes_ABD_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_axes_ABD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles=guidata(hObject);
    if(handles.flag==0)
        %If not scoring, show horizontal cursors
        currentPoint=get(hObject,'CurrentPoint');
        auxBaseline=handles.ABD(handles.BreathTroughsABD(handles.BreathTroughsABD(:,1)<currentPoint(1).*handles.Fs,1));
        showLimits(hObject,currentPoint(),0.9,handles.ABD,auxBaseline(end));
        set(hObject,'ButtonDownFcn', @RIPScore_main_axes_ABD_ButtonDownFcn);
        set(allchild(hObject),'HitTest','off');
        guidata(hObject,handles);
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

% --- Executes on button press in RIPScore_main_button_Delete.
function RIPScore_main_button_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.flag == 0)
    handles.flag = 1;
    guidata(hObject,handles);
    if(and( not(isempty(handles.eventIndex)) , not(isempty(handles.clickSample)) ))
        button=questdlg('Are you sure you want to delete the selected segment?','Delete');
        if(isequal(button,'Yes'))
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
            set(handles.RIPScore_main_edit_SegmSt,'string','');
            set(handles.RIPScore_main_edit_SegmEn,'string','');
            handles.clickSample=[];
            handles.eventIndex=[];
            
            handles.SCORING.Completed=0;
            guidata(hObject, handles);
            plot_data(handles,'yes');
        end
    else
        errordlg('Error: No segment selected','Error','modal');
    end
    handles.flag = 0;
    guidata(hObject,handles);
end
    
% --- Executes on button press in RIPScore_main_button_Comment.
function RIPScore_main_button_Comment_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_Comment (see GCBO)
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

% --- Executes on button press in RIPScore_main_button_BadPPG.
function RIPScore_main_button_BadPPG_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_BadPPG (see GCBO)
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
    
% --- Executes on button press in RIPScore_main_button_Next.
function RIPScore_main_button_Next_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.flag==0)
    handles.flag=1;
    guidata(hObject, handles);
    
    if(handles.timeH+handles.TimeShiftConstant > (length(handles.RCG))/handles.Fs)
        %If it goes beyond the number of samples
        handles.timeH=double((length(handles.RCG))/handles.Fs);
        handles.timeL=double(handles.timeH-handles.EpochSize);
    else
        %Shift EpochTime by TimeShiftConstant
        handles.timeL=handles.timeL+handles.TimeShiftConstant;
        handles.timeH=handles.timeH+handles.TimeShiftConstant;
    end
    set(handles.RIPScore_main_edit_SegmSt,'string','');
    set(handles.RIPScore_main_edit_SegmEn,'string','');
    handles.SCORING.currentTime=handles.timeL;
    set(handles.RIPScore_main_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));
    
    plot_data(handles,'yes');
    
    handles.clickSample=[];
    handles.eventIndex=[];
    
    handles.flag = 0;
    guidata(hObject,handles);
end

% --- Executes on button press in RIPScore_main_button_Previous.
function RIPScore_main_button_Previous_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_Previous (see GCBO)
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
    set(handles.RIPScore_main_edit_SegmSt,'string','');
    set(handles.RIPScore_main_edit_SegmEn,'string','');
    handles.SCORING.currentTime=handles.timeL;
    set(handles.RIPScore_main_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));
    
    plot_data(handles,'yes');
    
    handles.clickSample=[];
    handles.eventIndex=[];
    
    handles.flag=0;
    guidata(hObject,handles);
end
    
function RIPScore_main_edit_EpochTime_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_edit_EpochTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RIPScore_main_edit_EpochTime as text
%        str2double(get(hObject,'String')) returns contents of RIPScore_main_edit_EpochTime as a double
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

        set(handles.RIPScore_main_edit_SegmSt,'string','');
        set(handles.RIPScore_main_edit_SegmEn,'string','');
        handles.SCORING.currentTime=handles.timeL;
        set(handles.RIPScore_main_edit_EpochTime,'string',num2str(handles.SCORING.currentTime));

        plot_data(handles,'yes');
    else
        errordlg('Please enter a correct value for Epoch Start Time','Input Error','modal');
    end
    
    handles.flag=0;
    guidata(hObject,handles);
end

%Plots the signals and the RIP pattern bar
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
    plot(handles.RIPScore_main_axes_RCG,x,handles.RCG(x_samples));set(handles.RIPScore_main_axes_RCG,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH]);
    plot(handles.RIPScore_main_axes_ABD,x,handles.ABD(x_samples));set(handles.RIPScore_main_axes_ABD,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH]);
    plot(handles.RIPScore_main_axes_PPG,x,handles.PPG(x_samples));set(handles.RIPScore_main_axes_PPG,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH]);
    plot(handles.RIPScore_main_axes_SAT,x,handles.SAT(x_samples));set(handles.RIPScore_main_axes_SAT,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XLim',[handles.timeL handles.timeH]);xlabel(handles.RIPScore_main_axes_SAT,'Time(s)');
    cla(handles.RIPScore_main_axes_ABDvsRCG);
    set(handles.RIPScore_main_axes_ABDvsRCG,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    
    %Plotting the color-coded segments
    cla(handles.RIPScore_main_axes_AssignedState);
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
        set(patch([handles.SCORING.Events(eventIndex(index),1) handles.SCORING.Events(eventIndex(index),2) handles.SCORING.Events(eventIndex(index),2) handles.SCORING.Events(eventIndex(index),1)]./handles.Fs,[0 0 1 1],colorCode),'Parent',handles.RIPScore_main_axes_AssignedState);
    end
    set(handles.RIPScore_main_axes_AssignedState,'XTick',[handles.timeL handles.timeL+(handles.timeH-handles.timeL)/6 handles.timeL+(handles.timeH-handles.timeL)*2/6 handles.timeL+(handles.timeH-handles.timeL)*3/6 handles.timeL+(handles.timeH-handles.timeL)*4/6 handles.timeL+(handles.timeH-handles.timeL)*5/6 handles.timeH],'XTickLabel',[],'XLim',[handles.timeL handles.timeH],'YLim',[0 1],'YTick',[0 1],'YTickLabel',[]);
    set(handles.RIPScore_main_axes_RCG,'ButtonDownFcn',@RIPScore_main_axes_RCG_ButtonDownFcn);
    set(handles.RIPScore_main_axes_ABD,'ButtonDownFcn',@RIPScore_main_axes_ABD_ButtonDownFcn);
    set(allchild(handles.RIPScore_main_axes_RCG),'HitTest','off');
    set(allchild(handles.RIPScore_main_axes_ABD),'HitTest','off');
    set(allchild(handles.RIPScore_main_axes_AssignedState),'HitTest','off');
    
    %Adding the Scorer Comments
    if(length(handles.SCORING.Comments.start)>0)
        idxScorerComments=find(not(or(lt(handles.SCORING.Comments.end,handles.timeL.*handles.Fs),gt(handles.SCORING.Comments.start,handles.timeH.*handles.Fs))));
        scorerString={};
        for indexComments=1:length(idxScorerComments)
            scorerString{indexComments}=['(' num2str(handles.SCORING.Comments.start(idxScorerComments(indexComments))./handles.Fs,'%10.2f') ' to ' num2str(handles.SCORING.Comments.end(idxScorerComments(indexComments))./handles.Fs,'%10.2f') ') ' handles.SCORING.Comments.comment{idxScorerComments(indexComments)}];
        end
        set(handles.RIPScore_main_listbox_ScorerComments,'String',scorerString);
    else
        set(handles.RIPScore_main_listbox_ScorerComments,'String',{});
    end
    %Adding the Acquisition Notes
	if(length(handles.GenComments.start)>0)
        idxGeneralComments=find(not(or(lt(handles.GenComments.end,handles.timeL),gt(handles.GenComments.start,handles.timeH))));
        generalString={};
        for indexComments=1:length(idxGeneralComments)
            generalString{indexComments}=['(' num2str(handles.GenComments.start(idxGeneralComments(indexComments)),'%10.2f') ' to ' num2str(handles.GenComments.end(idxGeneralComments(indexComments)),'%10.2f') ') ' handles.GenComments.comment{idxGeneralComments(indexComments)}];
        end
        set(handles.RIPScore_main_listbox_AcquisitionNotes,'String',generalString);
    else
        set(handles.RIPScore_main_listbox_AcquisitionNotes,'String',{});
    end

%Plots the selected signals' segment in RED
function [] = ShowCursorData(handles)
    %The x-axis
    timeXPlot=[handles.START:1/handles.Fs:handles.END]';
    %Plot cardiorespiratory signals
    axes(handles.RIPScore_main_axes_RCG);hold on;
    plot(handles.RIPScore_main_axes_RCG,timeXPlot,handles.RCG(round(timeXPlot.*handles.Fs)),'r');hold off;
    axes(handles.RIPScore_main_axes_ABD);hold on;
    plot(handles.RIPScore_main_axes_ABD,timeXPlot,handles.ABD(round(timeXPlot.*handles.Fs)),'r');hold off;
    axes(handles.RIPScore_main_axes_PPG);hold on;
    plot(handles.RIPScore_main_axes_PPG,timeXPlot,handles.PPG(round(timeXPlot.*handles.Fs)),'r');hold off;
    axes(handles.RIPScore_main_axes_SAT);hold on;
    plot(handles.RIPScore_main_axes_SAT,timeXPlot,handles.SAT(round(timeXPlot.*handles.Fs)),'r');hold off;
	set(handles.RIPScore_main_axes_RCG,'ButtonDownFcn',@RIPScore_main_axes_RCG_ButtonDownFcn);
    set(handles.RIPScore_main_axes_ABD,'ButtonDownFcn',@RIPScore_main_axes_ABD_ButtonDownFcn);
    set(allchild(handles.RIPScore_main_axes_RCG),'HitTest','off');
    set(allchild(handles.RIPScore_main_axes_ABD),'HitTest','off');
    set(allchild(handles.RIPScore_main_axes_AssignedState),'HitTest','off');
    %Plot RIPScore_main_axes_ABDvsRCG
	plot(handles.RIPScore_main_axes_ABDvsRCG,handles.ABD(round(timeXPlot.*handles.Fs)),handles.RCG(round(timeXPlot.*handles.Fs)));
    set(handles.RIPScore_main_axes_ABDvsRCG,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
    ylim(handles.RIPScore_main_axes_ABDvsRCG,[min(handles.RCG(round(timeXPlot.*handles.Fs))) max(handles.RCG(round(timeXPlot.*handles.Fs)))]);
    xlim(handles.RIPScore_main_axes_ABDvsRCG,[min(handles.ABD(round(timeXPlot.*handles.Fs))) max(handles.ABD(round(timeXPlot.*handles.Fs)))]);

%Timer Callback
function TmrFcn(src,event,handles)
    handles=guidata(handles);
    handles.SCORING.ElapsedTime=handles.SCORING.ElapsedTime+toc;
    SCORING=handles.SCORING;
	save([handles.savename(1:end-4) '_BACKUP.mat'],'SCORING');
    guidata(handles.RIPScore_main_figure,handles);
    tic;
%     display('Backup Saved');

% --- Executes on button press in RIPScore_main_button_SaveContinue.
function RIPScore_main_button_SaveContinue_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_SaveContinue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag==0)
        handles.flag=1;
        guidata(hObject,handles);
        button=questdlg('Are you sure you want to save and continue?','Save');
        if(isequal(button,'Yes'))
            handles.SCORING.ElapsedTime=handles.SCORING.ElapsedTime+toc;
            SCORING=handles.SCORING;
            %Save the scoring
            save(handles.savename,'SCORING');
%             display('Scored Data Saved');

            %Check if there is a backup of this scoring file
            backup=dir([handles.savename(1:end-4) '_BACKUP.mat']);
            if(length(backup)>0)
                %If there is a backup, delete it
                delete([handles.savename(1:end-4) '_BACKUP.mat']);
            end
            tic;
        end
        handles.flag=0;
        guidata(hObject,handles);
    end

% --- Executes on button press in RIPScore_main_button_SaveDone.
function RIPScore_main_button_SaveDone_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_button_SaveDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    button=questdlg('Are you sure you want to save the current scoring and exit?','Save and Exit');
    if(isequal(button,'Yes'))
        handles.SCORING.ElapsedTime=handles.SCORING.ElapsedTime+toc;
        tic;
        SCORING=handles.SCORING;
        %Save the file
        save(handles.savename,'SCORING');
%         display('Scored Data Saved');

        %Check if there is a backup
        backup=dir([handles.savename(1:end-4) '_BACKUP.mat']);
        if(length(backup)>0)
            %Delete backup
            delete([handles.savename(1:end-4) '_BACKUP.mat']);
        end
        handles.output=handles;
        guidata(hObject,handles);
        uiresume(handles.RIPScore_main_figure);
    end

% --- Executes when user attempts to close RIPScore_main_figure.
function RIPScore_main_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.flag == 0)
        button=questdlg('Are you sure you want to exit without saving?','Exit');
        if(isequal(button,'Yes'))
            handles.output=[];
            guidata(hObject,handles);
            uiresume(handles.RIPScore_main_figure);
        end
    end
    

% --- Executes during object creation, after setting all properties.
function RIPScore_main_edit_EpochTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_edit_EpochTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function RIPScore_main_edit_SegmSt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_edit_SegmSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function RIPScore_main_edit_SegmEn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_edit_SegmSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RIPScore_main_listbox_ScorerComments.
function RIPScore_main_listbox_ScorerComments_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_listbox_ScorerComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RIPScore_main_listbox_ScorerComments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RIPScore_main_listbox_ScorerComments


% --- Executes during object creation, after setting all properties.
function RIPScore_main_listbox_ScorerComments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_listbox_ScorerComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RIPScore_main_listbox_AcquisitionNotes.
function RIPScore_main_listbox_AcquisitionNotes_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_listbox_AcquisitionNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RIPScore_main_listbox_AcquisitionNotes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RIPScore_main_listbox_AcquisitionNotes


% --- Executes during object creation, after setting all properties.
function RIPScore_main_listbox_AcquisitionNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_main_listbox_AcquisitionNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
