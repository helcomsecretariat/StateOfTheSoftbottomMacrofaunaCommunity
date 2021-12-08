#########################################################################################
###   HELCOM Core indicator "State of the softbottom macrofauna community" R-script   ###
###   for sub-basin assessments based on BQI							  ###
###														  ###
###   Developed within the "Baltic Data Flows" project, funded by the EU Innovation   ###
###   and Networks Agency (INEA) via CEF funding instrument.				  ###
###   Project information: https://balticdataflows.helcom.fi/				  ###
#########################################################################################

rm(list=ls())
options(max.print=50000000)

## Set working directory where input/output folders are located
#setwd("D:/ ...")

## load necessary libraries
library(dplyr)

## Read the files needed
# BQI_results.csv is the output file from the BQI calculation script (BQI_script.r) 
BQIdata <- read.csv(file = "./output/BQI_result.csv", header=TRUE)
Thresholds <- read.csv(file = "./input/SubsetThresholds.csv", sep=";", header=TRUE)
Clusters <- read.csv(file = "./input/StationClusters.csv", sep=";", header=TRUE)

## Filter sub-basins to be included in assessment (exclude coastal stations and stations below halocline and sub-basins without threshold). 
# Make sure stations to be included in assessment although located in coastal area are included. 
AssessmentData <- filter(BQIdata[BQIdata$HELCOM_L4 == "SEA-017" |
					   BQIdata$HELCOM_L4 == "SWE-023" |
					   BQIdata$HELCOM_L4 == "SEA-016" |
					   BQIdata$HELCOM_L4 == "SWE-021" |
					   BQIdata$HELCOM_L4 == "SEA-015" |
					   BQIdata$HELCOM_L4 == "SWE-017" |
					   BQIdata$HELCOM_L4 == "SWE-019" |
					   BQIdata$HELCOM_L4 == "SEA-014" |
					   BQIdata$STATN == "F69" |
					   BQIdata$HELCOM_L4 == "SEA-012" &
					   BQIdata$WADEP <= 60 |
					   BQIdata$HELCOM_L4 == "SWE-015" |
					   BQIdata$HELCOM_L4 == "SEA-013" &
					   BQIdata$WADEP <= 60 |
					   BQIdata$HELCOM_L4 == "SEA-011" |
					   BQIdata$HELCOM_L4 == "SEA-010" &
					   BQIdata$WADEP <= 60 |
					   BQIdata$HELCOM_L4 == "SWE-008" |
					   BQIdata$HELCOM_L4 == "SWE-014" |
					   BQIdata$HELCOM_L4 == "SEA-009" &
					   BQIdata$WADEP <= 60 |
					   BQIdata$HELCOM_L4 == "SWE-009" |
					   BQIdata$HELCOM_L4 == "SEA-005",])

## Add station code to samples lacking station code
# Find samples lacking station code. Check the list and add unique station codes (also add in StationClusters.csv)
no_st_code <- AssessmentData[is.na(AssessmentData$SD_station_code_All),]
no_st_code

# replace NA with cluster name for samples lacking station code (use same name as in StationClusters.csv)
# (if STATN is unique it can be used, otherwise use SampleID)
AssessmentData[AssessmentData$SampleID == 2173961,10] <- "LITH1"  
AssessmentData[AssessmentData$SampleID == 2290541,10] <- "LITH1"  
AssessmentData[AssessmentData$SampleID == 2290542,10] <- "LITH1"  
AssessmentData[AssessmentData$STATN == "OMMB2",10] <- "GER1"  
AssessmentData[AssessmentData$STATN == "OMMB8",10] <- "GER2"  

# Clusters for assessment
Cluster_match <- match(AssessmentData[,10], Clusters[,1])

for (i in 1:nrow(AssessmentData)) {
	AssessmentData[i,17] <- Clusters[Cluster_match[i],5]
}
colnames(AssessmentData)[17] <- "Cluster" 

# filter out coastal stations and stations below halocline
AssessmentData <- filter(AssessmentData[AssessmentData$Cluster != "c",])
AssessmentData <- filter(AssessmentData[AssessmentData$Cluster != "d",])


