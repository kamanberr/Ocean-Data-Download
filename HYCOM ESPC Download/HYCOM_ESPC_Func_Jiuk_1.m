function HYCOM_ESPC_Func_Jiuk_1(Period, timestep, Spatial_area, lat_step, lon_step, ...
    Depth_range, VariableData, HomeFolderNm, RawDataFolderNm, FileName, FileFormat, HYC_ver)
%   Written by Jiuk Hwang
%   Log
%       HYCOM_ESPC_Func_Jiuk_1.m
%       2025.04.21 Draft completed
%       2025.12.09 now you can download file as NC format
% =========================================================================

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
% Input Time Range
datestart   = datetime(sprintf('%d-%d-%d %d:%d:%d',Period(1,1), Period(1,2), Period(1,3), Period(1,4), Period(1,5), Period(1,6)), ...
    'Format','uuuu-MM-dd HH:mm:ss');
dateend   = datetime(sprintf('%d-%d-%d %d:%d:%d',Period(2,1), Period(2,2), Period(2,3), Period(2,4), Period(2,5), Period(2,6)), ...
    'Format','uuuu-MM-dd HH:mm:ss');

% Time Step
daterange   = (datestart:timestep*hours(1):dateend)';

% -------------------------------------------------------------------------
% Check the Input Parameter
if datestart < datetime('2024-08-10 12:00:00') || datestart > dateend
    fprintf('Wrong INPUT date! \n');
    return
end

% check Variables ---------------------------------------------------------
% select from {'sic', 'sih', 'siu', 'siv', 'sss', 'sst',
%               'ssu', 'ssv', 'surtx', 'surty',
%               'ssh', 'sssh',
%               'sal', 'temp', 'u', 'v'};
varcheck    = nan(1,16);
varcheck(1) = ismember('sic', string(VariableData));
varcheck(2) = ismember('sih', string(VariableData));
varcheck(3) = ismember('siu', string(VariableData));
varcheck(4) = ismember('siv', string(VariableData));
varcheck(5) = ismember('sss', string(VariableData));
varcheck(6) = ismember('sst', string(VariableData));
varcheck(7) = ismember('ssu', string(VariableData));
varcheck(8) = ismember('ssv', string(VariableData));
varcheck(9) = ismember('surtx', string(VariableData));
varcheck(10) = ismember('surty', string(VariableData));

varcheck(11) = ismember('ssh', string(VariableData));

varcheck(12) = ismember('sssh', string(VariableData));

varcheck(13) = ismember('sal', string(VariableData));
varcheck(14) = ismember('temp', string(VariableData));
varcheck(15) = ismember('u', string(VariableData));
varcheck(16) = ismember('v', string(VariableData));

if any(varcheck(13:16)) && rem(timestep, 3) ~= 0
    fprintf('Variable "sal", "temp", "u", "v" are not hourly dataset! \n');
    return
end

idlinkfull(1) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/ice";   % var 1~10
idlinkfull(2) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/ssh";   % var 11
idlinkfull(3) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/Sssh";  % var 12

idlinkfull(4) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/s3z";   % var 13
idlinkfull(5) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/t3z";   % var 14
idlinkfull(6) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/u3z";   % var 15
idlinkfull(7) = "https://tds.hycom.org/thredds/dodsC/ESPC-D-V02/v3z";   % var 16

% url for basic variables: time, depth, lon, lat
if any(varcheck(13:16)) % 3 hourly
    imsi = find(varcheck(13:16));
    ads1 = idlinkfull(3+imsi(1));
    [id_tm, id_la, id_lo, id_dep, timeaxisfromhyc0] = hyc_down_preparing(ads1, daterange, Spatial_area, Depth_range);
else % 1 houly
    ads1 = idlinkfull(1);
    [id_tm, id_la, id_lo, ~, timeaxisfromhyc0] = hyc_down_preparing(ads1, daterange, Spatial_area, 'surface');
    % timeaxisfromhyc = dateshift(timeaxisfromhyc0, 'end', 'hour', 'nearest');
end

% Check the pre-downloaded mat file -----------------------
timeaxisfromhyc2 = datetime(timeaxisfromhyc0(id_tm+1), 'Format','uuuu-MM-dd HH:mm');
hycyr = unique(year(timeaxisfromhyc2));
for loophycyr = hycyr'
    ckfpath = sprintf('%s%d\\',HomeFolderNm,loophycyr);

    % check the existence of FOLDER
    if exist(ckfpath, 'dir')
        clear fn ifn fn2 fndate ifndate id_id_tm;
        fn = dir(sprintf('%s*.%s', ckfpath, FileFormat));
        if height(fn) ~= 0
            for ifn = 1:height(fn)
                fn2 = split([fn(ifn).name], ["_", sprintf('.%s', FileFormat)]);
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

id_tm = rmmissing(id_tm); % exclude "pre-existing" mat file
% ---------------------------------------------------------

