function HYCOM_31down_func_Jiuk_2(Period, timestep, Spatial_area, Depth_range, VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, HYC_ver)
%   Written by Jiuk Hwang
%   Log
%       HYCOM_31down_func_Jiuk.m
%       2024.03.04 Draft completed
%       2024.03.06 Modify (1) : setting time range
%       2024.03.29 Modify (2) : bug with reject for download data after 2019
%
%       HYCOM_31down_func_Jiuk_2.m
%       2024.07.25 Update (1)
%                   1. now you can change the time step (3 or 12 hours) of data
%                   2. now we notice the unavailable data among the input time range
%                   3. save the mat file in each year
%                   4. avoid downloading duplicated mat file
%       2024.09.19 Modified by Jiuk Hwang
%       2024.09.23 Modified by Jiuk Hwang
%       2024.10.02 Modified by Jiuk Hwang
% =========================================================================

%% Preprocessing

% make FOLDER for save mat file -------------------------------------------
hfn_ch = char(HomeFolderNm); hfn_end = hfn_ch(end);
if hfn_end ~= '\';            HomeFolderNm = strcat(HomeFolderNm, '\');        end
clear hfn_ch hfn_end;
hfn_ch = char(RawDataFolderNm); hfn_end = hfn_ch(end);
if hfn_end ~= '\';            RawDataFolderNm = strcat(RawDataFolderNm, '\');        end
clear hfn_ch hfn_end;

HomeFolderNm = sprintf('%s%s', HomeFolderNm, RawDataFolderNm);

if ~exist(HomeFolderNm, 'dir')
    mkdir(HomeFolderNm);
end
% -------------------------------------------------------------------------

% Time Axis of HYCOM 3.1
HycSetTime      = NaT(8, 2);
HycSetTime(2,1) = datetime(2014,07,01,12,00,00);    HycSetTime(2,2) = datetime(2016,08,31,21,00,00);
HycSetTime(3,1) = datetime(2016,09,01,00,00,00);    HycSetTime(3,2) = datetime(2017,02,01,09,00,00);
HycSetTime(4,1) = datetime(2017,02,01,12,00,00);    HycSetTime(4,2) = datetime(2017,06,01,09,00,00);
HycSetTime(5,1) = datetime(2017,06,01,12,00,00);    HycSetTime(5,2) = datetime(2017,10,01,09,00,00);
HycSetTime(6,1) = datetime(2017,10,01,12,00,00);    HycSetTime(6,2) = datetime(2018,02,28,21,00,00);
HycSetTime(7,1) = datetime(2018,03,01,00,00,00);    HycSetTime(7,2) = datetime(2018,12,31,21,00,00);
HycSetTime(8,1) = datetime(2019,01,01,00,00,00);    HycSetTime(8,2) = datetime(3000,12,31,21,00,00);

% Input Time Range
datestart   = datetime(sprintf('%d-%d-%d %d:%d:%d',Period(1,1), Period(1,2), Period(1,3), Period(1,4), Period(1,5), Period(1,6)), ...
    'Format','uuuu-MM-dd HH:mm:ss');
dateend   = datetime(sprintf('%d-%d-%d %d:%d:%d',Period(2,1), Period(2,2), Period(2,3), Period(2,4), Period(2,5), Period(2,6)), ...
    'Format','uuuu-MM-dd HH:mm:ss');

% Time Step
daterange   = (datestart:timestep*hours(1):dateend)';

% Check the Input Parameter
dateID = nan(length(daterange),size(HycSetTime,1));     % prepare 'empty room'
for i=1:size(HycSetTime,1)                              % loop : time axis of hycom
    if strcmp(HYC_ver, 'Reanalysis') && datestart <= datetime('2015-12-31 09:00:00') && dateend <= datetime('2015-12-31 09:00:00')
        Rean_yr = unique(year(daterange));
        % elseif strcmp(HYC_ver, 'Analysis') && datestart > datetime('2015-12-31 09:00:00') && dateend > datetime('2015-12-31 09:00:00')
    elseif strcmp(HYC_ver, 'Analysis') && datestart >= datetime('2014-07-01 12:00:00') && dateend >= datetime('2014-07-01 12:00:00')
        % find the "input time range" from "time axis" of hycom
        dateID1 = daterange >= HycSetTime(i,1);
        dateID2 = daterange <= HycSetTime(i,2);
        % find the proper 'time zone' for each step in "input time range"
        dateID(:,i) = all([dateID1, dateID2] ,2);
    else
        disp('Wrong INPUT parameter!');        break;
    end
