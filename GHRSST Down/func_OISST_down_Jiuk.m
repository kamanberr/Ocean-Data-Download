function func_OISST_down_Jiuk(Project_Name, HOME_folder_path, Period, Spatial_area)
%   written by Jiuk Hwang
%   LOG
%       [2024.10.03] Draft done.
%       [2024.10.05] modify - only dowload OISST

% Store data in different folders by year
for idprd0 = Period(1,1):Period(2,1)    % Loop for sequence of "year"

    fprintf('Preparing Download for %d...\n', idprd0)
    disp('Please Wait...')

    link1 = sprintf("http://psl.noaa.gov/thredds/dodsC/Datasets/" + ...
        "noaa.oisst.v2.highres/sst.day.mean.%d.nc", idprd0);
    link2 = "?time,lat,lon";
    linkfull1 = sprintf('%s%s', link1, link2);

    imsi_time = downloadretry(linkfull1, "time");
    % units        = 'days since 1800-01-01 00:00:00'
    imsi_time2 = datetime(1800, 01, 01, 00, 00, 00) + days(imsi_time);
    imsi_lon = downloadretry(linkfull1, "lon");
    imsi_lat = downloadretry(linkfull1, "lat");
    disp('Ready to Download...')

    if Period(1,1)==Period(2,1)     % if the year is same between "start date" and "end date"
        Period2(1) = datetime(idprd0, Period(1,2), Period(1,3));
        Period2(2) = datetime(idprd0, Period(2,2), Period(2,3));
    else    % if the year is different between "start date" and "end date"
        if idprd0 == Period(1,1)    % first year
            Period2(1) = datetime(idprd0, Period(1,2), Period(1,3));
            Period2(2) = datetime(idprd0, 12, 31);
        elseif idprd0 == Period(2,1)    % end year
            Period2(1) = datetime(idprd0, 1, 1);
            Period2(2) = datetime(idprd0, Period(2,2), Period(2,3));
        else
            Period2(1) = datetime(idprd0, 1, 1);
            Period2(2) = datetime(idprd0, 12, 31);
        end
    end

    % ===========================================
    timeaxisfromhyc = imsi_time2;
    inputtime = (Period2(1):days(1):Period2(2))';
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
            fprintf('Cannot find the data for %s in THIS Year. \n', string(inputtime(looptime)))
        end
    end
    id_tm = rmmissing(id_tm);
    Period3 = timeaxisfromhyc(id_tm);

    % ===========================================
    % download folder
    fpath = sprintf('%s\\%s\\%d',HOME_folder_path,Project_Name,idprd0);

    % check the existence of "download folder"
    if ~exist(fpath, 'dir')     % if there is no folder
        mkdir(fpath);   % make new folder
        for idprd = Period3'      % download daily data
            downdown(imsi_time2, idprd, imsi_lat, imsi_lon, Spatial_area, ...
                link1, fpath);
        end
    else    % if folder already exists
        fprintf('%d Folder already exists.\n', idprd0)
        % get the information about data already saved
        fn = dir(sprintf('%s\\%s', fpath, '*.mat'));
        if height(fn) == 0      % if there is no data already saved
            for idprd = Period3'  % download daily data
                downdown(imsi_time2, idprd, imsi_lat, imsi_lon, Spatial_area, ...
                    link1, fpath);
            end
        else    % if there is some of data already saved.
            % get the information about the name of mat file already saved
            for ifn = 1:height(fn)
                fn2(ifn, :) = split([fn(ifn).name], ["_",".mat"]);
                fprintf('%s already exist \n', [fn(ifn).name])
            end
            check_exist = datetime(zeros(height(fn2), 1)+idprd0, ...
                str2double(fn2(:,end-2)), str2double(fn2(:,end-1)));

            % download daily data except mat file already exist.
            for idprd = Period3'
                if ~ismember(idprd, check_exist)
                    downdown(imsi_time2, idprd, imsi_lat, imsi_lon, Spatial_area, ...
                        link1, fpath);
                end
            end
        end
    end
    clear fn fn2 check_exist ifn iprd
end

% =========================================================================
    function downdown(imsi_time2, idprd, imsi_lat, imsi_lon, Spatial_area, ...
            link1, fpath)
        idtime = find(imsi_time2 == idprd);
        idlat(1) = findnearpoint(imsi_lat, Spatial_area(1));
        idlat(2) = findnearpoint(imsi_lat, Spatial_area(2));
        idlon(1) = findnearpoint(imsi_lon, Spatial_area(3));
        idlon(2) = findnearpoint(imsi_lon, Spatial_area(4));

        % sst : TIME, LAT, LON
        linkfull2 = sprintf("%s?time[%d:1:%d],lat[%d:1:%d],lon[%d:1:%d],sst[%d:1:%d][%d:1:%d][%d:1:%d]", ...
            link1, idtime-1, idtime-1, idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1, ...
            idtime-1, idtime-1, idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1);
        % the number in linkfull is start with 0(zero).
        % So each of number in linkfull should be "ID - 1".

        time = downloadretry(linkfull2, "time");
        oisst = struct;
        oisst.time = datetime(1800, 01, 01, 00, 00, 00) + days(time);
        oisst.lon = double(downloadretry(linkfull2, "lon"));
        oisst.lat = double(downloadretry(linkfull2, "lat"));
        oisst.sst = double(downloadretry(linkfull2, "sst"));
        oisst.sst(oisst.sst == -9.969209968386869e+36) = NaN;
        strtime = datevec(oisst.time);
        matname = sprintf("%s_%d_%02.f_%02.f.mat", 'OISST_v2', strtime(1), strtime(2), strtime(3));
        save(sprintf('%s\\%s',fpath, matname), "oisst");
        fprintf('Download complete for %s\n', matname);
    end

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

    function id = findnearpoint(base, target)
        % find nearest point of "target" from "base"
        [~, id] = min(abs(base-target));
    end

end