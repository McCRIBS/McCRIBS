function [X] = events2signal(Events)
%EVENTS2SIGNAL Takes the event matrix Events and
%   converts it to signal form. This function undoes
%   the operation performed by signal2events.
%   [X] = events2signal(Events) returns the information
%       of array Events into signal form (vector).
%
%   INPUT
%   Events is an N-by-3 vector with the information of
%       each event in X. Each row has the following
%       format: [Start Sample, End Sample, Type].
%
%   OUTPUT
%   X is an M-by-1 vector with a quantized signal (in
%       several categories).
%
%   EXAMPLE
%   [X]=events2signal(Events);
%
%   VERSION HISTORY
%   2013_12_16 - Updated help header based on [1] (CARR).
%   2013_11_02 - Created by: Carlos A. Robles-Rubio.
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

L=max(Events(:,2));
X=zeros(L,1);

for index=1:size(Events,1)
    X(Events(index,1):Events(index,2))=Events(index,3);
end

end