end

% check Variables
varcheck    = nan(1,5);
varcheck(1) = ismember('ssh', string(VariableData));
varcheck(2) = ismember('temp', string(VariableData));
varcheck(3) = ismember('sal', string(VariableData));
varcheck(4) = ismember('u', string(VariableData));
varcheck(5) = ismember('v', string(VariableData));

% URL
idlinkfull(1) = "https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_53.X//data//";

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_';
idlink2 = '56.3';
idlinkfull(2) = sprintf('%s%s', idlink1, idlink2);

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_';
idlink2 = '57.2';
idlinkfull(3) = sprintf('%s%s', idlink1, idlink2);

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_';
idlink2 = '92.8';
idlinkfull(4) = sprintf('%s%s', idlink1, idlink2);

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_';
idlink2 = '57.7';
idlinkfull(5) = sprintf('%s%s', idlink1, idlink2);

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_';
idlink2 = '92.9';
idlinkfull(6) = sprintf('%s%s', idlink1, idlink2);

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBv0.08//expt_';
idlink2 = '93.0';
idlinkfull(7) = sprintf('%s%s', idlink1, idlink2);

idlink1 = 'https://tds.hycom.org//thredds//dodsC//GLBy0.08//expt_';
idlink2 = '93.0';
idlinkfull(8) = sprintf('%s%s', idlink1, idlink2);

idlinkfull=idlinkfull';

%% MAIN CODE - Download


% Analysis
if strcmp(HYC_ver, 'Analysis')
    dateID_any = find(any(dateID,1));

    % loop : time axis (zone) of hycom
    for i_ver = 1:size(HycSetTime,1)
        if ismember(i_ver, dateID_any)
            dateID_re = logical(dateID(:,i_ver));
            if any(dateID_re)
                daterange_re = daterange(dateID_re);
                daterange_str_end = [daterange_re(1), daterange_re(end)];

                ads1 = idlinkfull(i_ver);

                [id_tm, id_la, id_lo, id_dep, timeaxisfromhyc] = hyc_down_preparing(ads1, daterange_str_end, timestep, Spatial_area, Depth_range);

                % Check the pre-downloaded mat file -----------------------
                timeaxisfromhyc2 = datetime(timeaxisfromhyc(id_tm+1), 'Format','uuuu-MM-dd HH:mm:ss');
                hycyr = unique(year(timeaxisfromhyc2));
                for loophycyr = hycyr'
                    ckfpath = sprintf('%s%d\\',HomeFolderNm,loophycyr);

                    % check the existence of FOLDER
                    if exist(ckfpath, 'dir')
                        clear fn ifn fn2 fndate ifndate id_id_tm;
                        fn = dir(sprintf('%s%s', ckfpath, '*.mat'));
                        if height(fn) ~= 0
                            for ifn = 1:height(fn)
                                fn2 = split([fn(ifn).name], ["_", ".mat"]);
                                fprintf('%s already exist \n', [fn(ifn).name])
                                fn3(1) = double(string(fn2{2,:}));
                                fn3(2) = double(string(fn2{3,:}));
                                fn3(3) = double(string(fn2{4,:}));
                                fn3(4) = double(string(fn2{5,:}));
                                fndate(ifn) = datetime(fn3(1),fn3(2),fn3(3),fn3(4),00, 00, 'Format','uuuu-MM-dd HH:mm:ss');
                            end
                            for ifndate = 1:length(fndate)
                                id_id_tm = timeaxisfromhyc2 == fndate(ifndate);
                                id_tm(id_id_tm) = NaN;
                            end
                        end
                    end
                end

                id_tm = rmmissing(id_tm);
                % ---------------------------------------------------------

                % Download ================================================
                if ~isempty(id_tm)
                    for loopdown = 1:length(id_tm)

                        hyc = hyc_down_specific_area(ads1, id_tm(loopdown), id_la, id_lo, id_dep, varcheck);

                        % save struct to mat file
                        strtime = datevec(hyc.date);
                        fpath = sprintf('%s%d\\',HomeFolderNm,strtime(1));
                        if ~exist(fpath, 'dir')
                            mkdir(fpath);
                        end
                        matnm = sprintf('%s_%d_%02.f_%02.f_%02.f_%s.mat', MatFileNm, strtime(1), strtime(2), strtime(3), strtime(4), HYC_ver);
                        fpath2 = sprintf('%s%s', fpath, matnm);
                        save(fpath2, "hyc")
                        fprintf('Download %s\n', matnm);
                    end
                end
                % =========================================================
            end
        end
    end

    % Reanalysis ==========================================================
