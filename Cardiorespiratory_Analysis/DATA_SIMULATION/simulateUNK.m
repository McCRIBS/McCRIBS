function [RCG,ABD,PPG,SAT] = simulateUNK(L,RHO)
%SIMULATEUNK Simulation of the state Unknown
%	in RIP Signals
%	[RCG,ABD,PPG,SAT] = simulateUNK(L,RHO)
%       returns a simulated RIP unknown segment.
%
%	INPUT
%   L is a scalar value indicating the length
%       in samples of the simulated segment.
%   RHO is a scalar value with the scaling of
%       the additive noise.
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
%   L=30*Fs;            %Simulate 30s of UNK
%   RHO=unifrnd(0,1);	%A random amplitude in the range [0,1]
%   [RCG,ABD,PPG,SAT]=simulateUNK(L,RHO);
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

    PAU=1;
    ASB=2;
    MVT=3;
    SYB=4;

    typeRCG=unidrnd(4);
    inRCGorABD=unidrnd(3);	%1: RCG, 2: ABD, 3: Both
    typeUNK=unidrnd(3);

    switch typeUNK
        case 1  %Absent data
            noiRCG=normrnd(0,1,L,1).*RHO;
            noiABD=normrnd(0,1,L,1).*RHO;
            switch inRCGorABD
                case 1  %In RCG
                    switch typeRCG
                        case 1  %PAU segment
                            [auxRCG,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                        case 2  %ASB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                        case 3  %MVT segment
                            [auxRCG,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                        case 4  %SYB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    end
                    auxRCG=auxRCG.*0+noiRCG;
                case 2  %In ABD
                    switch typeRCG
                        case 1  %PAU segment
                            [auxRCG,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                        case 2  %ASB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                        case 3  %MVT segment
                            [auxRCG,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                        case 4  %SYB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    end
                    auxABD=auxABD.*0+noiABD;
                case 3  %In both
                    switch typeRCG
                        case 1  %PAU segment
                            [auxRCG,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                        case 2  %ASB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                        case 3  %MVT segment
                            [auxRCG,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                        case 4  %SYB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    end
                    auxRCG=auxRCG.*0+noiRCG;
                    auxABD=auxABD.*0+noiABD;
            end
        case 2  %Low SNR
            SNR=unifrnd(0.1,0.5);   %As a unitless ratio (not in dB)
            switch inRCGorABD
                case 1  %In RCG
                    switch typeRCG
                        case 1  %PAU segment
                            [auxRCG,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                            SNR=SNR./10;
                        case 2  %ASB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                        case 3  %MVT segment
                            [auxRCG,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                        case 4  %SYB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    end
                    sigPwr=auxRCG'*auxRCG;
                    noiRCG=normrnd(0,1,L,1);
                    noiPwr=noiRCG'*noiRCG;
                    noiRCG=noiRCG.*sqrt(sigPwr/(noiPwr*SNR));
                    auxRCG=(auxRCG+noiRCG)./2;
                case 2  %In ABD
                    switch typeRCG
                        case 1  %PAU segment
                            [auxRCG,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                            SNR=SNR./10;
                        case 2  %ASB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                        case 3  %MVT segment
                            [auxRCG,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                        case 4  %SYB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    end
                    sigPwr=auxABD'*auxABD;
                    noiABD=normrnd(0,1,L,1);
                    noiPwr=noiABD'*noiABD;
                    noiABD=noiABD.*sqrt(sigPwr/(noiPwr*SNR));
                    auxABD=(auxABD+noiABD)./2;
                case 3  %In both
                    switch typeRCG
                        case 1  %PAU segment
                            [auxRCG,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                            SNR=SNR./10;
                        case 2  %ASB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                        case 3  %MVT segment
                            [auxRCG,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                        case 4  %SYB segment
                            [auxRCG,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    end
                    sigPwr=auxRCG'*auxRCG;
                    noiRCG=normrnd(0,1,L,1);
                    noiPwr=noiRCG'*noiRCG;
                    noiRCG=noiRCG.*sqrt(sigPwr/(noiPwr*SNR));
                    auxRCG=(auxRCG+noiRCG)./2;

                    sigPwr=auxABD'*auxABD;
                    noiABD=normrnd(0,1,L,1);
                    noiPwr=noiABD'*noiABD;
                    noiABD=noiABD.*sqrt(sigPwr/(noiPwr*SNR));
                    auxABD=(auxABD+noiABD)./2;
            end
        case 3  %Different event types in RCG and ABD
            switch typeRCG
                case 1  %PAU segment
                    [auxRCG,~]=simulatePAU(L,unifrnd(0,0.1));
                    typeABD=randsample([MVT;SYB],1);
                case 2  %ASB segment
                    [auxRCG,~]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                    typeABD=randsample([PAU;MVT],1);
                case 3  %MVT segment
                    [auxRCG,~]=simulateMVT(L,unifrnd(0.5,1.5),1);
                    typeABD=randsample([PAU;SYB],1);
                case 4  %SYB segment
                    [auxRCG,~]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
                    typeABD=randsample([PAU;MVT],1);
            end
            switch typeABD
                case 1  %PAU segment
                    [~,auxABD]=simulatePAU(L,unifrnd(0,0.1));
                case 2  %ASB segment
                    [~,auxABD]=simulateBRE(L,unifrnd(0.5,1).*sign(unifrnd(-1,1)));
                case 3  %MVT segment
                    [~,auxABD]=simulateMVT(L,unifrnd(0.5,1.5),1);
                case 4  %SYB segment
                    [~,auxABD]=simulateBRE(L,unifrnd(0,0.5).*sign(unifrnd(-1,1)));
            end
    end

    RCG=auxRCG;
    ABD=auxABD;

    %PPG and SAT
    PPG=zeros(size(RCG));
    SAT=zeros(size(RCG));
end