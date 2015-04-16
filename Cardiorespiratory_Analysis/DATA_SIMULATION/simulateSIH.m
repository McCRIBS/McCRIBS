function [RCG,ABD,PPG,SAT] = simulateSIH(RHO)
%SIMULATESIH Simulation of sighs in RIP Signals
%   [RCG,ABD,PPG,SAT] = simulateSIH(RHO)
%       returns a simulated sigh.
%
%   INPUT
%	RHO is a scalar value with the scaling factor for
%       the sigh amplitude.
%
%   OUTPUT
%   RCG is an M-by-1 vector containing the simulated
%       ribcage signal.
%   ABD is an M-by-1 vector containing the simulated
%       abdomen signal.
%   PPG is an M-by-1 vector containing the simulated
%       photoplethysmography signal.
%   SAT is an M-by-1 vector containing the simulated
%       blood oxygen saturation signal.
%
%   EXAMPLE
%   %Simulate a sigh with an amplitude RHO larger than that of a normal breath
%   RHO=2.5;
%   [RCG,ABD,PPG,SAT]=simulateSIH(RHO);
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

    Ndisc=10000; %Samples to discard
    N=1;
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
    heiAR=exp(heiAR(Ndisc+1:end)).*RHO;

    %Generate traces
    rcclean=[];
    abclean=[];

    for index=1:N
        auxrc=myIRFrcUSE(1:round(lenAR(index)),round(lenAR(index))).*heiAR(index);
        auxab=myIRFabUSE(1:round(lenAR(index)),round(lenAR(index))).*heiAR(index);
        auxsum=sum(auxrc)+sum(auxab);
        if auxsum>0
            auxSamp1=[1:1:length(auxrc)]';
            auxSamp2=[1:1:(length(auxrc)*2)]'./2;
            auxrc=spline(auxSamp1,auxrc,auxSamp2);
            auxab=spline(auxSamp1,auxab,auxSamp2);

            rcclean=[rcclean;auxrc];
            abclean=[abclean;auxab];
        end
    end

    if length(rcclean)>0
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
        rc=rcclean+rcnoise;
        ab=abclean+abnoise;

        %Zero-mean
        RCG=rc-mean(rc);
        ABD=ab-mean(ab);
    else
        RCG=zeros(0,1);
        ABD=zeros(0,1);
    end

    %PPG and SAT
    PPG=zeros(size(RCG));
    SAT=zeros(size(RCG));

end