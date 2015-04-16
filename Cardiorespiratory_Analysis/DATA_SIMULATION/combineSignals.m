function [XY,ixTran] = combineSignals(X,Y,wL,winType,Fs,ShowMsgs)
%COMBINESIGNALS Concatenates signal segments
%	[XY,ixTran] = combineSignals(X,Y,wL,winType,Fs,ShowMsgs)
%       returns X and Y concatenated using a transition
%       window of type winType and length 2*wL+1.
%
%   INPUT
%   X is an M-by-S matrix with S signals of M samples.
%   Y is an N-by-S matrix with S signals of N samples.
%   wL is a scalar value that defines the length
%       (in samples) of the transition window
%       (length = 2*wL+1).
%   winType is a scalar integer value with the
%       type of transition window, defined as:
%       (1) sigmoid, and
%       (other) straight line.
%   Fs is a scalar value with the sampling frequency
%       (default = 50 Hz).
%   ShowMsgs is a flag indicating if messages should
%       be sent to the standard output.
%
%   OUTPUT
%   XY is an (M+N-2*wL-1)-by-S matrix with the
%       concatenated X and Y.
%   ixTran is a (2*wL+1)-by-1 vector with the indices
%       of the concatenation transition.
%
%   EXAMPLE
%   wL=18;          %In samples
%   winType=1;      %Sigmoid window
%   Fs=50;          %In Hz
%   ShowMsgs=true;
%   [XY,ixTran]=combineSignals(X,Y,wL,winType,Fs,ShowMsgs);
%
%   VERSION HISTORY
%   2014_11_06 - Eliminated need for splines; added help (CARR).
%   Original - Created by: Carlos A. Robles-Rubio (CARR).
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

    if ~exist('winType') | isempty(winType)
        winType=inf;
    end
    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    XY=zeros(size(X,1)+size(Y,1)-(2*wL+1),size(X,2));
    newX=zeros(size(XY));
    newX(1:size(X,1),:)=X;
    newY=zeros(size(XY));
    newY(end-size(Y,1)+1:end,:)=Y;
    
    winX=zeros(size(XY));
    winY=zeros(size(XY));
    
    ixPrev=[1:1:size(X,1)-2*wL-1]';
    ixTran=[size(X,1)-2*wL:1:size(X,1)]';
    ixPost=[size(X,1)+1:1:size(XY,1)]';
    n0=ixTran(1)+wL;
    
    switch (winType)
        case 1                  %The sigmoid
            dom=linspace(-5,5,wL*2+1)';
            sigmoid=1-1./(1+exp(-dom));
            winX(ixPrev,:)=1;
            winX(ixPost,:)=0;
            winX(ixTran,:)=sigmoid*ones(1,size(X,2));
            winY=1-winX;
        otherwise               %The straight line window
            winX(ixPrev,:)=1;
            winX(ixPost,:)=0;
            winX(ixTran,:)=(0.5.*(n0+wL-ixTran)./wL)*ones(1,size(X,2));
            winY=1-winX;
    end
    
    XY=newX.*winX+newY.*winY;
end