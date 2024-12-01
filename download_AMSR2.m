%% AMSR-2 Air-Sea Essential Climate Variables (AS-ECV)
%   Written by Jiuk Hwang. 2024.10.21

%% Daily
clc; clear;
dt = datetime(2012,7,3):caldays(1):datetime(2023,12,31);

FigFolderNm = 'D:\MATLAB_JU\RawData\2024_Remote_Sensing_RAW\AMSR';
if ~exist(FigFolderNm, 'dir')
    mkdir(FigFolderNm);
end

for iyear = unique(year(dt))
    dtid = year(dt) == iyear;
    hamster = dt(dtid);
    for iday = 1:length(hamster)
        hamster2 = hamster(iday);
        link = sprintf("https://data.remss.com/amsr2/ocean/L3/v08.2/daily/%d/RSS_AMSR2_ocean_L3_daily_%s_v08.2.nc", iyear, string(hamster2));

        websave(sprintf('%s\\%s.nc', FigFolderNm, string(hamster2)), link)
    end
    
end

%% Monthly
clc; clear;
dt = datetime(2012,7,1):calmonths(1):datetime(2023,12,1);

FigFolderNm = 'D:\MATLAB_JU\RawData\2024_Remote_Sensing_RAW\AMSR_month';
if ~exist(FigFolderNm, 'dir')
    mkdir(FigFolderNm);
end

for iday = 1:length(dt)
    hamster = datetime(dt(iday), 'Format','uuuu-MM');
    link = sprintf("https://data.remss.com/amsr2/ocean/L3/v08.2/monthly/RSS_AMSR2_ocean_L3_monthly_%s_v08.2.nc", string(hamster));

    websave(sprintf('%s\\%s.nc', FigFolderNm, string(hamster)), link)
end