elseif strcmp(HYC_ver, 'Reanalysis')
    for i_ver = Rean_yr(1):Rean_yr(end)

        ads1 = sprintf('%s%d', idlinkfull(1), i_ver);

        [id_tm, id_la, id_lo, id_dep, timeaxisfromhyc] = hyc_down_preparing(ads1, [datestart, dateend], timestep, Spatial_area, Depth_range);

        % Check the pre-downloaded mat file -----------------------
        timeaxisfromhyc2 = datetime(timeaxisfromhyc(id_tm+1), 'Format','uuuu-MM-dd HH:mm:ss');
        hycyr = unique(year(timeaxisfromhyc2));
        for loophycyr = hycyr'
            ckfpath = sprintf('%s%d\\',HomeFolderNm,loophycyr);

            % check the existence of FOLDER
            if exist(ckfpath, 'dir')
                clear fn ifn fn2 fndate ifndate id_id_tm;
                fn = dir(sprintf('%s%s', ckfpath, '*.mat'));
                if height(fn) ~= 0
                    for ifn = 1:height(fn)
                        fn2 = split([fn(ifn).name], ["_", ".mat"]);
                        fprintf('%s already exist \n', [fn(ifn).name])
                        fn3(1) = double(string(fn2{2,:}));
                        fn3(2) = double(string(fn2{3,:}));
                        fn3(3) = double(string(fn2{4,:}));
                        fn3(4) = double(string(fn2{5,:}));
                        fndate(ifn) = datetime(fn3(1),fn3(2),fn3(3),fn3(4),00, 00, 'Format','uuuu-MM-dd HH:mm:ss');
                    end
                    for ifndate = 1:length(fndate)
                        id_id_tm = timeaxisfromhyc2 == fndate(ifndate);
                        id_tm(id_id_tm) = NaN;
                    end
                end
            end
        end

        id_tm = rmmissing(id_tm);
        % ---------------------------------------------------------

        % Download ================================================
        if ~isempty(id_tm)
            for loopdown = 1:length(id_tm)
                hyc = hyc_down_specific_area(ads1, id_tm(loopdown), id_la, id_lo, id_dep, varcheck);

                % save struct to mat file
                strtime = datevec(hyc.date);
                fpath = sprintf('%s%d\\',HomeFolderNm,strtime(1));
                if ~exist(fpath, 'dir')
                    mkdir(fpath);
                end
                matnm = sprintf('%s_%d_%02.f_%02.f_%02.f_%s.mat', MatFileNm, strtime(1), strtime(2), strtime(3), strtime(4), HYC_ver);
                fpath2 = sprintf('%s%s', fpath, matnm);
                save(fpath2, "hyc")
                fprintf('Download %s\n', matnm);
            end
        end
    end
end


end

% =========================================================================

% hyc_down_preparing ======================================================

function [id_tm, id_la, id_lo, id_dep, timeaxisfromhyc] = hyc_down_preparing(ads1, daterange_str_end, timestep, Spatial_area, Depth_range)

fprintf('NEW Session Begin!!! \n')
fprintf('Preparing Download... Please Wait.\n')

