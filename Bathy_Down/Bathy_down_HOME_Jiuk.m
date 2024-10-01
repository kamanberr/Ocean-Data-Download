%% Load Bathymetry data from various Sources
%   [2024.10.01] written by Jiuk Hwang

%% ETOPO 2022 - 30 arc / 60 arc
clc; clear;

% [lat start, lat end, lon start, lon end]
Spatial_area = [22, 23, 118, 119]; 

% resolution : 30 arc / 60 arc
resolution = 60;

% file path where you want to save the data
fpath = "C:\Users\Jiuk Hwang\OneDrive\문서\MATLAB\DATA_download\OSTIA_down";

func_ETOPO2022_down_Jiuk(Spatial_area, resolution, fpath)

%% SRTM 15+
clc; clear;

% [lat start, lat end, lon start, lon end]
% Limit : -90~90, -180~180
Spatial_area = [22.5, 23, 118.5, 119];  

% file format you want : csv / nc / mat / pdf / png / largePng / graph 
format = 'mat';

% Please be patient. 
% It may take a while to get the data due to high resolution of SRTM 15.
func_SRTM15_down_Jiuk(Spatial_area, format)

%% ETOPO 1 / ETOPO 2 / ETOPO 5
clc; clear;

% ETOPO 1 / ETOPO 2 / ETOPO 5
version = 1;

% [lat start, lat end, lon start, lon end]
% Limit : -90~90, -180~180
Spatial_area = [22, 23, 117, 119];  

% file format you want : csv / nc / mat / pdf / png / largePng / graph
format = 'mat';

func_ETOPO_125_down_Jiuk(version, Spatial_area, format)

%% GEBCO 2019
%   You can download the latest version of GEBCO data from below Link
%   LINK : https://download.gebco.net/
clc; clear;

% [lat start, lat end, lon start, lon end]
Spatial_area = [22, 23, 117, 119];  

% file path where you want to save the data
fpath = "C:\Users\Jiuk Hwang\OneDrive\문서\MATLAB\DATA_download\OSTIA_down";

func_GEBCO2019_down_Jiuk(Spatial_area, fpath)