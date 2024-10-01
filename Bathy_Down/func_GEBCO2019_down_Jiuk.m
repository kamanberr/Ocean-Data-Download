function func_GEBCO2019_down_Jiuk(Spatial_area, fpath)
%   written by Jiuk Hwang
%   LOG
%       [2024.10.01] Draft done.
%
%   GEBCO 2019
%   https://tds.marine.rutgers.edu/thredds/dodsC/other/
%   bathymetry/GEBCO_2019/GEBCO_2019.nc.html

link1 = "https://tds.marine.rutgers.edu/thredds/dodsC/other/bathymetry/" + ...
    "GEBCO_2019/GEBCO_2019.nc";
link2 = "?lat[0:1:43199],lon[0:1:86399]";

linkfull1 = sprintf('%s%s', link1, link2);

imsi_lat = ncread(linkfull1, "lat");
imsi_lon = ncread(linkfull1, "lon");

idlat(1) = findnearpoint(imsi_lat, Spatial_area(1));
idlat(2) = findnearpoint(imsi_lat, Spatial_area(2));
idlon(1) = findnearpoint(imsi_lon, Spatial_area(3));
idlon(2) = findnearpoint(imsi_lon, Spatial_area(4));

linkfull2 = sprintf("%s?lat[%d:1:%d],lon[%d:1:%d],elevation[%d:1:%d][%d:1:%d]", ...
    link1, idlat(1), idlat(2), idlon(1), idlon(2), idlat(1), idlat(2), idlon(1), idlon(2));

bedlat = double(ncread(linkfull2, "lat"));
bedlon = double(ncread(linkfull2, "lon"));
bed = double(ncread(linkfull2, "elevation"));

matname = sprintf("GEBCO2019_N%d%d_E%d%d.mat", Spatial_area);
save(sprintf('%s\\%s',fpath, matname), "bed", "bedlon", "bedlat");

% ---------------------------------------------------
function id = findnearpoint(base, target)
% find nearest point of "target" from "base"
[~, id] = min(abs(base-target)); end
% ---------------------------------------------------

end