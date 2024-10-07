# GHRSST data download with MATLAB

How to use this code?
1. Set the small area and just one day to prepare.
2. After running the code, you see the white internet window with "Log in."
3. You should "Log in" for "[NASA Earthdata](https://www.earthdata.nasa.gov/)" for the first time. 
4. After "Log in", you set the area and period you want. And just run!

Target data : OSITA v2, OSTIA Reprocessed, MUR 4.1, MUR 4.2 and OISST v2

1. The sources of OSTIA and MUR are [PO.DAAC Homepage](https://podaac.jpl.nasa.gov/cloud-datasets).
2. The source of OISST is [psl.noaa](https://psl.noaa.gov/data/gridded/data.noaa.oisst.v2.highres.html)
3. OSTIA v2 in PODAAC and OSTIA Analysis in CMEMS seem to same dataset.

   [PO.DAAC](https://podaac.jpl.nasa.gov/dataset/OSTIA-UKMO-L4-GLOB-v2.0)

   [CMEMS](https://data.marine.copernicus.eu/product/SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001/description)
   
4. The PDF file "Manual_for_download_data_from_PODAAC_using_MATLAB_(with_specific_Area_and_Period)" is the way that how I wrote the MATLAB script for downloading data from PODAAC. If you want more data from PODAAC, you could write a new MATLAB script using the manual.
