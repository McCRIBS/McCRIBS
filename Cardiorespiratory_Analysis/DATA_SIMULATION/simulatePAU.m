function [RCG,ABD,PPG,SAT] = simulatePAU(L,RHO)
%SIMULATEPAU Simulation of respiratory pause
%	in RIP Signals
%   [RCG,ABD,PPG,SAT] = simulatePAU(L,RHO)
%       returns a simulated RIP pause segment.
%
%   INPUT
%   L is a scalar value indicating the length
%       in samples of the simulated segment.
%   RHO is a scalar value with the desired
%       amplitude scaling (for pauses it should
%       be in the range [0,0.1]).
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
%   Fs=50;              %Sampling frequency in Hz
%   L=10*Fs;            %Simulate 10s of PAU
%   RHO=unifrnd(0,0.1); %A random amplitude in the range [0,0.1]
%   [RCG,ABD,PPG,SAT]=simulatePAU(L,RHO);
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

load('breathModels.mat');
load('AR_params.mat');
Fs=50;
PHI=unifrnd(-1,1);

Ndisc=10000; %Samples to discard
N=round(2*L/(0.75*Fs));    %The approximate number of breaths needed
SNR=20; %As a unitless ratio (not in dB)

%% RIP
%Generate length noise
lennoise=normrnd(0,sqrt(noiseVar.elrc),Ndisc+N,1);

%Generate correlated height noise
heinoise=normrnd(0,sqrt(noiseVar.el2hrc),Ndisc+N,1);

%Generate ARs
lenAR=zeros(Ndisc+N,1);
heiAR=zeros(Ndisc+N,1);
for index=AR_M+1:Ndisc+N
    lenAR(index)=wlrc(1:end-1)'*lenAR(index-AR_M:index-1)+wlrc(end)+lennoise(index);
    heiAR(index)=wl2hrc(1:end-1)'*lenAR(index-L2H_RC:index)+wl2hrc(end);
end
lenAR=round(exp(lenAR(Ndisc+1:end)));
heiAR=exp(heiAR(Ndisc+1:end));

%Generate traces
rcclean=[];
abclean=[];

numBreaths=0;
for index=1:N
    auxrc=myIRFrcUSE(1:round(lenAR(index)),round(lenAR(index))).*heiAR(index);
    auxab=myIRFabUSE(1:round(lenAR(index)),round(lenAR(index))).*heiAR(index);
    auxsum=sum(auxrc)+sum(auxab);
    if auxsum>0
        rcclean=[rcclean;auxrc];
        abclean=[abclean;auxab];
        numBreaths=numBreaths+1;
    end
end

%Generate the noise sequences and normalize for SNR
Nix_rc=size(rcclean,1);
Nix_ab=size(abclean,1);

bpnk=[0.049922035 -0.095993537 0.050612699 -0.004408786];
apnk=[1 -2.494956002   2.017265875  -0.522189400];

simpwrrc=rcclean'*rcclean/Nix_rc;
simpwrab=abclean'*abclean/Nix_ab;

%White noise
whitnrc=normrnd(0,1,Nix_rc,1);
whitpwr=whitnrc'*whitnrc/Nix_rc;
whitnrc=whitnrc.*sqrt(1/(whitpwr));

whitnab=normrnd(0,1,Nix_ab,1);
whitpwr=whitnab'*whitnab/Nix_ab;
whitnab=whitnab.*sqrt(1/(whitpwr));

%1/f^2 noise
pinknrc=filtfilt(bpnk,apnk,normrnd(0,1,Nix_rc+Ndisc,1));
pinknrc=pinknrc(Ndisc+1:end);
auxpwr=pinknrc'*pinknrc/Nix_rc;
pinknrc=pinknrc.*sqrt(99/(auxpwr));

pinknab=filtfilt(bpnk,apnk,normrnd(0,1,Nix_ab+Ndisc,1));
pinknab=pinknab(Ndisc+1:end);
auxpwr=pinknab'*pinknab/Nix_ab;
pinknab=pinknab.*sqrt(99/(auxpwr));

%Compound noise
rcnoise=whitnrc+pinknrc;
noipwr=rcnoise'*rcnoise/Nix_rc;
rcnoise=rcnoise.*sqrt(simpwrrc/(SNR*noipwr));
abnoise=whitnab+pinknab;
noipwr=abnoise'*abnoise/Nix_ab;
abnoise=abnoise.*sqrt(simpwrab/(SNR*noipwr));

%Add noise
rc=rcclean.*RHO+rcnoise;
ab=abclean.*RHO+abnoise;

%Zero-mean
rc=rc-mean(rc);
ab=ab-mean(ab);

%Phase shift
halfMeanPeriod=length(rc)./(2*numBreaths);
k=round(PHI*halfMeanPeriod);

auxRC=zeros(length(rc)+2*abs(k),1);
auxAB=zeros(length(rc)+2*abs(k),1);

auxRC(abs(k)+1-k:length(rc)+abs(k)-k)=rc;
auxAB(abs(k)+1:length(rc)+abs(k))=ab;

%Get segment
ranOffset=unidrnd(length(rc)-L-1);
RCG=auxRC(abs(k)+1+ranOffset:abs(k)+ranOffset+L);
ABD=auxAB(abs(k)+1+ranOffset:abs(k)+ranOffset+L);

% PPG and SAT
PPG=zeros(size(RCG));
SAT=zeros(size(RCG));

end