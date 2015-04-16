function [Xf2S] = filter2S(b,X,ShowMsgs)
%FILTER2S Performs two-sided zero-phase FIR filtering
%   [Xf2S] = filter2S(b,X,ShowMsgs) returns the
%       signals in X filtered by a two-sided FIR filter
%       with impulse response b.
%
%   INPUT
%   b is an P-by-1 vector with the impulse response
%       of the filter to be used. P must be an odd
%       number.
%   X is an M-by-K matrix with the signals to be
%       filtered.
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output (default=false).
%
%   OUTPUT
%   Xf2S is an M-by-1 vector containing the filtered
%       signal.
%
%   EXAMPLE
%   %Create a random signal X
%   M=400;
%   X=rand(M,1);
%   %Create a moving average filter of P points
%   P=51;
%   b=ones(P,1)./P;
%   %Filter signal X
%   Xf1S=filter(b,1,X);
%   Xf2S=filter2S(b,X);
%   %Plot the signals
%   plot([X Xf1S Xf2S]);
%   legend('Original','One-sided filtered','Two-sided filtered');
%
%   VERSION HISTORY
%   2015_04_02 - Created by Carlos A. Robles-Rubio (CARR).
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

    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    [M,K]=size(X);
    P=length(b);
    
    if mod(P,2)==0
        error(['The length of ''b'' must be an odd number. E.g., length(b) = ' num2str(P+1)]);
    end
    
    Xaux=filter(b,1,X);
    Xf2S=nan(M,K);
    Xf2S(floor(P/2)+1:end-floor(P/2),:)=Xaux(P:end,:);
end