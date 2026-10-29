%% Load Bathymetry data from various Sources
%   [2024.10.01] written by Jiuk Hwang
%   [2024.10.03] Modify : ETOPO 1, 2 download link
%                Debugging : GEBCO, ETOPO 2022 - extract range
%   [2024.10.03] Delete section for ETOPO 1, 2, 5 and GEBCO 2019
%   [2026.10.28] Bug fix : ETOPO 2022 30/60 arc links were swapped
%                Bug fix : SRTM15+ query broke with non-integer coordinates
%                Change  : SRTM15+ downloads directly (no browser)
%                Change  : unified output variables (bed, bedlon, bedlat)
%                Change  : 'mat' / 'nc' output for both datasets
%                Change  : longitude input accepted in -180~180 or 0~360,
%                          including areas crossing the dateline or 0 deg
%                Change  : file names use hemisphere tags (22N-54N_118E-144E)
%                Tested  : longitude conventions, dateline / prime-meridian
%                          crossing, global strip, mat-nc consistency
%   [2026.10.28] Add     : S2Shores global bathymetry (CNES-LEGOS, 30 arc-second)
%                          requires an AVISO+ account
%                Change  : dimension order of the data variable is detected
%                          from its size, not only from dimension names
%
%   Note : run each section separately (Ctrl + Enter).
%          Both ETOPO 2022 and SRTM15+ are cell-centered (pixel-registered)
%          grids, so grid points sit half a cell inside integer boundaries
%          (e.g. 118.0083 for a 118E boundary at 60 arc-second).
%          Saved longitude follows the input convention (e.g. 170~190).

%% ETOPO 2022 - 30 arc / 60 arc
clc; clear;
% [lat start, lat end, lon start, lon end]
% lat : -90~90 / lon : -180~180 or 0~360 (dateline crossing allowed)
Spatial_area = [22, 54, 118, 144];
% resolution : 30 (arc-second) / 60 (arc-second)
resolution = 60;
% folder where you want to save the data
fpath = 'D:\MATLAB_JU\RawData\Bathy';
% file format : 'mat' / 'nc'
format = 'nc';
func_ETOPO2022_down_Jiuk(Spatial_area, resolution, fpath, format);

%% SRTM 15+
clc; clear;
% [lat start, lat end, lon start, lon end]
% lat : -90~90 / lon : -180~180 or 0~360 (dateline crossing allowed)
Spatial_area = [22, 54, 118, 144];
% file format : 'mat' / 'nc' / 'csv' / 'png' / 'largePng' / 'pdf'
%   csv / png / largePng / pdf are rendered by ERDDAP and cannot cross
%   the dataset's longitude seam.
format = 'nc';
% folder where you want to save the data
fpath = 'D:\MATLAB_JU\RawData\Bathy';
% stride : 1 = full 15 arc-second resolution, 2 = every 2nd point, ...
stride = 1;
% Please be patient. A large area at full resolution may take a while.
func_SRTM15_down_Jiuk(Spatial_area, format, fpath, stride);

%% S2Shores (CNES-LEGOS) - 30 arc
clc; clear;
% [lat start, lat end, lon start, lon end]
% lat : -90~90 / lon : -180~180 or 0~360 (dateline crossing allowed)
Spatial_area = [33, 36, 127, 129];
% variable : 'blended' (S2Shores blended with GEBCO) / 'raw' (S2Shores only)
variable = 'blended';
% folder where you want to save the data
fpath = 'D:\MATLAB_JU\RawData\Bathy';
% file format : 'mat' / 'nc'
format = 'nc';
% stride : 1 = full 30 arc-second resolution, 2 = every 2nd point, ...
stride = 1;
% AVISO+ account (required)
%   Leave empty to use the AVISO_USERNAME / AVISO_PASSWORD environment
%   variables, or a .netrc file, instead of typing them in the script.
username = '~~@gmail.com';
password = '~~~~~';
func_S2Shores_down_Jiuk(Spatial_area, variable, fpath, format, stride, username, password);

%% ========================================================================
function outfile = func_ETOPO2022_down_Jiuk(Spatial_area, resolution, fpath, format)
%FUNC_ETOPO2022_DOWN_JIUK  Download ETOPO 2022 bedrock elevation subset.
%   outfile = func_ETOPO2022_down_Jiuk([lat1 lat2 lon1 lon2], res, fpath, format)
%   lon    : -180~180 or 0~360; areas crossing the dateline are allowed.
%            Output longitude follows the input convention (e.g. 170~190).
%   res    : 30 or 60 (arc-second)
%   format : 'mat' (default) / 'nc'
%   mat : bed [nlon x nlat], bedlon [nlon x 1], bedlat [nlat x 1] (ascending)
%   nc  : lon(lon), lat(lat), z(lat, lon) in CDL order (netCDF-4, compressed)
%
%   written by Jiuk Hwang
%   LOG
%       [2024.05.16] 30 arc Draft done.
%       [2024.06.24] 60 arc Draft done.
%       [2024.10.01] combine two script for convenience.
%       [2026.10.28] fix swapped links, ncread start/count subsetting,
%                    netCDF output, longitude convention handling.

