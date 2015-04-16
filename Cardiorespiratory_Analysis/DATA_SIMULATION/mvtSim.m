function  [mvtSig, mvtNoise, electNoise, t] = mvtSim(respSig, mvtDelay, mvtAmp, electAmp)
% MVTSIM - simulate a epoch with movement artifact
% [mvtSig, mvtNoise, electNoise, t] = mvtSim(respSig, mvtDelay, mvtAmp, electAmp)
%   ... 
% Usage
% Inputs:
%    respSig - respiration signal
%   mvtDealy - dealy for start of movement artifact
%   mvtAmp - amplidue of movement artifact, (default==1);
%   electAmp - amplitude of electricalnoise (default==1); 
% Outputs:
%   mvtSig - signal corrouted with movement artifact
%   mvtNoise - movement noise
%   electNouise - electrical noise. 
% 
% Example 
% 
% See also 
% 
%% AUTHOR: Robert Kearney 
%% $DATE: 21-Sep-2009 13:06:19 $ 
%% $Revision: 1.3 $ 
%% DEVELOPED: 7.8.0.347 (R2009a) 
%% FILENAME: mvtSim.m 
%
%
%Copyright (c) 2009-2015, Robert E. Kearney,
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

if nargin<4,
    electAmp=.1;
end
if nargin<3,
    mvtAmp=1;
end
tMax=(length(respSig)-1)*.02;   %add 1000 for drop samples
t = (0:0.02:tMax)';
[nr nc] = size(t);


%Original Values
% RR = rand(1);
% sigma=1+RR;
% driftVel=.02;
% mu=0;

sigma=0.5;
driftVel=0.1;
mu=0;

initialLocation=0;
[mvtNoise] = ornuhl(t,sigma,driftVel,mu,initialLocation);   %movement noise
% mvtNoise=mvtNoise(1001:end);
if mvtDelay >0,
    mvtNoise = [0*mvtNoise(1:round(mvtDelay*50)); mvtNoise(1:end-round(mvtDelay*50))];
end
mvtNoise=mvtAmp*mvtNoise;

electNoise = electAmp*randn(nr,1);%electronic noise (Gaussian)
% electNoise = electNoise(1001:end);
mvtSig = respSig+ mvtNoise+electNoise;


% ===== EOF ====== [mvtSim.m] ======  
