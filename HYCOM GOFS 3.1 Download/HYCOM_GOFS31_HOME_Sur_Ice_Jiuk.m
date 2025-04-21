%% DOWNLOAD HYCOM - Global Ocean Forecasting System (GOFS) 3.1 Sur & Ice product
%   [2025.04.20] Written    by Jiuk Hwang
%
%   < Analysis_Sur >
%       GOFS3.1 Analysis    - GLBy0.08/expt_93.0/sur
%       Period: 2018-09-11 12:00:00 ~ 2024-09-05 09:00:00 (1 hourly)
%
%   < Analysis_Ice >
%       GOFS3.1 Analysis    - GLBy0.08/expt_93.0/ice
%       Period: 2018-09-11 12:00:00 ~ 2024-09-05 09:00:00 (3 hourly)
%
%   < Reanalysis_Ice >
%       GOFS3.1 Reanalysis  - GLBv0.08/expt_53.X_ice
%       Period: 1994 ~ 2015 (3 hourly)
%
% -------------------------------------------------------------------------
% If there is a bug or you are debugging, please contact the e-mail below.
% e-mail : hwangjiuk34@gmail.com

% =========================================================================
%% < Analysis_Sur >
%       GOFS3.1 Analysis    - GLBy0.08/expt_93.0/sur
%       Period: 2018-09-11 12:00:00 ~ 2024-09-05 09:00:00 (1 hourly)
%
% [ Variables ]
%   qtot          - surf. heat flux (unit: w/m2)
%   emp           - water_flux_into_ocean (unit: kg/m2/s)
%   steric_ssh    - sea_surface_elevation (unit: meters)
%   ssh           - steric SSH (unit: meters)
%   u_bt          - barotropic_eastward_sea_water_velocity (unit: m/s)
%   v_bt          - barotropic_northward_sea_water_velocity (unit: m/s)
%   sblt          - surface boundary layer thickness (unit: meters)
%                      The surface boundary layer thickness (which is distinct from mixed layer thickness)
%                      is the depth range over which turbulent boundary layer eddies can penetrate
%                      before becoming stable relative to the local buoyancy and velocity.
%                      It is estimated as the minimum depth at which Ri_b exceeds the critical value Ri_c=0.3
%                          - https://www.hycom.org/attachments/067_kpp.pdf
%   mld           - ocean_mixed_layer_thickness (unit: meters)

clc; clear; close all;

VariableData = {"qtot", "emp", "steric_ssh", "ssh", "u_bt", "v_bt", "sblt", "mld"};
% Default: {"qtot", "emp", "steric_ssh", "ssh", "u_bt", "v_bt", "sblt", "mld"}

% Time Step : e.g. 1 hour or more =========================================
timestep = 3; % default is 1 hour

% Starting time (YY,MM,DD,hh,mm,ss) and Ending time (YY,MM,DD,hh,mm,ss) ===
Period = [2019, 12, 31, 21, 00, 00 ; 2020, 01, 2, 03, 00, 00];

% [lat start, lat end, lon start, lon end] ================================
% [S, N, W, E] - unit: -80 to 90 (N), 0 to 360 (E)
Spatial_area = [34, 35, 124, 125];

% If you want "coarse" resolution, change the step of lon & lat grid. =====
% Note that, Units of 'lat_step' and 'lon_step' are not "km",
%   just "number of grid point interval".
lat_step = 1; % default is 1 grid step.
lon_step = 1; % default is 1 grid step.

% you will save data in this file path below.  ============================
HomeFolderNm = "D:\MATLAB_JU\RawData\";
RawDataFolderNm = "HYC_Sur_test";

% mat files will be save with this name below. ============================
% DO NOT USE UNDERBAR("_") IN "MatFileNm"
% → e.g) "hyc_hello" → Don't use "_" !!!
MatFileNm = "HycSur"; % you will save data with this file name

HYCOM_GOFS31_Func_Sur_Jiuk(Period, timestep, Spatial_area, lat_step, lon_step, ...
    VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, "Analysis_Sur")

% =========================================================================
%% < GOFS3.1 Ice product >
%       1. GOFS3.1 Analysis    - GLBy0.08/expt_93.0/ice
%           Period: 2018-09-11 12:00:00 ~ 2024-09-05 09:00:00 (3 hourly)
%
%       2. GOFS3.1 Reanalysis  - GLBv0.08/expt_53.X_ice
%           Period: 1994 ~ 2015 (1 hourly)
%
% [ Variables ]
%   sst     - sea surface temperature (unit: degC)
%   sss     - sea surface salinity (unit: psu)
%   ssu     - eastward_sea_water_velocity (unit: m/s)
%   ssv     - northward_sea_water_velocity (unit: m/s)
%   sic     - sea_ice_area_fraction (unit: 1)
%   sih     - sea_ice_thickness (unit: m)
%   siu     - eastward_sea_ice_velocity (unit: m/s)
%   siv     - northward_sea_ice_velocity (unit: m/s)
%   surtx   - surface_downward_eastward_stress (unit: Pa)
%   surty   - surface_downward_northward_stress (unit: Pa)

clc; clear; close all;

VariableData = {"sst", "sss", "ssu", "ssv", "sic", "sih", "siu", "siv", "surtx", "surty"};
% Default: {"sst", "sss", "ssu", "ssv", "sic", "sih", "siu", "siv", "surtx", "surty"}

% Time Step : e.g. 3*N hours (N is integer) ===============================
timestep = 3; % Analysis default is 3 hours / Reanalysis default is 1 hour

% "Analysis_ice" or "Reanalysis_ice"
HYC_ver = "Reanalysis_ice";

% Starting time (YY,MM,DD,hh,mm,ss) and Ending time (YY,MM,DD,hh,mm,ss) ===
Period = [2013, 12, 31, 21, 00, 00 ; 2014, 01, 2, 03, 00, 00];

% [lat start, lat end, lon start, lon end] ================================
% [S, N, W, E] - unit: -80 to 90 (N), 0 to 360 (E)
Spatial_area = [34, 35, 124, 125];

% If you want "coarse" resolution, change the step of lon & lat grid. =====
% Note that, Units of 'lat_step' and 'lon_step' are not "km",
%   just "number of grid point interval".
lat_step = 1; % default is 1 grid step.
lon_step = 1; % default is 1 grid step.

% you will save data in this file path below.  ============================
HomeFolderNm = "D:\MATLAB_JU\RawData\";
RawDataFolderNm = "HYC_Ice_test";

% mat files will be save with this name below. ============================
% DO NOT USE UNDERBAR("_") IN "MatFileNm"
% → e.g) "hyc_hello" → Don't use "_" !!!
MatFileNm = "HycIce"; % you will save data with this file name

HYCOM_GOFS31_Func_Ice_Jiuk(Period, timestep, Spatial_area, lat_step, lon_step, ...
    VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, HYC_ver)

% =========================================================================