if nargin < 3 || isempty(fpath),  fpath  = pwd;   end
if nargin < 4 || isempty(format), format = 'mat'; end
format = check_format(format, ["mat", "nc"]);
check_area(Spatial_area);

switch resolution
    case 30, res = "30s";
    case 60, res = "60s";
    otherwise
        error('resolution must be 30 or 60 (arc-second).');
end

% ETOPO 2022 Bedrock elevation (NOAA NCEI THREDDS, OPeNDAP)
url = sprintf("https://www.ngdc.noaa.gov/thredds/dodsC/global/ETOPO2022/" + ...
    "%s/%s_bed_elev_netcdf/ETOPO_2022_v1_%s_N90W180_bed.nc", res, res, res);

[bed, bedlon, bedlat] = read_subset(url, Spatial_area, 1);

fname = sprintf("ETOPO2022_bedrock_%darc_%s", resolution, area_tag(Spatial_area));
meta = struct("varname", "bed", "long_name", "bedrock elevation (positive up)", ...
    "title", sprintf("ETOPO 2022 bedrock elevation, %d arc-second subset", resolution), ...
    "source", url);
outfile = save_grid(fullfile(fpath, fname), format, bed, bedlon, bedlat, meta);
end


%% ========================================================================
function outfile = func_SRTM15_down_Jiuk(Spatial_area, format, fpath, stride)
%FUNC_SRTM15_DOWN_JIUK  Download SRTM15+ subset from Rutgers ERDDAP.
%   outfile = func_SRTM15_down_Jiuk([lat1 lat2 lon1 lon2], format, fpath, stride)
%   lon    : -180~180 or 0~360; areas crossing the dateline are allowed
%            for 'mat' and 'nc'.
%   format : 'mat' (default) / 'nc' / 'csv' / 'png' / 'largePng' / 'pdf'
%   stride : 1 (default) = full 15 arc-second resolution
%   mat / nc use the same variables and layout as func_ETOPO2022_down_Jiuk.
%
%   written by Jiuk Hwang
%   LOG
%       [2024.10.01] Draft done.
%       [2026.10.28] direct download, stride option, unified output,
%                    longitude convention handling.
%   Source:
%   https://hfr.marine.rutgers.edu/erddap/griddap/bathymetry_srtm15_v24.html

if nargin < 2 || isempty(format), format = 'mat'; end
if nargin < 3 || isempty(fpath),  fpath  = pwd;   end
if nargin < 4 || isempty(stride), stride = 1;     end
format = check_format(format, ["mat", "nc", "csv", "png", "largepng", "pdf"]);
check_area(Spatial_area);
check_stride(stride);

base  = "https://hfr.marine.rutgers.edu/erddap/griddap/bathymetry_srtm15_v24";
fname = sprintf("SRTM15v24_%s", area_tag(Spatial_area));
if stride > 1, fname = fname + sprintf("_stride%d", stride); end

if ismember(format, ["mat", "nc"])
    % read through ERDDAP's OPeNDAP endpoint, same path as ETOPO
    [bed, bedlon, bedlat] = read_subset(base, Spatial_area, stride);
    meta = struct("varname", "bed", "long_name", "elevation (positive up)", ...
        "title", "SRTM15+ V2.4 elevation subset", "source", base);
    outfile = save_grid(fullfile(fpath, fname), format, bed, bedlon, bedlat, meta);
    return
end

% ERDDAP-rendered files : index-based query in the dataset's own order
G    = grid_info(base);
ilat = select_lat(G.lat, Spatial_area(1), Spatial_area(2), stride);
runs = select_lon(G.lon, Spatial_area(3), Spatial_area(4), stride);
if numel(runs) > 1
    error(['This area crosses the dataset''s longitude seam. ' ...
           'Use ''mat'' or ''nc'' format instead.']);
end
r    = runs{1};
qlat = sprintf("%%5B%d:%d:%d%%5D", ilat(1)-1, stride, ilat(end)-1);
qlon = sprintf("%%5B%d:%d:%d%%5D", r(1)-1,    stride, r(end)-1);
if G.latfirst, q = qlon + qlat; else, q = qlat + qlon; end   % CDL order

