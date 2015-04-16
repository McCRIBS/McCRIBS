function [BreathPeaksTroughs] = breathSegmentation(X,Nba,Nbn,Fs,ShowMsgs)
%BREATHSEGMENTATION Performs breath segmentation of RIP signals
%	[BreathPeaksTroughs] = breathSegmentation(X,Nba,Nbn,Fs,ShowMsgs)
%       returns the time occurrence of Peaks and
%       Troughs of each breath in X.
%
%   INPUT
%   X is an N-by-1 vector with either a ribcage or
%       an abdominal RIP signal (preferably from a
%       SYB or ASB segment only).
%   Nba is a scalar value with the length (in sample
%       points) of the moving-average sliding window.
%   Nbn is a scalar value with the length (in sample
%       points) of the sliding window for noise
%       reduction (Nbn << Nba).
%   Fs is a scalar value with the sampling frequency
%       (default = 50 Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output.
%
%   OUTPUT
%   BreathPeaksTroughs is an M-by-2 vector containing
%       the Peaks and Troughs information. Col1 is the
%       occurrence time, and Col2 is the type (0: Trough,
%       1: Peak).
%
%   EXAMPLE
%   Fs=50;
%   Nba=251;
%   Nbn=5;
%   BreathPeaksTroughs=breathSegmentation(RCG,Nba,Nbn,Fs,false);
%   %Plot RCG and mark Peaks and Troughs
%   figure
%   plot((1:1:size(RCG,1))'./Fs,RCG,'Color',signalColor('RCG'));
%   hold on;
%   ixPeak=BreathPeaksTroughs(:,2)==1;
%   ixTrou=BreathPeaksTroughs(:,2)==0;
%   plot(BreathPeaksTroughs(ixPeak,1)./Fs,RCG(BreathPeaksTroughs(ixPeak)),'dr','LineWidth',2);
%   plot(BreathPeaksTroughs(ixTrou,1)./Fs,RCG(BreathPeaksTroughs(ixTrou)),'ob','LineWidth',2);
%   hold off;
%   xlabel('Time (s)');
%   ylabel('Amplitude (a.u.)');
%
%   VERSION HISTORY
%   2014_10_28 - Improved help (CARR).
%   2011_09_30 - Created by: Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Detection of Breathing Segments in Respiratory Signals,"
%       in Conf. Proc. 34th IEEE Eng. Med. Biol. Soc.,
%       San Diego, USA, 2012, pp. 6333-6336.
%
%
%Copyright (c) 2011-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs') | isempty(ShowMsgs)
        ShowMsgs=false;
    end

    b1=ones(Nba,1)./Nba;
    b2=ones(Nbn,1)./Nbn;
    Xba=filter2S(b1,X);
    Xbn=filter2S(b2,X);

    Xbin=double(Xbn>Xba);

    segments=signal2events(Xbin);

    keyPoints=zeros(size(segments,1),2);
    for index=1:size(keyPoints,1)
        segmIdx=[segments(index,1):segments(index,2)]';
        if(segments(index,3)==0)
            [~,aux]=min(Xbn(segmIdx));
        else
            [~,aux]=max(Xbn(segmIdx));
        end
        keyPoints(index,:)=[segmIdx(aux) segments(index,3)];
    end

    BreathPeaksTroughs=keyPoints;

end