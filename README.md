# StateOfTheSoftbottomMacrofaunaCommunity
Repository for R scripts used for calculating HELCOM State of the soft-bottom macrofauna community indicator
## Introduction
The HELCOM core indicator State of the soft-bottom macrofauna community is used to assess the status of benthic habitats in the HELCOM Holistic Assessment of the Baltic Sea. The indicator report with information on indicator concept and results can be found on the HELCOM website ([link](https://helcom.fi/baltic-sea-trends/indicators/)).
## Scripts
This repository includes two scripts for calculation of the State of the soft-bottom macrofauna community indicator. 
#### _BQI_script.R_
This script assigns the samples to relevant species sensitivity lists and calculates sample-specific BQI-values.
#### _BQI_assessment.R_
This script performs an assessment of the indicator for each HELCOM sub-basin, based on the BQI-values calculated using the BQI script. 
## Indicator data
The indicator use data collected as part of the [HELCOM COMBINE monitoring program](https://helcom.fi/action-areas/monitoring-and-assessment/monitoring-guidelines/combine-manual/). Data are reported to the COMBINE database maintained by ICES and accessible through the [ICES Data Portal](https://data.ices.dk/). The indicator calculation script here use data extracts from the COMBINE database.
## Input files
Input files needed for the indcator calculations, as well as an example data set, are found in the input folder.
#### _ZB_HELCOM_20162020.txt_ - Input data 
An example data file, containing a data extract from the COMBINE database at ICES. The indicator is calculated using species abundances per sample. Sample metadata such as sampling station, coordinates, depth, HELCOM subbasin, sampling gear and sieve mesh size need to be included.
#### _SensitivityLists.csv_ - Lists of species sensitivies used in BQI calculation 
The species sensitivity values are based on [Schiele et al. 2016](https://doi.org/10.1093/icesjms/fsv265) (EIG1-19) and [Leonardsson et al. 2009](https://doi.org/10.1016/j.marpolbul.2009.05.007) (ES_SWE). The script assigns samples to the relevant sensitivity list based on coordinates, HELCOM sub-basin, depth, sample area and sieve mesh size. Samples are divided into subsets depending on the species sensitivity list assigned. 
#### _raster_salmean.txt_ - Mean salinity raster
To assign correct list of species sensitivity values, information on salinity is needed. The HELCOM indicator utilizes the EUSeaMap mean salinity map, which is found as a raster layer in the input file. Sample coordinates are used to extract the relevant salinity value from the raster.
#### _SubsetThresholds.csv_ - Threshold values and minimum-maximum values for the subsets 
If several subsets (species sensitivity lists) are used in the same assessment unit, BQI values need to be normalized based on minimum, maximum and threshold values before indicator assessment at assessment unit level. Threshold values are also needed for the indicator assessment. 
#### _StationClusters.csv_ - Grouping of stations for spatially balancing the data
For spatially balancing the assessment and to correct for differences in monitoring strategies, nearby stations are clustered into geographical sub-areas for the assessment. Assigning stations to sub-areas need to be done manually and inserted in the input file unisng a unique label for each sub-area. The input file utilizes station codes from ICES station dictionary to facilitate station mapping.
## Output files
The script produces the following output files, which can be found in the output folder:
#### _BQI_result.csv_
BQI values calculated for each sample included 
#### _Assessment_result.csv_
The sub-basin specific assessment result
## References