if format == "largepng", ext = "png"; srv = "largePng";
else, ext = format; srv = format; end
outfile = fullfile(fpath, fname + "." + ext);
websave(outfile, base + "." + srv + "?" + G.zname + q, weboptions("Timeout", 600));
fprintf('Saved: %s\n', outfile);
end


%% ========================================================================
function outfile = func_S2Shores_down_Jiuk(Spatial_area, variable, fpath, format, stride, username, password)
%FUNC_S2SHORES_DOWN_JIUK  Download S2Shores global bathymetry subset.
%   outfile = func_S2Shores_down_Jiuk([lat1 lat2 lon1 lon2], variable, fpath, ...
%                                     format, stride, username, password)
%   lon      : -180~180 or 0~360; areas crossing the dateline are allowed.
%   variable : 'blended' (default) satellite-derived depth blended with GEBCO
%              'raw'               satellite-derived depth only
%                                  (coastal areas; NaN elsewhere)
%   format   : 'mat' (default) / 'nc'
%   stride   : 1 (default) = full 30 arc-second resolution
%   mat : depth [nlon x nlat], bedlon [nlon x 1], bedlat [nlat x 1] (ascending)
%   nc  : lon(lon), lat(lat), depth(lat, lon) in CDL order
%   Depth is positive below mean sea level (positive down), following the
%   source dataset, so it is stored as "depth" rather than "bed"
%   (positive-up elevation in ETOPO / SRTM). Use -depth to compare with bed.
%
%   Authentication : the AVISO THREDDS server requires an AVISO+ account.
%   Credentials are taken, in this order, from
%     1) the username / password arguments,
%     2) the AVISO_USERNAME / AVISO_PASSWORD environment variables
%        (e.g. setenv("AVISO_USERNAME", "...") in startup.m),
%     3) a .netrc file referenced by .dodsrc (HTTP.NETRC=...).
%   Credentials are used only for the request and are never saved to files.
%
%   written by Jiuk Hwang
%   LOG
%       [2026.10.28] Draft done.
%       [2026.10.28] AVISO+ authentication (arguments / environment / .netrc).
%   Source:
%   S2Shores Spatio-Temporal Global Bathymetry Median Composite from
%   Sentinel-2 images (CNES-LEGOS), version 15012025, AVISO / ODATIS THREDDS
%   Reference : Almar et al. (2025), Scientific Data, 12, 1941.
%               doi:10.1038/s41597-025-06402-w

if nargin < 2 || isempty(variable), variable = 'blended'; end
if nargin < 3 || isempty(fpath),    fpath    = pwd;       end
if nargin < 4 || isempty(format),   format   = 'mat';     end
if nargin < 5 || isempty(stride),   stride   = 1;         end
if nargin < 6 || isempty(username), username = getenv("AVISO_USERNAME"); end
if nargin < 7 || isempty(password), password = getenv("AVISO_PASSWORD"); end
format = check_format(format, ["mat", "nc"]);
check_area(Spatial_area);
check_stride(stride);

variable = lower(string(variable));
switch variable
    case "blended"
        zname = "Depth_S2Shores_blended";
        desc  = "satellite-derived water depth blended with GEBCO 2020 (positive down, below mean sea level)";
    case "raw"
        zname = "Depth_S2Shores";
        desc  = "satellite-derived water depth (positive down, below mean sea level)";
    otherwise
        error('variable must be ''blended'' or ''raw''.');
end

host = "tds-odatis.aviso.altimetry.fr";
path = "/thredds/dodsC/coastal_s2shores/S2Shores_global_bathymetry_blended_15012025.nc";
url  = "https://" + host + path;                 % saved as source (no credentials)
if strlength(string(username)) > 0 && strlength(string(password)) > 0
    url_req = "https://" + pct_encode(username) + ":" + pct_encode(password) + ...
              "@" + host + path;
else
    url_req = url;                               % rely on .netrc / .dodsrc
end

try
    [depth, bedlon, bedlat] = read_subset(url_req, Spatial_area, stride, zname);
catch ME
    msg = ME.message;
    if strlength(string(password)) > 0           % never echo the password
        msg = strrep(msg, char(pct_encode(password)), '***');
        msg = strrep(msg, char(password), '***');
    end
    if contains(msg, "-77") || contains(msg, "Access failure", "IgnoreCase", true)
        error(['Access to the AVISO THREDDS server was denied (HTTP 401). ' ...
               'Check your AVISO+ account and its access to S2Shores, then ' ...
               'provide credentials as arguments, AVISO_USERNAME / ' ...
               'AVISO_PASSWORD environment variables, or a .netrc file.']);
    end
    error(msg);
