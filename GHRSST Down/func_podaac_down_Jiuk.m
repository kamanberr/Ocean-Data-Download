function failed = func_podaac_down_Jiuk(source, period, Spatial_area, out_dir, vars, method, lag_time)
%FUNC_PODAAC_DOWN_JIUK  Download subsetted GHRSST L4 SST from PO.DAAC via OPeNDAP.
%
%   failed = func_podaac_down_Jiuk(source, period, Spatial_area, out_dir)
%   failed = func_podaac_down_Jiuk(source, period, Spatial_area, out_dir, vars, method, lag_time)
%
%   source       : input name of the dataset (list in GHRSST_down_HOME_2_Jiuk.m)
%                  'ostia' 'ostia_rep' 'mur' 'mur25' 'gamssa' 'dmi'
%                  'ospo' 'ospo_night' 'k10' 'mw_ir_oi' 'mw_oi'
%   period       : [yyyy mm dd; yyyy mm dd]  (start date; end date)
%   Spatial_area : [lat_start, lat_end, lon_start, lon_end]  (lon: -180 to 180)
%   out_dir      : save folder (in 'browser' mode: the browser download folder)
%   vars         : variables to download, default {'analysed_sst'}
%                  all datasets : 'analysed_sst' 'analysis_error' 'sea_ice_fraction' 'mask'
%                  mur, mur25   : 'sst_anomaly' (mur only: 'dt_1km_data')
%   method       : 'token' (default) | 'browser'
%   lag_time     : seconds between requests in 'browser' mode (default 3)
%   failed       : dates that could not be downloaded (run again to retry)
%
%   The lon/lat grid of each dataset is downloaded once and cached as
%   <folder of this function>/grid/grid_<source>.nc4
%
%   written by Jiuk Hwang
%   LOG
%       [2024.10.03] Draft done.
%       [2024.10.05] Add MUR 4.1 / MUR 4.2
%       [2026.10.28] Token-based download, file verification, retry limit.
%       [2026.10.29] 11 GHRSST L4 datasets, variable selection,
%                    automatic grid caching (sample files no longer needed).

if nargin < 4 || isempty(out_dir),  out_dir  = pwd;              end
if nargin < 5 || isempty(vars),     vars     = {'analysed_sst'}; end
if nargin < 6 || isempty(method),   method   = 'token';          end
if nargin < 7 || isempty(lag_time), lag_time = 3;                end
vars      = cellstr(vars);
method    = validatestring(method, {'token', 'browser'});
max_retry = 5;
wait_s    = 10;

