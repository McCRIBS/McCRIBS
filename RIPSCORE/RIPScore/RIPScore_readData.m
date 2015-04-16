function [TIM,RCG,ABD,PPG,SAT] = RIPScore_readData(Subject)
%RIPSCORE_READDATA Loads the cardiorespiratory signals
%	saved in RIPScore data format.
%	[TIM,RCG,ABD,PPG,SAT] = RIPScore_readData(Subject)
%       returns the TIM, RCG, ABD, PPG, and SAT
%       cardiorespiratory signals.
%
%   INPUT
%	Subject is a string with the name of the MAT file
%       to be opened (without the ".mat" extension).
%
%   OUTPUT
%	TIM is an M-by-1 vector containing the time for
%       the recording from subject Subject.
%	RCG is an M-by-1 vector containing the Ribcage RIP
%       signal from subject Subject.
%	ABD is an M-by-1 vector containing the Abdomen RIP
%       signal from subject Subject.
%	PPG is an M-by-1 vector containing the Photoplethysmography
%       signal from subject Subject.
%	SAT is an M-by-1 vector containing the Blood Oxygen
%       Saturation signal from subject Subject.
%
%   EXAMPLE
%   Subject='POA_Infant_01_1';
%   [TIM,RCG,ABD,PPG,SAT]=RIPScore_readData(Subject)
%
%   VERSION HISTORY
%   2015_04_03 - Created by: Carlos A. Robles-Rubio.
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

    %Load RIPScore data file
    aux=load([Subject '.mat']);

    % Separate TIM, RCG, ABD, PPG and SAT signals
    TIM = aux.data(:,1);
    RCG = aux.data(:,2);
    ABD = aux.data(:,3);
    PPG = aux.data(:,4);
    SAT = aux.data(:,5);
    clear aux
end