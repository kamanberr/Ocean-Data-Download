### Summary
Download regional subsets of ETOPO 2022, SRTM15+, and S2Shores bathymetry directly in MATLAB, with flexible longitude conventions and MAT or netCDF output.

### Description
This script retrieves regional subsets of three global bathymetry products without downloading the full global grids. Only the requested region is transferred from the data server, which keeps downloads fast even at high resolution.

### Supported datasets:
ETOPO 2022 bedrock elevation (NOAA NCEI), at 30 or 60 arc-second resolution, accessed through the NCEI THREDDS OPeNDAP service.
SRTM15+ V2.4 (15 arc-second), accessed through the Rutgers ERDDAP server, with an optional stride for coarser sampling of large regions.
S2Shores global coastal bathymetry (CNES-LEGOS, 30 arc-second), derived from Sentinel-2 wave inversion and accessed through the AVISO/ODATIS THREDDS server. Both the satellite-derived depth and the version blended with GEBCO 2020 are available. An AVISO+ account is required (see below).

### Key features:
Longitude may be specified in either the −180~180 or the 0~360 convention, regardless of how the source dataset is stored. Regions that cross the dateline or the prime meridian are handled automatically, and the saved longitude follows the convention of the input (for example, 170~190).
All datasets share a common output layout, so the same post-processing code can be applied to any of them. MAT files contain the data grid [nlon × nlat] together with bedlon and bedlat (ascending). netCDF output is a compressed netCDF-4 file with CF-style units, variable descriptions, and source metadata.
Variable names reflect the sign convention. ETOPO 2022 and SRTM15+ are stored as bed (elevation, positive up), whereas S2Shores is stored as depth (positive below mean sea level), following the source dataset. Use -depth when comparing the two.
SRTM15+ can also be retrieved as CSV, PNG, or PDF rendered by ERDDAP, provided the region does not cross the dataset’s longitude seam.
Inputs are validated before any connection is made, and output files are named with hemisphere tags (for example, ETOPO2022_bedrock_60arc_22N-54N_118E-144E.mat).

Usage: set the region [lat start, lat end, lon start, lon end], the resolution or stride, the output format, and the destination folder in the corresponding section, then run that section.

S2Shores authentication: the AVISO THREDDS server requires a registered AVISO+ account with access to the S2Shores product. Credentials are read, in order of priority, from the function arguments, from the environment variables AVISO_USERNAME and AVISO_PASSWORD, or from a .netrc file referenced by .dodsrc. Setting the environment variables in startup.m avoids writing credentials in the script. Credentials are used only for the request and are never written to output files.

Notes:
ETOPO 2022 and SRTM15+ are cell-centered (pixel-registered) grids. When integer boundaries are requested, the first grid point lies half a cell inside the boundary.
According to its data descriptor, S2Shores is most reliable at intermediate depths (10–40 m) in coasts with moderate to high wave energy, and less reliable in very shallow intertidal zones, low-energy or fetch-limited basins, regions with strong currents, and beyond the effective sensing depth of the method. Users are advised to consult the original publication before applying it to a specific region.

### Data sources (please cite the original datasets when using them):
NOAA National Centers for Environmental Information. 2022: ETOPO 2022 15 Arc-Second Global Relief Model. NOAA National Centers for Environmental Information. DOI: 10.25921/fd45-gt74. Accessed [date].
Tozer, B., Sandwell, D. T., Smith, W. H., Olson, C., Beale, J. R., & Wessel, P. (2019). Global bathymetry and topography at 15 arc sec: SRTM15+. Earth and space science, 6(10), 1847-1864.
Almar, R., Bergsma, E. W. J., Thoumyre, G., Giros, A., Marchesiello, P., Lemai-Chenevier, S., Artigues, S., Loyer, S., & Delvit, J.-M. (2025). Global 1-km coastal bathymetry from Sentinel-2 wave inversion using the Satellite-to-Shores (S2Shores) toolbox. Scientific Data, 12, 1941. doi:10.1038/s41597-025-06402-w
Dataset: The global 1-km coastal bathymetry dataset produced by the S2Shores framework. CNES / Theia-Hydroweb Data Portal. doi:10.24400/329360/S2SHORES_COASTAL_BATHYMETRY

The below figures are examples of bathymetry using the data from this script.

### ETOPO 2022 30 arc
<img src="https://github.com/user-attachments/assets/e51eb5a4-2bbe-4dff-bbed-f6e332fe5bf2" width="600"/>

### ETOPO 2022 60 arc
<img src="https://github.com/user-attachments/assets/efc30235-712b-499a-8a43-a777f841c035" width="600"/>

### SRTM 15+
<img src="https://github.com/user-attachments/assets/940b7484-211b-400e-8cf1-65f5d7484548" width="600"/>


