function func_podaac_down_Jiuk(source, period, Spatial_area, lag_time)
%   written by Jiuk Hwang
%   LOG
%       [2024.10.03] Draft done.
%       [2024.10.05] Add MUR 4.1 / MUR 4.2

if strcmp(source,'OSTIA v2')
    fnm = "sample_lonlat_20070101_OSTIA_v02.nc4";
elseif strcmp(source, 'OSTIA rep')
    fnm = "sample_lonlat_19820101_OSTIA_REP_v02.nc4";
elseif strcmp(source,'MUR 4.1')
    fnm = 'sample_lonlat_20020601_MUR_41.nc4';
elseif strcmp(source, 'MUR 4.2')
    fnm = 'sample_lonlat_20020901_MUR_42.nc4';
else 
    disp("Wrong Input for 'source'")
end
lat = double(ncread(fnm, 'lat'));
lon = double(ncread(fnm, 'lon'));

idlat(1) = findnearpoint(lat, Spatial_area(1));
idlat(2) = findnearpoint(lat, Spatial_area(2));
idlon(1) = findnearpoint(lon, Spatial_area(3));
idlon(2) = findnearpoint(lon, Spatial_area(4));

period2 = datetime(period);
period3 = period2(1):days(1):period2(2);

for loop = 1:length(period3)
    period4 = period3(loop); period5 = datevec(period4); period5 = period5(1:3);
    period6 = sprintf("%d%02.0f%02.0f", period5);

    fprintf("Start to download %s \n", string(period4))

    if strcmp(source,'OSTIA v2')
        url1 = "https://opendap.earthdata.nasa.gov/collections" + ...
            "/C2036877535-POCLOUD/granules/";
        url3 = "120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.0-fv02.0.dap.nc4?=dap4.ce=";
        url4 = sprintf("/time[0:1:0];/lat[%d:1:%d];/lon[%d:1:%d];/analysed_sst[0:1:0][%d:1:%d][%d:1:%d]", ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1, ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1);
    elseif strcmp(source, 'OSTIA rep')
        url1 = "https://opendap.earthdata.nasa.gov/collections/" + ...
            "C2586786218-POCLOUD/granules/";
        url3 = "120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB_REP-v02.0-fv02.0.dap.nc4?dap4.ce=";
        url4 = sprintf("/time[0:1:0];/lat[%d:1:%d];/lon[%d:1:%d];/analysed_sst[0:1:0][%d:1:%d][%d:1:%d]", ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1, ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1);
    elseif strcmp(source,'MUR 4.1')
        url1 = "https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/" + ...
            "GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)" + ...
            "/granules/";
        url3 = "090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.dap.nc4?dap4.ce=";
        url4 = sprintf("/time[0:1:0];/lat[%d:1:%d];/lon[%d:1:%d];/analysed_sst[0:1:0][%d:1:%d][%d:1:%d]", ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1, ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1);
    elseif strcmp(source, 'MUR 4.2')
        url1 = "https://opendap.earthdata.nasa.gov/collections/" + ...
            "C2036880657-POCLOUD/granules/";
        url3 = "090000-JPL-L4_GHRSST-SSTfnd-MUR25-GLOB-v02.0-fv04.2.dap.nc4?dap4.ce=";
        "/analysed_sst[0:1:0][0:1:719][0:1:1439];/lat[0:1:719];/lon[0:1:1439];/time[0:1:0]";
        url4 = sprintf("/time[0:1:0];/lat[%d:1:%d];/lon[%d:1:%d];/analysed_sst[0:1:0][%d:1:%d][%d:1:%d]", ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1, ...
            idlat(1)-1, idlat(2)-1, idlon(1)-1, idlon(2)-1);
    end

    url2 = period6;
    url5 = strcat(url1, url2, url3, url4);
    web(url5)

    pause(lag_time);
end
% -----------------------------------------------------------
    function id = findnearpoint(base, target)
        % find nearest point of "target" from "base"
        [~, id] = min(abs(base-target));
    end
end