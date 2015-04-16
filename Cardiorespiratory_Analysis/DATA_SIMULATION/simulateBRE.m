function [RCG,ABD,PPG,SAT] = simulateBRE(L,PHI,SNR,Fs)
%SIMULATEBRE Simulation of breathing in RIP Signals
%   [RCG,ABD,PPG,SAT]=simulateBRE(L,PHI,SNR,Fs)
%       returns simulated breathing RIP signals.
%
%   INPUT
%	L is a scalar value indicating the length in
%       samples of the simulated segment.
%   PHI is a scalar value with the desired phase
%       between RCG and ABD. PHI is in the range [-1,1]
%       (normalized by 180 degrees), where a positive
%       phase indicates RCG occurs ahead of ABD.
%   SNR is the desired Signal-to-Noise Ratio
%       (default=13dB).
%   Fs is a scalar value with the sampling frequency
%       (default=50Hz).
%
%   OUTPUT
%   RCG is an M-by-1 vector containing the simulated
%      RIP ribcage signal.
%   ABD is an M-by-1 vector containing the simulated
%      RIP abdomen signal.
%   PPG is an M-by-1 vector containing the simulated
%      photoplethysmography signal.
%   SAT is an M-by-1 vector containing the simulated
%      blood oxygen saturation signal.
%
%   EXAMPLE
%   Fs=50;      %Sampling Frequency is 50 Hz
%   L=30*Fs;    %Desired segment length is 30 s
%   PHI=0.5;    %Desired phase between RCG and ABD is 90 degrees.
%   SNR=20;     %Desired SNR is 20 dB.
%	[RCG,ABD,PPG,SAT]=simulateBRE(L,PHI,SNR,Fs);
%
%   VERSION HISTORY
%   2014_10_21 - Updated help based on [1], and added input parameters (CARR).
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

    if ~exist('SNR','var') | isempty(SNR)
        SNR=13;
    end
    if ~exist('Fs','var') | isempty(Fs)
        Fs=50;
    end

    Ndisc=10000;            %Samples to discard when generating AR processes
    N=round(2*L/(0.75*Fs));	%Approx number of breaths needed for a length of L
    
    %% Load Model Parameters
    load('breathModels.mat');
    load('AR_params.mat');

    %% RIP
    %Generate length noise
    lennoise=normrnd(0,sqrt(noiseVar.elrc),Ndisc+N,1);

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
    rcnoise=rcnoise.*sqrt(1/noipwr);
    rcnoise=rcnoise.*sqrt(simpwrrc/(10^(SNR/10)));
    rcnoipwr=rcnoise'*rcnoise/Nix_rc;
    abnoise=whitnab+pinknab;
    noipwr=abnoise'*abnoise/Nix_ab;
    abnoise=abnoise.*sqrt(1/noipwr);
    abnoise=abnoise.*sqrt(simpwrab/(10^(SNR/10)));
    abnoipwr=abnoise'*abnoise/Nix_ab;

    %Add noise
    rc=rcclean+rcnoise;
    ab=abclean+abnoise;

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

    %% PPG and SAT
    PPG=zeros(size(RCG));
    SAT=zeros(size(RCG));
end