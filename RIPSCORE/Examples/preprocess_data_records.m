%'preprocess_data_records.m' loads raw data records
%and pre-processes them by inserting segments with
%known "true-states" at random times. It uses the
%following RIPScore functions:
%   (1) RIPScore_preprocess.m
%
%This script provides an example for the use of
%RIPScore functions and should be modified to fit
%local needs.
%
%   VERSION HISTORY
%   2015_04_05 - Created by: Carlos A. Robles-Rubio.
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

clear;
clc;
close all;

rng('shuffle');
McCRIB_DATA_ROOT=getenv('McCRIB_DATA_ROOT');

set(0,'defaultaxesfontsize',16);
set(0,'defaulttextfontsize',16);

%General variables
saveFlag=true;
ShowMsgs=true;
Fs=50;          %The sampling frequency

%Data records
datadir=[McCRIB_DATA_ROOT '\POA\Original_Dataset\data\']; %Path to the raw data. Data must be in RIPScore format

%"True-state" library
TrueState_Library_path=[McCRIB_DATA_ROOT '\POA\TrueState_Segment_Library\TrueState_Library.mat'];	%The complete path to the "true-state" segments library
aux=load(TrueState_Library_path);
TrueState_Library=aux.goldenEvents;
clear aux

%File names
fileNames={'POA_Infant_05_1';
    'POA_Infant_10_1';
    'POA_Infant_15_1';
    'POA_Infant_20_1'};

numFiles=length(fileNames);
lengthEach=zeros(numFiles,1);

%Pre-processing variables    
wL=18;
winType=1;

%% Generate and save "true-state" segments used for evaluation
useRealData=1;          %1:"true-state" data, 0:simulated data
expectedLength=1111*Fs; %The expected length (in samples) of the generated "true-state" segments after being concatenated

TrueState_Segms=generateEvents(useRealData,expectedLength,TrueState_Library,wL,true);
save('PreProcessing_Segments','TrueState_Segms');
numSegms=size(TrueState_Segms.type,1);

%% Load, pre-process, and save updated files
stSample=1;             %Start sample.
enSample=20000*Fs;      %End sample.

for index=1:numFiles
    %Load the original file
    OrigInfo=load([datadir fileNames{index}]);
    
    %Pre-process the original data and yield the pre-processed data
    [data,ReconstructionData]=RIPScore_preprocess(OrigInfo.data(stSample:enSample,:),TrueState_Segms,wL,winType,Fs,ShowMsgs);
    Column_Labels=OrigInfo.Column_Labels;
    
    if saveFlag
        save([fileNames{index} '_preproc'],'Column_Labels','ReconstructionData','data');
    end
    clear OrigInfo data ReconstructionData Column_Labels
end