%% DOWNLOAD HYCOM - ESPC-D-V02: Global 1/12° Analysis output
%   [2025.04.21] Written    by Jiuk Hwang
%
% -------------------------------------------------------------------------
%   [ ESPC-D-V02: Global 1/12° Analysis (Aug-10-2024 to Present) ]
%   Link:       https://www.hycom.org/dataserver/espc-d-v02/global-analysis
%   Resolution: ESPC-D-V02 daily 1/25° (GLBz0.04) deterministic run
%                   decimated to the GLBy0.08 1/12° grid
%               GLBy0.08 grid: 0.08° lon x 0.04° lat that covers 80S to 90N.
%   Period:     2024-Aug-10 to Present
%   Input:      FNMOC NAVGEM, Satellite SSH, SST, SMMI, in situ observations
% -------------------------------------------------------------------------
%   [2d Variables 1-hourly]:
%       ice
%           sic = sea_ice_area_fraction
%           sih = sea_ice_thickness
%           siu = eastward_sea_ice_velocity
%           siv = northward_sea_ice_velocity
%           sss = sea_water_salinity
%           sst = sea_water_temperature
%           ssu = eastward_sea_water_velocity
%           ssv = northward_sea_water_velocity
%           surtx = surface_downward_eastward_stress
%           surty = surface_downward_northward_stress
%       ssh
%           surf_el = Water Surface Elevation
%       Sssh
%           steric_ssh = steric SSH
%
%   [3z Variables 3-hourly]: sal, temp, u, v
%       s3z
%           salinity = Salinity
%       t3z
%           water_temp = Water Temperature
%       u3z
%           water_u = Eastward Water Velocity
%       v3z
%           water_v = Northward Water Velocity
% -------------------------------------------------------------------------
% If there is a bug or you are debugging, please contact the e-mail below.
% e-mail : hwangjiuk34@gmail.com
% -------------------------------------------------------------------------

clc; clear; close all;

% Starting time (YY,MM,DD,hh,mm,ss) and Ending time (YY,MM,DD,hh,mm,ss) ===
%   Period: "2024-08-10 12:00:00" to Present
Period = [2024, 12, 31, 00, 00, 00 ; 2025, 01, 1, 23, 00, 00];

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



% Variables ===============================================================

% %   [example 1. All variables]
% VariableData = {'sic', 'sih', 'siu', 'siv', 'sss', 'sst', ...
%     'ssu', 'ssv', 'surtx', 'surty', ...
%     'ssh', 'sssh', ...
%     'sal', 'temp', 'u', 'v'};

% %   [example 2. Only 1-hourly 2d variables]
% VariableData = {'sic', 'sih', 'siu', 'siv', 'sss', 'sst', ...
%     'ssu', 'ssv', 'surtx', 'surty', 'ssh', 'sssh'};

% %   [example 3. Only 3-hourly 3d variables]
% VariableData = {'sal', 'temp', 'u', 'v'};

% %   [example 4. Frequently used variables]
VariableData = {'ssh', 'sal', 'temp', 'u', 'v'};



% Time Step : =============================================================
%   2d Variables: (default) 1-hourly → e.g. 1 hour or more.
%   3z Variables: (default) 3-hourly → e.g. 3*N hours (N is integer)
timestep = 3;

% you will save data in this file path below.  ============================
HomeFolderNm = "D:\MATLAB_JU\RawData\";
RawDataFolderNm = "HYC_ESPC_test6";

% mat files will be save with this name below. ============================
% DO NOT USE UNDERBAR("_") IN "MatFileNm"
% → e.g) "hyc_hello" → Don't use "_" !!!
MatFileNm = "hyc"; % you will save data with this file name

% -------------------------------------------------------------------------
HYCOM_ESPC_Func_Jiuk_1(Period, timestep, Spatial_area, lat_step, lon_step, ...
    Depth_range, VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, 'ESPC')
% -------------------------------------------------------------------------