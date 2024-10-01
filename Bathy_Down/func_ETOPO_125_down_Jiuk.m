function func_ETOPO_125_down_Jiuk(version, Spatial_area, format)
%   written by Jiuk Hwang
%   LOG
%       [2024.10.01] Draft done.
if version == 1         % -90~90, -180~180
    % https://apdrc.soest.hawaii.edu/erddap/griddap/hawaii_soest_794e_6df2_6381.html
    link = sprintf("https://apdrc.soest.hawaii.edu/erddap/griddap/" + ...
        "hawaii_soest_794e_6df2_6381.%s?b_bathy" + ...
        "[(0000-01-01T00:00:00Z):1:(0000-01-01T00:00:00Z)]" + ...
        "[(%d):1:(%d)][(%d):1:(%d)]", format, Spatial_area);
    web(link);
elseif version == 2     % -90~90, -180~180
    % https://apdrc.soest.hawaii.edu/erddap/griddap/hawaii_soest_bc8b_7e44_d573.html
    link = sprintf("https://apdrc.soest.hawaii.edu/erddap/griddap/" + ...
        "hawaii_soest_bc8b_7e44_d573.%s?b_bathy" + ...
        "[(0000-01-01T00:00:00Z):1:(0000-01-01T00:00:00Z)]" + ...
        "[(%d):1:(%d)][(%d):1:(%d)]", format, Spatial_area);
    web(link);
elseif version == 5     % -90~90, -180~180
    % https://pae-paha.pacioos.hawaii.edu/erddap/griddap/etopo5_lon180.html
        link = sprintf("https://pae-paha.pacioos.hawaii.edu/erddap/griddap/" + ...
            "etopo5_lon180.%s?ROSE%%5B(%d):1:(%d)%%5D%%5B(%d):1:(%d)%%5D", ...
            format, Spatial_area);
    web(link);
else;     disp('Wrong Input in "Version"');
end
end