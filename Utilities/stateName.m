function [sttName] = stateName(stt)
%STATENAME Returs the name of the input state.
%	[sttName] = stateName(stt)
%		outputs a string with the full name of
%       the state in stt.
%
%   INPUT
%   stt is either a string with the state abbreviation
%       or an integer the state code as defined in [1].
%
%   OUTPUT
%   sttName is a string with the name of the
%       state in stt [1].
%
%   EXAMPLE
%   sttAbbrev='PAU';
%   [sttName]=stateName(sttAbbrev);
%   display(['State name of ' sttAbbrev ' is: ' sttName '.']);
%   [sttName]=stateName(stateCode(sttAbbrev));
%   display(['State name of ' sttAbbrev ' is: ' sttName '.']);
%
%   VERSION HISTORY
%   2015_03_31: Created by Carlos A. Robles-Rubio (CARR).
%
%   References:
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
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

    switch stt
        case 'PAU'
            sttName='Pause';
            return;
        case stateCode('PAU')
            sttName='Pause';
            return;
        case 'MVT'
            sttName='Movement artifact';
            return;
        case stateCode('MVT')
            sttName='Movement artifact';
            return;
        case 'UNK'
            sttName='Unknown';
            return;
        case stateCode('UNK')
            sttName='Unknown';
            return;
        case 'SYB'
            sttName='Synchronous-breathing';
            return;
        case stateCode('SYB')
            sttName='Synchronous-breathing';
            return;
        case 'ASB'
            sttName='Asynchronous-breathing';
            return;
        case stateCode('ASB')
            sttName='Asynchronous-breathing';
            return;
        case 'SIH'
            sttName='Sigh';
            return;
        case stateCode('SIH')
            sttName='Sigh';
            return;
        case 'BRE'
            sttName='Breathing';
            return;
        case stateCode('BRE')
            sttName='Breathing';
            return;
        case 'BDY'
            sttName='Bradycardia';
            return;
        case stateCode('BDY')
            sttName='Bradycardia';
            return;
        case 'NIL'
            sttName='No state assigned';
            return;           
        case stateCode('NIL')
            sttName='No state assigned';
            return;
    end
end