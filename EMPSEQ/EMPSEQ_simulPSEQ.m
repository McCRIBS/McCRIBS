function [Tau_sim_hat] = EMPSEQ_simulPSEQ(Tau_sim,ConfMat_sim)
%EMPSEQ_simulPSEQ simulates a Pattern SEQuence (PSEQ).
%
%   REFERENCES
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
%   [2] C. A. Robles-Rubio, K. A. Brown, R. E. Kearney,
%       "Optimal Classification of Respiratory Patterns
%       from Manual Analyses Using Expectation-Maximization,"
%       IEEE J Biomed Health Inform, In Press, 2017.
%
%   LICENSE
%   Copyright (c) 2017, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney,
%   McGill University
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without modification,
%   are permitted provided that the following conditions are met:
%
%   1. Redistributions of source code must retain the above copyright notice,
%      this list of conditions and the following disclaimer.
% 
%   2. Redistributions in binary form must reproduce the above copyright notice,
%      this list of conditions and the following disclaimer in the documentation
%      and/or other materials provided with the distribution.
% 
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
%   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
%   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
%   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
%   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
%   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
%   TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
%   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   SEE ALSO
%   EMPSEQ, EMPSEQ_simulConfMat

    numPatts=size(ConfMat_sim,1);
    
    Tau_sim_hat=nan(size(Tau_sim));
    
    for tau=1:numPatts
        %Select samples where the true pattern is 'tau'
        ixThisTruePatt=(Tau_sim==tau);
        numThisTruePatt=sum(ixThisTruePatt);

        for k=1:numPatts-1
            if length(find(ixThisTruePatt==1))>=round(ConfMat_sim(k,tau)*numThisTruePatt)
                myIxs=randsample(find(ixThisTruePatt==1),round(ConfMat_sim(k,tau)*numThisTruePatt),false);
            else
                myIxs=find(ixThisTruePatt==1);
            end
            ixThisTruePatt(myIxs)=0;
            Tau_sim_hat(myIxs)=k;

            clear myIxs
        end
        Tau_sim_hat(ixThisTruePatt)=numPatts;

        clear ixThisTrueCat numThisTrueCat
    end
end