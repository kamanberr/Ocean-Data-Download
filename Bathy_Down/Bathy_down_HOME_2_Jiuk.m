%% Load Bathymetry data from various Sources
%   [2024.10.01] written by Jiuk Hwang
%   [2024.10.03] Modify : ETOPO 1, 2 download link 
%                Debugging : GEBCO, ETOPO 2022 - extract range
%   [2024.10.03] Delete section for ETOPO 1, 2, 5 and GEBCO 2019

%% ETOPO 2022 - 30 arc / 60 arc
clc; clear;

% [lat start, lat end, lon start, lon end]
Spatial_area = [22, 54, 118, 144]; 

% resolution : 30 arc / 60 arc
resolution = 60;

% file path where you want to save the data
fpath = "C:\Users\Jiuk Hwang\OneDrive\문서\MATLAB\2024_showBathy";

func_ETOPO2022_down_Jiuk(Spatial_area, resolution, fpath)

%% SRTM 15+
clc; clear;

% [lat start, lat end, lon start, lon end]
% Limit : -90~90, -180~180
Spatial_area = [22, 54, 118, 144]; 

% file format you want : csv / nc / mat / pdf / png / largePng / graph 
format = 'mat';

% Please be patient. 
% It may take a while to get the data due to high resolution of SRTM 15.
func_SRTM15_down_Jiuk(Spatial_area, format)