end

fname = sprintf("S2Shores_%s_30arc_%s", variable, area_tag(Spatial_area));
if stride > 1, fname = fname + sprintf("_stride%d", stride); end
meta = struct("varname", "depth", "long_name", desc, ...
    "title", "S2Shores global bathymetry (CNES-LEGOS), 30 arc-second subset", ...
    "source", url);
outfile = save_grid(fullfile(fpath, fname), format, depth, bedlon, bedlat, meta);
end


%% ========================================================================
%  Shared helpers
%  ========================================================================
function [bed, bedlon, bedlat] = read_subset(url, area, stride, zname)
% Read a lat/lon subset over OPeNDAP, handling longitude convention,
% seam crossing and descending latitude.
if nargin < 4, zname = []; end
G    = grid_info(url, zname);
ilat = select_lat(G.lat, area(1), area(2), stride);
[runs, bedlon] = select_lon(G.lon, area(3), area(4), stride);
nlat  = numel(ilat);
parts = cell(numel(runs), 1);
for k = 1:numel(runs)
    r = runs{k};
    if G.latfirst      % variable stored as [lat x lon] in MATLAB order
        parts{k} = double(ncread(url, G.zname, [ilat(1) r(1)], ...
            [nlat numel(r)], [stride stride]))';
    else               % [lon x lat]
        parts{k} = double(ncread(url, G.zname, [r(1) ilat(1)], ...
            [numel(r) nlat], [stride stride]));
    end
end
bed    = vertcat(parts{:});
bedlat = G.lat(ilat);
if nlat > 1 && bedlat(2) < bedlat(1)     % make latitude ascending
    bedlat = flipud(bedlat);
    bed    = bed(:, end:-1:1);
end
end

% -------------------------------------------------------------------------
function G = grid_info(url, zname)
% Detect variable names, dimension order and coordinate axes.
info  = ncinfo(url);
vname = string({info.Variables.Name});
G.latname = pick_name(vname, ["lat", "latitude"]);
G.lonname = pick_name(vname, ["lon", "longitude"]);
if nargin < 2 || isempty(zname)
    G.zname = pick_name(vname, ["z", "elevation", "bed", "topo"]);
else
    G.zname = pick_name(vname, string(zname));
end
G.lat = double(ncread(url, G.latname));
G.lon = double(ncread(url, G.lonname));

zinfo = info.Variables(vname == G.zname);
sz    = zinfo.Size;
nlat  = numel(G.lat);  nlon = numel(G.lon);
if numel(sz) ~= 2 || ~isequal(sort(sz), sort([nlat nlon]))
    error('Variable %s must be a 2-D [lat, lon] grid.', G.zname);
end
if nlat ~= nlon
    G.latfirst = (sz(1) == nlat);
else
    dname = string({zinfo.Dimensions.Name});
    G.latfirst = (dname(1) == G.latname);
end
end

function name = pick_name(vname, candidates)
for c = candidates
    if any(vname == c), name = c; return; end
end
error('None of the variables [%s] found in the dataset.', strjoin(candidates, ', '));
end

% -------------------------------------------------------------------------
function [runs, outlon] = select_lon(lon, lon1, lon2, stride)
% Select longitudes within [lon1, lon2] for any axis convention
% (-180~180 or 0~360). Returns storage-index runs in output order and
% longitudes expressed continuously from lon1 (the input convention).
tol = 1e-6;
lon = lon(:);
if ~issorted(lon)
    error('Longitude axis must be monotonically increasing.');
end
n = numel(lon);
if abs(lon(end) - lon(1) - 360) < tol    % both ends stored (e.g. -180 and 180)
    n = n - 1;
end
cand = (1:n)';
rel  = mod(lon(cand) - lon1, 360);
rel(rel > 360 - tol) = 0;                % rounding just below lon1
span = lon2 - lon1;
if span >= 360 - tol
    sel = true(n, 1);
else
    sel = rel <= span + tol;
end
if ~any(sel)
    error('No longitude grid points found in the requested area.');
end
idx = cand(sel);  rel = rel(sel);
[rel, o] = sort(rel);  idx = idx(o);
idx = idx(1:stride:end);  rel = rel(1:stride:end);
outlon = lon1 + rel;
brk  = [0; find(diff(idx) ~= stride); numel(idx)];
runs = cell(numel(brk) - 1, 1);
for k = 1:numel(runs)
    runs{k} = idx(brk(k)+1 : brk(k+1));
