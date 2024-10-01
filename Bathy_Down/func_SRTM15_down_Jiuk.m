function func_SRTM15_down_Jiuk(Spatial_area, format)
%   written by Jiuk Hwang
%   LOG
%       [2024.10.01] Draft done.

% https://hfr.marine.rutgers.edu/erddap/griddap/bathymetry_srtm15_v24.html
link = sprintf("https://hfr.marine.rutgers.edu/erddap/griddap/" + ...
    "bathymetry_srtm15_v24.%s?z%%5B(%d):1:(%d)%%5D%%5B" + ...
    "(%d):1:(%d)%%5D", ...
    format, Spatial_area);
web(link);

end