% Download ================================================
if ~isempty(id_tm)
    for loopdown = 1:length(id_tm)

        if any(varcheck(13:16)) % 3 hourly
            hyc = hyc_down_specific_area(idlinkfull, ads1, id_tm(loopdown), id_la, id_lo, varcheck, lat_step, lon_step, id_dep);
        else % 1 houly
            hyc = hyc_down_specific_area(idlinkfull, ads1, id_tm(loopdown), id_la, id_lo, varcheck, lat_step, lon_step, 'surface');
        end

        % save struct to mat file
        strtime = datevec(hyc.date);
        fpath = sprintf('%s%d\\',HomeFolderNm,strtime(1));
        if ~exist(fpath, 'dir')
            mkdir(fpath);
        end
        if strcmp(FileFormat, 'mat') || strcmp(FileFormat, 'Mat') || strcmp(FileFormat, 'MAT')
            % Save as Mat file
            matnm = sprintf('%s_%d_%02.f_%02.f_%02.f_%s.mat', ...
                FileName, strtime(1), strtime(2), strtime(3), strtime(4), HYC_ver);
            fpath2 = sprintf('%s%s', fpath, matnm);
            save(fpath2, "hyc", "-v7.3")
        end

        if strcmp(FileFormat, 'nc') || strcmp(FileFormat, 'NC') || strcmp(FileFormat, 'Nc')
            % Save as NC file
            matnm = sprintf('%s_%d_%02.f_%02.f_%02.f_%s.nc', ...
                FileName, strtime(1), strtime(2), strtime(3), strtime(4), HYC_ver);
            coord_priority = ["lon", "lat", "dep"];
            fpath2 = sprintf('%s%s', fpath, matnm);
            func_struct2nc_hycom(hyc, fpath2, coord_priority);
        end
    end
end
% =========================================================

    function [id_tm, id_la, id_lo, id_dep, timeaxisfromhyc0] = hyc_down_preparing(ads1, daterange, Spatial_area, Depth_range)

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

        if strcmp(Depth_range, "surface")
            id_dep = zeros(1, 2);
            fprintf('This is request for Surface... Please Wait.\n')
        else
            ads3 = '?depth';
            ads_f3 = sprintf('%s%s', ads1, ads3);

            all_dep = downloadretry(ads_f3, 'depth');

            % id_dep = knnsearch(all_dep, Depth_range);
            id_dep(1) = findnearpoint(all_dep, Depth_range(1));
            id_dep(2) = findnearpoint(all_dep, Depth_range(2));
            id_dep = id_dep -1;

            fprintf('DEPTH data Ready... Please Wait.\n')
        end

        % ---------------------------------------------------
        function id = findnearpoint(base, target)
            % Input: (column vector, row vector)
            % find nearest point of "target" from "base"
            [~, id] = min(abs(base-target));
        end

    end


