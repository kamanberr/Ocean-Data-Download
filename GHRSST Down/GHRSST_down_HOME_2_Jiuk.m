%% SST Download (OISST from NOAA PSL, GHRSST L4 from PO.DAAC)
%   written by Jiuk Hwang
%   LOG
%       [2024.10.03] Draft done.
%       [2024.10.05] Modify url address.
%       [2025.02.21] Add description.
%       [2026.10.28] Token-based download, missing-date check integrated.
%       [2026.10.29] 11 GHRSST L4 datasets from PO.DAAC. OISST output: mat or nc.
%
% < How to use >
%   OISST  : set the area and period, and run the OISST section.
%   PO.DAAC: 1. Earthdata token setup (section below, once per MATLAB session)
%            2. choose the dataset by its input name (list below)
%            3. set the area and period, and run.
%            The lon/lat grid of each dataset is downloaded automatically on the first run.
%
%   Units : OISST "sst" in degrees Celsius, GHRSST "analysed_sst" in Kelvin.
%   OISST accepts any longitude range (e.g. [-180 180] global). GHRSST domains crossing the dateline are not supported.
%
% =========================================================================
%% [1] OISST v2 (NOAA PSL)
%   NOAA OI SST V2 High Resolution | sst.day.mean | 1981-Sep-01 to present | 0.25 deg
%   https://psl.noaa.gov/data/gridded/data.noaa.oisst.v2.highres.html
clc; clear;

Project_Name     = "OISST";                       % folder name
HOME_folder_path = fullfile(pwd, "Raw Data");     % root folder for saving data

period       = [2018, 8, 1; 2018, 8, 2];     % [start y,m,d ; end y,m,d]
Spatial_area = [-90, 90, -180, 180];            % [lat start, lat end, lon start, lon end] (lon: -180 to 180 or 0 to 360)
file_type    = 'nc';                          % output file type: 'mat' | 'nc'

failed = func_OISST_down_Jiuk(Project_Name, HOME_folder_path, period, Spatial_area, file_type);
if ~isempty(failed), disp(failed); end

