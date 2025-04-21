%% DOWNLOAD HYCOM - Global Ocean Forecasting System (GOFS) 3.1 output
%   [2024.03.04] Written    by Jiuk Hwang 
%   [2024.03.04] Modified   by Jiuk Hwang 
%   [2024.03.29] Modified   by Jiuk Hwang 
%   [2024.07.25] Updated    by Jiuk Hwang
%   [2024.09.10] Modified   by Yunji Noh 
%   [2024.09.19] Modified   by Jiuk Hwang
%   [2024.09.23] Modified   by Jiuk Hwang
%   [2024.10.02] Modified   by Jiuk Hwang
%   [2025.04.20] Updated    by Jiuk Hwang
%
% WARNING =================================================================
% 1. Analysis and Reanalysis have different periods of data.
%    Please make sure to check the period and download appropriate data.
% 2. The size of the Spatial Resolution grid changes around 2019.
% -------------------------------------------------------------------------
% [ Analysis ]                  (2014-07-01 12:00:00 ~ 2024-09-04 [Retrievd on 2025.03.30] )
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

%% Download HYCOM - T, S, SSH, U, V
% Notes ===================================================================
% Variables : temp[°C],  sal[psu],  ssh[m],  uv[m/s]
% Temporal resolution : (at least) 3 hours
% -------------------------------------------------------------------------

clc; clear; close all;
tic % start to count time 

% Starting time (YY,MM,DD,hh,mm,ss) and Ending time (YY,MM,DD,hh,mm,ss) ===
Period = [2023, 07, 20, 00, 00, 00 ; 2023, 07, 31, 23, 00, 00];

% Time Step : e.g. 3*N hours (N is integer) ===============================
timestep = 3; % default is 3 hours

% 'Analysis' or 'Reanalysis' (Be careful with the date range!) ============
HYC_ver = 'Analysis';

% [lat start, lat end, lon start, lon end] ================================
% [S, N, W, E] - unit: -80 to 90 (N), 0 to 360 (E)
Spatial_area = [34, 35, 124, 125];

% If you want "coarse" resolution, change the step of lon & lat grid. =====
% Note that, Units of 'lat_step' and 'lon_step' are not "km", 
%   just "number of grid point interval".
lat_step = 1; % default is 1 grid step.
lon_step = 1; % default is 1 grid step. 

% [shallow depth ; deep depth]  - unit : meters ===========================
% with Vertical Levels ( depth ) : 0 2 4 6 8 10 12 15 20 25 30 35 40 45 50 
%           60 70 80 90 100 125 150 200 250 300 350 400 500 600 700 800 900 
%           1000 1250 1500 2000 2500 3000 4000 5000 (meters)
Depth_range = [0 ; 500];

% select from {'temp', 'sal', 'ssh', 'u', 'v'};  ==========================
VariableData = {'temp', 'sal', 'ssh', 'u', 'v'};

% you will save data in this file path below.  ============================
HomeFolderNm = "D:\MATLAB_JU\RawData\";
RawDataFolderNm = "HYC_test";

% mat files will be save with this name below. ============================
% DO NOT USE UNDERBAR("_") IN "MatFileNm" 
% → e.g) "hyc_hello" → Don't use "_" !!!
MatFileNm = "hyc"; % you will save data with this file name

% function execution  =====================================================
HYCOM_GOFS31_Func_standard_Jiuk_3(Period, timestep, Spatial_area, lat_step, lon_step, Depth_range, ...
    VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, HYC_ver)

toc % display download time
