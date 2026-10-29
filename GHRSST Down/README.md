# SST Downloader: GHRSST L4 (PO.DAAC) and OISST, subset by area and period

MATLAB scripts that download daily sea surface temperature (SST) for a user-defined area and period directly from the data servers via OPeNDAP. Only the requested subset is transferred, so a regional time series can be built without downloading global files.

**Data sources**

- 11 GHRSST Level 4 analyses from [PO.DAAC](https://podaac.jpl.nasa.gov/cloud-datasets) (NASA Earthdata)
- NOAA OISST v2 High Resolution from [NOAA PSL](https://psl.noaa.gov/data/gridded/data.noaa.oisst.v2.highres.html)


![Alt text](https://github.com/kamanberr/Ocean-Data-Download/blob/main/GHRSST%20Down/GHRSST_EastAsiaMarginalSea%20v2.png) 

## Files

| File | Purpose |
|---|---|
| `GHRSST_down_HOME_2_Jiuk.m` | Main script. Set the dataset, area and period here and run section by section. |
| `func_OISST_down_Jiuk.m` | Downloads OISST v2 and saves one file per day (MAT or NetCDF). |
| `func_podaac_down_Jiuk.m` | Downloads any of the 11 GHRSST L4 datasets from PO.DAAC and saves one NetCDF file per day. |


## Supported datasets

The first column is the `source` name passed to `func_podaac_down_Jiuk`.

| Input name | Dataset (short name) | Period | Grid | Link |
|---|---|---|---|---|
| `ostia` | OSTIA Global Foundation SST Analysis (OSTIA-UKMO-L4-GLOB-v2.0) | 2006-12-31 to present | 0.05° | [link](https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-v2.0) |
| `ostia_rep` | OSTIA Global Historical Reprocessed Foundation SST Analysis (OSTIA-UKMO-L4-GLOB-REP-v2.0) | 1982-01-01 to 2023-12-31 | 0.05° | [link](https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-REP-v2.0) |
| `mur` | MUR Global Foundation SST Analysis v4.1 (MUR-JPL-L4-GLOB-v4.1) | 2002-05-31 to present | 0.01° | [link](https://podaac.jpl.nasa.gov/dataset/MUR-JPL-L4-GLOB-v4.1) |
| `mur25` | MUR 0.25deg Global Foundation SST Analysis v4.2 (MUR25-JPL-L4-GLOB-v04.2) | 2002-08-31 to present | 0.25° | [link](https://podaac.jpl.nasa.gov/dataset/MUR25-JPL-L4-GLOB-v04.2) |
| `gamssa` | GAMSSA 28km Global Foundation SST Analysis v1.0 (GAMSSA_28km-ABOM-L4-GLOB-v01) | 2008-07-23 to present | 0.25° | [link](https://podaac.jpl.nasa.gov/dataset/GAMSSA_28km-ABOM-L4-GLOB-v01) |
| `dmi` | DMI_OI Global Foundation SST Analysis (DMI_OI-DMI-L4-GLOB-v1.0) | 2013-04-30 to present | 0.05° | [link](https://podaac.jpl.nasa.gov/dataset/DMI_OI-DMI-L4-GLOB-v1.0) |
| `ospo` | OSPO Geo-Polar Blended Global Foundation SST Analysis (Geo_Polar_Blended-OSPO-L4-GLOB-v1.0) | 2014-06-02 to present | 0.054° | [link](https://podaac.jpl.nasa.gov/dataset/Geo_Polar_Blended-OSPO-L4-GLOB-v1.0) |
| `ospo_night` | OSPO Geo-Polar Blended Global Nighttime Foundation SST Analysis (Geo_Polar_Blended_Night-OSPO-L4-GLOB-v1.0) | 2014-06-02 to present | 0.054° | [link](https://podaac.jpl.nasa.gov/dataset/Geo_Polar_Blended_Night-OSPO-L4-GLOB-v1.0) |
| `k10` | K10_SST Global 10 km Analyzed SST from NAVO (K10_SST-NAVO-L4-GLOB-v01) | 2019-01-09 to present | 0.1° | [link](https://podaac.jpl.nasa.gov/dataset/K10_SST-NAVO-L4-GLOB-v01) |
| `mw_ir_oi` | MW_IR_OI Global Foundation SST Analysis v5.1 from REMSS (MW_IR_OI-REMSS-L4-GLOB-v5.1) | 2002-06-01 to present | 0.09° | [link](https://podaac.jpl.nasa.gov/dataset/MW_IR_OI-REMSS-L4-GLOB-v5.1) |
| `mw_oi` | MW_OI Global Foundation SST Analysis v5.1 from REMSS (MW_OI-REMSS-L4-GLOB-v5.1) | 1997-12-31 to present | 0.25° | [link](https://podaac.jpl.nasa.gov/dataset/MW_OI-REMSS-L4-GLOB-v5.1) |
| (OISST) | NOAA OI SST V2 High Resolution, daily mean | 1981-09-01 to present | 0.25° | [link](https://psl.noaa.gov/data/gridded/data.noaa.oisst.v2.highres.html) |

All GHRSST datasets above are daily, global, GDS2-compliant Level 4 analyses. 
OSTIA v2 on PO.DAAC appears to be the similar product as the OSTIA analysis distributed by [CMEMS](https://data.marine.copernicus.eu/product/SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001/description).

## How to use

### OISST (no account required)

1. Open `GHRSST_down_HOME_2_Jiuk.m`, section **[1] OISST v2**.
2. Set `period`, `Spatial_area` and `file_type` (`'mat'` or `'nc'`), then run the section.

### GHRSST L4 from PO.DAAC (Earthdata token required)

1. Create a free [NASA Earthdata](https://urs.earthdata.nasa.gov/users/new) account if you do not have one.
2. Log in at https://urs.earthdata.nasa.gov/, open the **Generate Token** tab and press **Generate Token**. Copy the token string.
3. In section **[2-1]** of the main script, paste the token into `setenv('EARTHDATA_TOKEN', '...')` and run the section. The token is kept only for the current MATLAB session and expires after about 60 days.
4. In section **[2-2]**, choose a dataset by its input name, set `period`, `Spatial_area` and `vars`, then run.

On the first run of each dataset the longitude and latitude grid is downloaded once and cached in `grid/` next to the function, so no sample files are needed.

A browser-based method (`method = 'browser'`) is also available for users who prefer the Earthdata login window as in the previous version. See the comments at the end of section [2-2].

### Options

- `Spatial_area = [lat_start, lat_end, lon_start, lon_end]`. OISST accepts any longitude range, including global (`[-180 180]`) and domains crossing 0°E. GHRSST datasets use −180 to 180 and do not support domains crossing the dateline.
- `vars` selects the GHRSST variables: `'analysed_sst'` (default), `'analysis_error'`, `'sea_ice_fraction'`, `'mask'`, and for MUR `'sst_anomaly'` (`'dt_1km_data'` for `mur` only).

## Output

- GHRSST: one NetCDF-4 file per day, named as the original granule (for example `20230801120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.0-fv02.0.nc4`), containing only the requested area and variables. `analysed_sst` is in Kelvin.
- OISST: one file per day, `OISST_v2_yyyy_MM_dd.mat` (struct `oisst` with `time`, `lon`, `lat`, `sst`) or `OISST_v2_yyyy_MM_dd.nc`. `sst` is in degrees Celsius.

Files that already exist are skipped, so an interrupted download can be resumed by running the same section again. Dates that could not be downloaded are returned by the functions and printed at the end; running the section once more retries only those dates.

## Acknowledgements

Automatic re-download of dates that failed during the download was originally contributed by Yunji Noh.

## Version history

- 2024-10: First release (OSTIA v2, OSTIA Reprocessed, MUR 4.1, MUR 4.2, OISST v2) using the browser login method.
- 2026-10: Token-based download with file verification and automatic retry; 11 GHRSST L4 datasets; variable selection; automatic grid caching; OISST output as MAT or NetCDF; global and 0°E-crossing OISST domains; test script.
