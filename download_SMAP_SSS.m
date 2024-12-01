%% Download RSS SMAP Salinity V6.0 Validated Dataset 
%   source : https://www.remss.com/missions/smap/salinity/ 
%
%   Written by Jiuk Hwang. 2024.12.01

%% Gridded (L3) 8day Running 
%   Date Range : 2015.04.01 ~ Present
clc; clear;
dt = datetime(2015,4,1):caldays(1):datetime(2015,4,1);

FigFolderNm = 'D:\MATLAB_JU\2024_RS_Assign6_SMAP';
if ~exist(FigFolderNm, 'dir')
    mkdir(FigFolderNm);
end

for iyear = unique(year(dt))
    dtid = year(dt) == iyear;
    hamster = dt(dtid);
    for iday = 1:length(hamster)
        hamster2 = days(hamster(iday) - datetime(iyear, 1, 1) + 1);
        link = sprintf("https://data.remss.com/smap/SSS/V06.0/FINAL/L3/8day_running/%d/RSS_smap_SSS_L3_8day_running_2015_%03.0f_FNL_v06.0.nc", iyear, hamster2);

        websave(sprintf('%s\\%s.nc', FigFolderNm, string(hamster(iday))), link)
    end    
end

%% Gridded (L3) Monthly
%   Date Range : 2015.04 ~ Present
clc; clear;
dt = datetime(2015,4,1):calmonths(1):datetime(2023,12,1);

FigFolderNm = 'D:\MATLAB_JU\2024_RS_Assign6_SMAP';
if ~exist(FigFolderNm, 'dir')
    mkdir(FigFolderNm);
end

for iyear = unique(year(dt))
    dtid = year(dt) == iyear;
    hamster = dt(dtid);
    for iday = 1:length(hamster)
        hamster2 = datetime(hamster(iday), 'Format','uuuu_MM');
        link = sprintf("https://data.remss.com/smap/SSS/V06.0/FINAL/L3/monthly/%d/RSS_smap_SSS_L3_monthly_%s_FNL_v06.0.nc", iyear, string(hamster2));

        websave(sprintf('%s\\%s.nc', FigFolderNm, string(hamster2)), link)
    end    
end