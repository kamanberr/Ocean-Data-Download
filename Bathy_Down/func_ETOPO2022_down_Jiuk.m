function func_ETOPO2022_down_Jiuk(Spatial_area, resolution, fpath)
%   written by Jiuk Hwang
%   LOG
%       [2024.05.16] 30 arc Draft done.
%       [2024.06.24] 60 arc Draft done.
%       [2024.10.01] combine two script for convenience.

if resolution == 30
    % ETOPO 2022 Bedrock elevation - 30arc
    %   https://www.ngdc.noaa.gov/thredds/dodsC/global/ETOPO2022/30s/
    %   30s_bed_elev_netcdf/ETOPO_2022_v1_30s_N90W180_bed.nc.html

    link1 = "https://www.ngdc.noaa.gov/thredds/dodsC/global/ETOPO2022/60s/" + ...
        "60s_bed_elev_netcdf/ETOPO_2022_v1_60s_N90W180_bed.nc";
    link2 = "?lat[0:1:10799],lon[0:1:21599]";

    % =====================================================================
elseif resolution == 60
    % ETOPO 2022 Bedrock elevation - 60arc
    %   https://www.ngdc.noaa.gov/thredds/dodsC/global/ETOPO2022/60s/
    %   60s_bed_elev_netcdf/ETOPO_2022_v1_60s_N90W180_bed.nc.html

    link1 = "https://www.ngdc.noaa.gov/thredds/dodsC/global/ETOPO2022/30s/" + ...
        "30s_bed_elev_netcdf/ETOPO_2022_v1_30s_N90W180_bed.nc";
    link2 = "?lat[0:1:21599],lon[0:1:43199]";

    % =====================================================================
else
    disp('Wrong Input of "Resolution"')
end

% download process ----------------------------------------------

linkfull1 = sprintf('%s%s', link1, link2);      % ncdisp(link1)

imsi_lat = ncread(linkfull1, "lat");
imsi_lon = ncread(linkfull1, "lon");

idlat(1) = findnearpoint(imsi_lat, Spatial_area(1));
idlat(2) = findnearpoint(imsi_lat, Spatial_area(2));
idlon(1) = findnearpoint(imsi_lon, Spatial_area(3));
idlon(2) = findnearpoint(imsi_lon, Spatial_area(4));

linkfull2 = sprintf("%s?lat[%d:1:%d],lon[%d:1:%d],z[%d:1:%d][%d:1:%d]", ...
    link1, idlat(1), idlat(2), idlon(1), idlon(2), idlat(1), idlat(2), idlon(1), idlon(2));

bedlat = double(ncread(linkfull2, "lat"));
bedlon = double(ncread(linkfull2, "lon"));
bed = double(ncread(linkfull2, "z"));

matname = sprintf("ETOPO2022_bedrock_%darc_N%d%d_E%d%d.mat", resolution, Spatial_area);
save(sprintf('%s\\%s',fpath, matname), "bed", "bedlon", "bedlat");

% ---------------------------------------------------
function id = findnearpoint(base, target)
% find nearest point of "target" from "base"
[~, id] = min(abs(base-target)); end
% ---------------------------------------------------

end