## Normalize BQI values based on threshold and max values (defined in Thresholds)
EIG_match <- match(AssessmentData[,5], Thresholds[,1])

for (i in 1:nrow(AssessmentData)){
	AssessmentData[i,18] <- as.numeric(Thresholds[EIG_match[i],2])
	AssessmentData[i,19] <- Thresholds[EIG_match[i],3]

	if (AssessmentData[i,4] <= AssessmentData[i,18]) {
		AssessmentData[i,20] <- (0.5 * (AssessmentData[i,4]/AssessmentData[i,18]))
	}
	else if (AssessmentData[i,4] > AssessmentData[i,18]) {
		AssessmentData[i,20] <- (0.5 + (0.5 * ((AssessmentData[i,4]-AssessmentData[i,18])/(AssessmentData[i,19]-AssessmentData[i,18]))))
	}
}
colnames(AssessmentData)[18] <- "Threshold"
colnames(AssessmentData)[19] <- "BQImax"
colnames(AssessmentData)[20] <- "normBQI"


## Define BQI values to be used in bootstrapping

for (i in 1:nrow(AssessmentData)) {
	if (AssessmentData[i,6] == "Bothnian Bay" || AssessmentData[i,6] == "The Quark" || 
			AssessmentData[i,6] == "Bothnian Sea" || AssessmentData[i,6] == "Åland Sea" ||
			AssessmentData[i,6] == "Northern Baltic Proper" || 
			AssessmentData[i,6] == "Western Gotland Basin") {
		AssessmentData[i,21] <- AssessmentData[i,4]
	}
	else {
		AssessmentData[i,21] <- AssessmentData[i,20]
	}
}


##### Bootstrap for assessment #####

# Set number of iterations (100000 used in HOLAS II)
iterations <- 100000			

# Split data per assessment unit
AssessmentData[,1] <- as.character(AssessmentData[,1])
AssessmentData[,6] <- as.character(AssessmentData[,6])
SAUs <- split(AssessmentData, AssessmentData$HELCOM_subbasin)

# Bootstrap for each sub-basin included in the assessment
for (k in 1:length(SAUs)) {
	bs_data <- SAUs[[k]]				
	SAU <- as.character(bs_data[1,6])		# name of sub-basin

	for (i in 1:iterations) { 
		for (j in 1:length(unique(bs_data[,10]))) {
			subarea <- sample(unique(bs_data[,17]), 1)
			station <- sample(unique(bs_data[bs_data$Cluster == subarea, 10]), 1)
			picked_sample <- sample(unique(bs_data[bs_data$SD_station_code == station, 1]),1)

			if (j==1) {
				picked_BQI <- bs_data[bs_data$SampleID == picked_sample, 21]
			}
			else {
				picked_BQI <- c(picked_BQI, bs_data[bs_data$SampleID == picked_sample, 21])
			}
		}

		if (i==1) {
			mean_BQI <- mean(picked_BQI)
		}
		else {
			mean_BQI <- c(mean_BQI, mean(picked_BQI))
		}
	}

	Assessment_Result <- quantile(mean_BQI, .20)
	Number_stations <- length(unique(bs_data[,10]))
	Number_clusters <- length(unique(bs_data[,17]))
		
# Collect results and information on assessment
	SAU_result <- c(SAU, Assessment_Result, Number_clusters, Number_stations)

	if (k == 1) {
		result_table <- SAU_result
		mean_BQI_table <- mean_BQI
	}
	else {
		result_table <- rbind(result_table, SAU_result)
		mean_BQI_table <- cbind(mean_BQI_table, mean_BQI)
	}
}

colnames(result_table) <- c("Assessment unit", "Assessment result", "Number of clusters", "Number of stations")
colnames(mean_BQI_table) <- result_table[,1]

## Save results as csv-files
write.csv(result_table, "./output/Assessment_result.csv", row.names=FALSE)
write.csv(mean_BQI_table, "./output/resample_mean_BQI.csv", row.names=FALSE)

