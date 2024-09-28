%% DOWNLOAD HYCOM - Global Ocean Forecasting System (GOFS) 3.1 output
%   [2024.03.04] Written    by Jiuk Hwang 
%   [2024.03.04] Modified   by Jiuk Hwang 
%   [2024.03.29] Modified   by Jiuk Hwang 
%   [2024.07.25] Updated    by Jiuk Hwang
%   [2024.09.10] Modified   by Yunji Noh 
%   [2024.09.19] Modified   by Jiuk Hwang
%   [2024.09.23] Modified   by Jiuk Hwang
%
% WARNING =================================================================
% 1. Analysis and Reanalysis have different periods of data.
%    Please make sure to check the period and download appropriate data.
% 2. The size of the Spatial Resolution grid changes around 2019.
% -------------------------------------------------------------------------
% [ Analysis ]                              (2014-07-01 12:00:00 ~ Present)
% 2014~2018 : GLBv0.08
%             0.08 deg lon x 0.08 deg lat between 40S-40N. 
%             Poleward of 40S/40N, the grid is 0.08 deg lon x 0.04 deg lat.
% 2019~     : GLBy0.08
%             0.08 deg lon x 0.04 deg lat that covers 80S to 90N.
% -------------------------------------------------------------------------
% [ Reanalysis ]                (1994-01-01 12:00:00 ~ 2015-12-31 09:00:00)
% 0.08° resolution between 40°S and 40°N
% 0.04° poleward of 40°S and 40°N
% -------------------------------------------------------------------------
% If there is a bug or you are debugging, please contact the e-mail below.
% e-mail : hwangjiuk34@gmail.com

%% Download HYCOM 
% Notes ===================================================================
% Variables : temp[°C],  sal[psu],  ssh[m],  uv[m/s]
% Temporal resolution : (at least) 3 hours
% -------------------------------------------------------------------------

clc; clear; close all;
tic % start to count time 

% Starting time (YY,MM,DD,hh,mm,ss) and Ending time (YY,MM,DD,hh,mm,ss)
Period = [2019, 01, 01, 00, 00, 00 ; 2019, 12, 31, 21, 00, 00];

% Time Step : e.g. 3 or 12 hours
timestep = 3;

% 'Analysis' or 'Reanalysis' (Be careful with the date range!)
HYC_ver = 'Analysis';

% [lat start, lat end, lon start, lon end]
Spatial_area = [33, 54, 127, 143];

% [shallow depth ; deep depth]  - unit : meters
Depth_range = [0 ; 3800];

% select from {'temp', 'sal', 'ssh', 'u', 'v'};
VariableData = {'temp', 'sal', 'ssh', 'u', 'v'};

% you will save data in this file path below.
HomeFolderNm = "D:\MATLAB_JU\RawData\";
RawDataFolderNm = "HYC_JIUK_ES";

% mat files will be save with this name below.
% DO NOT USE UNDERBAR("_") IN "MatFileNm" 
% → e.g) "hyc_hello" → Don't use "_" !!!
MatFileNm = "hycES"; % you will save data with this file name

% function execution
HYCOM_31down_func_Jiuk_2(Period, timestep, Spatial_area, Depth_range, ...
    VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, HYC_ver)

toc % display download time
