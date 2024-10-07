%% GHRSST Download 
%   written by Jiuk Hwang
%   LOG
%       [2024.10.03] Draft done.
%       [2024.10.05] Modify url adress.
%
%% OSTIA & MUR 
%
% [1] OSTIA GDS2 (OSTIA Analysis in CMEMS)  | OSTIA-UKMO-L4-GLOB-v2.0
%   Link : https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-v2.0
%   Spatial     Resolution  : 0.05° 
%   Temporal    Resolution  : Daily
%   Available   Period      : 2007-Jan-01 to Present
%--------------------------------------------------------------------------
% [2] OSTIA Reprocessed                     | OSTIA-UKMO-L4-GLOB-REP-v2.0
%   Link : https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-REP-v2.0
%   Spatial     Resolution  : 0.05° 
%   Temporal    Resolution  : Daily
%   Available   Period      : 1982-Jan-01 to 2022-Jun-01
%--------------------------------------------------------------------------
% [3] MUR SST Analysis 4.1                  | MUR-JPL-L4-GLOB-v4.1
%   Link : https://podaac.jpl.nasa.gov/dataset/MUR-JPL-L4-GLOB-v4.1
%   Spatial     Resolution  : 0.01° 
%   Temporal    Resolution  : Daily
%   Available   Period      : 2002-Jun-01 to present
%--------------------------------------------------------------------------
% [4] MUR SST Analysis 4.2                  | MUR25-JPL-L4-GLOB-v04.2
%   Link : https://podaac.jpl.nasa.gov/dataset/MUR25-JPL-L4-GLOB-v04.2
%   Spatial     Resolution  : 0.25° 
%   Temporal    Resolution  : Daily
%   Available   Period      : 2002-Sep-01 to Present
%--------------------------------------------------------------------------
clc; clear;

% OSITA v2 / OSTIA rep / MUR 4.1 / MUR 4.2
source = 'OSTIA v2';

period = [2012, 1, 1; 2023, 12, 31];
Spatial_area = [24, 35, 121, 132];

% If the downloaded file has the SAME NAME, INCREASE the value of lag_time
lag_time = 3; % seconds between download each files

func_podaac_down_Jiuk(source, period, Spatial_area, lag_time)

%% Extract Missing date during download process + Retry running
%   [2024.10.07] Written by Yunji Noh
%   This section is for the case of "OSTIA v2". 
%   It may need additional modification for other sources.

dateRange = datetime(period(1,:)):datetime(period(2,:));
% change folder path with your PC environment -----------------------------
files = dir('C:\Users\User\Downloads\*.nc4');
% -------------------------------------------------------------------------
fileDates = [];
for i = 1:length(files)
    fileName = files(i).name;
    fileDateStr = fileName(1:8);
    fileDate = datetime(fileDateStr, 'InputFormat', 'yyyyMMdd');
    fileDates = [fileDates; fileDate];
end
missingDates = setdiff(dateRange, fileDates);

for i=1:length(missingDates)
    date=datevec(missingDates(i));
    period_missing=[date(:,1:3); date(:,1:3)];
    func_podaac_down_Jiuk(source, period_missing, Spatial_area, lag_time)
end

% =========================================================================
%% OISST v2
%   Spatial     Resolution  : 0.25° 
%   Temporal    Resolution  : Daily
%   Available   Period      : 1981-09       ~ present

clc; clear; 

% Write the Project Name (for the Folder name and Mat file name)
Project_Name = "OISST";

% Write the FilePath that you want to save data
HOME_folder_path = "C:\Users\MATLAB\DATA_download\GHRSST_down";

% Set the Period : [Start year, Start month ; End year, End month]
%   OISST v2  : 1981-09       ~ present
Period = [2014, 1, 1; 2014, 1, 5];

% Set tha Area
% [lat start, lat end, lon start, lon end]
Spatial_area = [24, 35, 121, 132];

func_OISST_down_Jiuk(Project_Name, HOME_folder_path, Period, Spatial_area)