% hyc_down_specific_area ==================================================

    function hyc = hyc_down_specific_area(idlinkfull, ads1, id_tm, id_la, id_lo, varcheck, lat_step, lon_step, id_dep)

        % 3d variables: lon, lat, time, depth
        if ~strcmp(id_dep, "surface")
            adsset01 = sprintf('?depth[%d:1:%d],lat[%d:%d:%d],lon[%d:%d:%d],time[%d:1:%d]', ...
                id_dep(1), id_dep(2), id_la(1), lat_step, id_la(2), id_lo(1), lon_step, id_lo(2), id_tm, id_tm);

            adsset01 = string(adsset01);
            adsset1 = repmat(adsset01, 4, 1);

            adsrng1 = sprintf('[%d:1:%d][%d:1:%d][%d:%d:%d][%d:%d:%d]', ...
                id_tm, id_tm, id_dep(1), id_dep(2), id_la(1), lat_step, id_la(2), id_lo(1), lon_step, id_lo(2));
        end

        % 2d variables: lon, lat, time
        adsset02 = sprintf('?lat[%d:%d:%d],lon[%d:%d:%d],time[%d:1:%d]', ...
            id_la(1), lat_step, id_la(2), id_lo(1), lon_step, id_lo(2), id_tm, id_tm);
        adsset02 = string(adsset02);
        adsset2 = repmat(adsset02, 3, 1);

        adsrng2 = sprintf('[%d:1:%d][%d:%d:%d][%d:%d:%d]', ...
            id_tm, id_tm, id_la(1), lat_step, id_la(2), id_lo(1), lon_step, id_lo(2));

        for i_var = 1:length(varcheck)
            if varcheck(i_var) == 1
                % select from {'sic', 'sih', 'siu', 'siv', 'sss', 'sst',
                %               'ssu', 'ssv', 'surtx', 'surty',
                %               'ssh', 'sssh',
                %               'sal', 'temp', 'u', 'v'};
                if i_var == 1
                    adsset2(1, :) = sprintf('%s,sic%s',adsset2(1), adsrng2);
                elseif i_var == 2
                    adsset2(1) = sprintf('%s,sih%s',adsset2(1), adsrng2);
                elseif i_var == 3
                    adsset2(1) = sprintf('%s,siu%s',adsset2(1), adsrng2);
                elseif i_var == 4
                    adsset2(1) = sprintf('%s,siv%s',adsset2(1), adsrng2);
                elseif i_var == 5
                    adsset2(1) = sprintf('%s,sss%s',adsset2(1), adsrng2);
                elseif i_var == 6
                    adsset2(1) = sprintf('%s,sst%s',adsset2(1), adsrng2);
                elseif i_var == 7
                    adsset2(1) = sprintf('%s,ssu%s',adsset2(1), adsrng2);
                elseif i_var == 8
                    adsset2(1) = sprintf('%s,ssv%s',adsset2(1), adsrng2);
                elseif i_var == 9
                    adsset2(1) = sprintf('%s,surtx%s',adsset2(1), adsrng2);
                elseif i_var == 10
                    adsset2(1) = sprintf('%s,surty%s',adsset2(1), adsrng2);

                elseif i_var == 11
                    adsset2(2) = sprintf('%s,surf_el%s',adsset2(2), adsrng2);

                elseif i_var == 12
                    adsset2(3) = sprintf('%s,steric_ssh%s',adsset2(3), adsrng2);

                elseif i_var == 13
                    adsset1(1) = sprintf('%s,salinity%s',adsset1(1), adsrng1);
                elseif i_var == 14
                    adsset1(2) = sprintf('%s,water_temp%s',adsset1(2), adsrng1);
                elseif i_var == 15
                    adsset1(3) = sprintf('%s,water_u%s',adsset1(3), adsrng1);
                elseif i_var == 16
                    adsset1(4) = sprintf('%s,water_v%s',adsset1(4), adsrng1);
                end
            end
        end

        % load data
        hyc = struct;

        if ~strcmp(id_dep, "surface")
            ads1_basic = char(sprintf("%s%s", char(ads1), adsset01));
            dntm = downloadretry(ads1_basic, 'time');
            hyc.date = datetime(datetime(2000, 01, 01, 00, 00, 00)+hours(dntm), 'Format','uuuu-MM-dd HH:mm:ss');
            hyc.lat = downloadretry(ads1_basic, 'lat');
            hyc.lon = downloadretry(ads1_basic, 'lon');
            hyc.dep = downloadretry(ads1_basic, 'depth');
        else
            ads1_basic = char(sprintf("%s%s", char(ads1), adsset02));
            dntm = downloadretry(ads1_basic, 'time');
            hyc.date = datetime(datetime(2000, 01, 01, 00, 00, 00)+hours(dntm), 'Format','uuuu-MM-dd HH:mm:ss');
            hyc.lat = downloadretry(ads1_basic, 'lat');
            hyc.lon = downloadretry(ads1_basic, 'lon');
        end

        for i_var = 1:length(varcheck)
            if varcheck(i_var) == 1

                if i_var <= 10
                    ads_f1 = sprintf('%s%s', idlinkfull(1), adsset2(1));
                elseif i_var == 11
                    ads_f1 = sprintf('%s%s', idlinkfull(2), adsset2(2));
                elseif i_var == 12
                    ads_f1 = sprintf('%s%s', idlinkfull(3), adsset2(3));
                elseif i_var == 13
                    ads_f1 = sprintf('%s%s', idlinkfull(4), adsset1(1));
                elseif i_var == 14
                    ads_f1 = sprintf('%s%s', idlinkfull(5), adsset1(2));
                elseif i_var == 15
                    ads_f1 = sprintf('%s%s', idlinkfull(6), adsset1(3));
                elseif i_var == 16
                    ads_f1 = sprintf('%s%s', idlinkfull(7), adsset1(4));
                end

                ads_f1 = char(ads_f1);

                % select from {'sic', 'sih', 'siu', 'siv', 'sss', 'sst',
                %               'ssu', 'ssv', 'surtx', 'surty',
                %               'ssh', 'sssh',
                %               'sal', 'temp', 'u', 'v'};
                if i_var == 1
                    hyc.sic = downloadretry(ads_f1, "sic");
                elseif i_var == 2
                    hyc.sih = downloadretry(ads_f1, "sih");
                elseif i_var == 3
                    hyc.siu = downloadretry(ads_f1, "siu");
                elseif i_var == 4
                    hyc.siv = downloadretry(ads_f1, "siv");
                elseif i_var == 5
                    hyc.sss = downloadretry(ads_f1, "sss");
                elseif i_var == 6
                    hyc.sst = downloadretry(ads_f1, "sst");
                elseif i_var == 7
                    hyc.ssu = downloadretry(ads_f1, "ssu");
                elseif i_var == 8
                    hyc.ssv = downloadretry(ads_f1, "ssv");
                elseif i_var == 9
                    hyc.surtx = downloadretry(ads_f1, "surtx");
                elseif i_var == 10
                    hyc.surty = downloadretry(ads_f1, "surty");

                elseif i_var == 11
                    hyc.ssh = downloadretry(ads_f1, "surf_el");

                elseif i_var == 12
                    hyc.Sssh = downloadretry(ads_f1, "steric_ssh");

                elseif i_var == 13
                    hyc.sal = downloadretry(ads_f1, "salinity");
                elseif i_var == 14
                    hyc.temp = downloadretry(ads_f1, "water_temp");
                elseif i_var == 15
                    hyc.u = downloadretry(ads_f1, "water_u");
                elseif i_var == 16
                    hyc.v = downloadretry(ads_f1, "water_v");
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