ads2 = '?time';
ads_f2 = sprintf('%s%s', ads1, ads2);

fprintf('Time data downloading... Please Wait.\n')
all_time = downloadretry(ads_f2, 'time');

timeaxisfromhyc = datetime(2000, 01, 01, 00, 00, 00)+hours(all_time);

inputtime = (daterange_str_end(1):timestep*hours(1):daterange_str_end(2))';
id_tm = nan(length(inputtime),1);
for looptime = 1:length(inputtime)
    ck = find(timeaxisfromhyc == inputtime(looptime));
    if ~isempty(ck)
        if length(ck) > 1 % 2018-06-21 06:00:00 ← duplicated in "timeaxisfromhyc"
            id_tm(looptime) = ck(1);
        else
            id_tm(looptime) = ck;
        end
    else
        fprintf('Cannot find the data for %s in THIS Session. \n', string(inputtime(looptime)))
    end
end

id_tm = rmmissing(id_tm)-1;

fprintf('TIME data Ready... Please Wait.\n')

ads5 = '?lat,lon';
ads_f5 = sprintf('%s%s', ads1, ads5);

all_la = downloadretry(ads_f5, 'lat');        all_lo = downloadretry(ads_f5, 'lon');

% id_la = knnsearch(all_la, [Spatial_area(1); Spatial_area(2)]); id_la = id_la -1;
% id_lo = knnsearch(all_lo, [Spatial_area(3); Spatial_area(4)]); id_lo = id_lo -1;

id_la(1) = findnearpoint(all_la, Spatial_area(1)); 
id_la(2) = findnearpoint(all_la, Spatial_area(2)); 
id_la = id_la -1;
id_lo(1) = findnearpoint(all_lo, Spatial_area(3)); 
id_lo(2) = findnearpoint(all_lo, Spatial_area(4)); 
id_lo = id_lo -1;

fprintf('LAT & LON data Ready... Please Wait.\n')

ads3 = '?depth';
ads_f3 = sprintf('%s%s', ads1, ads3);

all_dep = downloadretry(ads_f3, 'depth');

% id_dep = knnsearch(all_dep, Depth_range); 
id_dep(1) = findnearpoint(all_dep, Depth_range(1)); 
id_dep(2) = findnearpoint(all_dep, Depth_range(2)); 
id_dep = id_dep -1;

fprintf('DEPTH data Ready... Please Wait.\n')

% ---------------------------------------------------
function id = findnearpoint(base, target)
% find nearest point of "target" from "base"
[~, id] = min(abs(base-target)); 
end

end

% hyc_down_specific_area ==================================================

function hyc = hyc_down_specific_area(ads1, id_tm, id_la, id_lo, id_dep, varcheck)

% lon, lat, time
adsset1 = sprintf('?lat[%d:1:%d],lon[%d:1:%d],time[%d:1:%d]', ...
    id_la(1), id_la(2), id_lo(1), id_lo(2), id_tm, id_tm);

% ssh
adsrng2 = sprintf('[%d:1:%d][%d:1:%d][%d:1:%d]', ...
    id_tm, id_tm, id_la(1), id_la(2), id_lo(1), id_lo(2));
if varcheck(1) == 1
    adsset1 = sprintf('%s,surf_el%s',adsset1, adsrng2);
end

% depth
adsset1 = sprintf('%s,depth[%d:1:%d]',adsset1, id_dep(1), id_dep(2));

% temp, sal, u, v
adsrng1 = sprintf('[%d:1:%d][%d:1:%d][%d:1:%d][%d:1:%d]', ...
    id_tm, id_tm, id_dep(1), id_dep(2), id_la(1), id_la(2), id_lo(1), id_lo(2));
for i_var = 2:length(varcheck)
    if varcheck(i_var) == 1
        if i_var == 2
            adsset1 = sprintf('%s,water_temp%s',adsset1, adsrng1);
        elseif i_var == 3
            adsset1 = sprintf('%s,salinity%s',adsset1, adsrng1);
        elseif i_var == 4
            adsset1 = sprintf('%s,water_u%s',adsset1, adsrng1);
        elseif i_var == 5
            adsset1 = sprintf('%s,water_v%s',adsset1, adsrng1);
        end
    end
