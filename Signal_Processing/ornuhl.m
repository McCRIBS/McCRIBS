function [x,y] = ornuhl(t,sigma,c,mu,x0)
%ORNUHL Simulates a one-dimensional Ornstein-Uhlenbeck
%   process using normally distributed based on two
%   different approaches.
%   [x,y] = ornuhl(t,sigma,c,mu,x0)
%
%   INPUT
%	t is an N-by-1 vector with the time samples; that
%       is, t=(0 1dt 2dt 3dt ... Ndt)';
%	sigma is a scalar value with the variance parameter
%       (strength of noise).
%	c is a scalar value with the drift velocity
%       parameter.
%	mu is a scalar value with the long-run mean
%       parameter.
%	x0 is a scalar value with the initial location
%       parameter.
%
%   OUTPUT
%   x is an N-by-1 vector with a simulated Ornstein-
%       Uhlenbeck process.
%
%   EXAMPLE
%   x=ornuhl(t,sigma,c,mu,x0);      %Uses a direct method
%   [x,y]=ornuhl(t,sigma,c,mu,x0);	%Computes y using the MATLAB filter function
%
%   VERSION HISTORY
%   2015_04_08 - Improved help based on [1], and removed 'state' option (Carlos A. Robles-Rubio).
%   Original - Created from code probably developed by Alexis Motto.
%
%   REFERENCES
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%
%Copyright (c) 2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    [nr,nc]=size(t);

    dt=t(2)-t(1); % time step

    if (nargin < 6)
        state = 37;
        if (nargin < 5)
            x0 = 0;
            if (nargin < 4)
                mu = 0;
            end
        end
    end

    dW = zeros(nr,1);
    x = zeros(nr,nc);

    %Method 1 (direct method)
    dW = sqrt(dt)*randn(nr,1);
    x = x0*exp(-c*t)+(1-exp(-c*t))*mu+sigma*exp(-c*t).*cumsum(exp(c*t).*dW);

    %Method 2 (Using the Matlab function filter)
    if (nargout > 1)
        y_free = sigma*cumsum(dW)+x0;
        y_filt = filter([0 c*dt], [1 -1+c*dt], y_free-mu);
        y = y_free-y_filt;
    end

    if (nargout == 0)
        plot(t,x);
        title('Ornstein-Uhlenbeck process path');
    end
end