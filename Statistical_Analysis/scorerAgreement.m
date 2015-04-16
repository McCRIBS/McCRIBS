function [k,kj,kstd,kjstd,kcil,kcih,kjcil,kjcih,Nj] = scorerAgreement(REF,CMP,sampleBYsample,B,ALPHA,evtMinLen,evtMaxLen,pctEvt,ShowMsgs,cats,flagWaitBar)
%SCORERAGREEMENT Evaluation of agreement between scorers
%	[k,kj,kstd,kjstd,kcil,kcih,kjcil,kjcih,Nj] = scorerAgreement(REF,CMP,sampleBYsample,B,ALPHA,evtMinLen,evtMaxLen,pctEvt,ShowMsgs,cats,flagWaitBar)
%       returns the overall and category specific
%       agreement between REF and CMP.
%
%   INPUT
%   REF is an M-by-1 vector with the scores from
%       the reference scorer. Scores must be indicated
%       by the first P integers. Zero-valued samples
%       are excluded from the analysis.
%   CMP is an M-by-1 vector with the scores from
%       the comparison scorer. Scores must be indicated
%       by the first P integers. Zero-valued samples
%       are excluded from the analysis.
%   sampleBYsample is a binary flag indicating the
%       type of evaluation to be performed:
%         - 0: Event-by-event
%         - 1: Sample-by-sample
%   B is a scalar value with the number of bootstrap
%       resamples used to estimate the mean and
%       standard deviation of the kappa values.
%   ALPHA is a scalar value used to obtain
%       (1-ALPHA) confidence intervals.
%   evtMinLen is a scalar value with the minimum
%       length (in samples) of events included in
%       the evaluation.
%   evtMaxLen is a scalar value with the maximum
%       length (in samples) of events included in
%       the evaluation.
%   pctEvt is a scalar value used with Event-by-
%       event evaluation. It indicates the percentage
%       of samples needed to mark an event as detected.
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%   cats is a P-by-1 vector of integers with the
%       category labels.
%   flagWaitBar is a flag indicating if a waitbar
%       should be shown (default=false).
%
%   OUTPUT
%   k is a scalar value with the overall kappa
%       estimator.
%   kj is a P-by-1 vector with the category specific
%       kappa estimates.
%   kstd is a scalar value with the standard deviation
%       of the overall kappa estimator.
%   kjstd is a P-by-1 vector with the standard 
%       deviation of the category specific kappa
%       estimates.
%   kcil is a scalar value with the lower limit
%       of the (1-ALPHA) confidence interval
%       estimate of the overall kappa.
%   kcih is a scalar value with the upper limit
%       of the (1-ALPHA) confidence interval
%       estimate of the overall kappa.
%   kjcil is a P-by-1 vector with the lower limit
%       of the (1-ALPHA) confidence interval
%       estimates of the category specific kappa
%       values.
%   kjcih is a P-by-1 vector with the upper limit
%       of the (1-ALPHA) confidence interval
%       estimates of the category specific kappa
%       values.
%
%   EXAMPLE
%   [k,kj,kstd,kjstd,kcil,kcih,kjcil,kjcih,Nj]=scorerAgreement(REF,CMP,sampleBYsample,B,ALPHA,evtMinLen,evtMaxLen,pctEvt,ShowMsgs,cats,flagWaitBar);
%
%   VERSION HISTORY
%   2015_04_09 - Updated help based on [1] (CARR).
%   Original - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
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

    if ~exist('cats') | isempty(cats)
        cats=[1:max([unique(REF);unique(CMP)])]';
    end
    if ~exist('flagWaitBar') | isempty(flagWaitBar)
        flagWaitBar=false;
    end

    if flagWaitBar
        myWaitBar=waitbar(0,'Calculating results, please wait...');
    end

    aux_pre_base=REF;
    aux_pre_test=CMP;
    aux_pre_base(CMP==0)=0;
    aux_pre_test(REF==0)=0;

    maxCatVal=max(cats);

    aux=signal2events(aux_pre_base);
    base_evts=sortrows(aux(and(and((aux(:,2)-aux(:,1)+1)>=evtMinLen,(aux(:,2)-aux(:,1)+1)<=evtMaxLen),aux(:,3)>0),:),1);
    Nevts=size(base_evts,1);

    if sampleBYsample==0
        new_base=zeros(Nevts,1);
        new_test=zeros(Nevts,1);

        for index=1:Nevts
            new_base(index)=base_evts(index,3);

            segm=aux_pre_test(base_evts(index,1):base_evts(index,2));
            modecat=mode(segm);
            if mean(segm==modecat)>pctEvt
                new_test(index)=modecat;
            else
                new_test(index)=maxCatVal+1;
            end
        end

        pre_base=new_base;
        pre_test=new_test;
    else
        pre_base=[];
        pre_test=[];
        for index=1:size(base_evts,1)
            ixes=base_evts(index,1):base_evts(index,2);
            pre_base=[pre_base;aux_pre_base(ixes)];
            pre_test=[pre_test;aux_pre_test(ixes)];
            clear ixes
        end
    end

    P=length(cats);
    possibleP=max([pre_base;pre_test]);
    if P<possibleP
        P=possibleP;
    end

    base=pre_base;
    test=pre_test;
    N=length(base);             %Total samples used for evaluation
    aNj=histc(base,[cats-0.5;cats(end)+0.5]);
    Nj=aNj(1:end-1)';

    kB=zeros(B,1);
    kjB=zeros(B,P);

    %Sample-by-sample evaluation
    for bootindex=1:B
        ixBootSamp=randsample(N,N,true);
        auxbase=base(ixBootSamp);
        auxtest=test(ixBootSamp);

        X=zeros(N,P);
        for index=1:length(X)
            X(index,auxbase(index))=X(index,auxbase(index))+1;
            X(index,auxtest(index))=X(index,auxtest(index))+1;
        end
        [auxk,auxkj]=fleiss(X,0.01);
        kB(bootindex,1)=auxk;
        kjB(bootindex,:)=auxkj;

        if ShowMsgs && mod(bootindex,B/100)==0
            display(['Kappa Variance Bootstrap: ' num2str(round(bootindex*100/B)/100)]);
        end
        if flagWaitBar
            waitbar(bootindex/B);
        end
    end

    k=nanmean(kB,1);
    kstd=nanstd(kB,[],1);
    kj=nanmean(kjB(:,1:maxCatVal),1);
    kjstd=nanstd(kjB(:,1:maxCatVal),[],1);
    qaux=quantile(kB,[ALPHA/2 1-ALPHA/2],1);
    kcil=qaux(1);
    kcih=qaux(2);
    qjaux=quantile(kjB(:,1:maxCatVal),[ALPHA/2 1-ALPHA/2],1);
    kjcil=qjaux(1,:);
    kjcih=qjaux(2,:);

    if isnan(k)==1
        k=-inf;
    end
    if isnan(kstd)==1
        kstd=inf;
    end
    if isnan(kcil)==1
        kcil=-inf;
    end
    if isnan(kcih)==1
        kcih=inf;
    end
    kj(isnan(kj))=-inf;
    kjstd(isnan(kjstd))=inf;
    kjcil(isnan(kjcil))=-inf;
    kjcih(isnan(kjcih))=inf;

    if flagWaitBar
        close(myWaitBar);
    end
end