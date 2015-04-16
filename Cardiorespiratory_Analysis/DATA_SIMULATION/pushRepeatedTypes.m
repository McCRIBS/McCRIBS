function newIndices = pushRepeatedTypes(types,indices)
%PUSHREPEATEDTYPES Rearranges the list in types so that
%   contiguous items have not the same value.
%   newIndices = pushRepeatedTypes(types,indices)
%
%   INPUT
%   types is an L-by-1 vector of integers with
%       the state type for a list of L segments.
%   indices is an L-by-1 vector of integers with
%       the order of each segment in the list.
%
%   OUTPUT
%   newIndices is an L-by-1 vector of integers with
%       the new order of each segment in the list,
%       after pushing repeated types to the end.
%
%   EXAMPLE
%   newIndices=pushRepeatedTypes(types,indices);
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

    tmp=[1;diff(types)];

    ixGtmp=find(tmp~=0);
    ixBtmp=find(tmp==0);
    
    ixG=indices(ixGtmp(1:end-1));
    ixB=indices([ixGtmp(end);ixBtmp]);

    if ~isempty(ixG)
        newIndices=[ixG;pushRepeatedTypes(types([ixGtmp(end);ixBtmp]),ixB)];
    else
        newIndices=ixB;
    end
end