function varargout = RIPScore_enterScorerID(varargin)
%RIPScore selection of scorer ID.
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
                   'gui_OpeningFcn', @RIPScore_enterScorerID_OpeningFcn, ...
                   'gui_OutputFcn',  @RIPScore_enterScorerID_OutputFcn, ...
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


% --- Executes just before RIPScore_enterScorerID is made visible.
function RIPScore_enterScorerID_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RIPScore_enterScorerID (see VARARGIN)

% Choose default command line output for RIPScore_enterScorerID
handles.output = hObject;

% Set the selected ScorerID to empty
handles.ScorerID=[];

% Get the path to search for existing scorer IDs
handles.pathname=varargin{2};

% Determine scorer type (trainee, scorer) to search for existing IDs
handles.GUImode=0;
handles.scorerType='scorer';

if length(varargin)>=3
    if varargin{3}==1
        handles.GUImode=1;
    end
end
if length(varargin)==4
    handles.scorerType=varargin{4};
end

% Search for existing IDs matching the RIPScore running mode
scorerIDs={};
if handles.GUImode==1;
    r=dir([handles.pathname handles.scorerType '_*.mat']);
    for index=1:length(r)
        [~,remaind]=strtok(r(index).name,'_');
        scorerIDs{index}=remaind(2:end-4);
    end
    scorerIDs=unique(scorerIDs);
else
    r=dir([handles.pathname 'scored_*.mat']);
    for index=1:length(r)
        [~,remaind]=strtok(r(index).name,'_');
        auxScorerIDs=strtok(remaind,'_');
        if length(auxScorerIDs)<4 || strcmp(auxScorerIDs(end-3:end),'.mat')~=1
            scorerIDs{index}=auxScorerIDs;
        end
    end
    scorerIDs=unique(scorerIDs);
end

% Update RIPScore_enterScorerID_SelectID with existing scorer IDs
handles.previousScorerIDs{1}='';
for index=1:length(scorerIDs)
    handles.previousScorerIDs{index+1}=scorerIDs{index};
end
handles.previousScorerIDs{length(scorerIDs)+2}='Add new...';

set(handles.RIPScore_enterScorerID_SelectID,'String',handles.previousScorerIDs');

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes RIPScore_enterScorerID wait for user response (see UIRESUME)
uiwait(handles.RIPScore_enterScorerID_figure);


% --- Outputs from this function are returned to the command line.
function varargout = RIPScore_enterScorerID_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isempty(handles.ScorerID))
    handles.output = nan;
else
    handles.output = handles.ScorerID;
end
guidata(hObject, handles);
varargout{1} = handles.output;
delete(handles.RIPScore_enterScorerID_figure);



function RIPScore_enterScorerID_EnterNewID_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_enterScorerID_EnterNewID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ScorerID = upper(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RIPScore_enterScorerID_EnterNewID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_enterScorerID_EnterNewID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in RIPScore_enterScorerID_OK.
function RIPScore_enterScorerID_OK_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_enterScorerID_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isempty(handles.ScorerID))
    errordlg('Please enter the scorer ID','Error','modal');
else
    uiresume(handles.RIPScore_enterScorerID_figure);
end


% --- Executes when user attempts to close RIPScore_enterScorerID_figure.
function RIPScore_enterScorerID_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_enterScorerID_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ScorerID = [];
guidata(hObject, handles);
uiresume(handles.RIPScore_enterScorerID_figure);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RIPScore_enterScorerID_SelectID.
function RIPScore_enterScorerID_SelectID_Callback(hObject, eventdata, handles)
% hObject    handle to RIPScore_enterScorerID_SelectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RIPScore_enterScorerID_SelectID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RIPScore_enterScorerID_SelectID
contents = cellstr(get(hObject,'String'));
if (strcmp(contents{get(hObject,'Value')},'Add new...'))
    set(hObject,'Visible','off');
    set(handles.RIPScore_enterScorerID_EnterNewID,'Visible','on');
else
    handles.ScorerID = contents{get(hObject,'Value')};
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function RIPScore_enterScorerID_SelectID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIPScore_enterScorerID_SelectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
