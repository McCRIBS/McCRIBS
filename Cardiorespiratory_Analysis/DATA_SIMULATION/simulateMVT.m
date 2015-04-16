function [RCG,ABD,PPG,SAT] = simulateMVT(L,RHOMV,RHOBR)
%SIMULATEMVT Simulation of movement artifact
%	in RIP Signals
%   [RCG,ABD,PPG,SAT] = simulateMVT(L,RHOMV,RHOBR)
%       returns simulated RIP movement artifact
%       signals.
%
%   INPUT
%	L is a scalar value indicating the length
%       in samples of the simulated segment.
%   RHOMV is a scalar value with the desired
%       amplitude scaling of the movement artifact
%       (suggested range: [0.5,1.5]).
%   RHOBR is a scalar value with the desired
%       amplitude scaling of the breathing signal
%       (suggested value: 1).
%
%   OUTPUT
%   RCG is an M-by-1 vector containing the simulated
%       ribcage signal.
%   ABD is an M-by-1 vector containing the simulated
%       abdomen signal.
%   PPG is an M-by-1 vector containing the simulated
%       photoplethysmography signal.
%   SAT is an M-by-1 vector containing the simulated
%       oxygen saturation signal.
%
%   EXAMPLE
%   Fs=50;      %Sampling frequency in Hz
%   L=30*Fs;    %Simulate 30s of MVT
%   RHOMV=1;
%   RHOBR=1;
%   [RCG,ABD,PPG,SAT]=simulateMVT(L,RHOMV,RHOBR);
%
%   VERSION HISTORY
%   2015_04_09 - Updated help based on [1] (CARR).
%   Original   - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
%   [2] C. A. Robles-Rubio, G. Bertolizio, K. A. Brown, and R. E. Kearney,
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

    Fs=50;

    [rc,ab,pp,sa]=simulateBRE(L,unifrnd(-1,1));

    mvtDelay=0;
    electAmp=0;
    [RCG,rcMvtNoise]=mvtSim(rc.*RHOBR,mvtDelay,RHOMV,electAmp);
    [ABD,abMvtNoise]=mvtSim(ab.*RHOBR,mvtDelay,RHOMV,electAmp);

    %PPG and SAT
    PPG=zeros(size(RCG));
    SAT=zeros(size(RCG));

end