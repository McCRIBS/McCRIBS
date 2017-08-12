function [ConfMat_sim] = EMPSEQ_simulConfMat(ConfMat,betamix_params)
%EMPSEQ_simulConfMat simulates a confusion matrix.
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
%   EMPSEQ, EMPSEQ_simulPSEQ

    numPatts=size(ConfMat,1);
    ConfMat_sim=nan(size(ConfMat));

    %For each pattern, tweak ConfMat
    for c=1:numPatts
        %Select which component of the mixture PDF to use
        whichPDF=binornd(1,1-betamix_params(c,1),1,1)+1;    %1: 1st component, 2: 2nd component
        
        %Set the PDF parameters
        if whichPDF==1      %Use the 1st beta PDF
            alph=betamix_params(c,2);
            beta=betamix_params(c,4);
        elseif whichPDF==2  %Use the 2nd beta PDF
            alph=betamix_params(c,3);
            beta=betamix_params(c,5);
        else
            error('Error at selecting the component PDF.');
        end
        
        %Get the new diagonal element
        newPD=betarnd(alph,beta,1,1);
        
        %Substitute with tweaked values
        ConfMat_sim(c,c)=newPD;
        auxix=ones(numPatts,1);
        auxix(c)=0;
        auxix=(auxix==1);
        ConfMat_sim(auxix,c)=ConfMat(auxix,c).*(1-newPD)/sum(ConfMat(auxix,c));
    end
end