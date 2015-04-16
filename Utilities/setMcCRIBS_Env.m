function [] = setMcCRIBS_Env(SourceCodeRoot,DataRoot)
%SETMCCRIBS_ENV Sets the MATLAB environment to work
%   with McCRIB software and data.
%	[] = setMcCRIBS_Env(SourceCodeRoot,DataRoot)
%       adds the functions in SourceCodeRoot to the
%       MATLAB path, and sets the environment variable
%       McCRIB_DATA_ROOT equal to DataRoot.
%
%   INPUT
%   SourceCodeRoot is a string with the path to the
%       McCRIB Software source code repository.
%   DataRoot is a string with the path to the main
%       data folder.
%
%   EXAMPLE
%   %Run this code before starting to work with McCRIB software and data
%	SourceCodeRoot='YOUR_PATH_TO_THE_SOURCE_CODE_REPOSITORY\McCRIBS';
%	DataRoot='YOUR_PATH_TO_THE_DATA_DIRECTORY\Data';
%	cd([SourceCodeRoot '\Utilities']);
%	setMcCRIBS_Env(SourceCodeRoot,DataRoot)
%	McCRIB_DATA_ROOT=getenv('McCRIB_DATA_ROOT');	%Use this line to get the environment variable defining the Data root directory.
%	cd(McCRIB_DATA_ROOT);
%
%   VERSION HISTORY
%   2015_04_09 - Updated help based on [1] (CARR).
%   Original - Created by Carlos A. Robles-Rubio (CARR).
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

    addpath(genpath(SourceCodeRoot),'-end');
    setenv('McCRIB_DATA_ROOT',DataRoot);
end