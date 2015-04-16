function [sttCode] = stateCode(sttAbbrev)
%STATECODE Returs the numerical code for the
%	specified input state.
%	[sttCode] = stateCode(sttAbbrev)
%		outputs the integer code for the state
%       in sttAbbrev.
%
%   INPUT
%   sttAbbrev is a string with the state abbreviation
%       as defined in [1].
%
%   OUTPUT
%   sttCode is a scalar value with the numerical
%       code for the state in sttAbbrev [1].
%
%   EXAMPLE
%   [sttCode]=stateCode('PAU');
%   display(['Code of PAU: ' num2str(sttCode)]);
%
%   VERSION HISTORY
%   2014_10_31: Made variable names consistent across functions (CARR).
%   2013_12_11: Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
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

    switch sttAbbrev
        case 'PAU'
            sttCode=1;
            return;
        case 'MVT'
            sttCode=3;
            return;
        case 'UNK'
            sttCode=99;
            return;
        case 'SYB'
            sttCode=4;
            return;
        case 'ASB'
            sttCode=2;
            return;
        case 'SIH'
            sttCode=5;
            return;
        case 'BRE'
            sttCode=6;
            return;
        case 'BDY'
            sttCode=11;
            return;
        case 'NIL'
            sttCode=0;
        otherwise
            error(['Error in stateCode, input not recognized: ' sttAbbrev]);
            sttCode=nan;
            return;
    end
end