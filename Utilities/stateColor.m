function [sttColor] = stateColor(stt)
%STATECOLOR Returs the RGB color vector for the
%	specified input state.
%	[sttColor] = stateColor(stt)
%		outputs the RGB color definition for the state
%       in stt.
%
%   INPUT
%   stt is either a string with the state abbreviation
%       or an integer the state code as defined in [1].
%
%   OUTPUT
%   sttColor is an 1-by-3 vector with the RGB
%       color for the state in stt [1].
%
%   EXAMPLE
%   sttAbbrev='PAU';
%   [sttColor]=stateColor(sttAbbrev);
%   display(['State color of ' sttAbbrev ' is: R = ' num2str(sttColor(1),'%1.4f') ', G = ' num2str(sttColor(2),'%1.4f') ', B = ' num2str(sttColor(3),'%1.4f') '.']);
%   [sttColor]=stateColor(stateCode(sttAbbrev));
%   display(['State color of ' sttAbbrev ' is: R = ' num2str(sttColor(1),'%1.4f') ', G = ' num2str(sttColor(2),'%1.4f') ', B = ' num2str(sttColor(3),'%1.4f') '.']);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions (CARR).
%   2013_12_11: Created by Carlos A. Robles-Rubio (CARR).
%
%   References:
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%
%Copyright (c) 2013-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    switch stt
        case 'PAU'
            sttColor=[0,0.5,1];             %Blue
            return;
        case stateCode('PAU')
            sttColor=[0,0.5,1];             %Blue
            return;
        case 'MVT'
            sttColor=[1,0.25,0.25];         %Red
            return;
        case stateCode('MVT')
            sttColor=[1,0.25,0.25];         %Red
            return;
        case 'UNK'
            sttColor=[0,0,0];               %Black
            return;
        case stateCode('UNK')
            sttColor=[0,0,0];               %Black
            return;
        case 'SYB'
            sttColor=[0.953,0.871,0.733];   %Beige
            return;
        case stateCode('SYB')
            sttColor=[0.953,0.871,0.733];   %Beige
            return;
        case 'ASB'
            sttColor=[0,1,0.5];             %Green
            return;
        case stateCode('ASB')
            sttColor=[0,1,0.5];             %Green
            return;
        case 'SIH'
            sttColor=[0.588,0.616,0.082];   %Olive
            return;
        case stateCode('SIH')
            sttColor=[0.588,0.616,0.082];   %Olive
            return;
        case 'BRE'
            sttColor=[0.66,0.87,0.52];      %Pastel Green
            return;
        case stateCode('BRE')
            sttColor=[0.66,0.87,0.52];      %Pastel Green
            return;
        case 'BDY'
            sttColor=[0.5,0,0.5];           %Purple
            return;
        case stateCode('BDY')
            sttColor=[0.5,0,0.5];           %Purple
            return;
        case 'NIL'
            sttColor=[0.941 0.941 0.941];	%Gray
            return;           
        case stateCode('NIL')               %not scored
            sttColor=[0.941 0.941 0.941];	%Gray
            return;
    end
end