# PH1_PLET_tool
Status: onboarding the tool in EDITO, testing data pipelines and implementation strategy.

## Data sources
### DASSH
This tool uses as input any CSV file output from the Plankton Lifeform Extraction Tool (PLET) available on DASSH: https://www.dassh.ac.uk/lifeforms/  
The PLET aggregates the plankton abundance datasets to lifeforms per month for a user-defined spatial area (rectangle or polygon) using a Master Taxa List of functional traits. 

### European Digital Twin of the Ocean
In the DTO-Bioflow project, a pipeline was tested to extract and prepare the data for PLET tool using EDITO. 


## PLET tool
This script uses the PLET export data to calculate the lifeform pairs indicator and to calculate the Kendall statistic for a 
user-specified range in the time-series for all lifeforms and relevant lifeform pairs contained in the dataset. It then outputs this information as a set
of figures to aid in understanding patterns and trends in plankton lifeform abundance.

There are two folders, "R" and "data". The folder "R" contains the scripts for running the tool. It is recomended to run the "R.proj" file (an R project file)
before opening the R Notebooks script "PH1-FW5_indicator_script" within R-Studio. This ensures that the working directory will automatically be set appropriately.
This "R" folder also contains a subdirectory "Supporting_scripts", which contains R files holding a set of functions necessary for running the indicator script.
It is recommended not to modify the files in this folder unless the user is expreienced with writing functions in R.

The "data" directory contains the CSV file downloaded from PLET for which the indicator is being calculated. There is already a prepared CSV file in this folder, 
entitled "lifeforms.csv", which was downloaded from the PLET. This file is a lifeform abundance time-series from the Continuous Plankton Recorder (CPR) dataset 
for the centre of the North Sea. This file can be replaced with any lifeform CSV exported from the PLET.

The reference and comparison period of the assessment can also be modified in the first chunk of the script. These periods must be distinct (i.e. periods do not
contain any of the same years of data). The minimum and maximum years used to define these two distinct periods are also used to define the temporal limits for the
whole of the analysis. 

Output figures will be written to an "output" folder contained within the main directory.

## Credits
The PLET too is developed by Matthew Holland and the original version is maintained on his [GitHub](https://github.com/hollam2/PH1_PLET_tool).

The modifications and extension for deployment in EDITO are developed by Willem Boone [GitHub](https://github.com/willem0boone/PH1_PLET_tool/tree/master)