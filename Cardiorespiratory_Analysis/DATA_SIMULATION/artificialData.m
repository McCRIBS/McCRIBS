function [Data,State,EventID] = artificialData(Events,wL,winType)
%ARTIFICIALDATA Concatenates the signals in Events
%   to produce signals in Data.
%   [Data,State,EventID] = artificialData(Events,wL,winType)
%
%   INPUT
%	Events is a struct array with a list of data
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
%   wL is a scalar value that defines the length
%       (in samples) of the transition window
%       (length = 2*wL+1) (see combineSignals).
%   winType is a scalar integer value with the
%       type of transition window (see combineSignals),
%       defined as:
%       (1) sigmoid, and
%       (other) straight line.
%
%   OUTPUT
%   Data is an N-by-K matrix with signals produced
%   	from the concatenation of segments in Events.
%   State is an N-by-1 vector with the state type
%   	of each sample. Transitions have a State=0.
%   EventID is an N-by-1 vector with the ID of
%       each sample. Transitions have an EventID=0.
%
%   EXAMPLE
%   wL=18;      %In samples
%   winType=1;  %Sigmoid window
%   [Data,State,EventID]=artificialData(Events,wL,winType);
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

    numEvents=size(Events.eventID,1);

    Data=Events.Data{1};
    State=ones(Events.length(1),1).*Events.type(1);
    EventID=ones(Events.length(1),1).*Events.eventID(1);

    for index=2:numEvents
        [Data,trIx]=combineSignals(Data,Events.Data{index},wL,winType);
        auxState=zeros(size(Data,1),1);
        auxState(1:length(State))=State;
        auxState(length(State)+1:end)=Events.type(index);
        auxState(trIx)=0;
        clear State
        State=auxState;

        auxEventID=zeros(size(Data,1),1);
        auxEventID(1:length(EventID))=EventID;
        auxEventID(length(EventID)+1:end)=Events.eventID(index);
        auxEventID(trIx)=0;
        clear EventID
        EventID=auxEventID;
    end

end

