function HYCOM_GOFS31_Func_Ice_Jiuk(Period, timestep, Spatial_area, lat_step, lon_step, VariableData, HomeFolderNm, RawDataFolderNm, MatFileNm, HYC_ver)
%   Written by Jiuk Hwang
%   Log
%       HYCOM_GOFS31_Func_Ice_Jiuk.m
%       2025.04.20 Draft completed
%
% -------------------------------------------------------------------------
% HYCOM GOFS 3.1 Analysis Ice      GLBy0.08/expt_93.0/ice
%   Period: 2018-09-11 12:00:00 ~ 2024-09-05 09:00:00
%   source: https://tds.hycom.org/thredds/catalogs/
%           GLBy0.08/expt_93.0_ice.html?dataset=GLBy0.08-expt_93.0-ice
% -------------------------------------------------------------------------
% HYCOM GOFS 3.1 Reanalysis Ice    GLBv0.08/expt_53.X_ice
%   Period: 1994 ~ 2015
%   source:https://tds.hycom.org/thredds/catalogs/GLBv0.08/expt_53.X_ice.html
% -------------------------------------------------------------------------

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

% Input Time Range
datestart   = datetime(sprintf('%d-%d-%d %d:%d:%d',Period(1,1), Period(1,2), Period(1,3), Period(1,4), Period(1,5), Period(1,6)), ...
    'Format','uuuu-MM-dd HH:mm:ss');
dateend   = datetime(sprintf('%d-%d-%d %d:%d:%d',Period(2,1), Period(2,2), Period(2,3), Period(2,4), Period(2,5), Period(2,6)), ...
    'Format','uuuu-MM-dd HH:mm:ss');

% Time Step
daterange   = (datestart:timestep*hours(1):dateend)';

% Check the Input Date
HycSetTime(1,1) = datetime(2018,09,11,12,00,00);    HycSetTime(1,2) = datetime(2024,09,05,09,00,00);

if strcmp(HYC_ver, 'Reanalysis_ice') && dateend <= datetime('2015-12-31 09:00:00') && datestart <= dateend
    Rean_yr = unique(year(daterange));
    loopyr = length(Rean_yr);
    idlinkfull0 = "https://tds.hycom.org/thredds/dodsC/GLBv0.08/expt_53.X/data_ice/";

elseif strcmp(HYC_ver, 'Analysis_ice') && datestart >= HycSetTime(1,1) && dateend <= HycSetTime(1,2) && datestart <= dateend
    idlinkfull = "https://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0/ice";
    loopyr = 1;
else
    disp('Wrong INPUT date range! \n');
end

% check Variables - {"sst", "sss", "ssu", "ssv", "sic", "sih", "siu", "siv", "surtx", "surty"}
varcheck    = nan(1,10);
varcheck(1) = ismember("sst", string(VariableData));
varcheck(2) = ismember("sss", string(VariableData));
varcheck(3) = ismember("ssu", string(VariableData));
varcheck(4) = ismember("ssv", string(VariableData));
varcheck(5) = ismember("sic", string(VariableData));
varcheck(6) = ismember('sih', string(VariableData));
varcheck(7) = ismember('siu', string(VariableData));
varcheck(8) = ismember('siv', string(VariableData));
varcheck(9) = ismember('surtx', string(VariableData));
varcheck(10) = ismember('surty', string(VariableData));

for iloopyr = 1:loopyr
    if strcmp(HYC_ver, 'Reanalysis_ice')
        idlinkfull = sprintf("%s/%d",idlinkfull0, Rean_yr(iloopyr));
    end

    ads1 = idlinkfull;
    % daterange_strnd = [daterange(1), daterange(end)];
    [id_tm, id_la, id_lo, timeaxisfromhyc0] = hyc_down_preparing(ads1, daterange, Spatial_area);
    % timeaxisfromhyc = dateshift(timeaxisfromhyc0, 'end', 'hour', 'nearest');

    % Check the pre-downloaded mat file -----------------------
    timeaxisfromhyc2 = datetime(timeaxisfromhyc0(id_tm+1), 'Format','uuuu-MM-dd HH:mm');
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
                    fn3(5) = double(string(fn2{6,:}));
                    fndate(ifn) = datetime(fn3(1),fn3(2),fn3(3),fn3(4),fn3(5),00, 'Format','uuuu-MM-dd HH:mm');
                end
                for ifndate = 1:length(fndate) % exclude "pre-existing" mat file
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

            hyc = hyc_down_specific_area(ads1, id_tm(loopdown), id_la, id_lo, varcheck, lat_step, lon_step);

            % save struct to mat file
            strtime = datevec(hyc.date);
            fpath = sprintf('%s%d\\',HomeFolderNm,strtime(1));
            if ~exist(fpath, 'dir')
                mkdir(fpath);
            end
            matnm = sprintf('%s_%d_%02.f_%02.f_%02.f_%02.f_%s.mat', MatFileNm, strtime(1), strtime(2), strtime(3), strtime(4), strtime(5), HYC_ver);
            fpath2 = sprintf('%s%s', fpath, matnm);
            save(fpath2, "hyc")
            fprintf('Download %s\n', matnm);
        end
    end
    % =========================================================