% ---------------------------------------------------------------- dataset
C     = dataset_config();
names = fieldnames(C);
k     = find(strcmpi(source, names), 1);
if isempty(k)
    error('Unknown source "%s". Valid names: %s', source, strjoin(names', ', '));
end
key = names{k};  cfg = C.(key);

% ---------------------------------------------------------------- period
d = datetime(period);
assert(numel(d) == 2 && d(1) <= d(2), ...
    'period must be [start; end] with the start date on or before the end date.');
if d(1) < cfg.first || d(2) > cfg.last
    warning('%s covers %s to %s. Dates outside this range will fail.', key, ...
        string(cfg.first, 'yyyy-MM-dd'), string(cfg.last, 'yyyy-MM-dd'));
end
dates = (d(1):caldays(1):d(2))';

% ---------------------------------------------------------------- token
opts = [];
if strcmp(method, 'token')
    token = getenv('EARTHDATA_TOKEN');
    if isempty(token)
        error(['EARTHDATA_TOKEN is not set. Run setenv(''EARTHDATA_TOKEN'', ''<your token>'') ' ...
            'or use method = ''browser''.']);
    end
    opts = weboptions('HeaderFields', {'Authorization', ['Bearer ' token]}, 'Timeout', 300);
end

% ---------------------------------------------------------------- grid (cached)
grid_dir  = fullfile(fileparts(mfilename('fullpath')), 'grid');
grid_file = fullfile(grid_dir, ['grid_' key '.nc4']);
if ~isfile(grid_file)
    if ~exist(grid_dir, 'dir'), mkdir(grid_dir); end
    grid_url = [cfg.url1 char(cfg.sample, 'yyyyMMdd') cfg.gname '.dap.nc4?dap4.ce=/lat;/lon'];
    switch method
        case 'token'
            fprintf('Downloading lon/lat grid of %s (first time only)...\n', key);
            websave(grid_file, grid_url, opts);
            ncinfo(grid_file);
        case 'browser'
            web(grid_url);
            error(['Grid file not found. Move the file just downloaded by the browser to\n' ...
                '  %s\nand run again.'], grid_file);
    end
end
lat = double(ncread(grid_file, 'lat'));
lon = double(ncread(grid_file, 'lon'));

lon_req = Spatial_area(3:4);
if max(lon) > 180, lon_req = mod(lon_req, 360); end     % dataset uses 0 to 360
idlat = sort([findnearpoint(lat, Spatial_area(1)), findnearpoint(lat, Spatial_area(2))]);
idlon = sort([findnearpoint(lon, lon_req(1)),      findnearpoint(lon, lon_req(2))]);

% OPeNDAP indices start at 0, so each index is "ID - 1".
ce = sprintf('/time[0:1:0];/lat[%d:1:%d];/lon[%d:1:%d]', idlat - 1, idlon - 1);
for v = 1:numel(vars)
    ce = [ce sprintf(';/%s[0:1:0][%d:1:%d][%d:1:%d]', vars{v}, idlat - 1, idlon - 1)]; %#ok<AGROW>
end

if ~exist(out_dir, 'dir'), mkdir(out_dir); end
failed = datetime.empty(0, 1);

% ---------------------------------------------------------------- download
switch method
    case 'token'
        for k = 1:numel(dates)
            ymd     = char(dates(k), 'yyyyMMdd');
            outfile = fullfile(out_dir, [ymd cfg.gname '.nc4']);
            if isfile(outfile)
                fprintf('%s already exists. Skipped.\n', ymd);
                continue
            end
            url = [cfg.url1 ymd cfg.gname '.dap.nc4?dap4.ce=' encode_ce(ce)];

            fprintf('Downloading %s ...\n', ymd);
            ok = false;
            for attempt = 1:max_retry
                try
                    websave(outfile, url, opts);
                    ncinfo(outfile);    % valid NetCDF, not an HTML error page
                    ok = true;
                    break
                catch ME
                    if isfile(outfile), delete(outfile); end
                    if contains(ME.identifier, 'HTTP401')
                        error('Authentication failed. Check or regenerate EARTHDATA_TOKEN.');
                    end
                    fprintf('  [%d/%d] %s\n', attempt, max_retry, ME.message);
                    pause(wait_s);
                end
            end
            if ok
                fprintf('  Done: %s\n', outfile);
            else
                failed(end+1, 1) = dates(k); %#ok<AGROW>
            end
        end

    case 'browser'
        % Requires an active Earthdata login in the MATLAB web browser.
        % If the downloaded files share the SAME NAME, INCREASE lag_time.
        for k = 1:numel(dates)
            ymd = char(dates(k), 'yyyyMMdd');
            if isfile(fullfile(out_dir, [ymd cfg.gname '.nc4']))
                fprintf('%s already exists. Skipped.\n', ymd);
                continue
            end
            fprintf('Requesting %s ...\n', ymd);
            web([cfg.url1 ymd cfg.gname '.dap.nc4?dap4.ce=' ce]);
            pause(lag_time);
        end
        pause(10);  % allow the last downloads to finish
        for k = 1:numel(dates)
            ymd = char(dates(k), 'yyyyMMdd');
            if ~isfile(fullfile(out_dir, [ymd cfg.gname '.nc4']))
                failed(end+1, 1) = dates(k); %#ok<AGROW>
            end
        end
end

if isempty(failed)
    fprintf('All requested dates are available in %s\n', out_dir);
else
    fprintf('%d date(s) failed. Run the function again to retry them.\n', numel(failed));
end
end

% =========================================================================
function C = dataset_config()
% url1 : OPeNDAP collection URL | gname : granule name after the date
% first/last : coverage | sample : a date known to exist (used for the grid)
u = 'https://opendap.earthdata.nasa.gov/collections/';
C.ostia      = mk([u 'C2036877535-POCLOUD/granules/'], '120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.0-fv02.0',             [2006 12 31], [],           [2019 9 9]);
C.ostia_rep  = mk([u 'C2586786218-POCLOUD/granules/'], '120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB_REP-v02.0-fv02.0',         [1982 1 1],   [2023 12 31], [2023 12 20]);
C.mur        = mk([u 'C1996881146-POCLOUD/granules/'], '090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1',                [2002 5 31],  [],           [2022 9 7]);
C.mur25      = mk([u 'C2036880657-POCLOUD/granules/'], '090000-JPL-L4_GHRSST-SSTfnd-MUR25-GLOB-v02.0-fv04.2',              [2002 8 31],  [],           [2026 10 5]);
C.gamssa     = mk([u 'C2036881735-POCLOUD/granules/'], '120000-ABOM-L4_GHRSST-SSTfnd-GAMSSA_28km-GLOB-v02.0-fv01.0',       [2008 7 23],  [],           [2026 10 24]);
C.dmi        = mk([u 'C2036881727-POCLOUD/granules/'], '000000-DMI-L4_GHRSST-SSTfnd-DMI_OI-GLOB-v02.0-fv01.0',             [2013 4 30],  [],           [2019 7 7]);
C.ospo       = mk([u 'C2036877754-POCLOUD/granules/'], '000000-OSPO-L4_GHRSST-SSTfnd-Geo_Polar_Blended-GLOB-v02.0-fv01.0', [2014 6 2],   [],           [2023 5 4]);
C.ospo_night = mk([u 'C2036877745-POCLOUD/granules/'], '000000-OSPO-L4_GHRSST-SSTfnd-Geo_Polar_Blended_Night-GLOB-v02.0-fv01.0', [2014 6 2], [],       [2018 5 4]);
C.k10        = mk([u 'C2036881956-POCLOUD/granules/'], '000000-NAVO-L4_GHRSST-SST1m-K10_SST-GLOB-v02.0-fv01.0',            [2019 1 9],   [],           [2021 5 5]);
C.mw_ir_oi   = mk([u 'C2205102254-POCLOUD/granules/'], '120000-REMSS-L4_GHRSST-SSTfnd-MW_IR_OI-GLOB-v02.0-fv05.1',         [2002 6 1],   [],           [2012 10 10]);
C.mw_oi      = mk([u 'C2205105895-POCLOUD/granules/'], '120000-REMSS-L4_GHRSST-SSTfnd-MW_OI-GLOB-v02.0-fv05.1',            [1997 12 31], [],           [2002 6 6]);
end

function c = mk(url1, gname, first, last, sample)
if isempty(last), last = [2100 1 1]; end     % still updated
c = struct('url1', url1, 'gname', gname, 'first', datetime(first), ...
    'last', datetime(last), 'sample', datetime(sample));
end

function id = findnearpoint(base, target)
% find nearest point of "target" from "base"
[~, id] = min(abs(base - target));
end

function s = encode_ce(s)
% percent-encode characters in the DAP4 constraint that websave may reject
s = strrep(s, '[', '%5B');
s = strrep(s, ']', '%5D');
s = strrep(s, ';', '%3B');
end