end

ads_f1 = sprintf('%s%s', ads1, adsset1);

% load data
hyc = struct;

dntm = downloadretry(ads_f1, 'time');
hyc.date = datetime(datetime(2000, 01, 01, 00, 00, 00)+hours(dntm), 'Format','uuuu-MM-dd HH:mm:ss');
hyc.lat = downloadretry(ads_f1, 'lat');
hyc.lon = downloadretry(ads_f1, 'lon');
hyc.dep = downloadretry(ads_f1, 'depth');

for i_var = 1:length(varcheck)
    if varcheck(i_var) == 1
        if i_var == 1
            hyc.ssh = downloadretry(ads_f1, 'surf_el');
        elseif i_var == 2
            hyc.temp = downloadretry(ads_f1, 'water_temp');
        elseif i_var == 3
            hyc.sal = downloadretry(ads_f1, 'salinity');
        elseif i_var == 4
            hyc.u = downloadretry(ads_f1, 'water_u');
        elseif i_var == 5
            hyc.v = downloadretry(ads_f1, 'water_v');
        end
    end
end

end

% -------------------------------------------------------------------------
function output = downloadretry(adress, var)
while true % If the downloading process is interrupted, then retry downloading automatically.
    try
        output = ncread(adress, var);
        break; % Exit the while statement if it runs without errors
    catch ME %Get information about errors that occur inside the try block into the object ME
        % Outputting error messages
        disp('Error Message : ');        disp(ME.message);
    end
    % Wait and run again
    disp('Process Retry... Please wait');    pause(15);    
end

end

% =========================================================================
% Check time range of each HYCOM data set
% (log) Final check the time range of HYCOM data set : 2024-03-06
%
% 1
%    1994-01-01 12:00:00   1994-12-31 21:00:00
%    1995-01-01 00:00:00   1995-12-31 21:00:00
%    1996-01-01 00:00:00   1996-12-31 21:00:00
%    1997-01-01 00:00:00   1997-12-31 21:00:00
%    1998-01-01 00:00:00   1998-12-31 21:00:00
%    1999-01-01 00:00:00   1999-12-31 21:00:00
%    2000-01-01 00:00:00   2000-12-31 21:00:00
%    2001-01-01 00:00:00   2001-12-31 21:00:00
%    2002-01-01 00:00:00   2002-12-31 21:00:00
%    2003-01-01 00:00:00   2003-12-31 21:00:00
%    2004-01-01 00:00:00   2004-12-31 21:00:00
%    2005-01-01 00:00:00   2005-12-31 21:00:00
%    2006-01-01 00:00:00   2006-12-31 21:00:00
%    2007-01-01 00:00:00   2007-12-31 21:00:00
%    2008-01-01 00:00:00   2008-12-31 21:00:00
%    2009-01-01 00:00:00   2009-12-31 21:00:00
%    2010-01-01 00:00:00   2010-12-31 21:00:00
%    2011-01-01 03:00:00   2011-12-31 21:00:00
%    2012-01-01 00:00:00   2012-12-31 21:00:00
%    2013-01-01 00:00:00   2013-12-31 21:00:00
%    2014-01-01 00:00:00   2014-12-31 09:00:00
%    2015-01-01 12:00:00   2015-12-31 09:00:00
% 2
%    2014-07-01 12:00:00   2016-09-30 09:00:00 start 2015 // stop 2016-08
% 3
%    2016-05-01 12:00:00   2017-02-01 09:00:00 start 2016-09 // cut
% 4
%    2017-02-01 12:00:00   2017-06-01 09:00:00 cut // cut
% 5
%    2017-06-01 12:00:00   2017-10-01 09:00:00 cut // cut
% 6
%    2017-10-01 12:00:00   2018-03-20 09:00:00 cut // stop 2018-02
% 7
%    2018-01-01 12:00:00   2020-02-19 09:00:00 start 2018-03 // stop 2018-12
% 8
%    2018-12-04 12:00:00   2024-03-05 09:00:00 start 2019-01