% =========================================================================
%% [2] GHRSST L4 (PO.DAAC)  -  dataset list
%   input name : full name | short name | period | grid | link
%
%   'ostia'      : GHRSST Level 4 OSTIA Global Foundation Sea Surface Temperature Analysis
%                  OSTIA-UKMO-L4-GLOB-v2.0 | 2006-Dec-31 to present | 0.05 deg
%                  https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-v2.0
%   'ostia_rep'  : GHRSST Level 4 OSTIA Global Historical Reprocessed Foundation Sea Surface Temperature Analysis
%                  OSTIA-UKMO-L4-GLOB-REP-v2.0 | 1982-Jan-01 to 2023-Dec-31 | 0.05 deg
%                  https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-REP-v2.0
%   'mur'        : GHRSST Level 4 MUR Global Foundation Sea Surface Temperature Analysis (v4.1)
%                  MUR-JPL-L4-GLOB-v4.1 | 2002-May-31 to present | 0.01 deg
%                  https://podaac.jpl.nasa.gov/dataset/MUR-JPL-L4-GLOB-v4.1
%   'mur25'      : GHRSST Level 4 MUR 0.25deg Global Foundation Sea Surface Temperature Analysis (v4.2)
%                  MUR25-JPL-L4-GLOB-v04.2 | 2002-Aug-31 to present | 0.25 deg
%                  https://podaac.jpl.nasa.gov/dataset/MUR25-JPL-L4-GLOB-v04.2
%   'gamssa'     : GHRSST Level 4 GAMSSA_28km Global Foundation Sea Surface Temperature Analysis v1.0 (GDS2)
%                  GAMSSA_28km-ABOM-L4-GLOB-v01 | 2008-Jul-23 to present | 0.25 deg
%                  https://podaac.jpl.nasa.gov/dataset/GAMSSA_28km-ABOM-L4-GLOB-v01
%   'dmi'        : GHRSST Level 4 DMI_OI Global Foundation Sea Surface Temperature Analysis (GDS version 2)
%                  DMI_OI-DMI-L4-GLOB-v1.0 | 2013-Apr-30 to present | 0.05 deg
%                  https://podaac.jpl.nasa.gov/dataset/DMI_OI-DMI-L4-GLOB-v1.0
%   'ospo'       : GHRSST Level 4 OSPO Global Foundation Sea Surface Temperature Analysis (GDS version 2)
%                  Geo_Polar_Blended-OSPO-L4-GLOB-v1.0 | 2014-Jun-02 to present | 0.054 deg
%                  https://podaac.jpl.nasa.gov/dataset/Geo_Polar_Blended-OSPO-L4-GLOB-v1.0
%   'ospo_night' : GHRSST Level 4 OSPO Global Nighttime Foundation Sea Surface Temperature Analysis (GDS version 2)
%                  Geo_Polar_Blended_Night-OSPO-L4-GLOB-v1.0 | 2014-Jun-02 to present | 0.054 deg
%                  https://podaac.jpl.nasa.gov/dataset/Geo_Polar_Blended_Night-OSPO-L4-GLOB-v1.0
%   'k10'        : GHRSST Level 4 K10_SST Global 10 km Analyzed Sea Surface Temperature from NAVO in GDS2.0
%                  K10_SST-NAVO-L4-GLOB-v01 | 2019-Jan-09 to present | 0.1 deg
%                  https://podaac.jpl.nasa.gov/dataset/K10_SST-NAVO-L4-GLOB-v01
%   'mw_ir_oi'   : GHRSST Level 4 MW_IR_OI Global Foundation Sea Surface Temperature analysis version 5.1 from REMSS
%                  MW_IR_OI-REMSS-L4-GLOB-v5.1 | 2002-Jun-01 to present | 0.09 deg
%                  https://podaac.jpl.nasa.gov/dataset/MW_IR_OI-REMSS-L4-GLOB-v5.1
%   'mw_oi'      : GHRSST Level 4 MW_OI Global Foundation Sea Surface Temperature analysis version 5.1 from REMSS
%                  MW_OI-REMSS-L4-GLOB-v5.1 | 1997-Dec-31 to present | 0.25 deg
%                  https://podaac.jpl.nasa.gov/dataset/MW_OI-REMSS-L4-GLOB-v5.1
%
%   Variables (vars) : 'analysed_sst' (default), 'analysis_error', 'sea_ice_fraction', 'mask'
%                      mur, mur25 only: 'sst_anomaly' (mur only: 'dt_1km_data')
%
%% [2-1] Earthdata token setup (once per MATLAB session)
%  [Step 1] Create a NASA Earthdata account: https://urs.earthdata.nasa.gov/users/new
%  [Step 2] Log in at https://urs.earthdata.nasa.gov/
%  [Step 3] Click the "Generate Token" tab, then press "Generate Token".
%  [Step 4] Copy the long string that appears (usually starts with "eyJ...").
%  [Step 5] Paste it between the quotation marks below, remove the leading "%", and run this section.
%
% setenv('EARTHDATA_TOKEN', 'paste-your-token-here');
%
%  NOTES : the token lasts only for the current MATLAB session (repeat Step 5 after restarting MATLAB),
%          expires after about 60 days (go back to Step 3 if "Authentication failed" appears),
%          and must be removed from this script before sharing it.
if isempty(getenv('EARTHDATA_TOKEN'))
    warning('EARTHDATA_TOKEN is not set. Complete Steps 1 to 5 above.');
else
    disp('Token is set.');
end

%% [2-2] GHRSST L4 download
clc; clear;

source = 'ostia';                             % input name from the list above
period       = [2018, 8, 1; 2018, 8, 31];     % [start y,m,d ; end y,m,d]
Spatial_area = [22, 54, 118, 144];            % [lat start, lat end, lon start, lon end] (lon: -180 to 180)
vars         = {'analysed_sst'};              % variables to download
out_dir      = fullfile(pwd, 'GHRSST', source);

failed = func_podaac_down_Jiuk(source, period, Spatial_area, out_dir, vars);
if ~isempty(failed), disp(failed); end     % run this section again to retry failed dates

% Browser method (no token): out_dir must be the browser download folder.
% out_dir = fullfile(getenv('USERPROFILE'), 'Downloads');
% failed  = func_podaac_down_Jiuk(source, period, Spatial_area, out_dir, vars, 'browser', 3);