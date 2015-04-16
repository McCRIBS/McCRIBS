function [sttAbbrev] = stateAbbreviation(sttCode)
%STATEABBREVIATION Returs the acronym of the specified state.
%	[sttAbbrev] = stateAbbreviation(sttCode)
%		outputs the acronym for the state code
%       in sttCode.
%
%   INPUT
%   sttCode is a scalar value with a numerical state
%       code [1].
%
%   OUTPUT
%   sttAbbrev is a string with the state abbreviation
%       as defined in [1].
%
%   EXAMPLE
%   sttCode=1;
%   [sttAbbrev]=stateAbbreviation(sttCode);
%   display(['Acronym of state #' num2str(sttCode) ': ' sttAbbrev]);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions (CARR).
%   2013_12_11: Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] McCRIB Group: Naming/Plotting Standards for Code, Figs and Symbols.
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

    switch sttCode
        case 1
            sttAbbrev='PAU';
            return;
        case 3
            sttAbbrev='MVT';
            return;
        case 99
            sttAbbrev='UNK';
            return;
        case 4
            sttAbbrev='SYB';
            return;
        case 2
            sttAbbrev='ASB';
            return;
        case 5
            sttAbbrev='SIH';
            return;
        case 6
            sttAbbrev='BRE';
            return;
        case 11
            sttAbbrev='BDY';
            return;
        case 0
            sttAbbrev = 'NIL';
        otherwise
            sttAbbrev=nan;
            error(['Error in stateAbbreviation, input not recognized: ' num2str(sttCode)]);
            return;
    end
end