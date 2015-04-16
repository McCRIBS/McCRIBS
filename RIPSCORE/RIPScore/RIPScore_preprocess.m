function [DataPrep,ReconstructionData] = RIPScore_preprocess(Data,TrueState_Segms,wL,winType,Fs,ShowMsgs)
%RIPSCORE_PREPROCESS Pre-processes raw cardiorespiratory
%	signals by inserting segments with known "true-states".
%	[DataPrep,ReconstructionData] = RIPScore_preprocess(Data,TrueState_Segms,wL,winType,Fs,ShowMsgs)
%       returns the pre-processed DataPrep by inserting
%       TrueState_Segms into Data.
%
%   INPUT
%   Data is an N-by-5 matrix with the original
%       cardiorespiratory signals to be pre-processed.
%	TrueState_Segms is a struct array with a list of
%       data segments with an identified "true-state".
%       These segments will be inserted into Data to
%       yield DataPrep. TrueState_Segms has the
%       following fields:
%    	* Data is a 1-by-L cell array with one "true-
%         state" segment per item. Each cell has an Si-
%         by-4 matrix, where Si is the length of the
%         segment and the columns correspond to:
%           (1)Ribcage (arbitrary units),
%           (2)Abdomen (arbitrary units),
%           (3)Photoplethysmograph (arbitrary units),
%           (4)Blood oxygen saturation (%).
%         The sampling frequency is Fs.
%    	* type is a L-by-1 vector with the state type
%         of each of the segments. The state type codes
%         are:
%           (1) Pause=1,
%           (2) Asynchronous-breathing=2,
%           (3) Movement artifact=3,
%           (4) Synchronous-breathing=4,
%           (5) Sigh=5,
%           (6) Unknown=99.
%    	* length is a L-by-1 vector with the length (in
%         samples) of each of the segments.
%    	* eventID is a L-by-1 vector with the ID of each
%         of the segments.
%   wL is a scalar value that defines the length
%       (in samples) of the transition window
%       (length = 2*wL+1) used to concatenate
%       inserted segments (default=18).
%   winType is a scalar integer value with the
%       type of concatenation transition window,
%       defined as:
%           (1) sigmoid (default), and
%           (other) straight line.
%   Fs is a scalar value with the sampling
%       frequency (default=50Hz).
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output (default=false).
%
%   OUTPUT
%   DataPrep is an M-by-5 matrix with the pre-processed
%       cardiorespiratory signals.
%   ReconstructionData is a struct with the pre-
%       processing information, including the location
%       of each inserted "true-state" segment, its
%       state code and state ID. The struct has the
%       following fields:
%    	* State_Tot is an M-by-1 vector of integers
%         with the state code for each sample in
%         DataPrep. Inserted "true-state" segments
%         have one of six state codes:
%           (1) Pause=1,
%           (2) Asynchronous-breathing=2,
%           (3) Movement artifact=3,
%           (4) Synchronous-breathing=4,
%           (5) Sigh=5,
%           (6) Unknown=99.
%    	* EventID_Tot is an M-by-1 vector indicating
%         which samples from DataPrep correspond to each
%         inserted "true-state" segment. Each segment
%         has a different ID and was inserted twice in
%         the original Data.
%
%   EXAMPLE
%
%   VERSION HISTORY
%   2015_04_04 - Created by: Carlos A. Robles-Rubio.
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

    if ~exist('wL') | isempty(wL)
        wL=18;
    end
    if ~exist('winType') | isempty(winType)
        winType=1;
    end
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    [numSampl,numSigs]=size(Data); %The number of samples and signals in data
    numSegm=size(TrueState_Segms.type,1); %The number of segments in TrueState_Segms
    
    %Assign original signals to temporary variables
    RCGorig=Data(:,2);
    ABDorig=Data(:,3);
    PPGorig=Data(:,4);
    SATorig=Data(:,5);
    
    %Determine Half Marker
    halfMarker=floor(length(RCGorig)/2);
    
    %Shuffle evaluation segments for each half
    randIx=randsample(numSegm,numSegm);
    Segms_Half1.Data={};
    Segms_Half1.type=zeros(numSegm,1);
    Segms_Half1.length=zeros(numSegm,1);
    Segms_Half1.eventID=zeros(numSegm,1);
    for jndex=1:numSegm
        Segms_Half1.Data{jndex}=TrueState_Segms.Data{randIx(jndex)};
        Segms_Half1.type(jndex)=TrueState_Segms.type(randIx(jndex));
        Segms_Half1.length(jndex)=TrueState_Segms.length(randIx(jndex));
        Segms_Half1.eventID(jndex)=TrueState_Segms.eventID(randIx(jndex));
    end
    clear randIx jndex
    randIx=randsample(numSegm,numSegm);
    Segms_Half2.Data={};
    Segms_Half2.type=zeros(numSegm,1);
    Segms_Half2.length=zeros(numSegm,1);
    Segms_Half2.eventID=zeros(numSegm,1);
    for jndex=1:numSegm
        Segms_Half2.Data{jndex}=TrueState_Segms.Data{randIx(jndex)};
        Segms_Half2.type(jndex)=TrueState_Segms.type(randIx(jndex));
        Segms_Half2.length(jndex)=TrueState_Segms.length(randIx(jndex));
        Segms_Half2.eventID(jndex)=TrueState_Segms.eventID(randIx(jndex));
    end
    clear randIx jndex
    
    %Insert the evaluation segments (Half 1)
    ixThisHalf=[(2*wL+2):1:halfMarker-(2*wL+2)]';       %Sample indices corresponding to this half
    ixToInsert=sort(randsample(ixThisHalf,numSegm));    %Randomly select indices where "true-state" segments will be inserted
    testShort=[2*wL+2;diff(ixToInsert)];                %Verify that the number of samples between insertion indices is > concatenation window (2*wL+1)
    ixTooShort=find(testShort<(2*wL+1));
    while ~isempty(ixTooShort)                          %Replace all indices where the number of samples between consecutive indices is <= (2*wL+1)
        for kndex=1:length(ixTooShort)
            ixToInsert(ixTooShort(kndex))=ixToInsert(ixTooShort(kndex))-testShort(ixTooShort(kndex))+2*wL+1;
        end
        testShort=[2*wL+2;diff(ixToInsert)];
        ixTooShort=find(testShort<(2*wL+1));
    end
    ixStartSeg=[1;ixToInsert(1:end-1)+1];               %The start of each original Data segment
    auxSegms.Data={};                                   %Auxiliary Segments struct to arrange original and "true-state" segments
    auxSegms.type=zeros(2*numSegm+1,1);
    auxSegms.length=zeros(2*numSegm+1,1);
    auxSegms.eventID=zeros(2*numSegm+1,1);
    counter=0;
    for jndex=1:numSegm                                 %For all original Data segments
        counter=counter+1;
        ixSegm=[ixStartSeg(jndex):1:ixToInsert(jndex)]';%Indices of the original Data segment
        auxData=[RCGorig(ixSegm) ABDorig(ixSegm) PPGorig(ixSegm) SATorig(ixSegm)];  %Get the original Data
        auxSegms.Data{counter}=auxData;                 %Save the original Data segment in the Segments struct
        auxSegms.type(counter)=-1;                      %Original data has no defined state (type=-1)
        auxSegms.length(counter)=length(ixSegm);
        auxSegms.eventID(counter)=-1;                   %Original data has no defined ID (eventID=-1)
        clear auxData ixSegm
        
        counter=counter+1;
        auxSegms.Data{counter}=Segms_Half1.Data{jndex}; %Get the next "true-state" segment and save it to the Segments struct
        auxSegms.type(counter)=Segms_Half1.type(jndex);
        auxSegms.length(counter)=Segms_Half1.length(jndex);
        auxSegms.eventID(counter)=Segms_Half1.eventID(jndex);
    end
    counter=counter+1;
    ixSegm=[ixToInsert(end)+1:1:halfMarker]';           %Get the final original Data segment
    auxData=[RCGorig(ixSegm) ABDorig(ixSegm) PPGorig(ixSegm) SATorig(ixSegm)];
    auxSegms.Data{counter}=auxData;                     %Save the segment to the struct
    auxSegms.type(counter)=-1;
    auxSegms.length(counter)=length(ixSegm);
    auxSegms.eventID(counter)=-1;
    [Data_Half1,State_Half1,EventID_Half1]=artificialData(auxSegms,wL,winType); %Concatenate the segments in the struct to get the 1st half of DataPrep
    clear counter ixThisHalf ixToInsert ixStartSeg auxSegms jndex auxData ixSegm testShort ixTooShort kndex
    
    %Insert the evaluation segments (Half 2)
    ixThisHalf=[halfMarker+(2*wL+2):1:numSampl-(2*wL+2)]';	%Sample indices corresponding to this half
    ixToInsert=sort(randsample(ixThisHalf,numSegm));        %Randomly select indices where "true-state" segments will be inserted
    testShort=[2*wL+2;diff(ixToInsert)];
    ixTooShort=find(testShort<(2*wL+1));
    while ~isempty(ixTooShort)
        for kndex=1:length(ixTooShort)
            ixToInsert(ixTooShort(kndex))=ixToInsert(ixTooShort(kndex))-testShort(ixTooShort(kndex))+2*wL+1;
        end
        testShort=[2*wL+2;diff(ixToInsert)];
        ixTooShort=find(testShort<(2*wL+1));
    end
    ixStartSeg=[halfMarker+1;ixToInsert(1:end-1)+1];        %The start of each original Data segment
    auxSegms.Data={};                                       %Auxiliary Segments struct to arrange original and "true-state" segments
    auxSegms.type=zeros(2*numSegm+1,1);
    auxSegms.length=zeros(2*numSegm+1,1);
    auxSegms.eventID=zeros(2*numSegm+1,1);
    counter=0;
    for jndex=1:numSegm
        counter=counter+1;
        ixSegm=[ixStartSeg(jndex):1:ixToInsert(jndex)]';
        auxData=[RCGorig(ixSegm) ABDorig(ixSegm) PPGorig(ixSegm) SATorig(ixSegm)];
        auxSegms.Data{counter}=auxData;                     %Save the original Data segment in the Segments struct
        auxSegms.type(counter)=-1;
        auxSegms.length(counter)=length(ixSegm);
        auxSegms.eventID(counter)=-1;
        clear auxData ixSegm
        
        counter=counter+1;
        auxSegms.Data{counter}=Segms_Half2.Data{jndex};     %Get the next "true-state" segment and save it to the Segments struct
        auxSegms.type(counter)=Segms_Half2.type(jndex);
        auxSegms.length(counter)=Segms_Half2.length(jndex);
        auxSegms.eventID(counter)=Segms_Half2.eventID(jndex);
    end
    counter=counter+1;
    ixSegm=[ixToInsert(end)+1:1:numSampl]';                 %Get the final original Data segment
    auxData=[RCGorig(ixSegm) ABDorig(ixSegm) PPGorig(ixSegm) SATorig(ixSegm)];
    auxSegms.Data{counter}=auxData;                         %Save the segment to the struct
    auxSegms.type(counter)=-1;
    auxSegms.length(counter)=length(ixSegm);
    auxSegms.eventID(counter)=-1;
    [Data_Half2,State_Half2,EventID_Half2]=artificialData(auxSegms,wL,winType); %Concatenate the segments in the struct to get the 2nd half of DataPrep
    clear counter ixThisHalf ixToInsert ixStartSeg auxSegms jndex auxData ixSegm testShort ixTooShort kndex
    
    %Consolidate the two halfs
    Data_Tot=[Data_Half1;Data_Half2];           %Final signals obtained by putting together the two halves
    ReconstructionData.State_Tot=[State_Half1;State_Half2];
    ReconstructionData.EventID_Tot=[EventID_Half1;EventID_Half2];
    ReconstructionData.EventIDNoSimulation=-1;	%Segments from Data that don't correspond to "true-state" segments
    ReconstructionData.EventIDTransitions=0;    %Segments that correspond to concatenation transitions
    clear Data_Half1 Data_Half2 State_Half1 State_Half2 EventID_Half1 EventID_Half2

    %Set the cardiorespiratory signals
    RCG=Data_Tot(:,1);
    ABD=Data_Tot(:,2);
    PPG=Data_Tot(:,3);
    SAT=Data_Tot(:,4);
    TIM=(1:1:length(RCG))-1;	%The time index, the first Data column
    TIM=TIM'./Fs;
    clear Data_Tot
    
    %Get the data in RIPScore format
    DataPrep=nan(length(RCG),numSigs);	%The data matrix,ReconstructionData
    DataPrep(:,1)=TIM;
    DataPrep(:,2)=RCG;
    DataPrep(:,3)=ABD;
    DataPrep(:,4)=PPG;
    DataPrep(:,5)=SAT;
end