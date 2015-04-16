function [Events] = signal2events(X)
%SIGNAL2EVENTS Takes a signal X and separates it into
%	different events according to the quantization.
%	This function undoes the operation performed by
%   events2signal.
%   [Events] = signal2events(X) returns the information
%       of signal X into event structure form.
%
%   INPUT
%   X is an M-by-1 vector with a quantized signal (in
%       several categories).
%
%   OUTPUT
%   Events is an N-by-3 matrix with the information of
%       each event in X. Each row has the following
%       format: [Start Time, End Time, Type].
%
%   EXAMPLE
%   [Events]=signal2events(X);
%
%   VERSION HISTORY
%   2013_12_16 - Updated help header based on [1] (CARR).
%   2011_10_01 - Created by: Carlos A. Robles-Rubio.
%
%   REFERENCES
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%
%Copyright (c) 2011-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

types=unique(X);

Events=[];

for index=1:length(types)
    idx=find(X==types(index));

    idxFinales=idx([diff(idx);9999]>1);
    idxInicios=idx([9999;diff(idx)]>1);
    Events=[Events;[idxInicios idxFinales ones(size(idxInicios,1),1).*types(index)]];
end

end