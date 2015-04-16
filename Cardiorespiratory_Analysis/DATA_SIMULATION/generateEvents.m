function [Events] = generateEvents(useRealData,minTotalLength,TrueState_Library,wL,flagWaitBar)
%GENERATEEVENTS Generates simulated cardiorespiratory
%   data segments.
%   [Events] = generateEvents(useRealData,minTotalLength,TrueState_Library,wL,flagWaitBar)
%
%   INPUT
%   useRealData is a flag indicating which type of data
%       will be generated:
%         (0) "Simulated-state" data=0,
%         (1) "True-state" data=1,
%	minTotalLength is the minimum length of data expected
%       after concatenating with a window of size=2wL+1.
%	TrueState_Library is a struct array with a list of
%       data segments with an identified "true-state".
%       TrueState_Lybrary has the
%       following fields:
%    	* data is a 1-by-L cell array with one "true-
%         state" segment per item. Each cell has an Si-
%         by-4 matrix, where Si is the length of the
%         segment and the columns correspond to:
%           (1)Ribcage (arbitrary units),
%           (2)Abdomen (arbitrary units),
%           (3)Photoplethysmograph (arbitrary units),
%           (4)Blood oxygen saturation (%).
%    	* type is a L-by-1 vector with the state type
%         of each of the segments. The state type codes
%         are:
%           (1) Pause=1,
%           (2) Asynchronous-breathing=2,
%           (3) Movement artifact=3,
%           (4) Synchronous-breathing=4,
%           (5) Sigh=5,
%           (6) Unknown=99.
%    	* lgth is a L-by-1 vector with the length (in
%         samples) of each of the segments.
%   wL is a scalar value that defines the length
%       (in samples) of the transition window
%       (length = 2*wL+1) (see combineSignals).
%   flagWaitBar is a flag indicating if a waitbar
%       should be shown.
%
%   OUTPUT
%   Events is a struct array with a list of data
%       segments. Events has the following fields:
%    	* Data is a 1-by-L cell array with one segment
%         per item. Each cell has an Si-by-K matrix,
%         where Si is the length of the segment and K
%         is the number of signals. Typically, there
%         are 4 columns that correspond to:
%           (1)Ribcage (arbitrary units),
%           (2)Abdomen (arbitrary units),
%           (3)Photoplethysmograph (arbitrary units),
%           (4)Blood oxygen saturation (%).
%    	* type is an L-by-1 vector with the state type
%         of each of the segments.
%    	* length is an L-by-1 vector with the length
%         (in samples) of each of the segments.
%    	* eventID is an L-by-1 vector with the ID of
%         each of the segments.
%
%   EXAMPLE
%   [Events]=generateEvents(useRealData,minTotalLength,TrueState_Library,wL,flagWaitBar);
%
%   VERSION HISTORY
%   Original - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, G. Bertolizio, K. A. Brown, and R. E. Kearney,
%       "Scoring Tools for the Analysis of Infant Respiratory
%       Inductive Plethysmography Signals," submitted to
%       PLoS One, 2015.
%
%
%Copyright (c) 2012-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('flagWaitBar') | isempty(flagWaitBar)
        flagWaitBar=true;
    end

    if flagWaitBar
        myWaitBar=waitbar(0,'Loading data, please wait...');
    end

    PAU=1;
    ASB=2;
    MVT=3;
    SYB=4;
    SIH=5;
    UNK=99;
    Fs=50;
    SNR=20;

    eventTypes=[PAU;ASB;MVT;SYB;SIH;UNK];

    minLength=minTotalLength*1.5;

    auxEvents.Data={};
    auxEvents.type=[];
    auxEvents.length=[];
    auxEvents.eventID=[];

    expectedTotalLength=0;
    numEvents=0;
    while expectedTotalLength<minLength
        for index=eventTypes'
            numEvents=numEvents+1;
            if useRealData
                ixType=find(TrueState_Library.type==index);
                auxlen=0;
                while auxlen<2*Fs
                    ixEvent=randsample(ixType,1);
                    auxlen=TrueState_Library.lgth(ixEvent);
                end
                auxEvents.Data{numEvents}=TrueState_Library.data{ixEvent};
                auxEvents.type(numEvents)=index;
                auxEvents.length(numEvents)=size(auxEvents.Data{numEvents},1);
                auxEvents.eventID(numEvents)=numEvents;
            else
                ranLength=round(exprnd(367))+2*Fs;
                if ranLength>60*Fs
                    ranLength=60*Fs;
                end
                switch index
                    case PAU
                        [RCG,ABD,PPG,SAT]=simulatePAU(ranLength,unifrnd(0,0.1));
                    case ASB
                        [RCG,ABD,PPG,SAT]=simulateBRE(ranLength,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                    case MVT
                        [RCG,ABD,PPG,SAT]=simulateMVT(ranLength,unifrnd(0.5,1.5),1);
                    case SYB
                        [RCG,ABD,PPG,SAT]=simulateBRE(ranLength,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    case SIH
                        auxlen=0;
                        while auxlen<=0
                            [RCG,ABD,PPG,SAT]=simulateSIH(unifrnd(2.5,3));
                            auxlen=length(RCG);
                        end
                    case UNK
                        [RCG,ABD,PPG,SAT]=simulateUNK(ranLength,0.05);
                end
                auxEvents.Data{numEvents}=[RCG,ABD,PPG,SAT];
                auxEvents.type(numEvents)=index;
                auxEvents.length(numEvents)=size(auxEvents.Data{numEvents},1);
                auxEvents.eventID(numEvents)=numEvents;
                clear RCG ABD PPG SAT
            end
            expectedTotalLength=expectedTotalLength+auxEvents.length(numEvents)-(2*wL+1);
        end
        if flagWaitBar
            waitbar(expectedTotalLength/minLength);
        end
    end

    %Randomize the events
    randIx=randsample(numEvents,numEvents);

    preEvents.Data={};
    preEvents.type=zeros(numEvents,1);
    preEvents.length=zeros(numEvents,1);
    preEvents.eventID=zeros(numEvents,1);

    for index=1:numEvents
        preEvents.Data{index}=auxEvents.Data{randIx(index)};
        preEvents.type(index)=auxEvents.type(randIx(index));
        preEvents.length(index)=auxEvents.length(randIx(index));
        preEvents.eventID(index)=auxEvents.eventID(randIx(index));
    end

    newIndices = pushRepeatedTypes(preEvents.type,[1:1:numEvents]');
    expectedFinalLength=cumsum(preEvents.length(newIndices))-(2*wL+1).*[0:1:(numEvents-1)]';
    finNumEvents=find(expectedFinalLength>minTotalLength,1);
    
    Events.Data={};
    Events.type=zeros(finNumEvents,1);
    Events.length=zeros(finNumEvents,1);
    Events.eventID=zeros(finNumEvents,1);

    for index=1:finNumEvents
        Events.Data{index}=preEvents.Data{newIndices(index)};
        Events.type(index)=preEvents.type(newIndices(index));
        Events.length(index)=preEvents.length(newIndices(index));
        Events.eventID(index)=preEvents.eventID(newIndices(index));
    end
    
    if flagWaitBar
        close(myWaitBar);
    end
end