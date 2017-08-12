function [Pi,Pi_0,Mu,theta,Patts,Delta,NumIters] = EMPSEQ(PSEQs,Pi_init,Epsilon,MaxIter,ShowMsgs)
%EMPSEQ gives the optimal consensus from multiple PSEQs.
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
%   EMPSEQ_simulPSEQ, EMPSEQ_simulConfMat

    if ~exist('Epsilon') | isempty(Epsilon)
        Epsilon=0;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    verbose([mfilename ': starting ...'],ShowMsgs);

    [N,R]=size(PSEQs);
    Patts=unique(PSEQs);
    K=length(Patts);
    
    for k=1:K
        PSEQs(PSEQs==Patts(k))=k;
    end
    
    Pi=nan(N,K);
    Mu=nan(K,K,R);
    theta=nan(K,1);
    
    Delta=nan(0,1);
    
%% Initialize
    verbose([char(9) 'initializing probability estimates ...'],ShowMsgs);
    if ~exist('Pi_init') | isempty(Pi_init)
        for k=1:K
            Pi(:,k)=mean(PSEQs==k,2);
        end
    else
        Pi=Pi_init;
    end
    Pi_0=Pi;
    verbose([char(9) 'initializing probability estimates ... done'],ShowMsgs);

    verbose([char(9) 'optimizing parameters ...'],ShowMsgs);
    %Iterate until MaxIter
    NumIters=0;
    while NumIters<MaxIter
        NumIters=NumIters+1;

        %% Parameter Estimation
        verbose([char(9) char(9) 'parameter estimation ...'],ShowMsgs);
        
        %Marginal class probabilities
        theta=mean(Pi)';
        
        %Confusion matrix of each PSEQ
        Mu=nan(K,K,R);
        for k=1:K
            for ks=1:K
                for j=1:R
                    Mu(ks,k,j)=sum(Pi(:,k).*(PSEQs(:,j)==ks));
                end
            end
            Mu(:,k,:)=Mu(:,k,:)./sum(Pi(:,k));
        end
        verbose([char(9) char(9) 'parameter estimation ... done'],ShowMsgs);

        %% Refine probability estimates based on confusion matrices
        verbose([char(9) char(9) 'refine probability estimates ...'],ShowMsgs);
        Pi_star=ones(N,K);
        for k=1:K
            Pi_star(:,k)=theta(k);
            for j=1:R
                Pi_star(:,k)=Pi_star(:,k).*Mu(PSEQs(:,j),k,j);
            end
        end
        
        Pi_new=Pi_star./(sum(Pi_star,2)*ones(1,K));
        
        %Check convergence
        [~,Tau_old]=max(Pi,[],2);
        [~,Tau_new]=max(Pi_new,[],2);
        Delta(NumIters)=mean(Tau_old~=Tau_new);
        
        Pi=Pi_new;
        clear Pi_new Pi_star
        verbose([char(9) char(9) 'refine probability estimates ... done'],ShowMsgs);
        
        verbose([char(9) char(9) 'iteration completion: ' num2str(floor((NumIters/MaxIter)*100)/100)],ShowMsgs);
        
        verbose('######################################',ShowMsgs);
        verbose(['Iteration ' num2str(NumIters) ' completed. Delta = ' num2str(Delta(NumIters)) ' '],ShowMsgs);
        verbose('######################################',ShowMsgs);
        verbose(' ',ShowMsgs);
        
        if Delta(NumIters)<=Epsilon
            verbose([char(9) char(9) 'converged at ' num2str(NumIters) ' iterations. Delta = ' num2str(round(Delta(NumIters)*100000)/100000)],ShowMsgs);
            break;
        end
    end
    verbose([char(9) 'optimizing parameters ... done'],ShowMsgs);
    
    verbose([mfilename ': finished'],ShowMsgs);
end