end


% =========================================================================
    function [id_tm, id_la, id_lo, timeaxisfromhyc0] = hyc_down_preparing(ads1, daterange, Spatial_area)

        fprintf('NEW Session Begin!!! \n')
        fprintf('Preparing Download... Please Wait.\n')

        ads2 = '?time';
        ads_f2 = sprintf('%s%s', ads1, ads2); % type is 'char'.

        fprintf('Time data downloading... Please Wait.\n')

        all_time = downloadretry(ads_f2, 'time');

        timeaxisfromhyc0 = datetime(2000, 01, 01, 00, 00, 00)+hours(all_time);
        timeaxisfromhyc = dateshift(timeaxisfromhyc0, 'end', 'hour', 'nearest');

        inputtime = daterange;
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

        all_la = downloadretry(ads_f5, "lat");        all_lo = downloadretry(ads_f5, "lon");

        id_la(1) = findnearpoint(all_la, Spatial_area(1));
        id_la(2) = findnearpoint(all_la, Spatial_area(2));
        id_la = id_la -1;
        id_lo(1) = findnearpoint(all_lo, Spatial_area(3));
        id_lo(2) = findnearpoint(all_lo, Spatial_area(4));
        id_lo = id_lo -1;

        fprintf('LAT & LON data Ready... Please Wait.\n')

        % ---------------------------------------------------
        function id = findnearpoint(base, target)
            % Input: (column vector, row vector)
            % find nearest point of "target" from "base"
            [~, id] = min(abs(base-target));
        end

    end

% hyc_down_specific_area ==================================================

    function hyc = hyc_down_specific_area(ads1, id_tm, id_la, id_lo, varcheck, lat_step, lon_step)

        % lon, lat, time
        adsset1 = sprintf('?lat[%d:%d:%d],lon[%d:%d:%d],time[%d:1:%d]', ...
            id_la(1), lat_step, id_la(2), id_lo(1), lon_step, id_lo(2), id_tm, id_tm);

        adsrng2 = sprintf('[%d:1:%d][%d:%d:%d][%d:%d:%d]', ...
            id_tm, id_tm, id_la(1), lat_step, id_la(2), id_lo(1), lon_step, id_lo(2));

        for i_var = 1:length(varcheck)
            if varcheck(i_var) == 1
                % {"sst", "sss", "ssu", "ssv", "sic", "sih", "siu", "siv", "surtx", "surty"}
                if i_var == 1
                    adsset1 = sprintf('%s,sst%s',adsset1, adsrng2);
                elseif i_var == 2
                    adsset1 = sprintf('%s,sss%s',adsset1, adsrng2);
                elseif i_var == 3
                    adsset1 = sprintf('%s,ssu%s',adsset1, adsrng2);
                elseif i_var == 4
                    adsset1 = sprintf('%s,ssv%s',adsset1, adsrng2);
                elseif i_var == 5
                    adsset1 = sprintf('%s,sic%s',adsset1, adsrng2);
                elseif i_var == 6
                    adsset1 = sprintf('%s,sih%s',adsset1, adsrng2);
                elseif i_var == 7
                    adsset1 = sprintf('%s,siu%s',adsset1, adsrng2);
                elseif i_var == 8
                    adsset1 = sprintf('%s,siv%s',adsset1, adsrng2);
                elseif i_var == 9
                    adsset1 = sprintf('%s,surtx%s',adsset1, adsrng2);
                elseif i_var == 10
                    adsset1 = sprintf('%s,surty%s',adsset1, adsrng2);
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

        for i_var = 1:length(varcheck)
            if varcheck(i_var) == 1
                % {"sst", "sss", "ssu", "ssv", "sic", "sih", "siu", "siv", "surtx", "surty"}
                if i_var == 1
                    hyc.sst = downloadretry(ads_f1, "sst");
                elseif i_var == 2
                    hyc.sss = downloadretry(ads_f1, "sss");
                elseif i_var == 3
                    hyc.ssu = downloadretry(ads_f1, "ssu");
                elseif i_var == 4
                    hyc.ssv = downloadretry(ads_f1, "ssv");
                elseif i_var == 5
                    hyc.sic = downloadretry(ads_f1, "sic");
                elseif i_var == 6
                    hyc.sih = downloadretry(ads_f1, "sih");
                elseif i_var == 7
                    hyc.siu = downloadretry(ads_f1, "siu");
                elseif i_var == 8
                    hyc.siv = downloadretry(ads_f1, "siv");
                elseif i_var == 9
                    hyc.surtx = downloadretry(ads_f1, "surtx");
                elseif i_var == 10
                    hyc.surty = downloadretry(ads_f1, "surty");
                end
                fprintf("Loading... %d/%d \n",i_var,length(varcheck))
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


end