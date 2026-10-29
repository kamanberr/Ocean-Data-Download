function failed = func_OISST_down_Jiuk(Project_Name, HOME_folder_path, Period, Spatial_area, file_type)
%FUNC_OISST_DOWN_JIUK  Download subsetted NOAA OISST v2 (daily, 0.25 deg) from NOAA PSL via OPeNDAP.
%
%   failed = func_OISST_down_Jiuk(Project_Name, HOME_folder_path, Period, Spatial_area)
%   failed = func_OISST_down_Jiuk(Project_Name, HOME_folder_path, Period, Spatial_area, file_type)
%
%   Project_Name     : folder name under HOME_folder_path
%   HOME_folder_path : root folder for saving data
%   Period           : [yyyy mm dd; yyyy mm dd]  (start date; end date)
%   Spatial_area     : [lat_start, lat_end, lon_start, lon_end]
%                      lon may be given as -180 to 180 or 0 to 360, e.g.
%                      [118 128] East Asia, [-10 10] crossing 0E, [-180 180] global.
%                      Saved lon is 0 to 360 (as in OISST), except for domains
%                      crossing 0E, which are saved as -180 to 180.
%   file_type        : 'mat' (default) | 'nc'
%   failed           : dates that could not be downloaded (run again to retry)
%
%   One file per day is saved as
%       HOME_folder_path/Project_Name/yyyy/OISST_v2_yyyy_MM_dd.mat   (struct "oisst": time, lon, lat, sst)
%       HOME_folder_path/Project_Name/yyyy/OISST_v2_yyyy_MM_dd.nc    (variables: time, lon, lat, sst)
%   Files that already exist are skipped.
%
%   written by Jiuk Hwang
%   LOG
%       [2024.10.03] Draft done.
%       [2024.10.05] modify - only download OISST
%       [2026.10.28] One subset request per chunk of days, portable paths, retry limit.
%       [2026.10.29] Output file type: 'mat' or 'nc'.
%                    Global and 0E-crossing longitude ranges supported.

if nargin < 5 || isempty(file_type), file_type = 'mat'; end
file_type = validatestring(file_type, {'mat', 'nc'});

base_url  = "http://psl.noaa.gov/thredds/dodsC/Datasets/noaa.oisst.v2.highres/sst.day.mean.%d.nc";
chunk     = 31;     % days per request (limits memory use for large domains)
max_retry = 10;
wait_s    = 15;

d = datetime(Period);
assert(numel(d) == 2 && d(1) <= d(2), ...
    'Period must be [start; end] with the start date on or before the end date.');

failed = datetime.empty(0, 1);

for yr = year(d(1)):year(d(2))
    want  = (max(d(1), datetime(yr, 1, 1)):caldays(1):min(d(2), datetime(yr, 12, 31)))';
    fpath = fullfile(HOME_folder_path, Project_Name, num2str(yr));
    if ~exist(fpath, 'dir'), mkdir(fpath); end

    fnames = "OISST_v2_" + string(want, 'yyyy_MM_dd') + "." + file_type;
    done   = isfile(fullfile(fpath, fnames));
    if all(done)
        fprintf('%d: all files already exist.\n', yr);
        continue
    end
    want = want(~done);  fnames = fnames(~done);

    try
        url = sprintf(base_url, yr);
        fprintf('Preparing download for %d...\n', yr);
        tnum = double(retry(@() ncread(url, 'time'), max_retry, wait_s));   % days since 1800-01-01
        tm   = datetime(1800, 1, 1) + days(tnum);
        lat  = double(retry(@() ncread(url, 'lat'), max_retry, wait_s));
        lon  = double(retry(@() ncread(url, 'lon'), max_retry, wait_s));

        ilat = sort([findnearpoint(lat, Spatial_area(1)), findnearpoint(lat, Spatial_area(2))]);
        nlat = diff(ilat) + 1;
        lat_sub = lat(ilat(1):ilat(2));
        [segs, lon_sub] = lon_segments(lon, Spatial_area(3:4));

        % match requested days to the time axis (first match if duplicated)
        [tf, it] = ismember(dateshift(want, 'start', 'day'), dateshift(tm, 'start', 'day'));
        if any(~tf)
            fprintf('No data on the server for: %s\n', strjoin(string(want(~tf), 'yyyy-MM-dd'), ', '));
            failed = [failed; want(~tf)]; %#ok<AGROW>
        end
        want = want(tf);  it = it(tf);  fnames = fnames(tf);

        for c = 1:chunk:numel(it)
            idx = c:min(c + chunk - 1, numel(it));
            i0  = it(idx(1));  i1 = it(idx(end));
            % sst in MATLAB order: lon x lat x time (subset on the server side)
            blk = [];
            for s = 1:numel(segs)
                st = segs{s};  nlon = st(2) - st(1) + 1;
                blk = [blk; retry(@() ncread(url, 'sst', [st(1) ilat(1) i0], [nlon nlat i1 - i0 + 1]), ...
                    max_retry, wait_s)]; %#ok<AGROW>
            end

            for k = idx
                sst = double(blk(:, :, it(k) - i0 + 1));
                sst(sst < -1e30) = NaN;     % missing value (-9.96921e+36)
                fname = fullfile(fpath, fnames(k));
                switch file_type
                    case 'mat'
                        oisst = struct('time', tm(it(k)), 'lon', lon_sub, 'lat', lat_sub, 'sst', sst);
                        save(fname, 'oisst');
                    case 'nc'
                        write_nc(fname, tnum(it(k)), lon_sub, lat_sub, sst);
                end
                fprintf('Download complete for %s\n', fnames(k));
            end
        end
    catch ME
        fprintf('Year %d failed: %s\n', yr, ME.message);
        failed = [failed; want]; %#ok<AGROW>
    end