end
end

function ilat = select_lat(lat, lat1, lat2, stride)
% Storage indices of latitudes within [lat1, lat2] (ascending or descending axis).
tol  = 1e-6;
ilat = find(lat(:) >= lat1 - tol & lat(:) <= lat2 + tol);
if isempty(ilat)
    error('No latitude grid points found in the requested area.');
end
ilat = ilat(1:stride:end);
end

% -------------------------------------------------------------------------
function outfile = save_grid(fbase, format, z, lon, lat, meta)
% meta : varname, long_name, title, source
outfile = string(fbase) + "." + format;
switch format
    case "mat"
        S.(meta.varname) = z;
        S.bedlon = lon;
        S.bedlat = lat;
        save(outfile, "-struct", "S");

    case "nc"
        if isfile(outfile), delete(outfile); end   % nccreate cannot overwrite
        v = meta.varname;
        nlon = numel(lon);  nlat = numel(lat);
        nccreate(outfile, "lon", "Dimensions", {"lon", nlon}, ...
            "Datatype", "double", "Format", "netcdf4");
        nccreate(outfile, "lat", "Dimensions", {"lat", nlat}, ...
            "Datatype", "double");
        % MATLAB order {lon, lat} -> CDL order (lat, lon)
        nccreate(outfile, v, "Dimensions", {"lon", nlon, "lat", nlat}, ...
            "Datatype", "single", "DeflateLevel", 4, ...
            "FillValue", single(-99999));
        ncwrite(outfile, "lon", lon);
        ncwrite(outfile, "lat", lat);
        ncwrite(outfile, v,     single(z));
        ncwriteatt(outfile, "lon", "units", "degrees_east");
        ncwriteatt(outfile, "lon", "long_name", "longitude");
        ncwriteatt(outfile, "lat", "units", "degrees_north");
        ncwriteatt(outfile, "lat", "long_name", "latitude");
        ncwriteatt(outfile, v,     "units", "m");
        ncwriteatt(outfile, v,     "long_name", meta.long_name);
        ncwriteatt(outfile, "/",   "title",  meta.title);
        ncwriteatt(outfile, "/",   "source", meta.source);
        ncwriteatt(outfile, "/",   "history", ...
            "Created " + string(datetime("now", "Format", "yyyy-MM-dd HH:mm")) + ...
            " by load_bathymetry_Jiuk");
end
fprintf('Saved: %s\n', outfile);
end

% -------------------------------------------------------------------------
function format = check_format(format, allowed)
format = lower(string(format));
if ~ismember(format, allowed)
    error('format must be one of: %s', strjoin(allowed, ', '));
end
end

function s = pct_encode(s)
% percent-encode a string for the user-info part of a URL (RFC 3986)
b   = unicode2native(char(s), 'UTF-8');
ok  = (b >= 'A' & b <= 'Z') | (b >= 'a' & b <= 'z') | (b >= '0' & b <= '9') | ...
      b == '-' | b == '.' | b == '_' | b == '~';
out = '';
for k = 1:numel(b)
    if ok(k), out = [out char(b(k))];               %#ok<AGROW>
    else,     out = [out sprintf('%%%02X', b(k))];  %#ok<AGROW>
    end
end
s = string(out);
end

function check_stride(stride)
if ~isnumeric(stride) || ~isscalar(stride) || stride < 1 || stride ~= round(stride)
    error('stride must be a positive integer.');
end
end

function check_area(a)
% validate [lat1 lat2 lon1 lon2]
if ~isnumeric(a) || numel(a) ~= 4
    error('Spatial_area must be [lat start, lat end, lon start, lon end].');
end
if any(a(1:2) < -90 | a(1:2) > 90)
    error('Latitude must be within -90~90.');
end
if any(a(3:4) < -180 | a(3:4) > 360)
    error('Longitude must be within -180~360 (either -180~180 or 0~360).');
end
if a(1) >= a(2) || a(3) >= a(4)
    error('Start value must be smaller than end value.');
end
if a(4) - a(3) > 360
    error('Longitude span cannot exceed 360 degrees.');
end
end

function tag = area_tag(a)
% e.g. [22 54 118 144] -> "22N-54N_118E-144E"
tag = sprintf("%s-%s_%s-%s", hemi(a(1), "N", "S"), hemi(a(2), "N", "S"), ...
                             hemi(a(3), "E", "W"), hemi(a(4), "E", "W"));
end

function s = hemi(x, pos, neg)
if x >= 0, s = sprintf("%g%s", x, pos); else, s = sprintf("%g%s", -x, neg); end
end