end

failed = unique(failed);
if isempty(failed)
    disp('All requested dates were downloaded.');
else
    fprintf('%d date(s) failed. Run the function again to retry them.\n', numel(failed));
end
end

% =========================================================================
function [segs, lon_sub] = lon_segments(lon, lon_in)
% Index range(s) of the dataset longitude (0 to 360) covering lon_in.
% segs : {[i_start i_end]} or two ranges for a domain crossing 0E.
lon_in = sort(lon_in);
if diff(lon_in) >= 360 - 1e-6                       % whole globe
    segs    = {[1 numel(lon)]};
    lon_sub = lon;
    return
end
lon_req = mod(lon_in, 360);
i1 = findnearpoint(lon, lon_req(1));
i2 = findnearpoint(lon, lon_req(2));
if i1 <= i2
    segs    = {[i1 i2]};
    lon_sub = lon(i1:i2);
else                                                % crosses 0E
    segs    = {[i1 numel(lon)], [1 i2]};
    lon_sub = [lon(i1:end) - 360; lon(1:i2)];       % saved as -180 to 180
end
end

function write_nc(fname, tnum, lon, lat, sst)
% Write one day of subsetted OISST as a NetCDF-4 file (dimensions: time, lat, lon).
if isfile(fname), delete(fname); end
nccreate(fname, 'time', 'Dimensions', {'time', 1},          'Datatype', 'double', 'Format', 'netcdf4');
nccreate(fname, 'lat',  'Dimensions', {'lat', numel(lat)},  'Datatype', 'double');
nccreate(fname, 'lon',  'Dimensions', {'lon', numel(lon)},  'Datatype', 'double');
nccreate(fname, 'sst',  'Dimensions', {'lon', numel(lon), 'lat', numel(lat), 'time', 1}, ...
    'Datatype', 'single', 'FillValue', NaN, 'DeflateLevel', 4);

ncwrite(fname, 'time', tnum);
ncwrite(fname, 'lat',  lat);
ncwrite(fname, 'lon',  lon);
ncwrite(fname, 'sst',  single(sst));

ncwriteatt(fname, 'time', 'units',     'days since 1800-01-01 00:00:00');
ncwriteatt(fname, 'time', 'long_name', 'Time');
ncwriteatt(fname, 'lat',  'units',     'degrees_north');
ncwriteatt(fname, 'lat',  'long_name', 'Latitude');
ncwriteatt(fname, 'lon',  'units',     'degrees_east');
ncwriteatt(fname, 'lon',  'long_name', 'Longitude');
ncwriteatt(fname, 'sst',  'units',     'degC');
ncwriteatt(fname, 'sst',  'long_name', 'Daily Sea Surface Temperature');
ncwriteatt(fname, '/',    'title',     'NOAA OI SST V2 High Resolution (daily mean), spatial subset');
ncwriteatt(fname, '/',    'source',    'https://psl.noaa.gov/data/gridded/data.noaa.oisst.v2.highres.html');
ncwriteatt(fname, '/',    'history',   ['Subset downloaded with func_OISST_down_Jiuk.m on ' char(datetime('now'))]);
end

function out = retry(fun, max_retry, wait_s)
% Retry automatically if the download is interrupted, up to max_retry times.
for k = 1:max_retry
    try
        out = fun();
        return
    catch ME
        fprintf('  [%d/%d] %s\n', k, max_retry, ME.message);
        if k == max_retry, rethrow(ME); end
        disp('  Retrying... Please wait.');
        pause(wait_s);
    end
end
end

function id = findnearpoint(base, target)
% find nearest point of "target" from "base"
[~, id] = min(abs(base - target));
end